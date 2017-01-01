`define DLY #1

module divide(
    // global
    clk               , // <i>  1b, global clock
    rstn              , // <i>  1b, global reset, active low
    // dividend and divisor input
    dividend          , // <i> 19b, dividend input, s18.0
    divisor           , // <i>  8b, divisor input, u8.0
    div_in_valid      , // <i>  1b, dividend and divisor input valid
    // quotient output
    quotient          , // <o> 11b, quotient output, s10.0
    div_out_valid       // <o>  1b, quotient output valid
    );

  // global
  input         clk               ; // <i>  1b, global clock
  input         rstn              ; // <i>  1b, global reset, active low
  // dividend and divisor input
  input  [18:0] dividend          ; // <i> 19b, dividend input, s18.0
  input  [7:0]  divisor           ; // <i>  8b, divisor input, u8.0
  input         div_in_valid      ; // <i>  1b, dividend and divisor input valid
  // quotient output
  output [10:0] quotient          ; // <o> 11b, quotient output, s10.0
  output        div_out_valid     ; // <o>  1b, quotient output valid

  wire          neg_flag          ; // input dividend negative flag

  reg           neg_flag_p1       ; // dividend negative flag in pipeline stage1
  reg    [18:0] dividend_abs_p1   ; // abs of dividend in pipeline stage1
  reg    [7:0]  divisor_p1        ; // divisor in pipeline stage1
  wire   [18:0] diff_p1           ; // diff of dividend_abs and divisor in pipeline stage1
  wire          quotient_p1       ; // quotient calc in pipeline stage1
  reg           div_pipe_valid_p1 ; // divide pipeline stage 1 valid

  wire          neg_flag_p2       ; // dividend negative flag in pipeline stage2
  wire   [17:0] dividend_abs_p2   ; // abs of dividend in pipeline stage2
  wire   [7:0]  divisor_p2        ; // divisor in pipeline stage2
  wire   [17:0] diff_p2           ; // diff of dividend_abs and divisor in pipeline stage2
  wire   [1:0]  quotient_p2       ; // quotient calc in pipeline stage2
  wire          div_pipe_valid_p2 ; // divide pipeline stage 2 valid

  reg           neg_flag_p3       ; // dividend negative flag in pipeline stage3
  reg    [16:0] dividend_abs_p3   ; // abs of dividend in pipeline stage3
  reg    [7:0]  divisor_p3        ; // divisor in pipeline stage3
  reg    [1:0]  quotient_tmp_p3   ; // delay of the previous quotient result in pipeline stage3
  wire   [16:0] diff_p3           ; // diff of dividend_abs and divisor in pipeline stage3
  wire   [2:0]  quotient_p3       ; // quotient calc in pipeline stage3
  reg           div_pipe_valid_p3 ; // divide pipeline stage 3 valid

  wire          neg_flag_p4       ; // dividend negative flag in pipeline stage4
  wire   [15:0] dividend_abs_p4   ; // abs of dividend in pipeline stage4
  wire   [7:0]  divisor_p4        ; // divisor in pipeline stage4
  wire   [15:0] diff_p4           ; // diff of dividend_abs and divisor in pipeline stage4
  wire   [3:0]  quotient_p4       ; // quotient calc in pipeline stage4
  wire          div_pipe_valid_p4 ; // divide pipeline stage 4 valid

  reg           neg_flag_p5       ; // dividend negative flag in pipeline stage5
  reg    [14:0] dividend_abs_p5   ; // abs of dividend in pipeline stage5
  reg    [7:0]  divisor_p5        ; // divisor in pipeline stage5
  reg    [3:0]  quotient_tmp_p5   ; // delay of the previous quotient result in pipeline stage5
  wire   [14:0] diff_p5           ; // diff of dividend_abs and divisor in pipeline stage5
  wire   [4:0]  quotient_p5       ; // quotient calc in pipeline stage5
  reg           div_pipe_valid_p5 ; // divide pipeline stage 5 valid

  wire          neg_flag_p6       ; // dividend negative flag in pipeline stage6
  wire   [13:0] dividend_abs_p6   ; // abs of dividend in pipeline stage6
  wire   [7:0]  divisor_p6        ; // divisor in pipeline stage6
  wire   [13:0] diff_p6           ; // diff of dividend_abs and divisor in pipeline stage6
  wire   [5:0]  quotient_p6       ; // quotient calc in pipeline stage6
  wire          div_pipe_valid_p6 ; // divide pipeline stage 6 valid

  reg           neg_flag_p7       ; // dividend negative flag in pipeline stage7
  reg    [12:0] dividend_abs_p7   ; // abs of dividend in pipeline stage7
  reg    [7:0]  divisor_p7        ; // divisor in pipeline stage7
  reg    [5:0]  quotient_tmp_p7   ; // delay of the previous quotient result in pipeline stage7
  wire   [12:0] diff_p7           ; // diff of dividend_abs and divisor in pipeline stage7
  wire   [6:0]  quotient_p7       ; // quotient calc in pipeline stage7
  reg           div_pipe_valid_p7 ; // divide pipeline stage 7 valid

  wire          neg_flag_p8       ; // dividend negative flag in pipeline stage8
  wire   [11:0] dividend_abs_p8   ; // abs of dividend in pipeline stage8
  wire   [7:0]  divisor_p8        ; // divisor in pipeline stage8
  wire   [11:0] diff_p8           ; // diff of dividend_abs and divisor in pipeline stage8
  wire   [7:0]  quotient_p8       ; // quotient calc in pipeline stage8
  wire          div_pipe_valid_p8 ; // divide pipeline stage 8 valid

  reg           neg_flag_p9       ; // dividend negative flag in pipeline stage9
  reg    [10:0] dividend_abs_p9   ; // abs of dividend in pipeline stage9
  reg    [7:0]  divisor_p9        ; // divisor in pipeline stage9
  reg    [7:0]  quotient_tmp_p9   ; // delay of the previous quotient result in pipeline stage9
  wire   [10:0] diff_p9           ; // diff of dividend_abs and divisor in pipeline stage9
  wire   [8:0]  quotient_p9       ; // quotient calc in pipeline stage9
  reg           div_pipe_valid_p9 ; // divide pipeline stage 9 valid

  wire          neg_flag_p10      ; // dividend negative flag in pipeline stage10
  wire   [9:0]  dividend_abs_p10  ; // abs of dividend in pipeline stage10
  wire   [7:0]  divisor_p10       ; // divisor in pipeline stage10
  wire   [9:0]  diff_p10          ; // diff of dividend_abs and divisor in pipeline stage10
  wire   [9:0]  quotient_p10      ; // quotient calc in pipeline stage10
  wire          div_pipe_valid_p10; // divide pipeline stage 10 valid

  reg           neg_flag_p11      ; // dividend negative flag in pipeline stage11
  reg    [8:0]  dividend_abs_p11  ; // abs of dividend in pipeline stage11
  reg    [7:0]  divisor_p11       ; // divisor in pipeline stage11
  reg    [9:0]  quotient_tmp_p11  ; // delay of the previous quotient result in pipeline stage11
  wire   [8:0]  diff_p11          ; // diff of dividend_abs and divisor in pipeline stage11
  wire   [10:0] quotient_p11      ; // quotient calc in pipeline stage11
  reg           div_pipe_valid_p11; // divide pipeline stage 11 valid

//--------------------------------------------
//    input stage
//--------------------------------------------

  assign neg_flag = dividend[18];

//--------------------------------------------
//    pipeline stage 1
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          neg_flag_p1     <= `DLY 1'b0;
          dividend_abs_p1 <= `DLY 19'h0;
          divisor_p1      <= `DLY 8'h0;
      end
      else if (div_in_valid) begin
          neg_flag_p1     <= `DLY neg_flag;
          dividend_abs_p1 <= `DLY neg_flag ? (~dividend + 1) : dividend;
          divisor_p1      <= `DLY divisor;
      end
  end

  assign diff_p1     = dividend_abs_p1 - {1'b0, divisor_p1, 10'h0};
  assign quotient_p1 = ~diff_p1[18];

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          div_pipe_valid_p1 <= `DLY 1'b0;
      end
      else begin
          div_pipe_valid_p1 <= `DLY div_in_valid;
      end
  end

//--------------------------------------------
//    pipeline stage 2
//--------------------------------------------

  assign neg_flag_p2       = neg_flag_p1;
  assign dividend_abs_p2   = diff_p1[18] ? dividend_abs_p1[17:0] : diff_p1[17:0];
  assign divisor_p2        = divisor_p1;
  assign diff_p2           = dividend_abs_p2 - {1'b0, divisor_p2, 9'h0};
  assign quotient_p2  = {quotient_p1, ~diff_p2[17]};
  assign div_pipe_valid_p2 = div_pipe_valid_p1;

//--------------------------------------------
//    pipeline stage 3
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          neg_flag_p3     <= `DLY 1'b0;
          dividend_abs_p3 <= `DLY 17'h0;
          divisor_p3      <= `DLY 8'h0;
          quotient_tmp_p3 <= `DLY 2'h0;
      end
      else if (div_pipe_valid_p2) begin
          neg_flag_p3     <= `DLY neg_flag_p2;
          dividend_abs_p3 <= `DLY diff_p2[17] ? dividend_abs_p2[16:0] : diff_p2[16:0];
          divisor_p3      <= `DLY divisor_p2;
          quotient_tmp_p3 <= `DLY quotient_p2;
      end
  end

  assign diff_p3     = dividend_abs_p3 - {1'b0, divisor_p3, 8'h0};
  assign quotient_p3 = {quotient_tmp_p3, ~diff_p3[16]};

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          div_pipe_valid_p3 <= `DLY 1'b0;
      end
      else begin
          div_pipe_valid_p3 <= `DLY div_pipe_valid_p2;
      end
  end

//--------------------------------------------
//    pipeline stage 4
//--------------------------------------------

  assign neg_flag_p4       = neg_flag_p3;
  assign dividend_abs_p4   = diff_p3[16] ? dividend_abs_p3[15:0] : diff_p3[15:0];
  assign divisor_p4        = divisor_p3;
  assign diff_p4           = dividend_abs_p4 - {1'b0, divisor_p4, 7'h0};
  assign quotient_p4  = {quotient_p3, ~diff_p4[15]};
  assign div_pipe_valid_p4 = div_pipe_valid_p3;

//--------------------------------------------
//    pipeline stage 5
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          neg_flag_p5     <= `DLY 1'b0;
          dividend_abs_p5 <= `DLY 15'h0;
          divisor_p5      <= `DLY 8'h0;
          quotient_tmp_p5 <= `DLY 4'h0;
      end
      else if (div_pipe_valid_p4) begin
          neg_flag_p5     <= `DLY neg_flag_p4;
          dividend_abs_p5 <= `DLY diff_p4[15] ? dividend_abs_p4[14:0] : diff_p4[14:0];
          divisor_p5      <= `DLY divisor_p4;
          quotient_tmp_p5 <= `DLY quotient_p4;
      end
  end

  assign diff_p5     = dividend_abs_p5 - {1'b0, divisor_p5, 6'h0};
  assign quotient_p5 = {quotient_tmp_p5, ~diff_p5[14]};

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          div_pipe_valid_p5 <= `DLY 1'b0;
      end
      else begin
          div_pipe_valid_p5 <= `DLY div_pipe_valid_p4;
      end
  end

//--------------------------------------------
//    pipeline stage 6
//--------------------------------------------

  assign neg_flag_p6       = neg_flag_p5;
  assign dividend_abs_p6   = diff_p5[14] ? dividend_abs_p5[13:0] : diff_p5[13:0];
  assign divisor_p6        = divisor_p5;
  assign diff_p6           = dividend_abs_p6 - {1'b0, divisor_p6, 5'h0};
  assign quotient_p6  = {quotient_p5, ~diff_p6[13]};
  assign div_pipe_valid_p6 = div_pipe_valid_p5;

//--------------------------------------------
//    pipeline stage 7
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          neg_flag_p7     <= `DLY 1'b0;
          dividend_abs_p7 <= `DLY 13'h0;
          divisor_p7      <= `DLY 8'h0;
          quotient_tmp_p7 <= `DLY 6'h0;
      end
      else if (div_pipe_valid_p6) begin
          neg_flag_p7     <= `DLY neg_flag_p6;
          dividend_abs_p7 <= `DLY diff_p6[13] ? dividend_abs_p6[12:0] : diff_p6[12:0];
          divisor_p7      <= `DLY divisor_p6;
          quotient_tmp_p7 <= `DLY quotient_p6;
      end
  end

  assign diff_p7          = dividend_abs_p7 - {1'b0, divisor_p7, 4'h0};
  assign quotient_p7 = {quotient_tmp_p7, ~diff_p7[12]};

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          div_pipe_valid_p7 <= `DLY 1'b0;
      end
      else begin
          div_pipe_valid_p7 <= `DLY div_pipe_valid_p6;
      end
  end

//--------------------------------------------
//    pipeline stage 8
//--------------------------------------------

  assign neg_flag_p8       = neg_flag_p7;
  assign dividend_abs_p8   = diff_p7[12] ? dividend_abs_p7[11:0] : diff_p7[11:0];
  assign divisor_p8        = divisor_p7;
  assign diff_p8           = dividend_abs_p8 - {1'b0, divisor_p8, 3'h0};
  assign quotient_p8  = {quotient_p7, ~diff_p8[11]};
  assign div_pipe_valid_p8 = div_pipe_valid_p7;

//--------------------------------------------
//    pipeline stage 9
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          neg_flag_p9     <= `DLY 1'b0;
          dividend_abs_p9 <= `DLY 11'h0;
          divisor_p9      <= `DLY 8'h0;
          quotient_tmp_p9 <= `DLY 8'h0;
      end
      else if (div_pipe_valid_p8) begin
          neg_flag_p9     <= `DLY neg_flag_p8;
          dividend_abs_p9 <= `DLY diff_p8[11] ? dividend_abs_p8[10:0] : diff_p8[10:0];
          divisor_p9      <= `DLY divisor_p8;
          quotient_tmp_p9 <= `DLY quotient_p8;
      end
  end

  assign diff_p9     = dividend_abs_p9 - {1'b0, divisor_p9, 2'h0};
  assign quotient_p9 = {quotient_tmp_p9, ~diff_p9[10]};

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          div_pipe_valid_p9 <= `DLY 1'b0;
      end
      else begin
          div_pipe_valid_p9 <= `DLY div_pipe_valid_p8;
      end
  end

//--------------------------------------------
//    pipeline stage 10
//--------------------------------------------

  assign neg_flag_p10       = neg_flag_p9;
  assign dividend_abs_p10   = diff_p9[10] ? dividend_abs_p9[9:0] : diff_p9[9:0];
  assign divisor_p10        = divisor_p9;
  assign diff_p10           = dividend_abs_p10 - {1'b0, divisor_p10, 1'h0};
  assign quotient_p10       = {quotient_p9, ~diff_p10[9]};
  assign div_pipe_valid_p10 = div_pipe_valid_p9;

//--------------------------------------------
//    pipeline stage 11
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          neg_flag_p11     <= `DLY 1'b0;
          dividend_abs_p11 <= `DLY 9'h0;
          divisor_p11      <= `DLY 8'h0;
          quotient_tmp_p11 <= `DLY 10'h0;
      end
      else if (div_pipe_valid_p10) begin
          neg_flag_p11     <= `DLY neg_flag_p10;
          dividend_abs_p11 <= `DLY diff_p10[9] ? dividend_abs_p10[8:0] : diff_p10[8:0];
          divisor_p11      <= `DLY divisor_p10;
          quotient_tmp_p11 <= `DLY quotient_p10;
      end
  end

  assign diff_p11     = dividend_abs_p11 - {1'b0, divisor_p11};
  assign quotient_p11 = {quotient_tmp_p11, ~diff_p11[8]};

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          div_pipe_valid_p11 <= `DLY 1'b0;
      end
      else begin
          div_pipe_valid_p11 <= `DLY div_pipe_valid_p10;
      end
  end

//--------------------------------------------
//    output stage
//--------------------------------------------

  assign quotient = neg_flag_p11 ? (~quotient_p11 + 1) : quotient_p11;
  assign div_out_valid = div_pipe_valid_p11;

endmodule
