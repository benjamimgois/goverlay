(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2024, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************)
unit PasVulkan.Image.PNG.ExternalLibrary;
{$ifdef fpc}
 {$mode objfpc}
{$else}
 {$i PasVulkan.inc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

{$if defined(fpc) and defined(Android)}
{ Automatically converted by H2Pas 0.99.15 from png.h }
{ The following command line parameters were used:
    png.h
}

{$PACKRECORDS C}

uses
 ctypes,
 zlib;

Const
{$ifdef windows}
  LibPng = 'libpng12'; // Library name
  { matching lib version for libpng12.dll, needed for initialization }
  PNG_LIBPNG_VER_STRING='1.2.12';
{$else windows}
  LibPng = 'png'; // Library name
  {$if defined(Android)}
    {$linklib png}
    {$linklib m}
  {$ifend}
  { matching lib version for libpng, needed for initialization }
  PNG_LIBPNG_VER_STRING='1.2.12';
{$endif windows}

 PNG_COLOR_MASK_PALETTE=1;
 PNG_COLOR_MASK_COLOR=2;
 PNG_COLOR_MASK_ALPHA=4;
 PNG_COLOR_TYPE_GRAY=0;
 PNG_COLOR_TYPE_PALETTE=PNG_COLOR_MASK_COLOR or PNG_COLOR_MASK_PALETTE;
 PNG_COLOR_TYPE_RGB=PNG_COLOR_MASK_COLOR;
 PNG_COLOR_TYPE_RGB_ALPHA=PNG_COLOR_MASK_COLOR or PNG_COLOR_MASK_ALPHA;
 PNG_COLOR_TYPE_GRAY_ALPHA=PNG_COLOR_MASK_ALPHA;
 PNG_COLOR_TYPE_RGBA=PNG_COLOR_TYPE_RGB_ALPHA;
 PNG_COLOR_TYPE_GA=PNG_COLOR_TYPE_GRAY_ALPHA;

 PNG_INFO_tRNS=$10;

 PNG_FILLER_AFTER=1;

type
   time_t = longint;
   int = longint;
   z_stream = TZStream;
   voidp = pointer;

   png_uint_32 = dword;
   png_int_32 = longint;
   png_uint_16 = word;
   png_int_16 = smallint;
   png_byte = byte;
   ppng_uint_32 = ^png_uint_32;
   ppng_int_32 = ^png_int_32;
   ppng_uint_16 = ^png_uint_16;
   ppng_int_16 = ^png_int_16;
   ppng_byte = ^png_byte;
   pppng_uint_32 = ^ppng_uint_32;
   pppng_int_32 = ^ppng_int_32;
   pppng_uint_16 = ^ppng_uint_16;
   pppng_int_16 = ^ppng_int_16;
   pppng_byte = ^ppng_byte;
   png_size_t = csize_t;
   png_fixed_point = png_int_32;
   ppng_fixed_point = ^png_fixed_point;
   pppng_fixed_point = ^ppng_fixed_point;
   png_voidp = pointer;
   png_bytep = Ppng_byte;
   ppng_bytep = ^png_bytep;
   png_uint_32p = Ppng_uint_32;
   png_int_32p = Ppng_int_32;
   png_uint_16p = Ppng_uint_16;
   ppng_uint_16p = ^png_uint_16p;
   png_int_16p = Ppng_int_16;
(* Const before type ignored *)
   png_const_charp = Pchar;
   png_charp = Pchar;
   ppng_charp = ^png_charp;
   png_fixed_point_p = Ppng_fixed_point;
   TFile = Pointer;
   png_FILE_p = ^FILE;
   png_doublep = Pdouble;
   png_bytepp = PPpng_byte;
   png_uint_32pp = PPpng_uint_32;
   png_int_32pp = PPpng_int_32;
   png_uint_16pp = PPpng_uint_16;
   png_int_16pp = PPpng_int_16;
 (* Const before type ignored *)
   png_const_charpp = PPchar;
   png_charpp = PPchar;
   ppng_charpp = ^png_charpp;
   png_fixed_point_pp = PPpng_fixed_point;
   png_doublepp = PPdouble;
   png_charppp = PPPchar;
   Pcharf = Pchar;
   PPcharf = ^Pcharf;
   png_zcharp = Pcharf;
   png_zcharpp = PPcharf;
   png_zstreamp = Pzstream;


var
{$ifndef darwin}
  png_libpng_ver    : array[0..11] of char;   cvar; external;
  png_pass_start    : array[0..6] of longint; cvar; external;
  png_pass_inc      : array[0..6] of longint; cvar; external;
  png_pass_ystart   : array[0..6] of longint; cvar; external;
  png_pass_yinc     : array[0..6] of longint; cvar; external;
  png_pass_mask     : array[0..6] of longint; cvar; external;
  png_pass_dsp_mask : array[0..6] of longint; cvar; external;
{$else darwin}
  png_libpng_ver    : array[0..11] of char;   external LibPng name 'png_libpng_ver';
  png_pass_start    : array[0..6] of longint; external LibPng name 'png_pass_start';
  png_pass_inc      : array[0..6] of longint; external LibPng name 'png_pass_inc';
  png_pass_ystart   : array[0..6] of longint; external LibPng name 'png_pass_ystart';
  png_pass_yinc     : array[0..6] of longint; external LibPng name 'png_pass_yinc';
  png_pass_mask     : array[0..6] of longint; external LibPng name 'png_pass_mask';
  png_pass_dsp_mask : array[0..6] of longint; external LibPng name 'png_pass_dsp_mask';
{$endif darwin}

Type
  png_color = record
       red : png_byte;
       green : png_byte;
       blue : png_byte;
    end;
  ppng_color = ^png_color;
  pppng_color = ^ppng_color;

  png_color_struct = png_color;
  png_colorp = Ppng_color;
  ppng_colorp = ^png_colorp;
  png_colorpp = PPpng_color;
  png_color_16 = record
       index : png_byte;
       red : png_uint_16;
       green : png_uint_16;
       blue : png_uint_16;
       gray : png_uint_16;
    end;
  ppng_color_16 = ^png_color_16 ;
  pppng_color_16 = ^ppng_color_16 ;
  png_color_16_struct = png_color_16;
  png_color_16p = Ppng_color_16;
  ppng_color_16p = ^png_color_16p;
  png_color_16pp = PPpng_color_16;
  png_color_8 = record
       red : png_byte;
       green : png_byte;
       blue : png_byte;
       gray : png_byte;
       alpha : png_byte;
    end;
  ppng_color_8 = ^png_color_8;
  pppng_color_8 = ^ppng_color_8;
  png_color_8_struct = png_color_8;
  png_color_8p = Ppng_color_8;
  ppng_color_8p = ^png_color_8p;
  png_color_8pp = PPpng_color_8;
  png_sPLT_entry = record
       red : png_uint_16;
       green : png_uint_16;
       blue : png_uint_16;
       alpha : png_uint_16;
       frequency : png_uint_16;
    end;
  ppng_sPLT_entry = ^png_sPLT_entry;
  pppng_sPLT_entry = ^ppng_sPLT_entry;
  png_sPLT_entry_struct = png_sPLT_entry;
  png_sPLT_entryp = Ppng_sPLT_entry;
  png_sPLT_entrypp = PPpng_sPLT_entry;
  png_sPLT_t = record
       name : png_charp;
       depth : png_byte;
       entries : png_sPLT_entryp;
       nentries : png_int_32;
    end;
  ppng_sPLT_t = ^png_sPLT_t;
  pppng_sPLT_t = ^ppng_sPLT_t;
  png_sPLT_struct = png_sPLT_t;
  png_sPLT_tp = Ppng_sPLT_t;
  png_sPLT_tpp = PPpng_sPLT_t;
  png_text = record
       compression : longint;
       key : png_charp;
       text : png_charp;
       text_length : png_size_t;
    end;
  ppng_text = ^png_text;
  pppng_text = ^ppng_text;

  png_text_struct = png_text;
  png_textp = Ppng_text;
  ppng_textp = ^png_textp;
  png_textpp = PPpng_text;
  png_time = record
       year : png_uint_16;
       month : png_byte;
       day : png_byte;
       hour : png_byte;
       minute : png_byte;
       second : png_byte;
    end;
  ppng_time = ^png_time;
  pppng_time = ^ppng_time;

  png_time_struct = png_time;
  png_timep = Ppng_time;
  PPNG_TIMEP = ^PNG_TIMEP;
  png_timepp = PPpng_time;
  png_unknown_chunk = record
       name : array[0..4] of png_byte;
       data : Ppng_byte;
       size : png_size_t;
       location : png_byte;
    end;
  ppng_unknown_chunk = ^png_unknown_chunk;
  pppng_unknown_chunk = ^ppng_unknown_chunk;

  png_unknown_chunk_t = png_unknown_chunk;
  png_unknown_chunkp = Ppng_unknown_chunk;
  png_unknown_chunkpp = PPpng_unknown_chunk;
  png_info = record
       width : png_uint_32;
       height : png_uint_32;
       valid : png_uint_32;
       rowbytes : png_uint_32;
       palette : png_colorp;
       num_palette : png_uint_16;
       num_trans : png_uint_16;
       bit_depth : png_byte;
       color_type : png_byte;
       compression_type : png_byte;
       filter_type : png_byte;
       interlace_type : png_byte;
       channels : png_byte;
       pixel_depth : png_byte;
       spare_byte : png_byte;
       signature : array[0..7] of png_byte;
       gamma : double;
       srgb_intent : png_byte;
       num_text : longint;
       max_text : longint;
       text : png_textp;
       mod_time : png_time;
       sig_bit : png_color_8;
       trans : png_bytep;
       trans_values : png_color_16;
       background : png_color_16;
       x_offset : png_int_32;
       y_offset : png_int_32;
       offset_unit_type : png_byte;
       x_pixels_per_unit : png_uint_32;
       y_pixels_per_unit : png_uint_32;
       phys_unit_type : png_byte;
       hist : png_uint_16p;
       x_white : double;
       y_white : double;
       x_red : double;
       y_red : double;
       x_green : double;
       y_green : double;
       x_blue : double;
       y_blue : double;
       pcal_purpose : png_charp;
       pcal_X0 : png_int_32;
       pcal_X1 : png_int_32;
       pcal_units : png_charp;
       pcal_params : png_charpp;
       pcal_type : png_byte;
       pcal_nparams : png_byte;
       free_me : png_uint_32;
       unknown_chunks : png_unknown_chunkp;
       unknown_chunks_num : png_size_t;
       iccp_name : png_charp;
       iccp_profile : png_charp;
       iccp_proflen : png_uint_32;
       iccp_compression : png_byte;
       splt_palettes : png_sPLT_tp;
       splt_palettes_num : png_uint_32;
       scal_unit : png_byte;
       scal_pixel_width : double;
       scal_pixel_height : double;
       scal_s_width : png_charp;
       scal_s_height : png_charp;
       row_pointers : png_bytepp;
       int_gamma : png_fixed_point;
       int_x_white : png_fixed_point;
       int_y_white : png_fixed_point;
       int_x_red : png_fixed_point;
       int_y_red : png_fixed_point;
       int_x_green : png_fixed_point;
       int_y_green : png_fixed_point;
       int_x_blue : png_fixed_point;
       int_y_blue : png_fixed_point;
    end;
  ppng_info = ^png_info;
  pppng_info = ^ppng_info;

  png_info_struct = png_info;
  png_infop = Ppng_info;
  png_infopp = PPpng_info;
  png_row_info = record
       width : png_uint_32;
       rowbytes : png_uint_32;
       color_type : png_byte;
       bit_depth : png_byte;
       channels : png_byte;
       pixel_depth : png_byte;
    end;
  ppng_row_info = ^png_row_info;
  pppng_row_info = ^ppng_row_info;

  png_row_info_struct = png_row_info;
  png_row_infop = Ppng_row_info;
  png_row_infopp = PPpng_row_info;
//  png_struct_def = png_struct;
  png_structp = ^png_struct;



png_error_ptr = Procedure(Arg1 : png_structp; Arg2 : png_const_charp);cdecl;
png_rw_ptr = Procedure(Arg1 : png_structp; Arg2 : png_bytep; Arg3 : png_size_t);cdecl;
png_flush_ptr = procedure (Arg1 : png_structp) ;cdecl;
png_read_status_ptr = procedure (Arg1 : png_structp; Arg2 : png_uint_32; Arg3: int);cdecl;
png_write_status_ptr = Procedure (Arg1 : png_structp; Arg2:png_uint_32;Arg3 : int) ;cdecl;
png_progressive_info_ptr = Procedure (Arg1 : png_structp; Arg2 : png_infop) ;cdecl;
png_progressive_end_ptr = Procedure (Arg1 : png_structp; Arg2 : png_infop) ;cdecl;
png_progressive_row_ptr = Procedure (Arg1 : png_structp; Arg2 : png_bytep; Arg3 : png_uint_32; Arg4 : int) ;cdecl;
png_user_transform_ptr = Procedure (Arg1 : png_structp; Arg2 : png_row_infop; Arg3 : png_bytep) ;cdecl;
png_user_chunk_ptr = Function (Arg1 : png_structp; Arg2 : png_unknown_chunkp): longint;cdecl;
png_unknown_chunk_ptr = Procedure (Arg1 : png_structp);cdecl;
png_malloc_ptr = Function (Arg1 : png_structp; Arg2 : png_size_t) : png_voidp ;cdecl;
png_free_ptr = Procedure (Arg1 : png_structp; Arg2 : png_voidp) ; cdecl;

   png_struct_def = record
        jmpbuf : jmp_buf;
        error_fn : png_error_ptr;
        warning_fn : png_error_ptr;
        error_ptr : png_voidp;
        write_data_fn : png_rw_ptr;
        read_data_fn : png_rw_ptr;
        io_ptr : png_voidp;
        read_user_transform_fn : png_user_transform_ptr;
        write_user_transform_fn : png_user_transform_ptr;
        user_transform_ptr : png_voidp;
        user_transform_depth : png_byte;
        user_transform_channels : png_byte;
        mode : png_uint_32;
        flags : png_uint_32;
        transformations : png_uint_32;
        zstream : z_stream;
        zbuf : png_bytep;
        zbuf_size : png_size_t;
        zlib_level : longint;
        zlib_method : longint;
        zlib_window_bits : longint;
        zlib_mem_level : longint;
        zlib_strategy : longint;
        width : png_uint_32;
        height : png_uint_32;
        num_rows : png_uint_32;
        usr_width : png_uint_32;
        rowbytes : png_uint_32;
        irowbytes : png_uint_32;
        iwidth : png_uint_32;
        row_number : png_uint_32;
        prev_row : png_bytep;
        row_buf : png_bytep;
        sub_row : png_bytep;
        up_row : png_bytep;
        avg_row : png_bytep;
        paeth_row : png_bytep;
        row_info : png_row_info;
        idat_size : png_uint_32;
        crc : png_uint_32;
        palette : png_colorp;
        num_palette : png_uint_16;
        num_trans : png_uint_16;
        chunk_name : array[0..4] of png_byte;
        compression : png_byte;
        filter : png_byte;
        interlaced : png_byte;
        pass : png_byte;
        do_filter : png_byte;
        color_type : png_byte;
        bit_depth : png_byte;
        usr_bit_depth : png_byte;
        pixel_depth : png_byte;
        channels : png_byte;
        usr_channels : png_byte;
        sig_bytes : png_byte;
        filler : png_uint_16;
        background_gamma_type : png_byte;
        background_gamma : double;
        background : png_color_16;
        background_1 : png_color_16;
        output_flush_fn : png_flush_ptr;
        flush_dist : png_uint_32;
        flush_rows : png_uint_32;
        gamma_shift : longint;
        gamma : double;
        screen_gamma : double;
        gamma_table : png_bytep;
        gamma_from_1 : png_bytep;
        gamma_to_1 : png_bytep;
        gamma_16_table : png_uint_16pp;
        gamma_16_from_1 : png_uint_16pp;
        gamma_16_to_1 : png_uint_16pp;
        sig_bit : png_color_8;
        shift : png_color_8;
        trans : png_bytep;
        trans_values : png_color_16;
        read_row_fn : png_read_status_ptr;
        write_row_fn : png_write_status_ptr;
        info_fn : png_progressive_info_ptr;
        row_fn : png_progressive_row_ptr;
        end_fn : png_progressive_end_ptr;
        save_buffer_ptr : png_bytep;
        save_buffer : png_bytep;
        current_buffer_ptr : png_bytep;
        current_buffer : png_bytep;
        push_length : png_uint_32;
        skip_length : png_uint_32;
        save_buffer_size : png_size_t;
        save_buffer_max : png_size_t;
        buffer_size : png_size_t;
        current_buffer_size : png_size_t;
        process_mode : longint;
        cur_palette : longint;
        current_text_size : png_size_t;
        current_text_left : png_size_t;
        current_text : png_charp;
        current_text_ptr : png_charp;
        palette_lookup : png_bytep;
        dither_index : png_bytep;
        hist : png_uint_16p;
        heuristic_method : png_byte;
        num_prev_filters : png_byte;
        prev_filters : png_bytep;
        filter_weights : png_uint_16p;
        inv_filter_weights : png_uint_16p;
        filter_costs : png_uint_16p;
        inv_filter_costs : png_uint_16p;
        time_buffer : png_charp;
        free_me : png_uint_32;
        user_chunk_ptr : png_voidp;
        read_user_chunk_fn : png_user_chunk_ptr;
        num_chunk_list : longint;
        chunk_list : png_bytep;
        rgb_to_gray_status : png_byte;
        rgb_to_gray_red_coeff : png_uint_16;
        rgb_to_gray_green_coeff : png_uint_16;
        rgb_to_gray_blue_coeff : png_uint_16;
        empty_plte_permitted : png_byte;
        int_gamma : png_fixed_point;
     end;
   ppng_struct_def = ^png_struct_def;
   pppng_struct_def = ^ppng_struct_def;
   png_struct = png_struct_def;
   ppng_struct = ^png_struct;
   pppng_struct = ^ppng_struct;

   version_1_0_8 = png_structp;
   png_structpp = PPpng_struct;

function png_access_version_number:png_uint_32;cdecl; external LibPng;
procedure png_set_sig_bytes(png_ptr:png_structp; num_bytes:longint);cdecl; external LibPng;
function png_sig_cmp(sig:png_bytep; start:png_size_t; num_to_check:png_size_t):longint;cdecl; external LibPng;
function png_check_sig(sig:png_bytep; num:longint):longint;cdecl; external LibPng;
function png_create_read_struct(user_png_ver:png_const_charp; error_ptr:png_voidp; error_fn:png_error_ptr; warn_fn:png_error_ptr):png_structp;cdecl; external LibPng;
function png_create_write_struct(user_png_ver:png_const_charp; error_ptr:png_voidp; error_fn:png_error_ptr; warn_fn:png_error_ptr):png_structp;cdecl; external LibPng;
function png_get_compression_buffer_size(png_ptr:png_structp):png_uint_32;cdecl; external LibPng;
procedure png_set_compression_buffer_size(png_ptr:png_structp; size:png_uint_32);cdecl; external LibPng;
function png_reset_zstream(png_ptr:png_structp):longint;cdecl; external LibPng;
procedure png_write_chunk(png_ptr:png_structp; chunk_name:png_bytep; data:png_bytep; length:png_size_t);cdecl; external LibPng;
procedure png_write_chunk_start(png_ptr:png_structp; chunk_name:png_bytep; length:png_uint_32);cdecl; external LibPng;
procedure png_write_chunk_data(png_ptr:png_structp; data:png_bytep; length:png_size_t);cdecl; external LibPng;
procedure png_write_chunk_end(png_ptr:png_structp);cdecl; external LibPng;
function png_create_info_struct(png_ptr:png_structp):png_infop;cdecl; external LibPng;
procedure png_info_init(info_ptr:png_infop);cdecl; external LibPng;
procedure png_write_info_before_PLTE(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
procedure png_write_info(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
procedure png_read_info(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
function png_convert_to_rfc1123(png_ptr:png_structp; ptime:png_timep):png_charp;cdecl; external LibPng;
procedure png_convert_from_struct_tm(ptime:png_timep; ttime:Pointer);cdecl; external LibPng;
procedure png_convert_from_time_t(ptime:png_timep; ttime:time_t);cdecl; external LibPng;
procedure png_set_expand(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_gray_1_2_4_to_8(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_palette_to_rgb(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_tRNS_to_alpha(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_bgr(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_gray_to_rgb(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_rgb_to_gray(png_ptr:png_structp; error_action:longint; red:double; green:double);cdecl; external LibPng;
procedure png_set_rgb_to_gray_fixed(png_ptr:png_structp; error_action:longint; red:png_fixed_point; green:png_fixed_point);cdecl; external LibPng;
function png_get_rgb_to_gray_status(png_ptr:png_structp):png_byte;cdecl; external LibPng;
procedure png_build_grayscale_palette(bit_depth:longint; palette:png_colorp);cdecl; external LibPng;
procedure png_set_strip_alpha(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_swap_alpha(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_invert_alpha(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_filler(png_ptr:png_structp; filler:png_uint_32; flags:longint);cdecl; external LibPng;
procedure png_set_swap(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_packing(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_packswap(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_shift(png_ptr:png_structp; true_bits:png_color_8p);cdecl; external LibPng;
function png_set_interlace_handling(png_ptr:png_structp):longint;cdecl; external LibPng;
procedure png_set_invert_mono(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_background(png_ptr:png_structp; background_color:png_color_16p; background_gamma_code:longint; need_expand:longint; background_gamma:double);cdecl; external LibPng;
procedure png_set_strip_16(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_dither(png_ptr:png_structp; palette:png_colorp; num_palette:longint; maximum_colors:longint; histogram:png_uint_16p;
            full_dither:longint);cdecl; external LibPng;
procedure png_set_gamma(png_ptr:png_structp; screen_gamma:double; default_file_gamma:double);cdecl; external LibPng;
procedure png_permit_empty_plte(png_ptr:png_structp; empty_plte_permitted:longint);cdecl; external LibPng;
procedure png_set_flush(png_ptr:png_structp; nrows:longint);cdecl; external LibPng;
procedure png_write_flush(png_ptr:png_structp);cdecl; external LibPng;
procedure png_start_read_image(png_ptr:png_structp);cdecl; external LibPng;
procedure png_read_update_info(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
procedure png_read_rows(png_ptr:png_structp; row:png_bytepp; display_row:png_bytepp; num_rows:png_uint_32);cdecl; external LibPng;
procedure png_read_row(png_ptr:png_structp; row:png_bytep; display_row:png_bytep);cdecl; external LibPng;
procedure png_read_image(png_ptr:png_structp; image:png_bytepp);cdecl; external LibPng;
procedure png_write_row(png_ptr:png_structp; row:png_bytep);cdecl; external LibPng;
procedure png_write_rows(png_ptr:png_structp; row:png_bytepp; num_rows:png_uint_32);cdecl; external LibPng;
procedure png_write_image(png_ptr:png_structp; image:png_bytepp);cdecl; external LibPng;
procedure png_write_end(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
procedure png_read_end(png_ptr:png_structp; info_ptr:png_infop);cdecl; external LibPng;
procedure png_destroy_info_struct(png_ptr:png_structp; info_ptr_ptr:png_infopp);cdecl; external LibPng;
procedure png_destroy_read_struct(png_ptr_ptr:png_structpp; info_ptr_ptr:png_infopp; end_info_ptr_ptr:png_infopp);cdecl; external LibPng;
procedure png_read_destroy(png_ptr:png_structp; info_ptr:png_infop; end_info_ptr:png_infop);cdecl; external LibPng;
procedure png_destroy_write_struct(png_ptr_ptr:png_structpp; info_ptr_ptr:png_infopp);cdecl; external LibPng;
procedure png_write_destroy_info(info_ptr:png_infop);cdecl; external LibPng;
procedure png_write_destroy(png_ptr:png_structp);cdecl; external LibPng;
procedure png_set_crc_action(png_ptr:png_structp; crit_action:longint; ancil_action:longint);cdecl; external LibPng;
procedure png_set_filter(png_ptr:png_structp; method:longint; filters:longint);cdecl; external LibPng;
procedure png_set_filter_heuristics(png_ptr:png_structp; heuristic_method:longint; num_weights:longint; filter_weights:png_doublep; filter_costs:png_doublep);cdecl; external LibPng;
procedure png_set_compression_level(png_ptr:png_structp; level:longint);cdecl; external LibPng;
procedure png_set_compression_mem_level(png_ptr:png_structp; mem_level:longint);cdecl; external LibPng;
procedure png_set_compression_strategy(png_ptr:png_structp; strategy:longint);cdecl; external LibPng;
procedure png_set_compression_window_bits(png_ptr:png_structp; window_bits:longint);cdecl; external LibPng;
procedure png_set_compression_method(png_ptr:png_structp; method:longint);cdecl; external LibPng;
procedure png_init_io(png_ptr:png_structp; fp:png_FILE_p);cdecl; external LibPng;
procedure png_set_error_fn(png_ptr:png_structp; error_ptr:png_voidp; error_fn:png_error_ptr; warning_fn:png_error_ptr);cdecl; external LibPng;
function png_get_error_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
procedure png_set_write_fn(png_ptr:png_structp; io_ptr:png_voidp; write_data_fn:png_rw_ptr; output_flush_fn:png_flush_ptr);cdecl; external LibPng;
procedure png_set_read_fn(png_ptr:png_structp; io_ptr:png_voidp; read_data_fn:png_rw_ptr);cdecl; external LibPng;
function png_get_io_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
procedure png_set_read_status_fn(png_ptr:png_structp; read_row_fn:png_read_status_ptr);cdecl; external LibPng;
procedure png_set_write_status_fn(png_ptr:png_structp; write_row_fn:png_write_status_ptr);cdecl; external LibPng;
procedure png_set_read_user_transform_fn(png_ptr:png_structp; read_user_transform_fn:png_user_transform_ptr);cdecl; external LibPng;
procedure png_set_write_user_transform_fn(png_ptr:png_structp; write_user_transform_fn:png_user_transform_ptr);cdecl; external LibPng;
procedure png_set_user_transform_info(png_ptr:png_structp; user_transform_ptr:png_voidp; user_transform_depth:longint; user_transform_channels:longint);cdecl; external LibPng;
function png_get_user_transform_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
procedure png_set_read_user_chunk_fn(png_ptr:png_structp; user_chunk_ptr:png_voidp; read_user_chunk_fn:png_user_chunk_ptr);cdecl; external LibPng;
function png_get_user_chunk_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
procedure png_set_progressive_read_fn(png_ptr:png_structp; progressive_ptr:png_voidp; info_fn:png_progressive_info_ptr; row_fn:png_progressive_row_ptr; end_fn:png_progressive_end_ptr);cdecl; external LibPng;
function png_get_progressive_ptr(png_ptr:png_structp):png_voidp;cdecl; external LibPng;
procedure png_process_data(png_ptr:png_structp; info_ptr:png_infop; buffer:png_bytep; buffer_size:png_size_t);cdecl; external LibPng;
procedure png_progressive_combine_row(png_ptr:png_structp; old_row:png_bytep; new_row:png_bytep);cdecl; external LibPng;
function png_malloc(png_ptr:png_structp; size:png_uint_32):png_voidp;cdecl; external LibPng;
procedure png_free(png_ptr:png_structp; ptr:png_voidp);cdecl; external LibPng;
procedure png_free_data(png_ptr:png_structp; info_ptr:png_infop; free_me:png_uint_32; num:longint);cdecl; external LibPng;
procedure png_data_freer(png_ptr:png_structp; info_ptr:png_infop; freer:longint; mask:png_uint_32);cdecl; external LibPng;
function png_memcpy_check(png_ptr:png_structp; s1:png_voidp; s2:png_voidp; size:png_uint_32):png_voidp;cdecl; external LibPng;
function png_memset_check(png_ptr:png_structp; s1:png_voidp; value:longint; size:png_uint_32):png_voidp;cdecl; external LibPng;
procedure png_error(png_ptr:png_structp; error:png_const_charp);cdecl; external LibPng;
procedure png_chunk_error(png_ptr:png_structp; error:png_const_charp);cdecl; external LibPng;
procedure png_warning(png_ptr:png_structp; message:png_const_charp);cdecl; external LibPng;
procedure png_chunk_warning(png_ptr:png_structp; message:png_const_charp);cdecl; external LibPng;
function png_get_valid(png_ptr:png_structp; info_ptr:png_infop; flag:png_uint_32):png_uint_32;cdecl; external LibPng;
function png_get_rowbytes(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
function png_get_rows(png_ptr:png_structp; info_ptr:png_infop):png_bytepp;cdecl; external LibPng;
procedure png_set_rows(png_ptr:png_structp; info_ptr:png_infop; row_pointers:png_bytepp);cdecl; external LibPng;
function png_get_channels(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
function png_get_image_width(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
function png_get_image_height(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
function png_get_bit_depth(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
function png_get_color_type(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
function png_get_filter_type(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
function png_get_interlace_type(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
function png_get_compression_type(png_ptr:png_structp; info_ptr:png_infop):png_byte;cdecl; external LibPng;
function png_get_pixels_per_meter(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
function png_get_x_pixels_per_meter(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
function png_get_y_pixels_per_meter(png_ptr:png_structp; info_ptr:png_infop):png_uint_32;cdecl; external LibPng;
function png_get_pixel_aspect_ratio(png_ptr:png_structp; info_ptr:png_infop):double;cdecl; external LibPng;
function png_get_x_offset_pixels(png_ptr:png_structp; info_ptr:png_infop):png_int_32;cdecl; external LibPng;
function png_get_y_offset_pixels(png_ptr:png_structp; info_ptr:png_infop):png_int_32;cdecl; external LibPng;
function png_get_x_offset_microns(png_ptr:png_structp; info_ptr:png_infop):png_int_32;cdecl; external LibPng;
function png_get_y_offset_microns(png_ptr:png_structp; info_ptr:png_infop):png_int_32;cdecl; external LibPng;
function png_get_signature(png_ptr:png_structp; info_ptr:png_infop):png_bytep;cdecl; external LibPng;
function png_get_bKGD(png_ptr:png_structp; info_ptr:png_infop; background:Ppng_color_16p):png_uint_32;cdecl; external LibPng;
procedure png_set_bKGD(png_ptr:png_structp; info_ptr:png_infop; background:png_color_16p);cdecl; external LibPng;
function png_get_cHRM(png_ptr:png_structp; info_ptr:png_infop; white_x:Pdouble; white_y:Pdouble; red_x:Pdouble;
           red_y:Pdouble; green_x:Pdouble; green_y:Pdouble; blue_x:Pdouble; blue_y:Pdouble):png_uint_32;cdecl; external LibPng;
function png_get_cHRM_fixed(png_ptr:png_structp; info_ptr:png_infop; int_white_x:Ppng_fixed_point; int_white_y:Ppng_fixed_point; int_red_x:Ppng_fixed_point;
           int_red_y:Ppng_fixed_point; int_green_x:Ppng_fixed_point; int_green_y:Ppng_fixed_point; int_blue_x:Ppng_fixed_point; int_blue_y:Ppng_fixed_point):png_uint_32;cdecl; external LibPng;
procedure png_set_cHRM(png_ptr:png_structp; info_ptr:png_infop; white_x:double; white_y:double; red_x:double;
            red_y:double; green_x:double; green_y:double; blue_x:double; blue_y:double);cdecl; external LibPng;
procedure png_set_cHRM_fixed(png_ptr:png_structp; info_ptr:png_infop; int_white_x:png_fixed_point; int_white_y:png_fixed_point; int_red_x:png_fixed_point;
            int_red_y:png_fixed_point; int_green_x:png_fixed_point; int_green_y:png_fixed_point; int_blue_x:png_fixed_point; int_blue_y:png_fixed_point);cdecl; external LibPng;
function png_get_gAMA(png_ptr:png_structp; info_ptr:png_infop; file_gamma:Pdouble):png_uint_32;cdecl; external LibPng;
function png_get_gAMA_fixed(png_ptr:png_structp; info_ptr:png_infop; int_file_gamma:Ppng_fixed_point):png_uint_32;cdecl; external LibPng;
procedure png_set_gAMA(png_ptr:png_structp; info_ptr:png_infop; file_gamma:double);cdecl; external LibPng;
procedure png_set_gAMA_fixed(png_ptr:png_structp; info_ptr:png_infop; int_file_gamma:png_fixed_point);cdecl; external LibPng;
function png_get_hIST(png_ptr:png_structp; info_ptr:png_infop; hist:Ppng_uint_16p):png_uint_32;cdecl; external LibPng;
procedure png_set_hIST(png_ptr:png_structp; info_ptr:png_infop; hist:png_uint_16p);cdecl; external LibPng;
function png_get_IHDR(png_ptr:png_structp; info_ptr:png_infop; width:Ppng_uint_32; height:Ppng_uint_32; bit_depth:Plongint;
           color_type:Plongint; interlace_type:Plongint; compression_type:Plongint; filter_type:Plongint):png_uint_32;cdecl; external LibPng;
procedure png_set_IHDR(png_ptr:png_structp; info_ptr:png_infop; width:png_uint_32; height:png_uint_32; bit_depth:longint;
            color_type:longint; interlace_type:longint; compression_type:longint; filter_type:longint);cdecl; external LibPng;
function png_get_oFFs(png_ptr:png_structp; info_ptr:png_infop; offset_x:Ppng_int_32; offset_y:Ppng_int_32; unit_type:Plongint):png_uint_32;cdecl; external LibPng;
procedure png_set_oFFs(png_ptr:png_structp; info_ptr:png_infop; offset_x:png_int_32; offset_y:png_int_32; unit_type:longint);cdecl; external LibPng;
function png_get_pCAL(png_ptr:png_structp; info_ptr:png_infop; purpose:Ppng_charp; X0:Ppng_int_32; X1:Ppng_int_32;
           atype:Plongint; nparams:Plongint; units:Ppng_charp; params:Ppng_charpp):png_uint_32;cdecl; external LibPng;
procedure png_set_pCAL(png_ptr:png_structp; info_ptr:png_infop; purpose:png_charp; X0:png_int_32; X1:png_int_32;
            atype:longint; nparams:longint; units:png_charp; params:png_charpp);cdecl; external LibPng;
function png_get_pHYs(png_ptr:png_structp; info_ptr:png_infop; res_x:Ppng_uint_32; res_y:Ppng_uint_32; unit_type:Plongint):png_uint_32;cdecl; external LibPng;
procedure png_set_pHYs(png_ptr:png_structp; info_ptr:png_infop; res_x:png_uint_32; res_y:png_uint_32; unit_type:longint);cdecl; external LibPng;
function png_get_PLTE(png_ptr:png_structp; info_ptr:png_infop; palette:Ppng_colorp; num_palette:Plongint):png_uint_32;cdecl; external LibPng;
procedure png_set_PLTE(png_ptr:png_structp; info_ptr:png_infop; palette:png_colorp; num_palette:longint);cdecl; external LibPng;
function png_get_sBIT(png_ptr:png_structp; info_ptr:png_infop; sig_bit:Ppng_color_8p):png_uint_32;cdecl; external LibPng;
procedure png_set_sBIT(png_ptr:png_structp; info_ptr:png_infop; sig_bit:png_color_8p);cdecl; external LibPng;
function png_get_sRGB(png_ptr:png_structp; info_ptr:png_infop; intent:Plongint):png_uint_32;cdecl; external LibPng;
procedure png_set_sRGB(png_ptr:png_structp; info_ptr:png_infop; intent:longint);cdecl; external LibPng;
procedure png_set_sRGB_gAMA_and_cHRM(png_ptr:png_structp; info_ptr:png_infop; intent:longint);cdecl; external LibPng;
function png_get_iCCP(png_ptr:png_structp; info_ptr:png_infop; name:png_charpp; compression_type:Plongint; profile:png_charpp;
           proflen:Ppng_uint_32):png_uint_32;cdecl; external LibPng;
procedure png_set_iCCP(png_ptr:png_structp; info_ptr:png_infop; name:png_charp; compression_type:longint; profile:png_charp;
            proflen:png_uint_32);cdecl; external LibPng;
function png_get_sPLT(png_ptr:png_structp; info_ptr:png_infop; entries:png_sPLT_tpp):png_uint_32;cdecl; external LibPng;
procedure png_set_sPLT(png_ptr:png_structp; info_ptr:png_infop; entries:png_sPLT_tp; nentries:longint);cdecl; external LibPng;
function png_get_text(png_ptr:png_structp; info_ptr:png_infop; text_ptr:Ppng_textp; num_text:Plongint):png_uint_32;cdecl; external LibPng;
procedure png_set_text(png_ptr:png_structp; info_ptr:png_infop; text_ptr:png_textp; num_text:longint);cdecl; external LibPng;
function png_get_tIME(png_ptr:png_structp; info_ptr:png_infop; mod_time:Ppng_timep):png_uint_32;cdecl; external LibPng;
procedure png_set_tIME(png_ptr:png_structp; info_ptr:png_infop; mod_time:png_timep);cdecl; external LibPng;
function png_get_tRNS(png_ptr:png_structp; info_ptr:png_infop; trans:Ppng_bytep; num_trans:Plongint; trans_values:Ppng_color_16p):png_uint_32;cdecl; external LibPng;
procedure png_set_tRNS(png_ptr:png_structp; info_ptr:png_infop; trans:png_bytep; num_trans:longint; trans_values:png_color_16p);cdecl; external LibPng;
function png_get_sCAL(png_ptr:png_structp; info_ptr:png_infop; aunit:Plongint; width:Pdouble; height:Pdouble):png_uint_32;cdecl; external LibPng;
procedure png_set_sCAL(png_ptr:png_structp; info_ptr:png_infop; aunit:longint; width:double; height:double);cdecl; external LibPng;
procedure png_set_sCAL_s(png_ptr:png_structp; info_ptr:png_infop; aunit:longint; swidth:png_charp; sheight:png_charp);cdecl; external LibPng;
procedure png_set_keep_unknown_chunks(png_ptr:png_structp; keep:longint; chunk_list:png_bytep; num_chunks:longint);cdecl; external LibPng;
procedure png_set_unknown_chunks(png_ptr:png_structp; info_ptr:png_infop; unknowns:png_unknown_chunkp; num_unknowns:longint);cdecl; external LibPng;
procedure png_set_unknown_chunk_location(png_ptr:png_structp; info_ptr:png_infop; chunk:longint; location:longint);cdecl; external LibPng;
function png_get_unknown_chunks(png_ptr:png_structp; info_ptr:png_infop; entries:png_unknown_chunkpp):png_uint_32;cdecl; external LibPng;
procedure png_set_invalid(png_ptr:png_structp; info_ptr:png_infop; mask:longint);cdecl; external LibPng;
procedure png_read_png(png_ptr:png_structp; info_ptr:png_infop; transforms:longint; params:voidp);cdecl; external LibPng;
procedure png_write_png(png_ptr:png_structp; info_ptr:png_infop; transforms:longint; params:voidp);cdecl; external LibPng;
function png_get_header_ver(png_ptr:png_structp):png_charp;cdecl; external LibPng;
function png_get_header_version(png_ptr:png_structp):png_charp;cdecl; external LibPng;
function png_get_libpng_ver(png_ptr:png_structp):png_charp;cdecl; external LibPng;
{$ifend}

implementation

end.
