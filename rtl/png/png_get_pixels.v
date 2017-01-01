`define DLY #1

module png_get_pixels(
    // global signals
    clk                 , // <i>  1b, global clock
    rstn                , // <i>  1b, global reset, active low
    // picture size
    pic_width           , // <i> 11b, picture width
    pic_height          , // <i> 11b, picture height
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
    pixel_out_data      , // <o>  8b, pixel data output
    pixel_out_done      , // <o>  1b, pixel data output done
    pixel_out_valid     , // <o>  1b, pixel data output valid
    pixel_out_rdy         // <i>  1b, pixel data output ready
    );

  // global signals
  input         clk                 ; // <i>  1b, global clock
  input         rstn                ; // <i>  1b, global reset, active low
  // picture size
  input  [10:0] pic_width           ; // <i> 11b, picture width
  input  [10:0] pic_height          ; // <i> 11b, picture height
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
  output [7:0]  pixel_out_data      ; // <o>  8b, pixel data output
  output        pixel_out_done      ; // <o>  1b, pixel data output done
  output        pixel_out_valid     ; // <o>  1b, pixel data output valid
  input         pixel_out_rdy       ; // <i>  1b, pixel data output ready

  wire          pixel_in_valid      ; // input pixel valid indicator
  wire          pixel_in_rdy        ; // when to read input pixel

  wire   [7:0]  x_block             ; // how many blocks in x direction
  wire   [7:0]  y_block             ; // how many blocks in y direction

  wire          x_end               ; // read to end of picture in x direction
  wire          y_end               ; // read to end of picture in y direction
  wire          x_end_ext           ; // read to end of extend picture in x direction
  wire          y_end_ext           ; // read to end of extend picture in y direction

  reg    [1:0]  rgb_sel_cnt         ; // counter used to select r/g/b data

  reg    [10:0] x_cnt               ; // used to count the pixel in x direction
  reg    [10:0] y_cnt               ; // used to count the lines in y direction

  wire          pixel_out_boundary  ; // pixel out of boundary indicator, used to drop padding data

  reg    [63:0] line_data_r         ; // red   data line
  reg    [63:0] line_data_g         ; // green data line
  reg    [63:0] line_data_b         ; // blue  data line
  reg    [7:0]  pixel_data_r        ; // red   data current used
  reg    [7:0]  pixel_data_g        ; // green data current used
  reg    [7:0]  pixel_data_b        ; // blue  data current used

//assign pixel_in_valid = (&sdata_rvld) & (&sdata_gvld) & (&sdata_bvld);
  assign pixel_in_valid = sdata_rvld[7] & sdata_gvld[7] & sdata_bvld[7];
  assign pixel_in_rdy   = pixel_out_rdy | pixel_out_boundary;

  assign x_block = (pic_width[10:3]  + |pic_width[2:0] );
  assign y_block = (pic_height[10:3] + |pic_height[2:0]);

  assign x_end     = (x_cnt == (pic_width  - 1));
  assign y_end     = (y_cnt == (pic_height - 1));
  assign x_end_ext = (x_cnt == ({x_block, 3'b0} - 1));
  assign y_end_ext = (y_cnt == ({y_block, 3'b0} - 1));

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          rgb_sel_cnt <= `DLY 2'h0;
      end
      else if (pixel_in_valid & pixel_in_rdy) begin
          if (rgb_sel_cnt == 2) begin
              rgb_sel_cnt <= `DLY 2'h0;
          end
          else begin
              rgb_sel_cnt <= `DLY rgb_sel_cnt + 2'h1;
          end
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          x_cnt <= `DLY 0;
      end
      else if (pixel_in_valid & pixel_in_rdy & (rgb_sel_cnt == 3'h2)) begin
          if (x_end_ext) begin
              x_cnt <= `DLY 0;
          end
          else begin
              x_cnt <= `DLY x_cnt + 1;
          end
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_cnt <= `DLY 0;
      end
      else if (pixel_in_valid & pixel_in_rdy & (rgb_sel_cnt == 3'h2) & x_end_ext) begin
          if (y_end_ext) begin
              y_cnt <= `DLY 0;
          end
          else begin
              y_cnt <= `DLY y_cnt + 1;
          end
      end
  end

  assign pixel_out_boundary = (x_cnt >= pic_width) | (y_cnt >= pic_height);

  assign sdata_rrdy[0] = pixel_in_rdy & (y_cnt[2:0] == 0) & (x_cnt[2:0] == 7) & (rgb_sel_cnt == 2'h2);
  assign sdata_rrdy[1] = pixel_in_rdy & (y_cnt[2:0] == 1) & (x_cnt[2:0] == 7) & (rgb_sel_cnt == 2'h2);
  assign sdata_rrdy[2] = pixel_in_rdy & (y_cnt[2:0] == 2) & (x_cnt[2:0] == 7) & (rgb_sel_cnt == 2'h2);
  assign sdata_rrdy[3] = pixel_in_rdy & (y_cnt[2:0] == 3) & (x_cnt[2:0] == 7) & (rgb_sel_cnt == 2'h2);
  assign sdata_rrdy[4] = pixel_in_rdy & (y_cnt[2:0] == 4) & (x_cnt[2:0] == 7) & (rgb_sel_cnt == 2'h2);
  assign sdata_rrdy[5] = pixel_in_rdy & (y_cnt[2:0] == 5) & (x_cnt[2:0] == 7) & (rgb_sel_cnt == 2'h2);
  assign sdata_rrdy[6] = pixel_in_rdy & (y_cnt[2:0] == 6) & (x_cnt[2:0] == 7) & (rgb_sel_cnt == 2'h2);
  assign sdata_rrdy[7] = pixel_in_rdy & (y_cnt[2:0] == 7) & (x_cnt[2:0] == 7) & (rgb_sel_cnt == 2'h2);
  assign sdata_grdy = sdata_rrdy;
  assign sdata_brdy = sdata_rrdy;

  always @(*) begin
      case (y_cnt[2:0])
          3'h0   : line_data_r = sdata_r0;
          3'h1   : line_data_r = sdata_r1;
          3'h2   : line_data_r = sdata_r2;
          3'h3   : line_data_r = sdata_r3;
          3'h4   : line_data_r = sdata_r4;
          3'h5   : line_data_r = sdata_r5;
          3'h6   : line_data_r = sdata_r6;
          default: line_data_r = sdata_r7;
      endcase
  end

  always @(*) begin
      case (y_cnt[2:0])
          3'h0   : line_data_g = sdata_g0;
          3'h1   : line_data_g = sdata_g1;
          3'h2   : line_data_g = sdata_g2;
          3'h3   : line_data_g = sdata_g3;
          3'h4   : line_data_g = sdata_g4;
          3'h5   : line_data_g = sdata_g5;
          3'h6   : line_data_g = sdata_g6;
          default: line_data_g = sdata_g7;
      endcase
  end

  always @(*) begin
      case (y_cnt[2:0])
          3'h0   : line_data_b = sdata_b0;
          3'h1   : line_data_b = sdata_b1;
          3'h2   : line_data_b = sdata_b2;
          3'h3   : line_data_b = sdata_b3;
          3'h4   : line_data_b = sdata_b4;
          3'h5   : line_data_b = sdata_b5;
          3'h6   : line_data_b = sdata_b6;
          default: line_data_b = sdata_b7;
      endcase
  end

  always @(*) begin
      case (x_cnt[2:0])
          3'h0   : pixel_data_r = line_data_r[63:56];
          3'h1   : pixel_data_r = line_data_r[55:48];
          3'h2   : pixel_data_r = line_data_r[47:40];
          3'h3   : pixel_data_r = line_data_r[39:32];
          3'h4   : pixel_data_r = line_data_r[31:24];
          3'h5   : pixel_data_r = line_data_r[23:16];
          3'h6   : pixel_data_r = line_data_r[15:8] ;
          default: pixel_data_r = line_data_r[7:0]  ;
      endcase
  end

  always @(*) begin
      case (x_cnt[2:0])
          3'h0   : pixel_data_g = line_data_g[63:56];
          3'h1   : pixel_data_g = line_data_g[55:48];
          3'h2   : pixel_data_g = line_data_g[47:40];
          3'h3   : pixel_data_g = line_data_g[39:32];
          3'h4   : pixel_data_g = line_data_g[31:24];
          3'h5   : pixel_data_g = line_data_g[23:16];
          3'h6   : pixel_data_g = line_data_g[15:8] ;
          default: pixel_data_g = line_data_g[7:0]  ;
      endcase
  end

  always @(*) begin
      case (x_cnt[2:0])
          3'h0   : pixel_data_b = line_data_b[63:56];
          3'h1   : pixel_data_b = line_data_b[55:48];
          3'h2   : pixel_data_b = line_data_b[47:40];
          3'h3   : pixel_data_b = line_data_b[39:32];
          3'h4   : pixel_data_b = line_data_b[31:24];
          3'h5   : pixel_data_b = line_data_b[23:16];
          3'h6   : pixel_data_b = line_data_b[15:8] ;
          default: pixel_data_b = line_data_b[7:0]  ;
      endcase
  end

  assign pixel_out_data = (rgb_sel_cnt == 2'h0) ? pixel_data_r :
                          (rgb_sel_cnt == 2'h1) ? pixel_data_g :
                                                  pixel_data_b ;

  assign pixel_out_valid = pixel_in_valid & ~pixel_out_boundary;

  assign pixel_out_done = x_end & y_end & (rgb_sel_cnt == 2'h2) & pixel_out_valid;

endmodule
