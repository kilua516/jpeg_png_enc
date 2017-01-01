`define DLY (#1)

module ac_chr_huffman(
    // input coeff and run length
    extra_bits      , // <i>  4b, extra bits count
    run_length      , // <i>  4b, run length
    // output huffman code and length
    code            , // <o> 16b, huffman code
    length            // <o>  5b, huffman code length
    );

  // input coeff and run length
  input  [3:0]  extra_bits      ; // <i>  4b, extra bits count
  input  [3:0]  run_length      ; // <i>  4b, run length
  // output huffman code and length
  output [15:0] code            ; // <o> 16b, huffman code
  output [4:0]  length          ; // <o>  5b, huffman code length

  reg    [20:0] huffman_lut     ;

  // huffman code lut
  always @(*) begin
      case ({run_length, extra_bits})
        8'h00  : huffman_lut = {5'd2 , 16'h0000};       // 0/0(EOB) 00
        8'h01  : huffman_lut = {5'd2 , 16'h0001};       // 0/1      01
        8'h02  : huffman_lut = {5'd3 , 16'h0004};       // 0/2      100
        8'h03  : huffman_lut = {5'd4 , 16'h000A};       // 0/3      1010
        8'h04  : huffman_lut = {5'd5 , 16'h0018};       // 0/4      11000
        8'h05  : huffman_lut = {5'd5 , 16'h0019};       // 0/5      11001
        8'h06  : huffman_lut = {5'd6 , 16'h0038};       // 0/6      111000
        8'h07  : huffman_lut = {5'd7 , 16'h0078};       // 0/7      1111000
        8'h08  : huffman_lut = {5'd9 , 16'h01F4};       // 0/8      111110100
        8'h09  : huffman_lut = {5'd10, 16'h03F6};       // 0/9      1111110110
        8'h0A  : huffman_lut = {5'd12, 16'h0FF4};       // 0/A      111111110100
        8'h11  : huffman_lut = {5'd4 , 16'h000B};       // 1/1      1011
        8'h12  : huffman_lut = {5'd6 , 16'h0039};       // 1/2      111001
        8'h13  : huffman_lut = {5'd8 , 16'h00F6};       // 1/3      11110110
        8'h14  : huffman_lut = {5'd9 , 16'h01F5};       // 1/4      111110101
        8'h15  : huffman_lut = {5'd11, 16'h07F6};       // 1/5      11111110110
        8'h16  : huffman_lut = {5'd12, 16'h0FF5};       // 1/6      111111110101
        8'h17  : huffman_lut = {5'd16, 16'hFF88};       // 1/7      1111111110001000
        8'h18  : huffman_lut = {5'd16, 16'hFF89};       // 1/8      1111111110001001
        8'h19  : huffman_lut = {5'd16, 16'hFF8A};       // 1/9      1111111110001010
        8'h1A  : huffman_lut = {5'd16, 16'hFF8B};       // 1/A      1111111110001011
        8'h21  : huffman_lut = {5'd5 , 16'h001A};       // 2/1      11010
        8'h22  : huffman_lut = {5'd8 , 16'h00F7};       // 2/2      11110111
        8'h23  : huffman_lut = {5'd10, 16'h03F7};       // 2/3      1111110111
        8'h24  : huffman_lut = {5'd12, 16'h0FF6};       // 2/4      111111110110
        8'h25  : huffman_lut = {5'd15, 16'h7FC2};       // 2/5      111111111000010
        8'h26  : huffman_lut = {5'd16, 16'hFF8C};       // 2/6      1111111110001100
        8'h27  : huffman_lut = {5'd16, 16'hFF8D};       // 2/7      1111111110001101
        8'h28  : huffman_lut = {5'd16, 16'hFF8E};       // 2/8      1111111110001110
        8'h29  : huffman_lut = {5'd16, 16'hFF8F};       // 2/9      1111111110001111
        8'h2A  : huffman_lut = {5'd16, 16'hFF90};       // 2/A      1111111110010000
        8'h31  : huffman_lut = {5'd5 , 16'h001B};       // 3/1      11011
        8'h32  : huffman_lut = {5'd8 , 16'h00F8};       // 3/2      11111000
        8'h33  : huffman_lut = {5'd10, 16'h03F8};       // 3/3      1111111000
        8'h34  : huffman_lut = {5'd12, 16'h0FF7};       // 3/4      111111110111
        8'h35  : huffman_lut = {5'd16, 16'hFF91};       // 3/5      1111111110010001
        8'h36  : huffman_lut = {5'd16, 16'hFF92};       // 3/6      1111111110010010
        8'h37  : huffman_lut = {5'd16, 16'hFF93};       // 3/7      1111111110010011
        8'h38  : huffman_lut = {5'd16, 16'hFF94};       // 3/8      1111111110010100
        8'h39  : huffman_lut = {5'd16, 16'hFF95};       // 3/9      1111111110010101
        8'h3A  : huffman_lut = {5'd16, 16'hFF96};       // 3/A      1111111110010110
        8'h41  : huffman_lut = {5'd6 , 16'h003A};       // 4/1      111010
        8'h42  : huffman_lut = {5'd9 , 16'h01F6};       // 4/2      111110110
        8'h43  : huffman_lut = {5'd16, 16'hFF97};       // 4/3      1111111110010111
        8'h44  : huffman_lut = {5'd16, 16'hFF98};       // 4/4      1111111110011000
        8'h45  : huffman_lut = {5'd16, 16'hFF99};       // 4/5      1111111110011001
        8'h46  : huffman_lut = {5'd16, 16'hFF9A};       // 4/6      1111111110011010
        8'h47  : huffman_lut = {5'd16, 16'hFF9B};       // 4/7      1111111110011011
        8'h48  : huffman_lut = {5'd16, 16'hFF9C};       // 4/8      1111111110011100
        8'h49  : huffman_lut = {5'd16, 16'hFF9D};       // 4/9      1111111110011101
        8'h4A  : huffman_lut = {5'd16, 16'hFF9E};       // 4/A      1111111110011110
        8'h51  : huffman_lut = {5'd6 , 16'h003B};       // 5/1      111011
        8'h52  : huffman_lut = {5'd10, 16'h03F9};       // 5/2      1111111001
        8'h53  : huffman_lut = {5'd16, 16'hFF9F};       // 5/3      1111111110011111
        8'h54  : huffman_lut = {5'd16, 16'hFFA0};       // 5/4      1111111110100000
        8'h55  : huffman_lut = {5'd16, 16'hFFA1};       // 5/5      1111111110100001
        8'h56  : huffman_lut = {5'd16, 16'hFFA2};       // 5/6      1111111110100010
        8'h57  : huffman_lut = {5'd16, 16'hFFA3};       // 5/7      1111111110100011
        8'h58  : huffman_lut = {5'd16, 16'hFFA4};       // 5/8      1111111110100100
        8'h59  : huffman_lut = {5'd16, 16'hFFA5};       // 5/9      1111111110100101
        8'h5A  : huffman_lut = {5'd16, 16'hFFA6};       // 5/A      1111111110100110
        8'h61  : huffman_lut = {5'd7 , 16'h0079};       // 6/1      1111001
        8'h62  : huffman_lut = {5'd11, 16'h07F7};       // 6/2      11111110111
        8'h63  : huffman_lut = {5'd16, 16'hFFA7};       // 6/3      1111111110100111
        8'h64  : huffman_lut = {5'd16, 16'hFFA8};       // 6/4      1111111110101000
        8'h65  : huffman_lut = {5'd16, 16'hFFA9};       // 6/5      1111111110101001
        8'h66  : huffman_lut = {5'd16, 16'hFFAA};       // 6/6      1111111110101010
        8'h67  : huffman_lut = {5'd16, 16'hFFAB};       // 6/7      1111111110101011
        8'h68  : huffman_lut = {5'd16, 16'hFFAC};       // 6/8      1111111110101100
        8'h69  : huffman_lut = {5'd16, 16'hFFAD};       // 6/9      1111111110101101
        8'h6A  : huffman_lut = {5'd16, 16'hFFAE};       // 6/A      1111111110101110
        8'h71  : huffman_lut = {5'd7 , 16'h007A};       // 7/1      1111010
        8'h72  : huffman_lut = {5'd11, 16'h07F8};       // 7/2      11111111000
        8'h73  : huffman_lut = {5'd16, 16'hFFAF};       // 7/3      1111111110101111
        8'h74  : huffman_lut = {5'd16, 16'hFFB0};       // 7/4      1111111110110000
        8'h75  : huffman_lut = {5'd16, 16'hFFB1};       // 7/5      1111111110110001
        8'h76  : huffman_lut = {5'd16, 16'hFFB2};       // 7/6      1111111110110010
        8'h77  : huffman_lut = {5'd16, 16'hFFB3};       // 7/7      1111111110110011
        8'h78  : huffman_lut = {5'd16, 16'hFFB4};       // 7/8      1111111110110100
        8'h79  : huffman_lut = {5'd16, 16'hFFB5};       // 7/9      1111111110110101
        8'h7A  : huffman_lut = {5'd16, 16'hFFB6};       // 7/A      1111111110110110
        8'h81  : huffman_lut = {5'd8 , 16'h00F9};       // 8/1      11111001
        8'h82  : huffman_lut = {5'd16, 16'hFFB7};       // 8/2      1111111110110111
        8'h83  : huffman_lut = {5'd16, 16'hFFB8};       // 8/3      1111111110111000
        8'h84  : huffman_lut = {5'd16, 16'hFFB9};       // 8/4      1111111110111001
        8'h85  : huffman_lut = {5'd16, 16'hFFBA};       // 8/5      1111111110111010
        8'h86  : huffman_lut = {5'd16, 16'hFFBB};       // 8/6      1111111110111011
        8'h87  : huffman_lut = {5'd16, 16'hFFBC};       // 8/7      1111111110111100
        8'h88  : huffman_lut = {5'd16, 16'hFFBD};       // 8/8      1111111110111101
        8'h89  : huffman_lut = {5'd16, 16'hFFBE};       // 8/9      1111111110111110
        8'h8A  : huffman_lut = {5'd16, 16'hFFBF};       // 8/A      1111111110111111
        8'h91  : huffman_lut = {5'd9 , 16'h01F7};       // 9/1      111110111
        8'h92  : huffman_lut = {5'd16, 16'hFFC0};       // 9/2      1111111111000000
        8'h93  : huffman_lut = {5'd16, 16'hFFC1};       // 9/3      1111111111000001
        8'h94  : huffman_lut = {5'd16, 16'hFFC2};       // 9/4      1111111111000010
        8'h95  : huffman_lut = {5'd16, 16'hFFC3};       // 9/5      1111111111000011
        8'h96  : huffman_lut = {5'd16, 16'hFFC4};       // 9/6      1111111111000100
        8'h97  : huffman_lut = {5'd16, 16'hFFC5};       // 9/7      1111111111000101
        8'h98  : huffman_lut = {5'd16, 16'hFFC6};       // 9/8      1111111111000110
        8'h99  : huffman_lut = {5'd16, 16'hFFC7};       // 9/9      1111111111000111
        8'h9A  : huffman_lut = {5'd16, 16'hFFC8};       // 9/A      1111111111001000
        8'hA1  : huffman_lut = {5'd9 , 16'h01F8};       // A/1      111111000
        8'hA2  : huffman_lut = {5'd16, 16'hFFC9};       // A/2      1111111111001001
        8'hA3  : huffman_lut = {5'd16, 16'hFFCA};       // A/3      1111111111001010
        8'hA4  : huffman_lut = {5'd16, 16'hFFCB};       // A/4      1111111111001011
        8'hA5  : huffman_lut = {5'd16, 16'hFFCC};       // A/5      1111111111001100
        8'hA6  : huffman_lut = {5'd16, 16'hFFCD};       // A/6      1111111111001101
        8'hA7  : huffman_lut = {5'd16, 16'hFFCE};       // A/7      1111111111001110
        8'hA8  : huffman_lut = {5'd16, 16'hFFCF};       // A/8      1111111111001111
        8'hA9  : huffman_lut = {5'd16, 16'hFFD0};       // A/9      1111111111010000
        8'hAA  : huffman_lut = {5'd16, 16'hFFD1};       // A/A      1111111111010001
        8'hB1  : huffman_lut = {5'd9 , 16'h01F9};       // B/1      111111001
        8'hB2  : huffman_lut = {5'd16, 16'hFFD2};       // B/2      1111111111010010
        8'hB3  : huffman_lut = {5'd16, 16'hFFD3};       // B/3      1111111111010011
        8'hB4  : huffman_lut = {5'd16, 16'hFFD4};       // B/4      1111111111010100
        8'hB5  : huffman_lut = {5'd16, 16'hFFD5};       // B/5      1111111111010101
        8'hB6  : huffman_lut = {5'd16, 16'hFFD6};       // B/6      1111111111010110
        8'hB7  : huffman_lut = {5'd16, 16'hFFD7};       // B/7      1111111111010111
        8'hB8  : huffman_lut = {5'd16, 16'hFFD8};       // B/8      1111111111011000
        8'hB9  : huffman_lut = {5'd16, 16'hFFD9};       // B/9      1111111111011001
        8'hBA  : huffman_lut = {5'd16, 16'hFFDA};       // B/A      1111111111011010
        8'hC1  : huffman_lut = {5'd9 , 16'h01FA};       // C/1      111111010
        8'hC2  : huffman_lut = {5'd16, 16'hFFDB};       // C/2      1111111111011011
        8'hC3  : huffman_lut = {5'd16, 16'hFFDC};       // C/3      1111111111011100
        8'hC4  : huffman_lut = {5'd16, 16'hFFDD};       // C/4      1111111111011101
        8'hC5  : huffman_lut = {5'd16, 16'hFFDE};       // C/5      1111111111011110
        8'hC6  : huffman_lut = {5'd16, 16'hFFDF};       // C/6      1111111111011111
        8'hC7  : huffman_lut = {5'd16, 16'hFFE0};       // C/7      1111111111100000
        8'hC8  : huffman_lut = {5'd16, 16'hFFE1};       // C/8      1111111111100001
        8'hC9  : huffman_lut = {5'd16, 16'hFFE2};       // C/9      1111111111100010
        8'hCA  : huffman_lut = {5'd16, 16'hFFE3};       // C/A      1111111111100011
        8'hD1  : huffman_lut = {5'd11, 16'h07F9};       // D/1      11111111001
        8'hD2  : huffman_lut = {5'd16, 16'hFFE4};       // D/2      1111111111100100
        8'hD3  : huffman_lut = {5'd16, 16'hFFE5};       // D/3      1111111111100101
        8'hD4  : huffman_lut = {5'd16, 16'hFFE6};       // D/4      1111111111100110
        8'hD5  : huffman_lut = {5'd16, 16'hFFE7};       // D/5      1111111111100111
        8'hD6  : huffman_lut = {5'd16, 16'hFFE8};       // D/6      1111111111101000
        8'hD7  : huffman_lut = {5'd16, 16'hFFE9};       // D/7      1111111111101001
        8'hD8  : huffman_lut = {5'd16, 16'hFFEA};       // D/8      1111111111101010
        8'hD9  : huffman_lut = {5'd16, 16'hFFEB};       // D/9      1111111111101011
        8'hDA  : huffman_lut = {5'd16, 16'hFFEC};       // D/A      1111111111101100
        8'hE1  : huffman_lut = {5'd14, 16'h3FE0};       // E/1      11111111100000
        8'hE2  : huffman_lut = {5'd16, 16'hFFED};       // E/2      1111111111101101
        8'hE3  : huffman_lut = {5'd16, 16'hFFEE};       // E/3      1111111111101110
        8'hE4  : huffman_lut = {5'd16, 16'hFFEF};       // E/4      1111111111101111
        8'hE5  : huffman_lut = {5'd16, 16'hFFF0};       // E/5      1111111111110000
        8'hE6  : huffman_lut = {5'd16, 16'hFFF1};       // E/6      1111111111110001
        8'hE7  : huffman_lut = {5'd16, 16'hFFF2};       // E/7      1111111111110010
        8'hE8  : huffman_lut = {5'd16, 16'hFFF3};       // E/8      1111111111110011
        8'hE9  : huffman_lut = {5'd16, 16'hFFF4};       // E/9      1111111111110100
        8'hEA  : huffman_lut = {5'd16, 16'hFFF5};       // E/A      1111111111110101
        8'hF0  : huffman_lut = {5'd10, 16'h03FA};       // F/0(ZRL) 1111111010
        8'hF1  : huffman_lut = {5'd15, 16'h7FC3};       // F/1      111111111000011
        8'hF2  : huffman_lut = {5'd16, 16'hFFF6};       // F/2      1111111111110110
        8'hF3  : huffman_lut = {5'd16, 16'hFFF7};       // F/3      1111111111110111
        8'hF4  : huffman_lut = {5'd16, 16'hFFF8};       // F/4      1111111111111000
        8'hF5  : huffman_lut = {5'd16, 16'hFFF9};       // F/5      1111111111111001
        8'hF6  : huffman_lut = {5'd16, 16'hFFFA};       // F/6      1111111111111010
        8'hF7  : huffman_lut = {5'd16, 16'hFFFB};       // F/7      1111111111111011
        8'hF8  : huffman_lut = {5'd16, 16'hFFFC};       // F/8      1111111111111100
        8'hF9  : huffman_lut = {5'd16, 16'hFFFD};       // F/9      1111111111111101
        8'hFA  : huffman_lut = {5'd16, 16'hFFFE};       // F/A      1111111111111110
        default: huffman_lut = {5'd1 , 16'hFFFF};
      endcase
  end

  assign code   = huffman_lut[15:0];
  assign length = huffman_lut[20:16];

endmodule
