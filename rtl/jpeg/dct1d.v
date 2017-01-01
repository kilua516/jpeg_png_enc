`define DLY #1

module dct1d(
    // global signals
    clk             , // <i>  1b, global clock
    rstn            , // <i>  1b, global reset, active low
    // input 8 points data
    dct_in_0        , // <i> 11b, dct input symbol 0
    dct_in_1        , // <i> 11b, dct input symbol 1
    dct_in_2        , // <i> 11b, dct input symbol 2
    dct_in_3        , // <i> 11b, dct input symbol 3
    dct_in_4        , // <i> 11b, dct input symbol 4
    dct_in_5        , // <i> 11b, dct input symbol 5
    dct_in_6        , // <i> 11b, dct input symbol 6
    dct_in_7        , // <i> 11b, dct input symbol 7
    dct_in_valid    , // <i>  1b, dct input valid
    // output 8 points data
    dct_out_0       , // <o> 14b, dct output symbol 0
    dct_out_1       , // <o> 14b, dct output symbol 1
    dct_out_2       , // <o> 14b, dct output symbol 2
    dct_out_3       , // <o> 14b, dct output symbol 3
    dct_out_4       , // <o> 14b, dct output symbol 4
    dct_out_5       , // <o> 14b, dct output symbol 5
    dct_out_6       , // <o> 14b, dct output symbol 6
    dct_out_7       , // <o> 14b, dct output symbol 7
    dct_out_valid     // <o>  1b, dct output valid
    );

  // global signals
  input         clk             ; // <i>  1b, global clock
  input         rstn            ; // <i>  1b, global reset, active low
  // input 8 points data
  input  [10:0] dct_in_0        ; // <i> 11b, dct input symbol 0
  input  [10:0] dct_in_1        ; // <i> 11b, dct input symbol 1
  input  [10:0] dct_in_2        ; // <i> 11b, dct input symbol 2
  input  [10:0] dct_in_3        ; // <i> 11b, dct input symbol 3
  input  [10:0] dct_in_4        ; // <i> 11b, dct input symbol 4
  input  [10:0] dct_in_5        ; // <i> 11b, dct input symbol 5
  input  [10:0] dct_in_6        ; // <i> 11b, dct input symbol 6
  input  [10:0] dct_in_7        ; // <i> 11b, dct input symbol 7
  input         dct_in_valid    ; // <i>  1b, dct input valid
  // output 8 points data
  output [13:0] dct_out_0       ; // <o> 14b, dct output symbol 0
  output [13:0] dct_out_1       ; // <o> 14b, dct output symbol 1
  output [13:0] dct_out_2       ; // <o> 14b, dct output symbol 2
  output [13:0] dct_out_3       ; // <o> 14b, dct output symbol 3
  output [13:0] dct_out_4       ; // <o> 14b, dct output symbol 4
  output [13:0] dct_out_5       ; // <o> 14b, dct output symbol 5
  output [13:0] dct_out_6       ; // <o> 14b, dct output symbol 6
  output [13:0] dct_out_7       ; // <o> 14b, dct output symbol 7
  output        dct_out_valid   ; // <o>  1b, dct output valid

  parameter C1 = 10'd501;
  parameter C2 = 10'd472;
  parameter C3 = 10'd425;
  parameter C4 = 10'd361;
  parameter C5 = 10'd284;
  parameter C6 = 10'd195;
  parameter C7 = 10'd99 ;

  reg    [11:0] dct_tmp_0a7_p1    ;
  reg    [11:0] dct_tmp_1a6_p1    ;
  reg    [11:0] dct_tmp_2a5_p1    ;
  reg    [11:0] dct_tmp_3a4_p1    ;
  reg    [11:0] dct_tmp_0m7_p1    ;
  reg    [11:0] dct_tmp_1m6_p1    ;
  reg    [11:0] dct_tmp_2m5_p1    ;
  reg    [11:0] dct_tmp_3m4_p1    ;
  reg           dct_pipe_valid_p1 ;

  wire   [22:0] dct_tmp_0_p1      ;
  wire   [22:0] dct_tmp_1_p1      ;
  wire   [22:0] dct_tmp_2_p1      ;
  wire   [22:0] dct_tmp_3_p1      ;
  wire   [22:0] dct_tmp_4_p1      ;
  wire   [22:0] dct_tmp_5_p1      ;
  wire   [22:0] dct_tmp_6_p1      ;
  wire   [22:0] dct_tmp_7_p1      ;
  wire   [22:0] dct_tmp_8_p1      ;
  wire   [22:0] dct_tmp_9_p1      ;
  wire   [22:0] dct_tmp_10_p1     ;
  wire   [22:0] dct_tmp_11_p1     ;
  wire   [22:0] dct_tmp_12_p1     ;
  wire   [22:0] dct_tmp_13_p1     ;
  wire   [22:0] dct_tmp_14_p1     ;
  wire   [22:0] dct_tmp_15_p1     ;
  wire   [22:0] dct_tmp_16_p1     ;
  wire   [22:0] dct_tmp_17_p1     ;
  wire   [22:0] dct_tmp_18_p1     ;
  wire   [22:0] dct_tmp_19_p1     ;
  wire   [22:0] dct_tmp_20_p1     ;
  wire   [22:0] dct_tmp_21_p1     ;
  wire   [22:0] dct_tmp_22_p1     ;
  wire   [22:0] dct_tmp_23_p1     ;
  wire   [22:0] dct_tmp_24_p1     ;
  wire   [22:0] dct_tmp_25_p1     ;
  wire   [22:0] dct_tmp_26_p1     ;
  wire   [22:0] dct_tmp_27_p1     ;
  wire   [22:0] dct_tmp_28_p1     ;
  wire   [22:0] dct_tmp_29_p1     ;
  wire   [22:0] dct_tmp_30_p1     ;
  wire   [22:0] dct_tmp_31_p1     ;

  reg    [22:0] dct_tmp_0_p2      ;
  reg    [22:0] dct_tmp_1_p2      ;
  reg    [22:0] dct_tmp_2_p2      ;
  reg    [22:0] dct_tmp_3_p2      ;
  reg    [22:0] dct_tmp_4_p2      ;
  reg    [22:0] dct_tmp_5_p2      ;
  reg    [22:0] dct_tmp_6_p2      ;
  reg    [22:0] dct_tmp_7_p2      ;
  reg    [22:0] dct_tmp_8_p2      ;
  reg    [22:0] dct_tmp_9_p2      ;
  reg    [22:0] dct_tmp_10_p2     ;
  reg    [22:0] dct_tmp_11_p2     ;
  reg    [22:0] dct_tmp_12_p2     ;
  reg    [22:0] dct_tmp_13_p2     ;
  reg    [22:0] dct_tmp_14_p2     ;
  reg    [22:0] dct_tmp_15_p2     ;

  reg           dct_pipe_valid_p2 ;

  reg    [23:0] dct_tmp_0_p3      ;
  reg    [23:0] dct_tmp_1_p3      ;
  reg    [23:0] dct_tmp_2_p3      ;
  reg    [23:0] dct_tmp_3_p3      ;
  reg    [23:0] dct_tmp_4_p3      ;
  reg    [23:0] dct_tmp_5_p3      ;
  reg    [23:0] dct_tmp_6_p3      ;
  reg    [23:0] dct_tmp_7_p3      ;

  reg           dct_pipe_valid_p3 ;

//--------------------------------------------
//    pipeline stage 1
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dct_tmp_0a7_p1 <= `DLY 12'h0;
          dct_tmp_1a6_p1 <= `DLY 12'h0;
          dct_tmp_2a5_p1 <= `DLY 12'h0;
          dct_tmp_3a4_p1 <= `DLY 12'h0;
          dct_tmp_0m7_p1 <= `DLY 12'h0;
          dct_tmp_1m6_p1 <= `DLY 12'h0;
          dct_tmp_2m5_p1 <= `DLY 12'h0;
          dct_tmp_3m4_p1 <= `DLY 12'h0;
      end
      else if (dct_in_valid) begin
          dct_tmp_0a7_p1 <= `DLY {dct_in_0[10], dct_in_0} + {dct_in_7[10], dct_in_7};
          dct_tmp_1a6_p1 <= `DLY {dct_in_1[10], dct_in_1} + {dct_in_6[10], dct_in_6};
          dct_tmp_2a5_p1 <= `DLY {dct_in_2[10], dct_in_2} + {dct_in_5[10], dct_in_5};
          dct_tmp_3a4_p1 <= `DLY {dct_in_3[10], dct_in_3} + {dct_in_4[10], dct_in_4};
          dct_tmp_0m7_p1 <= `DLY {dct_in_0[10], dct_in_0} - {dct_in_7[10], dct_in_7};
          dct_tmp_1m6_p1 <= `DLY {dct_in_1[10], dct_in_1} - {dct_in_6[10], dct_in_6};
          dct_tmp_2m5_p1 <= `DLY {dct_in_2[10], dct_in_2} - {dct_in_5[10], dct_in_5};
          dct_tmp_3m4_p1 <= `DLY {dct_in_3[10], dct_in_3} - {dct_in_4[10], dct_in_4};
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dct_pipe_valid_p1 <= `DLY 1'b0;
      end
      else begin
          dct_pipe_valid_p1 <= `DLY dct_in_valid;
      end
  end

  assign dct_tmp_0_p1  = mul_12s_11s(dct_tmp_0a7_p1, {1'b0, C4});
  assign dct_tmp_1_p1  = mul_12s_11s(dct_tmp_1a6_p1, {1'b0, C4});
  assign dct_tmp_2_p1  = mul_12s_11s(dct_tmp_2a5_p1, {1'b0, C4});
  assign dct_tmp_3_p1  = mul_12s_11s(dct_tmp_3a4_p1, {1'b0, C4});
  assign dct_tmp_4_p1  = mul_12s_11s(dct_tmp_0m7_p1, {1'b0, C1});
  assign dct_tmp_5_p1  = mul_12s_11s(dct_tmp_1m6_p1, {1'b0, C3});
  assign dct_tmp_6_p1  = mul_12s_11s(dct_tmp_2m5_p1, {1'b0, C5});
  assign dct_tmp_7_p1  = mul_12s_11s(dct_tmp_3m4_p1, {1'b0, C7});
  assign dct_tmp_8_p1  = mul_12s_11s(dct_tmp_0a7_p1, {1'b0, C2});
  assign dct_tmp_9_p1  = mul_12s_11s(dct_tmp_1a6_p1, {1'b0, C6});
  assign dct_tmp_10_p1 = mul_12s_11s(dct_tmp_2a5_p1, {1'b0, C6});
  assign dct_tmp_11_p1 = mul_12s_11s(dct_tmp_3a4_p1, {1'b0, C2});
  assign dct_tmp_12_p1 = mul_12s_11s(dct_tmp_0m7_p1, {1'b0, C3});
  assign dct_tmp_13_p1 = mul_12s_11s(dct_tmp_1m6_p1, {1'b0, C7});
  assign dct_tmp_14_p1 = mul_12s_11s(dct_tmp_2m5_p1, {1'b0, C1});
  assign dct_tmp_15_p1 = mul_12s_11s(dct_tmp_3m4_p1, {1'b0, C5});
  assign dct_tmp_16_p1 = dct_tmp_0_p1                           ; // dct_tmp_0a7_p1 * c4;
  assign dct_tmp_17_p1 = dct_tmp_1_p1                           ; // dct_tmp_1a6_p1 * c4;
  assign dct_tmp_18_p1 = dct_tmp_2_p1                           ; // dct_tmp_2a5_p1 * c4;
  assign dct_tmp_19_p1 = dct_tmp_3_p1                           ; // dct_tmp_3a4_p1 * c4;
  assign dct_tmp_20_p1 = mul_12s_11s(dct_tmp_0m7_p1, {1'b0, C5});
  assign dct_tmp_21_p1 = mul_12s_11s(dct_tmp_1m6_p1, {1'b0, C1});
  assign dct_tmp_22_p1 = mul_12s_11s(dct_tmp_2m5_p1, {1'b0, C7});
  assign dct_tmp_23_p1 = mul_12s_11s(dct_tmp_3m4_p1, {1'b0, C3});
  assign dct_tmp_24_p1 = mul_12s_11s(dct_tmp_0a7_p1, {1'b0, C6});
  assign dct_tmp_25_p1 = mul_12s_11s(dct_tmp_1a6_p1, {1'b0, C2});
  assign dct_tmp_26_p1 = mul_12s_11s(dct_tmp_2a5_p1, {1'b0, C2});
  assign dct_tmp_27_p1 = mul_12s_11s(dct_tmp_3a4_p1, {1'b0, C6});
  assign dct_tmp_28_p1 = mul_12s_11s(dct_tmp_0m7_p1, {1'b0, C7});
  assign dct_tmp_29_p1 = mul_12s_11s(dct_tmp_1m6_p1, {1'b0, C5});
  assign dct_tmp_30_p1 = mul_12s_11s(dct_tmp_2m5_p1, {1'b0, C3});
  assign dct_tmp_31_p1 = mul_12s_11s(dct_tmp_3m4_p1, {1'b0, C1});

//--------------------------------------------
//    pipeline stage 2
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dct_tmp_0_p2  <= `DLY 23'h0;
          dct_tmp_1_p2  <= `DLY 23'h0;
          dct_tmp_2_p2  <= `DLY 23'h0;
          dct_tmp_3_p2  <= `DLY 23'h0;
          dct_tmp_4_p2  <= `DLY 23'h0;
          dct_tmp_5_p2  <= `DLY 23'h0;
          dct_tmp_6_p2  <= `DLY 23'h0;
          dct_tmp_7_p2  <= `DLY 23'h0;
          dct_tmp_8_p2  <= `DLY 23'h0;
          dct_tmp_9_p2  <= `DLY 23'h0;
          dct_tmp_10_p2 <= `DLY 23'h0;
          dct_tmp_11_p2 <= `DLY 23'h0;
          dct_tmp_12_p2 <= `DLY 23'h0;
          dct_tmp_13_p2 <= `DLY 23'h0;
          dct_tmp_14_p2 <= `DLY 23'h0;
          dct_tmp_15_p2 <= `DLY 23'h0;
      end
      else if (dct_pipe_valid_p1) begin
          dct_tmp_0_p2  <= `DLY dct_tmp_0_p1  + dct_tmp_1_p1 ;
          dct_tmp_1_p2  <= `DLY dct_tmp_2_p1  + dct_tmp_3_p1 ;
          dct_tmp_2_p2  <= `DLY dct_tmp_4_p1  + dct_tmp_5_p1 ;
          dct_tmp_3_p2  <= `DLY dct_tmp_6_p1  + dct_tmp_7_p1 ;
          dct_tmp_4_p2  <= `DLY dct_tmp_8_p1  + dct_tmp_9_p1 ;
          dct_tmp_5_p2  <= `DLY dct_tmp_10_p1 + dct_tmp_11_p1;
          dct_tmp_6_p2  <= `DLY dct_tmp_12_p1 - dct_tmp_13_p1;
          dct_tmp_7_p2  <= `DLY dct_tmp_14_p1 + dct_tmp_15_p1;
          dct_tmp_8_p2  <= `DLY dct_tmp_16_p1 - dct_tmp_17_p1;
          dct_tmp_9_p2  <= `DLY dct_tmp_18_p1 - dct_tmp_19_p1;
          dct_tmp_10_p2 <= `DLY dct_tmp_20_p1 - dct_tmp_21_p1;
          dct_tmp_11_p2 <= `DLY dct_tmp_22_p1 + dct_tmp_23_p1;
          dct_tmp_12_p2 <= `DLY dct_tmp_24_p1 - dct_tmp_25_p1;
          dct_tmp_13_p2 <= `DLY dct_tmp_26_p1 - dct_tmp_27_p1;
          dct_tmp_14_p2 <= `DLY dct_tmp_28_p1 - dct_tmp_29_p1;
          dct_tmp_15_p2 <= `DLY dct_tmp_30_p1 - dct_tmp_31_p1;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dct_pipe_valid_p2 <= `DLY 1'b0;
      end
      else begin
          dct_pipe_valid_p2 <= `DLY dct_pipe_valid_p1;
      end
  end

//--------------------------------------------
//    pipeline stage 3
//--------------------------------------------

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dct_tmp_0_p3 <= `DLY 24'h0;
          dct_tmp_1_p3 <= `DLY 24'h0;
          dct_tmp_2_p3 <= `DLY 24'h0;
          dct_tmp_3_p3 <= `DLY 24'h0;
          dct_tmp_4_p3 <= `DLY 24'h0;
          dct_tmp_5_p3 <= `DLY 24'h0;
          dct_tmp_6_p3 <= `DLY 24'h0;
          dct_tmp_7_p3 <= `DLY 24'h0;
      end
      else if (dct_pipe_valid_p2) begin
          dct_tmp_0_p3 <= `DLY {dct_tmp_0_p2[22] , dct_tmp_0_p2 } + {dct_tmp_1_p2[22] , dct_tmp_1_p2 };
          dct_tmp_1_p3 <= `DLY {dct_tmp_2_p2[22] , dct_tmp_2_p2 } + {dct_tmp_3_p2[22] , dct_tmp_3_p2 };
          dct_tmp_2_p3 <= `DLY {dct_tmp_4_p2[22] , dct_tmp_4_p2 } - {dct_tmp_5_p2[22] , dct_tmp_5_p2 };
          dct_tmp_3_p3 <= `DLY {dct_tmp_6_p2[22] , dct_tmp_6_p2 } - {dct_tmp_7_p2[22] , dct_tmp_7_p2 };
          dct_tmp_4_p3 <= `DLY {dct_tmp_8_p2[22] , dct_tmp_8_p2 } - {dct_tmp_9_p2[22] , dct_tmp_9_p2 };
          dct_tmp_5_p3 <= `DLY {dct_tmp_10_p2[22], dct_tmp_10_p2} + {dct_tmp_11_p2[22], dct_tmp_11_p2};
          dct_tmp_6_p3 <= `DLY {dct_tmp_12_p2[22], dct_tmp_12_p2} + {dct_tmp_13_p2[22], dct_tmp_13_p2};
          dct_tmp_7_p3 <= `DLY {dct_tmp_14_p2[22], dct_tmp_14_p2} + {dct_tmp_15_p2[22], dct_tmp_15_p2};
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          dct_pipe_valid_p3 <= `DLY 1'b0;
      end
      else begin
          dct_pipe_valid_p3 <= `DLY dct_pipe_valid_p2;
      end
  end

//--------------------------------------------
//    output stage
//--------------------------------------------

  assign dct_out_0     = dct_tmp_0_p3[23:10];
  assign dct_out_1     = dct_tmp_1_p3[23:10];
  assign dct_out_2     = dct_tmp_2_p3[23:10];
  assign dct_out_3     = dct_tmp_3_p3[23:10];
  assign dct_out_4     = dct_tmp_4_p3[23:10];
  assign dct_out_5     = dct_tmp_5_p3[23:10];
  assign dct_out_6     = dct_tmp_6_p3[23:10];
  assign dct_out_7     = dct_tmp_7_p3[23:10];
  assign dct_out_valid = dct_pipe_valid_p3;

  function [22:0] mul_12s_11s;
      input signed [11:0] a;
      input signed [10:0] b;
      mul_12s_11s = a*b;
  endfunction

endmodule
