(********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggVorbis 'TREMOR' CODEC SOURCE CODE.   *
 *                                                                  *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE OggVorbis 'TREMOR' SOURCE CODE IS (C) COPYRIGHT 1994-2003    *
 * BY THE Xiph.Org FOUNDATION http://www.xiph.org/                  *
 *                                                                  *
 ********************************************************************)
unit PasVulkan.Audio.OGGVorbisTremor.ExternalLibrary;
{$ifdef UseExternalOGGVorbisTremorLibrary}
{$ifdef fpc}
 {$mode delphi}
 {$warnings off}
 {$hints off}
 {$ifdef cpui386}
  {$define cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef fpc_little_endian}
  {$define little_endian}
 {$else}
  {$ifdef fpc_big_endian}
   {$define big_endian}
  {$endif}
 {$endif}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
{$else}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu64}
 {$endif}
 {$optimization on}
 {$undef HasSAR}
 {$define UseDIV}
{$endif}
{$overflowchecks off}
{$rangechecks off}
{$writeableconst on}
{$PACKRECORDS C}

{$endif}
interface

{$ifdef UseExternalOGGVorbisTremorLibrary}
const LibTremor = 'tremolo'; // Library name

{$linklib tremolo}
{$linklib m}

const OGG_SUCCESS=0;

      OGG_HOLE=-10;
      OGG_SPAN=-11;
      OGG_EVERSION=-12;
      OGG_ESERIAL=-123;
      OGG_EINVAL=-14;
      OGG_EEOS=-15;

      OV_FALSE=-1;
      OV_EOF=-2;
      OV_HOLE=-3;

      OV_EREAD=-128;
      OV_EFAULT=-129;
      OV_EIMPL=-130;
      OV_EINVAL=-131;
      OV_ENOTVORBIS=-132;
      OV_EBADHEADER=-133;
      OV_EVERSION=-134;
      OV_ENOTAUDIO=-135;
      OV_EBADPACKET=-136;
      OV_EBADLINK=-137;
      OV_ENOSEEK=-138;

      WORD_ALIGN=8;

      VIF_POSIT=63;
      VIF_CLASS=16;
      VIF_PARTS=31;

      VI_TRANSFORMB=1;
      VI_WINDOWB=1;
      VI_TIMEB=1;
      VI_FLOORB=2;
      VI_RESB=3;
      VI_MAPB=1;

      LSP_FRACBITS=14;

      FROMdB_LOOKUP_SZ=35;
      FROMdB2_LOOKUP_SZ=32;
      FROMdB_SHIFT=5;
      FROMdB2_SHIFT=3;
      FROMdB2_MASK=31;

      SEEK_SET=0;
      SEEK_CUR=1;
      SEEK_END=2;

      errno:longint=0;

      CHUNKSIZE=1024;

      NOTOPEN=0;
      PARTOPEN=1;
      OPENED=2;
      STREAMSET=3;
      INITSET=4;

      VQ_FEXP=10;
      VQ_FMAN=21;
      VQ_FEXP_BIAS=768;  

type LOOKUP_T=longint;

{$ifndef fpc}
     ptruint=longword;
     ptrint=longint;
{$endif}

     PTwoPointers=^TTwoPointers;
     TTwoPointers=array[0..1] of pointer;

     PInt64Casted=^TInt64Casted;
     TInt64Casted=packed record
      case boolean of
       false:({$ifdef little_endian}Lo,Hi{$else}Hi,Lo{$endif}:longint;);
       true:(Value:int64;);
     end;

     ogg_int8_t=shortint;
     ogg_uint8_t=byte;

     ogg_int16_t=smallint;
     ogg_uint16_t=word;

     ogg_int32_t=longint;
     ogg_uint32_t=longword;

     ogg_int64_t=int64;
     ogg_uint64_t={$ifdef fpc}qword{$else}int64{$endif};

     PPLongint=^PLongint;
     PLongint=^Longint;

     PPLongword=^PLongword;
     PLongword=^Longword;

     PPPLongints=^TPPLongints;
     PPLongints=^TPLongints;
     PLongints=^TLongints;
     TPPLongints=array[0..$ffff] of PPLongints;
     TPLongints=array[0..$ffff] of PLongints;
     TLongints=array[0..$ffff] of longint;

     PSmallInts=^TSmallInts;
     TSmallInts=array[0..$ffff] of smallint;

     PPPointers=^TPPointers;
     PPointers=^TPointers;
     TPPointers=array[0..$ffff] of PPointers;
     TPointers=array[0..$ffff] of Pointer;

     PPLongwords=^TPLongwords;
     PLongwords=^TLongwords;
     TPLongwords=array[0..$ffff] of PLongwords;
     TLongwords=array[0..$ffff] of longword;

     PInt64=^int64;

     PInt64s=^TInt64s;
     TInt64s=array[0..$ffff] of int64;

     PPPogg_int32_t=^PPogg_int32_t;
     PPogg_int32_t=^Pogg_int32_t;
     Pogg_int32_t=^ogg_int32_t;

     PPogg_uint32_t=^Pogg_uint32_t;
     Pogg_uint32_t=^ogg_uint32_t;

     Pogg_buffer=^ogg_buffer;
     Pogg_reference=^ogg_reference;
     PPogg_reference=^Pogg_reference;
     Pogg_buffer_state=^ogg_buffer_state;

     ogg_buffer_state=record
      unused_buffers:Pogg_buffer;
      unused_references:Pogg_reference;
      outstanding:longint;
      shutdown:longint;
     end;

     ogg_buffer=record
      data:PAnsiChar;
      Size:longint;
      RefCount:longint;
      ptr:packed record
       case boolean of
        false:(owner:Pogg_buffer_state);
        true:(next:Pogg_buffer);
      end;
     end;

     ogg_reference=record
      buffer:Pogg_buffer;
      begin_:longint;
      length:longint;
      next:Pogg_reference;
     end;

     Poggpack_buffer=^oggpack_buffer;
     oggpack_buffer=record
      headbit:longint;
      headptr:PAnsiChar;
      headend:longint;
      head:Pogg_reference;
      tail:Pogg_reference;
      count:longint;
     end;

     Poggbyte_buffer=^oggbyte_buffer;
     oggbyte_buffer=record
      baseref:Pogg_reference;
      ref:Pogg_reference;
      ptr:PAnsiChar;
      pos:longint;
      end_:longint;
     end;

     Pogg_sync_state=^ogg_sync_state;
     ogg_sync_state=record
      bufferpool:Pogg_buffer_state;
      fifo_head:Pogg_reference;
      fifo_tail:Pogg_reference;
      fifo_fill:longint;
      unsynced:longint;
      headerbytes:longint;
      bodybytes:longint;
     end;

     Pogg_stream_state=^ogg_stream_state;
     ogg_stream_state=record
      header_head:Pogg_reference;
      header_tail:Pogg_reference;
      body_head:Pogg_reference;
      body_tail:Pogg_reference;
      e_o_s:longint;
      b_o_s:longint;
      serialno:longint;
      pageno:longint;
      packetno:ogg_int64_t;
      granulepos:ogg_int64_t;
      lacing_fill:longint;
      body_fill:ogg_uint32_t;
      holeflag:longint;
      spanflag:longint;
      clearflag:longint;
      laceptr:longint;
      body_fill_next:ogg_uint32_t;
     end;

     Pogg_packet=^ogg_packet;
     ogg_packet=record
      packet:Pogg_reference;
      bytes:longint;
      b_o_s:longint;
      e_o_s:longint;
      granulepos:ogg_int64_t;
      packetno:ogg_int64_t;
     end;

     Pogg_page=^ogg_page;
     ogg_page=record
      header:Pogg_reference;
      header_len:longint;
      body:Pogg_reference;
      body_len:longint;
     end;

     Pvorbis_info=^vorbis_info;
     vorbis_info=record
      version:longint;
      channels:longint;
      rate:longint;
      bitrate_upper:longint;
      bitrate_nominal:longint;
      bitrate_lower:longint;
      bitrate_window:longint;
      codec_setup:pointer;
     end;

     Pvorbis_dsp_state=^vorbis_dsp_state;
     vorbis_dsp_state=record
      analysisp:longint;
      vi:Pvorbis_info;
      pcm:PPLongints;
      pcmret:PPLongints;
      pcm_storage:longint;
      pcm_current:longint;
      pcm_returned:longint;
      preextraiplate:longint;
      eofflag:longint;
      lW:longint;
      W:longint;
      nW:longint;
      centerW:longint;
      granulepos:ogg_int64_t;
      sequence:ogg_int64_t;
      backend_state:pointer;
     end;

     Palloc_chain=^alloc_chain;

     Pvorbis_block=^vorbis_block;
     vorbis_block=record
      pcm:PPLongints;
      opb:oggpack_buffer;
      lW:longint;
      W:longint;
      nW:longint;
      pcmend:longint;
      mode:longint;
      eofflag:longint;
      granulepos:ogg_int64_t;
      sequence:ogg_int64_t;
      vd:Pvorbis_dsp_state;
      localstore:pointer;
      localtop:longint;
      localalloc:longint;
      totaluse:longint;
      reap:Palloc_chain;
     end;

     alloc_chain=record
      ptr:pointer;
      next:Palloc_chain;
     end;

     PPAnsiChar=^PAnsiChar;

     Pvorbis_comment=^vorbis_comment;
     vorbis_comment=record
      user_comments:PPAnsiChar;
      comment_lengths:PLongints;
      comments:longint;
      vendor:PAnsiChar;
     end;

     Pstatic_codebook=^static_codebook;
     static_codebook=record
      dim:longint;
      entries:longint;
      lengthlist:PLongints;
      maptype:longint;
      q_min:longint;
      q_delta:longint;
      q_quant:longint;
      q_sequencep:longint;
      quantlist:PLongints;
     end;

     Pcodebook=^codebook;
     codebook=record
      dim:longint;
      entries:longint;
      used_entries:longint;
      binarypoint:longint;
      valuelist:PLongints;
      codelist:PLongwords;
      dec_index:PLongints;
      dec_codelengths:PAnsiChar;
      dec_firsttable:PLongwords;
      dec_firsttablen:longint;
      dec_maxlength:longint;
      q_min:longint;
      q_delta:longint;
     end;

     Pcodebooks=^codebooks;
     PPcodebooks=^TPcodebooks;
     PPPcodebooks=^TPPcodebooks;
     TPPcodebooks=array[0..$ffff] of ppcodebooks;
     TPcodebooks=array[0..$ffff] of pcodebooks;
     codebooks=array[0..$ffff] of codebook;

     PPvorbis_look_mapping=^Pvorbis_look_mapping;
     Pvorbis_look_mapping=^vorbis_look_mapping;
     vorbis_look_mapping=pointer;

     PPvorbis_look_floor=^Pvorbis_look_floor;
     Pvorbis_look_floor=^vorbis_look_floor;
     vorbis_look_floor=pointer;

     PPvorbis_look_residue=^Pvorbis_look_residue;
     Pvorbis_look_residue=^vorbis_look_residue;
     vorbis_look_residue=pointer;

     Pvorbis_look_transform=^vorbis_look_transform;
     vorbis_look_transform=pointer;

     Pvorbis_info_mode=^vorbis_info_mode;
     vorbis_info_mode=record
      blockflag:longint;
      windowtype:longint;
      transformtype:longint;
      mapping:longint;
     end;

     PPvorbis_info_mapping=^Pvorbis_info_mapping;
     Pvorbis_info_mapping=^vorbis_info_mapping;
     vorbis_info_mapping=pointer;

     Pvorbis_info_floor=^vorbis_info_floor;
     vorbis_info_floor=pointer;

     Pvorbis_info_residue=^vorbis_info_residue;
     vorbis_info_residue=pointer;

     Pvorbis_info_transform=^vorbis_info_transform;
     vorbis_info_transform=pointer;

     Pprivate_state=^private_state;
     private_state=record
      window:TTwoPointers;
      modebits:longint;
      mode:PPvorbis_look_mapping;
      sample_count:ogg_int64_t;
     end;

     Pcodec_setup_info=^codec_setup_info;
     codec_setup_info=record
      blocksizes:array[0..1] of longint;
      modes:longint;
      maps:longint;
      times:longint;
      floors:longint;
      residues:longint;
      books:longint;
      mode_param:array[0..63] of Pvorbis_info_mode;
      map_type:array[0..63] of longint;
      map_param:array[0..63] of Pvorbis_info_mapping;
      time_type:array[0..63] of longint;
      floor_type:array[0..63] of longint;
      floor_param:array[0..63] of Pvorbis_info_floor;
      residue_type:array[0..63] of longint;
      residue_param:array[0..63] of Pvorbis_info_residue;
      book_param:array[0..255] of Pstatic_codebook;
      fullbooks:Pcodebook;
      passlimit:array[0..31] of longint;
      coupling_passes:longint;
     end;

     PPvorbis_func_floor=^Pvorbis_func_floor;
     Pvorbis_func_floor=^vorbis_func_floor;
     vorbis_func_floor=record
      unpack:function(vi:Pvorbis_info;opb:Poggpack_buffer):Pvorbis_info_floor;
      look:function(vd:Pvorbis_dsp_state;mi:Pvorbis_info_mode;i:Pvorbis_info_floor):Pvorbis_look_floor;
      free_info:procedure(i:Pvorbis_info_floor);
      free_look:procedure(i:Pvorbis_look_floor);
      inverse1:function(vb:Pvorbis_block;i:Pvorbis_look_floor):pointer;
      inverse2:function(vb:Pvorbis_block;i:Pvorbis_look_floor;memo:pointer;out_:PLongints):longint;
     end;

     Pvorbis_info_floor0=^vorbis_info_floor0;
     vorbis_info_floor0=record
      order:longint;
      rate:longint;
      barkmap:longint;
      ampbits:longint;
      ampdB:longint;
      numbooks:longint;
      books:array[0..15] of longint;
     end;

     Pvorbis_info_floor1=^vorbis_info_floor1;
     vorbis_info_floor1=record
      partitions:longint;
      partitionclass:array[0..VIF_PARTS-1] of longint;
      class_dim:array[0..VIF_CLASS-1] of longint;
      class_subs:array[0..VIF_CLASS-1] of longint;
      class_book:array[0..VIF_CLASS-1] of longint;
      class_subbook:array[0..VIF_CLASS-1,0..7] of longint;
      mult:longint;
      postlist:array[0..VIF_POSIT+1] of longint;
     end;

     PPvorbis_func_residue=^Pvorbis_func_residue;
     Pvorbis_func_residue=^vorbis_func_residue;
     vorbis_func_residue=record
      unpack:function(a:Pvorbis_info;b:Poggpack_buffer):Pvorbis_info_residue; cdecl;
      look:function(a:Pvorbis_dsp_state;b:Pvorbis_info_mode;c:Pvorbis_info_residue):Pvorbis_look_residue; cdecl;
      free_info:procedure(i:Pvorbis_info_residue); cdecl;
      free_look:procedure(i:Pvorbis_look_residue); cdecl;
      inverse:function(a:Pvorbis_block;b:Pvorbis_look_residue;c:PPLongints;d:PLongints;e:longint):longint; cdecl;
     end;

     Pvorbis_info_residue0=^vorbis_info_residue0;
     vorbis_info_residue0=record
      begin_:longint;
      end_:longint;
      grouping:longint;
      partitions:longint;
      groupbook:longint;
      secondstages:array[0..63] of longint;
      booklist:array[0..255] of longint;
     end;

     Pvorbis_func_mapping=^vorbis_func_mapping;
     vorbis_func_mapping=record
      unpack:function(a:Pvorbis_info;b:Poggpack_buffer):Pvorbis_info_mapping; cdecl;
      look:function(a:Pvorbis_dsp_state;b:Pvorbis_info_mode;c:Pvorbis_info_mapping):Pvorbis_look_mapping; cdecl;
      free_info:procedure(i:Pvorbis_info_mapping); cdecl;
      free_look:procedure(i:Pvorbis_look_mapping); cdecl;
      inverse:function(a:Pvorbis_block;b:Pvorbis_look_mapping):longint; cdecl;
     end;

     Pvorbis_info_mapping0=^vorbis_info_mapping0;
     vorbis_info_mapping0=record
      submaps:longint;
      chmuxlist:array[0..255] of longint;
      floorsubmap:array[0..15] of longint;
      residuesubmap:array[0..15] of longint;
      psy:array[0..1] of longint;
      coupling_steps:longint;
      coupling_mag:array[0..255] of longint;
      coupling_ang:array[0..255] of longint;
     end;

     Pvorbis_look_floor0=^vorbis_look_floor0;
     vorbis_look_floor0=record
      n:longint;
      ln:longint;
      m:longint;
      linearmap:PLongints;
      vi:Pvorbis_info_floor0;
      lsp_look:PLongints;
     end;

     Pvorbis_look_floor1=^vorbis_look_floor1;
     vorbis_look_floor1=record
      forward_index:array[0..VIF_POSIT+1] of longint;
      hineighbor:array[0..VIF_POSIT-1] of longint;
      loneighbor:array[0..VIF_POSIT-1] of longint;
      posts:longint;
      n:longint;
      quant_q:longint;
      vi:Pvorbis_info_floor1;
     end;

     Pvorbis_look_mapping0=^vorbis_look_mapping0;
     vorbis_look_mapping0=record
      mode:Pvorbis_info_mode;
      map:Pvorbis_info_mapping0;
      floor_look:PPvorbis_look_floor;
      residue_look:PPvorbis_look_residue;
      floor_func:PPvorbis_func_floor;
      residue_func:PPvorbis_func_residue;
      ch:longint;
      lastframe:longint;
      pcmbundle:PPLongints;
      zerobundle:PLongints;
      nonzero:PLongints;
      floormemo:PPPointers;
      channels:longint;
     end;

     Pvorbis_look_residue0=^vorbis_look_residue0;
     vorbis_look_residue0=record
      info:Pvorbis_info_residue0;
      map:longint;
      parts:longint;
      stages:longint;
      fullbooks:Pcodebooks;
      phrasebook:Pcodebook;
      partbooks:PPPcodebooks;
      partvals:longint;
      decodemap:PPLongints;
      partword:pointer;
      partwords:longint;
     end;

     Pov_callbacks=^ov_callbacks;
     ov_callbacks=record
      read_func:function(ptr:pointer;size,nmemb:ptruint;datasource:pointer):ptruint; cdecl;
      seek_func:function(datasource:pointer;offset:int64;whence:longint):longint; cdecl;
      close_func:function(datasource:pointer):longint; cdecl;
      tell_func:function(datasource:pointer):longint; cdecl;
     end;

     Pvorbis_infos=^Tvorbis_infos;
     Tvorbis_infos=array[0..0] of vorbis_info;

     Pvorbis_comments=^Tvorbis_comments;
     Tvorbis_comments=array[0..0] of vorbis_comment;

     POggVorbis_File=^OggVorbis_File;
     OggVorbis_File=record
      datasource:pointer;
      seekable:longint;
      offset:int64;
      end_:int64;
      oy:Pogg_sync_state;
      links:longint;
      offsets:PInt64s;
      dataoffsets:PInt64s;
      serialnos:PLongwords;
      pcmlengths:PInt64s;
      vi:Pvorbis_infos;
      vc:Pvorbis_comments;
      pcm_offset:ogg_int64_t;
      ready_state:longint;
      current_serialno:ogg_uint32_t;
      current_link:longint;
      bittrack:ogg_int64_t;
      samptrack:ogg_int64_t;
      os:Pogg_stream_state;
      vd:vorbis_dsp_state;
      vb:vorbis_block;
      callbacks:ov_callbacks;
      safedummy:array[0..1023] of byte;
     end;

{
procedure oggpack_readinit(b:Poggpack_buffer;r:Pogg_reference); cdecl; external LibTremor;
function oggpack_look(b:Poggpack_buffer;bits:longint):longint; cdecl; external LibTremor;
procedure oggpack_adv(b:Poggpack_buffer;bits:longint); cdecl; external LibTremor;
function oggpack_eop(b:Poggpack_buffer):longint; cdecl; external LibTremor;
function oggpack_read(b:Poggpack_buffer;bits:longint):longint; cdecl; external LibTremor;
function oggpack_bytes(b:Poggpack_buffer):longint; cdecl; external LibTremor;
function oggpack_bits(b:Poggpack_buffer):longint; cdecl; external LibTremor;

function vorbis_block_init(v:Pvorbis_dsp_state;vb:Pvorbis_block):longint;
function vorbis_block_clear(vb:Pvorbis_block):longint;

function vorbis_synthesis_restart(v:Pvorbis_dsp_state):longint;
function vorbis_synthesis_init(v:Pvorbis_dsp_state;vi:Pvorbis_info):longint;
function vorbis_synthesis_blockin(v:Pvorbis_dsp_state;vb:Pvorbis_block):longint;
function vorbis_synthesis_pcmout(v:Pvorbis_dsp_state;pcm:PPPLongints):longint;
function vorbis_synthesis_read(v:Pvorbis_dsp_state;bytes:longint):longint;

function _book_maptype1_quantvals(b:Pstatic_codebook):longint;

function vorbis_staticbook_unpack(opb:Poggpack_buffer):Pstatic_codebook;

function vorbis_book_decode(book:Pcodebook;b:Poggpack_buffer):longint;

type TDecodeFunc=function(book:Pcodebook;a:PLongints;b:Poggpack_buffer;n,point:longint):longint;

function vorbis_book_decodevs_add(book:Pcodebook;a:PLongints;b:Poggpack_buffer;n,point:longint):longint;
function vorbis_book_decodev_add(book:Pcodebook;a:PLongints;b:Poggpack_buffer;n,point:longint):longint;
function vorbis_book_decodev_set(book:Pcodebook;a:PLongints;b:Poggpack_buffer;n,point:longint):longint;
function vorbis_book_decodevv_add(book:Pcodebook;a:PPLongints;offset,ch:longint;b:Poggpack_buffer;n,point:longint):longint;

function vorbis_invsqlook_i(a,e:longint):longint;
function vorbis_fromdBlook_i(a:longint):longint;
function vorbis_coslook_i(a:longint):longint;
function vorbis_coslook2_i(a:longint):longint;

function toBARK(n:longint):longint;

procedure vorbis_lsp_to_curve(curve:PLongints;map:PLongints;n,ln:longint;lsp:PLongints;m:longint;amp,ampoffset:longint;icos:PLongints);

function bitreverse(x:ogg_uint32_t):ogg_uint32_t;

procedure floor0_free_info(i:Pvorbis_info_floor);
procedure floor0_free_look(i:Pvorbis_look_floor);
function floor0_unpack(vi:Pvorbis_info;opb:Poggpack_buffer):Pvorbis_info_floor;
function floor0_look(vd:Pvorbis_dsp_state;mi:Pvorbis_info_mode;i:Pvorbis_info_floor):Pvorbis_look_floor;
function floor0_inverse1(vb:Pvorbis_block;i:Pvorbis_look_floor):pointer;
function floor0_inverse2(vb:Pvorbis_block;i:Pvorbis_look_floor;memo:pointer;out_:PLongints):longint;

procedure floor1_free_info(i:Pvorbis_info_floor);
procedure floor1_free_look(i:Pvorbis_look_floor);
function floor1_unpack(vi:Pvorbis_info;opb:Poggpack_buffer):Pvorbis_info_floor;
function floor1_look(vd:Pvorbis_dsp_state;mi:Pvorbis_info_mode;i_:Pvorbis_info_floor):Pvorbis_look_floor;
function floor1_inverse1(vb:Pvorbis_block;i_:Pvorbis_look_floor):pointer;
function floor1_inverse2(vb:Pvorbis_block;i_:Pvorbis_look_floor;memo:pointer;out_:PLongints):longint;

function ogg_buffer_create:Pogg_buffer_state;
procedure ogg_buffer_destroy(bs:Pogg_buffer_state);
function ogg_buffer_alloc(bs:Pogg_buffer_state;bytes:longint):Pogg_reference;
procedure ogg_buffer_realloc(r:Pogg_reference;bytes:longint);
procedure ogg_buffer_mark(r:Pogg_reference);
function ogg_buffer_sub(r:Pogg_reference;begin_,length:longint):Pogg_reference;
function ogg_buffer_dup(r:Pogg_reference):Pogg_reference;
function ogg_buffer_split(tail,head:PPogg_reference;pos:longint):Pogg_reference;
procedure ogg_buffer_release_one(r:Pogg_reference);
procedure ogg_buffer_release(r:Pogg_reference);
function ogg_buffer_pretruncate(r:Pogg_reference;pos:longint):Pogg_reference;
function ogg_buffer_walk(r:Pogg_reference):Pogg_reference;
function ogg_buffer_cat(tail,head:Pogg_reference):Pogg_reference;

function oggbyte_init(b:Poggbyte_buffer;r:Pogg_reference):longint;
procedure oggbyte_set4(b:Poggbyte_buffer;val:ogg_uint32_t;pos:longint);
function oggbyte_read1(b:Poggbyte_buffer;pos:longint):byte;
function oggbyte_read4(b:Poggbyte_buffer;pos:longint):ogg_uint32_t;
function oggbyte_read8(b:Poggbyte_buffer;pos:longint):ogg_int64_t;

function ogg_page_version(og:Pogg_page):longint;
function ogg_page_continued(og:Pogg_page):longint;
function ogg_page_bos(og:Pogg_page):longint;
function ogg_page_eos(og:Pogg_page):longint;
function ogg_page_granulepos(og:Pogg_page):ogg_int64_t;
function ogg_page_serialno(og:Pogg_page):ogg_uint32_t;
function ogg_page_pageno(og:Pogg_page):ogg_uint32_t;
function ogg_page_packets(og:Pogg_page):longint;

function ogg_sync_create:Pogg_sync_state;
function ogg_sync_destroy(oy:Pogg_sync_state):longint;
function ogg_sync_bufferin(oy:Pogg_sync_state;bytes:longint):pointer;
function ogg_sync_wrote(oy:Pogg_sync_state;bytes:longint):longint;
function ogg_sync_pageseek(oy:Pogg_sync_state;og:Pogg_page):longint;
function ogg_sync_pageout(oy:Pogg_sync_state;og:Pogg_page):longint;
function ogg_sync_reset(oy:Pogg_sync_state):longint;

function ogg_stream_create(serialno:longint):Pogg_stream_state;
function ogg_stream_destroy(os:Pogg_stream_state):longint;
function ogg_stream_pagein(os:Pogg_stream_state;og:Pogg_page):longint;
function ogg_stream_reset(os:Pogg_stream_state):longint;
function ogg_stream_reset_serialno(os:Pogg_stream_state;serialno:longint):longint;

function ogg_stream_packetout(os:Pogg_stream_state;op:Pogg_packet):longint;
function ogg_stream_packetpeek(os:Pogg_stream_state;op:Pogg_packet):longint;

function ogg_packet_release(op:Pogg_packet):longint;

function ogg_page_release(og:Pogg_page):longint;
procedure ogg_page_dup(dup,orig:Pogg_page);

procedure vorbis_comment_init(vc:Pvorbis_comment);
function vorbis_comment_query(vc:Pvorbis_comment;tag:PAnsiChar;count:longint):PAnsiChar;
function vorbis_comment_query_count(vc:Pvorbis_comment;tag:PAnsiChar):longint;
procedure vorbis_comment_clear(vc:Pvorbis_comment);
function vorbis_info_blocksize(vi:Pvorbis_info;zo:longint):longint;
procedure vorbis_info_init(vi:Pvorbis_info);
procedure vorbis_info_clear(vi:Pvorbis_info);

function vorbis_synthesis_idheader(op:Pogg_packet):longint;
function vorbis_synthesis_headerin(vi:Pvorbis_info;vc:Pvorbis_comment;op:Pogg_packet):longint;

procedure mapping0_free_info(i:Pvorbis_info_mapping);
procedure mapping0_free_look(l:Pvorbis_look_mapping);
function mapping0_look(vd:Pvorbis_dsp_state;vm:Pvorbis_info_mode;m:Pvorbis_info_mapping):Pvorbis_look_mapping;
function mapping0_unpack(vi:Pvorbis_info;opb:Poggpack_buffer):Pvorbis_info_mapping;
function mapping0_inverse(vb:Pvorbis_block;l:Pvorbis_look_mapping):longint;

procedure mdct_forward(n:longint;in_,out_:PLongints);
procedure mdct_backward(n:longint;in_,out_:PLongints);

procedure res0_free_info(i:Pvorbis_info_residue);
procedure res0_free_look(i:Pvorbis_look_residue);
function res0_unpack(vi:Pvorbis_info;opb:Poggpack_buffer):Pvorbis_info_residue;
function res0_look(vd:Pvorbis_dsp_state;vm:Pvorbis_info_mode;vr:Pvorbis_info_residue):Pvorbis_look_residue;
function res0_inverse(vb:Pvorbis_block;vi:Pvorbis_look_residue;in_:PPLongInts;nonzero:PLongints;ch:longint):longint;
function res1_inverse(vb:Pvorbis_block;vi:Pvorbis_look_residue;in_:PPLongInts;nonzero:PLongints;ch:longint):longint;
function res2_inverse(vb:Pvorbis_block;vi:Pvorbis_look_residue;in_:PPLongInts;nonzero:PLongints;ch:longint):longint;

procedure vorbis_dsp_clear(v:Pvorbis_dsp_state);

procedure vorbis_book_clear(b:Pcodebook);

procedure vorbis_staticbook_clear(b:Pstatic_codebook);
procedure vorbis_staticbook_destroy(b:Pstatic_codebook);
function vorbis_book_init_decode(dest:Pcodebook;source:Pstatic_codebook):longint;

function vorbis_synthesis(vb:Pvorbis_block;op:Pogg_packet;decodep:longint):longint;

function vorbis_packet_blocksize(vi:Pvorbis_info;op:Pogg_packet):longint;
}

function ov_clear(vf:POggVorbis_File):longint; cdecl; external LibTremor;
function ov_open_callbacks(f:pointer;vf:POggVorbis_File;initial:PAnsiChar;ibytes:longint;callbacks:ov_callbacks):longint; cdecl; external LibTremor;
function ov_open(f:pointer;vf:POggVorbis_File;initial:PAnsiChar;ibytes:longint):longint; cdecl; external LibTremor;
function ov_test_callbacks(f:pointer;vf:POggVorbis_File;initial:PAnsiChar;ibytes:longint;callbacks:ov_callbacks):longint; cdecl; external LibTremor;
function ov_test(f:pointer;vf:POggVorbis_File;initial:PAnsiChar;ibytes:longint):longint; cdecl; external LibTremor;
function ov_test_open(vf:POggVorbis_File):longint; cdecl; external LibTremor;
function ov_streams(vf:POggVorbis_File):longint; cdecl; external LibTremor;
function ov_seekable(vf:POggVorbis_File):longint; cdecl; external LibTremor;
function ov_bitrate(vf:POggVorbis_File;i:longint):longint; cdecl; external LibTremor;
function ov_bitrate_instant(vf:POggVorbis_File):longint; cdecl; external LibTremor;
function ov_serialnumber(vf:POggVorbis_File;i:longint):longint; cdecl; external LibTremor;
function ov_raw_total(vf:POggVorbis_File;i:longint):ogg_int64_t; cdecl; external LibTremor;
function ov_pcm_total(vf:POggVorbis_File;i:longint):ogg_int64_t; cdecl; external LibTremor;
function ov_time_total(vf:POggVorbis_File;i:longint):ogg_int64_t; cdecl; external LibTremor;
function ov_raw_seek(vf:POggVorbis_File;pos:ogg_int64_t):longint; cdecl; external LibTremor;
function ov_pcm_seek_page(vf:POggVorbis_File;pos:ogg_int64_t):longint; cdecl; external LibTremor;
function ov_pcm_seek(vf:POggVorbis_File;pos:ogg_int64_t):longint; cdecl; external LibTremor;
function ov_time_seek(vf:POggVorbis_File;milliseconds:ogg_int64_t):longint; cdecl; external LibTremor;
function ov_time_seek_page(vf:POggVorbis_File;milliseconds:ogg_int64_t):longint; cdecl; external LibTremor;
function ov_raw_tell(vf:POggVorbis_File):ogg_int64_t; cdecl; external LibTremor;
function ov_pcm_tell(vf:POggVorbis_File):ogg_int64_t; cdecl; external LibTremor;
function ov_time_tell(vf:POggVorbis_File):ogg_int64_t; cdecl; external LibTremor;
function ov_info(vf:POggVorbis_File;link:longint):Pvorbis_info; cdecl; external LibTremor;
function ov_comment(vf:POggVorbis_File;link:longint):Pvorbis_comment; cdecl; external LibTremor;
function ov_read(vf:POggVorbis_File;buffer:pointer;bytes_req:longint;bitstream:PLongint):longint; cdecl; external LibTremor;

{$endif}

implementation

end.




