`define DLY #1

module dct(
    // global signals
    clk             , // <i>  1b, global clock
    rstn            , // <i>  1b, global reset, active low
    // frame control
    frame_start     , // <i>  1b, frame end indicator
    frame_end       , // <i>  1b, frame end indicator
    // pixel data input
    pixel_data_in   , // <i> 24b, pixel data input
    pixel_in_valid  , // <i>  1b, pixel data input valid
    // output 8 points data
    dct_data_out    , // <o> 42b, dct data output
    dct_out_valid     // <o>  1b, dct data output valid
    );

  // global signals
  input         clk             ; // <i>  1b, global clock
  input         rstn            ; // <i>  1b, global reset, active low
  // frame control
  input         frame_start     ; // <i>  1b, frame end indicator
  input         frame_end       ; // <i>  1b, frame end indicator
  // pixel data input
  input  [23:0] pixel_data_in   ; // <i> 24b, pixel data input
  input         pixel_in_valid  ; // <i>  1b, pixel data input valid
  // output 8 points data
  output [41:0] dct_data_out    ; // <o> 42b, dct data output
  output        dct_out_valid   ; // <o>  1b, dct data output valid

  reg           dct_out_valid   ;

  wire   [7:0]  pixel_in_y            ; // input data y
  wire   [7:0]  pixel_in_u            ; // input data u
  wire   [7:0]  pixel_in_v            ; // input data v
  reg    [2:0]  pixel_in_cnt          ; // input data count

  reg           pixel_in_valid_tail   ; // pixel in valid for extended tail
  reg    [7:0]  pixel_in_y_prev       ; // save previous y data for boundary extend
  reg    [7:0]  pixel_in_u_prev       ; // save previous u data for boundary extend
  reg    [7:0]  pixel_in_v_prev       ; // save previous v data for boundary extend

  wire   [7:0]  pixel_in_y_ext        ; // y data input after extend
  wire   [7:0]  pixel_in_u_ext        ; // u data input after extend
  wire   [7:0]  pixel_in_v_ext        ; // v data input after extend

  wire          pixel_in_valid_ext    ; // pixel input valid after extend

  reg    [63:0] y_in_line_buf         ; // y input line buffer
  reg    [63:0] u_in_line_buf         ; // u input line buffer
  reg    [63:0] v_in_line_buf         ; // v input line buffer
  reg           y_in_line_buf_valid   ; // y input line buffer valid
  wire          u_in_line_buf_valid   ; // u input line buffer valid
  wire          v_in_line_buf_valid   ; // v input line buffer valid

  wire   [7:0]  y_dctx_in_0           ; // y dctx input data 0
  wire   [7:0]  y_dctx_in_1           ; // y dctx input data 1
  wire   [7:0]  y_dctx_in_2           ; // y dctx input data 2
  wire   [7:0]  y_dctx_in_3           ; // y dctx input data 3
  wire   [7:0]  y_dctx_in_4           ; // y dctx input data 4
  wire   [7:0]  y_dctx_in_5           ; // y dctx input data 5
  wire   [7:0]  y_dctx_in_6           ; // y dctx input data 6
  wire   [7:0]  y_dctx_in_7           ; // y dctx input data 7
  wire          y_dctx_in_valid       ; // y dctx input data valid
  wire   [7:0]  u_dctx_in_0           ; // u dctx input data 0
  wire   [7:0]  u_dctx_in_1           ; // u dctx input data 1
  wire   [7:0]  u_dctx_in_2           ; // u dctx input data 2
  wire   [7:0]  u_dctx_in_3           ; // u dctx input data 3
  wire   [7:0]  u_dctx_in_4           ; // u dctx input data 4
  wire   [7:0]  u_dctx_in_5           ; // u dctx input data 5
  wire   [7:0]  u_dctx_in_6           ; // u dctx input data 6
  wire   [7:0]  u_dctx_in_7           ; // u dctx input data 7
  wire          u_dctx_in_valid       ; // u dctx input data valid
  wire   [7:0]  v_dctx_in_0           ; // v dctx input data 0
  wire   [7:0]  v_dctx_in_1           ; // v dctx input data 1
  wire   [7:0]  v_dctx_in_2           ; // v dctx input data 2
  wire   [7:0]  v_dctx_in_3           ; // v dctx input data 3
  wire   [7:0]  v_dctx_in_4           ; // v dctx input data 4
  wire   [7:0]  v_dctx_in_5           ; // v dctx input data 5
  wire   [7:0]  v_dctx_in_6           ; // v dctx input data 6
  wire   [7:0]  v_dctx_in_7           ; // v dctx input data 7
  wire          v_dctx_in_valid       ; // v dctx input data valid

  wire   [13:0] y_dctx_out_0          ; // y dctx output data 0
  wire   [13:0] y_dctx_out_1          ; // y dctx output data 1
  wire   [13:0] y_dctx_out_2          ; // y dctx output data 2
  wire   [13:0] y_dctx_out_3          ; // y dctx output data 3
  wire   [13:0] y_dctx_out_4          ; // y dctx output data 4
  wire   [13:0] y_dctx_out_5          ; // y dctx output data 5
  wire   [13:0] y_dctx_out_6          ; // y dctx output data 6
  wire   [13:0] y_dctx_out_7          ; // y dctx output data 7
  wire          y_dctx_out_valid      ; // y dctx output data valid
  wire   [13:0] u_dctx_out_0          ; // u dctx output data 0
  wire   [13:0] u_dctx_out_1          ; // u dctx output data 1
  wire   [13:0] u_dctx_out_2          ; // u dctx output data 2
  wire   [13:0] u_dctx_out_3          ; // u dctx output data 3
  wire   [13:0] u_dctx_out_4          ; // u dctx output data 4
  wire   [13:0] u_dctx_out_5          ; // u dctx output data 5
  wire   [13:0] u_dctx_out_6          ; // u dctx output data 6
  wire   [13:0] u_dctx_out_7          ; // u dctx output data 7
  wire          u_dctx_out_valid      ; // u dctx output data valid
  wire   [13:0] v_dctx_out_0          ; // v dctx output data 0
  wire   [13:0] v_dctx_out_1          ; // v dctx output data 1
  wire   [13:0] v_dctx_out_2          ; // v dctx output data 2
  wire   [13:0] v_dctx_out_3          ; // v dctx output data 3
  wire   [13:0] v_dctx_out_4          ; // v dctx output data 4
  wire   [13:0] v_dctx_out_5          ; // v dctx output data 5
  wire   [13:0] v_dctx_out_6          ; // v dctx output data 6
  wire   [13:0] v_dctx_out_7          ; // v dctx output data 7
  wire          v_dctx_out_valid      ; // v dctx output data valid

  reg    [87:0] y_dctx_out_buf        ; // buffer the output dctx data of y
  reg    [87:0] u_dctx_out_buf        ; // buffer the output dctx data of u
  reg    [87:0] v_dctx_out_buf        ; // buffer the output dctx data of v

  reg    [5:0]  block_buf_wr_cnt      ; // block buffer write count
  wire          block_buf_wr_done     ; // block buffer write done
  reg    [5:0]  block_buf_rd_cnt      ; // block buffer read count
  wire          block_buf_rd_done     ; // block buffer read done

  reg           block_buf_sel         ; // select current write to block buffer 0 or 1
  wire          block_buf_sel_nxt     ; // next value of block_buf_sel
  reg           block_buf_sel_d       ; // delay of block_buf_sel to sync with block_bufx_dout

  reg           block_buf0_wr         ; // block buffer 0 write enable
  reg           block_buf1_wr         ; // block buffer 1 write enable
  reg           block_buf0_rd         ; // block buffer 0 read enable
  reg           block_buf1_rd         ; // block buffer 1 read enable
  wire          block_buf_wr          ; // block buffer write enable
  wire          block_buf_rd          ; // block buffer read enable
  reg           block_buf_rd_d        ; // delay of block_buf0_rd and block_buf1_rd

  wire   [5:0]  block_buf0_waddr      ; // block buffer 0 write address
  wire   [5:0]  block_buf1_waddr      ; // block buffer 1 write address
  wire   [5:0]  block_buf0_raddr      ; // block buffer 0 read address
  wire   [5:0]  block_buf1_raddr      ; // block buffer 1 read address
  wire   [5:0]  block_buf0_addr       ; // block buffer 0 address
  wire   [5:0]  block_buf1_addr       ; // block buffer 1 address

  wire   [32:0] block_buf_din         ; // block buffer data input
  wire   [32:0] block_buf0_dout       ; // block buffer 0 data output
  wire   [32:0] block_buf1_dout       ; // block buffer 1 data output
  wire   [32:0] block_buf_dout        ; // block buffer data output

  reg    [2:0]  dcty_in_cnt           ; // dcty input data count

  reg    [87:0] y_dcty_in_line_buf    ; // input line buffer of dcty y data
  reg    [87:0] u_dcty_in_line_buf    ; // input line buffer of dcty u data
  reg    [87:0] v_dcty_in_line_buf    ; // input line buffer of dcty v data

  reg           y_dcty_line_buf_valid ; // line buffer of dcty y data valid
  wire          u_dcty_line_buf_valid ; // line buffer of dcty u data valid
  wire          v_dcty_line_buf_valid ; // line buffer of dcty v data valid

  wire   [10:0] y_dcty_in_0           ; // y dcty input data 0
  wire   [10:0] y_dcty_in_1           ; // y dcty input data 1
  wire   [10:0] y_dcty_in_2           ; // y dcty input data 2
  wire   [10:0] y_dcty_in_3           ; // y dcty input data 3
  wire   [10:0] y_dcty_in_4           ; // y dcty input data 4
  wire   [10:0] y_dcty_in_5           ; // y dcty input data 5
  wire   [10:0] y_dcty_in_6           ; // y dcty input data 6
  wire   [10:0] y_dcty_in_7           ; // y dcty input data 7
  wire          y_dcty_in_valid       ; // y dcty input data valid
  wire   [10:0] u_dcty_in_0           ; // u dcty input data 0
  wire   [10:0] u_dcty_in_1           ; // u dcty input data 1
  wire   [10:0] u_dcty_in_2           ; // u dcty input data 2
  wire   [10:0] u_dcty_in_3           ; // u dcty input data 3
  wire   [10:0] u_dcty_in_4           ; // u dcty input data 4
  wire   [10:0] u_dcty_in_5           ; // u dcty input data 5
  wire   [10:0] u_dcty_in_6           ; // u dcty input data 6
  wire   [10:0] u_dcty_in_7           ; // u dcty input data 7
  wire          u_dcty_in_valid       ; // u dcty input data valid
  wire   [10:0] v_dcty_in_0           ; // v dcty input data 0
  wire   [10:0] v_dcty_in_1           ; // v dcty input data 1
  wire   [10:0] v_dcty_in_2           ; // v dcty input data 2
  wire   [10:0] v_dcty_in_3           ; // v dcty input data 3
  wire   [10:0] v_dcty_in_4           ; // v dcty input data 4
  wire   [10:0] v_dcty_in_5           ; // v dcty input data 5
  wire   [10:0] v_dcty_in_6           ; // v dcty input data 6
  wire   [10:0] v_dcty_in_7           ; // v dcty input data 7
  wire          v_dcty_in_valid       ; // v dcty input data valid

  wire   [13:0] y_dcty_out_0          ; // y dcty output data 0
  wire   [13:0] y_dcty_out_1          ; // y dcty output data 1
  wire   [13:0] y_dcty_out_2          ; // y dcty output data 2
  wire   [13:0] y_dcty_out_3          ; // y dcty output data 3
  wire   [13:0] y_dcty_out_4          ; // y dcty output data 4
  wire   [13:0] y_dcty_out_5          ; // y dcty output data 5
  wire   [13:0] y_dcty_out_6          ; // y dcty output data 6
  wire   [13:0] y_dcty_out_7          ; // y dcty output data 7
  wire          y_dcty_out_valid      ; // y dcty output data valid
  wire   [13:0] u_dcty_out_0          ; // u dcty output data 0
  wire   [13:0] u_dcty_out_1          ; // u dcty output data 1
  wire   [13:0] u_dcty_out_2          ; // u dcty output data 2
  wire   [13:0] u_dcty_out_3          ; // u dcty output data 3
  wire   [13:0] u_dcty_out_4          ; // u dcty output data 4
  wire   [13:0] u_dcty_out_5          ; // u dcty output data 5
  wire   [13:0] u_dcty_out_6          ; // u dcty output data 6
  wire   [13:0] u_dcty_out_7          ; // u dcty output data 7
  wire          u_dcty_out_valid      ; // u dcty output data valid
  wire   [13:0] v_dcty_out_0          ; // v dcty output data 0
  wire   [13:0] v_dcty_out_1          ; // v dcty output data 1
  wire   [13:0] v_dcty_out_2          ; // v dcty output data 2
  wire   [13:0] v_dcty_out_3          ; // v dcty output data 3
  wire   [13:0] v_dcty_out_4          ; // v dcty output data 4
  wire   [13:0] v_dcty_out_5          ; // v dcty output data 5
  wire   [13:0] v_dcty_out_6          ; // v dcty output data 6
  wire   [13:0] v_dcty_out_7          ; // v dcty output data 7
  wire          v_dcty_out_valid      ; // v dcty output data valid

  reg   [111:0] y_dcty_out_buf        ; // buffer the output dcty data of y
  reg   [111:0] u_dcty_out_buf        ; // buffer the output dcty data of u
  reg   [111:0] v_dcty_out_buf        ; // buffer the output dcty data of v

  reg    [2:0]  dcty_out_cnt          ; // dcty output data count

//--------------------------------------------
//    input stage
//--------------------------------------------

  // unpack data into y/u/v
  assign pixel_in_y = pixel_data_in[23:16];
  assign pixel_in_u = pixel_data_in[15:8] ;
  assign pixel_in_v = pixel_data_in[7:0]  ;

  // count the input pixels
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          pixel_in_cnt <= `DLY 3'h0;
      end
      else if (frame_start | frame_end) begin
          pixel_in_cnt <= `DLY 3'h0;
      end
      else if (pixel_in_valid) begin
          pixel_in_cnt <= `DLY pixel_in_cnt + 3'h1;
      end
  end

  // pack input data into 64-bit line buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_in_line_buf[63:0] <= `DLY 64'h0;
          u_in_line_buf[63:0] <= `DLY 64'h0;
          v_in_line_buf[63:0] <= `DLY 64'h0;
      end
      else if (pixel_in_valid) begin
          case (pixel_in_cnt[2:0])
              3'h0:
              begin
                  y_in_line_buf <= `DLY {y_in_line_buf[63:8] , pixel_in_y[7:0]};
                  u_in_line_buf <= `DLY {u_in_line_buf[63:8] , pixel_in_u[7:0]};
                  v_in_line_buf <= `DLY {v_in_line_buf[63:8] , pixel_in_v[7:0]};
              end
              3'h1:
              begin
                  y_in_line_buf <= `DLY {y_in_line_buf[63:16], pixel_in_y[7:0], y_in_line_buf[7:0]};
                  u_in_line_buf <= `DLY {u_in_line_buf[63:16], pixel_in_u[7:0], u_in_line_buf[7:0]};
                  v_in_line_buf <= `DLY {v_in_line_buf[63:16], pixel_in_v[7:0], v_in_line_buf[7:0]};
              end
              3'h2:
              begin
                  y_in_line_buf <= `DLY {y_in_line_buf[63:24], pixel_in_y[7:0], y_in_line_buf[15:0]};
                  u_in_line_buf <= `DLY {u_in_line_buf[63:24], pixel_in_u[7:0], u_in_line_buf[15:0]};
                  v_in_line_buf <= `DLY {v_in_line_buf[63:24], pixel_in_v[7:0], v_in_line_buf[15:0]};
              end
              3'h3:
              begin
                  y_in_line_buf <= `DLY {y_in_line_buf[63:32], pixel_in_y[7:0], y_in_line_buf[23:0]};
                  u_in_line_buf <= `DLY {u_in_line_buf[63:32], pixel_in_u[7:0], u_in_line_buf[23:0]};
                  v_in_line_buf <= `DLY {v_in_line_buf[63:32], pixel_in_v[7:0], v_in_line_buf[23:0]};
              end
              3'h4:
              begin
                  y_in_line_buf <= `DLY {y_in_line_buf[63:40], pixel_in_y[7:0], y_in_line_buf[31:0]};
                  u_in_line_buf <= `DLY {u_in_line_buf[63:40], pixel_in_u[7:0], u_in_line_buf[31:0]};
                  v_in_line_buf <= `DLY {v_in_line_buf[63:40], pixel_in_v[7:0], v_in_line_buf[31:0]};
              end
              3'h5:
              begin
                  y_in_line_buf <= `DLY {y_in_line_buf[63:48], pixel_in_y[7:0], y_in_line_buf[39:0]};
                  u_in_line_buf <= `DLY {u_in_line_buf[63:48], pixel_in_u[7:0], u_in_line_buf[39:0]};
                  v_in_line_buf <= `DLY {v_in_line_buf[63:48], pixel_in_v[7:0], v_in_line_buf[39:0]};
              end
              3'h6:
              begin
                  y_in_line_buf <= `DLY {y_in_line_buf[63:56], pixel_in_y[7:0], y_in_line_buf[47:0]};
                  u_in_line_buf <= `DLY {u_in_line_buf[63:56], pixel_in_u[7:0], u_in_line_buf[47:0]};
                  v_in_line_buf <= `DLY {v_in_line_buf[63:56], pixel_in_v[7:0], v_in_line_buf[47:0]};
              end
              default:
              begin
                  y_in_line_buf <= `DLY {pixel_in_y[7:0], y_in_line_buf[55:0]};
                  u_in_line_buf <= `DLY {pixel_in_u[7:0], u_in_line_buf[55:0]};
                  v_in_line_buf <= `DLY {pixel_in_v[7:0], v_in_line_buf[55:0]};
              end
          endcase
      end
  end

  // line buffer valid
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_in_line_buf_valid <= `DLY 1'b0;
      end
      else if (pixel_in_valid & (pixel_in_cnt[2:0] == 3'h7)) begin
          y_in_line_buf_valid <= `DLY 1'b1;
      end
      else begin
          y_in_line_buf_valid <= `DLY 1'b0;
      end
  end

  assign u_in_line_buf_valid = y_in_line_buf_valid;
  assign v_in_line_buf_valid = y_in_line_buf_valid;

//--------------------------------------------
//    dctx calculation
//--------------------------------------------

  // dctx input
  assign y_dctx_in_0     = y_in_line_buf[7:0]  ;
  assign y_dctx_in_1     = y_in_line_buf[15:8] ;
  assign y_dctx_in_2     = y_in_line_buf[23:16];
  assign y_dctx_in_3     = y_in_line_buf[31:24];
  assign y_dctx_in_4     = y_in_line_buf[39:32];
  assign y_dctx_in_5     = y_in_line_buf[47:40];
  assign y_dctx_in_6     = y_in_line_buf[55:48];
  assign y_dctx_in_7     = y_in_line_buf[63:56];
  assign y_dctx_in_valid = y_in_line_buf_valid ;
  assign u_dctx_in_0     = u_in_line_buf[7:0]  ;
  assign u_dctx_in_1     = u_in_line_buf[15:8] ;
  assign u_dctx_in_2     = u_in_line_buf[23:16];
  assign u_dctx_in_3     = u_in_line_buf[31:24];
  assign u_dctx_in_4     = u_in_line_buf[39:32];
  assign u_dctx_in_5     = u_in_line_buf[47:40];
  assign u_dctx_in_6     = u_in_line_buf[55:48];
  assign u_dctx_in_7     = u_in_line_buf[63:56];
  assign u_dctx_in_valid = u_in_line_buf_valid ;
  assign v_dctx_in_0     = v_in_line_buf[7:0]  ;
  assign v_dctx_in_1     = v_in_line_buf[15:8] ;
  assign v_dctx_in_2     = v_in_line_buf[23:16];
  assign v_dctx_in_3     = v_in_line_buf[31:24];
  assign v_dctx_in_4     = v_in_line_buf[39:32];
  assign v_dctx_in_5     = v_in_line_buf[47:40];
  assign v_dctx_in_6     = v_in_line_buf[55:48];
  assign v_dctx_in_7     = v_in_line_buf[63:56];
  assign v_dctx_in_valid = v_in_line_buf_valid ;

  // dctx of y
  dct1d y_dctx(
    // global signals
    .clk              (clk                                ), // <i>  1b, global clock
    .rstn             (rstn                               ), // <i>  1b, global reset, active low
    // input 8 points data
    .dct_in_0         ({{3{y_dctx_in_0[7]}}, y_dctx_in_0} ), // <i> 11b, dct input symbol 0
    .dct_in_1         ({{3{y_dctx_in_1[7]}}, y_dctx_in_1} ), // <i> 11b, dct input symbol 1
    .dct_in_2         ({{3{y_dctx_in_2[7]}}, y_dctx_in_2} ), // <i> 11b, dct input symbol 2
    .dct_in_3         ({{3{y_dctx_in_3[7]}}, y_dctx_in_3} ), // <i> 11b, dct input symbol 3
    .dct_in_4         ({{3{y_dctx_in_4[7]}}, y_dctx_in_4} ), // <i> 11b, dct input symbol 4
    .dct_in_5         ({{3{y_dctx_in_5[7]}}, y_dctx_in_5} ), // <i> 11b, dct input symbol 5
    .dct_in_6         ({{3{y_dctx_in_6[7]}}, y_dctx_in_6} ), // <i> 11b, dct input symbol 6
    .dct_in_7         ({{3{y_dctx_in_7[7]}}, y_dctx_in_7} ), // <i> 11b, dct input symbol 7
    .dct_in_valid     (y_dctx_in_valid                    ), // <i>  1b, dct input valid
    // output 8 points data
    .dct_out_0        (y_dctx_out_0                       ), // <o> 14b, dct output symbol 0
    .dct_out_1        (y_dctx_out_1                       ), // <o> 14b, dct output symbol 1
    .dct_out_2        (y_dctx_out_2                       ), // <o> 14b, dct output symbol 2
    .dct_out_3        (y_dctx_out_3                       ), // <o> 14b, dct output symbol 3
    .dct_out_4        (y_dctx_out_4                       ), // <o> 14b, dct output symbol 4
    .dct_out_5        (y_dctx_out_5                       ), // <o> 14b, dct output symbol 5
    .dct_out_6        (y_dctx_out_6                       ), // <o> 14b, dct output symbol 6
    .dct_out_7        (y_dctx_out_7                       ), // <o> 14b, dct output symbol 7
    .dct_out_valid    (y_dctx_out_valid                   )  // <o>  1b, dct output valid
    );

  // dctx of u
  dct1d u_dctx(
    // global signals
    .clk              (clk                                ), // <i>  1b, global clock
    .rstn             (rstn                               ), // <i>  1b, global reset, active low
    // input 8 points data
    .dct_in_0         ({{3{u_dctx_in_0[7]}}, u_dctx_in_0} ), // <i> 11b, dct input symbol 0
    .dct_in_1         ({{3{u_dctx_in_1[7]}}, u_dctx_in_1} ), // <i> 11b, dct input symbol 1
    .dct_in_2         ({{3{u_dctx_in_2[7]}}, u_dctx_in_2} ), // <i> 11b, dct input symbol 2
    .dct_in_3         ({{3{u_dctx_in_3[7]}}, u_dctx_in_3} ), // <i> 11b, dct input symbol 3
    .dct_in_4         ({{3{u_dctx_in_4[7]}}, u_dctx_in_4} ), // <i> 11b, dct input symbol 4
    .dct_in_5         ({{3{u_dctx_in_5[7]}}, u_dctx_in_5} ), // <i> 11b, dct input symbol 5
    .dct_in_6         ({{3{u_dctx_in_6[7]}}, u_dctx_in_6} ), // <i> 11b, dct input symbol 6
    .dct_in_7         ({{3{u_dctx_in_7[7]}}, u_dctx_in_7} ), // <i> 11b, dct input symbol 7
    .dct_in_valid     (u_dctx_in_valid                    ), // <i>  1b, dct input valid
    // output 8 points data
    .dct_out_0        (u_dctx_out_0                       ), // <o> 14b, dct output symbol 0
    .dct_out_1        (u_dctx_out_1                       ), // <o> 14b, dct output symbol 1
    .dct_out_2        (u_dctx_out_2                       ), // <o> 14b, dct output symbol 2
    .dct_out_3        (u_dctx_out_3                       ), // <o> 14b, dct output symbol 3
    .dct_out_4        (u_dctx_out_4                       ), // <o> 14b, dct output symbol 4
    .dct_out_5        (u_dctx_out_5                       ), // <o> 14b, dct output symbol 5
    .dct_out_6        (u_dctx_out_6                       ), // <o> 14b, dct output symbol 6
    .dct_out_7        (u_dctx_out_7                       ), // <o> 14b, dct output symbol 7
    .dct_out_valid    (u_dctx_out_valid                   )  // <o>  1b, dct output valid
    );

  // dctx of v
  dct1d v_dctx(
    // global signals
    .clk              (clk                                ), // <i>  1b, global clock
    .rstn             (rstn                               ), // <i>  1b, global reset, active low
    // input 8 points data
    .dct_in_0         ({{3{v_dctx_in_0[7]}}, v_dctx_in_0} ), // <i> 11b, dct input symbol 0
    .dct_in_1         ({{3{v_dctx_in_1[7]}}, v_dctx_in_1} ), // <i> 11b, dct input symbol 1
    .dct_in_2         ({{3{v_dctx_in_2[7]}}, v_dctx_in_2} ), // <i> 11b, dct input symbol 2
    .dct_in_3         ({{3{v_dctx_in_3[7]}}, v_dctx_in_3} ), // <i> 11b, dct input symbol 3
    .dct_in_4         ({{3{v_dctx_in_4[7]}}, v_dctx_in_4} ), // <i> 11b, dct input symbol 4
    .dct_in_5         ({{3{v_dctx_in_5[7]}}, v_dctx_in_5} ), // <i> 11b, dct input symbol 5
    .dct_in_6         ({{3{v_dctx_in_6[7]}}, v_dctx_in_6} ), // <i> 11b, dct input symbol 6
    .dct_in_7         ({{3{v_dctx_in_7[7]}}, v_dctx_in_7} ), // <i> 11b, dct input symbol 7
    .dct_in_valid     (v_dctx_in_valid                    ), // <i>  1b, dct input valid
    // output 8 points data
    .dct_out_0        (v_dctx_out_0                       ), // <o> 14b, dct output symbol 0
    .dct_out_1        (v_dctx_out_1                       ), // <o> 14b, dct output symbol 1
    .dct_out_2        (v_dctx_out_2                       ), // <o> 14b, dct output symbol 2
    .dct_out_3        (v_dctx_out_3                       ), // <o> 14b, dct output symbol 3
    .dct_out_4        (v_dctx_out_4                       ), // <o> 14b, dct output symbol 4
    .dct_out_5        (v_dctx_out_5                       ), // <o> 14b, dct output symbol 5
    .dct_out_6        (v_dctx_out_6                       ), // <o> 14b, dct output symbol 6
    .dct_out_7        (v_dctx_out_7                       ), // <o> 14b, dct output symbol 7
    .dct_out_valid    (v_dctx_out_valid                   )  // <o>  1b, dct output valid
    );

    // buffer the output of dctx
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_dctx_out_buf <= `DLY 88'h0;
          u_dctx_out_buf <= `DLY 88'h0;
          v_dctx_out_buf <= `DLY 88'h0;
      end
      else if (y_dctx_out_valid) begin
          y_dctx_out_buf <= `DLY {y_dctx_out_0[10:0], y_dctx_out_1[10:0], y_dctx_out_2[10:0], y_dctx_out_3[10:0],
                                  y_dctx_out_4[10:0], y_dctx_out_5[10:0], y_dctx_out_6[10:0], y_dctx_out_7[10:0]};
          u_dctx_out_buf <= `DLY {u_dctx_out_0[10:0], u_dctx_out_1[10:0], u_dctx_out_2[10:0], u_dctx_out_3[10:0],
                                  u_dctx_out_4[10:0], u_dctx_out_5[10:0], u_dctx_out_6[10:0], u_dctx_out_7[10:0]};
          v_dctx_out_buf <= `DLY {v_dctx_out_0[10:0], v_dctx_out_1[10:0], v_dctx_out_2[10:0], v_dctx_out_3[10:0],
                                  v_dctx_out_4[10:0], v_dctx_out_5[10:0], v_dctx_out_6[10:0], v_dctx_out_7[10:0]};
      end
  end

//--------------------------------------------
//    block buffer control signals
//--------------------------------------------

  // count the data written into block buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_wr_cnt <= `DLY 6'h0;
      end
      else if (block_buf_wr) begin
          block_buf_wr_cnt <= `DLY block_buf_wr_cnt + 6'h1;
      end
  end

  // block write done indicator
  assign block_buf_wr_done = (block_buf_wr_cnt == 6'h3F) & block_buf_wr;

  // count the data read from block buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_rd_cnt <= `DLY 6'h0;
      end
      else if (block_buf_rd) begin
          block_buf_rd_cnt <= `DLY block_buf_rd_cnt + 6'h1;
      end
  end

  // block read done indicator
  assign block_buf_rd_done = (block_buf_rd_cnt == 6'h3F) & block_buf_rd;

  // block buffer select
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_sel <= `DLY 1'b0;
      end
      else begin
          block_buf_sel <= `DLY block_buf_sel_nxt;
      end
  end

  // next value of block_buf_sel
  assign block_buf_sel_nxt = block_buf_wr_done ? ~block_buf_sel : block_buf_sel;

  // delay of block_buf_sel
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_sel_d <= `DLY 1'b0;
      end
      else begin
          block_buf_sel_d <= `DLY block_buf_sel;
      end
  end

  // block buffer0 write enable
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf0_wr <= `DLY 1'b0;
      end
      else if (~block_buf_sel & (block_buf_wr_cnt == 6'h3F)) begin
          block_buf0_wr <= `DLY 1'b0;
      end
      else if (~block_buf_sel_nxt & y_dctx_out_valid) begin
          block_buf0_wr <= `DLY 1'b1;
      end
  end

  // block buffer1 write enable
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf1_wr <= `DLY 1'b0;
      end
      else if (block_buf_sel & (block_buf_wr_cnt == 6'h3F)) begin
          block_buf1_wr <= `DLY 1'b0;
      end
      else if (block_buf_sel_nxt & y_dctx_out_valid) begin
          block_buf1_wr <= `DLY 1'b1;
      end
  end

  // block buffer write enable
  assign block_buf_wr = block_buf0_wr | block_buf1_wr;

  // set to 1 when block buffer 0 is filled with dctx data and ready for read
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf0_rd <= `DLY 1'b0;
      end
      else if (~block_buf_sel & block_buf_wr_done) begin
          block_buf0_rd <= `DLY 1'b1;
      end
      else if (block_buf_sel & block_buf_rd_done) begin
          block_buf0_rd <= `DLY 1'b0;
      end
  end

  // set to 1 when block buffer 1 is filled with dctx data and ready for read
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf1_rd <= `DLY 1'b0;
      end
      else if (block_buf_sel & block_buf_wr_done) begin
          block_buf1_rd <= `DLY 1'b1;
      end
      else if (~block_buf_sel & block_buf_rd_done) begin
          block_buf1_rd <= `DLY 1'b0;
      end
  end

  // block buffer read enable
  assign block_buf_rd = block_buf0_rd | block_buf1_rd;

  // delay block_buf0_rd and block_buf1_rd to sync with read data from buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_rd_d <= `DLY 1'b0;
      end
      else begin
          block_buf_rd_d <= `DLY block_buf_rd;
      end
  end

  // block buffer waddr
  assign block_buf0_waddr = block_buf_wr_cnt;
  assign block_buf1_waddr = block_buf_wr_cnt;

  // block buffer raddr
  assign block_buf0_raddr = {block_buf_rd_cnt[2:0], block_buf_rd_cnt[5:3]};
  assign block_buf1_raddr = {block_buf_rd_cnt[2:0], block_buf_rd_cnt[5:3]};

  // block buffer address
  assign block_buf0_addr = ~block_buf_sel ? block_buf0_waddr : block_buf0_raddr;
  assign block_buf1_addr =  block_buf_sel ? block_buf1_waddr : block_buf1_raddr;

  // block buffer data input
  assign block_buf_din = (block_buf_wr_cnt[2:0] == 3'h0) ? {y_dctx_out_buf[87:77], u_dctx_out_buf[87:77], v_dctx_out_buf[87:77]} :
                         (block_buf_wr_cnt[2:0] == 3'h1) ? {y_dctx_out_buf[76:66], u_dctx_out_buf[76:66], v_dctx_out_buf[76:66]} :
                         (block_buf_wr_cnt[2:0] == 3'h2) ? {y_dctx_out_buf[65:55], u_dctx_out_buf[65:55], v_dctx_out_buf[65:55]} :
                         (block_buf_wr_cnt[2:0] == 3'h3) ? {y_dctx_out_buf[54:44], u_dctx_out_buf[54:44], v_dctx_out_buf[54:44]} :
                         (block_buf_wr_cnt[2:0] == 3'h4) ? {y_dctx_out_buf[43:33], u_dctx_out_buf[43:33], v_dctx_out_buf[43:33]} :
                         (block_buf_wr_cnt[2:0] == 3'h5) ? {y_dctx_out_buf[32:22], u_dctx_out_buf[32:22], v_dctx_out_buf[32:22]} :
                         (block_buf_wr_cnt[2:0] == 3'h6) ? {y_dctx_out_buf[21:11], u_dctx_out_buf[21:11], v_dctx_out_buf[21:11]} :
                                                           {y_dctx_out_buf[10:0] , u_dctx_out_buf[10:0] , v_dctx_out_buf[10:0] } ;

  // block buffer data output
  assign block_buf_dout = block_buf_sel_d ? block_buf0_dout : block_buf1_dout;

//--------------------------------------------
//    dcty calculation
//--------------------------------------------

  // delay the block_buf_rd_cnt to sync with data output from buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dcty_in_cnt <= `DLY 3'h0;
      end
      else begin
          dcty_in_cnt <= `DLY block_buf_rd_cnt;
      end
  end

  // pack output from dctx into dcty input line buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_dcty_in_line_buf <= `DLY 88'h0;
          u_dcty_in_line_buf <= `DLY 88'h0;
          v_dcty_in_line_buf <= `DLY 88'h0;
      end
      else if (block_buf_rd_d) begin
          case (dcty_in_cnt[2:0])
              3'h0:
              begin
                  y_dcty_in_line_buf <= `DLY {y_dcty_in_line_buf[87:11], block_buf_dout[32:22]};
                  u_dcty_in_line_buf <= `DLY {u_dcty_in_line_buf[87:11], block_buf_dout[21:11]};
                  v_dcty_in_line_buf <= `DLY {v_dcty_in_line_buf[87:11], block_buf_dout[10:0] };
              end
              3'h1:
              begin
                  y_dcty_in_line_buf <= `DLY {y_dcty_in_line_buf[87:22], block_buf_dout[32:22], y_dcty_in_line_buf[10:0]};
                  u_dcty_in_line_buf <= `DLY {u_dcty_in_line_buf[87:22], block_buf_dout[21:11], u_dcty_in_line_buf[10:0]};
                  v_dcty_in_line_buf <= `DLY {v_dcty_in_line_buf[87:22], block_buf_dout[10:0] , v_dcty_in_line_buf[10:0]};
              end
              3'h2:
              begin
                  y_dcty_in_line_buf <= `DLY {y_dcty_in_line_buf[87:33], block_buf_dout[32:22], y_dcty_in_line_buf[21:0]};
                  u_dcty_in_line_buf <= `DLY {u_dcty_in_line_buf[87:33], block_buf_dout[21:11], u_dcty_in_line_buf[21:0]};
                  v_dcty_in_line_buf <= `DLY {v_dcty_in_line_buf[87:33], block_buf_dout[10:0] , v_dcty_in_line_buf[21:0]};
              end
              3'h3:
              begin
                  y_dcty_in_line_buf <= `DLY {y_dcty_in_line_buf[87:44], block_buf_dout[32:22], y_dcty_in_line_buf[32:0]};
                  u_dcty_in_line_buf <= `DLY {u_dcty_in_line_buf[87:44], block_buf_dout[21:11], u_dcty_in_line_buf[32:0]};
                  v_dcty_in_line_buf <= `DLY {v_dcty_in_line_buf[87:44], block_buf_dout[10:0] , v_dcty_in_line_buf[32:0]};
              end
              3'h4:
              begin
                  y_dcty_in_line_buf <= `DLY {y_dcty_in_line_buf[87:55], block_buf_dout[32:22], y_dcty_in_line_buf[43:0]};
                  u_dcty_in_line_buf <= `DLY {u_dcty_in_line_buf[87:55], block_buf_dout[21:11], u_dcty_in_line_buf[43:0]};
                  v_dcty_in_line_buf <= `DLY {v_dcty_in_line_buf[87:55], block_buf_dout[10:0] , v_dcty_in_line_buf[43:0]};
              end
              3'h5:
              begin
                  y_dcty_in_line_buf <= `DLY {y_dcty_in_line_buf[87:66], block_buf_dout[32:22], y_dcty_in_line_buf[54:0]};
                  u_dcty_in_line_buf <= `DLY {u_dcty_in_line_buf[87:66], block_buf_dout[21:11], u_dcty_in_line_buf[54:0]};
                  v_dcty_in_line_buf <= `DLY {v_dcty_in_line_buf[87:66], block_buf_dout[10:0] , v_dcty_in_line_buf[54:0]};
              end
              3'h6:
              begin
                  y_dcty_in_line_buf <= `DLY {y_dcty_in_line_buf[87:77], block_buf_dout[32:22], y_dcty_in_line_buf[65:0]};
                  u_dcty_in_line_buf <= `DLY {u_dcty_in_line_buf[87:77], block_buf_dout[21:11], u_dcty_in_line_buf[65:0]};
                  v_dcty_in_line_buf <= `DLY {v_dcty_in_line_buf[87:77], block_buf_dout[10:0] , v_dcty_in_line_buf[65:0]};
              end
              3'h7:
              begin
                  y_dcty_in_line_buf <= `DLY {block_buf_dout[32:22], y_dcty_in_line_buf[76:0]};
                  u_dcty_in_line_buf <= `DLY {block_buf_dout[21:11], u_dcty_in_line_buf[76:0]};
                  v_dcty_in_line_buf <= `DLY {block_buf_dout[10:0] , v_dcty_in_line_buf[76:0]};
              end
          endcase
      end
  end

  // dcty data input line buffer valid
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_dcty_line_buf_valid <= `DLY 1'b0;
      end
      else if (block_buf_rd_d & (dcty_in_cnt[2:0] == 3'h7)) begin
          y_dcty_line_buf_valid <= `DLY 1'b1;
      end
      else begin
          y_dcty_line_buf_valid <= `DLY 1'b0;
      end
  end

  assign u_dcty_line_buf_valid = y_dcty_line_buf_valid;
  assign v_dcty_line_buf_valid = y_dcty_line_buf_valid;

  // dcty input
  assign y_dcty_in_0     = y_dcty_in_line_buf[10:0] ;
  assign y_dcty_in_1     = y_dcty_in_line_buf[21:11];
  assign y_dcty_in_2     = y_dcty_in_line_buf[32:22];
  assign y_dcty_in_3     = y_dcty_in_line_buf[43:33];
  assign y_dcty_in_4     = y_dcty_in_line_buf[54:44];
  assign y_dcty_in_5     = y_dcty_in_line_buf[65:55];
  assign y_dcty_in_6     = y_dcty_in_line_buf[76:66];
  assign y_dcty_in_7     = y_dcty_in_line_buf[87:77];
  assign y_dcty_in_valid = y_dcty_line_buf_valid;
  assign u_dcty_in_0     = u_dcty_in_line_buf[10:0] ;
  assign u_dcty_in_1     = u_dcty_in_line_buf[21:11];
  assign u_dcty_in_2     = u_dcty_in_line_buf[32:22];
  assign u_dcty_in_3     = u_dcty_in_line_buf[43:33];
  assign u_dcty_in_4     = u_dcty_in_line_buf[54:44];
  assign u_dcty_in_5     = u_dcty_in_line_buf[65:55];
  assign u_dcty_in_6     = u_dcty_in_line_buf[76:66];
  assign u_dcty_in_7     = u_dcty_in_line_buf[87:77];
  assign u_dcty_in_valid = u_dcty_line_buf_valid;
  assign v_dcty_in_0     = v_dcty_in_line_buf[10:0] ;
  assign v_dcty_in_1     = v_dcty_in_line_buf[21:11];
  assign v_dcty_in_2     = v_dcty_in_line_buf[32:22];
  assign v_dcty_in_3     = v_dcty_in_line_buf[43:33];
  assign v_dcty_in_4     = v_dcty_in_line_buf[54:44];
  assign v_dcty_in_5     = v_dcty_in_line_buf[65:55];
  assign v_dcty_in_6     = v_dcty_in_line_buf[76:66];
  assign v_dcty_in_7     = v_dcty_in_line_buf[87:77];
  assign v_dcty_in_valid = v_dcty_line_buf_valid;

  // dcty of y
  dct1d y_dcty(
    // global signals
    .clk              (clk              ), // <i>  1b, global clock
    .rstn             (rstn             ), // <i>  1b, global reset, active low
    // input 8 points data
    .dct_in_0         (y_dcty_in_0      ), // <i> 11b, dct input symbol 0
    .dct_in_1         (y_dcty_in_1      ), // <i> 11b, dct input symbol 1
    .dct_in_2         (y_dcty_in_2      ), // <i> 11b, dct input symbol 2
    .dct_in_3         (y_dcty_in_3      ), // <i> 11b, dct input symbol 3
    .dct_in_4         (y_dcty_in_4      ), // <i> 11b, dct input symbol 4
    .dct_in_5         (y_dcty_in_5      ), // <i> 11b, dct input symbol 5
    .dct_in_6         (y_dcty_in_6      ), // <i> 11b, dct input symbol 6
    .dct_in_7         (y_dcty_in_7      ), // <i> 11b, dct input symbol 7
    .dct_in_valid     (y_dcty_in_valid  ), // <i>  1b, dct input valid
    // output 8 points data
    .dct_out_0        (y_dcty_out_0     ), // <o> 14b, dct output symbol 0
    .dct_out_1        (y_dcty_out_1     ), // <o> 14b, dct output symbol 1
    .dct_out_2        (y_dcty_out_2     ), // <o> 14b, dct output symbol 2
    .dct_out_3        (y_dcty_out_3     ), // <o> 14b, dct output symbol 3
    .dct_out_4        (y_dcty_out_4     ), // <o> 14b, dct output symbol 4
    .dct_out_5        (y_dcty_out_5     ), // <o> 14b, dct output symbol 5
    .dct_out_6        (y_dcty_out_6     ), // <o> 14b, dct output symbol 6
    .dct_out_7        (y_dcty_out_7     ), // <o> 14b, dct output symbol 7
    .dct_out_valid    (y_dcty_out_valid )  // <o>  1b, dct output valid
    );

  // dcty of u
  dct1d u_dcty(
    // global signals
    .clk              (clk              ), // <i>  1b, global clock
    .rstn             (rstn             ), // <i>  1b, global reset, active low
    // input 8 points data
    .dct_in_0         (u_dcty_in_0      ), // <i> 11b, dct input symbol 0
    .dct_in_1         (u_dcty_in_1      ), // <i> 11b, dct input symbol 1
    .dct_in_2         (u_dcty_in_2      ), // <i> 11b, dct input symbol 2
    .dct_in_3         (u_dcty_in_3      ), // <i> 11b, dct input symbol 3
    .dct_in_4         (u_dcty_in_4      ), // <i> 11b, dct input symbol 4
    .dct_in_5         (u_dcty_in_5      ), // <i> 11b, dct input symbol 5
    .dct_in_6         (u_dcty_in_6      ), // <i> 11b, dct input symbol 6
    .dct_in_7         (u_dcty_in_7      ), // <i> 11b, dct input symbol 7
    .dct_in_valid     (u_dcty_in_valid  ), // <i>  1b, dct input valid
    // output 8 points data
    .dct_out_0        (u_dcty_out_0     ), // <o> 14b, dct output symbol 0
    .dct_out_1        (u_dcty_out_1     ), // <o> 14b, dct output symbol 1
    .dct_out_2        (u_dcty_out_2     ), // <o> 14b, dct output symbol 2
    .dct_out_3        (u_dcty_out_3     ), // <o> 14b, dct output symbol 3
    .dct_out_4        (u_dcty_out_4     ), // <o> 14b, dct output symbol 4
    .dct_out_5        (u_dcty_out_5     ), // <o> 14b, dct output symbol 5
    .dct_out_6        (u_dcty_out_6     ), // <o> 14b, dct output symbol 6
    .dct_out_7        (u_dcty_out_7     ), // <o> 14b, dct output symbol 7
    .dct_out_valid    (u_dcty_out_valid )  // <o>  1b, dct output valid
    );

  // dcty of v
  dct1d v_dcty(
    // global signals
    .clk              (clk              ), // <i>  1b, global clock
    .rstn             (rstn             ), // <i>  1b, global reset, active low
    // input 8 points data
    .dct_in_0         (v_dcty_in_0      ), // <i> 11b, dct input symbol 0
    .dct_in_1         (v_dcty_in_1      ), // <i> 11b, dct input symbol 1
    .dct_in_2         (v_dcty_in_2      ), // <i> 11b, dct input symbol 2
    .dct_in_3         (v_dcty_in_3      ), // <i> 11b, dct input symbol 3
    .dct_in_4         (v_dcty_in_4      ), // <i> 11b, dct input symbol 4
    .dct_in_5         (v_dcty_in_5      ), // <i> 11b, dct input symbol 5
    .dct_in_6         (v_dcty_in_6      ), // <i> 11b, dct input symbol 6
    .dct_in_7         (v_dcty_in_7      ), // <i> 11b, dct input symbol 7
    .dct_in_valid     (v_dcty_in_valid  ), // <i>  1b, dct input valid
    // output 8 points data
    .dct_out_0        (v_dcty_out_0     ), // <o> 14b, dct output symbol 0
    .dct_out_1        (v_dcty_out_1     ), // <o> 14b, dct output symbol 1
    .dct_out_2        (v_dcty_out_2     ), // <o> 14b, dct output symbol 2
    .dct_out_3        (v_dcty_out_3     ), // <o> 14b, dct output symbol 3
    .dct_out_4        (v_dcty_out_4     ), // <o> 14b, dct output symbol 4
    .dct_out_5        (v_dcty_out_5     ), // <o> 14b, dct output symbol 5
    .dct_out_6        (v_dcty_out_6     ), // <o> 14b, dct output symbol 6
    .dct_out_7        (v_dcty_out_7     ), // <o> 14b, dct output symbol 7
    .dct_out_valid    (v_dcty_out_valid )  // <o>  1b, dct output valid
    );

  // buffer the output of dcty
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_dcty_out_buf <= `DLY 112'h0;
          u_dcty_out_buf <= `DLY 112'h0;
          v_dcty_out_buf <= `DLY 112'h0;
      end
      else if (y_dcty_out_valid) begin
          y_dcty_out_buf <= `DLY {y_dcty_out_0, y_dcty_out_1, y_dcty_out_2, y_dcty_out_3,
                                  y_dcty_out_4, y_dcty_out_5, y_dcty_out_6, y_dcty_out_7};
          u_dcty_out_buf <= `DLY {u_dcty_out_0, u_dcty_out_1, u_dcty_out_2, u_dcty_out_3,
                                  u_dcty_out_4, u_dcty_out_5, u_dcty_out_6, u_dcty_out_7};
          v_dcty_out_buf <= `DLY {v_dcty_out_0, v_dcty_out_1, v_dcty_out_2, v_dcty_out_3,
                                  v_dcty_out_4, v_dcty_out_5, v_dcty_out_6, v_dcty_out_7};
      end
  end

  // count the output data from dcty out buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dcty_out_cnt <= `DLY 3'h0;
      end
      else if (y_dcty_out_valid) begin
          dcty_out_cnt <= `DLY 3'h0;
      end
      else if (dct_out_valid) begin
          dcty_out_cnt <= `DLY dcty_out_cnt + 3'h1;
      end
  end

//--------------------------------------------
//    output stage
//--------------------------------------------

  // dct data output valid
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dct_out_valid <= `DLY 1'b0;
      end
      else if (y_dcty_out_valid) begin
          dct_out_valid <= `DLY 1'b1;
      end
      else if (dcty_out_cnt == 3'h7) begin
          dct_out_valid <= `DLY 1'b0;
      end
  end

  // dct data output
  assign dct_data_out = (dcty_out_cnt[2:0] == 3'h0) ? {y_dcty_out_buf[111:98], u_dcty_out_buf[111:98], v_dcty_out_buf[111:98]} :
                        (dcty_out_cnt[2:0] == 3'h1) ? {y_dcty_out_buf[97:84] , u_dcty_out_buf[97:84] , v_dcty_out_buf[97:84] } :
                        (dcty_out_cnt[2:0] == 3'h2) ? {y_dcty_out_buf[83:70] , u_dcty_out_buf[83:70] , v_dcty_out_buf[83:70] } :
                        (dcty_out_cnt[2:0] == 3'h3) ? {y_dcty_out_buf[69:56] , u_dcty_out_buf[69:56] , v_dcty_out_buf[69:56] } :
                        (dcty_out_cnt[2:0] == 3'h4) ? {y_dcty_out_buf[55:42] , u_dcty_out_buf[55:42] , v_dcty_out_buf[55:42] } :
                        (dcty_out_cnt[2:0] == 3'h5) ? {y_dcty_out_buf[41:28] , u_dcty_out_buf[41:28] , v_dcty_out_buf[41:28] } :
                        (dcty_out_cnt[2:0] == 3'h6) ? {y_dcty_out_buf[27:14] , u_dcty_out_buf[27:14] , v_dcty_out_buf[27:14] } :
                                                      {y_dcty_out_buf[13:0]  , u_dcty_out_buf[13:0]  , v_dcty_out_buf[13:0]  } ;

//--------------------------------------------
//    block buffer instances
//--------------------------------------------

  dct_block_buf dct_block_buf_u0 (
    .clk        (clk              ),
    .wea        (block_buf0_wr    ),
    .addra      (block_buf0_addr  ),
    .din        (block_buf_din    ),
    .dout       (block_buf0_dout  ) 
    );

  dct_block_buf dct_block_buf_u1 (
    .clk        (clk              ),
    .wea        (block_buf1_wr    ),
    .addra      (block_buf1_addr  ),
    .din        (block_buf_din    ),
    .dout       (block_buf1_dout  ) 
    );

endmodule
