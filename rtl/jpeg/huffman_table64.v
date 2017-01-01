`define DLY #1

module huffman_table64(
    clk         , // <i>  1b, global clock
    rd_en       , // <i>  1b, read enable
    rd_addr     , // <i>  6b, read addrss
    dout          // <o> 64b, table output
    );

  input         clk         ; // <i>  1b, global clock
  input         rd_en       ; // <i>  1b, read enable
  input  [5:0]  rd_addr     ; // <i>  6b, read addrss
  output [63:0] dout        ; // <o> 64b, table output

  reg    [63:0] dout        ;

  always @(posedge clk) begin
      if (rd_en) begin
          case (rd_addr)
              6'h00  : dout <= `DLY 64'h0000010501010101;
              6'h01  : dout <= `DLY 64'h0101000000000000;
              6'h02  : dout <= `DLY 64'h0000010203040506;
              6'h03  : dout <= `DLY 64'h0708090a0b010003;
              6'h04  : dout <= `DLY 64'h0101010101010101;
              6'h05  : dout <= `DLY 64'h0100000000000001;
              6'h06  : dout <= `DLY 64'h0203040506070809;
              6'h07  : dout <= `DLY 64'h0a0b100002010303;
              6'h08  : dout <= `DLY 64'h0204030505040400;
              6'h09  : dout <= `DLY 64'h00017d0102030004;
              6'h0A  : dout <= `DLY 64'h1105122131410613;
              6'h0B  : dout <= `DLY 64'h5161072271143281;
              6'h0C  : dout <= `DLY 64'h91a1082342b1c115;
              6'h0D  : dout <= `DLY 64'h52d1f02433627282;
              6'h0E  : dout <= `DLY 64'h090a161718191a25;
              6'h0F  : dout <= `DLY 64'h262728292a343536;
              6'h10  : dout <= `DLY 64'h3738393a43444546;
              6'h11  : dout <= `DLY 64'h4748494a53545556;
              6'h12  : dout <= `DLY 64'h5758595a63646566;
              6'h13  : dout <= `DLY 64'h6768696a73747576;
              6'h14  : dout <= `DLY 64'h7778797a83848586;
              6'h15  : dout <= `DLY 64'h8788898a92939495;
              6'h16  : dout <= `DLY 64'h969798999aa2a3a4;
              6'h17  : dout <= `DLY 64'ha5a6a7a8a9aab2b3;
              6'h18  : dout <= `DLY 64'hb4b5b6b7b8b9bac2;
              6'h19  : dout <= `DLY 64'hc3c4c5c6c7c8c9ca;
              6'h1A  : dout <= `DLY 64'hd2d3d4d5d6d7d8d9;
              6'h1B  : dout <= `DLY 64'hdae1e2e3e4e5e6e7;
              6'h1C  : dout <= `DLY 64'he8e9eaf1f2f3f4f5;
              6'h1D  : dout <= `DLY 64'hf6f7f8f9fa110002;
              6'h1E  : dout <= `DLY 64'h0102040403040705;
              6'h1F  : dout <= `DLY 64'h0404000102770001;
              6'h20  : dout <= `DLY 64'h0203110405213106;
              6'h21  : dout <= `DLY 64'h1241510761711322;
              6'h22  : dout <= `DLY 64'h328108144291a1b1;
              6'h23  : dout <= `DLY 64'hc109233352f01562;
              6'h24  : dout <= `DLY 64'h72d10a162434e125;
              6'h25  : dout <= `DLY 64'hf11718191a262728;
              6'h26  : dout <= `DLY 64'h292a35363738393a;
              6'h27  : dout <= `DLY 64'h434445464748494a;
              6'h28  : dout <= `DLY 64'h535455565758595a;
              6'h29  : dout <= `DLY 64'h636465666768696a;
              6'h2A  : dout <= `DLY 64'h737475767778797a;
              6'h2B  : dout <= `DLY 64'h8283848586878889;
              6'h2C  : dout <= `DLY 64'h8a92939495969798;
              6'h2D  : dout <= `DLY 64'h999aa2a3a4a5a6a7;
              6'h2E  : dout <= `DLY 64'ha8a9aab2b3b4b5b6;
              6'h2F  : dout <= `DLY 64'hb7b8b9bac2c3c4c5;
              6'h30  : dout <= `DLY 64'hc6c7c8c9cad2d3d4;
              6'h31  : dout <= `DLY 64'hd5d6d7d8d9dae2e3;
              6'h32  : dout <= `DLY 64'he4e5e6e7e8e9eaf2;
              default: dout <= `DLY 64'hf3f4f5f6f7f8f9fa;
          endcase
      end
  end

endmodule
