`define DLY #1

module huffman_enc_lum(
    // global
    clk               , // <i>  1b, global clock
    rstn              , // <i>  1b, global reset, active low
    // DC input
    dc_coeff_in_valid , // <i>  1b, dc coeff input valid
    dc_coeff          , // <i> 12b, dc_coeff input
    // AC input
    ac_coeff_in_valid , // <i>  1b, ac coeff input valid
    ac_coeff          , // <i> 12b, ac coeff input
    run_length        , // <i>  4b, run length
    eob_flag          , // <i>  1b, eob flag input
    // output huffman code and length
    code_out_valid    , // <o>  1b, huffman code output valid
    code              , // <o> 26b, huffman code
    length            , // <o>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    eob_out             // <o>  1b, eob flag output
    );

  // global
  input         clk               ; // <i>  1b, global clock
  input         rstn              ; // <i>  1b, global reset, active low
  // DC input
  input         dc_coeff_in_valid ; // <i>  1b, dc coeff input valid
  input  [11:0] dc_coeff          ; // <i> 12b, dc_coeff input
  // AC input
  input         ac_coeff_in_valid ; // <i>  1b, ac coeff input valid
  input  [11:0] ac_coeff          ; // <i> 12b, ac coeff input
  input  [3:0]  run_length        ; // <i>  4b, run length
  input         eob_flag          ; // <i>  1b, eob flag input
  // output huffman code and length
  output        code_out_valid    ; // <o>  1b, huffman code output valid
  output [26:0] code              ; // <o> 27b, huffman code
  output [4:0]  length            ; // <o>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
  output        eob_out           ; // <o>  1b, eob flag output

  parameter DC_COEFF = 1'b0;
  parameter AC_COEFF = 1'b1;

  wire          coeff_in_valid          ; // coeff input valid
  wire   [11:0] coeff                   ; // coeff data

  reg           coeff_in_valid_p1       ; // pipeline1: delay of coeff_in_valid
  reg           coeff_neg_p1            ; // pipeline1: delay of coeff neg flag
  reg    [10:0] coeff_abs_p1            ; // pipeline1: delay of abs of coeff
  reg    [3:0]  run_length_p1           ; // pipeline1: delay of run_length
  reg           eob_flag_p1             ; // pipeline1: delay of eob_flag
  reg           in_dat_type_p1          ; // pipeline1: delay of input data type

  reg           coeff_in_valid_p2       ; // pipeline2: delay of coeff_in_valid
  reg    [3:0]  extra_bits_p2           ; // pipeline2: number of extra bits
  reg    [10:0] coeff_abs_p2            ; // pipeline2: delay of abs of coeff
  reg           coeff_neg_p2            ; // pipeline2: delay of coeff neg flag
  reg    [3:0]  run_length_p2           ; // pipeline2: delay of run_length
  reg           eob_flag_p2             ; // pipeline2: delay of eob_flag
  reg           in_dat_type_p2          ; // pipeline2: delay of input data type
  wire   [15:0] dc_lum_code_p2          ; // pipeline2: dc lum huffman code
  wire   [4:0]  dc_lum_length_p2        ; // pipeline2: dc lum huffman code length
  wire   [15:0] ac_lum_code_p2          ; // pipeline2: ac lum huffman code
  wire   [4:0]  ac_lum_length_p2        ; // pipeline2: ac lum huffman code length

  reg           code_out_valid_p3       ; // pipeline3: huffman code output valid
  reg    [3:0]  extra_bits_p3           ; // pipeline3: number of extra bits
  reg    [10:0] coeff_abs_p3            ; // pipeline3: delay of abs of coeff
  reg           coeff_neg_p3            ; // pipeline3: delay of coeff neg flag
  reg    [15:0] code_p3                 ; // pipeline3: huffman code from lut
  reg    [4:0]  length_p3               ; // pipeline3: huffman code length
  wire   [10:0] coeff_ext_p3            ; // pipeline3: code of extra bits
  reg           eob_flag_p3             ; // pipeline3: delay of eob_flag
  reg    [26:0] huffman_code_p3         ; // pipeline3: huffman code output(with extra bits)
  wire   [4:0]  huffman_code_len_p3     ; // pipeline3: huffman code output length(with extra bits)
  wire   [4:0]  left_aligned_bits_p3    ; // pipeline3: count of zero on the left of huffman code
  wire   [26:0] huffman_code_shift_3_p3 ; // pipeline3: shift huffman code to left aligned
  wire   [26:0] huffman_code_shift_2_p3 ; // pipeline3: shift huffman code to left aligned
  wire   [26:0] huffman_code_shift_1_p3 ; // pipeline3: shift huffman code to left aligned
  wire   [26:0] huffman_code_shift_0_p3 ; // pipeline3: shift huffman code to left aligned

  reg           code_out_valid_p4       ; // pipeline4: huffman code output valid
  reg    [26:0] huffman_code_p4         ; // pipeline4: huffman code output(with extra bits)
  reg    [4:0]  huffman_code_len_p4     ; // pipeline4: huffman code output length(with extra bits)
  reg           eob_flag_p4             ; // pipeline4: delay of eob_flag

//--------------------------------------------
//    input stage
//--------------------------------------------

  assign in_dat_type = dc_coeff_in_valid ? DC_COEFF : AC_COEFF;
  assign coeff_in_valid = ac_coeff_in_valid | dc_coeff_in_valid;

  assign coeff = dc_coeff_in_valid ? dc_coeff : // DC_LUM
                                     ac_coeff ; // AC_LUM

//--------------------------------------------
//    pipeline stage 1
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          coeff_in_valid_p1 <= `DLY 1'b0;
      end
      else begin
          coeff_in_valid_p1 <= `DLY coeff_in_valid;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          coeff_neg_p1 <= `DLY 1'b0;
      end
      else if (coeff_in_valid) begin
          coeff_neg_p1 <= `DLY coeff[11];
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          coeff_abs_p1 <= `DLY 11'h0;
      end
      else if (coeff_in_valid) begin
          if (coeff[11]) begin
              coeff_abs_p1 <= `DLY ~coeff[10:0] + 11'b1;
          end
          else begin
              coeff_abs_p1 <= `DLY coeff[10:0];
          end
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          run_length_p1 <= `DLY 4'h0;
          eob_flag_p1   <= `DLY 1'b0;
      end
      else if (coeff_in_valid) begin
          run_length_p1 <= `DLY run_length;
          eob_flag_p1   <= `DLY eob_flag  ;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          in_dat_type_p1 <= `DLY 1'h0;
      end
      else if (coeff_in_valid) begin
          in_dat_type_p1 <= `DLY in_dat_type;
      end
  end

//--------------------------------------------
//    pipeline stage 2
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          coeff_in_valid_p2 <= `DLY 1'b0;
      end
      else begin
          coeff_in_valid_p2 <= `DLY coeff_in_valid_p1;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          extra_bits_p2 <= `DLY 4'h0;
      end
      else if (coeff_in_valid_p1) begin
          if (coeff_abs_p1[10])
              extra_bits_p2 <= `DLY 4'hB;
          else if (coeff_abs_p1[9])
              extra_bits_p2 <= `DLY 4'hA;
          else if (coeff_abs_p1[8])
              extra_bits_p2 <= `DLY 4'h9;
          else if (coeff_abs_p1[7])
              extra_bits_p2 <= `DLY 4'h8;
          else if (coeff_abs_p1[6])
              extra_bits_p2 <= `DLY 4'h7;
          else if (coeff_abs_p1[5])
              extra_bits_p2 <= `DLY 4'h6;
          else if (coeff_abs_p1[4])
              extra_bits_p2 <= `DLY 4'h5;
          else if (coeff_abs_p1[3])
              extra_bits_p2 <= `DLY 4'h4;
          else if (coeff_abs_p1[2])
              extra_bits_p2 <= `DLY 4'h3;
          else if (coeff_abs_p1[1])
              extra_bits_p2 <= `DLY 4'h2;
          else if (coeff_abs_p1[0])
              extra_bits_p2 <= `DLY 4'h1;
          else
              extra_bits_p2 <= `DLY 4'h0;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          coeff_abs_p2 <= `DLY 11'h0;
          coeff_neg_p2 <= `DLY 1'b0 ;
      end
      else if (coeff_in_valid_p1) begin
          coeff_abs_p2 <= `DLY coeff_abs_p1;
          coeff_neg_p2 <= `DLY coeff_neg_p1;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          run_length_p2 <= `DLY 4'h0;
          eob_flag_p2   <= `DLY 1'b0;
      end
      else if (coeff_in_valid_p1) begin
          run_length_p2 <= `DLY run_length_p1;
          eob_flag_p2   <= `DLY eob_flag_p1  ;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          in_dat_type_p2 <= `DLY 1'h0;
      end
      else if (coeff_in_valid_p1) begin
          in_dat_type_p2 <= `DLY in_dat_type_p1;
      end
  end

  dc_lum_huffman dc_lum_huffman(
    // input coeff and run length
    .extra_bits       (extra_bits_p2        ), // <i>  4b, extra bits count
    // output huffman code and length
    .code             (dc_lum_code_p2       ), // <o> 16b, huffman code
    .length           (dc_lum_length_p2     )  // <o>  5b, huffman code length
    );

  ac_lum_huffman ac_lum_huffman(
    // input coeff and run length
    .extra_bits       (extra_bits_p2        ), // <i>  4b, extra bits count
    .run_length       (run_length_p2        ), // <i>  4b, run length
    // output huffman code and length
    .code             (ac_lum_code_p2       ), // <o> 16b, huffman code
    .length           (ac_lum_length_p2     )  // <o>  5b, huffman code length
    );

//--------------------------------------------
//    pipeline stage 3
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          code_out_valid_p3 <= `DLY 1'b0;
      end
      else begin
          code_out_valid_p3 <= `DLY coeff_in_valid_p2;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          extra_bits_p3 <= `DLY 4'h0;
      end
      else if (coeff_in_valid_p2) begin
          extra_bits_p3 <= `DLY extra_bits_p2;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          coeff_abs_p3 <= `DLY 11'h0;
          coeff_neg_p3 <= `DLY 1'b0 ;
      end
      else if (coeff_in_valid_p2) begin
          coeff_abs_p3 <= `DLY coeff_abs_p2;
          coeff_neg_p3 <= `DLY coeff_neg_p2;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          code_p3   <= `DLY 16'h0;
          length_p3 <= `DLY 4'h0 ;
      end
      else if (coeff_in_valid_p2) begin
          case (in_dat_type_p2)
              DC_COEFF:
                      begin
                          code_p3   <= `DLY dc_lum_code_p2  ;
                          length_p3 <= `DLY dc_lum_length_p2;
                      end
              default: // AC_COEFF
                      begin
                          code_p3   <= `DLY ac_lum_code_p2  ;
                          length_p3 <= `DLY ac_lum_length_p2;
                      end
          endcase
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          eob_flag_p3 <= `DLY 1'b0;
      end
      else if (coeff_in_valid_p2) begin
          eob_flag_p3 <= `DLY eob_flag_p2;
      end
  end

  assign coeff_ext_p3 = coeff_neg_p3 ? ~coeff_abs_p3 : coeff_abs_p3;

  always @(*) begin
      case (extra_bits_p3)
          4'h0   : huffman_code_p3 = {code_p3                    , 11'h7FF}; // 00
          4'h1   : huffman_code_p3 = {code_p3, coeff_ext_p3[0]   , 10'h3FF}; // 010
          4'h2   : huffman_code_p3 = {code_p3, coeff_ext_p3[1:0] , 9'h1FF }; // 011
          4'h3   : huffman_code_p3 = {code_p3, coeff_ext_p3[2:0] , 8'hFF  }; // 100
          4'h4   : huffman_code_p3 = {code_p3, coeff_ext_p3[3:0] , 7'h7F  }; // 101
          4'h5   : huffman_code_p3 = {code_p3, coeff_ext_p3[4:0] , 6'h3F  }; // 110
          4'h6   : huffman_code_p3 = {code_p3, coeff_ext_p3[5:0] , 5'h1F  }; // 1110
          4'h7   : huffman_code_p3 = {code_p3, coeff_ext_p3[6:0] , 4'hF   }; // 11110
          4'h8   : huffman_code_p3 = {code_p3, coeff_ext_p3[7:0] , 3'h7   }; // 111110
          4'h9   : huffman_code_p3 = {code_p3, coeff_ext_p3[8:0] , 2'h3   }; // 1111110
          4'ha   : huffman_code_p3 = {code_p3, coeff_ext_p3[9:0] , 1'h1   }; // 11111110
          4'hb   : huffman_code_p3 = {code_p3, coeff_ext_p3[10:0]         }; // 111111110
          default: huffman_code_p3 = {code_p3                    , 11'h7FF};
      endcase
  end

  // calc the count of zero on the left
  assign left_aligned_bits_p3 = 16 - length_p3;

  // shift huffman code to left aligned
  // left_aligned_bits_p3 is less than 16, so bit[4] ignored
  assign huffman_code_shift_3_p3 = left_aligned_bits_p3[3] ? {huffman_code_p3[18:0], 8'hFF}        : huffman_code_p3        ;
  assign huffman_code_shift_2_p3 = left_aligned_bits_p3[2] ? {huffman_code_shift_3_p3[22:0], 4'hF} : huffman_code_shift_3_p3;
  assign huffman_code_shift_1_p3 = left_aligned_bits_p3[1] ? {huffman_code_shift_2_p3[24:0], 2'h3} : huffman_code_shift_2_p3;
  assign huffman_code_shift_0_p3 = left_aligned_bits_p3[0] ? {huffman_code_shift_1_p3[25:0], 1'h1} : huffman_code_shift_1_p3;

  assign huffman_code_len_p3 = length_p3 + extra_bits_p3;

//--------------------------------------------
//    pipeline stage 4
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          code_out_valid_p4 <= `DLY 1'b0;
      end
      else begin
          code_out_valid_p4 <= `DLY code_out_valid_p3;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          huffman_code_len_p4 <= `DLY 5'h0;
          huffman_code_p4     <= `DLY 27'h0;
          eob_flag_p4         <= `DLY 1'b0;
      end
      else if (code_out_valid_p3) begin
          huffman_code_len_p4 <= `DLY huffman_code_len_p3;
          huffman_code_p4     <= `DLY huffman_code_shift_0_p3;
          eob_flag_p4         <= `DLY eob_flag_p3;
      end
  end

  assign code_out_valid = code_out_valid_p4  ;
  assign length         = huffman_code_len_p4;
  assign code           = huffman_code_p4    ;
  assign eob_out        = eob_flag_p4        ;

endmodule
