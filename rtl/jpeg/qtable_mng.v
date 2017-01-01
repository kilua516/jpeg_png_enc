`define DLY #1

module qtable_mng(
    // global
    clk                 , // <i>  1b, global clock
    rstn                , // <i>  1b, global reset, active low
    // qtable interface with jpeg_packing and quantization
    pack_lum_qtable_rd  , // <i>  1b, lum quantization table read enable from jpeg_packing
    pack_chr_qtable_rd  , // <i>  1b, chr quantization table read enable from jpeg_packing
    qnt_lum_qtable_rd   , // <i>  1b, lum quantization table read enable from quantization
    qnt_chr_qtable_rd   , // <i>  1b, chr quantization table read enable from quantization
    lum_qtable_data     , // <o>  8b, quantization table value
    chr_qtable_data     , // <o>  8b, quantization table value
    // qtable interface with external qtable memory
    lum_qtable_rd_ext   , // <o>  1b, lum quantization table read enable to external
    chr_qtable_rd_ext   , // <o>  1b, chr quantization table read enable to external
    lum_qtable_addr_ext , // <o>  6b, lum quantization table read address to external
    chr_qtable_addr_ext , // <o>  6b, chr quantization table read address to external
    lum_qtable_data_ext , // <i>  8b, quantization table value from external
    chr_qtable_data_ext   // <i>  8b, quantization table value from external
    );

  // global
  input         clk                 ; // <i>  1b, global clock
  input         rstn                ; // <i>  1b, global reset, active low
  // qtable interface with jpeg_packing and quantization
  input         pack_lum_qtable_rd  ; // <i>  1b, lum quantization table read enable from jpeg_packing
  input         pack_chr_qtable_rd  ; // <i>  1b, chr quantization table read enable from jpeg_packing
  input         qnt_lum_qtable_rd   ; // <i>  1b, lum quantization table read enable from quantization
  input         qnt_chr_qtable_rd   ; // <i>  1b, chr quantization table read enable from quantization
  output [7:0]  lum_qtable_data     ; // <o>  8b, quantization table value
  output [7:0]  chr_qtable_data     ; // <o>  8b, quantization table value
  // qtable interface with external qtable memory
  output        lum_qtable_rd_ext   ; // <o>  1b, lum quantization table read enable to external
  output        chr_qtable_rd_ext   ; // <o>  1b, chr quantization table read enable to external
  output [5:0]  lum_qtable_addr_ext ; // <o>  6b, lum quantization table read address to external
  output [5:0]  chr_qtable_addr_ext ; // <o>  6b, chr quantization table read address to external
  input  [7:0]  lum_qtable_data_ext ; // <i>  8b, quantization table value from external
  input  [7:0]  chr_qtable_data_ext ; // <i>  8b, quantization table value from external

  wire          qtable_rd_ext       ; // read enable to external qtable memory
  reg    [5:0]  qtable_addr_ext     ; // qtable address to external memory
  reg    [5:0]  qtable_addr_ext_nxt ; // next value of qtable_addr_ext

  // read enable to external qtable memory
  assign qtable_rd_ext = pack_lum_qtable_rd |
                         pack_chr_qtable_rd |
                         qnt_lum_qtable_rd  |
                         qnt_chr_qtable_rd  ;

  // address to external qtable memory
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          qtable_addr_ext <= `DLY 6'h0;
      end
      else if (qtable_rd_ext) begin
          qtable_addr_ext <= `DLY qtable_addr_ext_nxt;
      end
  end

  // zigzag sequence generator
  always @(*) begin
      case (qtable_addr_ext)
          6'd0   : qtable_addr_ext_nxt = 1 ;
          6'd1   : qtable_addr_ext_nxt = 8 ;
          6'd2   : qtable_addr_ext_nxt = 3 ;
          6'd3   : qtable_addr_ext_nxt = 10;
          6'd4   : qtable_addr_ext_nxt = 5 ;
          6'd5   : qtable_addr_ext_nxt = 12;
          6'd6   : qtable_addr_ext_nxt = 7 ;
          6'd7   : qtable_addr_ext_nxt = 14;
          6'd8   : qtable_addr_ext_nxt = 16;
          6'd9   : qtable_addr_ext_nxt = 2 ;
          6'd10  : qtable_addr_ext_nxt = 17;
          6'd11  : qtable_addr_ext_nxt = 4 ;
          6'd12  : qtable_addr_ext_nxt = 19;
          6'd13  : qtable_addr_ext_nxt = 6 ;
          6'd14  : qtable_addr_ext_nxt = 21;
          6'd15  : qtable_addr_ext_nxt = 23;
          6'd16  : qtable_addr_ext_nxt = 9 ;
          6'd17  : qtable_addr_ext_nxt = 24;
          6'd18  : qtable_addr_ext_nxt = 11;
          6'd19  : qtable_addr_ext_nxt = 26;
          6'd20  : qtable_addr_ext_nxt = 13;
          6'd21  : qtable_addr_ext_nxt = 28;
          6'd22  : qtable_addr_ext_nxt = 15;
          6'd23  : qtable_addr_ext_nxt = 30;
          6'd24  : qtable_addr_ext_nxt = 32;
          6'd25  : qtable_addr_ext_nxt = 18;
          6'd26  : qtable_addr_ext_nxt = 33;
          6'd27  : qtable_addr_ext_nxt = 20;
          6'd28  : qtable_addr_ext_nxt = 35;
          6'd29  : qtable_addr_ext_nxt = 22;
          6'd30  : qtable_addr_ext_nxt = 37;
          6'd31  : qtable_addr_ext_nxt = 39;
          6'd32  : qtable_addr_ext_nxt = 25;
          6'd33  : qtable_addr_ext_nxt = 40;
          6'd34  : qtable_addr_ext_nxt = 27;
          6'd35  : qtable_addr_ext_nxt = 42;
          6'd36  : qtable_addr_ext_nxt = 29;
          6'd37  : qtable_addr_ext_nxt = 44;
          6'd38  : qtable_addr_ext_nxt = 31;
          6'd39  : qtable_addr_ext_nxt = 46;
          6'd40  : qtable_addr_ext_nxt = 48;
          6'd41  : qtable_addr_ext_nxt = 34;
          6'd42  : qtable_addr_ext_nxt = 49;
          6'd43  : qtable_addr_ext_nxt = 36;
          6'd44  : qtable_addr_ext_nxt = 51;
          6'd45  : qtable_addr_ext_nxt = 38;
          6'd46  : qtable_addr_ext_nxt = 53;
          6'd47  : qtable_addr_ext_nxt = 55;
          6'd48  : qtable_addr_ext_nxt = 41;
          6'd49  : qtable_addr_ext_nxt = 56;
          6'd50  : qtable_addr_ext_nxt = 43;
          6'd51  : qtable_addr_ext_nxt = 58;
          6'd52  : qtable_addr_ext_nxt = 45;
          6'd53  : qtable_addr_ext_nxt = 60;
          6'd54  : qtable_addr_ext_nxt = 47;
          6'd55  : qtable_addr_ext_nxt = 62;
          6'd56  : qtable_addr_ext_nxt = 57;
          6'd57  : qtable_addr_ext_nxt = 50;
          6'd58  : qtable_addr_ext_nxt = 59;
          6'd59  : qtable_addr_ext_nxt = 52;
          6'd60  : qtable_addr_ext_nxt = 61;
          6'd61  : qtable_addr_ext_nxt = 54;
          6'd62  : qtable_addr_ext_nxt = 63;
          default: qtable_addr_ext_nxt = 0 ;
      endcase
  end

  // address to external qtable memory
  assign lum_qtable_addr_ext = qtable_addr_ext;
  assign chr_qtable_addr_ext = qtable_addr_ext;

  // read enable to external qtable memory
  assign lum_qtable_rd_ext = qtable_rd_ext;
  assign chr_qtable_rd_ext = qtable_rd_ext;

  // qtable data from external qtable memory
  assign lum_qtable_data = lum_qtable_data_ext;
  assign chr_qtable_data = chr_qtable_data_ext;

endmodule
