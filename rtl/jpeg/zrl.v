`define DLY #1

module zrl(
    // global
    clk                 , // <i>  1b, global clock
    rstn                , // <i>  1b, global reset, active low
    // frame control
    frame_start         , // <i>  1b, frame end indicator
    frame_end           , // <i>  1b, frame end indicator
    // input quantized data
    q_data              , // <i> 11b, zigzag data output
    q_data_valid        , // <i>  1b, zigzag data output valid
    // DC output
    dc_coeff_out_valid  , // <o>  1b, dc coeff output valid
    dc_coeff            , // <o> 12b, dc_coeff output
    // AC output
    ac_coeff_out_valid  , // <o>  1b, ac coeff output valid
    ac_coeff            , // <o> 12b, ac coeff output
    run_length          , // <o>  4b, run length
    eob_out               // <o>  1b, end of block indicator
    );

  // global
  input         clk                 ; // <i>  1b, global clock
  input         rstn                ; // <i>  1b, global reset, active low
  // frame control
  input         frame_start         ; // <i>  1b, frame end indicator
  input         frame_end           ; // <i>  1b, frame end indicator
  // input quantized data
  input  [10:0] q_data              ; // <i> 11b, zigzag data output
  input         q_data_valid        ; // <i>  1b, zigzag data output valid
  // DC output
  output        dc_coeff_out_valid  ; // <o>  1b, dc coeff output valid
  output [11:0] dc_coeff            ; // <o> 12b, dc_coeff output
  // AC output
  output        ac_coeff_out_valid  ; // <o>  1b, ac coeff output valid
  output [11:0] ac_coeff            ; // <o> 12b, ac coeff output
  output [3:0]  run_length          ; // <o>  4b, run length
  output        eob_out             ; // <o>  1b, end of block indicator

  reg    [5:0]  data_in_cnt         ; // count the input data
  wire          eob                 ; // end of block indicator
  wire          dc_coeff_in_valid   ; // dc coeff input valid
  wire   [11:0] dc_diff             ; // diff of dc data
  reg    [10:0] dc_pre              ; // previous dc value
  wire          ac_coeff_neq0       ; // ac coeff not equal to 0
  reg    [5:0]  run_length_cnt      ; // run length counter
  wire          run_length_valid    ; // run length data valid

  wire          zrl_fifo_wr         ;
  wire          zrl_fifo_rd         ;
  wire   [19:0] zrl_fifo_din        ;
  wire   [19:0] zrl_fifo_dout       ;
  wire          zrl_fifo_empty      ;

  reg           coeff_is_dc_fdout   ; // fifo output coeff is dc coeff
  reg           eob_fdout           ; // fifo output data is eob
  reg    [11:0] coeff_fdout         ; // fifo output coeff data
  reg    [5:0]  length_fdout        ; // fifo output run length data

  reg           zrl_fifo_ext_valid  ; // zrl fifo extend data valid

  wire          length_fdout_ge_16  ; // run_length from fifo greater than or equal to 16
  wire          length_fdout_lt_16  ; // run_length from fifo less than 16

  wire          zrl_data_flush      ; // zrl_fifo extend data flush enable

  parameter DC_TYPE = 1'b1;
  parameter AC_TYPE = 1'b0;

  // input data count
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          data_in_cnt <= `DLY 6'h0;
      end
      else if (q_data_valid) begin
          data_in_cnt <= `DLY data_in_cnt + 6'h1;
      end
  end

  // end of block indicator
  assign eob = (data_in_cnt == 6'h3F) & q_data_valid;

  // dc coeff input valid
  assign dc_coeff_in_valid = (data_in_cnt == 6'h0) & q_data_valid;

  // calc diff of dc coeff
  assign dc_diff = {q_data[10], q_data} - {dc_pre[10], dc_pre};

  // save the previous dc coeff
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dc_pre <= `DLY 11'h0;
      end
      else if (frame_start | frame_end) begin
          dc_pre <= `DLY 11'h0;
      end
      else if (dc_coeff_in_valid) begin
          dc_pre <= `DLY q_data;
      end
  end

  // ac coeff not equal to 0
  assign ac_coeff_neq0 = (q_data != 11'h0);

  // count the run length
  //   count until a non-zero value even if run_length_cnt >= 16,
  //   to reduce not necessary F/0(ZRL)
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          run_length_cnt <= `DLY 6'h0;
      end
      else if (eob) begin
          run_length_cnt <= `DLY 6'h0;
      end
      else if (q_data_valid) begin
          if (ac_coeff_neq0) begin
              run_length_cnt <= `DLY 6'h0;
          end
          else if (~dc_coeff_in_valid) begin
              run_length_cnt <= `DLY run_length_cnt + 6'h1;
          end
      end
  end

  // run length valid when ac_coeff not equal to 0, or at the end of block
  assign run_length_valid = (q_data_valid & ac_coeff_neq0) | eob;

  // save the coeff and run_length_cnt in fifo, since when run_length_cnt >= 16
  // and not an eob is assert, more than 1 clock cycle is needed to generate
  // one or more F/0(ZRL) and a normal ZRL symbol
  fifo #(20,    // FIFO_DW
         3 ,    // FIFO_AW
         8 )    // FIFO_DEPTH
  zrl_fifo(
    // global
    .clk                (clk            ), // <i>  1b, global clock
    .rstn               (rstn           ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (zrl_fifo_wr    ), // <i>  1b, fifo write enable
    .din                (zrl_fifo_din   ), // <i>    , fifo data input
    .full               (/*floating*/   ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (zrl_fifo_rd    ), // <o>  1b, fifo read enable
    .dout               (zrl_fifo_dout  ), // <o>    , fifo data output
    .empty              (zrl_fifo_empty )  // <o>  1b, fifo empty indicator
    );

  assign zrl_fifo_wr = dc_coeff_in_valid | run_length_valid;
  assign zrl_fifo_din = dc_coeff_in_valid ? {DC_TYPE, 1'b0, dc_diff             , 6'h0          } :
                                            {AC_TYPE, eob , {q_data[10], q_data}, run_length_cnt} ;
  assign zrl_fifo_rd = ~zrl_fifo_empty & (~zrl_fifo_ext_valid | zrl_data_flush);

  // fifo output coeff is dc or not
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          coeff_is_dc_fdout <= `DLY 1'b0;
      end
      else if (zrl_fifo_rd) begin
          coeff_is_dc_fdout <= `DLY zrl_fifo_dout[19];
      end
  end

  // fifo output coeff is eob or not
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          eob_fdout <= `DLY 1'b0;
      end
      else if (zrl_fifo_rd) begin
          eob_fdout <= `DLY zrl_fifo_dout[18];
      end
  end

  // fifo output coeff
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          coeff_fdout <= `DLY 12'h0;
      end
      else if (zrl_fifo_rd) begin
          coeff_fdout <= `DLY zrl_fifo_dout[17:6];
      end
  end

  // fifo output run length
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          length_fdout <= `DLY 6'h0;
      end
      else if (zrl_fifo_rd) begin
          length_fdout <= `DLY zrl_fifo_dout[5:0];
      end
      else if (ac_coeff_out_valid) begin
          length_fdout <= `DLY length_fdout - 6'h10;
      end
  end

  // fifo output extend data valid
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          zrl_fifo_ext_valid <= `DLY 1'b0;
      end
      else if (zrl_fifo_rd) begin
          zrl_fifo_ext_valid <= `DLY 1'b1;
      end
      else if (zrl_data_flush) begin
          zrl_fifo_ext_valid <= `DLY 1'b0;
      end
  end

  // run_length greater than or equal to 16
  assign length_fdout_ge_16 = (|length_fdout[5:4]);
  // run_length less than 16
  assign length_fdout_lt_16 = ~length_fdout_ge_16;

  // flush the extend data from fifo output
  assign zrl_data_flush = dc_coeff_out_valid | (ac_coeff_out_valid & ((eob_fdout & (coeff_fdout == 12'h0)) | length_fdout_lt_16));

  // output signals
  assign dc_coeff_out_valid = zrl_fifo_ext_valid & coeff_is_dc_fdout;
  assign ac_coeff_out_valid = zrl_fifo_ext_valid & ~coeff_is_dc_fdout;
  assign dc_coeff = coeff_fdout;
  assign ac_coeff = length_fdout_ge_16 ? 4'h0 : coeff_fdout;
  assign run_length = (eob_fdout & (coeff_fdout == 12'h0)) ? 4'h0 :
                      length_fdout_ge_16                   ? 4'hF :
                      length_fdout[3:0]; 
  assign eob_out = eob_fdout & ((coeff_fdout == 12'h0) | length_fdout_lt_16);

endmodule

