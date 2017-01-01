`define DLY (#1)
//`default_nettype none

module jpeg_enc(
    // global signals
    clk                 , // <i>  1b, system clock
    rstn                , // <i>  1b, global reset, active low
    // interface with control registers
    frame_start         , // <i>  1b, frame start indicator
    frame_end           , // <o>  1b, frame end indicator
    pic_width           , // <i> 11b, picture width
    pic_height          , // <i> 11b, picture height
    jpeg_file_len       , // <o> 20b, jpeg file length indicator
    // signals with quantization table
    lum_qtable_rd_ext   , // <o>  1b, lum quantization table read enable to external
    chr_qtable_rd_ext   , // <o>  1b, chr quantization table read enable to external
    lum_qtable_addr_ext , // <o>  6b, lum quantization table read address to external
    chr_qtable_addr_ext , // <o>  6b, chr quantization table read address to external
    lum_qtable_data_ext , // <i>  8b, quantization table value from external
    chr_qtable_data_ext , // <i>  8b, quantization table value from external
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
    cdata_vld           , // <o>  1b, jpeg stream output valid
    cdata                 // <o> 32b, jpeg stream output
    );

  // global signals
  input         clk                 ; // <i>  1b, system clock
  input         rstn                ; // <i>  1b, global reset, active low
  // interface with control registers
  input         frame_start         ; // <i>  1b, frame start indicator
  output        frame_end           ; // <o>  1b, frame end indicator
  input  [10:0] pic_width           ; // <i> 11b, picture width
  input  [10:0] pic_height          ; // <i> 11b, picture height
  output [19:0] jpeg_file_len       ; // <o> 20b, jpeg file length indicator
  // signals with quantization table
  output        lum_qtable_rd_ext   ; // <o>  1b, lum quantization table read enable to external
  output        chr_qtable_rd_ext   ; // <o>  1b, chr quantization table read enable to external
  output [5:0]  lum_qtable_addr_ext ; // <o>  6b, lum quantization table read address to external
  output [5:0]  chr_qtable_addr_ext ; // <o>  6b, chr quantization table read address to external
  input  [7:0]  lum_qtable_data_ext ; // <i>  8b, quantization table value from external
  input  [7:0]  chr_qtable_data_ext ; // <i>  8b, quantization table value from external
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
  output        cdata_vld           ; // <o>  1b, jpeg stream output valid
  output [31:0] cdata               ; // <o> 32b, jpeg stream output

  wire  [23:0]  pixel_data_out          ;
  wire          pixel_out_valid         ;

  wire  [23:0]  yuv_data_out            ;
  wire          yuv_out_valid           ;

  wire  [41:0]  dct_data_out            ;
  wire          dct_out_valid           ;

  wire  [41:0]  zigzag_data             ;
  wire          zigzag_out_valid        ;

  wire          q_data_valid            ;
  wire  [10:0]  y_q_data                ;
  wire  [10:0]  u_q_data                ;
  wire  [10:0]  v_q_data                ;

  wire          y_dc_coeff_out_valid    ;
  wire  [11:0]  y_dc_coeff              ;
  wire          y_ac_coeff_out_valid    ;
  wire  [11:0]  y_ac_coeff              ;
  wire  [3:0]   y_run_length            ;
  wire          y_eob_out               ;

  wire          u_dc_coeff_out_valid    ;
  wire  [11:0]  u_dc_coeff              ;
  wire          u_ac_coeff_out_valid    ;
  wire  [11:0]  u_ac_coeff              ;
  wire  [3:0]   u_run_length            ;
  wire          u_eob_out               ;

  wire          v_dc_coeff_out_valid    ;
  wire  [11:0]  v_dc_coeff              ;
  wire          v_ac_coeff_out_valid    ;
  wire  [11:0]  v_ac_coeff              ;
  wire  [3:0]   v_run_length            ;
  wire          v_eob_out               ;

  wire          y_code_out_valid        ;
  wire  [26:0]  y_ecs_code              ;
  wire  [4:0]   y_ecs_code_length       ;
  wire          y_ecs_eob               ;

  wire          u_code_out_valid        ;
  wire  [26:0]  u_ecs_code              ;
  wire  [4:0]   u_ecs_code_length       ;
  wire          u_ecs_eob               ;

  wire          v_code_out_valid        ;
  wire  [26:0]  v_ecs_code              ;
  wire  [4:0]   v_ecs_code_length       ;
  wire          v_ecs_eob               ;

  wire          code_out_valid          ;
  wire  [31:0]  ecs_code                ;
  wire  [5:0]   ecs_code_length         ;
  wire          ecs_eob                 ;

  wire          qnt_qtable_rd           ;
  wire          pack_lum_qtable_rd      ;
  wire          pack_chr_qtable_rd      ;
  wire  [7:0]   lum_qtable_data         ;
  wire  [7:0]   chr_qtable_data         ;

  wire  [10:0]  pic_width               ;
  wire  [10:0]  pic_height              ;

  jpeg_get_pixels get_pixels_u0(
    // global signals
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
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
    .pixel_data_out     (pixel_data_out   ), // <o> 24b, pixel data input
    .pixel_out_valid    (pixel_out_valid  )  // <o>  1b, pixel data input valid
    );

  rgb2yuv rgb2yuv_u0(
    // global signals
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // pixel data input
    .pixel_data_in      (pixel_data_out   ), // <i> 24b, pixel data input
    .pixel_in_valid     (pixel_out_valid  ), // <i>  1b, pixel data input valid
    // pixel data output
    .pixel_data_out     (yuv_data_out     ), // <o> 24b, dct data output
    .pixel_out_valid    (yuv_out_valid    )  // <o>  1b, dct data output valid
    );

  dct dct_u0(
    // global signals
    .clk              (clk            ), // <i>  1b, global clock
    .rstn             (rstn           ), // <i>  1b, global reset, active low
    // frame control
    .frame_start      (frame_start    ), // <i>  1b, frame end indicator
    .frame_end        (frame_end      ), // <i>  1b, frame end indicator
    // pixel data input
    .pixel_data_in    (yuv_data_out   ), // <i> 24b, pixel data input
    .pixel_in_valid   (yuv_out_valid  ), // <i>  1b, pixel data input valid
//  .pixel_data_in    (pixel_data_out ), // <i> 24b, pixel data input
//  .pixel_in_valid   (pixel_out_valid), // <i>  1b, pixel data input valid
    // output 8 points data
    .dct_data_out     (dct_data_out   ), // <o> 42b, dct data output
    .dct_out_valid    (dct_out_valid  )  // <o>  1b, dct data output valid
    );

  zigzag zigzag_u0(
    // global
    .clk                  (clk              ), // <i>  1b, global clock
    .rstn                 (rstn             ), // <i>  1b, global reset, active low
    // input dct_data
    .dct_data             (dct_data_out     ), // <i> 42b, dct data output
    .dct_data_valid       (dct_out_valid    ), // <i>  1b, dct data output valid
    // zigzag out
    .zigzag_data          (zigzag_data      ), // <o> 42b, zigzag data output
    .zigzag_data_valid    (zigzag_out_valid )  // <o>  1b, zigzag data output valid
    );

  quantization qnt_u0(
    // global
    .clk                  (clk              ), // <i>  1b, global clock
    .rstn                 (rstn             ), // <i>  1b, global reset, active low
    // input zigzag_data
    .zigzag_data          (zigzag_data      ), // <i> 42b, zigzag data output
    .zigzag_data_valid    (zigzag_out_valid ), // <i>  1b, zigzag data output valid
    // quantization table
    .lum_qtable_rd        (qnt_lum_qtable_rd), // <o>  1b, lum quantization table read enable
    .chr_qtable_rd        (qnt_chr_qtable_rd), // <o>  1b, chr quantization table read enable
    .lum_qtable_data      (lum_qtable_data  ), // <i>  8b, lum quantization table value
    .chr_qtable_data      (chr_qtable_data  ), // <i>  8b, chr quantization table value
    // output quantized data
    .q_data_valid         (q_data_valid     ), // <o>  1b, zigzag data output valid
    .y_q_data             (y_q_data         ), // <o> 11b, zigzag data output
    .u_q_data             (u_q_data         ), // <o> 11b, zigzag data output
    .v_q_data             (v_q_data         )  // <o> 11b, zigzag data output
    );

  zrl y_zrl_u0(
    // global
    .clk                  (clk                  ), // <i>  1b, global clock
    .rstn                 (rstn                 ), // <i>  1b, global reset, active low
    // frame control
    .frame_start          (frame_start          ), // <i>  1b, frame end indicator
    .frame_end            (frame_end            ), // <i>  1b, frame end indicator
    // input quantized data
    .q_data               (y_q_data             ), // <i> 11b, zigzag data output
    .q_data_valid         (q_data_valid         ), // <i>  1b, zigzag data output valid
    // DC output
    .dc_coeff_out_valid   (y_dc_coeff_out_valid ), // <o>  1b, dc coeff output valid
    .dc_coeff             (y_dc_coeff           ), // <o> 12b, dc_coeff output
    // AC output
    .ac_coeff_out_valid   (y_ac_coeff_out_valid ), // <o>  1b, ac coeff output valid
    .ac_coeff             (y_ac_coeff           ), // <o> 12b, ac coeff output
    .run_length           (y_run_length         ), // <o>  4b, run length
    .eob_out              (y_eob_out            )  // <o>  1b, end of block indicator
    );

  zrl u_zrl_u1(
    // global
    .clk                  (clk                  ), // <i>  1b, global clock
    .rstn                 (rstn                 ), // <i>  1b, global reset, active low
    // frame control
    .frame_start          (frame_start          ), // <i>  1b, frame end indicator
    .frame_end            (frame_end            ), // <i>  1b, frame end indicator
    // input quantized data
    .q_data               (u_q_data             ), // <i> 11b, zigzag data output
    .q_data_valid         (q_data_valid         ), // <i>  1b, zigzag data output valid
    // DC output
    .dc_coeff_out_valid   (u_dc_coeff_out_valid ), // <o>  1b, dc coeff output valid
    .dc_coeff             (u_dc_coeff           ), // <o> 12b, dc_coeff output
    // AC output
    .ac_coeff_out_valid   (u_ac_coeff_out_valid ), // <o>  1b, ac coeff output valid
    .ac_coeff             (u_ac_coeff           ), // <o> 12b, ac coeff output
    .run_length           (u_run_length         ), // <o>  4b, run length
    .eob_out              (u_eob_out            )  // <o>  1b, end of block indicator
    );

  zrl v_zrl_u2(
    // global
    .clk                  (clk                  ), // <i>  1b, global clock
    .rstn                 (rstn                 ), // <i>  1b, global reset, active low
    // frame control
    .frame_start          (frame_start          ), // <i>  1b, frame end indicator
    .frame_end            (frame_end            ), // <i>  1b, frame end indicator
    // input quantized data
    .q_data               (v_q_data             ), // <i> 11b, zigzag data output
    .q_data_valid         (q_data_valid         ), // <i>  1b, zigzag data output valid
    // DC output                                
    .dc_coeff_out_valid   (v_dc_coeff_out_valid ), // <o>  1b, dc coeff output valid
    .dc_coeff             (v_dc_coeff           ), // <o> 12b, dc_coeff output
    // AC output                                
    .ac_coeff_out_valid   (v_ac_coeff_out_valid ), // <o>  1b, ac coeff output valid
    .ac_coeff             (v_ac_coeff           ), // <o> 12b, ac coeff output
    .run_length           (v_run_length         ), // <o>  4b, run length
    .eob_out              (v_eob_out            )  // <o>  1b, end of block indicator
    );

  huffman_enc_lum huffman_enc_lum_u0(
    // global
    .clk                (clk                  ), // <i>  1b, global clock
    .rstn               (rstn                 ), // <i>  1b, global reset, active low
    // DC input
    .dc_coeff_in_valid  (y_dc_coeff_out_valid ), // <i>  1b, dc coeff input valid
    .dc_coeff           (y_dc_coeff           ), // <i> 12b, dc_coeff input
    // AC input
    .ac_coeff_in_valid  (y_ac_coeff_out_valid ), // <i>  1b, ac coeff input valid
    .ac_coeff           (y_ac_coeff           ), // <i> 12b, ac coeff input
    .run_length         (y_run_length         ), // <i>  4b, run length
    .eob_flag           (y_eob_out            ), // <i>  1b, eob flag input
    // output huffman code and length
    .code_out_valid     (y_code_out_valid     ), // <o>  1b, huffman code output valid
    .code               (y_ecs_code           ), // <o> 27b, huffman code
    .length             (y_ecs_code_length    ), // <o>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    .eob_out            (y_ecs_eob            )  // <o>  1b, eob flag output
    );

  huffman_enc_chr huffman_enc_chr_u0(
    // global
    .clk                (clk                  ), // <i>  1b, global clock
    .rstn               (rstn                 ), // <i>  1b, global reset, active low
    // DC input
    .dc_coeff_in_valid  (u_dc_coeff_out_valid ), // <i>  1b, dc coeff input valid
    .dc_coeff           (u_dc_coeff           ), // <i> 12b, dc_coeff input
    // AC input
    .ac_coeff_in_valid  (u_ac_coeff_out_valid ), // <i>  1b, ac coeff input valid
    .ac_coeff           (u_ac_coeff           ), // <i> 12b, ac coeff input
    .run_length         (u_run_length         ), // <i>  4b, run length
    .eob_flag           (u_eob_out            ), // <i>  1b, eob flag input
    // output huffman code and length
    .code_out_valid     (u_code_out_valid     ), // <o>  1b, huffman code output valid
    .code               (u_ecs_code           ), // <o> 27b, huffman code
    .length             (u_ecs_code_length    ), // <o>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    .eob_out            (u_ecs_eob            )  // <o>  1b, eob flag output
    );

  huffman_enc_chr huffman_enc_chr_u1(
    // global
    .clk                (clk                  ), // <i>  1b, global clock
    .rstn               (rstn                 ), // <i>  1b, global reset, active low
    // DC input
    .dc_coeff_in_valid  (v_dc_coeff_out_valid ), // <i>  1b, dc coeff input valid
    .dc_coeff           (v_dc_coeff           ), // <i> 12b, dc_coeff input
    // AC input
    .ac_coeff_in_valid  (v_ac_coeff_out_valid ), // <i>  1b, ac coeff input valid
    .ac_coeff           (v_ac_coeff           ), // <i> 12b, ac coeff input
    .run_length         (v_run_length         ), // <i>  4b, run length
    .eob_flag           (v_eob_out            ), // <i>  1b, eob flag input
    // output huffman code and length
    .code_out_valid     (v_code_out_valid     ), // <o>  1b, huffman code output valid
    .code               (v_ecs_code           ), // <o> 27b, huffman code
    .length             (v_ecs_code_length    ), // <o>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    .eob_out            (v_ecs_eob            )  // <o>  1b, eob flag output
    );

  ecs_merge32 ecs_merge_u0(
    // global
    .clk                    (clk                  ), // <i>  1b, global clock
    .rstn                   (rstn                 ), // <i>  1b, global reset, active low
    // y huffman code out
    .y_huff_code_valid      (y_code_out_valid     ), // <i>  1b, huffman code output valid
    .y_huff_code            (y_ecs_code           ), // <i> 27b, huffman code
    .y_huff_code_length     (y_ecs_code_length    ), // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    .y_ecs_eob              (y_ecs_eob            ), // <i>  1b, y eob flag
    // u huffman code out
    .u_huff_code_valid      (u_code_out_valid     ), // <i>  1b, huffman code output valid
    .u_huff_code            (u_ecs_code           ), // <i> 27b, huffman code
    .u_huff_code_length     (u_ecs_code_length    ), // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    .u_ecs_eob              (u_ecs_eob            ), // <i>  1b, u eob flag
    // v huffman code out
    .v_huff_code_valid      (v_code_out_valid     ), // <i>  1b, huffman code output valid
    .v_huff_code            (v_ecs_code           ), // <i> 27b, huffman code
    .v_huff_code_length     (v_ecs_code_length    ), // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    .v_ecs_eob              (v_ecs_eob            ), // <i>  1b, v eob flag
    // output huffman code
    .code_out_valid         (code_out_valid       ), // <o>  1b, huffman code output valid
    .code                   (ecs_code             ), // <o> 32b, huffman code
    .length                 (ecs_code_length      ), // <o>  6b, huffman code length(0 for 1, 1 for 2...15 for 16)
    .ecs_eob                (ecs_eob              )  // <o>  1b, eob flag
    );

  jpeg_packing32 jpeg_packing_u0(
    // global
    .clk                (clk                ), // <i>  1b, global clock
    .rstn               (rstn               ), // <i>  1b, global reset, active low
    // interface with registers
    .frame_start        (frame_start        ), // <i>  1b, frame start indicator
    .frame_end          (frame_end          ), // <o>  1b, frame end indicator
    .lum_q_table        (lum_qtable_data    ), // <i>  8b, lum quantization table coeff
    .chr_q_table        (chr_qtable_data    ), // <i>  8b, chr quantization table coeff
    .pic_width          (pic_width          ), // <i> 11b, picture width
    .pic_height         (pic_height         ), // <i> 11b, picture height
    .h1                 (4'h1               ), // <i>  4b, conponent 1 h
    .v1                 (4'h1               ), // <i>  4b, conponent 1 v
    .h2                 (4'h1               ), // <i>  4b, conponent 2 h
    .v2                 (4'h1               ), // <i>  4b, conponent 2 v
    .h3                 (4'h1               ), // <i>  4b, conponent 3 h
    .v3                 (4'h1               ), // <i>  4b, conponent 3 v
    .jpeg_file_len      (jpeg_file_len      ), // <o> 20b, jpeg file length indicator
    // read lum table/chr table control
    .lum_q_rd           (pack_lum_qtable_rd ), // <o>  1b, lum quantization table read enable
    .chr_q_rd           (pack_chr_qtable_rd ), // <o>  1b, chr quantization table read enable
    // entropy coded segment input
    .ecs_out_valid      (code_out_valid     ), // <i>  1b, huffman code output valid
    .ecs_code           (ecs_code           ), // <i> 32b, huffman code
    .ecs_length         (ecs_code_length    ), // <i>  6b, huffman code length(0 for 1, 1 for 2...15 for 16)
    .ecs_eob            (ecs_eob            ), // <i>  1b, eob flag
    // stream output
    .jpeg_out_valid     (cdata_vld          ), // <o>  1b, jpeg stream output valid
    .jpeg_out_data      (cdata              )  // <o> 32b, jpeg stream output
    );

  qtable_mng qtable_mng_u0(
    // global
    .clk                  (clk                ), // <i>  1b, global clock
    .rstn                 (rstn               ), // <i>  1b, global reset, active low
    // qtable interface with jpeg_packing and quantization
    .pack_lum_qtable_rd   (pack_lum_qtable_rd ), // <i>  1b, lum quantization table read enable from jpeg_packing
    .pack_chr_qtable_rd   (pack_chr_qtable_rd ), // <i>  1b, chr quantization table read enable from jpeg_packing
    .qnt_lum_qtable_rd    (qnt_lum_qtable_rd  ), // <i>  1b, lum quantization table read enable from quantization
    .qnt_chr_qtable_rd    (qnt_chr_qtable_rd  ), // <i>  1b, chr quantization table read enable from quantization
    .lum_qtable_data      (lum_qtable_data    ), // <o>  8b, quantization table value
    .chr_qtable_data      (chr_qtable_data    ), // <o>  8b, quantization table value
    // qtable interface with external qtable memory
    .lum_qtable_rd_ext    (lum_qtable_rd_ext  ), // <o>  1b, lum quantization table read enable to external
    .chr_qtable_rd_ext    (chr_qtable_rd_ext  ), // <o>  1b, chr quantization table read enable to external
    .lum_qtable_addr_ext  (lum_qtable_addr_ext), // <o>  6b, lum quantization table read address to external
    .chr_qtable_addr_ext  (chr_qtable_addr_ext), // <o>  6b, chr quantization table read address to external
    .lum_qtable_data_ext  (lum_qtable_data_ext), // <i>  8b, quantization table value from external
    .chr_qtable_data_ext  (chr_qtable_data_ext)  // <i>  8b, quantization table value from external
    );

endmodule
