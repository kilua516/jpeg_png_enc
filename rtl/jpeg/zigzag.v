`define DLY #1

module zigzag(
    // global
    clk                 , // <i>  1b, global clock
    rstn                , // <i>  1b, global reset, active low
    // input dct_data
    dct_data            , // <i> 42b, dct data output
    dct_data_valid      , // <i>  1b, dct data output valid
    // zigzag out
    zigzag_data         , // <o> 42b, zigzag data output
    zigzag_data_valid     // <o>  1b, zigzag data output valid
    );

  // global
  input         clk                 ; // <i>  1b, global clock
  input         rstn                ; // <i>  1b, global reset, active low
  // input dct_data
  input  [41:0] dct_data            ; // <i> 42b, dct data output
  input         dct_data_valid      ; // <i>  1b, dct data output valid
  // zigzag out
  output [41:0] zigzag_data         ; // <o> 42b, zigzag data output
  output        zigzag_data_valid   ; // <o>  1b, zigzag data output valid

  reg    [5:0]  block_buf_wr_cnt    ; // block buffer write count
  wire          block_buf_wr_done   ; // block buffer write done
  reg    [5:0]  block_buf_rd_cnt    ; // block buffer read count
  wire          block_buf_rd_done   ; // block buffer read done

  reg           block_buf_sel       ; // select current write to block buffer 0 or 1
  reg           block_buf_sel_d     ; // delay of block_buf_sel to sync with block_bufx_dout

  wire          block_buf0_wr       ; // block buffer 0 write enable
  wire          block_buf1_wr       ; // block buffer 1 write enable
  reg           block_buf0_rd       ; // block buffer 0 read enable
  reg           block_buf1_rd       ; // block buffer 1 read enable
  wire          block_buf_wr        ; // block buffer write enable
  wire          block_buf_rd        ; // block buffer read enable
  reg           block_buf_rd_d      ; // delay of block_buf0_rd and block_buf1_rd

  wire   [5:0]  block_buf0_waddr    ; // block buffer 0 write address
  wire   [5:0]  block_buf1_waddr    ; // block buffer 1 write address
  wire   [5:0]  block_buf0_raddr    ; // block buffer 0 read address
  wire   [5:0]  block_buf1_raddr    ; // block buffer 1 read address
  wire   [5:0]  block_buf0_addr     ; // block buffer 0 address
  wire   [5:0]  block_buf1_addr     ; // block buffer 1 address

  wire   [41:0] block_buf_din       ; // block buffer data input
  wire   [41:0] block_buf0_dout     ; // block buffer 0 data output
  wire   [41:0] block_buf1_dout     ; // block buffer 1 data output
  wire   [41:0] block_buf_dout      ; // block buffer data output

  reg    [5:0]  zigzag_addr         ; // zigzag address

//--------------------------------------------
//    block buffer control signals
//--------------------------------------------

  // count the data written into block buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_wr_cnt <= `DLY 6'h0;
      end
      else if (dct_data_valid) begin
          block_buf_wr_cnt <= `DLY block_buf_wr_cnt + 6'h1;
      end
  end

  // block write done indicator
  assign block_buf_wr_done = (block_buf_wr_cnt == 6'h3F) & dct_data_valid;

  // count the data read from block buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_rd_cnt <= `DLY 6'h0;
      end
      else if (block_buf_rd) begin
          block_buf_rd_cnt <= `DLY block_buf_rd_cnt + 6'h1;
      end
  end

  // block read done indicator
  assign block_buf_rd_done = (block_buf_rd_cnt == 6'h3F) & block_buf_rd;

  // block buffer select
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_sel <= `DLY 1'b0;
      end
      else if (block_buf_wr_done) begin
          block_buf_sel <= `DLY ~block_buf_sel;
      end
  end

  // delay of block_buf_sel
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_sel_d <= `DLY 1'b0;
      end
      else begin
          block_buf_sel_d <= `DLY block_buf_sel;
      end
  end

  // block buffer 0 and 1 write enable
  assign block_buf0_wr = dct_data_valid & ~block_buf_sel;
  assign block_buf1_wr = dct_data_valid &  block_buf_sel;

  // block buffer write enable
  assign block_buf_wr = block_buf0_wr | block_buf1_wr;

  // set to 1 when block buffer 0 is filled with dctx data and ready for read
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf0_rd <= `DLY 1'b0;
      end
      else if (~block_buf_sel & block_buf_wr_done) begin
          block_buf0_rd <= `DLY 1'b1;
      end
      else if (block_buf_sel & block_buf_rd_done) begin
          block_buf0_rd <= `DLY 1'b0;
      end
  end

  // set to 1 when block buffer 1 is filled with dctx data and ready for read
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf1_rd <= `DLY 1'b0;
      end
      else if (block_buf_sel & block_buf_wr_done) begin
          block_buf1_rd <= `DLY 1'b1;
      end
      else if (~block_buf_sel & block_buf_rd_done) begin
          block_buf1_rd <= `DLY 1'b0;
      end
  end

  // block buffer read enable
  assign block_buf_rd = block_buf0_rd | block_buf1_rd;

  // delay block_buf0_rd and block_buf1_rd to sync with read data from buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          block_buf_rd_d <= `DLY 1'b0;
      end
      else begin
          block_buf_rd_d <= `DLY block_buf_rd;
      end
  end

  // block buffer waddr
  assign block_buf0_waddr = {block_buf_wr_cnt[2:0], block_buf_wr_cnt[5:3]};
  assign block_buf1_waddr = {block_buf_wr_cnt[2:0], block_buf_wr_cnt[5:3]};

  // block buffer raddr
  assign block_buf0_raddr = zigzag_addr;
  assign block_buf1_raddr = zigzag_addr;

  // block buffer address
  assign block_buf0_addr = ~block_buf_sel ? block_buf0_waddr : block_buf0_raddr;
  assign block_buf1_addr =  block_buf_sel ? block_buf1_waddr : block_buf1_raddr;

  // block buffer data input
  assign block_buf_din = dct_data;

  // block buffer data output
  assign block_buf_dout = block_buf_sel_d ? block_buf0_dout : block_buf1_dout;

  // zigzag address generate
  always @(*) begin
      case (block_buf_rd_cnt[5:0])
          6'd0   : zigzag_addr = 0 ;
          6'd1   : zigzag_addr = 1 ;
          6'd2   : zigzag_addr = 8 ;
          6'd3   : zigzag_addr = 16;
          6'd4   : zigzag_addr = 9 ;
          6'd5   : zigzag_addr = 2 ;
          6'd6   : zigzag_addr = 3 ;
          6'd7   : zigzag_addr = 10;
          6'd8   : zigzag_addr = 17;
          6'd9   : zigzag_addr = 24;
          6'd10  : zigzag_addr = 32;
          6'd11  : zigzag_addr = 25;
          6'd12  : zigzag_addr = 18;
          6'd13  : zigzag_addr = 11;
          6'd14  : zigzag_addr = 4 ;
          6'd15  : zigzag_addr = 5 ;
          6'd16  : zigzag_addr = 12;
          6'd17  : zigzag_addr = 19;
          6'd18  : zigzag_addr = 26;
          6'd19  : zigzag_addr = 33;
          6'd20  : zigzag_addr = 40;
          6'd21  : zigzag_addr = 48;
          6'd22  : zigzag_addr = 41;
          6'd23  : zigzag_addr = 34;
          6'd24  : zigzag_addr = 27;
          6'd25  : zigzag_addr = 20;
          6'd26  : zigzag_addr = 13;
          6'd27  : zigzag_addr = 6 ;
          6'd28  : zigzag_addr = 7 ;
          6'd29  : zigzag_addr = 14;
          6'd30  : zigzag_addr = 21;
          6'd31  : zigzag_addr = 28;
          6'd32  : zigzag_addr = 35;
          6'd33  : zigzag_addr = 42;
          6'd34  : zigzag_addr = 49;
          6'd35  : zigzag_addr = 56;
          6'd36  : zigzag_addr = 57;
          6'd37  : zigzag_addr = 50;
          6'd38  : zigzag_addr = 43;
          6'd39  : zigzag_addr = 36;
          6'd40  : zigzag_addr = 29;
          6'd41  : zigzag_addr = 22;
          6'd42  : zigzag_addr = 15;
          6'd43  : zigzag_addr = 23;
          6'd44  : zigzag_addr = 30;
          6'd45  : zigzag_addr = 37;
          6'd46  : zigzag_addr = 44;
          6'd47  : zigzag_addr = 51;
          6'd48  : zigzag_addr = 58;
          6'd49  : zigzag_addr = 59;
          6'd50  : zigzag_addr = 52;
          6'd51  : zigzag_addr = 45;
          6'd52  : zigzag_addr = 38;
          6'd53  : zigzag_addr = 31;
          6'd54  : zigzag_addr = 39;
          6'd55  : zigzag_addr = 46;
          6'd56  : zigzag_addr = 53;
          6'd57  : zigzag_addr = 60;
          6'd58  : zigzag_addr = 61;
          6'd59  : zigzag_addr = 54;
          6'd60  : zigzag_addr = 47;
          6'd61  : zigzag_addr = 55;
          6'd62  : zigzag_addr = 62;
          default: zigzag_addr = 63;
      endcase
  end

//--------------------------------------------
//    output signals
//--------------------------------------------

  assign zigzag_data       = block_buf_dout;
  assign zigzag_data_valid = block_buf_rd_d;

//--------------------------------------------
//    block buffer instances
//--------------------------------------------

  zigzag_buf zigzag_buf_u0 (
    .clk        (clk              ),
    .wea        (block_buf0_wr    ),
    .addra      (block_buf0_addr  ),
    .din        (block_buf_din    ),
    .dout       (block_buf0_dout  ) 
    );

  zigzag_buf zigzag_buf_u1 (
    .clk        (clk              ),
    .wea        (block_buf1_wr    ),
    .addra      (block_buf1_addr  ),
    .din        (block_buf_din    ),
    .dout       (block_buf1_dout  ) 
    );

endmodule
