`define DLY #1

module jpeg_get_pixels(
    // global signals
    clk                 , // <i>  1b, global clock
    rstn                , // <i>  1b, global reset, active low
    // data from 8 line fifo
    sdata_rvld          , // <i>  8b, input 8 line r data valid
    sdata_gvld          , // <i>  8b, input 8 line g data valid
    sdata_bvld          , // <i>  8b, input 8 line b data valid
    sdata_rrdy          , // <o>  8b, input r data accept
    sdata_grdy          , // <o>  8b, input g data accept
    sdata_brdy          , // <o>  8b, input b data accept
    sdata_r0            , // <i> 64b, r data from line0 of a block
    sdata_r1            , // <i> 64b, r data from line1 of a block
    sdata_r2            , // <i> 64b, r data from line2 of a block
    sdata_r3            , // <i> 64b, r data from line3 of a block
    sdata_r4            , // <i> 64b, r data from line4 of a block
    sdata_r5            , // <i> 64b, r data from line5 of a block
    sdata_r6            , // <i> 64b, r data from line6 of a block
    sdata_r7            , // <i> 64b, r data from line7 of a block
    sdata_g0            , // <i> 64b, g data from line0 of a block
    sdata_g1            , // <i> 64b, g data from line1 of a block
    sdata_g2            , // <i> 64b, g data from line2 of a block
    sdata_g3            , // <i> 64b, g data from line3 of a block
    sdata_g4            , // <i> 64b, g data from line4 of a block
    sdata_g5            , // <i> 64b, g data from line5 of a block
    sdata_g6            , // <i> 64b, g data from line6 of a block
    sdata_g7            , // <i> 64b, g data from line7 of a block
    sdata_b0            , // <i> 64b, b data from line0 of a block
    sdata_b1            , // <i> 64b, b data from line1 of a block
    sdata_b2            , // <i> 64b, b data from line2 of a block
    sdata_b3            , // <i> 64b, b data from line3 of a block
    sdata_b4            , // <i> 64b, b data from line4 of a block
    sdata_b5            , // <i> 64b, b data from line5 of a block
    sdata_b6            , // <i> 64b, b data from line6 of a block
    sdata_b7            , // <i> 64b, b data from line7 of a block
    // pixel data output
    pixel_data_out      , // <o> 24b, pixel data input
    pixel_out_valid       // <o>  1b, pixel data input valid
    );

  // global signals
  input         clk                 ; // <i>  1b, global clock
  input         rstn                ; // <i>  1b, global reset, active low
  // data from 8 line fifo
  input  [7:0]  sdata_rvld          ; // <i>  8b, input 8 line r data valid
  input  [7:0]  sdata_gvld          ; // <i>  8b, input 8 line g data valid
  input  [7:0]  sdata_bvld          ; // <i>  8b, input 8 line b data valid
  output [7:0]  sdata_rrdy          ; // <o>  8b, input r data accept
  output [7:0]  sdata_grdy          ; // <o>  8b, input g data accept
  output [7:0]  sdata_brdy          ; // <o>  8b, input b data accept
  input  [63:0] sdata_r0            ; // <i> 64b, r data from line0 of a block
  input  [63:0] sdata_r1            ; // <i> 64b, r data from line1 of a block
  input  [63:0] sdata_r2            ; // <i> 64b, r data from line2 of a block
  input  [63:0] sdata_r3            ; // <i> 64b, r data from line3 of a block
  input  [63:0] sdata_r4            ; // <i> 64b, r data from line4 of a block
  input  [63:0] sdata_r5            ; // <i> 64b, r data from line5 of a block
  input  [63:0] sdata_r6            ; // <i> 64b, r data from line6 of a block
  input  [63:0] sdata_r7            ; // <i> 64b, r data from line7 of a block
  input  [63:0] sdata_g0            ; // <i> 64b, g data from line0 of a block
  input  [63:0] sdata_g1            ; // <i> 64b, g data from line1 of a block
  input  [63:0] sdata_g2            ; // <i> 64b, g data from line2 of a block
  input  [63:0] sdata_g3            ; // <i> 64b, g data from line3 of a block
  input  [63:0] sdata_g4            ; // <i> 64b, g data from line4 of a block
  input  [63:0] sdata_g5            ; // <i> 64b, g data from line5 of a block
  input  [63:0] sdata_g6            ; // <i> 64b, g data from line6 of a block
  input  [63:0] sdata_g7            ; // <i> 64b, g data from line7 of a block
  input  [63:0] sdata_b0            ; // <i> 64b, b data from line0 of a block
  input  [63:0] sdata_b1            ; // <i> 64b, b data from line1 of a block
  input  [63:0] sdata_b2            ; // <i> 64b, b data from line2 of a block
  input  [63:0] sdata_b3            ; // <i> 64b, b data from line3 of a block
  input  [63:0] sdata_b4            ; // <i> 64b, b data from line4 of a block
  input  [63:0] sdata_b5            ; // <i> 64b, b data from line5 of a block
  input  [63:0] sdata_b6            ; // <i> 64b, b data from line6 of a block
  input  [63:0] sdata_b7            ; // <i> 64b, b data from line7 of a block
  // pixel data output
  output [23:0] pixel_data_out      ; // <o> 24b, pixel data input
  output        pixel_out_valid     ; // <o>  1b, pixel data input valid

  reg    [23:0] pixel_data_out      ;

  reg    [5:0]  pixel_out_cnt       ;
  reg    [23:0] pixel_from_line0    ;
  reg    [23:0] pixel_from_line1    ;
  reg    [23:0] pixel_from_line2    ;
  reg    [23:0] pixel_from_line3    ;
  reg    [23:0] pixel_from_line4    ;
  reg    [23:0] pixel_from_line5    ;
  reg    [23:0] pixel_from_line6    ;
  reg    [23:0] pixel_from_line7    ;

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          pixel_out_cnt <= `DLY 6'h0;
      end
      else if (pixel_out_valid) begin
          pixel_out_cnt <= `DLY pixel_out_cnt + 6'h1;
      end
  end

  assign pixel_out_valid = (&sdata_rvld) & (&sdata_gvld) & (&sdata_bvld);

  assign sdata_rrdy = {8{pixel_out_valid & (pixel_out_cnt == 6'h3F)}};
  assign sdata_grdy = {8{pixel_out_valid & (pixel_out_cnt == 6'h3F)}};
  assign sdata_brdy = {8{pixel_out_valid & (pixel_out_cnt == 6'h3F)}};

  always @(*) begin
      case (pixel_out_cnt[2:0])
          3'h0   : pixel_from_line0 = {sdata_r0[63:56], sdata_g0[63:56], sdata_b0[63:56]};
          3'h1   : pixel_from_line0 = {sdata_r0[55:48], sdata_g0[55:48], sdata_b0[55:48]};
          3'h2   : pixel_from_line0 = {sdata_r0[47:40], sdata_g0[47:40], sdata_b0[47:40]};
          3'h3   : pixel_from_line0 = {sdata_r0[39:32], sdata_g0[39:32], sdata_b0[39:32]};
          3'h4   : pixel_from_line0 = {sdata_r0[31:24], sdata_g0[31:24], sdata_b0[31:24]};
          3'h5   : pixel_from_line0 = {sdata_r0[23:16], sdata_g0[23:16], sdata_b0[23:16]};
          3'h6   : pixel_from_line0 = {sdata_r0[15:8] , sdata_g0[15:8] , sdata_b0[15:8] };
          default: pixel_from_line0 = {sdata_r0[7:0]  , sdata_g0[7:0]  , sdata_b0[7:0]  };
      endcase
  end

  always @(*) begin
      case (pixel_out_cnt[2:0])
          3'h0   : pixel_from_line1 = {sdata_r1[63:56], sdata_g1[63:56], sdata_b1[63:56]};
          3'h1   : pixel_from_line1 = {sdata_r1[55:48], sdata_g1[55:48], sdata_b1[55:48]};
          3'h2   : pixel_from_line1 = {sdata_r1[47:40], sdata_g1[47:40], sdata_b1[47:40]};
          3'h3   : pixel_from_line1 = {sdata_r1[39:32], sdata_g1[39:32], sdata_b1[39:32]};
          3'h4   : pixel_from_line1 = {sdata_r1[31:24], sdata_g1[31:24], sdata_b1[31:24]};
          3'h5   : pixel_from_line1 = {sdata_r1[23:16], sdata_g1[23:16], sdata_b1[23:16]};
          3'h6   : pixel_from_line1 = {sdata_r1[15:8] , sdata_g1[15:8] , sdata_b1[15:8] };
          default: pixel_from_line1 = {sdata_r1[7:0]  , sdata_g1[7:0]  , sdata_b1[7:0]  };
      endcase
  end

  always @(*) begin
      case (pixel_out_cnt[2:0])
          3'h0   : pixel_from_line2 = {sdata_r2[63:56], sdata_g2[63:56], sdata_b2[63:56]};
          3'h1   : pixel_from_line2 = {sdata_r2[55:48], sdata_g2[55:48], sdata_b2[55:48]};
          3'h2   : pixel_from_line2 = {sdata_r2[47:40], sdata_g2[47:40], sdata_b2[47:40]};
          3'h3   : pixel_from_line2 = {sdata_r2[39:32], sdata_g2[39:32], sdata_b2[39:32]};
          3'h4   : pixel_from_line2 = {sdata_r2[31:24], sdata_g2[31:24], sdata_b2[31:24]};
          3'h5   : pixel_from_line2 = {sdata_r2[23:16], sdata_g2[23:16], sdata_b2[23:16]};
          3'h6   : pixel_from_line2 = {sdata_r2[15:8] , sdata_g2[15:8] , sdata_b2[15:8] };
          default: pixel_from_line2 = {sdata_r2[7:0]  , sdata_g2[7:0]  , sdata_b2[7:0]  };
      endcase
  end

  always @(*) begin
      case (pixel_out_cnt[2:0])
          3'h0   : pixel_from_line3 = {sdata_r3[63:56], sdata_g3[63:56], sdata_b3[63:56]};
          3'h1   : pixel_from_line3 = {sdata_r3[55:48], sdata_g3[55:48], sdata_b3[55:48]};
          3'h2   : pixel_from_line3 = {sdata_r3[47:40], sdata_g3[47:40], sdata_b3[47:40]};
          3'h3   : pixel_from_line3 = {sdata_r3[39:32], sdata_g3[39:32], sdata_b3[39:32]};
          3'h4   : pixel_from_line3 = {sdata_r3[31:24], sdata_g3[31:24], sdata_b3[31:24]};
          3'h5   : pixel_from_line3 = {sdata_r3[23:16], sdata_g3[23:16], sdata_b3[23:16]};
          3'h6   : pixel_from_line3 = {sdata_r3[15:8] , sdata_g3[15:8] , sdata_b3[15:8] };
          default: pixel_from_line3 = {sdata_r3[7:0]  , sdata_g3[7:0]  , sdata_b3[7:0]  };
      endcase
  end

  always @(*) begin
      case (pixel_out_cnt[2:0])
          3'h0   : pixel_from_line4 = {sdata_r4[63:56], sdata_g4[63:56], sdata_b4[63:56]};
          3'h1   : pixel_from_line4 = {sdata_r4[55:48], sdata_g4[55:48], sdata_b4[55:48]};
          3'h2   : pixel_from_line4 = {sdata_r4[47:40], sdata_g4[47:40], sdata_b4[47:40]};
          3'h3   : pixel_from_line4 = {sdata_r4[39:32], sdata_g4[39:32], sdata_b4[39:32]};
          3'h4   : pixel_from_line4 = {sdata_r4[31:24], sdata_g4[31:24], sdata_b4[31:24]};
          3'h5   : pixel_from_line4 = {sdata_r4[23:16], sdata_g4[23:16], sdata_b4[23:16]};
          3'h6   : pixel_from_line4 = {sdata_r4[15:8] , sdata_g4[15:8] , sdata_b4[15:8] };
          default: pixel_from_line4 = {sdata_r4[7:0]  , sdata_g4[7:0]  , sdata_b4[7:0]  };
      endcase
  end

  always @(*) begin
      case (pixel_out_cnt[2:0])
          3'h0   : pixel_from_line5 = {sdata_r5[63:56], sdata_g5[63:56], sdata_b5[63:56]};
          3'h1   : pixel_from_line5 = {sdata_r5[55:48], sdata_g5[55:48], sdata_b5[55:48]};
          3'h2   : pixel_from_line5 = {sdata_r5[47:40], sdata_g5[47:40], sdata_b5[47:40]};
          3'h3   : pixel_from_line5 = {sdata_r5[39:32], sdata_g5[39:32], sdata_b5[39:32]};
          3'h4   : pixel_from_line5 = {sdata_r5[31:24], sdata_g5[31:24], sdata_b5[31:24]};
          3'h5   : pixel_from_line5 = {sdata_r5[23:16], sdata_g5[23:16], sdata_b5[23:16]};
          3'h6   : pixel_from_line5 = {sdata_r5[15:8] , sdata_g5[15:8] , sdata_b5[15:8] };
          default: pixel_from_line5 = {sdata_r5[7:0]  , sdata_g5[7:0]  , sdata_b5[7:0]  };
      endcase
  end

  always @(*) begin
      case (pixel_out_cnt[2:0])
          3'h0   : pixel_from_line6 = {sdata_r6[63:56], sdata_g6[63:56], sdata_b6[63:56]};
          3'h1   : pixel_from_line6 = {sdata_r6[55:48], sdata_g6[55:48], sdata_b6[55:48]};
          3'h2   : pixel_from_line6 = {sdata_r6[47:40], sdata_g6[47:40], sdata_b6[47:40]};
          3'h3   : pixel_from_line6 = {sdata_r6[39:32], sdata_g6[39:32], sdata_b6[39:32]};
          3'h4   : pixel_from_line6 = {sdata_r6[31:24], sdata_g6[31:24], sdata_b6[31:24]};
          3'h5   : pixel_from_line6 = {sdata_r6[23:16], sdata_g6[23:16], sdata_b6[23:16]};
          3'h6   : pixel_from_line6 = {sdata_r6[15:8] , sdata_g6[15:8] , sdata_b6[15:8] };
          default: pixel_from_line6 = {sdata_r6[7:0]  , sdata_g6[7:0]  , sdata_b6[7:0]  };
      endcase
  end

  always @(*) begin
      case (pixel_out_cnt[2:0])
          3'h0   : pixel_from_line7 = {sdata_r7[63:56], sdata_g7[63:56], sdata_b7[63:56]};
          3'h1   : pixel_from_line7 = {sdata_r7[55:48], sdata_g7[55:48], sdata_b7[55:48]};
          3'h2   : pixel_from_line7 = {sdata_r7[47:40], sdata_g7[47:40], sdata_b7[47:40]};
          3'h3   : pixel_from_line7 = {sdata_r7[39:32], sdata_g7[39:32], sdata_b7[39:32]};
          3'h4   : pixel_from_line7 = {sdata_r7[31:24], sdata_g7[31:24], sdata_b7[31:24]};
          3'h5   : pixel_from_line7 = {sdata_r7[23:16], sdata_g7[23:16], sdata_b7[23:16]};
          3'h6   : pixel_from_line7 = {sdata_r7[15:8] , sdata_g7[15:8] , sdata_b7[15:8] };
          default: pixel_from_line7 = {sdata_r7[7:0]  , sdata_g7[7:0]  , sdata_b7[7:0]  };
      endcase
  end

  always @(*) begin
      case (pixel_out_cnt[5:3])
          3'h0   : pixel_data_out = pixel_from_line0;
          3'h1   : pixel_data_out = pixel_from_line1;
          3'h2   : pixel_data_out = pixel_from_line2;
          3'h3   : pixel_data_out = pixel_from_line3;
          3'h4   : pixel_data_out = pixel_from_line4;
          3'h5   : pixel_data_out = pixel_from_line5;
          3'h6   : pixel_data_out = pixel_from_line6;
          default: pixel_data_out = pixel_from_line7;
      endcase
  end

endmodule
