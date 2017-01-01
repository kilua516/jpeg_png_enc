`define DLY #1

module quantization(
    // global
    clk                 , // <i>  1b, global clock
    rstn                , // <i>  1b, global reset, active low
    // input zigzag_data
    zigzag_data         , // <i> 42b, zigzag data output
    zigzag_data_valid   , // <i>  1b, zigzag data output valid
    // quantization table
    lum_qtable_rd       , // <o>  1b, lum quantization table read enable
    chr_qtable_rd       , // <o>  1b, chr quantization table read enable
    lum_qtable_data     , // <i>  8b, lum quantization table value
    chr_qtable_data     , // <i>  8b, chr quantization table value
    // output quantized data
    q_data_valid        , // <o>  1b, zigzag data output valid
    y_q_data            , // <o> 11b, zigzag data output
    u_q_data            , // <o> 11b, zigzag data output
    v_q_data              // <o> 11b, zigzag data output
    );

  // global
  input         clk                 ; // <i>  1b, global clock
  input         rstn                ; // <i>  1b, global reset, active low
  // input dct_data
  input  [41:0] zigzag_data         ; // <i> 42b, zigzag data output
  input         zigzag_data_valid   ; // <i>  1b, zigzag data output valid
  // quantization table
  output        lum_qtable_rd       ; // <o>  1b, lum quantization table read enable
  output        chr_qtable_rd       ; // <o>  1b, chr quantization table read enable
  input  [7:0]  lum_qtable_data     ; // <i>  8b, lum quantization table value
  input  [7:0]  chr_qtable_data     ; // <i>  8b, chr quantization table value
  // output quantized data
  output        q_data_valid        ; // <o>  1b, zigzag data output valid
  output [10:0] y_q_data            ; // <o> 11b, zigzag data output
  output [10:0] u_q_data            ; // <o> 11b, zigzag data output
  output [10:0] v_q_data            ; // <o> 11b, zigzag data output

  reg    [18:0] y_zigzag_data_d     ; // delay of y zigzag_data
  reg    [18:0] u_zigzag_data_d     ; // delay of u zigzag_data
  reg    [18:0] v_zigzag_data_d     ; // delay of v zigzag_data
  reg           zigzag_data_valid_d ; // delay of zigzag_data_valid

  // delay input signals to sync with qtable_data
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_zigzag_data_d     <= `DLY 19'h0;
          u_zigzag_data_d     <= `DLY 19'h0;
          v_zigzag_data_d     <= `DLY 19'h0;
          zigzag_data_valid_d <= `DLY 1'b0;
      end
      else begin
          y_zigzag_data_d       <= `DLY {{5{zigzag_data[41]}},
                                         zigzag_data[41:28]  };
          u_zigzag_data_d       <= `DLY {{5{zigzag_data[27]}},
                                         zigzag_data[27:14]  };
          v_zigzag_data_d       <= `DLY {{5{zigzag_data[13]}},
                                         zigzag_data[13:0]   };
          zigzag_data_valid_d <= `DLY zigzag_data_valid;
      end
  end

  // qtable read enable
  assign lum_qtable_rd = zigzag_data_valid;
  assign chr_qtable_rd = zigzag_data_valid;

  // divide
  divide y_quantize_u0(
    // global
    .clk                (clk                ), // <i>  1b, global clock
    .rstn               (rstn               ), // <i>  1b, global reset, active low
    // dividend and divisor input
    .dividend           (y_zigzag_data_d    ), // <i> 19b, dividend input, s18.0
    .divisor            (lum_qtable_data    ), // <i>  8b, divisor input, u8.0
    .div_in_valid       (zigzag_data_valid_d), // <i>  1b, dividend and divisor input valid
    // quotient output
    .quotient           (y_q_data           ), // <o> 11b, quotient output, s10.0
    .div_out_valid      (q_data_valid       )  // <o>  1b, quotient output valid
    );

  // divide
  divide u_quantize_u1(
    // global
    .clk                (clk                ), // <i>  1b, global clock
    .rstn               (rstn               ), // <i>  1b, global reset, active low
    // dividend and divisor input
    .dividend           (u_zigzag_data_d    ), // <i> 19b, dividend input, s18.0
    .divisor            (chr_qtable_data    ), // <i>  8b, divisor input, u8.0
    .div_in_valid       (zigzag_data_valid_d), // <i>  1b, dividend and divisor input valid
    // quotient output
    .quotient           (u_q_data           ), // <o> 11b, quotient output, s10.0
    .div_out_valid      (/*floating*/       )  // <o>  1b, quotient output valid
    );

  // divide
  divide v_quantize_u2(
    // global
    .clk                (clk                ), // <i>  1b, global clock
    .rstn               (rstn               ), // <i>  1b, global reset, active low
    // dividend and divisor input
    .dividend           (v_zigzag_data_d    ), // <i> 19b, dividend input, s18.0
    .divisor            (chr_qtable_data    ), // <i>  8b, divisor input, u8.0
    .div_in_valid       (zigzag_data_valid_d), // <i>  1b, dividend and divisor input valid
    // quotient output
    .quotient           (v_q_data           ), // <o> 11b, quotient output, s10.0
    .div_out_valid      (/*floating*/       )  // <o>  1b, quotient output valid
    );

endmodule
