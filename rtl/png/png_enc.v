`define DLY (#1)
//`default_nettype none

module png_enc(
    // global signals
    clk                 , // <i>  1b, system clock
    rstn                , // <i>  1b, global reset, active low
    // interface with control registers
    frame_start         , // <i>  1b, frame start indicator
    frame_end           , // <o>  1b, frame end indicator
    pic_width           , // <i> 11b, picture width
    pic_height          , // <i> 11b, picture height
    png_file_len        , // <o> 23b, png file length indicator
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
    // stream output
    cdata_vld           , // <o>  1b, png stream output valid
    cdata                 // <o> 32b, png stream output
    );

  // global signals
  input         clk                 ; // <i>  1b, system clock
  input         rstn                ; // <i>  1b, global reset, active low
  // interface with control registers
  input         frame_start         ; // <i>  1b, frame start indicator
  output        frame_end           ; // <o>  1b, frame end indicator
  input  [10:0] pic_width           ; // <i> 11b, picture width
  input  [10:0] pic_height          ; // <i> 11b, picture height
  output [22:0] png_file_len        ; // <o> 23b, png file length indicator
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
  // stream output
  output        cdata_vld           ; // <o>  1b, png stream output valid
  output [31:0] cdata               ; // <o> 32b, png stream output

  wire   [7:0]  pixel_out_data          ;
  wire          pixel_out_valid         ;
  wire          pixel_out_rdy           ;
  wire          pixel_out_done          ;

  wire  [10:0]  pic_width               ;
  wire  [10:0]  pic_height              ;

  png_get_pixels get_pixels_u0(
    // global signals
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // picture size
    .pic_width          (pic_width        ), // <i> 11b, picture width
    .pic_height         (pic_height       ), // <i> 11b, picture height
    // data from 8 line fifo
    .sdata_rvld         (sdata_rvld       ), // <i>  8b, input 8 line r data valid
    .sdata_gvld         (sdata_gvld       ), // <i>  8b, input 8 line g data valid
    .sdata_bvld         (sdata_bvld       ), // <i>  8b, input 8 line b data valid
    .sdata_rrdy         (sdata_rrdy       ), // <o>  8b, input r data accept
    .sdata_grdy         (sdata_grdy       ), // <o>  8b, input g data accept
    .sdata_brdy         (sdata_brdy       ), // <o>  8b, input b data accept
    .sdata_r0           (sdata_r0         ), // <i> 64b, r data from line0 of a block
    .sdata_r1           (sdata_r1         ), // <i> 64b, r data from line1 of a block
    .sdata_r2           (sdata_r2         ), // <i> 64b, r data from line2 of a block
    .sdata_r3           (sdata_r3         ), // <i> 64b, r data from line3 of a block
    .sdata_r4           (sdata_r4         ), // <i> 64b, r data from line4 of a block
    .sdata_r5           (sdata_r5         ), // <i> 64b, r data from line5 of a block
    .sdata_r6           (sdata_r6         ), // <i> 64b, r data from line6 of a block
    .sdata_r7           (sdata_r7         ), // <i> 64b, r data from line7 of a block
    .sdata_g0           (sdata_g0         ), // <i> 64b, g data from line0 of a block
    .sdata_g1           (sdata_g1         ), // <i> 64b, g data from line1 of a block
    .sdata_g2           (sdata_g2         ), // <i> 64b, g data from line2 of a block
    .sdata_g3           (sdata_g3         ), // <i> 64b, g data from line3 of a block
    .sdata_g4           (sdata_g4         ), // <i> 64b, g data from line4 of a block
    .sdata_g5           (sdata_g5         ), // <i> 64b, g data from line5 of a block
    .sdata_g6           (sdata_g6         ), // <i> 64b, g data from line6 of a block
    .sdata_g7           (sdata_g7         ), // <i> 64b, g data from line7 of a block
    .sdata_b0           (sdata_b0         ), // <i> 64b, b data from line0 of a block
    .sdata_b1           (sdata_b1         ), // <i> 64b, b data from line1 of a block
    .sdata_b2           (sdata_b2         ), // <i> 64b, b data from line2 of a block
    .sdata_b3           (sdata_b3         ), // <i> 64b, b data from line3 of a block
    .sdata_b4           (sdata_b4         ), // <i> 64b, b data from line4 of a block
    .sdata_b5           (sdata_b5         ), // <i> 64b, b data from line5 of a block
    .sdata_b6           (sdata_b6         ), // <i> 64b, b data from line6 of a block
    .sdata_b7           (sdata_b7         ), // <i> 64b, b data from line7 of a block
    // pixel data output
    .pixel_out_data     (pixel_out_data   ), // <o>  8b, pixel data input
    .pixel_out_done     (pixel_out_done   ), // <o>  1b, pixel data output done
    .pixel_out_valid    (pixel_out_valid  ), // <o>  1b, pixel data input valid
    .pixel_out_rdy      (pixel_out_rdy    )  // <i>  1b, pixel data output ready
    );

  png_packing32 png_packing_u0(
    // global
    .clk                (clk                ), // <i>  1b, global clock
    .rstn               (rstn               ), // <i>  1b, global reset, active low
    // interface with registers
    .frame_start        (frame_start        ), // <i>  1b, frame start indicator
    .frame_end          (frame_end          ), // <o>  1b, frame end indicator
    .pic_width          (pic_width          ), // <i> 11b, picture width
    .pic_height         (pic_height         ), // <i> 11b, picture height
    .png_file_len       (png_file_len       ), // <o> 23b, png file length indicator
    // pic data input
    .pic_din_valid      (pixel_out_valid    ), // <i>  1b, input data valid
    .pic_din_rdy        (pixel_out_rdy      ), // <o>  1b, ready to accept input data
    .pic_din_done       (pixel_out_done     ), // <i>  1b, input data done of a frame
    .pic_data           (pixel_out_data     ), // <i>  8b, input data
    // stream output
    .png_out_valid      (cdata_vld          ), // <o>  1b, png stream output valid
    .png_out_data       (cdata              )  // <o> 32b, png stream output
    );

endmodule
