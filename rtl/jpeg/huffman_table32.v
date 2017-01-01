`define DLY #1

module huffman_table32(
    clk         , // <i>  1b, global clock
    rd_en       , // <i>  1b, read enable
    rd_addr     , // <i>  7b, read addrss
    dout          // <o> 32b, table output
    );

  input         clk         ; // <i>  1b, global clock
  input         rd_en       ; // <i>  1b, read enable
  input  [6:0]  rd_addr     ; // <i>  7b, read addrss
  output [31:0] dout        ; // <o> 32b, table output

  reg    [31:0] dout        ;

  always @(posedge clk) begin
      if (rd_en) begin
          case (rd_addr)
              7'h00  : dout <= `DLY 32'h00000105;
              7'h01  : dout <= `DLY 32'h01010101;
              7'h02  : dout <= `DLY 32'h01010000;
              7'h03  : dout <= `DLY 32'h00000000;
              7'h04  : dout <= `DLY 32'h00000102;
              7'h05  : dout <= `DLY 32'h03040506;
              7'h06  : dout <= `DLY 32'h0708090a;
              7'h07  : dout <= `DLY 32'h0b010003;
              7'h08  : dout <= `DLY 32'h01010101;
              7'h09  : dout <= `DLY 32'h01010101;
              7'h0A  : dout <= `DLY 32'h01000000;
              7'h0B  : dout <= `DLY 32'h00000001;
              7'h0C  : dout <= `DLY 32'h02030405;
              7'h0D  : dout <= `DLY 32'h06070809;
              7'h0E  : dout <= `DLY 32'h0a0b1000;
              7'h0F  : dout <= `DLY 32'h02010303;
              7'h10  : dout <= `DLY 32'h02040305;
              7'h11  : dout <= `DLY 32'h05040400;
              7'h12  : dout <= `DLY 32'h00017d01;
              7'h13  : dout <= `DLY 32'h02030004;
              7'h14  : dout <= `DLY 32'h11051221;
              7'h15  : dout <= `DLY 32'h31410613;
              7'h16  : dout <= `DLY 32'h51610722;
              7'h17  : dout <= `DLY 32'h71143281;
              7'h18  : dout <= `DLY 32'h91a10823;
              7'h19  : dout <= `DLY 32'h42b1c115;
              7'h1A  : dout <= `DLY 32'h52d1f024;
              7'h1B  : dout <= `DLY 32'h33627282;
              7'h1C  : dout <= `DLY 32'h090a1617;
              7'h1D  : dout <= `DLY 32'h18191a25;
              7'h1E  : dout <= `DLY 32'h26272829;
              7'h1F  : dout <= `DLY 32'h2a343536;
              7'h20  : dout <= `DLY 32'h3738393a;
              7'h21  : dout <= `DLY 32'h43444546;
              7'h22  : dout <= `DLY 32'h4748494a;
              7'h23  : dout <= `DLY 32'h53545556;
              7'h24  : dout <= `DLY 32'h5758595a;
              7'h25  : dout <= `DLY 32'h63646566;
              7'h26  : dout <= `DLY 32'h6768696a;
              7'h27  : dout <= `DLY 32'h73747576;
              7'h28  : dout <= `DLY 32'h7778797a;
              7'h29  : dout <= `DLY 32'h83848586;
              7'h2A  : dout <= `DLY 32'h8788898a;
              7'h2B  : dout <= `DLY 32'h92939495;
              7'h2C  : dout <= `DLY 32'h96979899;
              7'h2D  : dout <= `DLY 32'h9aa2a3a4;
              7'h2E  : dout <= `DLY 32'ha5a6a7a8;
              7'h2F  : dout <= `DLY 32'ha9aab2b3;
              7'h30  : dout <= `DLY 32'hb4b5b6b7;
              7'h31  : dout <= `DLY 32'hb8b9bac2;
              7'h32  : dout <= `DLY 32'hc3c4c5c6;
              7'h33  : dout <= `DLY 32'hc7c8c9ca;
              7'h34  : dout <= `DLY 32'hd2d3d4d5;
              7'h35  : dout <= `DLY 32'hd6d7d8d9;
              7'h36  : dout <= `DLY 32'hdae1e2e3;
              7'h37  : dout <= `DLY 32'he4e5e6e7;
              7'h38  : dout <= `DLY 32'he8e9eaf1;
              7'h39  : dout <= `DLY 32'hf2f3f4f5;
              7'h3A  : dout <= `DLY 32'hf6f7f8f9;
              7'h3B  : dout <= `DLY 32'hfa110002;
              7'h3C  : dout <= `DLY 32'h01020404;
              7'h3D  : dout <= `DLY 32'h03040705;
              7'h3E  : dout <= `DLY 32'h04040001;
              7'h3F  : dout <= `DLY 32'h02770001;
              7'h40  : dout <= `DLY 32'h02031104;
              7'h41  : dout <= `DLY 32'h05213106;
              7'h42  : dout <= `DLY 32'h12415107;
              7'h43  : dout <= `DLY 32'h61711322;
              7'h44  : dout <= `DLY 32'h32810814;
              7'h45  : dout <= `DLY 32'h4291a1b1;
              7'h46  : dout <= `DLY 32'hc1092333;
              7'h47  : dout <= `DLY 32'h52f01562;
              7'h48  : dout <= `DLY 32'h72d10a16;
              7'h49  : dout <= `DLY 32'h2434e125;
              7'h4A  : dout <= `DLY 32'hf1171819;
              7'h4B  : dout <= `DLY 32'h1a262728;
              7'h4C  : dout <= `DLY 32'h292a3536;
              7'h4D  : dout <= `DLY 32'h3738393a;
              7'h4E  : dout <= `DLY 32'h43444546;
              7'h4F  : dout <= `DLY 32'h4748494a;
              7'h50  : dout <= `DLY 32'h53545556;
              7'h51  : dout <= `DLY 32'h5758595a;
              7'h52  : dout <= `DLY 32'h63646566;
              7'h53  : dout <= `DLY 32'h6768696a;
              7'h54  : dout <= `DLY 32'h73747576;
              7'h55  : dout <= `DLY 32'h7778797a;
              7'h56  : dout <= `DLY 32'h82838485;
              7'h57  : dout <= `DLY 32'h86878889;
              7'h58  : dout <= `DLY 32'h8a929394;
              7'h59  : dout <= `DLY 32'h95969798;
              7'h5A  : dout <= `DLY 32'h999aa2a3;
              7'h5B  : dout <= `DLY 32'ha4a5a6a7;
              7'h5C  : dout <= `DLY 32'ha8a9aab2;
              7'h5D  : dout <= `DLY 32'hb3b4b5b6;
              7'h5E  : dout <= `DLY 32'hb7b8b9ba;
              7'h5F  : dout <= `DLY 32'hc2c3c4c5;
              7'h60  : dout <= `DLY 32'hc6c7c8c9;
              7'h61  : dout <= `DLY 32'hcad2d3d4;
              7'h62  : dout <= `DLY 32'hd5d6d7d8;
              7'h63  : dout <= `DLY 32'hd9dae2e3;
              7'h64  : dout <= `DLY 32'he4e5e6e7;
              7'h65  : dout <= `DLY 32'he8e9eaf2;
              7'h66  : dout <= `DLY 32'hf3f4f5f6;
              default: dout <= `DLY 32'hf7f8f9fa;
          endcase
      end
  end

endmodule
