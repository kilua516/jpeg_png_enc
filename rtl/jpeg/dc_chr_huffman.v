`define DLY (#1)

module dc_chr_huffman(
    // input coeff and run length
    extra_bits      , // <i>  4b, extra bits count
    // output huffman code and length
    code            , // <o> 16b, huffman code
    length            // <o>  5b, huffman code length
    );

  // input coeff and run length
  input  [3:0]  extra_bits      ; // <i>  4b, extra bits count
  // output huffman code and length
  output [15:0] code            ; // <o> 16b, huffman code
  output [4:0]  length          ; // <o>  5b, huffman code length

  reg    [20:0] huffman_lut     ;

  // huffman code lut
  always @(*) begin
      case (extra_bits)
        4'h0   : huffman_lut = {5'd2 , 16'h0000};       // 00
        4'h1   : huffman_lut = {5'd2 , 16'h0001};       // 01
        4'h2   : huffman_lut = {5'd2 , 16'h0002};       // 10
        4'h3   : huffman_lut = {5'd3 , 16'h0006};       // 110
        4'h4   : huffman_lut = {5'd4 , 16'h000E};       // 1110
        4'h5   : huffman_lut = {5'd5 , 16'h001E};       // 11110
        4'h6   : huffman_lut = {5'd6 , 16'h003E};       // 111110
        4'h7   : huffman_lut = {5'd7 , 16'h007E};       // 1111110
        4'h8   : huffman_lut = {5'd8 , 16'h00FE};       // 11111110
        4'h9   : huffman_lut = {5'd9 , 16'h01FE};       // 111111110
        4'ha   : huffman_lut = {5'd10, 16'h03FE};       // 1111111110
        4'hb   : huffman_lut = {5'd11, 16'h07FE};       // 11111111110
        default: huffman_lut = {5'd1 , 16'hFFFF};
      endcase
  end

  assign code   = huffman_lut[15:0];
  assign length = huffman_lut[20:16];

endmodule
