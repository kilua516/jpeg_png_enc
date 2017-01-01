`define DLY #1

module fifo(
    // global
    clk               , // <i>  1b, global clock
    rstn              , // <i>  1b, global reset, active low
    // fifo wr
    wr                , // <i>  1b, fifo write enable
    din               , // <i>    , fifo data input
    full              , // <o>  1b, fifo full indicator
    // fifo rd
    rd                , // <o>  1b, fifo read enable
    dout              , // <o>    , fifo data output
    empty               // <o>  1b, fifo empty indicator
    );

  parameter FIFO_DW    = 8;
  parameter FIFO_AW    = 5;
  parameter FIFO_DEPTH = 32;

  // global
  input                 clk   ; // <i>  1b, global clock
  input                 rstn  ; // <i>  1b, global reset, active low
  // fifo wr
  input                 wr    ; // <i>  1b, fifo write enable
  input  [FIFO_DW-1:0]  din   ; // <i>    , fifo data input
  output                full  ; // <o>  1b, fifo full indicator
  // fifo rd
  output                rd    ; // <o>  1b, fifo read enable
  output [FIFO_DW-1:0]  dout  ; // <o>    , fifo data output
  output                empty ; // <o>  1b, fifo empty indicator

  reg [FIFO_DW-1:0] mem[0:FIFO_DEPTH-1];
  reg [FIFO_AW-1:0] fifo_wptr;
  reg [FIFO_AW-1:0] fifo_rptr;
  reg [FIFO_AW:0]   fifo_count;

  assign wr_valid = wr & ~full ;
  assign rd_valid = rd & ~empty;

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          fifo_wptr  <= `DLY 0;
          fifo_rptr  <= `DLY 0;
          fifo_count <= `DLY 0;
      end
      else if (wr_valid & rd_valid) begin
          fifo_wptr  <= `DLY fifo_wptr + 1;
          fifo_rptr  <= `DLY fifo_rptr + 1;
          fifo_count <= `DLY fifo_count;
      end
      else if (wr_valid) begin
          fifo_wptr  <= `DLY fifo_wptr + 1;
          fifo_rptr  <= `DLY fifo_rptr;
          fifo_count <= `DLY fifo_count + 1;
      end
      else if (rd_valid) begin
          fifo_wptr  <= `DLY fifo_wptr;
          fifo_rptr  <= `DLY fifo_rptr + 1;
          fifo_count <= `DLY fifo_count - 1;
      end
  end

  assign full  = (fifo_count == FIFO_DEPTH);
  assign empty = (fifo_count == 0);

  always @(posedge clk) begin
      if (wr_valid) begin
          mem[fifo_wptr] <= `DLY din;
      end
  end

  assign dout = mem[fifo_rptr];

  always @(posedge clk) begin
      if (wr & full) begin
          $display("%t, Error! write when fifo is full! %u %u", $time, FIFO_DW, FIFO_DEPTH);
      end
  end

endmodule
