`define DLY #1

module ecs_merge32(
    // global
    clk                   , // <i>  1b, global clock
    rstn                  , // <i>  1b, global reset, active low
    // y huffman code out
    y_huff_code_valid     , // <i>  1b, huffman code output valid
    y_huff_code           , // <i> 27b, huffman code
    y_huff_code_length    , // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    y_ecs_eob             , // <i>  1b, y eob flag
    // u huffman code out
    u_huff_code_valid     , // <i>  1b, huffman code output valid
    u_huff_code           , // <i> 27b, huffman code
    u_huff_code_length    , // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    u_ecs_eob             , // <i>  1b, u eob flag
    // v huffman code out
    v_huff_code_valid     , // <i>  1b, huffman code output valid
    v_huff_code           , // <i> 27b, huffman code
    v_huff_code_length    , // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
    v_ecs_eob             , // <i>  1b, v eob flag
    // output huffman code
    code_out_valid        , // <o>  1b, huffman code output valid
    code                  , // <o> 32b, huffman code
    length                , // <o>  6b, huffman code length(0 for 1, 1 for 2...15 for 16)
    ecs_eob                 // <o>  1b, eob flag
    );

  // global
  input         clk                   ; // <i>  1b, global clock
  input         rstn                  ; // <i>  1b, global reset, active low
  // y huffman code out
  input         y_huff_code_valid     ; // <i>  1b, huffman code output valid
  input  [26:0] y_huff_code           ; // <i> 27b, huffman code
  input  [4:0]  y_huff_code_length    ; // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
  input         y_ecs_eob             ; // <i>  1b, y eob flag
  // u huffman code out
  input         u_huff_code_valid     ; // <i>  1b, huffman code output valid
  input  [26:0] u_huff_code           ; // <i> 27b, huffman code
  input  [4:0]  u_huff_code_length    ; // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
  input         u_ecs_eob             ; // <i>  1b, u eob flag
  // v huffman code out
  input         v_huff_code_valid     ; // <i>  1b, huffman code output valid
  input  [26:0] v_huff_code           ; // <i> 27b, huffman code
  input  [4:0]  v_huff_code_length    ; // <i>  5b, huffman code length(0 for 1, 1 for 2...15 for 16)
  input         v_ecs_eob             ; // <i>  1b, v eob flag
  // output huffman code
  output        code_out_valid        ; // <o>  1b, huffman code output valid
  output [31:0] code                  ; // <o> 32b, huffman code
  output [5:0]  length                ; // <o>  6b, huffman code length(0 for 1, 1 for 2...15 for 16)
  output        ecs_eob               ; // <o>  1b, eob flag

  parameter Y_DATA = 2'h0;
  parameter U_DATA = 2'h1;
  parameter V_DATA = 2'h2;

  wire   [42:0] y_huff_code_shift_4 ; // shift y_huff_code to fill in y_code_buf
  wire   [50:0] y_huff_code_shift_3 ; // shift y_huff_code to fill in y_code_buf
  wire   [54:0] y_huff_code_shift_2 ; // shift y_huff_code to fill in y_code_buf
  wire   [56:0] y_huff_code_shift_1 ; // shift y_huff_code to fill in y_code_buf
  wire   [57:0] y_huff_code_shift_0 ; // shift y_huff_code to fill in y_code_buf

  reg    [57:0] y_code_buf          ; // y_code_buf used to merge code into 64-bit
  reg    [5:0]  y_bit_ptr           ; // y_bit_ptr used to point the position in y_code_buf
  wire   [5:0]  y_bit_ptr_nxt       ; // y_bit_ptr used to point the position in y_code_buf
  reg           y_bit_ptr_ov        ; // y_bit_ptr overflow
  wire          y_bit_ptr_ov_nxt    ; // next value of y_bit_ptr_ov
  reg           y_ecs_eob_d1        ; // delay of y_ecs_eob
  wire          y_ecs_eob_tail      ; // ecs eob tail occurs when eob and bit_ptr_ov at the same time
  reg           y_ecs_eob_tail_d    ; // delay of y_ecs_eob_tail
  reg    [5:0]  y_ecs_eob_tail_len  ; // ecs eob tail length
  reg    [5:0]  y_code_bit_len      ; // code bit length written into fifo
  reg    [25:0] y_code_ecs_eob_tail ; // ecs eob tail code
  wire   [31:0] y_code              ; // y_code to be written into y_ecs_fifo

  wire          y_ecs_fifo_wr       ;
  wire          y_ecs_fifo_rd       ;
  wire   [38:0] y_ecs_fifo_din      ;
  wire   [38:0] y_ecs_fifo_dout     ;
  wire          y_ecs_fifo_empty    ;

  wire          y_eob_fdout         ; // y_eob from fifo
  wire   [5:0]  y_code_len_fdout    ; // y_code_len from fifo
  wire   [31:0] y_code_fdout        ; // y_code from fifo

  wire   [42:0] u_huff_code_shift_4 ; // shift u_huff_code to fill in u_code_buf
  wire   [50:0] u_huff_code_shift_3 ; // shift u_huff_code to fill in u_code_buf
  wire   [54:0] u_huff_code_shift_2 ; // shift u_huff_code to fill in u_code_buf
  wire   [56:0] u_huff_code_shift_1 ; // shift u_huff_code to fill in u_code_buf
  wire   [57:0] u_huff_code_shift_0 ; // shift u_huff_code to fill in u_code_buf

  reg    [57:0] u_code_buf          ; // u_code_buf used to merge code into 64-bit
  reg    [5:0]  u_bit_ptr           ; // u_bit_ptr used to point the position in u_code_buf
  wire   [5:0]  u_bit_ptr_nxt       ; // u_bit_ptr used to point the position in u_code_buf
  reg           u_bit_ptr_ov        ; // u_bit_ptr overflow
  wire          u_bit_ptr_ov_nxt    ; // next value of u_bit_ptr_ov
  reg           u_ecs_eob_d1        ; // delay of u_ecs_eob
  wire          u_ecs_eob_tail      ; // ecs eob tail occurs when eob and bit_ptr_ov at the same time
  reg           u_ecs_eob_tail_d    ; // delay of u_ecs_eob_tail
  reg    [5:0]  u_ecs_eob_tail_len  ; // ecs eob tail length
  reg    [5:0]  u_code_bit_len      ; // code bit length written into fifo
  reg    [25:0] u_code_ecs_eob_tail ; // ecs eob tail code
  wire   [31:0] u_code              ; // u_code to be written into u_ecs_fifo

  wire          u_ecs_fifo_wr       ;
  wire          u_ecs_fifo_rd       ;
  wire   [38:0] u_ecs_fifo_din      ;
  wire   [38:0] u_ecs_fifo_dout     ;
  wire          u_ecs_fifo_empty    ;

  wire          u_eob_fdout         ; // u_eob from fifo
  wire   [5:0]  u_code_len_fdout    ; // u_code_len from fifo
  wire   [31:0] u_code_fdout        ; // u_code from fifo

  wire   [42:0] v_huff_code_shift_4 ; // shift v_huff_code to fill in v_code_buf
  wire   [50:0] v_huff_code_shift_3 ; // shift v_huff_code to fill in v_code_buf
  wire   [54:0] v_huff_code_shift_2 ; // shift v_huff_code to fill in v_code_buf
  wire   [56:0] v_huff_code_shift_1 ; // shift v_huff_code to fill in v_code_buf
  wire   [57:0] v_huff_code_shift_0 ; // shift v_huff_code to fill in v_code_buf

  reg    [57:0] v_code_buf          ; // v_code_buf used to merge code into 64-bit
  reg    [5:0]  v_bit_ptr           ; // v_bit_ptr used to point the position in v_code_buf
  wire   [5:0]  v_bit_ptr_nxt       ; // v_bit_ptr used to point the position in v_code_buf
  reg           v_bit_ptr_ov        ; // v_bit_ptr overflow
  wire          v_bit_ptr_ov_nxt    ; // next value of v_bit_ptr_ov
  reg           v_ecs_eob_d1        ; // delay of v_ecs_eob
  wire          v_ecs_eob_tail      ; // ecs eob tail occurs when eob and bit_ptr_ov at the same time
  reg           v_ecs_eob_tail_d    ; // delay of v_ecs_eob_tail
  reg    [5:0]  v_ecs_eob_tail_len  ; // ecs eob tail length
  reg    [5:0]  v_code_bit_len      ; // code bit length written into fifo
  reg    [25:0] v_code_ecs_eob_tail ; // ecs eob tail code
  wire   [31:0] v_code              ; // v_code to be written into v_ecs_fifo

  wire          v_ecs_fifo_wr       ;
  wire          v_ecs_fifo_rd       ;
  wire   [38:0] v_ecs_fifo_din      ;
  wire   [38:0] v_ecs_fifo_dout     ;
  wire          v_ecs_fifo_empty    ;

  wire          v_eob_fdout         ; // v_eob from fifo
  wire   [5:0]  v_code_len_fdout    ; // v_code_len from fifo
  wire   [31:0] v_code_fdout        ; // v_code from fifo

  reg    [1:0]  yuv_selector        ; // used to select y/u/v data
  wire          yuv_select_y        ; // select y data
  wire          yuv_select_u        ; // select u data
  wire          yuv_select_v        ; // select v data

//--------------------------------------------
//    merge y huffman code into 64-bit data
//--------------------------------------------

  // shift jpeg_packing_data to make stuff jpeg_out_buf easier
  assign y_huff_code_shift_4 = y_bit_ptr[4] ? {16'hFFFF     , y_huff_code[26:0]        } : {y_huff_code[26:0]        , 16'hFFFF     };
  assign y_huff_code_shift_3 = y_bit_ptr[3] ? {8'hFF        , y_huff_code_shift_4[42:0]} : {y_huff_code_shift_4[42:0], 8'hFF        };
  assign y_huff_code_shift_2 = y_bit_ptr[2] ? {4'hF         , y_huff_code_shift_3[50:0]} : {y_huff_code_shift_3[50:0], 4'hF         };
  assign y_huff_code_shift_1 = y_bit_ptr[1] ? {2'h3         , y_huff_code_shift_2[54:0]} : {y_huff_code_shift_2[54:0], 2'h3         };
  assign y_huff_code_shift_0 = y_bit_ptr[0] ? {1'b1         , y_huff_code_shift_1[56:0]} : {y_huff_code_shift_1[56:0], 1'b1         };

  // y code buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF;
      end
      else if (y_ecs_eob_d1 & y_huff_code_valid) begin
          y_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF & y_huff_code_shift_0;
      end
      else if (y_ecs_eob_d1) begin
          y_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF;
      end
      else if (y_bit_ptr_ov & y_huff_code_valid) begin
          y_code_buf <= `DLY {y_code_buf[25:0], 32'hFFFF_FFFF} & y_huff_code_shift_0;
      end
      else if (y_huff_code_valid) begin
          y_code_buf <= `DLY y_code_buf & y_huff_code_shift_0;
      end
      else if (y_bit_ptr_ov) begin
          y_code_buf <= `DLY {y_code_buf[25:0], 32'hFFFF_FFFF};
      end
  end

  //  y code buffer bit pointer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_bit_ptr <= `DLY 6'h0;
      end
      else if (y_huff_code_valid) begin
          if (y_ecs_eob) begin
              y_bit_ptr <= `DLY 6'h0;
          end
          else begin
              y_bit_ptr <= `DLY y_bit_ptr_nxt;
          end
      end
  end

  // next value of y_bit_ptr
  assign y_bit_ptr_nxt = y_bit_ptr + {1'b0, y_huff_code_length};

  // y_bit_ptr overflow
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_bit_ptr_ov <= `DLY 1'b0;
      end
      else begin
          y_bit_ptr_ov <= `DLY y_bit_ptr_ov_nxt & y_huff_code_valid;
      end
  end

  // next value of y_bit_ptr_ov
  assign y_bit_ptr_ov_nxt = (y_bit_ptr_nxt[5] ^ y_bit_ptr[5]);

  // delay of y_ecs_eob, sync with y_code_buf
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_ecs_eob_d1 <= `DLY 1'b0;
      end
      else begin
          y_ecs_eob_d1 <= `DLY (y_huff_code_valid & y_ecs_eob);
      end
  end

  // y_ecs eob tail, when y_ecs_eob_d1 and y_bit_ptr_ov, tail would be left
  // after flush data
  assign y_ecs_eob_tail = y_ecs_eob_d1 & y_bit_ptr_ov & (y_ecs_eob_tail_len != 0);

  // calculate the ecs_eob_tail length
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_ecs_eob_tail_len <= `DLY 6'h0;
      end
      else if (y_ecs_eob & y_bit_ptr_ov_nxt) begin
          y_ecs_eob_tail_len <= `DLY {1'b0, y_bit_ptr_nxt[4:0]};
      end
  end

  // delay y_ecs_eob_tail to sync with y_code_bit_len and y_code_ecs_eob_tail
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_ecs_eob_tail_d <= `DLY 1'b0;
      end
      else begin
          y_ecs_eob_tail_d <= `DLY y_ecs_eob_tail;
      end
  end

  // effective bit length in y_code_buf
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_code_bit_len <= `DLY 6'h0;
      end
      else if (y_ecs_eob_tail) begin
          y_code_bit_len <= `DLY y_ecs_eob_tail_len;
      end
      else if (y_huff_code_valid) begin
          if (y_bit_ptr_ov_nxt) begin
              y_code_bit_len <= `DLY 6'h20;
          end
          else if (y_ecs_eob) begin
              y_code_bit_len <= `DLY {~(|(y_bit_ptr_nxt[4:0])), y_bit_ptr_nxt[4:0]};
          end
      end
  end

  // extra buffer for y_ecs eob tail data
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          y_code_ecs_eob_tail <= `DLY 26'h3FF_FFFF;
      end
      else if (y_ecs_eob_tail) begin
          y_code_ecs_eob_tail <= `DLY y_code_buf[25:0];
      end
  end

  // final y_code to be written into y_ecs_fifo
  assign y_code = y_ecs_eob_tail_d ? {y_code_ecs_eob_tail, 6'h3F}: y_code_buf[57:26];

  // buffer 64-bit data in fifo, since the output stream is y/u/v in turn,
  // data may not be fetched immediately
  fifo #(39,    // FIFO_DW
         4 ,    // FIFO_AW
         16)    // FIFO_DEPTH
  y_ecs_fifo(
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (y_ecs_fifo_wr    ), // <i>  1b, fifo write enable
    .din                (y_ecs_fifo_din   ), // <i>    , fifo data input
    .full               (/*floating*/     ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (y_ecs_fifo_rd    ), // <o>  1b, fifo read enable
    .dout               (y_ecs_fifo_dout  ), // <o>    , fifo data output
    .empty              (y_ecs_fifo_empty )  // <o>  1b, fifo empty indicator
    );

  assign y_ecs_fifo_wr  = y_bit_ptr_ov | y_ecs_eob_d1 | y_ecs_eob_tail_d;
  assign y_ecs_fifo_rd  = yuv_select_y & code_out_valid;
  assign y_ecs_fifo_din = {(y_ecs_eob_d1 & ~y_ecs_eob_tail) | y_ecs_eob_tail_d, y_code_bit_len, y_code};

  assign y_eob_fdout      = y_ecs_fifo_dout[38];
  assign y_code_len_fdout = y_ecs_fifo_dout[37:32];
  assign y_code_fdout     = y_ecs_fifo_dout[31:0];

//--------------------------------------------
//    merge u huffman code into 64-bit data
//--------------------------------------------

  // shift jpeg_packing_data to make stuff jpeg_out_buf easier
  assign u_huff_code_shift_4 = u_bit_ptr[4] ? {16'hFFFF     , u_huff_code[26:0]        } : {u_huff_code[26:0]        , 16'hFFFF     };
  assign u_huff_code_shift_3 = u_bit_ptr[3] ? {8'hFF        , u_huff_code_shift_4[42:0]} : {u_huff_code_shift_4[42:0], 8'hFF        };
  assign u_huff_code_shift_2 = u_bit_ptr[2] ? {4'hF         , u_huff_code_shift_3[50:0]} : {u_huff_code_shift_3[50:0], 4'hF         };
  assign u_huff_code_shift_1 = u_bit_ptr[1] ? {2'h3         , u_huff_code_shift_2[54:0]} : {u_huff_code_shift_2[54:0], 2'h3         };
  assign u_huff_code_shift_0 = u_bit_ptr[0] ? {1'b1         , u_huff_code_shift_1[56:0]} : {u_huff_code_shift_1[56:0], 1'b1         };

  // u code buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF;
      end
      else if (u_ecs_eob_d1 & u_huff_code_valid) begin
          u_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF & u_huff_code_shift_0;
      end
      else if (u_ecs_eob_d1) begin
          u_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF;
      end
      else if (u_bit_ptr_ov & u_huff_code_valid) begin
          u_code_buf <= `DLY {u_code_buf[25:0], 32'hFFFF_FFFF} & u_huff_code_shift_0;
      end
      else if (u_huff_code_valid) begin
          u_code_buf <= `DLY u_code_buf & u_huff_code_shift_0;
      end
      else if (u_bit_ptr_ov) begin
          u_code_buf <= `DLY {u_code_buf[25:0], 32'hFFFF_FFFF};
      end
  end

  //  u code buffer bit pointer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_bit_ptr <= `DLY 6'h0;
      end
      else if (u_huff_code_valid) begin
          if (u_ecs_eob) begin
              u_bit_ptr <= `DLY 6'h0;
          end
          else begin
              u_bit_ptr <= `DLY u_bit_ptr_nxt;
          end
      end
  end

  // next value of u_bit_ptr
  assign u_bit_ptr_nxt = u_bit_ptr + {1'b0, u_huff_code_length};

  // u_bit_ptr overflow
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_bit_ptr_ov <= `DLY 1'b0;
      end
      else begin
          u_bit_ptr_ov <= `DLY u_bit_ptr_ov_nxt & u_huff_code_valid;
      end
  end

  // next value of u_bit_ptr_ov
  assign u_bit_ptr_ov_nxt = (u_bit_ptr_nxt[5] ^ u_bit_ptr[5]);

  // delay of u_ecs_eob, sync with u_code_buf
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_ecs_eob_d1 <= `DLY 1'b0;
      end
      else begin
          u_ecs_eob_d1 <= `DLY (u_huff_code_valid & u_ecs_eob);
      end
  end

  // u_ecs eob tail, when u_ecs_eob_d1 and u_bit_ptr_ov, tail would be left
  // after flush data
  assign u_ecs_eob_tail = u_ecs_eob_d1 & u_bit_ptr_ov & (u_ecs_eob_tail_len != 0);

  // calculate the ecs_eob_tail length
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_ecs_eob_tail_len <= `DLY 6'h0;
      end
      else if (u_ecs_eob & u_bit_ptr_ov_nxt) begin
          u_ecs_eob_tail_len <= `DLY {1'b0, u_bit_ptr_nxt[4:0]};
      end
  end

  // delay u_ecs_eob_tail to sync with u_code_bit_len and u_code_ecs_eob_tail
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_ecs_eob_tail_d <= `DLY 1'b0;
      end
      else begin
          u_ecs_eob_tail_d <= `DLY u_ecs_eob_tail;
      end
  end

  // effective bit length in u_code_buf
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_code_bit_len <= `DLY 6'h0;
      end
      else if (u_ecs_eob_tail) begin
          u_code_bit_len <= `DLY u_ecs_eob_tail_len;
      end
      else if (u_huff_code_valid) begin
          if (u_bit_ptr_ov_nxt) begin
              u_code_bit_len <= `DLY 6'h20;
          end
          else if (u_ecs_eob) begin
              u_code_bit_len <= `DLY {~(|(u_bit_ptr_nxt[4:0])), u_bit_ptr_nxt[4:0]};
          end
      end
  end

  // extra buffer for u_ecs eob tail data
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          u_code_ecs_eob_tail <= `DLY 26'h3FF_FFFF;
      end
      else if (u_ecs_eob_tail) begin
          u_code_ecs_eob_tail <= `DLY u_code_buf[25:0];
      end
  end

  // final u_code to be written into u_ecs_fifo
  assign u_code = u_ecs_eob_tail_d ? {u_code_ecs_eob_tail, 6'h3F}: u_code_buf[57:26];

  // buffer 64-bit data in fifo, since the output stream is y/u/v in turn,
  // data may not be fetched immediately
  fifo #(39,    // FIFO_DW
         4 ,    // FIFO_AW
         16)    // FIFO_DEPTH
  u_ecs_fifo(
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (u_ecs_fifo_wr    ), // <i>  1b, fifo write enable
    .din                (u_ecs_fifo_din   ), // <i>    , fifo data input
    .full               (/*floating*/     ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (u_ecs_fifo_rd    ), // <o>  1b, fifo read enable
    .dout               (u_ecs_fifo_dout  ), // <o>    , fifo data output
    .empty              (u_ecs_fifo_empty )  // <o>  1b, fifo empty indicator
    );

  assign u_ecs_fifo_wr  = u_bit_ptr_ov | u_ecs_eob_d1 | u_ecs_eob_tail_d;
  assign u_ecs_fifo_rd  = yuv_select_u & code_out_valid;
  assign u_ecs_fifo_din = {(u_ecs_eob_d1 & ~u_ecs_eob_tail) | u_ecs_eob_tail_d, u_code_bit_len, u_code};

  assign u_eob_fdout      = u_ecs_fifo_dout[38];
  assign u_code_len_fdout = u_ecs_fifo_dout[37:32];
  assign u_code_fdout     = u_ecs_fifo_dout[31:0];

//--------------------------------------------
//    merge v huffman code into 64-bit data
//--------------------------------------------

  // shift jpeg_packing_data to make stuff jpeg_out_buf easier
  assign v_huff_code_shift_4 = v_bit_ptr[4] ? {16'hFFFF     , v_huff_code[26:0]        } : {v_huff_code[26:0]        , 16'hFFFF     };
  assign v_huff_code_shift_3 = v_bit_ptr[3] ? {8'hFF        , v_huff_code_shift_4[42:0]} : {v_huff_code_shift_4[42:0], 8'hFF        };
  assign v_huff_code_shift_2 = v_bit_ptr[2] ? {4'hF         , v_huff_code_shift_3[50:0]} : {v_huff_code_shift_3[50:0], 4'hF         };
  assign v_huff_code_shift_1 = v_bit_ptr[1] ? {2'h3         , v_huff_code_shift_2[54:0]} : {v_huff_code_shift_2[54:0], 2'h3         };
  assign v_huff_code_shift_0 = v_bit_ptr[0] ? {1'b1         , v_huff_code_shift_1[56:0]} : {v_huff_code_shift_1[56:0], 1'b1         };

  // v code buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF;
      end
      else if (v_ecs_eob_d1 & v_huff_code_valid) begin
          v_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF & v_huff_code_shift_0;
      end
      else if (v_ecs_eob_d1) begin
          v_code_buf <= `DLY 58'h3FF_FFFF_FFFF_FFFF;
      end
      else if (v_bit_ptr_ov & v_huff_code_valid) begin
          v_code_buf <= `DLY {v_code_buf[25:0], 32'hFFFF_FFFF} & v_huff_code_shift_0;
      end
      else if (v_huff_code_valid) begin
          v_code_buf <= `DLY v_code_buf & v_huff_code_shift_0;
      end
      else if (v_bit_ptr_ov) begin
          v_code_buf <= `DLY {v_code_buf[25:0], 32'hFFFF_FFFF};
      end
  end

  //  v code buffer bit pointer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_bit_ptr <= `DLY 6'h0;
      end
      else if (v_huff_code_valid) begin
          if (v_ecs_eob) begin
              v_bit_ptr <= `DLY 6'h0;
          end
          else begin
              v_bit_ptr <= `DLY v_bit_ptr_nxt;
          end
      end
  end

  // next value of v_bit_ptr
  assign v_bit_ptr_nxt = v_bit_ptr + {1'b0, v_huff_code_length};

  // v_bit_ptr overflow
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_bit_ptr_ov <= `DLY 1'b0;
      end
      else begin
          v_bit_ptr_ov <= `DLY v_bit_ptr_ov_nxt & v_huff_code_valid;
      end
  end

  // next value of v_bit_ptr_ov
  assign v_bit_ptr_ov_nxt = (v_bit_ptr_nxt[5] ^ v_bit_ptr[5]);

  // delay of v_ecs_eob, sync with v_code_buf
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_ecs_eob_d1 <= `DLY 1'b0;
      end
      else begin
          v_ecs_eob_d1 <= `DLY (v_huff_code_valid & v_ecs_eob);
      end
  end

  // v_ecs eob tail, when v_ecs_eob_d1 and v_bit_ptr_ov, tail would be left
  // after flush data
  assign v_ecs_eob_tail = v_ecs_eob_d1 & v_bit_ptr_ov & (v_ecs_eob_tail_len != 0);

  // calculate the ecs_eob_tail length
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_ecs_eob_tail_len <= `DLY 6'h0;
      end
      else if (v_ecs_eob & v_bit_ptr_ov_nxt) begin
          v_ecs_eob_tail_len <= `DLY {1'b0, v_bit_ptr_nxt[4:0]};
      end
  end

  // delay v_ecs_eob_tail to sync with v_code_bit_len and v_code_ecs_eob_tail
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_ecs_eob_tail_d <= `DLY 1'b0;
      end
      else begin
          v_ecs_eob_tail_d <= `DLY v_ecs_eob_tail;
      end
  end

  // effective bit length in v_code_buf
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_code_bit_len <= `DLY 6'h0;
      end
      else if (v_ecs_eob_tail) begin
          v_code_bit_len <= `DLY v_ecs_eob_tail_len;
      end
      else if (v_huff_code_valid) begin
          if (v_bit_ptr_ov_nxt) begin
              v_code_bit_len <= `DLY 6'h20;
          end
          else if (v_ecs_eob) begin
              v_code_bit_len <= `DLY {~(|(v_bit_ptr_nxt[4:0])), v_bit_ptr_nxt[4:0]};
          end
      end
  end

  // extra buffer for v_ecs eob tail data
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          v_code_ecs_eob_tail <= `DLY 26'h3FF_FFFF;
      end
      else if (v_ecs_eob_tail) begin
          v_code_ecs_eob_tail <= `DLY v_code_buf[25:0];
      end
  end

  // final v_code to be written into v_ecs_fifo
  assign v_code = v_ecs_eob_tail_d ? {v_code_ecs_eob_tail, 6'h3F}: v_code_buf[57:26];

  // buffer 64-bit data in fifo, since the output stream is y/u/v in turn,
  // data may not be fetched immediately
  fifo #(39,    // FIFO_DW
         4 ,    // FIFO_AW
         16)    // FIFO_DEPTH
  v_ecs_fifo(
    // global
    .clk                (clk              ), // <i>  1b, global clock
    .rstn               (rstn             ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                 (v_ecs_fifo_wr    ), // <i>  1b, fifo write enable
    .din                (v_ecs_fifo_din   ), // <i>    , fifo data input
    .full               (/*floating*/     ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                 (v_ecs_fifo_rd    ), // <o>  1b, fifo read enable
    .dout               (v_ecs_fifo_dout  ), // <o>    , fifo data output
    .empty              (v_ecs_fifo_empty )  // <o>  1b, fifo empty indicator
    );

  assign v_ecs_fifo_wr  = v_bit_ptr_ov | v_ecs_eob_d1 | v_ecs_eob_tail_d;
  assign v_ecs_fifo_rd  = yuv_select_v & code_out_valid;
  assign v_ecs_fifo_din = {(v_ecs_eob_d1 & ~v_ecs_eob_tail) | v_ecs_eob_tail_d, v_code_bit_len, v_code};

  assign v_eob_fdout      = v_ecs_fifo_dout[38];
  assign v_code_len_fdout = v_ecs_fifo_dout[37:32];
  assign v_code_fdout     = v_ecs_fifo_dout[31:0];

//--------------------------------------------
//    control y/u/v data sequence
//--------------------------------------------

  // yuv_selector used to select y/u/v data
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          yuv_selector <= `DLY Y_DATA;
      end
      else if (ecs_eob) begin
          if (yuv_selector == Y_DATA) begin
              yuv_selector <= `DLY U_DATA;
          end
          else if (yuv_selector == U_DATA) begin
              yuv_selector <= `DLY V_DATA;
          end
          else if (yuv_selector == V_DATA) begin
              yuv_selector <= `DLY Y_DATA;
          end
      end
  end

  assign yuv_select_y = (yuv_selector == Y_DATA);
  assign yuv_select_u = (yuv_selector == U_DATA);
  assign yuv_select_v = (yuv_selector == V_DATA);

//--------------------------------------------
// get the output according to the yuv_selector
//--------------------------------------------

  // eob of current select data
  assign ecs_eob = (yuv_select_y & ~y_ecs_fifo_empty & y_eob_fdout) | 
                   (yuv_select_u & ~u_ecs_fifo_empty & u_eob_fdout) |
                   (yuv_select_v & ~v_ecs_fifo_empty & v_eob_fdout) ;

  // huffman code output valid
  assign code_out_valid = yuv_select_y ? (~y_ecs_fifo_empty) :
                          yuv_select_u ? (~u_ecs_fifo_empty) :
                                         (~v_ecs_fifo_empty) ;

  // huffman code output
  assign code = yuv_select_y ? y_code_fdout :
                yuv_select_u ? u_code_fdout :
                               v_code_fdout ;

  // huffman code output length
  assign length = yuv_select_y ? y_code_len_fdout :
                  yuv_select_u ? u_code_len_fdout :
                                 v_code_len_fdout ;

endmodule
