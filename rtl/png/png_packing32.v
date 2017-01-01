`define DLY #1

module png_packing32(
    // global
    clk               , // <i>  1b, global clock
    rstn              , // <i>  1b, global reset, active low
    // interface with registers
    frame_start       , // <i>  1b, frame start indicator
    frame_end         , // <o>  1b, frame end indicator
    pic_width         , // <i> 11b, picture width
    pic_height        , // <i> 11b, picture height
    png_file_len      , // <o> 23b, png file length indicator
    // pic data input
    pic_din_valid     , // <i>  1b, input data valid
    pic_din_rdy       , // <o>  1b, ready to accept input data
    pic_din_done      , // <i>  1b, input data done of a frame
    pic_data          , // <i>  8b, input data
    // stream output
    png_out_valid     , // <o>  1b, png stream output valid
    png_out_data        // <o> 32b, png stream output
    );

  // global
  input         clk               ; // <i>  1b, global clock
  input         rstn              ; // <i>  1b, global reset, active low
  // interface with registers
  input         frame_start       ; // <i>  1b, frame start indicator
  output        frame_end         ; // <o>  1b, frame end indicator
  input  [10:0] pic_width         ; // <i> 11b, picture width
  input  [10:0] pic_height        ; // <i> 11b, picture height
  output [22:0] png_file_len      ; // <o> 23b, png file length indicator
  // pic data input
  input         pic_din_valid     ; // <i>  1b, input data valid
  output        pic_din_rdy       ; // <o>  1b, ready to accept input data
  input         pic_din_done      ; // <i>  1b, input data done of a frame
  input  [7:0]  pic_data          ; // <i>  8b, input data
  // stream output
  output        png_out_valid     ; // <o>  1b, png stream output valid
  output [31:0] png_out_data      ; // <o> 32b, png stream output

  reg           frame_end                 ; // frame end indicator

  reg    [22:0] png_file_len              ; // png file length indicator

  reg    [2:0]  png_out_st                ; // png_packing state machine current state
  reg    [2:0]  png_out_nxt_st            ; // png_packing state machine next state

  wire          png_out_st_idle           ; // png_packing state is idle
  wire          png_out_st_sign           ; // png_packing state is sign
  wire          png_out_st_ihdr           ; // png_packing state is ihdr
  wire          png_out_st_idat           ; // png_packing state is idat
  wire          png_out_st_iend           ; // png_packing state is iend

  wire          png_sign_done             ; // png_out_st_sign state is done
  wire          png_ihdr_done             ; // png_out_st_ihdr state is done
  wire          png_idat_done             ; // png_out_st_idat state is done
  wire          png_iend_done             ; // png_out_st_iend state is done

  reg    [2:0]  chunk_layout_st           ; // chunk_layout state machine
  reg    [2:0]  chunk_layout_nxt_st       ; // next state of chunk_layout state machine

  wire          chunk_layout_st_idle      ; // chunk_layout state is idle
  wire          chunk_layout_st_length    ; // chunk_layout state is length
  wire          chunk_layout_st_type      ; // chunk_layout state is type
  wire          chunk_layout_st_data      ; // chunk_layout state is data
  wire          chunk_layout_st_crc       ; // chunk_layout state is crc

  wire          chunk_layout_length_done  ; // chunk_layout_st_length state is done
  wire          chunk_layout_type_done    ; // chunk_layout_st_type   state is done  
  wire          chunk_layout_data_done    ; // chunk_layout_st_data   state is done  
  wire          chunk_layout_crc_done     ; // chunk_layout_st_crc    state is done   

  reg    [1:0]  zlib_st                   ; // zlib state machine
  reg    [1:0]  zlib_nxt_st               ; // zlib state machine

  wire          zlib_st_idle              ; // zlib state is idle  
  wire          zlib_st_header            ; // zlib state is header
  wire          zlib_st_data              ; // zlib state is data  
  wire          zlib_st_adler             ; // zlib state is adler 

  wire          zlib_header_done          ; // zlib_st_header is done
  wire          zlib_data_done            ; // zlib_st_data   is done
  wire          zlib_adler_done           ; // zlib_st_adler  is done

  reg    [22:0] stream_out_cnt            ; // count the data stream output

  reg    [23:0] pic_byte_cnts             ; // picture total byte counts, include filter type at beginning of each line
  reg    [8:0]  lz77_block_total          ; // lz77 total block counts
  reg    [8:0]  lz77_block_cnt            ; // count the lz77 block
  wire   [15:0] lz77_block_size           ; // lz77 block size
  wire          lz77_block_done           ; // indicate current lz77 block is done
  wire          lz77_last_block           ; // indicates current lz77 block is the last block
  reg    [23:0] bytes_remain              ; // count the remain bytes in current picture
  wire   [31:0] chunk_length              ; // length of each chunk

  reg    [12:0] x_byte_cnt                ; // count the bytes in a line, include filter type byte
  wire          line_start                ; // line start indicator, used for filter type byte insert

  wire   [7:0]  bit_depth                 ; // bit depth in png file
  wire   [7:0]  color_type                ; // color type in png file
  wire   [7:0]  comp_method               ; // compress method in png file
  wire   [7:0]  filt_method               ; // filter method in png file
  wire   [7:0]  intl_method               ; // interlace mode in png file

  reg    [31:0] sign_data                 ; // data used in signature
  reg    [2:0]  sign_data_len             ; // data length used in signature
  reg           sign_data_vld             ; // data valid used in signature
  reg    [31:0] ihdr_data                 ; // data used in IHDR
  reg    [2:0]  ihdr_data_len             ; // data length used in IHDR
  reg           ihdr_data_vld             ; // data valid used in IHDR
  reg    [31:0] idat_data                 ; // data used in IDAT
  reg    [2:0]  idat_data_len             ; // data length used in IDAT
  reg           idat_data_vld             ; // data valid used in IDAT
  reg    [31:0] iend_data                 ; // data used in IEND
  reg    [2:0]  iend_data_len             ; // data length used in IEND
  reg           iend_data_vld             ; // data valid used in IEND

  reg    [31:0] png_packing_data          ; // data to be packetized, selected from each segment(soi/dht/dqt...)
  reg    [2:0]  png_packing_length        ; // data length to be packetized
  reg           png_packing_dvalid        ; // packing data valid indicator

  reg           last_data_flag            ; // last data flag to end png encoding task

  wire   [55:0] png_packing_data_shift_0  ; // png_packing data shift
  wire   [47:0] png_packing_data_shift_1  ; // png_packing data shift
  
  reg    [55:0] png_out_buf               ; // png output buffer
  reg    [23:0] png_out_buf_tail          ; // png output buffer tail, data valid when png_out_byte_ptr overflow and last_data_flag

  reg    [23:0] png_file_len_cnt          ; // png file length counter
  reg    [2:0]  png_out_byte_ptr          ; // current byte pointer in png_out_buffer
  wire   [2:0]  png_out_byte_ptr_nxt      ; // next value of png_out_byte_ptr
  reg           png_out_byte_ptr_ov       ; // png_out_byte_ptr overflow
  reg           last_data_flag_out        ; // last data flag at output stage
  reg           last_data_flag_d          ; // delay of last_data_flag_out

  wire          png_out_flush             ; // flush the output buffer

  wire          crc_init                  ; // crc initialize
  wire   [7:0]  crc_dat_in                ; // crc calculate data in
  wire          crc_dat_in_vld            ; // crc calculate data in valid
  wire   [31:0] chunk_crc                 ; // chunk crc result
  wire          chunk_crc_vld             ; // chunk crc valid
  wire          zlib_dat_in_vld           ; // adler32 calculate data in valid
  wire   [31:0] adler_data                ; // adler32 result
  wire          adler_data_vld            ; // adler32 valid

  // file packing state machine parameter define
  parameter PNG_IDLE    = 3'h0;
  parameter PNG_SIGN    = 3'h1;
  parameter PNG_IHDR    = 3'h2;
  parameter PNG_IDAT    = 3'h3;
  parameter PNG_IEND    = 3'h4;

  // chunk layout state machine parameter define
  parameter CHUNK_IDLE   = 3'h0;
  parameter CHUNK_LENGTH = 3'h1;
  parameter CHUNK_TYPE   = 3'h2;
  parameter CHUNK_DATA   = 3'h3;
  parameter CHUNK_CRC    = 3'h4;

  // zlib packing state machine parameter define
  parameter ZLIB_IDLE   = 2'h0;
  parameter ZLIB_HEADER = 2'h1;
  parameter ZLIB_DATA   = 2'h2;
  parameter ZLIB_ADLER  = 2'h3;

//--------------------------------------------
//    packing state control
//--------------------------------------------

  // png_out packing state machine
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          png_out_st <= `DLY PNG_IDLE;
      end
      else begin
          png_out_st <= `DLY png_out_nxt_st;
      end
  end

  // next state of png_out_st
  always @(*) begin
      png_out_nxt_st = PNG_IDLE;
      case (png_out_st)
          PNG_IDLE:
          begin
              if (frame_start | frame_end)
                  png_out_nxt_st = PNG_SIGN;
              else
                  png_out_nxt_st = PNG_IDLE;
          end
          PNG_SIGN:
          begin
              if (png_sign_done)
                  png_out_nxt_st = PNG_IHDR;
              else
                  png_out_nxt_st = PNG_SIGN;
          end
          PNG_IHDR:
          begin
              if (png_ihdr_done)
                  png_out_nxt_st = PNG_IDAT;
              else
                  png_out_nxt_st = PNG_IHDR;
          end
          PNG_IDAT:
          begin
              if (png_idat_done)
                  png_out_nxt_st = PNG_IEND;
              else
                  png_out_nxt_st = PNG_IDAT;
          end
          PNG_IEND:
          begin
              if (png_iend_done)
                  png_out_nxt_st = PNG_IDLE;
              else
                  png_out_nxt_st = PNG_IEND;
          end
          default:
                  png_out_nxt_st = PNG_IDLE;
      endcase
  end

  // each state indicator
  assign png_out_st_idle    = (png_out_st == PNG_IDLE);
  assign png_out_st_sign    = (png_out_st == PNG_SIGN);
  assign png_out_st_ihdr    = (png_out_st == PNG_IHDR);
  assign png_out_st_idat    = (png_out_st == PNG_IDAT);
  assign png_out_st_iend    = (png_out_st == PNG_IEND);

  // done indicator according to the corresponding data process
  assign png_sign_done = png_out_st_sign & (stream_out_cnt == 1);
  assign png_ihdr_done = png_out_st_ihdr & chunk_layout_crc_done;
  assign png_idat_done = png_out_st_idat & chunk_layout_crc_done;
  assign png_iend_done = png_out_st_iend & chunk_layout_crc_done;

  // sub state machine in every png out state
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          chunk_layout_st <= `DLY CHUNK_IDLE;
      end
      else if (frame_start | frame_end) begin
          chunk_layout_st <= `DLY CHUNK_IDLE;
      end
      else begin
          chunk_layout_st <= `DLY chunk_layout_nxt_st;
      end
  end

  // next state of chunk_layout_st
  always @(*) begin
      chunk_layout_nxt_st = CHUNK_IDLE;
      case (chunk_layout_st)
          CHUNK_IDLE:
          begin
              if (~png_out_st_idle & ~png_out_st_sign)
                  chunk_layout_nxt_st = CHUNK_LENGTH;
              else
                  chunk_layout_nxt_st = CHUNK_IDLE;
          end
          CHUNK_LENGTH:
          begin
              if (chunk_layout_length_done)
                  chunk_layout_nxt_st = CHUNK_TYPE;
              else
                  chunk_layout_nxt_st = CHUNK_LENGTH;
          end
          CHUNK_TYPE:
          begin
              if (chunk_layout_type_done & (chunk_length == 0))
                  chunk_layout_nxt_st = CHUNK_CRC;
              else if (chunk_layout_type_done & (chunk_length != 0))
                  chunk_layout_nxt_st = CHUNK_DATA;
              else
                  chunk_layout_nxt_st = CHUNK_TYPE;
          end
          CHUNK_DATA:
          begin
              if (chunk_layout_data_done)
                  chunk_layout_nxt_st = CHUNK_CRC;
              else
                  chunk_layout_nxt_st = CHUNK_DATA;
          end
          default: // CHUNK_CRC:
          begin
              if (chunk_layout_crc_done)
                  chunk_layout_nxt_st = CHUNK_LENGTH;
              else
                  chunk_layout_nxt_st = CHUNK_CRC;
          end
      endcase
  end

  assign chunk_layout_st_idle   = (chunk_layout_st == CHUNK_IDLE  );
  assign chunk_layout_st_length = (chunk_layout_st == CHUNK_LENGTH);
  assign chunk_layout_st_type   = (chunk_layout_st == CHUNK_TYPE  );
  assign chunk_layout_st_data   = (chunk_layout_st == CHUNK_DATA  );
  assign chunk_layout_st_crc    = (chunk_layout_st == CHUNK_CRC   );

  assign chunk_layout_length_done = chunk_layout_st_length & (stream_out_cnt == 0);
  assign chunk_layout_type_done   = chunk_layout_st_type   & (stream_out_cnt == 3);
  assign chunk_layout_data_done   = png_out_st_ihdr ? (chunk_layout_st_data & (stream_out_cnt == 12))               :
                                                      (chunk_layout_st_data & zlib_st_adler & (stream_out_cnt == 3));
  assign chunk_layout_crc_done    = chunk_layout_st_crc    & (stream_out_cnt == 0);

  // sub state machine in png_out_idat state
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          zlib_st <= `DLY ZLIB_IDLE;
      end
      else if (frame_start | frame_end) begin
          zlib_st <= `DLY ZLIB_IDLE;
      end
      else begin
          zlib_st <= `DLY zlib_nxt_st;
      end
  end

  // next state of zlib_st
  always @(*) begin
      zlib_nxt_st = ZLIB_IDLE;
      case (zlib_st)
          ZLIB_IDLE:
          begin
              if (png_out_st_idat & chunk_layout_type_done)
                  zlib_nxt_st = ZLIB_HEADER;
              else
                  zlib_nxt_st = ZLIB_IDLE;
          end
          ZLIB_HEADER:
          begin
              if (zlib_header_done)
                  zlib_nxt_st = ZLIB_DATA;
              else
                  zlib_nxt_st = ZLIB_HEADER;
          end
          ZLIB_DATA:
          begin
              if (zlib_data_done)
                  zlib_nxt_st = ZLIB_ADLER;
              else
                  zlib_nxt_st = ZLIB_DATA;
          end
          default: // ZLIB_ADLER:
          begin
              if (zlib_adler_done)
                  zlib_nxt_st = ZLIB_IDLE;
              else
                  zlib_nxt_st = ZLIB_ADLER;
          end
      endcase
  end

  assign zlib_st_idle   = (zlib_st == ZLIB_IDLE  );
  assign zlib_st_header = (zlib_st == ZLIB_HEADER);
  assign zlib_st_data   = (zlib_st == ZLIB_DATA  );
  assign zlib_st_adler  = (zlib_st == ZLIB_ADLER );

  assign zlib_header_done = zlib_st_header & (stream_out_cnt == 1);
  assign zlib_data_done   = zlib_st_data   & pic_din_done         ;
  assign zlib_adler_done  = zlib_st_adler  & (stream_out_cnt == 3);

  // stream out data count in each state
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          stream_out_cnt <= `DLY 0;
      end
      else if (frame_start | frame_end) begin
          stream_out_cnt <= `DLY 0;
      end
      else if ((png_out_st      != png_out_nxt_st     ) |
               (chunk_layout_st != chunk_layout_nxt_st) |
               (zlib_st         != zlib_nxt_st        ) |
               lz77_block_done                          ) begin
          stream_out_cnt <= `DLY 0;
      end
      else if (png_out_st_idat & zlib_st_data & ~idat_data_vld) begin
          stream_out_cnt <= `DLY stream_out_cnt;
      end
      else if (~png_out_st_idle) begin
          stream_out_cnt <= `DLY stream_out_cnt + 1;
      end
  end

//--------------------------------------------
//    data to be packetized in png file
//--------------------------------------------
  
  // indicate the byte counts of the picture data in png file
  // register to improve timing
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          pic_byte_cnts <= `DLY 24'h0;
      end
      else begin
          pic_byte_cnts <= `DLY (pic_width * 3 + 1) * pic_height;
      end
  end

  // indicate how many lz77 blocks in png file
  // register to improve timing
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          lz77_block_total <= `DLY 9'h0;
      end
      else begin
          lz77_block_total <= `DLY pic_byte_cnts[23:15] + (|pic_byte_cnts[14:0]);
      end
  end

  // lz77 block counts
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          lz77_block_cnt <= `DLY 9'h0;
      end
      else if (frame_start | frame_end) begin
          lz77_block_cnt <= `DLY 9'h0;
      end
      else if (lz77_block_done) begin
          lz77_block_cnt <= `DLY lz77_block_cnt + 9'h1;
      end
  end

  // lz77 block size
  assign lz77_block_size = (|bytes_remain[23:15]) ? 16'h8000 : bytes_remain[15:0];

  // lz77 block done
  assign lz77_block_done = idat_data_vld & zlib_st_data & (stream_out_cnt == 32772);

  // last lz77 block indicator
  assign lz77_last_block = (lz77_block_cnt == (lz77_block_total - 1));

  // bytes remain in current picture
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          bytes_remain <= `DLY 24'h0;
      end
      else if (zlib_header_done) begin
          bytes_remain <= `DLY pic_byte_cnts;
      end
      else if (chunk_layout_st_data & zlib_st_data & (stream_out_cnt == 4)) begin
          bytes_remain <= `DLY bytes_remain - {8'h0, lz77_block_size};
      end
  end

  // length of each chunk
  assign chunk_length = png_out_st_ihdr ? 13                                         :
                        png_out_st_idat ? (pic_byte_cnts + lz77_block_total * 5 + 6) :
                                          0                                          ;

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          x_byte_cnt <= `DLY 11'h0;
      end
      else if (idat_data_vld & (stream_out_cnt > 4)) begin
          if (x_byte_cnt == (3 * pic_width)) begin
              x_byte_cnt <= `DLY 13'h0;
          end
          else begin
              x_byte_cnt <= `DLY x_byte_cnt + 13'h1;
          end
      end
  end

  assign line_start = (x_byte_cnt == 0);

  assign pic_din_rdy = chunk_layout_st_data &
                       zlib_st_data         &
                       (stream_out_cnt > 4) &
                       idat_data_vld        &
                       ~line_start          ;

  // signature data and length
  always @(*) begin
      if (png_out_st_sign) begin
          if (stream_out_cnt == 0) begin
              sign_data = 32'h474E_5089;
              sign_data_len = 3'h4;
              sign_data_vld = 1'b1;
          end
          else begin
              sign_data = 32'h0A1A_0A0D;
              sign_data_len = 3'h4;
              sign_data_vld = 1'b1;
          end
      end
      else begin
          sign_data = 32'hFFFF_FFFF;
          sign_data_len = 3'h0;
          sign_data_vld = 1'b0;
      end
  end

  assign bit_depth   = 8;
  assign color_type  = 2;
  assign comp_method = 0;
  assign filt_method = 0;
  assign intl_method = 0;

  // IHDR
  always @(*) begin
      if (png_out_st_ihdr) begin
          if (chunk_layout_st_length) begin
              ihdr_data = {chunk_length[7:0]  , 
                           chunk_length[15:8] ,
                           chunk_length[23:16],
                           chunk_length[31:24]};
              ihdr_data_len = 3'd4;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 0)) begin
              ihdr_data = 32'hFFFF_FF49;
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 1)) begin
              ihdr_data = 32'hFFFF_FF48;
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 2)) begin
              ihdr_data = 32'hFFFF_FF44;
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 3)) begin
              ihdr_data = 32'hFFFF_FF52;
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 0)) begin
              ihdr_data = 32'hFFFF_FF00;
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 1)) begin
              ihdr_data = 32'hFFFF_FF00;
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 2)) begin
              ihdr_data = {24'hFF_FFFF, 5'h0, pic_width[10:8]};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 3)) begin
              ihdr_data = {24'hFF_FFFF, pic_width[7:0]};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 4)) begin
              ihdr_data = 32'hFFFF_FF00;
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 5)) begin
              ihdr_data = 32'hFFFF_FF00;
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 6)) begin
              ihdr_data = {24'hFF_FFFF, 5'h0, pic_height[10:8]};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 7)) begin
              ihdr_data = {24'hFF_FFFF, pic_height[7:0]};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 8)) begin
              ihdr_data = {24'hFF_FFFF, bit_depth};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 9)) begin
              ihdr_data = {24'hFF_FFFF, color_type};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 10)) begin
              ihdr_data = {24'hFF_FFFF, comp_method};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 11)) begin
              ihdr_data = {24'hFF_FFFF, filt_method};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & (stream_out_cnt == 12)) begin
              ihdr_data = {24'hFF_FFFF, intl_method};
              ihdr_data_len = 3'd1;
              ihdr_data_vld = 1'b1;
          end
          else if (chunk_layout_st_crc) begin
              ihdr_data = {~chunk_crc[7:0]  , 
                           ~chunk_crc[15:8] ,
                           ~chunk_crc[23:16],
                           ~chunk_crc[31:24]};
              ihdr_data_len = 3'd4;
              ihdr_data_vld = chunk_crc_vld;
          end
      end
      else begin
          ihdr_data = 32'hFFFF_FFFF;
          ihdr_data_len = 3'd0;
          ihdr_data_vld = 1'b0;
      end
  end

  // IDAT
  always @(*) begin
      if (png_out_st_idat) begin
          if (chunk_layout_st_length) begin
              idat_data = {chunk_length[7:0]  , 
                           chunk_length[15:8] ,
                           chunk_length[23:16],
                           chunk_length[31:24]};
              idat_data_len = 3'd4;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 0)) begin
              idat_data = 32'hFFFF_FF49;
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 1)) begin
              idat_data = 32'hFFFF_FF44;
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 2)) begin
              idat_data = 32'hFFFF_FF41;
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 3)) begin
              idat_data = 32'hFFFF_FF54;
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_header & (stream_out_cnt == 0)) begin
              idat_data = 32'hFFFF_FF78;
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_header & (stream_out_cnt == 1)) begin
              idat_data = 32'hFFFF_FF01;
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_data & (stream_out_cnt == 0)) begin
              if (lz77_last_block) begin
                  idat_data = 32'hFFFF_FF01;
                  idat_data_len = 3'd1;
                  idat_data_vld = 1'b1;
              end
              else begin
                  idat_data = 32'hFFFF_FF00;
                  idat_data_len = 3'd1;
                  idat_data_vld = 1'b1;
              end
          end
          else if (chunk_layout_st_data & zlib_st_data & (stream_out_cnt == 1)) begin
              idat_data = {24'hFF_FFFF, lz77_block_size[7:0]};
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_data & (stream_out_cnt == 2)) begin
              idat_data = {24'hFF_FFFF, lz77_block_size[15:8]};
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_data & (stream_out_cnt == 3)) begin
              idat_data = {24'hFF_FFFF, ~lz77_block_size[7:0]};
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_data & (stream_out_cnt == 4)) begin
              idat_data = {24'hFF_FFFF, ~lz77_block_size[15:8]};
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_data & (stream_out_cnt > 4)) begin
              if (line_start) begin
                  idat_data = 32'hFFFF_FF00; // filter type 0
                  idat_data_len = 3'd1;
                  idat_data_vld = 1'b1;
              end
              else begin
                  idat_data = {24'hFF_FFFF, pic_data};
                  idat_data_len = 3'd1;
                  idat_data_vld = pic_din_valid;
              end
          end
          else if (chunk_layout_st_data & zlib_st_adler & (stream_out_cnt == 0)) begin
              idat_data = {24'hFF_FFFF, adler_data[31:24]};
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_adler & (stream_out_cnt == 1)) begin
              idat_data = {24'hFF_FFFF, adler_data[23:16]};
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_adler & (stream_out_cnt == 2)) begin
              idat_data = {24'hFF_FFFF, adler_data[15:8]};
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_data & zlib_st_adler & (stream_out_cnt == 3)) begin
              idat_data = {24'hFF_FFFF, adler_data[7:0]};
              idat_data_len = 3'd1;
              idat_data_vld = 1'b1;
          end
          else if (chunk_layout_st_crc) begin
              idat_data = {~chunk_crc[7:0]  , 
                           ~chunk_crc[15:8] ,
                           ~chunk_crc[23:16],
                           ~chunk_crc[31:24]};
              idat_data_len = 3'd4;
              idat_data_vld = chunk_crc_vld;
          end
      end
      else begin
          idat_data = 32'hFFFF_FFFF;
          idat_data_len = 3'd0;
          idat_data_vld = 1'b0;
      end
  end

  // IEND
  always @(*) begin
      if (png_out_st_iend) begin
          if (chunk_layout_st_length) begin
              iend_data = {chunk_length[7:0]  , 
                           chunk_length[15:8] ,
                           chunk_length[23:16],
                           chunk_length[31:24]};
              iend_data_len = 3'd4;
              iend_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 0)) begin
              iend_data = 32'hFFFF_FF49;
              iend_data_len = 3'd1;
              iend_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 1)) begin
              iend_data = 32'hFFFF_FF45;
              iend_data_len = 3'd1;
              iend_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 2)) begin
              iend_data = 32'hFFFF_FF4E;
              iend_data_len = 3'd1;
              iend_data_vld = 1'b1;
          end
          else if (chunk_layout_st_type & (stream_out_cnt == 3)) begin
              iend_data = 32'hFFFF_FF44;
              iend_data_len = 3'd1;
              iend_data_vld = 1'b1;
          end
          else if (chunk_layout_st_crc) begin
              iend_data = {~chunk_crc[7:0]  , 
                           ~chunk_crc[15:8] ,
                           ~chunk_crc[23:16],
                           ~chunk_crc[31:24]};
              iend_data_len = 3'd4;
              iend_data_vld = chunk_crc_vld;
          end
      end
      else begin
          iend_data = 32'hFFFF_FFFF;
          iend_data_len = 3'd0;
          iend_data_vld = 1'b0;
      end
  end

//--------------------------------------------
//    mix data from each segment together
//--------------------------------------------

  // mix data from each segment together
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          png_packing_data   <= `DLY 32'hFFFF_FFFF;
          png_packing_length <= `DLY 3'b0;
          png_packing_dvalid <= `DLY 1'b0;
      end
      else if (png_out_st_idle) begin
          png_packing_data   <= `DLY 32'hFFFF_FFFF;
          png_packing_length <= `DLY 3'b0;
          png_packing_dvalid <= `DLY 1'b0;
      end
      else if (png_out_st_sign) begin
          png_packing_data   <= `DLY sign_data;
          png_packing_length <= `DLY sign_data_len;
          png_packing_dvalid <= `DLY sign_data_vld;
      end
      else if (png_out_st_ihdr) begin
          png_packing_data   <= `DLY ihdr_data;
          png_packing_length <= `DLY ihdr_data_len;
          png_packing_dvalid <= `DLY ihdr_data_vld;
      end
      else if (png_out_st_idat) begin
          png_packing_data   <= `DLY idat_data;
          png_packing_length <= `DLY idat_data_len;
          png_packing_dvalid <= `DLY idat_data_vld;
      end
      else if (png_out_st_iend) begin
          png_packing_data   <= `DLY iend_data;
          png_packing_length <= `DLY iend_data_len;
          png_packing_dvalid <= `DLY iend_data_vld;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag <= `DLY 1'b0;
      end
      else begin
          last_data_flag <= `DLY png_iend_done;
      end
  end

  // shift png_sbuff_split to make stuff png_out_buf easier
  assign png_packing_data_shift_1 = png_out_byte_ptr[1] ? {png_packing_data[31:0]        , 16'hFFFF} : {16'hFFFF, png_packing_data[31:0]        };
  assign png_packing_data_shift_0 = png_out_byte_ptr[0] ? {png_packing_data_shift_1[47:0], 8'hFF   } : {8'hFF   , png_packing_data_shift_1[47:0]};

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          png_out_buf <= `DLY 56'hFF_FFFF_FFFF_FFFF;
      end
      else if (frame_start | frame_end) begin
          png_out_buf <= `DLY 56'hFF_FFFF_FFFF_FFFF;
      end
      else if (png_packing_dvalid & png_out_byte_ptr_ov) begin
          png_out_buf <= `DLY {32'hFFFF_FFFF, png_out_buf[55:32]} & png_packing_data_shift_0;
      end
      else if (png_packing_dvalid) begin
          png_out_buf <= `DLY png_out_buf & png_packing_data_shift_0;
      end
      else if (png_out_byte_ptr_ov) begin
          png_out_buf <= `DLY {32'hFFFF_FFFF, png_out_buf[55:32]};
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          png_out_buf_tail <= `DLY 24'h0;
      end
      else if (png_out_byte_ptr_ov & last_data_flag_out) begin
          png_out_buf_tail <= `DLY png_out_buf[55:32];
      end
  end

  // png file length counter
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          png_file_len_cnt <= `DLY 23'h0;
      end
      else if (frame_start | frame_end) begin
          png_file_len_cnt <= `DLY 23'h0;
      end
      else if (png_packing_dvalid) begin
          png_file_len_cnt <= `DLY png_file_len_cnt + {19'h0, png_packing_length};
      end
  end

  // png file length
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          png_file_len <= `DLY 23'h0;
      end
      else if (frame_end) begin
          png_file_len <= `DLY png_file_len_cnt;
      end
  end

  // png output buffer byte pointer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          png_out_byte_ptr <= `DLY 3'h0;
      end
      else if (frame_start | frame_end) begin
          png_out_byte_ptr <= `DLY 3'h0;
      end
      else if (png_packing_dvalid) begin
          png_out_byte_ptr <= `DLY png_out_byte_ptr_nxt;
      end
  end

  // next value of png_out_byte_ptr
  assign png_out_byte_ptr_nxt = png_out_byte_ptr + {1'b0, png_packing_length};

  // png_out_byte_ptr overflow
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          png_out_byte_ptr_ov <= `DLY 1'b0;
      end
      else begin
          png_out_byte_ptr_ov <= `DLY (png_out_byte_ptr_nxt[2] ^ png_out_byte_ptr[2]) & png_packing_dvalid;
      end
  end

  // last data flag of the output stage
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag_out <= `DLY 1'b0;
      end
      else begin
          last_data_flag_out <= `DLY (last_data_flag & png_packing_dvalid);
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag_d <= `DLY 1'b0;
      end
      else begin
          last_data_flag_d <= `DLY (png_out_byte_ptr_ov & last_data_flag_out & (|png_out_byte_ptr[1:0]));
      end
  end

  // frame end indicator
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          frame_end <= `DLY 1'b0;
      end
      else if (last_data_flag_out & (~png_out_byte_ptr_ov | ~(|png_out_byte_ptr[1:0]))) begin
          frame_end <= `DLY 1'b1;
      end
      else if (last_data_flag_d) begin
          frame_end <= `DLY 1'b1;
      end
      else begin
          frame_end <= `DLY 1'b0;
      end
  end

  // buffer flush when at least 8 bits data exist or png file end
  assign png_out_flush = png_out_byte_ptr_ov | last_data_flag_out | last_data_flag_d;

  assign png_out_valid = png_out_flush;
  assign png_out_data  = last_data_flag_d ? {8'hFF, png_out_buf_tail} : png_out_buf[31:0];

  // crc32 calculation
  png_crc32 png_crc32_u0(
    // global
    .clk                (clk                  ), // <i>  1b, global clock
    .rstn               (rstn                 ), // <i>  1b, global reset, active low
    // crc control
    .crc_init           (crc_init             ), // <i>  1b, crc initial, active high
    // crc data input
    .data_in            (crc_dat_in[7:0]      ), // <i>  8b, data input
    .data_in_vld        (crc_dat_in_vld       ), // <i>  1b, data input valid
    // crc data output
    .crc_out            (chunk_crc            ), // <o> 32b, crc data output
    .crc_out_vld        (chunk_crc_vld        )  // <o>  1b, crc data output valid
    );

  assign crc_init = chunk_layout_length_done;
  assign crc_dat_in = png_out_st_ihdr ? ihdr_data[7:0] :
                      png_out_st_idat ? idat_data[7:0] :
                                        iend_data[7:0] ;
  assign crc_dat_in_vld = (chunk_layout_st_type | chunk_layout_st_data) & 
                          (ihdr_data_vld | idat_data_vld | iend_data_vld);

  // adler32 calculation
  png_adler32 png_adler32_u0(
    // global
    .clk                (clk                  ), // <i>  1b, global clock
    .rstn               (rstn                 ), // <i>  1b, global reset, active low
    // adler32 control
    .adler32_init       (zlib_header_done     ), // <i>  1b, adler32 initial, active high
    // adler32 data input
    .data_in            (idat_data[7:0]       ), // <i>  8b, data input
    .data_in_vld        (zlib_dat_in_vld      ), // <i>  1b, data input valid
    // adler32 data output
    .adler32_out        (adler_data           ), // <o> 32b, adler32 data output
    .adler32_out_vld    (adler_data_vld       )  // <o>  1b, adler32 data output valid
    );

  assign zlib_dat_in_vld = zlib_st_data & (stream_out_cnt > 4) & idat_data_vld;

//--------------------------------------------
//                  debug
//--------------------------------------------

//integer   PNG_FILE;
//integer   PNG_PIC;
//integer   ADLER_DBG;
//integer   CRC_DBG;
//integer   out_cnt;

//initial begin
//    PNG_FILE = $fopen("png_file.txt", "wb");
//    PNG_PIC  = $fopen("png.png", "wb");
//    ADLER_DBG = $fopen("adler_dbg.txt", "wb");
//    CRC_DBG = $fopen("crc_dbg.txt", "wb");
//    out_cnt = 0;
//    wait (png_out_st_iend);
//    wait (png_out_st_idle);
//    #1000;
//    $fclose(PNG_FILE);
//    $fclose(PNG_PIC);
//    $fclose(ADLER_DBG);
//    $fclose(CRC_DBG);
//end

//always @(posedge clk) begin
//    if (zlib_dat_in_vld) begin
//        $fdisplay(ADLER_DBG, "%x %x", png_adler32_u0.adler32_out_nxt, idat_data[7:0]);
//    end
//end

//always @(posedge clk) begin
//    if (crc_dat_in_vld) begin
//        $fdisplay(CRC_DBG, "%x %x", png_crc32_u0.crc_out_nxt, crc_dat_in[7:0]);
//    end
//end

//always @(posedge clk) begin
//    if (png_out_valid) begin
//        $fdisplay(PNG_FILE, "%x", png_out_data[7:0]  );
//        $fdisplay(PNG_FILE, "%x", png_out_data[15:8] );
//        $fdisplay(PNG_FILE, "%x", png_out_data[23:16]);
//        $fdisplay(PNG_FILE, "%x", png_out_data[31:24]);
//        $fwrite(PNG_PIC, "%c", png_out_data[7:0]);
//        $fwrite(PNG_PIC, "%c", png_out_data[15:8]);
//        $fwrite(PNG_PIC, "%c", png_out_data[23:16]);
//        $fwrite(PNG_PIC, "%c", png_out_data[31:24]);
//        out_cnt = out_cnt + 4;
//    end
//end

endmodule
