`define DLY #1

module jpeg_packing64(
    // global
    clk               , // <i>  1b, global clock
    rstn              , // <i>  1b, global reset, active low
    // interface with registers
    lum_q_table       , // <i>  8b, lum quantization table coeff
    chr_q_table       , // <i>  8b, chr quantization table coeff
    pic_width         , // <i> 11b, picture width
    pic_height        , // <i> 11b, picture height
    h1                , // <i>  4b, conponent 1 h
    v1                , // <i>  4b, conponent 1 v
    h2                , // <i>  4b, conponent 2 h
    v2                , // <i>  4b, conponent 2 v
    h3                , // <i>  4b, conponent 3 h
    v3                , // <i>  4b, conponent 3 v
    jpeg_file_len     , // <o> 20b, jpeg file length indicator
    // read lum table/chr table control
    lum_q_rd          , // <o>  1b, lum quantization table read enable
    chr_q_rd          , // <o>  1b, chr quantization table read enable
    // entropy coded segment input
    ecs_out_valid     , // <i>  1b, huffman code output valid
    ecs_code          , // <i> 64b, huffman code
    ecs_length        , // <i>  7b, huffman code length
    ecs_eob           , // <i>  1b, eob flag
    // frame end indicator
    frame_end         , // <i>  1b, frame end indicator
    // stream output
    jpeg_out_valid    , // <o>  1b, jpeg stream output valid
    jpeg_out_data       // <o> 64b, jpeg stream output
    );

  // global
  input         clk               ; // <i>  1b, global clock
  input         rstn              ; // <i>  1b, global reset, active low
  // interface with registers
  input  [7:0]  lum_q_table       ; // <i>  8b, lum quantization table coeff
  input  [7:0]  chr_q_table       ; // <i>  8b, chr quantization table coeff
  input  [10:0] pic_width         ; // <i> 11b, picture width
  input  [10:0] pic_height        ; // <i> 11b, picture height
  input  [3:0]  h1                ; // <i>  4b, conponent 1 h
  input  [3:0]  v1                ; // <i>  4b, conponent 1 v
  input  [3:0]  h2                ; // <i>  4b, conponent 2 h
  input  [3:0]  v2                ; // <i>  4b, conponent 2 v
  input  [3:0]  h3                ; // <i>  4b, conponent 3 h
  input  [3:0]  v3                ; // <i>  4b, conponent 3 v
  output [19:0] jpeg_file_len     ; // <o> 20b, jpeg file length indicator
  // read lum table/huffman table control
  output        lum_q_rd          ; // <o>  1b, lum quantization table read enable
  output        chr_q_rd          ; // <o>  1b, chr quantization table read enable
  // entropy coded segment input
  input         ecs_out_valid     ; // <i>  1b, huffman code output valid
  input  [63:0] ecs_code          ; // <i> 64b, huffman code
  input  [6:0]  ecs_length        ; // <i>  7b, huffman code length
  input         ecs_eob           ; // <i>  1b, eob flag
  // frame end indicator
  input         frame_end         ; // <i>  1b, frame end indicator
  // stream output
  output        jpeg_out_valid    ; // <o>  1b, jpeg stream output valid
  output [63:0] jpeg_out_data     ; // <o> 64b, jpeg stream output

  reg    [19:0] jpeg_file_len             ; // jpeg file length indicator

  reg    [2:0]  jpeg_out_st               ; // jpeg_packing state machine current state
  reg    [2:0]  jpeg_out_nxt_st           ; // jpeg_packing state machine next state

  wire          jpeg_out_st_idle          ; // jpeg_packing state is idle
  wire          jpeg_out_st_soi           ; // jpeg_packing state is soi
  wire          jpeg_out_st_dqt           ; // jpeg_packing state is dqt  
  wire          jpeg_out_st_dht           ; // jpeg_packing state is dht  
  wire          jpeg_out_st_frmh          ; // jpeg_packing state is frmh 
  wire          jpeg_out_st_scanh         ; // jpeg_packing state is scanh
  wire          jpeg_out_st_ecs           ; // jpeg_packing state is ecs
  wire          jpeg_out_st_eoi           ; // jpeg_packing state is eoi  

  reg           jpeg_out_st_ecs_d1        ; // delay of jpeg_out_st_ecs
  reg           jpeg_out_st_ecs_d2        ; // delay of jpeg_out_st_ecs_d1
  reg           jpeg_out_st_eoi_d1        ; // delay of jpeg_out_st_eoi
  reg           jpeg_out_st_eoi_d2        ; // delay of jpeg_out_st_eoi_d1
  reg           jpeg_out_st_eoi_d3        ; // delay of jpeg_out_st_eoi_d2

  wire          jpeg_soi_done             ; // jpeg_out_st_soi     state is done
  wire          jpeg_dqt_done             ; // jpeg_out_st_dqt     state is done
  wire          jpeg_dht_done             ; // jpeg_out_st_dht     state is done
  wire          jpeg_frame_header_done    ; // jpeg_out_st_frmh    state is done
  wire          jpeg_scan_header_done     ; // jpeg_out_st_scanh   state is done
  wire          jpeg_ecs_done             ; // jpeg_out_st_ecs     state is done
  wire          jpeg_eoi_done             ; // jpeg_out_st_eoi     state is done

  reg    [16:0] stream_out_cnt            ; // count the data stream output

  wire   [7:0]  x_blocks                  ; // blocks count through x axis
  wire   [7:0]  y_blocks                  ; // blocks count through y axis
  wire   [16:0] total_blocks              ; // total blocks count in picture

  wire   [63:0] soi_data                  ; // data used in soi
  wire   [6:0]  soi_data_len              ; // data length used in soi
  reg    [63:0] dqt_data                  ; // data used in dqt
  reg    [6:0]  dqt_data_len              ; // data length used in dqt
  reg    [63:0] dht_data                  ; // data used in dht
  reg    [6:0]  dht_data_len              ; // data length used in dht
  reg    [63:0] frmh_data                 ; // data used in frmh
  reg    [6:0]  frmh_data_len             ; // data length used in frmh
  reg    [63:0] scanh_data                ; // data used in scanh
  reg    [6:0]  scanh_data_len            ; // data length used in scanh
  wire   [63:0] eoi_data                  ; // data used in eoi
  wire   [6:0]  eoi_data_len              ; // data length used in eoi

  wire   [5:0]  huffman_table_addr        ; // huffman table address

  reg    [63:0] jpeg_packing_data         ; // data to be packetized, selected from each segment(soi/dht/dqt...)
  reg    [6:0]  jpeg_packing_length       ; // data length to be packetized
  reg           jpeg_packing_dvalid       ; // packing data valid indicator

  wire  [126:0] jpeg_packing_data_shift_0 ; // jpeg_packing data shift
  wire  [125:0] jpeg_packing_data_shift_1 ; // jpeg_packing data shift
  wire  [123:0] jpeg_packing_data_shift_2 ; // jpeg_packing data shift
  wire  [119:0] jpeg_packing_data_shift_3 ; // jpeg_packing data shift
  wire  [111:0] jpeg_packing_data_shift_4 ; // jpeg_packing data shift
  wire   [95:0] jpeg_packing_data_shift_5 ; // jpeg_packing data shift

  reg   [126:0] jpeg_pack_buf             ; // packing data output buffer
  reg    [7:0]  ecs_byte_flag             ; // indicates which byte contains ecs

  reg    [6:0]  bit_ptr                   ; // current data bit position in jpeg_pack_buf
  wire   [6:0]  bit_ptr_nxt               ; // next value of bit_ptr
  wire   [6:0]  bit_ptr_add               ; // bit_ptr add new data length
  reg           bit_ptr_ov                ; // bit_ptr overflow

  reg           last_data_flag            ; // last data flag to end jpeg encoding task

  wire          jpeg_pack_buf_flush       ; // flush jpeg_pack_buf

  reg           last_data_flag_p1         ; // last data flag used in stuff pipeline 1
  reg           jpeg_stuff_buf_valid_p1   ; // jpeg_stuff_buf valid in pipeline 1
  reg    [3:0]  jpeg_stuff_buf_len_p1     ; // jpeg_stuff_buf effective length in pipeline 1, unit in byte
  reg    [63:0] jpeg_stuff_buf_p1         ; // jpeg_stuff_buf in pipeline 1
  wire   [7:0]  ecs_byte_flag_p1          ; // ecs_byte_flag in stuff pipeline 1
  wire          byte_stuff_en_p1          ; // byte 0 stuff enable in stuff pipeline 1
  wire   [71:0] jpeg_stuff_p1             ; // jpeg_pack_buf data after stuffed at byte 0 in pipeline 1
  wire   [3:0]  jpeg_stuff_len_p1         ; // jpeg_stuff_p1 effective byte length in pipeline 1

  wire          last_data_flag_p2         ; // last data flag used in stuff pipeline 2
  wire          jpeg_stuff_buf_valid_p2   ; // jpeg_stuff_buf valid in pipeline 2
  wire   [3:0]  jpeg_stuff_buf_len_p2     ; // jpeg_stuff_buf effective length in pipeline 2
  wire   [71:0] jpeg_stuff_buf_p2         ; // jpeg_stuff_buf in pipeline 2
  wire   [6:0]  ecs_byte_flag_p2          ; // ecs_byte_flag in stuff pipeline 2
  wire          byte_stuff_en_p2          ; // byte 1 stuff enable in stuff pipeline 2
  wire   [79:0] jpeg_stuff_p2             ; // jpeg_pack_buf data after stuffed at byte 1 in pipeline 2
  wire   [3:0]  jpeg_stuff_len_p2         ; // jpeg_stuff_p2 effective byte length in pipeline 2

  reg           last_data_flag_p3         ; // last data flag used in stuff pipeline 3
  reg           jpeg_stuff_buf_valid_p3   ; // jpeg_stuff_buf valid in pipeline 3
  reg    [3:0]  jpeg_stuff_buf_len_p3     ; // jpeg_stuff_buf effective length in pipeline 3
  reg    [79:0] jpeg_stuff_buf_p3         ; // jpeg_stuff_buf in pipeline 3
  reg    [5:0]  ecs_byte_flag_p3          ; // ecs_byte_flag in stuff pipeline 3
  wire          byte_stuff_en_p3          ; // byte 2 stuff enable in stuff pipeline 3
  wire   [87:0] jpeg_stuff_p3             ; // jpeg_pack_buf data after stuffed at byte 2 in pipeline 3
  wire   [3:0]  jpeg_stuff_len_p3         ; // jpeg_stuff_p3 effective byte length in pipeline 3

  wire          last_data_flag_p4         ; // last data flag used in stuff pipeline 4
  wire          jpeg_stuff_buf_valid_p4   ; // jpeg_stuff_buf valid in pipeline 4
  wire   [3:0]  jpeg_stuff_buf_len_p4     ; // jpeg_stuff_buf effective length in pipeline 4
  wire   [87:0] jpeg_stuff_buf_p4         ; // jpeg_stuff_buf in pipeline 4
  wire   [4:0]  ecs_byte_flag_p4          ; // ecs_byte_flag in stuff pipeline 4
  wire          byte_stuff_en_p4          ; // byte 3 stuff enable in stuff pipeline 4
  wire   [95:0] jpeg_stuff_p4             ; // jpeg_pack_buf data after stuffed at byte 3 in pipeline 4
  wire   [3:0]  jpeg_stuff_len_p4         ; // jpeg_stuff_p4 effective byte length in pipeline 4

  reg           last_data_flag_p5         ; // last data flag used in stuff pipeline 5
  reg           jpeg_stuff_buf_valid_p5   ; // jpeg_stuff_buf valid in pipeline 5
  reg    [3:0]  jpeg_stuff_buf_len_p5     ; // jpeg_stuff_buf effective length in pipeline 5
  reg    [95:0] jpeg_stuff_buf_p5         ; // jpeg_stuff_buf in pipeline 5
  reg    [3:0]  ecs_byte_flag_p5          ; // ecs_byte_flag in stuff pipeline 5
  wire          byte_stuff_en_p5          ; // byte 4 stuff enable in stuff pipeline 5
  wire  [103:0] jpeg_stuff_p5             ; // jpeg_pack_buf data after stuffed at byte 4 in pipeline 5
  wire   [3:0]  jpeg_stuff_len_p5         ; // jpeg_stuff_p5 effective byte length in pipeline 5

  wire          last_data_flag_p6         ; // last data flag used in stuff pipeline 6
  wire          jpeg_stuff_buf_valid_p6   ; // jpeg_stuff_buf valid in pipeline 6
  wire   [3:0]  jpeg_stuff_buf_len_p6     ; // jpeg_stuff_buf effective length in pipeline 6
  wire  [103:0] jpeg_stuff_buf_p6         ; // jpeg_stuff_buf in pipeline 6
  wire   [2:0]  ecs_byte_flag_p6          ; // ecs_byte_flag in stuff pipeline 6
  wire          byte_stuff_en_p6          ; // byte 5 stuff enable in stuff pipeline 6
  wire  [111:0] jpeg_stuff_p6             ; // jpeg_pack_buf data after stuffed at byte 5 in pipeline 6
  wire   [3:0]  jpeg_stuff_len_p6         ; // jpeg_stuff_p6 effective byte length in pipeline 6

  reg           last_data_flag_p7         ; // last data flag used in stuff pipeline 7
  reg           jpeg_stuff_buf_valid_p7   ; // jpeg_stuff_buf valid in pipeline 7
  reg    [3:0]  jpeg_stuff_buf_len_p7     ; // jpeg_stuff_buf effective length in pipeline 7
  reg   [111:0] jpeg_stuff_buf_p7         ; // jpeg_stuff_buf in pipeline 7
  reg    [1:0]  ecs_byte_flag_p7          ; // ecs_byte_flag in stuff pipeline 7
  wire          byte_stuff_en_p7          ; // byte 6 stuff enable in stuff pipeline 7
  wire  [119:0] jpeg_stuff_p7             ; // jpeg_pack_buf data after stuffed at byte 6 in pipeline 7
  wire   [3:0]  jpeg_stuff_len_p7         ; // jpeg_stuff_p7 effective byte length in pipeline 7

  wire          last_data_flag_p8         ; // last data flag used in stuff pipeline 8
  wire          jpeg_stuff_buf_valid_p8   ; // jpeg_stuff_buf valid in pipeline 8
  wire   [3:0]  jpeg_stuff_buf_len_p8     ; // jpeg_stuff_buf effective length in pipeline 8
  wire  [119:0] jpeg_stuff_buf_p8         ; // jpeg_stuff_buf in pipeline 8
  wire          ecs_byte_flag_p8          ; // ecs_byte_flag in stuff pipeline 8
  wire          byte_stuff_en_p8          ; // byte 7 stuff enable in stuff pipeline 8
  wire  [127:0] jpeg_stuff_p8             ; // jpeg_pack_buf data after stuffed at byte 7 in pipeline 8
  wire   [4:0]  jpeg_stuff_len_p8         ; // jpeg_stuff_p8 effective byte length in pipeline 8

  wire          elapse_fifo_wr            ;
  wire          elapse_fifo_rd            ;
  wire  [133:0] elapse_fifo_din           ;
  wire  [133:0] elapse_fifo_dout          ;
  wire          elapse_fifo_empty         ;

  reg   [127:0] jpeg_stuff_fdout          ;
  reg    [4:0]  jpeg_stuff_len_fdout      ;
  reg           last_data_flag_fdout      ;

  reg           elapse_fifo_ext_valid     ;

  wire          jpeg_stuff_len_gt_8       ; // jpeg stuff length greater than 8
  wire          jpeg_stuff_len_le_8       ; // jpeg stuff length less than or equal to 8

  wire          elapse_data_flush         ; // flush jpeg_stuff_fdout data

  wire   [63:0] jpeg_stuff_split          ; // data split from jpeg_stuff_fdout
  wire   [4:0]  jpeg_stuff_split_len      ; // data length of jpeg_stuff_split
  wire          jpeg_stuff_split_valid    ; // data valid of jpeg_stuff_split

  wire   [95:0] jpeg_stuff_split_shift_2  ; // jpeg_stuff_split data shift
  wire  [111:0] jpeg_stuff_split_shift_1  ; // jpeg_stuff_split data shift
  wire  [119:0] jpeg_stuff_split_shift_0  ; // jpeg_stuff_split data shift

  reg   [119:0] jpeg_out_buf              ; // jpeg output buffer
  reg    [55:0] jpeg_out_buf_tail         ; // jpeg output buffer tail, data valid when jpeg_out_byte_ptr overflow and last_data_flag

  reg    [3:0]  jpeg_out_byte_ptr         ; // current byte pointer in jpeg_out_buffer
  wire   [3:0]  jpeg_out_byte_ptr_nxt     ; // next value of jpeg_out_byte_ptr
  reg           jpeg_out_byte_ptr_ov      ; // jpeg_out_byte_ptr overflow
  reg           last_data_flag_out        ; // last data flag at output stage
  reg           last_data_flag_d          ; // delay of last_data_flag_out

  wire          jpeg_out_flush            ; // flush the output buffer

  wire   [15:0] huffman_table_len         ; // huffman table length
  wire   [63:0] huffman_table_data        ; // huffman table data

  // state machine parameter define
  parameter JPEG_IDLE    = 3'h0;
  parameter JPEG_SOI     = 3'h1;
  parameter JPEG_DQT     = 3'h2;
  parameter JPEG_DHT     = 3'h3;
  parameter JPEG_FRMH    = 3'h4;
  parameter JPEG_SCANH   = 3'h5;
  parameter JPEG_ECS     = 3'h6;
  parameter JPEG_EOI     = 3'h7;

//--------------------------------------------
//    packing state control
//--------------------------------------------

  // jpeg_out packing state machine
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_st <= `DLY JPEG_IDLE;
      end
      else begin
          jpeg_out_st <= `DLY jpeg_out_nxt_st;
      end
  end

  // next state of jpeg_out_st
  always @(*) begin
      jpeg_out_nxt_st = JPEG_IDLE;
      case (jpeg_out_st)
          JPEG_IDLE:
          begin
              if (frame_end)
                  jpeg_out_nxt_st = JPEG_SOI;
              else
                  jpeg_out_nxt_st = JPEG_IDLE;
          end
          JPEG_SOI:
          begin
              if (jpeg_soi_done)
                  jpeg_out_nxt_st = JPEG_DQT;
              else
                  jpeg_out_nxt_st = JPEG_SOI;
          end
          JPEG_DQT:
          begin
              if (jpeg_dqt_done)
                  jpeg_out_nxt_st = JPEG_DHT;
              else
                  jpeg_out_nxt_st = JPEG_DQT;
          end
          JPEG_DHT:
          begin
              if (jpeg_dht_done)
                  jpeg_out_nxt_st = JPEG_FRMH;
              else
                  jpeg_out_nxt_st = JPEG_DHT;
          end
          JPEG_FRMH:
          begin
              if (jpeg_frame_header_done)
                  jpeg_out_nxt_st = JPEG_SCANH;
              else
                  jpeg_out_nxt_st = JPEG_FRMH;
          end
          JPEG_SCANH:
          begin
              if (jpeg_scan_header_done)
                  jpeg_out_nxt_st = JPEG_ECS;
              else
                  jpeg_out_nxt_st = JPEG_SCANH;
          end
          JPEG_ECS:
          begin
              if (jpeg_ecs_done)
                  jpeg_out_nxt_st = JPEG_EOI;
              else
                  jpeg_out_nxt_st = JPEG_ECS;
          end
          JPEG_EOI:
          begin
              if (jpeg_eoi_done)
                  jpeg_out_nxt_st = JPEG_IDLE;
              else
                  jpeg_out_nxt_st = JPEG_EOI;
          end
          default:
                  jpeg_out_nxt_st = JPEG_IDLE;
      endcase
  end

  // each state indicator
  assign jpeg_out_st_idle    = (jpeg_out_st == JPEG_IDLE    );
  assign jpeg_out_st_soi     = (jpeg_out_st == JPEG_SOI     );
  assign jpeg_out_st_dqt     = (jpeg_out_st == JPEG_DQT     );
  assign jpeg_out_st_dht     = (jpeg_out_st == JPEG_DHT     );
  assign jpeg_out_st_frmh    = (jpeg_out_st == JPEG_FRMH    );
  assign jpeg_out_st_scanh   = (jpeg_out_st == JPEG_SCANH   );
  assign jpeg_out_st_ecs     = (jpeg_out_st == JPEG_ECS     );
  assign jpeg_out_st_eoi     = (jpeg_out_st == JPEG_EOI     );

  // stream out data count in each state
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          stream_out_cnt <= `DLY 0;
      end
      else if (jpeg_out_st != jpeg_out_nxt_st) begin
          stream_out_cnt <= `DLY 0;
      end
      else if (~jpeg_out_st_idle & ~jpeg_out_st_ecs) begin
          stream_out_cnt <= `DLY stream_out_cnt + 1;
      end
      else if (jpeg_out_st_ecs) begin // in ecs state, stream_out_cnt is used to count blocks
          if (ecs_out_valid & ecs_eob) begin
              stream_out_cnt <= `DLY stream_out_cnt + 1;
          end
      end
  end

  // done indicator according to the corresponding data process
  assign jpeg_soi_done          = jpeg_out_st_soi     & (stream_out_cnt == 0           );
  assign jpeg_dqt_done          = jpeg_out_st_dqt     & (stream_out_cnt == 129         );
  assign jpeg_dht_done          = jpeg_out_st_dht     & (stream_out_cnt == 52          );
  assign jpeg_frame_header_done = jpeg_out_st_frmh    & (stream_out_cnt == 2           );
  assign jpeg_scan_header_done  = jpeg_out_st_scanh   & (stream_out_cnt == 1           );
  assign jpeg_ecs_done          = jpeg_out_st_ecs     & (stream_out_cnt == total_blocks);
  assign jpeg_eoi_done          = jpeg_out_st_eoi     & (stream_out_cnt == 0           );

  // calc the block counts in the picture
  assign x_blocks = pic_width[10:3]  + (|pic_width[2:0] );
  assign y_blocks = pic_height[10:3] + (|pic_height[2:0]);
  assign total_blocks = x_blocks*y_blocks*3;

//--------------------------------------------
//    data to be packetized in each segment
//--------------------------------------------

  // soi data and length
  assign soi_data = 64'hFFD8_FFFF_FFFF_FFFF;
  assign soi_data_len = 7'd16;

  // dqt data and length
  always @(*) begin
      if (jpeg_out_st_dqt) begin
          if (stream_out_cnt == 0) begin
              dqt_data = 64'hFFDB_0084_00FF_FFFF;
              dqt_data_len = 7'd40;
          end
          else if ((stream_out_cnt >= 1) & (stream_out_cnt <= 64)) begin
              dqt_data = {lum_q_table, 56'hFF_FFFF_FFFF_FFFF};
              dqt_data_len = 7'd8;
          end
          else if (stream_out_cnt == 65) begin
              dqt_data = {8'h01, 56'hFF_FFFF_FFFF_FFFF};
              dqt_data_len = 7'd8;
          end
          else begin // else if ((stream_out_cnt >= 66) & (stream_out_cnt <= 129))
              dqt_data = {chr_q_table, 56'hFF_FFFF_FFFF_FFFF};
              dqt_data_len = 7'd8;
          end
      end
      else begin
          dqt_data = 64'hFFFF_FFFF_FFFF_FFFF;
          dqt_data_len = 7'd0;
      end
  end

  // quantization table read enable
  assign lum_q_rd = jpeg_out_st_dqt & (stream_out_cnt >= 0 ) & (stream_out_cnt <= 63 );
  assign chr_q_rd = jpeg_out_st_dqt & (stream_out_cnt >= 65) & (stream_out_cnt <= 128);

  // huffman table length
  assign huffman_table_len = 16'h01A2;

  // dht data and length
  always @(*) begin
      if (jpeg_out_st_dht) begin
          if (stream_out_cnt == 0) begin
              dht_data = {16'hFFC4, huffman_table_len[15:0], 32'hFFFF_FFFF};
              dht_data_len = 7'd32;
          end
          else begin // if (stream_out_cnt >= 1) begin
              dht_data = huffman_table_data;
              dht_data_len = 7'd64;
          end
      end
      else begin
          dht_data = 64'hFFFF_FFFF_FFFF_FFFF;
          dht_data_len = 7'd0;
      end
  end

  assign huffman_table_addr = stream_out_cnt[5:0];

  // frame header data and length
  always @(*) begin
      if (jpeg_out_st_frmh) begin
          if (stream_out_cnt == 0) begin
              frmh_data = {32'hFFC0_0011, 8'h8, {5'h0, pic_height[10:0]}, {5'h0, pic_width[10:8]}};
              frmh_data_len = 7'd64;
          end
          else if (stream_out_cnt == 1) begin
              frmh_data = {pic_width[7:0], 8'h3, 8'h1, {h1, v1}, 8'h0, 8'h2, {h2, v2}, 8'h1};
              frmh_data_len = 7'd64;
          end
          else begin // if (stream_out_cnt == 2) begin
              frmh_data = {8'h3, {h3, v3}, 8'h1, 40'hFF_FFFF_FFFF};
              frmh_data_len = 7'd24;
          end
      end
      else begin
          frmh_data = 64'hFFFF_FFFF_FFFF_FFFF;
          frmh_data_len = 7'd0;
      end
  end

  // scan header data and length
  always @(*) begin
      if (jpeg_out_st_scanh) begin
          if (stream_out_cnt == 0) begin
              scanh_data = 64'hFFDA_000C_0301_0002;
              scanh_data_len = 7'd64;
          end
          else begin // if (stream_out_cnt == 1) begin
              scanh_data = 64'h1103_1100_3F00_FFFF;
              scanh_data_len = 7'd48;
          end
      end
      else begin
          scanh_data = 64'hFFFF_FFFF_FFFF_FFFF;
          scanh_data_len = 7'd0;
      end
  end

  // eoi data and length
  assign eoi_data = 64'hFFD9_FFFF_FFFF_FFFF;
  assign eoi_data_len = 7'd16;

//--------------------------------------------
//    mix data from each segment together
//--------------------------------------------

  // mix data from each segment together
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_packing_data   <= `DLY 64'hFFFF_FFFF_FFFF_FFFF;
          jpeg_packing_length <= `DLY 7'b0;
          jpeg_packing_dvalid <= `DLY 1'b0;
      end
      else if (jpeg_out_st_idle) begin
          jpeg_packing_data   <= `DLY 64'hFFFF_FFFF_FFFF_FFFF;
          jpeg_packing_length <= `DLY 7'b0;
          jpeg_packing_dvalid <= `DLY 1'b0;
      end
      else if (jpeg_out_st_soi) begin
          jpeg_packing_data   <= `DLY soi_data;
          jpeg_packing_length <= `DLY soi_data_len;
          jpeg_packing_dvalid <= `DLY 1'b1;
      end
      else if (jpeg_out_st_dqt) begin
          jpeg_packing_data   <= `DLY dqt_data;
          jpeg_packing_length <= `DLY dqt_data_len;
          jpeg_packing_dvalid <= `DLY 1'b1;
      end
      else if (jpeg_out_st_dht) begin
          jpeg_packing_data   <= `DLY dht_data;
          jpeg_packing_length <= `DLY dht_data_len;
          jpeg_packing_dvalid <= `DLY 1'b1;
      end
      else if (jpeg_out_st_frmh) begin
          jpeg_packing_data   <= `DLY frmh_data;
          jpeg_packing_length <= `DLY frmh_data_len;
          jpeg_packing_dvalid <= `DLY 1'b1;
      end
      else if (jpeg_out_st_scanh) begin
          jpeg_packing_data   <= `DLY scanh_data;
          jpeg_packing_length <= `DLY scanh_data_len;
          jpeg_packing_dvalid <= `DLY 1'b1;
      end
      else if (jpeg_out_st_ecs) begin
          jpeg_packing_data   <= `DLY ecs_code;
          jpeg_packing_length <= `DLY ecs_length;
          jpeg_packing_dvalid <= `DLY ecs_out_valid;
      end
      else if (jpeg_out_st_eoi) begin
          jpeg_packing_data   <= `DLY eoi_data;
          jpeg_packing_length <= `DLY eoi_data_len;
          jpeg_packing_dvalid <= `DLY 1'b1;
      end
  end

  // delay jpeg_out_st_eoi, sync with jpeg_packing_dvalid
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_st_eoi_d1 <= `DLY 1'b0;
      end
      else begin
          jpeg_out_st_eoi_d1 <= `DLY jpeg_out_st_eoi;
      end
  end

  // delay jpeg_out_st_eoi to end the jpeg packing task
  // sync with jpeg_packing_dvalid and jpeg_packing_data
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_st_ecs_d1  <= `DLY 1'b0;
      end
      else begin
          jpeg_out_st_ecs_d1  <= `DLY jpeg_out_st_ecs ;
      end
  end

  // shift jpeg_packing_data to make stuff jpeg_pack_buf easier
  assign jpeg_packing_data_shift_5 = bit_ptr[5] ? {32'hFFFF_FFFF, jpeg_packing_data[63:0]         } : {jpeg_packing_data[63:0]         , 32'hFFFF_FFFF};
  assign jpeg_packing_data_shift_4 = bit_ptr[4] ? {16'hFFFF     , jpeg_packing_data_shift_5[95:0] } : {jpeg_packing_data_shift_5[95:0] , 16'hFFFF     };
  assign jpeg_packing_data_shift_3 = bit_ptr[3] ? {8'hFF        , jpeg_packing_data_shift_4[111:0]} : {jpeg_packing_data_shift_4[111:0], 8'hFF        };
  assign jpeg_packing_data_shift_2 = bit_ptr[2] ? {4'hF         , jpeg_packing_data_shift_3[119:0]} : {jpeg_packing_data_shift_3[119:0], 4'hF         };
  assign jpeg_packing_data_shift_1 = bit_ptr[1] ? {2'h3         , jpeg_packing_data_shift_2[123:0]} : {jpeg_packing_data_shift_2[123:0], 2'h3         };
  assign jpeg_packing_data_shift_0 = bit_ptr[0] ? {1'b1         , jpeg_packing_data_shift_1[125:0]} : {jpeg_packing_data_shift_1[125:0], 1'b1         };

//--------------------------------------------
//    stuff bitstream into packing buffer
//--------------------------------------------

  // jpeg packing buffer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_pack_buf <= `DLY 127'h7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
      end
      else if (jpeg_packing_dvalid & bit_ptr_ov) begin
          jpeg_pack_buf <= `DLY {jpeg_pack_buf[62:0], 64'hFFFF_FFFF_FFFF_FFFF} & jpeg_packing_data_shift_0;
      end
      else if (jpeg_packing_dvalid) begin
          jpeg_pack_buf <= `DLY jpeg_pack_buf & jpeg_packing_data_shift_0;
      end
      else if (bit_ptr_ov) begin
          jpeg_pack_buf <= `DLY {jpeg_pack_buf[62:0], 64'hFFFF_FFFF_FFFF_FFFF};
      end
  end

  // delay jpeg_out_st_ecs
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_st_ecs_d2  <= `DLY 1'b0;
      end
      else if (jpeg_packing_dvalid) begin
          jpeg_out_st_ecs_d2  <= `DLY jpeg_out_st_ecs_d1;
      end
  end

  // ecs byte flag to flag which byte contains ecs
  // sync with jpeg_pack_buf
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          ecs_byte_flag <= `DLY 8'h0;
      end
      else if (~jpeg_out_st_ecs_d2 & jpeg_out_st_ecs_d1) begin
          ecs_byte_flag <= `DLY (bit_ptr[5:3] == 0) ? 8'hFF :
                                (bit_ptr[5:3] == 1) ? 8'h7F :
                                (bit_ptr[5:3] == 2) ? 8'h3F :
                                (bit_ptr[5:3] == 3) ? 8'h1F :
                                (bit_ptr[5:3] == 4) ? 8'h0F :
                                (bit_ptr[5:3] == 5) ? 8'h07 :
                                (bit_ptr[5:3] == 6) ? 8'h03 :
                                                      8'h01 ;
      end
      else if (jpeg_out_st_ecs_d2 & ~jpeg_out_st_ecs_d1) begin
          ecs_byte_flag <= `DLY (bit_ptr[5:3] == 0) ? 8'h00 :
                                (bit_ptr[5:3] == 1) ? 8'h80 :
                                (bit_ptr[5:3] == 2) ? 8'hC0 :
                                (bit_ptr[5:3] == 3) ? 8'hE0 :
                                (bit_ptr[5:3] == 4) ? 8'hF0 :
                                (bit_ptr[5:3] == 5) ? 8'hF8 :
                                (bit_ptr[5:3] == 6) ? 8'hFC :
                                                      8'hFE ;
      end
      else if (jpeg_out_st_ecs_d1 & bit_ptr_ov) begin
          ecs_byte_flag <= `DLY 8'hFF;
      end
  end

  // jpeg pack buffer bit pointer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          bit_ptr <= `DLY 7'h0;
      end
      else if (jpeg_packing_dvalid) begin
          bit_ptr <= `DLY bit_ptr_nxt;
      end
  end

  // bit_ptr add new input code length
  assign bit_ptr_add = bit_ptr + {1'b0, jpeg_packing_length};
  // next value of bit_ptr, when ecs done, data output should be 8-bit aligned
  assign bit_ptr_nxt = jpeg_ecs_done ? (bit_ptr_add[6:0] + {2'b0, (|bit_ptr_add[2:0]), 3'b0}) & 7'h78 : bit_ptr_add[6:0];

  // bit_ptr overflow
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          bit_ptr_ov <= `DLY 1'b0;
      end
      else begin
          bit_ptr_ov <= `DLY (bit_ptr_nxt[6] ^ bit_ptr[6]) & jpeg_packing_dvalid;
      end
  end

  // delay jpeg_out_st_eoi to end the jpeg packing task
  // jpeg_out_st_eoi_d2 sync with jpeg_pack_buf
  // jpeg_out_st_eoi_d3 is one cycle delay of jpeg_out_st_eoi_d2
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_st_eoi_d2 <= `DLY 1'b0;
          jpeg_out_st_eoi_d3 <= `DLY 1'b0;
      end
      else begin
          jpeg_out_st_eoi_d2 <= `DLY jpeg_out_st_eoi_d1;
          jpeg_out_st_eoi_d3 <= `DLY jpeg_out_st_eoi_d2;
      end
  end

  // leave jpeg_out_st_eoi state means the last data have been filled into
  // jpeg_pack_buf, sync with jpeg_out_st_eoi_d3 but not jpeg_out_st_eoi_d2 to
  // avoid collision with bit_ptr_ov
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag <= `DLY 1'b0;
      end
      else begin
          last_data_flag <= `DLY (jpeg_out_st_eoi_d3 & ~jpeg_out_st_eoi_d2);
      end
  end

  // buffer flush when at least 8 bits data exist or jpeg file end
  assign jpeg_pack_buf_flush = bit_ptr_ov | last_data_flag;

//--------------------------------------------
//    stuff 0x00 after 0xff
//--------------------------------------------

  // fill in jpeg_stuff_buf_p1 to do the stuff process
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_stuff_buf_p1[63:0] <= `DLY 64'h0;
      end
      else if (jpeg_pack_buf_flush) begin
          jpeg_stuff_buf_p1[63:0] <= `DLY jpeg_pack_buf[126:63];
      end
  end

  // jpeg_stuff_buf_p1 effective data length
  // sync with jpeg_stuff_buf_p1
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_stuff_buf_len_p1 <= `DLY 4'h0;
      end
      else if (jpeg_pack_buf_flush) begin
          if (last_data_flag) begin
              jpeg_stuff_buf_len_p1 <= `DLY {1'b0, bit_ptr[5:3]};
          end
          else begin
              jpeg_stuff_buf_len_p1 <= `DLY 4'h8;
          end
      end
  end

  // jpeg_stuff_buf_valid_p1
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_stuff_buf_valid_p1 <= `DLY 1'b0;
          last_data_flag_p1       <= `DLY 1'b0;
      end
      else begin
          jpeg_stuff_buf_valid_p1 <= `DLY jpeg_pack_buf_flush;
          last_data_flag_p1       <= `DLY last_data_flag;
      end
  end

  // if ecs byte at byte 0 and 0xff is found, then 0x00 is stuffed
  assign ecs_byte_flag_p1 = ecs_byte_flag;
  assign byte_stuff_en_p1 = (ecs_byte_flag_p1[0] & (jpeg_stuff_buf_p1[7:0] == 8'hFF)); 
  assign jpeg_stuff_p1 = byte_stuff_en_p1 ? {jpeg_stuff_buf_p1[63:0], 8'h00} :
                                            {jpeg_stuff_buf_p1[63:0], 8'hFF} ;
  assign jpeg_stuff_len_p1 = byte_stuff_en_p1 ? (jpeg_stuff_buf_len_p1 + 1) : jpeg_stuff_buf_len_p1;

  // jpeg_pack_buf pipeline 2
  assign last_data_flag_p2       = last_data_flag_p1      ;
  assign jpeg_stuff_buf_valid_p2 = jpeg_stuff_buf_valid_p1;
  assign jpeg_stuff_buf_len_p2   = jpeg_stuff_len_p1      ;
  assign jpeg_stuff_buf_p2       = jpeg_stuff_p1          ;
  assign ecs_byte_flag_p2        = ecs_byte_flag_p1[7:1]  ;

  // if ecs byte at byte 1 and 0xff is found, then 0x00 is stuffed
  assign byte_stuff_en_p2  = (ecs_byte_flag_p2[0] & (jpeg_stuff_buf_p2[23:16] == 8'hFF));
  assign jpeg_stuff_p2 = byte_stuff_en_p2 ? {jpeg_stuff_buf_p2[71:16], 8'h00, jpeg_stuff_buf_p2[15:0]} :
                                            {jpeg_stuff_buf_p2[71:0] , 8'hFF}                        ;
  assign jpeg_stuff_len_p2 = byte_stuff_en_p2 ? (jpeg_stuff_buf_len_p2 + 1) : jpeg_stuff_buf_len_p2;

  // jpeg_pack_buf pipeline 3
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag_p3       <= `DLY 1'b0;
          jpeg_stuff_buf_valid_p3 <= `DLY 1'b0;
          jpeg_stuff_buf_len_p3   <= `DLY 7'h0;
          jpeg_stuff_buf_p3       <= `DLY 80'h0;
          ecs_byte_flag_p3        <= `DLY 6'h0;
      end
      else begin
          last_data_flag_p3       <= `DLY last_data_flag_p2      ;
          jpeg_stuff_buf_valid_p3 <= `DLY jpeg_stuff_buf_valid_p2;
          jpeg_stuff_buf_len_p3   <= `DLY jpeg_stuff_len_p2      ;
          jpeg_stuff_buf_p3       <= `DLY jpeg_stuff_p2          ;
          ecs_byte_flag_p3        <= `DLY ecs_byte_flag_p2[6:1]  ;
      end
  end

  // if ecs byte at byte 2 and 0xff is found, then 0x00 is stuffed
  assign byte_stuff_en_p3  = (ecs_byte_flag_p3[0] & (jpeg_stuff_buf_p3[39:32] == 8'hFF));
  assign jpeg_stuff_p3 = byte_stuff_en_p3 ? {jpeg_stuff_buf_p3[79:32], 8'h00, jpeg_stuff_buf_p3[31:0]} :
                                            {jpeg_stuff_buf_p3[79:0] , 8'hFF}                        ;
  assign jpeg_stuff_len_p3 = byte_stuff_en_p3 ? (jpeg_stuff_buf_len_p3 + 1) : jpeg_stuff_buf_len_p3;

  // jpeg_pack_buf pipeline 4
  assign last_data_flag_p4       = last_data_flag_p3      ;
  assign jpeg_stuff_buf_valid_p4 = jpeg_stuff_buf_valid_p3;
  assign jpeg_stuff_buf_len_p4   = jpeg_stuff_len_p3      ;
  assign jpeg_stuff_buf_p4       = jpeg_stuff_p3          ;
  assign ecs_byte_flag_p4        = ecs_byte_flag_p3[5:1]  ;

  // if ecs byte at byte 3 and 0xff is found, then 0x00 is stuffed
  assign byte_stuff_en_p4  = (ecs_byte_flag_p4[0] & (jpeg_stuff_buf_p4[55:48] == 8'hFF));
  assign jpeg_stuff_p4 = byte_stuff_en_p4 ? {jpeg_stuff_buf_p4[87:48], 8'h00, jpeg_stuff_buf_p4[47:0]} :
                                            {jpeg_stuff_buf_p4[87:0] , 8'hFF}                        ;
  assign jpeg_stuff_len_p4 = byte_stuff_en_p4 ? (jpeg_stuff_buf_len_p4 + 1) : jpeg_stuff_buf_len_p4;

  // jpeg_pack_buf pipeline 5
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag_p5       <= `DLY 1'b0;
          jpeg_stuff_buf_valid_p5 <= `DLY 1'b0;
          jpeg_stuff_buf_len_p5   <= `DLY 7'h0;
          jpeg_stuff_buf_p5       <= `DLY 88'h0;
          ecs_byte_flag_p5        <= `DLY 4'h0;
      end
      else begin
          last_data_flag_p5       <= `DLY last_data_flag_p4      ;
          jpeg_stuff_buf_valid_p5 <= `DLY jpeg_stuff_buf_valid_p4;
          jpeg_stuff_buf_len_p5   <= `DLY jpeg_stuff_len_p4      ;
          jpeg_stuff_buf_p5       <= `DLY jpeg_stuff_p4          ;
          ecs_byte_flag_p5        <= `DLY ecs_byte_flag_p4[4:1]  ;
      end
  end

  // if ecs byte at byte 4 and 0xff is found, then 0x00 is stuffed
  assign byte_stuff_en_p5  = (ecs_byte_flag_p5[0] & (jpeg_stuff_buf_p5[71:64] == 8'hFF));
  assign jpeg_stuff_p5 = byte_stuff_en_p5 ? {jpeg_stuff_buf_p5[95:64], 8'h00, jpeg_stuff_buf_p5[63:0]} :
                                            {jpeg_stuff_buf_p5[95:0] , 8'hFF}                        ;
  assign jpeg_stuff_len_p5 = byte_stuff_en_p5 ? (jpeg_stuff_buf_len_p5 + 1) : jpeg_stuff_buf_len_p5;

  // jpeg_pack_buf pipeline 6
  assign last_data_flag_p6       = last_data_flag_p5      ;
  assign jpeg_stuff_buf_valid_p6 = jpeg_stuff_buf_valid_p5;
  assign jpeg_stuff_buf_len_p6   = jpeg_stuff_len_p5      ;
  assign jpeg_stuff_buf_p6       = jpeg_stuff_p5          ;
  assign ecs_byte_flag_p6        = ecs_byte_flag_p5[3:1]  ;

  // if ecs byte at byte 5 and 0xff is found, then 0x00 is stuffed
  assign byte_stuff_en_p6  = (ecs_byte_flag_p6[0] & (jpeg_stuff_buf_p6[87:80] == 8'hFF));
  assign jpeg_stuff_p6 = byte_stuff_en_p6 ? {jpeg_stuff_buf_p6[103:80], 8'h00, jpeg_stuff_buf_p6[79:0]} :
                                            {jpeg_stuff_buf_p6[103:0] , 8'hFF}                        ;
  assign jpeg_stuff_len_p6 = byte_stuff_en_p6 ? (jpeg_stuff_buf_len_p6 + 1) : jpeg_stuff_buf_len_p6;

  // jpeg_pack_buf pipeline 7
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag_p7       <= `DLY 1'b0;
          jpeg_stuff_buf_valid_p7 <= `DLY 1'b0;
          jpeg_stuff_buf_len_p7   <= `DLY 7'h0;
          jpeg_stuff_buf_p7       <= `DLY 96'h0;
          ecs_byte_flag_p7        <= `DLY 2'h0;
      end
      else begin
          last_data_flag_p7       <= `DLY last_data_flag_p6      ;
          jpeg_stuff_buf_valid_p7 <= `DLY jpeg_stuff_buf_valid_p6;
          jpeg_stuff_buf_len_p7   <= `DLY jpeg_stuff_len_p6      ;
          jpeg_stuff_buf_p7       <= `DLY jpeg_stuff_p6          ;
          ecs_byte_flag_p7        <= `DLY ecs_byte_flag_p6[2:1]  ;
      end
  end

  // if ecs byte at byte 6 and 0xff is found, then 0x00 is stuffed
  assign byte_stuff_en_p7  = (ecs_byte_flag_p7[0] & (jpeg_stuff_buf_p7[103:96] == 8'hFF));
  assign jpeg_stuff_p7 = byte_stuff_en_p7 ? {jpeg_stuff_buf_p7[111:96], 8'h00, jpeg_stuff_buf_p7[95:0]} :
                                            {jpeg_stuff_buf_p7[111:0] , 8'hFF}                        ;
  assign jpeg_stuff_len_p7 = byte_stuff_en_p7 ? (jpeg_stuff_buf_len_p7 + 1) : jpeg_stuff_buf_len_p7;

  // jpeg_pack_buf pipeline 8
  assign last_data_flag_p8       = last_data_flag_p7      ;
  assign jpeg_stuff_buf_valid_p8 = jpeg_stuff_buf_valid_p7;
  assign jpeg_stuff_buf_len_p8   = jpeg_stuff_len_p7      ;
  assign jpeg_stuff_buf_p8       = jpeg_stuff_p7          ;
  assign ecs_byte_flag_p8        = ecs_byte_flag_p7[1]    ;

  // if ecs byte at byte 7 and 0xff is found, then 0x00 is stuffed
  assign byte_stuff_en_p8  = (ecs_byte_flag_p8 & (jpeg_stuff_buf_p8[119:112] == 8'hFF));
  assign jpeg_stuff_p8 = byte_stuff_en_p8 ? {jpeg_stuff_buf_p8[119:112], 8'h00, jpeg_stuff_buf_p8[111:0]} :
                                            {jpeg_stuff_buf_p8[119:0]  , 8'hFF}                        ;
  assign jpeg_stuff_len_p8 = byte_stuff_en_p8 ? (jpeg_stuff_buf_len_p8 + 1) : jpeg_stuff_buf_len_p8;

//--------------------------------------------
//    split data longer than 64 bits
//--------------------------------------------

  // elapse fifo is used to split data longer than 64 bits
  fifo #(134,    // FIFO_DW
         2  ,    // FIFO_AW
         4  )    // FIFO_DEPTH
  elapse_fifo_u0(
    // global
    .clk               (clk               ), // <i>  1b, global clock
    .rstn              (rstn              ), // <i>  1b, global reset, active low
    // fifo wr
    .wr                (elapse_fifo_wr    ), // <i>  1b, fifo write enable
    .din               (elapse_fifo_din   ), // <i>    , fifo data input
    .full              (/*floating*/      ), // <o>  1b, fifo full indicator
    // fifo rd
    .rd                (elapse_fifo_rd    ), // <o>  1b, fifo read enable
    .dout              (elapse_fifo_dout  ), // <o>    , fifo data output
    .empty             (elapse_fifo_empty )  // <o>  1b, fifo empty indicator
    );

  assign elapse_fifo_wr = jpeg_stuff_buf_valid_p8;
  assign elapse_fifo_rd = ~elapse_fifo_empty & (~elapse_fifo_ext_valid | elapse_data_flush);
  assign elapse_fifo_din = {last_data_flag_p8, jpeg_stuff_len_p8, jpeg_stuff_p8};

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_stuff_fdout <= `DLY 128'h0;
      end
      else if (elapse_fifo_rd) begin
          jpeg_stuff_fdout <= `DLY elapse_fifo_dout[127:0];
      end
      else if (jpeg_stuff_split_valid) begin
          jpeg_stuff_fdout <= `DLY {jpeg_stuff_fdout[63:0], 64'h0};
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_stuff_len_fdout <= `DLY 5'h0;
      end
      else if (elapse_fifo_rd) begin
          jpeg_stuff_len_fdout <= `DLY elapse_fifo_dout[132:128];
      end
      else if (jpeg_stuff_split_valid) begin
          jpeg_stuff_len_fdout <= `DLY jpeg_stuff_len_fdout - 8;
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag_fdout <= `DLY 1'b0;
      end
      else if (elapse_fifo_rd) begin
          last_data_flag_fdout <= `DLY elapse_fifo_dout[133];
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          elapse_fifo_ext_valid <= `DLY 1'b0;
      end
      else if (elapse_fifo_rd) begin
          elapse_fifo_ext_valid <= `DLY 1'b1;
      end
      else if (elapse_data_flush) begin
          elapse_fifo_ext_valid <= `DLY 1'b0;
      end
  end

  assign jpeg_stuff_len_gt_8 = jpeg_stuff_len_fdout[4] | (jpeg_stuff_len_fdout[3] & (|jpeg_stuff_len_fdout[2:0]));
  assign jpeg_stuff_len_le_8 = ~jpeg_stuff_len_gt_8;

  assign elapse_data_flush = (jpeg_stuff_len_le_8 & jpeg_stuff_split_valid);

  assign jpeg_stuff_split       = jpeg_stuff_fdout[127:64];
  assign jpeg_stuff_split_len   = jpeg_stuff_len_gt_8 ? 4'h8 : jpeg_stuff_len_fdout[3:0];
  assign jpeg_stuff_split_valid = elapse_fifo_ext_valid;

  // shift jpeg_sbuff_split to make stuff jpeg_out_buf easier
  assign jpeg_stuff_split_shift_2 = jpeg_out_byte_ptr[2] ? {32'hFFFF_FFFF , jpeg_stuff_split[63:0]         } : {jpeg_stuff_split[63:0]         , 32'hFFFF_FFFF};
  assign jpeg_stuff_split_shift_1 = jpeg_out_byte_ptr[1] ? {16'hFFFF      , jpeg_stuff_split_shift_2[95:0] } : {jpeg_stuff_split_shift_2[95:0] , 16'hFFFF     };
  assign jpeg_stuff_split_shift_0 = jpeg_out_byte_ptr[0] ? {8'hFF         , jpeg_stuff_split_shift_1[111:0]} : {jpeg_stuff_split_shift_1[111:0], 8'hFF        };

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_buf <= `DLY 120'hFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
      end
      else if (jpeg_stuff_split_valid & jpeg_out_byte_ptr_ov) begin
          jpeg_out_buf <= `DLY {jpeg_out_buf[55:0], 64'hFFFF_FFFF_FFFF_FFFF} & jpeg_stuff_split_shift_0;
      end
      else if (jpeg_stuff_split_valid) begin
          jpeg_out_buf <= `DLY jpeg_out_buf & jpeg_stuff_split_shift_0;
      end
      else if (jpeg_out_byte_ptr_ov) begin
          jpeg_out_buf <= `DLY {jpeg_out_buf[55:0], 64'hFFFF_FFFF_FFFF_FFFF};
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_buf_tail <= `DLY 56'h0;
      end
      else if (jpeg_out_byte_ptr_ov & last_data_flag_out) begin
          jpeg_out_buf_tail <= `DLY jpeg_out_buf[55:0];
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_file_len <= `DLY 20'h0;
      end
      else if (frame_end) begin
          jpeg_file_len <= `DLY 20'h0;
      end
      else if (jpeg_stuff_split_valid) begin
          jpeg_file_len <= `DLY jpeg_file_len + {15'h0, jpeg_stuff_split_len};
      end
  end

  // jpeg output buffer byte pointer
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_byte_ptr <= `DLY 4'h0;
      end
      else if (jpeg_stuff_split_valid) begin
          jpeg_out_byte_ptr <= `DLY jpeg_out_byte_ptr_nxt;
      end
  end

  // next value of jpeg_out_byte_ptr
  assign jpeg_out_byte_ptr_nxt = jpeg_out_byte_ptr + {1'b0, jpeg_stuff_split_len};

  // jpeg_out_byte_ptr overflow
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          jpeg_out_byte_ptr_ov <= `DLY 1'b0;
      end
      else begin
          jpeg_out_byte_ptr_ov <= `DLY (jpeg_out_byte_ptr_nxt[3] ^ jpeg_out_byte_ptr[3]) & jpeg_stuff_split_valid;
      end
  end

  // last data flag of the output stage
  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag_out <= `DLY 1'b0;
      end
      else begin
          last_data_flag_out <= `DLY (last_data_flag_fdout & jpeg_stuff_split_valid & jpeg_stuff_len_le_8);
      end
  end

  always @(posedge clk or negedge rstn) begin
      if (~rstn) begin
          last_data_flag_d <= `DLY 1'b0;
      end
      else begin
          last_data_flag_d <= `DLY jpeg_out_byte_ptr_ov & last_data_flag_out;
      end
  end

  // buffer flush when at least 8 bits data exist or jpeg file end
  assign jpeg_out_flush = jpeg_out_byte_ptr_ov | last_data_flag_out | last_data_flag_d;

  assign jpeg_out_valid = jpeg_out_flush;
  assign jpeg_out_data  = last_data_flag_d ? {jpeg_out_buf_tail, 8'hFF} : jpeg_out_buf[119:56];

//--------------------------------------------
//    huffman table rom
//--------------------------------------------

  huffman_table huffman_table(
    .clk         (clk               ), // <i>  1b, global clock
    .rd_en       (jpeg_out_st_dht   ), // <i>  1b, read enable
    .rd_addr     (huffman_table_addr), // <i>  6b, read addrss
    .dout        (huffman_table_data)  // <o> 64b, table output
    );

//--------------------------------------------
//                  debug
//--------------------------------------------

//integer   JPEG_FILE;
//integer   JPEG_PIC;
//integer   out_cnt;

//initial begin
//    JPEG_FILE = $fopen("jpeg_file.txt", "wb");
//    JPEG_PIC  = $fopen("jpeg.jpg", "wb");
//    out_cnt = 0;
//    wait (jpeg_out_st_eoi);
//    wait (jpeg_out_st_idle);
//    #1000;
//    $fclose(JPEG_FILE);
//    $fclose(JPEG_PIC);
//end

//always @(posedge clk) begin
//    if (jpeg_out_valid) begin
//        $fdisplay(JPEG_FILE, "%x, %d", jpeg_out_data[63:56], jpeg_file_len);
//        $fdisplay(JPEG_FILE, "%x, %d", jpeg_out_data[55:48], jpeg_file_len);
//        $fdisplay(JPEG_FILE, "%x, %d", jpeg_out_data[47:40], jpeg_file_len);
//        $fdisplay(JPEG_FILE, "%x, %d", jpeg_out_data[39:32], jpeg_file_len);
//        $fdisplay(JPEG_FILE, "%x, %d", jpeg_out_data[31:24], jpeg_file_len);
//        $fdisplay(JPEG_FILE, "%x, %d", jpeg_out_data[23:16], jpeg_file_len);
//        $fdisplay(JPEG_FILE, "%x, %d", jpeg_out_data[15:8] , jpeg_file_len);
//        $fdisplay(JPEG_FILE, "%x, %d", jpeg_out_data[7:0]  , jpeg_file_len);
//        $fwrite(JPEG_PIC, "%c", jpeg_out_data[63:56]);
//        $fwrite(JPEG_PIC, "%c", jpeg_out_data[55:48]);
//        $fwrite(JPEG_PIC, "%c", jpeg_out_data[47:40]);
//        $fwrite(JPEG_PIC, "%c", jpeg_out_data[39:32]);
//        $fwrite(JPEG_PIC, "%c", jpeg_out_data[31:24]);
//        $fwrite(JPEG_PIC, "%c", jpeg_out_data[23:16]);
//        $fwrite(JPEG_PIC, "%c", jpeg_out_data[15:8]);
//        $fwrite(JPEG_PIC, "%c", jpeg_out_data[7:0]);
//        out_cnt = out_cnt + 8;
//    end
//end
//integer   i;
//reg   [63:0]  test;
//always @(posedge clk) begin
//    if (jpeg_stuff_split_valid) begin
//        for (i = 0; i < jpeg_stuff_split_len; i = i + 1) begin
//            test = (jpeg_stuff_split[63:0] << (i*8));
//            $fdisplay(JPEG_FILE, "%x, %d", test[63:56], (jpeg_file_len + i + 1));
//        end
//    end
//end

//integer   bit_cnt_debug;
//always @(posedge clk or negedge rstn) begin
//    if (~rstn) begin
//        bit_cnt_debug <= `DLY 0;
//    end
//    else if (jpeg_packing_dvalid) begin
//        bit_cnt_debug <= `DLY bit_cnt_debug + jpeg_packing_length;
//    end
//end

endmodule
