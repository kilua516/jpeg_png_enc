`define DLY #1

module rgb2yuv(
    // global signals
    clk             , // <i>  1b, global clock
    rstn            , // <i>  1b, global reset, active low
    // pixel data input
    pixel_data_in   , // <i> 24b, pixel data input
    pixel_in_valid  , // <i>  1b, pixel data input valid
    // pixel data output
    pixel_data_out  , // <o> 24b, dct data output
    pixel_out_valid   // <o>  1b, dct data output valid
    );

  // global signals
  input         clk             ; // <i>  1b, global clock
  input         rstn            ; // <i>  1b, global reset, active low
  // pixel data input
  input  [23:0] pixel_data_in   ; // <i> 24b, pixel data input
  input         pixel_in_valid  ; // <i>  1b, pixel data input valid
  // pixel data output
  output [23:0] pixel_data_out  ; // <o> 24b, dct data output
  output        pixel_out_valid ; // <o>  1b, dct data output valid

  reg           pixel_out_valid ;

  wire   [7:0]  r_in    ;
  wire   [7:0]  g_in    ;
  wire   [7:0]  b_in    ;

  wire   [19:0] y_tmp   ;
  wire   [19:0] u_tmp   ;
  wire   [19:0] v_tmp   ;

  reg    [7:0]  y_clip  ;
  reg    [7:0]  u_clip  ;
  reg    [7:0]  v_clip  ;

  assign r_in = pixel_data_in[23:16];
  assign g_in = pixel_data_in[15:8] ;
  assign b_in = pixel_data_in[7:0]  ;

  assign y_tmp = ( 218 * $signed({1'b0, r_in}) + 732 * $signed({1'b0, g_in}) +  74 * $signed({1'b0, b_in}));
  assign u_tmp = (-117 * $signed({1'b0, r_in}) - 395 * $signed({1'b0, g_in}) + 512 * $signed({1'b0, b_in})) + 131072;
  assign v_tmp = ( 512 * $signed({1'b0, r_in}) - 465 * $signed({1'b0, g_in}) -  47 * $signed({1'b0, b_in})) + 131072;

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_clip <= `DLY 8'h0;
      end
      else if (pixel_in_valid) begin
          y_clip <= `DLY (y_tmp[19])          ? 0           :
                         (y_tmp[18:10] > 255) ? 255         :
                                                y_tmp[17:10];
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_clip <= `DLY 8'h0;
      end
      else if (pixel_in_valid) begin
          u_clip <= `DLY (u_tmp[19])          ? 0           :
                         (u_tmp[18:10] > 255) ? 255         :
                                                u_tmp[17:10];
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_clip <= `DLY 8'h0;
      end
      else if (pixel_in_valid) begin
          v_clip <= `DLY (v_tmp[19])          ? 0           :
                         (v_tmp[18:10] > 255) ? 255         :
                                                v_tmp[17:10];
      end
  end

  assign pixel_data_out = {~y_clip[7], y_clip[6:0],
                           ~u_clip[7], u_clip[6:0], 
                           ~v_clip[7], v_clip[6:0]};

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          pixel_out_valid <= `DLY 1'b0;
      end
      else begin
          pixel_out_valid <= `DLY pixel_in_valid;
      end
  end

endmodule
