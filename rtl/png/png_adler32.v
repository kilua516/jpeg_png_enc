`define DLY #1

module png_adler32(
    // global
    clk               , // <i>  1b, global clock
    rstn              , // <i>  1b, global reset, active low
    // adler32 control
    adler32_init      , // <i>  1b, adler32 initial, active high
    // adler32 data input
    data_in           , // <i>  8b, data input
    data_in_vld       , // <i>  1b, data input valid
    // adler32 data output
    adler32_out       , // <o> 32b, adler32 data output
    adler32_out_vld     // <o>  1b, adler32 data output valid
    );

  // global
  input         clk               ; // <i>  1b, global clock
  input         rstn              ; // <i>  1b, global reset, active low
  // adler32 control
  input         adler32_init      ; // <i>  1b, adler32 initial, active high
  // adler32 data input
  input  [7:0]  data_in           ; // <i>  8b, data input
  input         data_in_vld       ; // <i>  1b, data input valid
  // adler32 data output
  output [31:0] adler32_out       ; // <o> 32b, adler32 data output
  output        adler32_out_vld   ; // <o>  1b, adler32 data output valid

  reg           adler32_out_vld   ;
  reg    [31:0] adler32_out       ;

  wire   [15:0] s1                ;
  wire   [16:0] s1_nxt            ;
  wire   [17:0] s1_nxt_m_65521    ;
  wire   [15:0] s1_nxt_mod        ;
  wire   [15:0] s2                ;
  wire   [16:0] s2_nxt            ;
  wire   [17:0] s2_nxt_m_65521    ;
  wire   [15:0] s2_nxt_mod        ;

  wire   [31:0] adler32_out_nxt   ;

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          adler32_out_vld <= `DLY 1'b0;
      end
      else begin
          adler32_out_vld <= `DLY data_in_vld;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          adler32_out <= `DLY 32'h1;
      end
      else if (adler32_init) begin
          adler32_out <= `DLY 32'h1;
      end
      else if (data_in_vld) begin
          adler32_out <= `DLY adler32_out_nxt;
      end
  end

  assign s1 = adler32_out[15:0] ;
  assign s2 = adler32_out[31:16];

  assign s1_nxt = s1 + data_in;
  assign s1_nxt_m_65521 = s1_nxt - 65521;
  assign s1_nxt_mod = (s1_nxt_m_65521[17] == 1'b1) ? s1_nxt[15:0] : s1_nxt_m_65521[15:0];
  assign s2_nxt = s1_nxt_mod + s2;
  assign s2_nxt_m_65521 = s2_nxt - 65521;
  assign s2_nxt_mod = (s2_nxt_m_65521[17] == 1'b1) ? s2_nxt[15:0] : s2_nxt_m_65521[15:0];

  assign adler32_out_nxt = {s2_nxt_mod, s1_nxt_mod};

endmodule
