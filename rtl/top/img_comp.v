module img_comp(
    // global signals
    clk                   , // <i>  1b, system clock
    rstn                  , // <i>  1b, global reset, active low
    // interface with control registers
    jpeg_en               , // <i>  1b, jpeg encoder enable
    png_en                , // <i>  1b, png encoder enable
    frame_start           , // <i>  1b, frame start indicator
    frame_end             , // <o>  1b, frame end indicator
    pic_width             , // <i> 11b, picture width
    pic_height            , // <i> 11b, picture height
    file_len              , // <o> 23b, jpeg file length indicator
    // signals with quantization table
    lum_qtable_rd_ext     , // <o>  1b, lum quantization table read enable to external
    chr_qtable_rd_ext     , // <o>  1b, chr quantization table read enable to external
    lum_qtable_addr_ext   , // <o>  6b, lum quantization table read address to external
    chr_qtable_addr_ext   , // <o>  6b, chr quantization table read address to external
    lum_qtable_data_ext   , // <i>  8b, quantization table value from external
    chr_qtable_data_ext   , // <i>  8b, quantization table value from external
    // data from 8 line fifo
    sdata_rvld            , // <i>  8b, input 8 line r data valid
    sdata_gvld            , // <i>  8b, input 8 line g data valid
    sdata_bvld            , // <i>  8b, input 8 line b data valid
    sdata_rrdy            , // <o>  8b, input r data accept
    sdata_grdy            , // <o>  8b, input g data accept
    sdata_brdy            , // <o>  8b, input b data accept
    sdata_r0              , // <i> 64b, r data from line0 of a block
    sdata_r1              , // <i> 64b, r data from line1 of a block
    sdata_r2              , // <i> 64b, r data from line2 of a block
    sdata_r3              , // <i> 64b, r data from line3 of a block
    sdata_r4              , // <i> 64b, r data from line4 of a block
    sdata_r5              , // <i> 64b, r data from line5 of a block
    sdata_r6              , // <i> 64b, r data from line6 of a block
    sdata_r7              , // <i> 64b, r data from line7 of a block
    sdata_g0              , // <i> 64b, g data from line0 of a block
    sdata_g1              , // <i> 64b, g data from line1 of a block
    sdata_g2              , // <i> 64b, g data from line2 of a block
    sdata_g3              , // <i> 64b, g data from line3 of a block
    sdata_g4              , // <i> 64b, g data from line4 of a block
    sdata_g5              , // <i> 64b, g data from line5 of a block
    sdata_g6              , // <i> 64b, g data from line6 of a block
    sdata_g7              , // <i> 64b, g data from line7 of a block
    sdata_b0              , // <i> 64b, b data from line0 of a block
    sdata_b1              , // <i> 64b, b data from line1 of a block
    sdata_b2              , // <i> 64b, b data from line2 of a block
    sdata_b3              , // <i> 64b, b data from line3 of a block
    sdata_b4              , // <i> 64b, b data from line4 of a block
    sdata_b5              , // <i> 64b, b data from line5 of a block
    sdata_b6              , // <i> 64b, b data from line6 of a block
    sdata_b7              , // <i> 64b, b data from line7 of a block
    // stream output
    cdata_vld             , // <o>  1b, jpeg stream output valid
    cdata                   // <o> 32b, jpeg stream output
    );

  // global signals
  input         clk                   ; // <i>  1b, system clock
  input         rstn                  ; // <i>  1b, global reset, active low
  // interface with control registers
  input         jpeg_en               ; // <i>  1b, jpeg encoder enable
  input         png_en                ; // <i>  1b, png encoder enable
  input         frame_start           ; // <i>  1b, frame start indicator
  output        frame_end             ; // <o>  1b, frame end indicator
  input  [10:0] pic_width             ; // <i> 11b, picture width
  input  [10:0] pic_height            ; // <i> 11b, picture height
  input  [22:0] file_len              ; // <o> 23b, jpeg file length indicator
  // signals with quantization table
  output        lum_qtable_rd_ext     ; // <o>  1b, lum quantization table read enable to external
  output        chr_qtable_rd_ext     ; // <o>  1b, chr quantization table read enable to external
  output [5:0]  lum_qtable_addr_ext   ; // <o>  6b, lum quantization table read address to external
  output [5:0]  chr_qtable_addr_ext   ; // <o>  6b, chr quantization table read address to external
  input  [7:0]  lum_qtable_data_ext   ; // <i>  8b, quantization table value from external
  input  [7:0]  chr_qtable_data_ext   ; // <i>  8b, quantization table value from external
  // data from 8 line fifo
  input  [7:0]  sdata_rvld            ; // <i>  8b, input 8 line r data valid
  input  [7:0]  sdata_gvld            ; // <i>  8b, input 8 line g data valid
  input  [7:0]  sdata_bvld            ; // <i>  8b, input 8 line b data valid
  output [7:0]  sdata_rrdy            ; // <o>  8b, input r data accept
  output [7:0]  sdata_grdy            ; // <o>  8b, input g data accept
  output [7:0]  sdata_brdy            ; // <o>  8b, input b data accept
  input  [63:0] sdata_r0              ; // <i> 64b, r data from line0 of a block
  input  [63:0] sdata_r1              ; // <i> 64b, r data from line1 of a block
  input  [63:0] sdata_r2              ; // <i> 64b, r data from line2 of a block
  input  [63:0] sdata_r3              ; // <i> 64b, r data from line3 of a block
  input  [63:0] sdata_r4              ; // <i> 64b, r data from line4 of a block
  input  [63:0] sdata_r5              ; // <i> 64b, r data from line5 of a block
  input  [63:0] sdata_r6              ; // <i> 64b, r data from line6 of a block
  input  [63:0] sdata_r7              ; // <i> 64b, r data from line7 of a block
  input  [63:0] sdata_g0              ; // <i> 64b, g data from line0 of a block
  input  [63:0] sdata_g1              ; // <i> 64b, g data from line1 of a block
  input  [63:0] sdata_g2              ; // <i> 64b, g data from line2 of a block
  input  [63:0] sdata_g3              ; // <i> 64b, g data from line3 of a block
  input  [63:0] sdata_g4              ; // <i> 64b, g data from line4 of a block
  input  [63:0] sdata_g5              ; // <i> 64b, g data from line5 of a block
  input  [63:0] sdata_g6              ; // <i> 64b, g data from line6 of a block
  input  [63:0] sdata_g7              ; // <i> 64b, g data from line7 of a block
  input  [63:0] sdata_b0              ; // <i> 64b, b data from line0 of a block
  input  [63:0] sdata_b1              ; // <i> 64b, b data from line1 of a block
  input  [63:0] sdata_b2              ; // <i> 64b, b data from line2 of a block
  input  [63:0] sdata_b3              ; // <i> 64b, b data from line3 of a block
  input  [63:0] sdata_b4              ; // <i> 64b, b data from line4 of a block
  input  [63:0] sdata_b5              ; // <i> 64b, b data from line5 of a block
  input  [63:0] sdata_b6              ; // <i> 64b, b data from line6 of a block
  input  [63:0] sdata_b7              ; // <i> 64b, b data from line7 of a block
  // stream output
  output        cdata_vld             ; // <o>  1b, jpeg stream output valid
  output [31:0] cdata                 ; // <o> 32b, jpeg stream output

  wire          png_frame_end         ; // png frame end indicator
  wire   [22:0] png_file_len          ; // png file length
  wire   [7:0]  png_sdata_rvld        ; // png input 8 line r data valid
  wire   [7:0]  png_sdata_gvld        ; // png input 8 line g data valid
  wire   [7:0]  png_sdata_bvld        ; // png input 8 line b data valid
  wire   [7:0]  png_sdata_rrdy        ; // png input r data accept
  wire   [7:0]  png_sdata_grdy        ; // png input g data accept
  wire   [7:0]  png_sdata_brdy        ; // png input b data accept
  wire   [63:0] png_sdata_r0          ; // png r data from line0 of a block
  wire   [63:0] png_sdata_r1          ; // png r data from line1 of a block
  wire   [63:0] png_sdata_r2          ; // png r data from line2 of a block
  wire   [63:0] png_sdata_r3          ; // png r data from line3 of a block
  wire   [63:0] png_sdata_r4          ; // png r data from line4 of a block
  wire   [63:0] png_sdata_r5          ; // png r data from line5 of a block
  wire   [63:0] png_sdata_r6          ; // png r data from line6 of a block
  wire   [63:0] png_sdata_r7          ; // png r data from line7 of a block
  wire   [63:0] png_sdata_g0          ; // png g data from line0 of a block
  wire   [63:0] png_sdata_g1          ; // png g data from line1 of a block
  wire   [63:0] png_sdata_g2          ; // png g data from line2 of a block
  wire   [63:0] png_sdata_g3          ; // png g data from line3 of a block
  wire   [63:0] png_sdata_g4          ; // png g data from line4 of a block
  wire   [63:0] png_sdata_g5          ; // png g data from line5 of a block
  wire   [63:0] png_sdata_g6          ; // png g data from line6 of a block
  wire   [63:0] png_sdata_g7          ; // png g data from line7 of a block
  wire   [63:0] png_sdata_b0          ; // png b data from line0 of a block
  wire   [63:0] png_sdata_b1          ; // png b data from line1 of a block
  wire   [63:0] png_sdata_b2          ; // png b data from line2 of a block
  wire   [63:0] png_sdata_b3          ; // png b data from line3 of a block
  wire   [63:0] png_sdata_b4          ; // png b data from line4 of a block
  wire   [63:0] png_sdata_b5          ; // png b data from line5 of a block
  wire   [63:0] png_sdata_b6          ; // png b data from line6 of a block
  wire   [63:0] png_sdata_b7          ; // png b data from line7 of a block
  wire          png_cdata_vld         ; // png stream output valid
  wire   [31:0] png_cdata             ; // png stream output

  wire          jpeg_frame_end        ; // jpeg frame end indicator
  wire   [19:0] jpeg_file_len         ; // jpeg file length
  wire   [7:0]  jpeg_sdata_rvld       ; // jpeg input 8 line r data valid
  wire   [7:0]  jpeg_sdata_gvld       ; // jpeg input 8 line g data valid
  wire   [7:0]  jpeg_sdata_bvld       ; // jpeg input 8 line b data valid
  wire   [7:0]  jpeg_sdata_rrdy       ; // jpeg input r data accept
  wire   [7:0]  jpeg_sdata_grdy       ; // jpeg input g data accept
  wire   [7:0]  jpeg_sdata_brdy       ; // jpeg input b data accept
  wire   [63:0] jpeg_sdata_r0         ; // jpeg r data from line0 of a block
  wire   [63:0] jpeg_sdata_r1         ; // jpeg r data from line1 of a block
  wire   [63:0] jpeg_sdata_r2         ; // jpeg r data from line2 of a block
  wire   [63:0] jpeg_sdata_r3         ; // jpeg r data from line3 of a block
  wire   [63:0] jpeg_sdata_r4         ; // jpeg r data from line4 of a block
  wire   [63:0] jpeg_sdata_r5         ; // jpeg r data from line5 of a block
  wire   [63:0] jpeg_sdata_r6         ; // jpeg r data from line6 of a block
  wire   [63:0] jpeg_sdata_r7         ; // jpeg r data from line7 of a block
  wire   [63:0] jpeg_sdata_g0         ; // jpeg g data from line0 of a block
  wire   [63:0] jpeg_sdata_g1         ; // jpeg g data from line1 of a block
  wire   [63:0] jpeg_sdata_g2         ; // jpeg g data from line2 of a block
  wire   [63:0] jpeg_sdata_g3         ; // jpeg g data from line3 of a block
  wire   [63:0] jpeg_sdata_g4         ; // jpeg g data from line4 of a block
  wire   [63:0] jpeg_sdata_g5         ; // jpeg g data from line5 of a block
  wire   [63:0] jpeg_sdata_g6         ; // jpeg g data from line6 of a block
  wire   [63:0] jpeg_sdata_g7         ; // jpeg g data from line7 of a block
  wire   [63:0] jpeg_sdata_b0         ; // jpeg b data from line0 of a block
  wire   [63:0] jpeg_sdata_b1         ; // jpeg b data from line1 of a block
  wire   [63:0] jpeg_sdata_b2         ; // jpeg b data from line2 of a block
  wire   [63:0] jpeg_sdata_b3         ; // jpeg b data from line3 of a block
  wire   [63:0] jpeg_sdata_b4         ; // jpeg b data from line4 of a block
  wire   [63:0] jpeg_sdata_b5         ; // jpeg b data from line5 of a block
  wire   [63:0] jpeg_sdata_b6         ; // jpeg b data from line6 of a block
  wire   [63:0] jpeg_sdata_b7         ; // jpeg b data from line7 of a block
  wire          jpeg_cdata_vld        ; // jpeg stream output valid
  wire   [31:0] jpeg_cdata            ; // jpeg stream output

  assign png_sdata_rvld = {8{png_en}} & sdata_rvld; 
  assign png_sdata_gvld = {8{png_en}} & sdata_gvld; 
  assign png_sdata_bvld = {8{png_en}} & sdata_bvld; 
  assign png_sdata_r0   = {64{png_en}} & sdata_r0;
  assign png_sdata_r1   = {64{png_en}} & sdata_r1;
  assign png_sdata_r2   = {64{png_en}} & sdata_r2;
  assign png_sdata_r3   = {64{png_en}} & sdata_r3;
  assign png_sdata_r4   = {64{png_en}} & sdata_r4;
  assign png_sdata_r5   = {64{png_en}} & sdata_r5;
  assign png_sdata_r6   = {64{png_en}} & sdata_r6;
  assign png_sdata_r7   = {64{png_en}} & sdata_r7;
  assign png_sdata_g0   = {64{png_en}} & sdata_g0;
  assign png_sdata_g1   = {64{png_en}} & sdata_g1;
  assign png_sdata_g2   = {64{png_en}} & sdata_g2;
  assign png_sdata_g3   = {64{png_en}} & sdata_g3;
  assign png_sdata_g4   = {64{png_en}} & sdata_g4;
  assign png_sdata_g5   = {64{png_en}} & sdata_g5;
  assign png_sdata_g6   = {64{png_en}} & sdata_g6;
  assign png_sdata_g7   = {64{png_en}} & sdata_g7;
  assign png_sdata_b0   = {64{png_en}} & sdata_b0;
  assign png_sdata_b1   = {64{png_en}} & sdata_b1;
  assign png_sdata_b2   = {64{png_en}} & sdata_b2;
  assign png_sdata_b3   = {64{png_en}} & sdata_b3;
  assign png_sdata_b4   = {64{png_en}} & sdata_b4;
  assign png_sdata_b5   = {64{png_en}} & sdata_b5;
  assign png_sdata_b6   = {64{png_en}} & sdata_b6;
  assign png_sdata_b7   = {64{png_en}} & sdata_b7;

  assign jpeg_sdata_rvld = {8{jpeg_en}} & sdata_rvld; 
  assign jpeg_sdata_gvld = {8{jpeg_en}} & sdata_gvld; 
  assign jpeg_sdata_bvld = {8{jpeg_en}} & sdata_bvld; 
  assign jpeg_sdata_r0   = {64{jpeg_en}} & sdata_r0;
  assign jpeg_sdata_r1   = {64{jpeg_en}} & sdata_r1;
  assign jpeg_sdata_r2   = {64{jpeg_en}} & sdata_r2;
  assign jpeg_sdata_r3   = {64{jpeg_en}} & sdata_r3;
  assign jpeg_sdata_r4   = {64{jpeg_en}} & sdata_r4;
  assign jpeg_sdata_r5   = {64{jpeg_en}} & sdata_r5;
  assign jpeg_sdata_r6   = {64{jpeg_en}} & sdata_r6;
  assign jpeg_sdata_r7   = {64{jpeg_en}} & sdata_r7;
  assign jpeg_sdata_g0   = {64{jpeg_en}} & sdata_g0;
  assign jpeg_sdata_g1   = {64{jpeg_en}} & sdata_g1;
  assign jpeg_sdata_g2   = {64{jpeg_en}} & sdata_g2;
  assign jpeg_sdata_g3   = {64{jpeg_en}} & sdata_g3;
  assign jpeg_sdata_g4   = {64{jpeg_en}} & sdata_g4;
  assign jpeg_sdata_g5   = {64{jpeg_en}} & sdata_g5;
  assign jpeg_sdata_g6   = {64{jpeg_en}} & sdata_g6;
  assign jpeg_sdata_g7   = {64{jpeg_en}} & sdata_g7;
  assign jpeg_sdata_b0   = {64{jpeg_en}} & sdata_b0;
  assign jpeg_sdata_b1   = {64{jpeg_en}} & sdata_b1;
  assign jpeg_sdata_b2   = {64{jpeg_en}} & sdata_b2;
  assign jpeg_sdata_b3   = {64{jpeg_en}} & sdata_b3;
  assign jpeg_sdata_b4   = {64{jpeg_en}} & sdata_b4;
  assign jpeg_sdata_b5   = {64{jpeg_en}} & sdata_b5;
  assign jpeg_sdata_b6   = {64{jpeg_en}} & sdata_b6;
  assign jpeg_sdata_b7   = {64{jpeg_en}} & sdata_b7;

  assign sdata_rrdy = ({8{png_en}} & png_sdata_rrdy) | ({8{jpeg_en}} & jpeg_sdata_rrdy);
  assign sdata_grdy = ({8{png_en}} & png_sdata_grdy) | ({8{jpeg_en}} & jpeg_sdata_grdy);
  assign sdata_brdy = ({8{png_en}} & png_sdata_brdy) | ({8{jpeg_en}} & jpeg_sdata_brdy);

  assign cdata_vld = (    png_en   & png_cdata_vld) | (    jpeg_en   & jpeg_cdata_vld);
  assign cdata     = ({32{png_en}} & png_cdata    ) | ({32{jpeg_en}} & jpeg_cdata    );

  assign file_len = ({23{png_en}} & png_file_len) | ({23{jpeg_en}} & {3'h0, jpeg_file_len});

  assign frame_end = (png_en & png_frame_end) | (jpeg_en & jpeg_frame_end);

  png_enc png_enc_u0(
    // global signals
    .clk                  (clk                ), // <i>  1b, system clock
    .rstn                 (rstn               ), // <i>  1b, global reset, active low
    // interface with control registers
    .frame_start          (frame_start        ), // <i>  1b, frame start indicator
    .frame_end            (png_frame_end      ), // <o>  1b, frame end indicator
    .pic_width            (pic_width          ), // <i> 11b, picture width
    .pic_height           (pic_height         ), // <i> 11b, picture height
    .png_file_len         (png_file_len       ), // <o> 23b, png file length indicator
    // data from 8 line fifo
    .sdata_rvld           (png_sdata_rvld     ), // <i>  8b, input 8 line r data valid
    .sdata_gvld           (png_sdata_gvld     ), // <i>  8b, input 8 line g data valid
    .sdata_bvld           (png_sdata_bvld     ), // <i>  8b, input 8 line b data valid
    .sdata_rrdy           (png_sdata_rrdy     ), // <o>  8b, input r data accept
    .sdata_grdy           (png_sdata_grdy     ), // <o>  8b, input g data accept
    .sdata_brdy           (png_sdata_brdy     ), // <o>  8b, input b data accept
    .sdata_r0             (png_sdata_r0       ), // <i> 64b, r data from line0 of a block
    .sdata_r1             (png_sdata_r1       ), // <i> 64b, r data from line1 of a block
    .sdata_r2             (png_sdata_r2       ), // <i> 64b, r data from line2 of a block
    .sdata_r3             (png_sdata_r3       ), // <i> 64b, r data from line3 of a block
    .sdata_r4             (png_sdata_r4       ), // <i> 64b, r data from line4 of a block
    .sdata_r5             (png_sdata_r5       ), // <i> 64b, r data from line5 of a block
    .sdata_r6             (png_sdata_r6       ), // <i> 64b, r data from line6 of a block
    .sdata_r7             (png_sdata_r7       ), // <i> 64b, r data from line7 of a block
    .sdata_g0             (png_sdata_g0       ), // <i> 64b, g data from line0 of a block
    .sdata_g1             (png_sdata_g1       ), // <i> 64b, g data from line1 of a block
    .sdata_g2             (png_sdata_g2       ), // <i> 64b, g data from line2 of a block
    .sdata_g3             (png_sdata_g3       ), // <i> 64b, g data from line3 of a block
    .sdata_g4             (png_sdata_g4       ), // <i> 64b, g data from line4 of a block
    .sdata_g5             (png_sdata_g5       ), // <i> 64b, g data from line5 of a block
    .sdata_g6             (png_sdata_g6       ), // <i> 64b, g data from line6 of a block
    .sdata_g7             (png_sdata_g7       ), // <i> 64b, g data from line7 of a block
    .sdata_b0             (png_sdata_b0       ), // <i> 64b, b data from line0 of a block
    .sdata_b1             (png_sdata_b1       ), // <i> 64b, b data from line1 of a block
    .sdata_b2             (png_sdata_b2       ), // <i> 64b, b data from line2 of a block
    .sdata_b3             (png_sdata_b3       ), // <i> 64b, b data from line3 of a block
    .sdata_b4             (png_sdata_b4       ), // <i> 64b, b data from line4 of a block
    .sdata_b5             (png_sdata_b5       ), // <i> 64b, b data from line5 of a block
    .sdata_b6             (png_sdata_b6       ), // <i> 64b, b data from line6 of a block
    .sdata_b7             (png_sdata_b7       ), // <i> 64b, b data from line7 of a block
    // stream output
    .cdata_vld            (png_cdata_vld      ), // <o>  1b, png stream output valid
    .cdata                (png_cdata          )  // <o> 32b, png stream output
    );

  jpeg_enc jpeg_enc_u0(
    // global signals
    .clk                  (clk                ), // <i>  1b, system clock
    .rstn                 (rstn               ), // <i>  1b, global reset, active low
    // interface with control registers
    .frame_start          (frame_start        ), // <i>  1b, frame start indicator
    .frame_end            (jpeg_frame_end     ), // <o>  1b, frame end indicator
    .pic_width            (pic_width          ), // <i> 11b, picture width
    .pic_height           (pic_height         ), // <i> 11b, picture height
    .jpeg_file_len        (jpeg_file_len      ), // <o> 20b, jpeg file length indicator
    // signals with quantization table
    .lum_qtable_rd_ext    (lum_qtable_rd_ext  ), // <o>  1b, lum quantization table read enable to external
    .chr_qtable_rd_ext    (chr_qtable_rd_ext  ), // <o>  1b, chr quantization table read enable to external
    .lum_qtable_addr_ext  (lum_qtable_addr_ext), // <o>  6b, lum quantization table read address to external
    .chr_qtable_addr_ext  (chr_qtable_addr_ext), // <o>  6b, chr quantization table read address to external
    .lum_qtable_data_ext  (lum_qtable_data_ext), // <i>  8b, quantization table value from external
    .chr_qtable_data_ext  (chr_qtable_data_ext), // <i>  8b, quantization table value from external
    // data from 8 line fifo
    .sdata_rvld           (jpeg_sdata_rvld    ), // <i>  8b, input 8 line r data valid
    .sdata_gvld           (jpeg_sdata_gvld    ), // <i>  8b, input 8 line g data valid
    .sdata_bvld           (jpeg_sdata_bvld    ), // <i>  8b, input 8 line b data valid
    .sdata_rrdy           (jpeg_sdata_rrdy    ), // <o>  8b, input r data accept
    .sdata_grdy           (jpeg_sdata_grdy    ), // <o>  8b, input g data accept
    .sdata_brdy           (jpeg_sdata_brdy    ), // <o>  8b, input b data accept
    .sdata_r0             (jpeg_sdata_r0      ), // <i> 64b, r data from line0 of a block
    .sdata_r1             (jpeg_sdata_r1      ), // <i> 64b, r data from line1 of a block
    .sdata_r2             (jpeg_sdata_r2      ), // <i> 64b, r data from line2 of a block
    .sdata_r3             (jpeg_sdata_r3      ), // <i> 64b, r data from line3 of a block
    .sdata_r4             (jpeg_sdata_r4      ), // <i> 64b, r data from line4 of a block
    .sdata_r5             (jpeg_sdata_r5      ), // <i> 64b, r data from line5 of a block
    .sdata_r6             (jpeg_sdata_r6      ), // <i> 64b, r data from line6 of a block
    .sdata_r7             (jpeg_sdata_r7      ), // <i> 64b, r data from line7 of a block
    .sdata_g0             (jpeg_sdata_g0      ), // <i> 64b, g data from line0 of a block
    .sdata_g1             (jpeg_sdata_g1      ), // <i> 64b, g data from line1 of a block
    .sdata_g2             (jpeg_sdata_g2      ), // <i> 64b, g data from line2 of a block
    .sdata_g3             (jpeg_sdata_g3      ), // <i> 64b, g data from line3 of a block
    .sdata_g4             (jpeg_sdata_g4      ), // <i> 64b, g data from line4 of a block
    .sdata_g5             (jpeg_sdata_g5      ), // <i> 64b, g data from line5 of a block
    .sdata_g6             (jpeg_sdata_g6      ), // <i> 64b, g data from line6 of a block
    .sdata_g7             (jpeg_sdata_g7      ), // <i> 64b, g data from line7 of a block
    .sdata_b0             (jpeg_sdata_b0      ), // <i> 64b, b data from line0 of a block
    .sdata_b1             (jpeg_sdata_b1      ), // <i> 64b, b data from line1 of a block
    .sdata_b2             (jpeg_sdata_b2      ), // <i> 64b, b data from line2 of a block
    .sdata_b3             (jpeg_sdata_b3      ), // <i> 64b, b data from line3 of a block
    .sdata_b4             (jpeg_sdata_b4      ), // <i> 64b, b data from line4 of a block
    .sdata_b5             (jpeg_sdata_b5      ), // <i> 64b, b data from line5 of a block
    .sdata_b6             (jpeg_sdata_b6      ), // <i> 64b, b data from line6 of a block
    .sdata_b7             (jpeg_sdata_b7      ), // <i> 64b, b data from line7 of a block
    // stream output
    .cdata_vld            (jpeg_cdata_vld     ), // <o>  1b, jpeg stream output valid
    .cdata                (jpeg_cdata         )  // <o> 32b, jpeg stream output
    );

endmodule
