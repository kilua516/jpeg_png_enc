`define DLY #1

module zigzag_buf(
    clk        ,
    wea        ,
    addra      ,
    din        ,
    dout
    );

  input         clk        ;
  input         wea        ;
  input  [5:0]  addra      ;
  input  [41:0] din        ;
  output [41:0] dout       ;

`ifdef FPGA
  blk_mem_gen_v7_2 #(????) blk_mem_42x64(
    .clka       (clk    ),
    .wea        (wea    ),
    .addra      (addra  ),
    .dina       (din    ),
    .clkb       (clk    ),
    .addrb      (addra  ),
    .doubt      (dout   )
    );

`else
  reg    [41:0] dout       ;

  reg    [41:0] mem[0:63];

  always @(posedge clk) begin
      if (wea) begin
          mem[addra] <= `DLY din;
      end
  end

  always @(posedge clk) begin
      dout <= `DLY mem[addra];
  end
`endif

endmodule
