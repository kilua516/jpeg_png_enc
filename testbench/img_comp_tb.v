`define TEST_JPEG
//`define TEST_PNG
`define DLY #1

module img_comp_tb;

//parameter HSIZE  = 308 ;
//parameter VSIZE  = 231 ;
//parameter HSTART = 10;
//parameter VSTART = 10;
//parameter HEND   = 10;
//parameter VEND   = 10;
  parameter HSIZE  = 8  ;
  parameter VSIZE  = 8  ;
  parameter HSTART = 10 ;
  parameter VSTART = 10 ;
  parameter HEND   = 40 ;
  parameter VEND   = 40 ;

  reg       clk     ;
  reg       rstn    ;

  reg       jpeg_en ;
  reg       png_en  ;

  wire [10:0]   pic_width   ;
  wire [10:0]   pic_height  ;
  reg           frame_start ;
  wire          frame_end   ;
  wire [22:0]   file_len    ;

  wire  [7:0]   sdata_rvld    ;
  wire  [7:0]   sdata_gvld    ;
  wire  [7:0]   sdata_bvld    ;
  wire  [7:0]   sdata_rrdy    ;
  wire  [7:0]   sdata_grdy    ;
  wire  [7:0]   sdata_brdy    ;
  wire  [63:0]  sdata_r0      ;
  wire  [63:0]  sdata_r1      ;
  wire  [63:0]  sdata_r2      ;
  wire  [63:0]  sdata_r3      ;
  wire  [63:0]  sdata_r4      ;
  wire  [63:0]  sdata_r5      ;
  wire  [63:0]  sdata_r6      ;
  wire  [63:0]  sdata_r7      ;
  wire  [63:0]  sdata_g0      ;
  wire  [63:0]  sdata_g1      ;
  wire  [63:0]  sdata_g2      ;
  wire  [63:0]  sdata_g3      ;
  wire  [63:0]  sdata_g4      ;
  wire  [63:0]  sdata_g5      ;
  wire  [63:0]  sdata_g6      ;
  wire  [63:0]  sdata_g7      ;
  wire  [63:0]  sdata_b0      ;
  wire  [63:0]  sdata_b1      ;
  wire  [63:0]  sdata_b2      ;
  wire  [63:0]  sdata_b3      ;
  wire  [63:0]  sdata_b4      ;
  wire  [63:0]  sdata_b5      ;
  wire  [63:0]  sdata_b6      ;
  wire  [63:0]  sdata_b7      ;
  wire  [63:0]  r_fifo0_data  ;
  wire  [63:0]  r_fifo1_data  ;
  wire  [63:0]  r_fifo2_data  ;
  wire  [63:0]  r_fifo3_data  ;
  wire  [63:0]  r_fifo4_data  ;
  wire  [63:0]  r_fifo5_data  ;
  wire  [63:0]  r_fifo6_data  ;
  wire  [63:0]  r_fifo7_data  ;
  wire  [63:0]  g_fifo0_data  ;
  wire  [63:0]  g_fifo1_data  ;
  wire  [63:0]  g_fifo2_data  ;
  wire  [63:0]  g_fifo3_data  ;
  wire  [63:0]  g_fifo4_data  ;
  wire  [63:0]  g_fifo5_data  ;
  wire  [63:0]  g_fifo6_data  ;
  wire  [63:0]  g_fifo7_data  ;
  wire  [63:0]  b_fifo0_data  ;
  wire  [63:0]  b_fifo1_data  ;
  wire  [63:0]  b_fifo2_data  ;
  wire  [63:0]  b_fifo3_data  ;
  wire  [63:0]  b_fifo4_data  ;
  wire  [63:0]  b_fifo5_data  ;
  wire  [63:0]  b_fifo6_data  ;
  wire  [63:0]  b_fifo7_data  ;

  wire          cdata_vld     ;
  wire  [31:0]  cdata         ;

  wire          pic_hsync     ;
  wire          pic_vsync     ;
  wire          pic_dat_en    ;
  wire  [23:0]  pic_data      ;

  reg           pic_hsync_d   ;
  wire          pic_hsync_pedge;

  reg           valid_line    ;
  reg   [10:0]  y_cnt         ;
  reg   [2:0]   pos_cnt       ;

  reg   [63:0]  r_buf         ;
  reg   [63:0]  g_buf         ;
  reg   [63:0]  b_buf         ;

  reg           line0_wr      ;
  reg           line1_wr      ;
  reg           line2_wr      ;
  reg           line3_wr      ;
  reg           line4_wr      ;
  reg           line5_wr      ;
  reg           line6_wr      ;
  reg           line7_wr      ;
  wire          line_wr       ;

  wire          sdata_r0_empty  ;
  wire          sdata_r1_empty  ;
  wire          sdata_r2_empty  ;
  wire          sdata_r3_empty  ;
  wire          sdata_r4_empty  ;
  wire          sdata_r5_empty  ;
  wire          sdata_r6_empty  ;
  wire          sdata_r7_empty  ;
  wire          sdata_g0_empty  ;
  wire          sdata_g1_empty  ;
  wire          sdata_g2_empty  ;
  wire          sdata_g3_empty  ;
  wire          sdata_g4_empty  ;
  wire          sdata_g5_empty  ;
  wire          sdata_g6_empty  ;
  wire          sdata_g7_empty  ;
  wire          sdata_b0_empty  ;
  wire          sdata_b1_empty  ;
  wire          sdata_b2_empty  ;
  wire          sdata_b3_empty  ;
  wire          sdata_b4_empty  ;
  wire          sdata_b5_empty  ;
  wire          sdata_b6_empty  ;
  wire          sdata_b7_empty  ;

  wire          lum_qtable_rd_ext  ;
  wire          chr_qtable_rd_ext  ;
  wire  [5:0]   lum_qtable_addr_ext;
  wire  [5:0]   chr_qtable_addr_ext;
  reg   [7:0]   lum_qtable_data_ext;
  reg   [7:0]   chr_qtable_data_ext;

  assign pic_width  = HSIZE;
  assign pic_height = VSIZE;

  initial begin
`ifdef TEST_JPEG
      png_en  = 1'b0;
      jpeg_en = 1'b1;
`else
      png_en  = 1'b1;
      jpeg_en = 1'b0;
`endif
      clk  = 0;
      rstn = 0;
      #1001;
      rstn = 1;
      @(posedge clk);
      frame_start = 1'b1;
      @(posedge clk);
      frame_start = 1'b0;
  end

  always begin
      #5;
      clk = (~clk) & rstn;
  end

  always @(posedge clk) begin
      case (lum_qtable_addr_ext)
          6'd0   : lum_qtable_data_ext <= `DLY 2 ;
          6'd1   : lum_qtable_data_ext <= `DLY 1 ;
          6'd2   : lum_qtable_data_ext <= `DLY 1 ;
          6'd3   : lum_qtable_data_ext <= `DLY 2 ;
          6'd4   : lum_qtable_data_ext <= `DLY 3 ;
          6'd5   : lum_qtable_data_ext <= `DLY 5 ;
          6'd6   : lum_qtable_data_ext <= `DLY 6 ;
          6'd7   : lum_qtable_data_ext <= `DLY 7 ;
          6'd8   : lum_qtable_data_ext <= `DLY 1 ;
          6'd9   : lum_qtable_data_ext <= `DLY 1 ;
          6'd10  : lum_qtable_data_ext <= `DLY 2 ;
          6'd11  : lum_qtable_data_ext <= `DLY 2 ;
          6'd12  : lum_qtable_data_ext <= `DLY 3 ;
          6'd13  : lum_qtable_data_ext <= `DLY 7 ;
          6'd14  : lum_qtable_data_ext <= `DLY 7 ;
          6'd15  : lum_qtable_data_ext <= `DLY 7 ;
          6'd16  : lum_qtable_data_ext <= `DLY 2 ;
          6'd17  : lum_qtable_data_ext <= `DLY 2 ;
          6'd18  : lum_qtable_data_ext <= `DLY 2 ;
          6'd19  : lum_qtable_data_ext <= `DLY 3 ;
          6'd20  : lum_qtable_data_ext <= `DLY 5 ;
          6'd21  : lum_qtable_data_ext <= `DLY 7 ;
          6'd22  : lum_qtable_data_ext <= `DLY 8 ;
          6'd23  : lum_qtable_data_ext <= `DLY 7 ;
          6'd24  : lum_qtable_data_ext <= `DLY 2 ;
          6'd25  : lum_qtable_data_ext <= `DLY 2 ;
          6'd26  : lum_qtable_data_ext <= `DLY 3 ;
          6'd27  : lum_qtable_data_ext <= `DLY 3 ;
          6'd28  : lum_qtable_data_ext <= `DLY 6 ;
          6'd29  : lum_qtable_data_ext <= `DLY 10;
          6'd30  : lum_qtable_data_ext <= `DLY 10;
          6'd31  : lum_qtable_data_ext <= `DLY 7 ;
          6'd32  : lum_qtable_data_ext <= `DLY 2 ;
          6'd33  : lum_qtable_data_ext <= `DLY 3 ;
          6'd34  : lum_qtable_data_ext <= `DLY 4 ;
          6'd35  : lum_qtable_data_ext <= `DLY 7 ;
          6'd36  : lum_qtable_data_ext <= `DLY 8 ;
          6'd37  : lum_qtable_data_ext <= `DLY 13;
          6'd38  : lum_qtable_data_ext <= `DLY 12;
          6'd39  : lum_qtable_data_ext <= `DLY 9 ;
          6'd40  : lum_qtable_data_ext <= `DLY 3 ;
          6'd41  : lum_qtable_data_ext <= `DLY 4 ;
          6'd42  : lum_qtable_data_ext <= `DLY 7 ;
          6'd43  : lum_qtable_data_ext <= `DLY 8 ;
          6'd44  : lum_qtable_data_ext <= `DLY 10;
          6'd45  : lum_qtable_data_ext <= `DLY 12;
          6'd46  : lum_qtable_data_ext <= `DLY 14;
          6'd47  : lum_qtable_data_ext <= `DLY 11;
          6'd48  : lum_qtable_data_ext <= `DLY 6 ;
          6'd49  : lum_qtable_data_ext <= `DLY 8 ;
          6'd50  : lum_qtable_data_ext <= `DLY 9 ;
          6'd51  : lum_qtable_data_ext <= `DLY 10;
          6'd52  : lum_qtable_data_ext <= `DLY 12;
          6'd53  : lum_qtable_data_ext <= `DLY 15;
          6'd54  : lum_qtable_data_ext <= `DLY 14;
          6'd55  : lum_qtable_data_ext <= `DLY 12;
          6'd56  : lum_qtable_data_ext <= `DLY 9 ;
          6'd57  : lum_qtable_data_ext <= `DLY 11;
          6'd58  : lum_qtable_data_ext <= `DLY 11;
          6'd59  : lum_qtable_data_ext <= `DLY 12;
          6'd60  : lum_qtable_data_ext <= `DLY 13;
          6'd61  : lum_qtable_data_ext <= `DLY 12;
          6'd62  : lum_qtable_data_ext <= `DLY 12;
          default: lum_qtable_data_ext <= `DLY 12;
      endcase
  end

  always @(posedge clk) begin
      case (chr_qtable_addr_ext)
          6'd0   : chr_qtable_data_ext <= `DLY 2 ;
          6'd1   : chr_qtable_data_ext <= `DLY 2 ;
          6'd2   : chr_qtable_data_ext <= `DLY 3 ;
          6'd3   : chr_qtable_data_ext <= `DLY 6 ;
          6'd4   : chr_qtable_data_ext <= `DLY 12;
          6'd5   : chr_qtable_data_ext <= `DLY 12;
          6'd6   : chr_qtable_data_ext <= `DLY 12;
          6'd7   : chr_qtable_data_ext <= `DLY 12;
          6'd8   : chr_qtable_data_ext <= `DLY 2 ;
          6'd9   : chr_qtable_data_ext <= `DLY 3 ;
          6'd10  : chr_qtable_data_ext <= `DLY 3 ;
          6'd11  : chr_qtable_data_ext <= `DLY 8 ;
          6'd12  : chr_qtable_data_ext <= `DLY 12;
          6'd13  : chr_qtable_data_ext <= `DLY 12;
          6'd14  : chr_qtable_data_ext <= `DLY 12;
          6'd15  : chr_qtable_data_ext <= `DLY 12;
          6'd16  : chr_qtable_data_ext <= `DLY 3 ;
          6'd17  : chr_qtable_data_ext <= `DLY 3 ;
          6'd18  : chr_qtable_data_ext <= `DLY 7 ;
          6'd19  : chr_qtable_data_ext <= `DLY 12;
          6'd20  : chr_qtable_data_ext <= `DLY 12;
          6'd21  : chr_qtable_data_ext <= `DLY 12;
          6'd22  : chr_qtable_data_ext <= `DLY 12;
          6'd23  : chr_qtable_data_ext <= `DLY 12;
          6'd24  : chr_qtable_data_ext <= `DLY 6 ;
          6'd25  : chr_qtable_data_ext <= `DLY 8 ;
          6'd26  : chr_qtable_data_ext <= `DLY 12;
          6'd27  : chr_qtable_data_ext <= `DLY 12;
          6'd28  : chr_qtable_data_ext <= `DLY 12;
          6'd29  : chr_qtable_data_ext <= `DLY 12;
          6'd30  : chr_qtable_data_ext <= `DLY 12;
          6'd31  : chr_qtable_data_ext <= `DLY 12;
          6'd32  : chr_qtable_data_ext <= `DLY 12;
          6'd33  : chr_qtable_data_ext <= `DLY 12;
          6'd34  : chr_qtable_data_ext <= `DLY 12;
          6'd35  : chr_qtable_data_ext <= `DLY 12;
          6'd36  : chr_qtable_data_ext <= `DLY 12;
          6'd37  : chr_qtable_data_ext <= `DLY 12;
          6'd38  : chr_qtable_data_ext <= `DLY 12;
          6'd39  : chr_qtable_data_ext <= `DLY 12;
          6'd40  : chr_qtable_data_ext <= `DLY 12;
          6'd41  : chr_qtable_data_ext <= `DLY 12;
          6'd42  : chr_qtable_data_ext <= `DLY 12;
          6'd43  : chr_qtable_data_ext <= `DLY 12;
          6'd44  : chr_qtable_data_ext <= `DLY 12;
          6'd45  : chr_qtable_data_ext <= `DLY 12;
          6'd46  : chr_qtable_data_ext <= `DLY 12;
          6'd47  : chr_qtable_data_ext <= `DLY 12;
          6'd48  : chr_qtable_data_ext <= `DLY 12;
          6'd49  : chr_qtable_data_ext <= `DLY 12;
          6'd50  : chr_qtable_data_ext <= `DLY 12;
          6'd51  : chr_qtable_data_ext <= `DLY 12;
          6'd52  : chr_qtable_data_ext <= `DLY 12;
          6'd53  : chr_qtable_data_ext <= `DLY 12;
          6'd54  : chr_qtable_data_ext <= `DLY 12;
          6'd55  : chr_qtable_data_ext <= `DLY 12;
          6'd56  : chr_qtable_data_ext <= `DLY 12;
          6'd57  : chr_qtable_data_ext <= `DLY 12;
          6'd58  : chr_qtable_data_ext <= `DLY 12;
          6'd59  : chr_qtable_data_ext <= `DLY 12;
          6'd60  : chr_qtable_data_ext <= `DLY 12;
          6'd61  : chr_qtable_data_ext <= `DLY 12;
          6'd62  : chr_qtable_data_ext <= `DLY 12;
          default: chr_qtable_data_ext <= `DLY 12;
      endcase
  end

  img_comp img_comp_dut(
    // global signals
    .clk                    (clk                ), // <i>  1b, system clock
    .rstn                   (rstn               ), // <i>  1b, global reset, active low
    // interface with control registers
    .jpeg_en                (jpeg_en            ), // <i>  1b, jpeg encoder enable
    .png_en                 (png_en             ), // <i>  1b, png encoder enable
    .frame_start            (frame_start        ), // <i>  1b, frame start indicator
    .frame_end              (frame_end          ), // <o>  1b, frame end indicator
    .pic_width              (pic_width          ), // <i> 11b, picture width
    .pic_height             (pic_height         ), // <i> 11b, picture height
    .file_len               (file_len           ), // <o> 23b, jpeg file length indicator
    // signals with quantization table
    .lum_qtable_rd_ext      (lum_qtable_rd_ext  ), // <o>  1b, lum quantization table read enable to external
    .chr_qtable_rd_ext      (chr_qtable_rd_ext  ), // <o>  1b, chr quantization table read enable to external
    .lum_qtable_addr_ext    (lum_qtable_addr_ext), // <o>  6b, lum quantization table read address to external
    .chr_qtable_addr_ext    (chr_qtable_addr_ext), // <o>  6b, chr quantization table read address to external
    .lum_qtable_data_ext    (lum_qtable_data_ext), // <i>  8b, quantization table value from external
    .chr_qtable_data_ext    (chr_qtable_data_ext), // <i>  8b, quantization table value from external
    // data from 8 line fifo
    .sdata_rvld             (sdata_rvld         ), // <i>  8b, input 8 line r data valid
    .sdata_gvld             (sdata_gvld         ), // <i>  8b, input 8 line g data valid
    .sdata_bvld             (sdata_bvld         ), // <i>  8b, input 8 line b data valid
    .sdata_rrdy             (sdata_rrdy         ), // <o>  8b, input r data accept
    .sdata_grdy             (sdata_grdy         ), // <o>  8b, input g data accept
    .sdata_brdy             (sdata_brdy         ), // <o>  8b, input b data accept
    .sdata_r0               (sdata_r0           ), // <i> 64b, r data from line0 of a block
    .sdata_r1               (sdata_r1           ), // <i> 64b, r data from line1 of a block
    .sdata_r2               (sdata_r2           ), // <i> 64b, r data from line2 of a block
    .sdata_r3               (sdata_r3           ), // <i> 64b, r data from line3 of a block
    .sdata_r4               (sdata_r4           ), // <i> 64b, r data from line4 of a block
    .sdata_r5               (sdata_r5           ), // <i> 64b, r data from line5 of a block
    .sdata_r6               (sdata_r6           ), // <i> 64b, r data from line6 of a block
    .sdata_r7               (sdata_r7           ), // <i> 64b, r data from line7 of a block
    .sdata_g0               (sdata_g0           ), // <i> 64b, g data from line0 of a block
    .sdata_g1               (sdata_g1           ), // <i> 64b, g data from line1 of a block
    .sdata_g2               (sdata_g2           ), // <i> 64b, g data from line2 of a block
    .sdata_g3               (sdata_g3           ), // <i> 64b, g data from line3 of a block
    .sdata_g4               (sdata_g4           ), // <i> 64b, g data from line4 of a block
    .sdata_g5               (sdata_g5           ), // <i> 64b, g data from line5 of a block
    .sdata_g6               (sdata_g6           ), // <i> 64b, g data from line6 of a block
    .sdata_g7               (sdata_g7           ), // <i> 64b, g data from line7 of a block
    .sdata_b0               (sdata_b0           ), // <i> 64b, b data from line0 of a block
    .sdata_b1               (sdata_b1           ), // <i> 64b, b data from line1 of a block
    .sdata_b2               (sdata_b2           ), // <i> 64b, b data from line2 of a block
    .sdata_b3               (sdata_b3           ), // <i> 64b, b data from line3 of a block
    .sdata_b4               (sdata_b4           ), // <i> 64b, b data from line4 of a block
    .sdata_b5               (sdata_b5           ), // <i> 64b, b data from line5 of a block
    .sdata_b6               (sdata_b6           ), // <i> 64b, b data from line6 of a block
    .sdata_b7               (sdata_b7           ), // <i> 64b, b data from line7 of a block
    // stream output
    .cdata_vld              (cdata_vld          ), // <o>  1b, jpeg stream output valid
    .cdata                  (cdata              )  // <o> 32b, jpeg stream output
    );

  pic_gen #(HSIZE + HSTART + HEND, // HTOTAL
            VSIZE + VSTART + VEND, // VTOTAL
            HSTART               , // HSTART
            VSTART               , // VSTART
            HSIZE                , // HSIZE 
            VSIZE                , // VSIZE 
`ifdef TEST_JPEG
            1       ) // CLK_DIV
`else
            3       ) // CLK_DIV
`endif
  pic_gen (
    // global signals
    .clk                    (clk                ), // <i>  1b, global clock
    .rstn                   (rstn               ), // <i>  1b, global reset, active low
    // picture data output
    .pic_hsync              (pic_hsync          ), // <o>  1b, picture hsync
    .pic_vsync              (pic_vsync          ), // <o>  1b, picture vsync
    .pic_dat_en             (pic_dat_en         ), // <o>  1b, picture data enable
    .pic_data               (pic_data           )  // <o> 24b, picture data
    );

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          pic_hsync_d <= `DLY 1'b0;
      end
      else begin
          pic_hsync_d <= `DLY pic_hsync;
      end
  end

  assign pic_hsync_pedge = pic_hsync & ~pic_hsync_d;

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          valid_line <= `DLY 1'b0;
      end
      else if (pic_dat_en) begin
          valid_line <= `DLY 1'b1;
      end
      else if (pic_hsync_pedge) begin
          valid_line <= `DLY 1'b0;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_cnt <= `DLY 0;
      end
      else if (pic_vsync) begin
          y_cnt <= `DLY 0;
      end
      else if (pic_hsync_pedge & valid_line) begin
          y_cnt <= `DLY y_cnt + 1;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          pos_cnt <= `DLY 3'h0;
      end
      else if (pic_hsync_pedge) begin
          pos_cnt <= `DLY 3'h0;
      end
      else if (pic_dat_en) begin
          pos_cnt <= `DLY pos_cnt + 3'h1;
      end
  end

//always @(posedge clk or negedge rstn) begin
//    if (~rstn) begin
//        r_buf <= `DLY 64'h0;
//    end
//    else if (pic_dat_en) begin
//        case (pos_cnt)
//            0: r_buf[63:56] <= `DLY pic_data[23:16];
//            1: r_buf[55:48] <= `DLY pic_data[23:16];
//            2: r_buf[47:40] <= `DLY pic_data[23:16];
//            3: r_buf[39:32] <= `DLY pic_data[23:16];
//            4: r_buf[31:24] <= `DLY pic_data[23:16];
//            5: r_buf[23:16] <= `DLY pic_data[23:16];
//            6: r_buf[15:8]  <= `DLY pic_data[23:16];
//            7: r_buf[7:0]   <= `DLY pic_data[23:16];
//        endcase
//    end
//    else if (line_wr) begin
//        r_buf <= `DLY 64'h0;
//    end
//end

//always @(posedge clk or negedge rstn) begin
//    if (~rstn) begin
//        g_buf <= `DLY 64'h0;
//    end
//    else if (pic_dat_en) begin
//        case (pos_cnt)
//            0: g_buf[63:56] <= `DLY pic_data[15:8];
//            1: g_buf[55:48] <= `DLY pic_data[15:8];
//            2: g_buf[47:40] <= `DLY pic_data[15:8];
//            3: g_buf[39:32] <= `DLY pic_data[15:8];
//            4: g_buf[31:24] <= `DLY pic_data[15:8];
//            5: g_buf[23:16] <= `DLY pic_data[15:8];
//            6: g_buf[15:8]  <= `DLY pic_data[15:8];
//            7: g_buf[7:0]   <= `DLY pic_data[15:8];
//        endcase
//    end
//    else if (line_wr) begin
//        g_buf <= `DLY 64'h0;
//    end
//end

//always @(posedge clk or negedge rstn) begin
//    if (~rstn) begin
//        b_buf <= `DLY 64'h0;
//    end
//    else if (pic_dat_en) begin
//        case (pos_cnt)
//            0: b_buf[63:56] <= `DLY pic_data[7:0];
//            1: b_buf[55:48] <= `DLY pic_data[7:0];
//            2: b_buf[47:40] <= `DLY pic_data[7:0];
//            3: b_buf[39:32] <= `DLY pic_data[7:0];
//            4: b_buf[31:24] <= `DLY pic_data[7:0];
//            5: b_buf[23:16] <= `DLY pic_data[7:0];
//            6: b_buf[15:8]  <= `DLY pic_data[7:0];
//            7: b_buf[7:0]   <= `DLY pic_data[7:0];
//        endcase
//    end
//    else if (line_wr) begin
//        b_buf <= `DLY 64'h0;
//    end
//end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          r_buf <= `DLY 64'h0;
      end
      else if (pic_dat_en) begin
          case (pos_cnt)
              0: r_buf[63:0] <= `DLY {8{pic_data[23:16]}};
              1: r_buf[55:0] <= `DLY {7{pic_data[23:16]}};
              2: r_buf[47:0] <= `DLY {6{pic_data[23:16]}};
              3: r_buf[39:0] <= `DLY {5{pic_data[23:16]}};
              4: r_buf[31:0] <= `DLY {4{pic_data[23:16]}};
              5: r_buf[23:0] <= `DLY {3{pic_data[23:16]}};
              6: r_buf[15:0] <= `DLY {2{pic_data[23:16]}};
              7: r_buf[7:0]  <= `DLY pic_data[23:16];
          endcase
      end
      else if (line_wr) begin
          r_buf <= `DLY 64'h0;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          g_buf <= `DLY 64'h0;
      end
      else if (pic_dat_en) begin
          case (pos_cnt)
              0: g_buf[63:0] <= `DLY {8{pic_data[15:8]}};
              1: g_buf[55:0] <= `DLY {7{pic_data[15:8]}};
              2: g_buf[47:0] <= `DLY {6{pic_data[15:8]}};
              3: g_buf[39:0] <= `DLY {5{pic_data[15:8]}};
              4: g_buf[31:0] <= `DLY {4{pic_data[15:8]}};
              5: g_buf[23:0] <= `DLY {3{pic_data[15:8]}};
              6: g_buf[15:0] <= `DLY {2{pic_data[15:8]}};
              7: g_buf[7:0]  <= `DLY pic_data[15:8];
          endcase
      end
      else if (line_wr) begin
          g_buf <= `DLY 64'h0;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          b_buf <= `DLY 64'h0;
      end
      else if (pic_dat_en) begin
          case (pos_cnt)
              0: b_buf[63:0] <= `DLY {8{pic_data[7:0]}};
              1: b_buf[55:0] <= `DLY {7{pic_data[7:0]}};
              2: b_buf[47:0] <= `DLY {6{pic_data[7:0]}};
              3: b_buf[39:0] <= `DLY {5{pic_data[7:0]}};
              4: b_buf[31:0] <= `DLY {4{pic_data[7:0]}};
              5: b_buf[23:0] <= `DLY {3{pic_data[7:0]}};
              6: b_buf[15:0] <= `DLY {2{pic_data[7:0]}};
              7: b_buf[7:0]  <= `DLY pic_data[7:0];
          endcase
      end
      else if (line_wr) begin
          b_buf <= `DLY 64'h0;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          line0_wr <= `DLY 1'b0;
          line1_wr <= `DLY 1'b0;
          line2_wr <= `DLY 1'b0;
          line3_wr <= `DLY 1'b0;
          line4_wr <= `DLY 1'b0;
          line5_wr <= `DLY 1'b0;
          line6_wr <= `DLY 1'b0;
          line7_wr <= `DLY 1'b0;
      end
      else begin
          line0_wr <= `DLY valid_line & ((y_cnt[2:0] == 0) | ((y_cnt == (pic_height - 1) & (y_cnt[2:0] <= 0)))) & (((pos_cnt == 7) & pic_dat_en) | (|pic_width[2:0] & pic_hsync_pedge));
          line1_wr <= `DLY valid_line & ((y_cnt[2:0] == 1) | ((y_cnt == (pic_height - 1) & (y_cnt[2:0] <= 1)))) & (((pos_cnt == 7) & pic_dat_en) | (|pic_width[2:0] & pic_hsync_pedge));
          line2_wr <= `DLY valid_line & ((y_cnt[2:0] == 2) | ((y_cnt == (pic_height - 1) & (y_cnt[2:0] <= 2)))) & (((pos_cnt == 7) & pic_dat_en) | (|pic_width[2:0] & pic_hsync_pedge));
          line3_wr <= `DLY valid_line & ((y_cnt[2:0] == 3) | ((y_cnt == (pic_height - 1) & (y_cnt[2:0] <= 3)))) & (((pos_cnt == 7) & pic_dat_en) | (|pic_width[2:0] & pic_hsync_pedge));
          line4_wr <= `DLY valid_line & ((y_cnt[2:0] == 4) | ((y_cnt == (pic_height - 1) & (y_cnt[2:0] <= 4)))) & (((pos_cnt == 7) & pic_dat_en) | (|pic_width[2:0] & pic_hsync_pedge));
          line5_wr <= `DLY valid_line & ((y_cnt[2:0] == 5) | ((y_cnt == (pic_height - 1) & (y_cnt[2:0] <= 5)))) & (((pos_cnt == 7) & pic_dat_en) | (|pic_width[2:0] & pic_hsync_pedge));
          line6_wr <= `DLY valid_line & ((y_cnt[2:0] == 6) | ((y_cnt == (pic_height - 1) & (y_cnt[2:0] <= 6)))) & (((pos_cnt == 7) & pic_dat_en) | (|pic_width[2:0] & pic_hsync_pedge));
          line7_wr <= `DLY valid_line & ((y_cnt[2:0] == 7) | ((y_cnt == (pic_height - 1) & (y_cnt[2:0] <= 7)))) & (((pos_cnt == 7) & pic_dat_en) | (|pic_width[2:0] & pic_hsync_pedge));
      end
  end

  assign line_wr = line0_wr | line1_wr | line2_wr | line3_wr |
                   line4_wr | line5_wr | line6_wr | line7_wr ;

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    r_fifo_0 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line0_wr         ), // <i>  1b, fifo write enable
    .din                (r_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_rrdy[0]    ), // <o>  1b, fifo read enable
    .dout               (r_fifo0_data     ), // <o>    , fifo data output
    .empty              (sdata_r0_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    r_fifo_1 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line1_wr         ), // <i>  1b, fifo write enable
    .din                (r_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_rrdy[1]    ), // <o>  1b, fifo read enable
    .dout               (r_fifo1_data     ), // <o>    , fifo data output
    .empty              (sdata_r1_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    r_fifo_2 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line2_wr         ), // <i>  1b, fifo write enable
    .din                (r_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_rrdy[2]    ), // <o>  1b, fifo read enable
    .dout               (r_fifo2_data     ), // <o>    , fifo data output
    .empty              (sdata_r2_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    r_fifo_3 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line3_wr         ), // <i>  1b, fifo write enable
    .din                (r_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_rrdy[3]    ), // <o>  1b, fifo read enable
    .dout               (r_fifo3_data     ), // <o>    , fifo data output
    .empty              (sdata_r3_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    r_fifo_4 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line4_wr         ), // <i>  1b, fifo write enable
    .din                (r_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_rrdy[4]    ), // <o>  1b, fifo read enable
    .dout               (r_fifo4_data     ), // <o>    , fifo data output
    .empty              (sdata_r4_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    r_fifo_5 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line5_wr         ), // <i>  1b, fifo write enable
    .din                (r_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_rrdy[5]    ), // <o>  1b, fifo read enable
    .dout               (r_fifo5_data     ), // <o>    , fifo data output
    .empty              (sdata_r5_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    r_fifo_6 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line6_wr         ), // <i>  1b, fifo write enable
    .din                (r_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_rrdy[6]    ), // <o>  1b, fifo read enable
    .dout               (r_fifo6_data     ), // <o>    , fifo data output
    .empty              (sdata_r6_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    r_fifo_7 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line7_wr         ), // <i>  1b, fifo write enable
    .din                (r_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_rrdy[7]    ), // <o>  1b, fifo read enable
    .dout               (r_fifo7_data     ), // <o>    , fifo data output
    .empty              (sdata_r7_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    g_fifo_0 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line0_wr         ), // <i>  1b, fifo write enable
    .din                (g_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_grdy[0]    ), // <o>  1b, fifo read enable
    .dout               (g_fifo0_data     ), // <o>    , fifo data output
    .empty              (sdata_g0_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    g_fifo_1 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line1_wr         ), // <i>  1b, fifo write enable
    .din                (g_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_grdy[1]    ), // <o>  1b, fifo read enable
    .dout               (g_fifo1_data     ), // <o>    , fifo data output
    .empty              (sdata_g1_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    g_fifo_2 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line2_wr         ), // <i>  1b, fifo write enable
    .din                (g_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_grdy[2]    ), // <o>  1b, fifo read enable
    .dout               (g_fifo2_data     ), // <o>    , fifo data output
    .empty              (sdata_g2_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    g_fifo_3 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line3_wr         ), // <i>  1b, fifo write enable
    .din                (g_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_grdy[3]    ), // <o>  1b, fifo read enable
    .dout               (g_fifo3_data     ), // <o>    , fifo data output
    .empty              (sdata_g3_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    g_fifo_4 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line4_wr         ), // <i>  1b, fifo write enable
    .din                (g_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_grdy[4]    ), // <o>  1b, fifo read enable
    .dout               (g_fifo4_data     ), // <o>    , fifo data output
    .empty              (sdata_g4_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    g_fifo_5 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line5_wr         ), // <i>  1b, fifo write enable
    .din                (g_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_grdy[5]    ), // <o>  1b, fifo read enable
    .dout               (g_fifo5_data     ), // <o>    , fifo data output
    .empty              (sdata_g5_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    g_fifo_6 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line6_wr         ), // <i>  1b, fifo write enable
    .din                (g_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_grdy[6]    ), // <o>  1b, fifo read enable
    .dout               (g_fifo6_data     ), // <o>    , fifo data output
    .empty              (sdata_g6_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    g_fifo_7 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line7_wr         ), // <i>  1b, fifo write enable
    .din                (g_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_grdy[7]    ), // <o>  1b, fifo read enable
    .dout               (g_fifo7_data     ), // <o>    , fifo data output
    .empty              (sdata_g7_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    b_fifo_0 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line0_wr         ), // <i>  1b, fifo write enable
    .din                (b_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_brdy[0]    ), // <o>  1b, fifo read enable
    .dout               (b_fifo0_data     ), // <o>    , fifo data output
    .empty              (sdata_b0_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    b_fifo_1 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line1_wr         ), // <i>  1b, fifo write enable
    .din                (b_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_brdy[1]    ), // <o>  1b, fifo read enable
    .dout               (b_fifo1_data     ), // <o>    , fifo data output
    .empty              (sdata_b1_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    b_fifo_2 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line2_wr         ), // <i>  1b, fifo write enable
    .din                (b_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_brdy[2]    ), // <o>  1b, fifo read enable
    .dout               (b_fifo2_data     ), // <o>    , fifo data output
    .empty              (sdata_b2_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    b_fifo_3 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line3_wr         ), // <i>  1b, fifo write enable
    .din                (b_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_brdy[3]    ), // <o>  1b, fifo read enable
    .dout               (b_fifo3_data     ), // <o>    , fifo data output
    .empty              (sdata_b3_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    b_fifo_4 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line4_wr         ), // <i>  1b, fifo write enable
    .din                (b_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_brdy[4]    ), // <o>  1b, fifo read enable
    .dout               (b_fifo4_data     ), // <o>    , fifo data output
    .empty              (sdata_b4_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    b_fifo_5 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line5_wr         ), // <i>  1b, fifo write enable
    .din                (b_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_brdy[5]    ), // <o>  1b, fifo read enable
    .dout               (b_fifo5_data     ), // <o>    , fifo data output
    .empty              (sdata_b5_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    b_fifo_6 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line6_wr         ), // <i>  1b, fifo write enable
    .din                (b_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_brdy[6]    ), // <o>  1b, fifo read enable
    .dout               (b_fifo6_data     ), // <o>    , fifo data output
    .empty              (sdata_b6_empty   )  // <o>  1b, fifo empty indicator
    );

  fifo #(64  ,  // FIFO_DW    
         11  ,  // FIFO_AW    
         2048)  // FIFO_DEPTH 
    b_fifo_7 (
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (line7_wr         ), // <i>  1b, fifo write enable
    .din                (b_buf            ), // <i>    , fifo data input
    .full               (                 ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (sdata_brdy[7]    ), // <o>  1b, fifo read enable
    .dout               (b_fifo7_data     ), // <o>    , fifo data output
    .empty              (sdata_b7_empty   )  // <o>  1b, fifo empty indicator
    );

  assign sdata_r0 = r_fifo0_data;
  assign sdata_r1 = sdata_r1_empty ? r_fifo0_data : r_fifo1_data;
  assign sdata_r2 = sdata_r2_empty ? r_fifo1_data : r_fifo2_data;
  assign sdata_r3 = sdata_r3_empty ? r_fifo2_data : r_fifo3_data;
  assign sdata_r4 = sdata_r4_empty ? r_fifo3_data : r_fifo4_data;
  assign sdata_r5 = sdata_r5_empty ? r_fifo4_data : r_fifo5_data;
  assign sdata_r6 = sdata_r6_empty ? r_fifo5_data : r_fifo6_data;
  assign sdata_r7 = sdata_r7_empty ? r_fifo6_data : r_fifo7_data;
  assign sdata_g0 = g_fifo0_data;
  assign sdata_g1 = sdata_g1_empty ? g_fifo0_data : g_fifo1_data;
  assign sdata_g2 = sdata_g2_empty ? g_fifo1_data : g_fifo2_data;
  assign sdata_g3 = sdata_g3_empty ? g_fifo2_data : g_fifo3_data;
  assign sdata_g4 = sdata_g4_empty ? g_fifo3_data : g_fifo4_data;
  assign sdata_g5 = sdata_g5_empty ? g_fifo4_data : g_fifo5_data;
  assign sdata_g6 = sdata_g6_empty ? g_fifo5_data : g_fifo6_data;
  assign sdata_g7 = sdata_g7_empty ? g_fifo6_data : g_fifo7_data;
  assign sdata_b0 = b_fifo0_data;
  assign sdata_b1 = sdata_b1_empty ? b_fifo0_data : b_fifo1_data;
  assign sdata_b2 = sdata_b2_empty ? b_fifo1_data : b_fifo2_data;
  assign sdata_b3 = sdata_b3_empty ? b_fifo2_data : b_fifo3_data;
  assign sdata_b4 = sdata_b4_empty ? b_fifo3_data : b_fifo4_data;
  assign sdata_b5 = sdata_b5_empty ? b_fifo4_data : b_fifo5_data;
  assign sdata_b6 = sdata_b6_empty ? b_fifo5_data : b_fifo6_data;
  assign sdata_b7 = sdata_b7_empty ? b_fifo6_data : b_fifo7_data;

  assign sdata_rvld = {~sdata_r7_empty,
                       ~sdata_r6_empty,
                       ~sdata_r5_empty,
                       ~sdata_r4_empty,
                       ~sdata_r3_empty,
                       ~sdata_r2_empty,
                       ~sdata_r1_empty,
                       ~sdata_r0_empty};
  assign sdata_gvld = {~sdata_g7_empty,
                       ~sdata_g6_empty,
                       ~sdata_g5_empty,
                       ~sdata_g4_empty,
                       ~sdata_g3_empty,
                       ~sdata_g2_empty,
                       ~sdata_g1_empty,
                       ~sdata_g0_empty};
  assign sdata_bvld = {~sdata_b7_empty,
                       ~sdata_b6_empty,
                       ~sdata_b5_empty,
                       ~sdata_b4_empty,
                       ~sdata_b3_empty,
                       ~sdata_b2_empty,
                       ~sdata_b1_empty,
                       ~sdata_b0_empty};

  integer   PIC_SOURCE;

  integer   IMG_FILE;
  integer   IMG_PIC ;

  initial begin
      PIC_SOURCE = $fopen("pic_source.txt", "wb");
//    @(posedge frame_end);
//    @(posedge frame_end);
      @(posedge frame_end);
      #1000;
      $fclose(PIC_SOURCE);
  end

  initial begin
      IMG_FILE = $fopen("img_file.txt", "wb");
      if (jpeg_en) begin
          IMG_PIC  = $fopen("img.jpg", "wb");
      end
      else if (png_en) begin
          IMG_PIC  = $fopen("img.png", "wb");
      end
//    @(posedge frame_end);
//    @(posedge frame_end);
      @(posedge frame_end);
      #1000;
      $fclose(IMG_FILE);
      $fclose(IMG_PIC);
      $finish;
  end

  always @(posedge clk) begin
      if (sdata_rvld[0] & sdata_rrdy[0]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_r0);
      end
      if (sdata_rvld[1] & sdata_rrdy[1]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_r1);
      end
      if (sdata_rvld[2] & sdata_rrdy[2]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_r2);
      end
      if (sdata_rvld[3] & sdata_rrdy[3]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_r3);
      end
      if (sdata_rvld[4] & sdata_rrdy[4]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_r4);
      end
      if (sdata_rvld[5] & sdata_rrdy[5]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_r5);
      end
      if (sdata_rvld[6] & sdata_rrdy[6]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_r6);
      end
      if (sdata_rvld[7] & sdata_rrdy[7]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_r7);
      end
      if (sdata_gvld[0] & sdata_grdy[0]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_g0);
      end
      if (sdata_gvld[1] & sdata_grdy[1]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_g1);
      end
      if (sdata_gvld[2] & sdata_grdy[2]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_g2);
      end
      if (sdata_gvld[3] & sdata_grdy[3]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_g3);
      end
      if (sdata_gvld[4] & sdata_grdy[4]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_g4);
      end
      if (sdata_gvld[5] & sdata_grdy[5]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_g5);
      end
      if (sdata_gvld[6] & sdata_grdy[6]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_g6);
      end
      if (sdata_gvld[7] & sdata_grdy[7]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_g7);
      end
      if (sdata_bvld[0] & sdata_brdy[0]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_b0);
      end
      if (sdata_bvld[1] & sdata_brdy[1]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_b1);
      end
      if (sdata_bvld[2] & sdata_brdy[2]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_b2);
      end
      if (sdata_bvld[3] & sdata_brdy[3]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_b3);
      end
      if (sdata_bvld[4] & sdata_brdy[4]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_b4);
      end
      if (sdata_bvld[5] & sdata_brdy[5]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_b5);
      end
      if (sdata_bvld[6] & sdata_brdy[6]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_b6);
      end
      if (sdata_bvld[7] & sdata_brdy[7]) begin
          $fdisplay(PIC_SOURCE, "%x", sdata_b7);
      end
  end

  always @(posedge clk) begin
      if (cdata_vld) begin
          $fdisplay(IMG_FILE, "%x", cdata[7:0]  );
          $fdisplay(IMG_FILE, "%x", cdata[15:8] );
          $fdisplay(IMG_FILE, "%x", cdata[23:16]);
          $fdisplay(IMG_FILE, "%x", cdata[31:24]);
          $fwrite(IMG_PIC, "%c", cdata[7:0]);
          $fwrite(IMG_PIC, "%c", cdata[15:8]);
          $fwrite(IMG_PIC, "%c", cdata[23:16]);
          $fwrite(IMG_PIC, "%c", cdata[31:24]);
      end
  end

  integer   Y_DCTX_IN   ;
  integer   Y_DCTY_OUT  ;

  initial begin
      Y_DCTX_IN  = $fopen("y_dctx_in.txt", "wb");
      Y_DCTY_OUT = $fopen("y_dcty_out.txt", "wb");
//    @(posedge frame_end);
//    @(posedge frame_end);
      @(posedge frame_end);
      #1000;
      $fclose(Y_DCTX_IN);
      $fclose(Y_DCTY_OUT);
  end

  wire          y_dcty_out_valid = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_valid;
  wire  [13:0]  y_dcty_out_0     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_0    ;
  wire  [13:0]  y_dcty_out_1     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_1    ;
  wire  [13:0]  y_dcty_out_2     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_2    ;
  wire  [13:0]  y_dcty_out_3     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_3    ;
  wire  [13:0]  y_dcty_out_4     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_4    ;
  wire  [13:0]  y_dcty_out_5     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_5    ;
  wire  [13:0]  y_dcty_out_6     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_6    ;
  wire  [13:0]  y_dcty_out_7     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dcty_out_7    ;

  always @(posedge clk) begin
      if (y_dcty_out_valid) begin
          $fdisplay(Y_DCTY_OUT, "%x %x %x %x %x %x %x %x ",
                         y_dcty_out_0,
                         y_dcty_out_1,
                         y_dcty_out_2,
                         y_dcty_out_3,
                         y_dcty_out_4,
                         y_dcty_out_5,
                         y_dcty_out_6,
                         y_dcty_out_7);
      end
  end

  wire          y_dctx_in_valid = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_valid;
  wire  [7:0]   y_dctx_in_0     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_0    ;
  wire  [7:0]   y_dctx_in_1     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_1    ;
  wire  [7:0]   y_dctx_in_2     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_2    ;
  wire  [7:0]   y_dctx_in_3     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_3    ;
  wire  [7:0]   y_dctx_in_4     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_4    ;
  wire  [7:0]   y_dctx_in_5     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_5    ;
  wire  [7:0]   y_dctx_in_6     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_6    ;
  wire  [7:0]   y_dctx_in_7     = img_comp_dut.jpeg_enc_u0.dct_u0.y_dctx_in_7    ;

  always @(posedge clk) begin
      if (y_dctx_in_valid) begin
          $fdisplay(Y_DCTX_IN, "%x %x %x %x %x %x %x %x ",
                         y_dctx_in_0,
                         y_dctx_in_1,
                         y_dctx_in_2,
                         y_dctx_in_3,
                         y_dctx_in_4,
                         y_dctx_in_5,
                         y_dctx_in_6,
                         y_dctx_in_7);
      end
  end

  initial begin
      $fsdbDumpfile("test.fsdb");
      $fsdbDumpvars(0, img_comp_tb);
  end

endmodule
