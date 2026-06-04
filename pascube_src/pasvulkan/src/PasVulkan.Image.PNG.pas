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
unit PasVulkan.Image.PNG;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(fpc) and defined(Android) and defined(cpuarm)}
 {$define UsePNGExternalLibrary}
{$else}
 {$undef UsePNGExternalLibrary}
{$ifend}
{$undef fpc_}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Compression.Deflate;

type EpvLoadPNGImage=class(Exception);

     PpvPNGPixelFormat=^TpvPNGPixelFormat;
     TpvPNGPixelFormat=
      (
       Unknown,
       R8G8B8A8,
       R16G16B16A16
      );

function LoadPNGImage(DataPointer:TpvPointer;DataSize:TpvUInt32;var ImageData:TpvPointer;var ImageWidth,ImageHeight:TpvInt32;const HeaderOnly:boolean;var PixelFormat:TpvPNGPixelFormat):boolean;

function SavePNGImage(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;out aDestData:TpvPointer;out aDestDataSize:TpvUInt32;const aImagePixelFormat:TpvPNGPixelFormat=TpvPNGPixelFormat.R8G8B8A8;const aFast:boolean=false):boolean;

function SavePNGImageAsStream(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aStream:TStream;const aImagePixelFormat:TpvPNGPixelFormat=TpvPNGPixelFormat.R8G8B8A8;const aFast:boolean=false):boolean;

function SavePNGImageAsFile(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aFileName:string;const aImagePixelFormat:TpvPNGPixelFormat=TpvPNGPixelFormat.R8G8B8A8;const aFast:boolean=false):boolean;

implementation

{$if defined(fpc) and defined(UsePNGExternalLibrary)}
uses PasVulkan.Image.PNG.ExternalLibrary;
{$elseif defined(fpc_)}
uses FPReadPNG,FPImage;
{$ifend}

function CRC32(const aData:TpvPointer;const aLength:TpvUInt32):TpvUInt32;
const CRC32Table:array[0..15] of TpvUInt32=($00000000,$1db71064,$3b6e20c8,$26d930ac,$76dc4190,
                                            $6b6b51f4,$4db26158,$5005713c,$edb88320,$f00f9344,
                                            $d6d6a3e8,$cb61b38c,$9b64c2b0,$86d3d2d4,$a00ae278,
                                            $bdbdf21c);

var Buf:PpvUInt8;
    Index:TpvUInt32;
begin
 if aLength=0 then begin
  result:=0;
 end else begin
  Buf:=aData;
  result:=$ffffffff;
  for Index:=1 to aLength do begin
   result:=result xor Buf^;
   result:=CRC32Table[result and $f] xor (result shr 4);
   result:=CRC32Table[result and $f] xor (result shr 4);
   inc(Buf);
  end;
  result:=result xor $ffffffff;
 end;
end;

{$if defined(fpc) and defined(UsePNGExternalLibrary)}
type POwnStream=^TOwnStream;
     TOwnStream=record
      Data:pointer;
     end;

procedure PNGReadData(png_ptr:png_structp;OutData:png_bytep;Bytes:png_size_t); cdecl;
var p:POwnStream;
begin
 p:=png_get_io_ptr(png_ptr);
 Move(p^.Data^,OutData^,Bytes);
 inc(p^.Data,Bytes);
end;
{$ifend}

{$if defined(fpc_) and not defined(UsePNGExternalLibrary)}
type TFPImage=class(TFPMemoryImage)
      public
       function GetScanline(const y:TpvInt32):pointer;
      end;

function TFPImage.GetScanline(const y:TpvInt32):pointer;
begin
 result:=@fData^[y*Width*2];
end;
{$ifend}

function LoadPNGImage(DataPointer:TpvPointer;DataSize:TpvUInt32;var ImageData:TpvPointer;var ImageWidth,ImageHeight:TpvInt32;const HeaderOnly:boolean;var PixelFormat:TpvPNGPixelFormat):boolean;
{$if defined(fpc) and defined(UsePNGExternalLibrary)}
const kPngSignatureLength=8;
var png_ptr:png_structp;
    info_ptr:png_infop;
    Stream:TOwnStream;
    Width,Height,BytesPerRow:TpvUInt32;
    BitDepth,ColorType,x,y,NumPasses,Pass:TpvInt32;
    Row,Src,Dst:PpvUInt8;
    Src16,Dst16:PpvUInt16;
    color:png_colorp;
    Value:byte;
begin

 result:=false;

 if png_sig_cmp(DataPointer,0,8)<>0 then begin
  exit;
 end;

 png_ptr:=png_create_read_struct(PNG_LIBPNG_VER_STRING,nil,nil,nil);
 if not assigned(png_ptr) then begin
  exit;
 end;

 info_Ptr:=png_create_info_struct(png_Ptr);
 if not assigned(info_ptr) then begin
  png_destroy_read_struct(@png_Ptr,nil,nil);
  exit;
 end;

 Stream.Data:=@PAnsiChar(DataPointer)[0];

 png_set_read_fn(png_ptr,@Stream,PNGReadData);

//png_set_sig_bytes(png_ptr,kPngSignatureLength);

 png_read_info(png_ptr,info_ptr);

 Width:=0;
 Height:=0;
 BitDepth:=0;
 ColorType:=-1;
 if png_get_IHDR(png_ptr,info_ptr,@Width,@Height,@BitDepth,@ColorType,nil,nil,nil)<>1 then begin
  png_destroy_read_struct(@png_Ptr,nil,nil);
  exit;
 end;

 ImageWidth:=Width;
 ImageHeight:=Height;

 if ColorType in [PNG_COLOR_TYPE_GRAY,
                  PNG_COLOR_TYPE_GRAY_ALPHA,
                  PNG_COLOR_TYPE_PALETTE,
                  PNG_COLOR_TYPE_RGB,
                  PNG_COLOR_TYPE_RGBA] then begin
  png_set_packing(png_ptr);
  if (ColorType=PNG_COLOR_TYPE_PALETTE) or
     ((ColorType=PNG_COLOR_TYPE_GRAY) and (BitDepth<8)) or
     (png_get_valid(png_ptr,info_ptr,PNG_INFO_tRNS)=PNG_INFO_tRNS) then begin
   png_set_expand(png_ptr);
  end;
  png_set_gray_to_rgb(png_ptr);
  png_set_filler(png_ptr,$ff,PNG_FILLER_AFTER);
  png_read_update_info(png_ptr,info_ptr);
  if png_get_IHDR(png_ptr,info_ptr,@Width,@Height,@BitDepth,@ColorType,nil,nil,nil)<>1 then begin
   png_destroy_read_struct(@png_Ptr,nil,nil);
   exit;
  end;
  case BitDepth of
   16:begin
    PixelFormat:=TpvPNGPixelFormat.R16G16B16A16;
   end;
   else begin
    PixelFormat:=TpvPNGPixelFormat.R8G8B8A8;
   end;
  end;
  if not HeaderOnly then begin
   case BitDepth of
    16:begin
     GetMem(ImageData,ImageWidth*ImageHeight*8);
    end;
    else begin
     GetMem(ImageData,ImageWidth*ImageHeight*4);
    end;
   end;
   BytesPerRow:=png_get_rowbytes(png_ptr,info_ptr);
   GetMem(Row,BytesPerRow*2);
   NumPasses:=png_set_interlace_handling(png_ptr);
   for Pass:=1 to NumPasses do begin
    case ColorType of
     PNG_COLOR_TYPE_GRAY:begin
      case BitDepth of
       8:begin
        Dst:=ImageData;
        for y:=0 to ImageHeight-1 do begin
         png_read_row(png_ptr,pointer(Row),nil);
         Src:=Row;
         for x:=0 to ImageWidth-1 do begin
          Value:=Src^;
          inc(Src);
          Dst^:=Value;
          inc(Dst);
          Dst^:=Value;
          inc(Dst);
          Dst^:=Value;
          inc(Dst);
          Dst^:=$ff;
          inc(Dst);
         end;
        end;
       end;
       16:begin
        Dst16:=ImageData;
        for y:=0 to ImageHeight-1 do begin
         png_read_row(png_ptr,pointer(Row),nil);
         Src16:=pointer(Row);
         for x:=0 to ImageWidth-1 do begin
          Value:=Src16^;
          inc(Src16);
          Dst16^:=Value;
          inc(Dst16);
          Dst16^:=Value;
          inc(Dst16);
          Dst16^:=Value;
          inc(Dst16);
          Dst16^:=$ffff;
          inc(Dst16);
         end;
        end;
       end;
       else begin
        png_destroy_read_struct(@png_Ptr,nil,nil);
        exit;
       end;
      end;
     end;
     PNG_COLOR_TYPE_GRAY_ALPHA:begin
      Dst:=ImageData;
      for y:=0 to ImageHeight-1 do begin
       png_read_row(png_ptr,pointer(Row),nil);
       Src:=Row;
       for x:=0 to ImageWidth-1 do begin
        Dst^:=Src^;
        inc(Dst);
        Dst^:=Src^;
        inc(Dst);
        Dst^:=Src^;
        inc(Dst);
        inc(Src);
        Dst^:=Src^;
        inc(Dst);
        inc(Src);
       end;
      end;
     end;
     PNG_COLOR_TYPE_PALETTE:begin
      Dst:=ImageData;
      for y:=0 to ImageHeight-1 do begin
       png_read_row(png_ptr,pointer(Row),nil);
       Src:=Row;
       for x:=0 to ImageWidth-1 do begin
        color:=info_ptr^.palette;
        inc(color,Src^);
        inc(Src);
        Dst^:=color^.red;
        inc(Dst);
        Dst^:=color^.green;
        inc(Dst);
        Dst^:=color^.blue;
        inc(Dst);
        Dst^:=$ff;
        inc(Dst);
       end;
      end;
     end;
     PNG_COLOR_TYPE_RGB,PNG_COLOR_TYPE_RGBA:begin
      case BitDepth of
       8:begin
        Dst:=ImageData;
        for y:=0 to ImageHeight-1 do begin
         png_read_row(png_ptr,pointer(Row),nil);
         Src:=Row;
         Move(Src^,Dst^,ImageWidth*4);
         inc(Dst,ImageWidth*4);
        end;
       end;
       16:begin
        Dst:=ImageData;
        for y:=0 to ImageHeight-1 do begin
         png_read_row(png_ptr,pointer(Row),nil);
         Src:=pointer(Row);
         Move(Src^,Dst^,ImageWidth*8);
         inc(Dst,ImageWidth*8);
        end;
       end;
       else begin
        png_destroy_read_struct(@png_Ptr,nil,nil);
        exit;
       end;
      end;
     end;
    end;
   end;
   FreeMem(Row);
   png_read_end(png_ptr,info_ptr);
  end;
 end else begin
  png_destroy_read_struct(@png_Ptr,nil,nil);
  exit;
 end;

 png_destroy_read_struct(@png_Ptr,nil,nil);

 result:=true;
end;
{$elseif defined(fpc_)}
var Image:TFPMemoryImage;
    Stream:TMemoryStream;
    sp,dp:PpvUInt8;
    y,x:TpvInt32;
    c:TpvUInt32;
    Reader:TFPReaderPNG;
begin

 Reader:=TFPReaderPNG.Create;
 try

  Stream:=TMemoryStream.Create;
  try
   Stream.Write(DataPointer^,DataSize);
   Stream.Seek(0,soFromBeginning);

   // Load image
   Image:=TFPMemoryImage.create(0,0);
   try

    Image.LoadFromStream(Stream,Reader);

    ImageWidth:=Image.Width;
    ImageHeight:=Image.Height;
    GetMem(ImageData,ImageWidth*ImageHeight*4);

    for y:=0 to ImageHeight-1 do begin
     sp:=TFPImage(Image).GetScanline(y);
     inc(sp);
     dp:=ImageData;
     inc(dp,y*ImageWidth);
     for x:=0 to ImageWidth-1 do begin
      c:=sp^;
      inc(sp,2);
      c:=(c shl 8) or sp^;
      inc(sp,2);
      c:=(c shl 8) or sp^;
      inc(sp,2);
      PUInt32(dp)^:=(sp^ shl 24) or c;
      inc(sp,2);
      inc(dp,4);
     end;
    end;

    PixelFormat:=TpvPNGPixelFormat.R8G8B8A8;

    result:=true;

   finally
    FreeAndNil(Image);
   end;
  finally
   FreeAndNil(Stream);
  end;
 finally
  FreeAndNil(Reader);
 end;
end;
{$else}
type TBitsUsed=array[0..7] of TpvUInt32;
     PByteArray=^TByteArray;
     TByteArray=array[0..65535] of TpvUInt8;
     TColorData=TpvUInt64;
     TPixelColorType=
      (
       Unknown,
       Palette1,
       Palette2,
       Palette4,
       Palette8,
       Gray1,
       Gray2,
       Gray4,
       Gray8,
       Gray16,
       GrayAlpha8,
       GrayAlpha16,
       Color8,
       Color16,
       ColorAlpha8,
       ColorAlpha16
      );
     PPNGPixelUI8=^TPNGPixelUI8;
     TPNGPixelUI8=packed record
      r,g,b,a:TpvUInt8;
     end;
     PPNGPixelUI16=^TPNGPixelUI16;
     TPNGPixelUI16=packed record
      r,g,b,a:TpvUInt16;
     end;
const StartPoints:array[0..7,0..1] of TpvUInt16=((0,0),(0,0),(4,0),(0,4),(2,0),(0,2),(1,0),(0,1));
      Delta:array[0..7,0..1] of TpvUInt16=((1,1),(8,8),(8,8),(4,8),(4,4),(2,4),(2,2),(1,2));
      BitsUsed1Depth:TBitsUsed=($80,$40,$20,$10,$08,$04,$02,$01);
      BitsUsed2Depth:TBitsUsed=($c0,$30,$0c,$03,0,0,0,0);
      BitsUsed4Depth:TBitsUsed=($f0,$0f,0,0,0,0,0,0);
var DataEnd,DataPtr,DataNextChunk,DataPtrEx:TpvPointer;
    PixelColorType:TPixelColorType;
    ByteWidth:TpvInt32;
    CountBitsUsed,BitShift:TpvUInt32;
    BitDepth,StartX,StartY,DeltaX,DeltaY,OutputBitsPerPixel,WidthHeight:TpvInt32;
    BitsUsed:TBitsUsed;
    SwitchLine,CurrentLine,PreviousLine:PByteArray;
    CountScanlines,ScanLineLength:array[0..7] of TpvUInt32;
    ChunkLength,ChunkType,Width,Height,ColorType,Comp,Filter,Interlace,CRC,
    PalImgBytes,ImgBytes,PaletteSize,l,ml:TpvUInt32;
    First,HasTransparent,CgBI:boolean;
    Palette:array of TPNGPixelUI16;
    TransparentColor:array of TpvUInt16;
    i,rx,ry,y{,BitsPerPixel,ImageLineWidth,ImageSize},StartPass,EndPass,d:TpvInt32;
    idata,DecompressPtr:TpvPointer;
    idatasize,idatacapacity,LineFilter:TpvUInt32;
    idataexpandedsize:TpvSizeUInt;
    idataexpanded:TpvPointer;
    UsingBitGroup,DataIndex:TpvUInt32;
    Last:TpvUInt64;
 procedure RaiseError;
 begin
  raise EpvLoadPNGImage.Create('Invalid or corrupt PNG stream');
 end;
 function Swap16(x:TpvUInt16):TpvUInt16; {$ifdef fpc}inline;{$endif}
 begin
  result:=((x and $ff) shl 8) or ((x and $ff00) shr 8);
 end;
 function Swap32(x:TpvUInt32):TpvUInt32; {$ifdef fpc}inline;{$endif}
 begin
  result:=(Swap16(x and $ffff) shl 16) or Swap16((x and $ffff0000) shr 16);
 end;
 function Swap64(x:TpvUInt64):TpvUInt64; {$ifdef fpc}inline;{$endif}
 begin
  result:=(TpvUInt64(Swap32(x and TpvUInt64($ffffffff))) shl 32) or Swap32((x and TpvUInt64($ffffffff00000000)) shr 32);
 end;
 function GetU8(var p:TpvPointer):TpvUInt8; {$ifdef fpc}inline;{$endif}
 begin
  result:=TpvUInt8(p^);
  inc(PpvRawByteChar(p),sizeof(TpvUInt8));
 end;
 function GetU16(var p:TpvPointer):TpvUInt16; {$ifdef fpc}inline;{$endif}
 begin
  result:=GetU8(p) shl 8;
  result:=result or GetU8(p);
 end;
 function GetU32(var p:TpvPointer):TpvUInt32; {$ifdef fpc}inline;{$endif}
 begin
  result:=GetU16(p) shl 16;
  result:=result or GetU16(p);
 end;
 function CalcColor:TColorData; {$ifdef fpc}inline;{$endif}
 var i:TpvInt32;
     p:TpvPointer;
     w:PpvUInt16;
     v:TpvUInt16;
 begin
  if UsingBitGroup=0 then begin
{$ifdef big_endian}
   result:=0;
   Move(CurrentLine^[DataIndex],result,ByteWidth);
{$else}
   p:=@CurrentLine^[DataIndex];
   case ByteWidth of
    1:begin
     result:=TpvUInt8(p^);
    end;
    2:begin
     result:=TpvUInt16(p^);
    end;
    4:begin
     result:=TpvUInt32(p^);
    end;
    8:begin
     result:=TpvUInt64(p^);
    end;
    else begin
     result:=0;
     Move(p^,result,ByteWidth);
    end;
   end;
{$endif}
   if BitDepth=16 then begin
    p:=@result;
    w:=p;
    for i:=1 to ByteWidth div SizeOf(TpvUInt16) do begin
     v:=w^;
     w^:=((v and $ff) shl 8) or ((v and $ff00) shr 8);
     inc(w);
    end;
   end;
{$ifdef big_endian}
   result:=Swap64(result);
{$endif}
   inc(DataIndex,ByteWidth);
   Last:=result;
  end else begin
   result:=Last;
  end;
  if ByteWidth=1 then begin
   result:=(TpvUInt32(result and BitsUsed[UsingBitGroup]) and $ffffffff) shr (((CountBitsUsed-UsingBitGroup)-1)*BitShift);
   inc(UsingBitgroup);
   if UsingBitGroup>=CountBitsUsed then begin
    UsingBitGroup:=0;
   end;
  end;
 end;
 procedure HandleScanLine(const y,CurrentPass:TpvInt32;const ScanLine:PByteArray);
 var x,l,pc:TpvInt32;
     c:TColorData;
     pe:TPNGPixelUI16;
     pui8:PPNGPixelUI8;
     pui16:PPNGPixelUI16;
 begin
  UsingBitGroup:=0;
  DataIndex:=0;
  pc:=length(Palette);
  l:=length(TransparentColor);
  for x:=0 to ScanlineLength[CurrentPass]-1 do begin
   case PixelColorType of
    TPixelColorType.Palette1:begin
     c:=CalcColor;
     if c<pc then begin
      pe:=Palette[c];
     end else begin
      pe.r:=0;
      pe.g:=0;
      pe.b:=0;
      pe.a:=0;
     end;
    end;
    TPixelColorType.Palette2:begin
     c:=CalcColor;
     if c<pc then begin
      pe:=Palette[c];
     end else begin
      pe.r:=0;
      pe.g:=0;
      pe.b:=0;
      pe.a:=0;
     end;
    end;
    TPixelColorType.Palette4:begin
     c:=CalcColor;
     if c<pc then begin
      pe:=Palette[c];
     end else begin
      pe.r:=0;
      pe.g:=0;
      pe.b:=0;
      pe.a:=0;
     end;
    end;
    TPixelColorType.Palette8:begin
     c:=CalcColor;
     if c<pc then begin
      pe:=Palette[c];
     end else begin
      pe.r:=0;
      pe.g:=0;
      pe.b:=0;
      pe.a:=0;
     end;
    end;
    TPixelColorType.Gray1:begin
     c:=CalcColor;
     pe.r:=(0-(c and 1)) and $ffff;
     pe.g:=(0-(c and 1)) and $ffff;
     pe.b:=(0-(c and 1)) and $ffff;
     pe.a:=$ffff;
    end;
    TPixelColorType.Gray2:begin
     c:=CalcColor;
     pe.r:=(c and 3) or ((c and 3) shl 2) or ((c and 3) shl 4) or ((c and 3) shl 6) or ((c and 3) shl 8) or ((c and 3) shl 10) or ((c and 3) shl 12) or ((c and 3) shl 14);
     pe.g:=(c and 3) or ((c and 3) shl 2) or ((c and 3) shl 4) or ((c and 3) shl 6) or ((c and 3) shl 8) or ((c and 3) shl 10) or ((c and 3) shl 12) or ((c and 3) shl 14);
     pe.b:=(c and 3) or ((c and 3) shl 2) or ((c and 3) shl 4) or ((c and 3) shl 6) or ((c and 3) shl 8) or ((c and 3) shl 10) or ((c and 3) shl 12) or ((c and 3) shl 14);
     pe.a:=$ffff;
    end;
    TPixelColorType.Gray4:begin
     c:=CalcColor;
     pe.r:=(c and $f) or ((c and $f) shl 4) or ((c and $f) shl 8) or ((c and $f) shl 12);
     pe.g:=(c and $f) or ((c and $f) shl 4) or ((c and $f) shl 8) or ((c and $f) shl 12);
     pe.b:=(c and $f) or ((c and $f) shl 4) or ((c and $f) shl 8) or ((c and $f) shl 12);
     pe.a:=$ffff;
    end;
    TPixelColorType.Gray8:begin
     pe.r:=TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^) or (TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^)) shl 8);
     pe.g:=pe.r;
     pe.b:=pe.r;
     pe.a:=$ffff;
     inc(DataIndex);
    end;
    TPixelColorType.Gray16:begin
     pe.r:=(TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^)) shl 8) or TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+1])^);
     pe.g:=pe.r;
     pe.b:=pe.r;
     pe.a:=$ffff;
     inc(DataIndex,2);
    end;
    TPixelColorType.GrayAlpha8:begin
     c:=CalcColor;
     pe.r:=(c and $00ff) or ((c and $00ff) shl 8);
     pe.g:=(c and $00ff) or ((c and $00ff) shl 8);
     pe.b:=(c and $00ff) or ((c and $00ff) shl 8);
     pe.a:=(c and $ff00) or ((c and $ff00) shr 8);
    end;
    TPixelColorType.GrayAlpha16:begin
     c:=CalcColor;
     pe.r:=(c shr 16) and $ffff;
     pe.g:=(c shr 16) and $ffff;
     pe.b:=(c shr 16) and $ffff;
     pe.a:=c and $ffff;
    end;
    TPixelColorType.Color8:begin
     pe.r:=TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^) or (TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^)) shl 8);
     pe.g:=TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+1])^) or (TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+1])^)) shl 8);
     pe.b:=TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+2])^) or (TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+2])^)) shl 8);
     pe.a:=$ffff;
     inc(DataIndex,3);
    end;
    TPixelColorType.Color16:begin
     pe.r:=(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^) shl 8) or
           (TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+1])^) shl 0);
     pe.g:=(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+2])^) shl 8) or
           (TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+3])^) shl 0);
     pe.b:=(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+4])^) shl 8) or
           (TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+5])^) shl 0);
     pe.a:=$ffff;
     inc(DataIndex,6);
    end;
    TPixelColorType.ColorAlpha8:begin
     pe.r:=TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^) or (TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^)) shl 8);
     pe.g:=TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+1])^) or (TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+1])^)) shl 8);
     pe.b:=TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+2])^) or (TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+2])^)) shl 8);
     pe.a:=TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+3])^) or (TpvUInt16(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+3])^)) shl 8);
     inc(DataIndex,4);
    end;
    TPixelColorType.ColorAlpha16:begin
     pe.r:=(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+0])^) shl 8) or
           (TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+1])^) shl 0);
     pe.g:=(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+2])^) shl 8) or
           (TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+3])^) shl 0);
     pe.b:=(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+4])^) shl 8) or
           (TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+5])^) shl 0);
     pe.a:=(TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+6])^) shl 8) or
           (TpvUInt8(TpvPointer(@CurrentLine^[DataIndex+7])^) shl 0);
     inc(DataIndex,8);
    end;
    else begin
     pe.r:=0;
     pe.g:=0;
     pe.b:=0;
     pe.a:=0;
     RaiseError;
    end;
   end;
   if (((l=1) and ((pe.r=TransparentColor[0]) and (pe.r=TransparentColor[0]) and (pe.b=TransparentColor[0])))) or
      (((l=3) and ((pe.r=TransparentColor[0]) and (pe.r=TransparentColor[1]) and (pe.b=TransparentColor[2])))) then begin
    pe.a:=0;
   end;
   case PixelFormat of
    TpvPNGPixelFormat.R8G8B8A8:begin
     pui8:=PPNGPixelUI8(TpvPointer(@PpvRawByteChar(ImageData)[((y*TpvInt32(Width))+(StartX+(x*DeltaX)))*sizeof(TPNGPixelUI8)]));
     pui8^.r:=pe.r shr 8;
     pui8^.g:=pe.g shr 8;
     pui8^.b:=pe.b shr 8;
     pui8^.a:=pe.a shr 8;
    end;
    TpvPNGPixelFormat.R16G16B16A16:begin
     pui16:=PPNGPixelUI16(TpvPointer(@PpvRawByteChar(ImageData)[((y*TpvInt32(Width))+(StartX+(x*DeltaX)))*sizeof(TPNGPixelUI16)]));
     pui16^.r:=pe.r;
     pui16^.g:=pe.g;
     pui16^.b:=pe.b;
     pui16^.a:=pe.a;
    end;
    else begin
     RaiseError;
    end;
   end;
  end;
 end;
 procedure CgBISwapBGR2RGBandUnpremultiply;
 var i,b,a:TpvInt32;
     pui8:PPNGPixelUI8;
     pui16:PPNGPixelUI16;
 begin
  case PixelFormat of
   TpvPNGPixelFormat.R8G8B8A8:begin
    a:=255;
    pui8:=PPNGPixelUI8(TpvPointer(@PpvRawByteChar(ImageData)[0]));
    for i:=0 to WidthHeight-1 do begin
     a:=a and pui8^.a;
     inc(pui8);
    end;
    if ((ColorType and 4)<>0) or (a<>255) or HasTransparent then begin
     pui8:=PPNGPixelUI8(TpvPointer(@PpvRawByteChar(ImageData)[0]));
     for i:=0 to WidthHeight-1 do begin
      a:=pui8^.a;
      if a<>0 then begin
       b:=pui8^.b;
       pui8^.b:=(pui8^.r*255) div a;
       pui8^.r:=(b*255) div a;
       pui8^.g:=(pui8^.g*255) div a;
      end else begin
       b:=pui8^.b;
       pui8^.b:=pui8^.r;
       pui8^.r:=b;
      end;
      inc(pui8);
     end;
    end else begin
     pui8:=PPNGPixelUI8(TpvPointer(@PpvRawByteChar(ImageData)[0]));
     for i:=0 to WidthHeight-1 do begin
      b:=pui8^.b;
      pui8^.b:=pui8^.r;
      pui8^.r:=b;
      inc(pui8);
     end;
    end;
   end;
   TpvPNGPixelFormat.R16G16B16A16:begin
    a:=65535;
    pui16:=PPNGPixelUI16(TpvPointer(@PpvRawByteChar(ImageData)[0]));
    for i:=0 to WidthHeight-1 do begin
     a:=a and pui16^.a;
     inc(pui16);
    end;
    if ((ColorType and 4)<>0) or (a<>65535) or HasTransparent then begin
     pui16:=PPNGPixelUI16(TpvPointer(@PpvRawByteChar(ImageData)[0]));
     for i:=0 to WidthHeight-1 do begin
      a:=pui16^.a;
      if a<>0 then begin
       b:=pui16^.b;
       pui16^.b:=(pui16^.r*65535) div a;
       pui16^.r:=(b*65535) div a;
       pui16^.g:=(pui16^.g*65535) div a;
      end else begin
       b:=pui16^.b;
       pui16^.b:=pui16^.r;
       pui16^.r:=b;
      end;
      inc(pui16);
     end;
    end else begin
     pui16:=PPNGPixelUI16(TpvPointer(@PpvRawByteChar(ImageData)[0]));
     for i:=0 to WidthHeight-1 do begin
      b:=pui16^.b;
      pui16^.b:=pui16^.r;
      pui16^.r:=b;
      inc(pui16);
     end;
    end;
   end;
   else begin
    RaiseError;
   end;
  end;
 end;
 function Paeth(a,b,c:TpvInt32):TpvInt32; {$ifdef fpc}inline;{$endif}
 var p,pa,pb,pc:TpvInt32;
 begin
  p:=(a+b)-c;
  pa:=abs(p-a);
  pb:=abs(p-b);
  pc:=abs(p-c);
  if (pa<=pb) and (pa<=pc) then begin
   result:=a;
  end else if pb<=pc then begin
   result:=b;
  end else begin
   result:=c;
  end;
 end;
begin
 result:=false;
 ImageData:=nil;
 try
  Palette:=nil;
  TransparentColor:=nil;
  idataexpanded:=nil;
  idata:=nil;
  idataexpanded:=nil;
  try
   try
    if (assigned(DataPointer) and (DataSize>8)) and
       ((PpvRawByteChar(DataPointer)[0]=#$89) and (PpvRawByteChar(DataPointer)[1]=#$50) and (PpvRawByteChar(DataPointer)[2]=#$4e) and (PpvRawByteChar(DataPointer)[3]=#$47) and
        (PpvRawByteChar(DataPointer)[4]=#$0d) and (PpvRawByteChar(DataPointer)[5]=#$0a) and (PpvRawByteChar(DataPointer)[6]=#$1a) and (PpvRawByteChar(DataPointer)[7]=#$0a)) then begin
     DataEnd:=@PpvRawByteChar(DataPointer)[DataSize];
     First:=true;
     PalImgBytes:=0;
     ImgBytes:=0;
     DataPtr:=@PpvRawByteChar(DataPointer)[8];
     Width:=0;
     Height:=0;
     idatasize:=0;
     idatacapacity:=0;
     PaletteSize:=0;
     idataexpandedsize:=0;
     BitDepth:=0;
     ColorType:=0;
     Interlace:=0;
     WidthHeight:=0;
     CgBI:=false;
     HasTransparent:=false;
     while (PpvRawByteChar(DataPtr)+11)<PpvRawByteChar(DataEnd) do begin
      ChunkLength:=GetU32(DataPtr);
      if (PpvRawByteChar(DataPtr)+(4+ChunkLength))>PpvRawByteChar(DataEnd) then begin
       result:=false;
       break;
      end;
      DataPtrEx:=DataPtr;
      ChunkType:=GetU32(DataPtr);
      DataNextChunk:=@PpvRawByteChar(DataPtr)[ChunkLength];
      CRC:=GetU32(DataNextChunk);
      if CRC32(DataPtrEx,ChunkLength+4)<>CRC then begin
       result:=false;
       break;
      end;
      case ChunkType of
       TpvUInt32((ord('C') shl 24) or (ord('g') shl 16) or (ord('B') shl 8) or ord('I')):begin // CgBI
        CgBI:=true;
       end;
       TpvUInt32((ord('I') shl 24) or (ord('H') shl 16) or (ord('D') shl 8) or ord('R')):begin // IHDR
        if ChunkLength=13 then begin
         if not First then begin
          result:=false;
          break;
         end;
         First:=false;
         Width:=GetU32(DataPtr);
         Height:=GetU32(DataPtr);
         if ((Width>(1 shl 24)) or (Height>(1 shl 24))) or ((Width=0) or (Height=0)) then begin
          result:=false;
          break;
         end;
         if HeaderOnly then begin
          result:=true;
          break;
         end;
         BitDepth:=GetU8(DataPtr);
         if not (BitDepth in [1,2,4,8,16]) then begin
          result:=false;
          break;
         end;
         ColorType:=GetU8(DataPtr);
         if (ColorType>6) or ((ColorType<>3) and ((ColorType and 1)<>0)) then begin
          result:=false;
          exit;
         end else if ColorType=3 then begin
          PalImgBytes:=3;
         end;
         Comp:=GetU8(DataPtr);
         if Comp<>0 then begin
          result:=false;
          break;
         end;
         Filter:=GetU8(DataPtr);
         if Filter<>0 then begin
          result:=false;
          break;
         end;
         Interlace:=GetU8(DataPtr);
         if Interlace>1 then begin
          result:=false;
          break;
         end;
         if PalImgBytes=0 then begin
          if (ColorType and 2)<>0 then begin
           ImgBytes:=3;
          end else begin
           ImgBytes:=1;
          end;
          if (ColorType and 4)<>0 then begin
           inc(ImgBytes);
          end;
          if (((1 shl 30) div Width) div ImgBytes)<Height then begin
           result:=false;
           break;
          end;
         end else begin
          ImgBytes:=1;
          if (((1 shl 30) div Width) div 4)<Height then begin
           result:=false;
           break;
          end;
         end;
        end else begin
         result:=false;
         break;
        end;
       end;
       TpvUInt32((ord('P') shl 24) or (ord('L') shl 16) or (ord('T') shl 8) or ord('E')):begin // PLTE
        if First then begin
         result:=false;
         break;
        end;
        case PalImgBytes of
         3:begin
          PaletteSize:=ChunkLength div 3;
          if (PaletteSize*3)<>ChunkLength then begin
           result:=false;
           break;
          end;
          SetLength(Palette,PaletteSize);
          for i:=0 to PaletteSize-1 do begin
           d:=GetU8(DataPtr);
           Palette[i].r:=d or (d shl 8);
           d:=GetU8(DataPtr);
           Palette[i].g:=d or (d shl 8);
           d:=GetU8(DataPtr);
           Palette[i].b:=d or (d shl 8);
           Palette[i].a:=$ff;
          end;
         end;
         4:begin
          PaletteSize:=ChunkLength div 4;
          if (PaletteSize*4)<>ChunkLength then begin
           result:=false;
           exit;
          end;
          SetLength(Palette,PaletteSize);
          for i:=0 to PaletteSize-1 do begin
           d:=GetU8(DataPtr);
           Palette[i].r:=d or (d shl 8);
           d:=GetU8(DataPtr);
           Palette[i].g:=d or (d shl 8);
           d:=GetU8(DataPtr);
           Palette[i].b:=d or (d shl 8);
           d:=GetU8(DataPtr);
           Palette[i].a:=d or (d shl 8);
          end;
         end;
         else begin
          result:=false;
          break;
         end;
        end;
       end;
       TpvUInt32((ord('t') shl 24) or (ord('R') shl 16) or (ord('N') shl 8) or ord('S')):begin // tRNS
        if First or assigned(idata) then begin
         result:=false;
         break;
        end;
        if PalImgBytes<>0 then begin
         if (length(Palette)=0) or (TpvInt32(ChunkLength)>length(Palette)) then begin
          result:=false;
          break;
         end;
         PalImgBytes:=4;
         for i:=0 to PaletteSize-1 do begin
          d:=GetU8(DataPtr);
          Palette[i].a:=d or (d shl 8);
         end;
        end else begin
         if ChunkLength=ImgBytes then begin
          SetLength(TransparentColor,TpvInt32(ImgBytes));
          for i:=0 to TpvInt32(ImgBytes)-1 do begin
           d:=GetU8(DataPtr);
           TransparentColor[i]:=d or (d shl 8);
          end;
         end else begin
          if ((ImgBytes and 1)=0) or (ChunkLength<>(ImgBytes*2)) then begin
           result:=false;
           break;
          end;
          HasTransparent:=true;
          SetLength(TransparentColor,TpvInt32(ImgBytes));
          for i:=0 to TpvInt32(ImgBytes)-1 do begin
           TransparentColor[i]:=GetU16(DataPtr);
          end;
         end;
        end;
       end;
       TpvUInt32((ord('I') shl 24) or (ord('D') shl 16) or (ord('A') shl 8) or ord('T')):begin // IDAT
        if First or ((PalImgBytes<>0) and (length(Palette)=0)) then begin
         result:=false;
         break;
        end;
        if (idatasize=0) or (idatacapacity=0) or not assigned(idata) then begin
         idatasize:=ChunkLength;
         idatacapacity:=ChunkLength;
         GetMem(idata,idatacapacity);
         Move(DataPtr^,idata^,ChunkLength);
        end else begin
         if (idatasize+ChunkLength)>=idatacapacity then begin
          if idatacapacity=0 then begin
           idatacapacity:=1;
          end;
          while (idatasize+ChunkLength)>=idatacapacity do begin
           inc(idatacapacity,idatacapacity);
          end;
          ReallocMem(idata,idatacapacity);
         end;
         Move(DataPtr^,PpvRawByteChar(idata)[idatasize],ChunkLength);
         inc(idatasize,ChunkLength);
        end;
       end;
       TpvUInt32((ord('I') shl 24) or (ord('E') shl 16) or (ord('N') shl 8) or ord('D')):begin // IEND
        if First or ((PalImgBytes<>0) and (length(Palette)=0)) or not assigned(idata) then begin
         result:=false;
         break;
        end;
        if not DoInflate(idata,idatasize,idataexpanded,idataexpandedsize,not CgBI) then begin
         result:=false;
         break;
        end;
//      BitsPerPixel:=TpvInt32(ImgBytes)*BitDepth;
        ImageWidth:=Width;
        ImageHeight:=Height;
        WidthHeight:=Width*Height;
        case BitDepth of
         16:begin
          OutputBitsPerPixel:=64;
          PixelFormat:=TpvPNGPixelFormat.R16G16B16A16;
         end;
         else begin
          OutputBitsPerPixel:=32;
          PixelFormat:=TpvPNGPixelFormat.R8G8B8A8;
         end;
        end;
//      ImageBytesPerPixel:=((TpvInt32(ImgBytes)*TpvInt32(BitDepth))+7) shr 3;
//      ImageLineWidth:=((ImageWidth*BitsPerPixel)+7) shr 3;
//      ImageSize:=(((ImageWidth*ImageHeight)*BitsPerPixel)+7) shr 3;
        GetMem(ImageData,(((ImageWidth*ImageHeight)*OutputBitsPerPixel)+7) shr 3);
        try
         CountBitsUsed:=0;
         case Interlace of
          0:begin
           StartPass:=0;
           EndPass:=0;
           CountScanlines[0]:=Height;
           ScanLineLength[0]:=Width;
          end;
          1:begin
           StartPass:=1;
           EndPass:=7;
           for i:=1 to 7 do begin
            d:=Height div Delta[i,1];
            if (Height mod Delta[i,1])>StartPoints[i,1] then begin
             inc(d);
            end;
            CountScanLines[i]:=d;
            d:=Width div Delta[i,0];
            if (Width mod Delta[i,0])>StartPoints[i,0] then begin
             inc(d);
            end;
            ScanLineLength[i]:=d;
           end;
          end;
          else begin
           if assigned(ImageData) then begin
            FreeMem(ImageData);
            ImageData:=nil;
           end;
           result:=false;
           break;
          end;
         end;
         ByteWidth:=0;
         PixelColorType:=TPixelColorType.Unknown;
         case ColorType of
          0:begin
           case BitDepth of
            1:begin
             PixelColorType:=TPixelColorType.Gray1;
             ByteWidth:=1;
            end;
            2:begin
             PixelColorType:=TPixelColorType.Gray2;
             ByteWidth:=1;
            end;
            4:begin
             PixelColorType:=TPixelColorType.Gray4;
             ByteWidth:=1;
            end;
            8:begin
             PixelColorType:=TPixelColorType.Gray8;
             ByteWidth:=1;
            end;
            16:begin
             PixelColorType:=TPixelColorType.Gray16;
             ByteWidth:=2;
            end;
           end;
          end;
          2:begin
           if BitDepth=8 then begin
            PixelColorType:=TPixelColorType.Color8;
            ByteWidth:=3;
           end else begin
            PixelColorType:=TPixelColorType.Color16;
            ByteWidth:=6;
           end;
          end;
          3:begin
           case BitDepth of
            1:begin
             PixelColorType:=TPixelColorType.Palette1;
            end;
            2:begin
             PixelColorType:=TPixelColorType.Palette2;
            end;
            4:begin
             PixelColorType:=TPixelColorType.Palette4;
            end;
            8:begin
             PixelColorType:=TPixelColorType.Palette8;
            end;
           end;
           if BitDepth=16 then begin
            ByteWidth:=2;
           end else begin
            ByteWidth:=1;
           end;
          end;
          4:begin
           if BitDepth=8 then begin
            PixelColorType:=TPixelColorType.GrayAlpha8;
            ByteWidth:=2;
           end else begin
            PixelColorType:=TPixelColorType.GrayAlpha16;
            ByteWidth:=4;
           end;
          end;
          6:begin
           if BitDepth=8 then begin
            PixelColorType:=TPixelColorType.ColorAlpha8;
            ByteWidth:=4;
           end else begin
            PixelColorType:=TPixelColorType.ColorAlpha16;
            ByteWidth:=8;
           end;
          end;
         end;
         case BitDepth of
          1:begin
           CountBitsUsed:=8;
           BitShift:=1;
           BitsUsed:=BitsUsed1Depth;
          end;
          2:begin
           CountBitsUsed:=4;
           BitShift:=2;
           BitsUsed:=BitsUsed2Depth;
          end;
          4:begin
           CountBitsUsed:=2;
           BitShift:=4;
           BitsUsed:=BitsUsed4Depth;
          end;
          8:begin
           CountBitsUsed:=1;
           BitShift:=0;
           BitsUsed[0]:=$ff;
          end;
         end;
         DecompressPtr:=idataexpanded;
         ml:=16;
         try
          GetMem(PreviousLine,16);
          GetMem(CurrentLine,16);
          for i:=StartPass to EndPass do begin
           StartX:=StartPoints[i,0];
           StartY:=StartPoints[i,1];
           DeltaX:=Delta[i,0];
           DeltaY:=Delta[i,1];
           if ByteWidth=1 then begin
            l:=ScanLineLength[i] div CountBitsUsed;
            if (ScanLineLength[i] mod CountBitsUsed)>0 then begin
             inc(l);
            end;
           end else begin
            l:=ScanLineLength[i]*TpvUInt32(ByteWidth);
           end;
           if ml=0 then begin
            GetMem(PreviousLine,l);
            GetMem(CurrentLine,l);
           end else if ml<l then begin
            ReallocMem(PreviousLine,l);
            ReallocMem(CurrentLine,l);
           end;
           ml:=l;
           FillChar(CurrentLine^,l,TpvRawByteChar(#0));
           for ry:=0 to CountScanlines[i]-1 do begin
            SwitchLine:=CurrentLine;
            CurrentLine:=PreviousLine;
            PreviousLine:=SwitchLine;
            y:=StartY+(ry*DeltaY);
            LineFilter:=GetU8(DecompressPtr);
            Move(DecompressPtr^,CurrentLine^,l);
            inc(PpvRawByteChar(DecompressPtr),l);
            case LineFilter of
             1:begin // Sub
              for rx:=0 to l-1 do begin
               if rx<ByteWidth then begin
                CurrentLine^[rx]:=CurrentLine^[rx] and $ff;
               end else begin
                CurrentLine^[rx]:=(CurrentLine^[rx]+CurrentLine^[rx-ByteWidth]) and $ff;
               end;
              end;
             end;
             2:begin // Up
              for rx:=0 to l-1 do begin
               CurrentLine^[rx]:=(CurrentLine^[rx]+PreviousLine^[rx]) and $ff;
              end;
             end;
             3:begin // Average
              for rx:=0 to l-1 do begin
               if rx<ByteWidth then begin
                CurrentLine^[rx]:=(CurrentLine^[rx]+(PreviousLine^[rx] div 2)) and $ff;
               end else begin
                CurrentLine^[rx]:=(CurrentLine^[rx]+((CurrentLine^[rx-ByteWidth]+PreviousLine^[rx]) div 2)) and $ff;
               end;
              end;
             end;
             4:begin // Paeth
              for rx:=0 to l-1 do begin
               if rx<ByteWidth then begin
                CurrentLine^[rx]:=(CurrentLine^[rx]+Paeth(0,PreviousLine^[rx],0)) and $ff;
               end else begin
                CurrentLine^[rx]:=(CurrentLine^[rx]+Paeth(CurrentLine^[rx-ByteWidth],PreviousLine^[rx],PreviousLine^[rx-ByteWidth])) and $ff;
               end;
              end;
             end;
            end;
            HandleScanLine(y,i,CurrentLine);
           end;
          end;
         finally
          FreeMem(PreviousLine);
          FreeMem(CurrentLine);
         end;
         if CgBI then begin
          CgBISwapBGR2RGBandUnpremultiply;
         end;
        finally
        end;
        result:=true;
        break;
       end;
       else begin
       end;
      end;
      DataPtr:=DataNextChunk;
     end;
    end;
   except
    on e:EpvLoadPNGImage do begin
     result:=false;
    end;
    on e:Exception do begin
     raise;
    end;
   end;
  finally
   SetLength(Palette,0);
   SetLength(TransparentColor,0);
   if assigned(idata) then begin
    FreeMem(idata);
    idata:=nil;
   end;
   if assigned(idataexpanded) then begin
    FreeMem(idataexpanded);
    idataexpanded:=nil;
   end;
  end;
 except
  if assigned(ImageData) then begin
   FreeMem(ImageData);
   ImageData:=nil;
  end;
  result:=false;
 end;
end;
{$ifend}

function SavePNGImage(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;out aDestData:TpvPointer;out aDestDataSize:TpvUInt32;const aImagePixelFormat:TpvPNGPixelFormat=TpvPNGPixelFormat.R8G8B8A8;const aFast:boolean=false):boolean;
type PPNGHeader=^TPNGHeader;
     TPNGHeader=packed record
      PNGSignature:array[0..7] of TpvUInt8;
      IHDRChunkSize:array[0..3] of TpvUInt8;
      IHDRChunkSignature:array[0..3] of TpvUInt8;
      IHDRChunkWidth:array[0..3] of TpvUInt8;
      IHDRChunkHeight:array[0..3] of TpvUInt8;
      IHDRChunkBitDepth:TpvUInt8;
      IHDRChunkColorType:TpvUInt8;
      IHDRChunkCompressionMethod:TpvUInt8;
      IHDRChunkFilterMethod:TpvUInt8;
      IHDRChunkInterlaceMethod:TpvUInt8;
      IHDRChunkCRC32Checksum:array[0..3] of TpvUInt8;
      sRGBChunkSize:array[0..3] of TpvUInt8;
      sRGBChunkSignature:array[0..3] of TpvUInt8;
      sRGBChunkData:TpvUInt8;
      sRGBChunkCRC32Checksum:array[0..3] of TpvUInt8;
      gAMAChunkSize:array[0..3] of TpvUInt8;
      gAMAChunkSignature:array[0..3] of TpvUInt8;
      gAMAChunkData:array[0..3] of TpvUInt8;
      gAMAChunkCRC32Checksum:array[0..3] of TpvUInt8;
      IDATChunkSize:array[0..3] of TpvUInt8;
      IDATChunkSignature:array[0..3] of TpvUInt8;
     end;
     PPNGFooter=^TPNGFooter;
     TPNGFooter=packed record
      IDATChunkCRC32Checksum:array[0..3] of TpvUInt8;
      IENDChunkSize:array[0..3] of TpvUInt8;
      IENDChunkSignature:array[0..3] of TpvUInt8;
      IENDChunkCRC32Checksum:array[0..3] of TpvUInt8;
     end;
     PBytes=^TBytes;
     TBytes=array[0..$7ffffffe] of TpvUInt8;
const PNGHeaderTemplate:TPNGHeader=
       (
        PNGSignature:($89,$50,$4e,$47,$0d,$0a,$1a,$0a);
        IHDRChunkSize:($00,$00,$00,$0d);
        IHDRChunkSignature:($49,$48,$44,$52);
        IHDRChunkWidth:($00,$00,$00,$00);
        IHDRChunkHeight:($00,$00,$00,$00);
        IHDRChunkBitDepth:$08;
        IHDRChunkColorType:$06; // RGBA
        IHDRChunkCompressionMethod:$00;
        IHDRChunkFilterMethod:$00;
        IHDRChunkInterlaceMethod:$00;
        IHDRChunkCRC32Checksum:($00,$00,$00,$00);
        sRGBChunkSize:($00,$00,$00,$01);
        sRGBChunkSignature:($73,$52,$47,$42);
        sRGBChunkData:$00;
        sRGBChunkCRC32Checksum:($ae,$ce,$1c,$e9);
        gAMAChunkSize:($00,$00,$00,$04);
        gAMAChunkSignature:($67,$41,$4d,$41);
        gAMAChunkData:($00,$00,$b1,$8f);
        gAMAChunkCRC32Checksum:($0b,$fc,$61,$05);
        IDATChunkSize:($00,$00,$00,$00);
        IDATChunkSignature:($49,$44,$41,$54);
       );
      PNGFooterTemplate:TPNGFooter=
       (
        IDATChunkCRC32Checksum:($00,$00,$00,$00);
        IENDChunkSize:($00,$00,$00,$00);
        IENDChunkSignature:($49,$45,$4e,$44);
        IENDChunkCRC32Checksum:($ae,$42,$60,$82);
       );
 function Paeth(a,b,c:TpvInt32):TpvInt32;
 var p,pa,pb,pc:TpvInt32;
 begin
  p:=(a+b)-c;
  pa:=abs(p-a);
  pb:=abs(p-b);
  pc:=abs(p-c);
  if (pa<=pb) and (pa<=pc) then begin
   result:=a;
  end else if pb<=pc then begin
   result:=b;
  end else begin
   result:=c;
  end;
 end;
 procedure ProcessLineFilter(const aInput,aOutput:PBytes;const aRowSize,aByteWidth,aLineFilterIndex:TpvUInt32);
 var InByteIndex,OutByteIndex,Index:TpvUInt32;
 begin
  InByteIndex:=0;
  OutByteIndex:=0;
  aOutput^[OutByteIndex]:=aLineFilterIndex;
  inc(OutByteIndex);
  case aLineFilterIndex of
   1:begin
    // Sub
    for Index:=1 to aRowSize do begin
     if Index<=aByteWidth then begin
      aOutput^[OutByteIndex]:=aInput^[InByteIndex];
     end else begin
      aOutput^[OutByteIndex]:=aInput^[InByteIndex]-aInput^[InByteIndex-aByteWidth];
     end;
     inc(InByteIndex);
     inc(OutByteIndex);
    end;
   end;
   2:begin
    // Up
    for Index:=1 to aRowSize do begin
     aOutput^[OutByteIndex]:=aInput^[InByteIndex]-aInput^[TpvSizeInt(InByteIndex)-TpvSizeInt(aRowSize)];
     inc(InByteIndex);
     inc(OutByteIndex);
    end;
   end;
   3:begin
    // Average
    for Index:=1 to aRowSize do begin
     if Index<=aByteWidth then begin
      aOutput^[OutByteIndex]:=aInput^[InByteIndex]-(aInput^[TpvSizeInt(InByteIndex)-TpvSizeInt(aRowSize)] shr 1);
     end else begin
      aOutput^[OutByteIndex]:=aInput^[InByteIndex]-((aInput^[InByteIndex-aByteWidth]+aInput^[TpvSizeInt(InByteIndex)-TpvSizeInt(aRowSize)]) shr 1);
     end;
     inc(InByteIndex);
     inc(OutByteIndex);
    end;
   end;
   4:begin
    // Paeth
    for Index:=1 to aRowSize do begin
     if Index<=aByteWidth then begin
      aOutput^[OutByteIndex]:=aInput^[InByteIndex]-aInput^[TpvSizeInt(InByteIndex)-TpvSizeInt(aRowSize)];
     end else begin
      aOutput^[OutByteIndex]:=aInput^[InByteIndex]-Paeth(aInput^[InByteIndex-aByteWidth],aInput^[TpvSizeInt(InByteIndex)-TpvSizeInt(aRowSize)],aInput^[TpvSizeInt(InByteIndex)-TpvSizeInt(aRowSize+aByteWidth)]);
     end;
     inc(InByteIndex);
     inc(OutByteIndex);
    end;
   end;
   else begin
    // None
    Move(aInput^[InByteIndex],aOutput^[OutByteIndex],aRowSize);
   end;
  end;
 end;
{$if not defined(FPC_BIG_ENDIAN)}
 function SwapEndian(const ImageDataSize:TpvUInt32):pointer;
 var Counter:TpvSizeUInt;
     InPixel,OutPixel:PpvUInt16;
     Value:TpvUInt16;
 begin
  result:=nil;
  case aImagePixelFormat of
   TpvPNGPixelFormat.R16G16B16A16:begin
    GetMem(result,ImageDataSize);
    InPixel:=aImageData;
    OutPixel:=result;
    for Counter:=1 to aImageWidth*aImageHeight*4 do begin
     Value:=InPixel^;
{$ifdef fpc}
     OutPixel^:=RolWord(Value,8);
{$else}
     OutPixel^:=(Value shr 8) or (Value shl 8);
{$endif}
     inc(InPixel);
     inc(OutPixel);
    end;
   end;
   else begin
   end;
  end;
 end;
{$ifend}
var PNGHeader:PPNGHeader;
    PNGFooter:PPNGFooter;
    CRC32ChecksumValue,ImageDataSize,RowSize,LineIndex,Index,ByteWidth,
    InByteIndex,OutByteIndex,FakeEntropy,LineFilterIndex,BestFakeEntropy,BestLineFilterIndex:TpvUInt32;
    IDATDataSize:TpvSizeUInt;
    ImageData,IDATData{$if not defined(FPC_BIG_ENDIAN)},TemporaryImageData{$ifend}:TpvPointer;
begin
 result:=false;
 case aImagePixelFormat of
  TpvPNGPixelFormat.R8G8B8A8:begin
   ByteWidth:=4;
  end;
  TpvPNGPixelFormat.R16G16B16A16:begin
   ByteWidth:=8;
  end;
  else begin
   Assert(false);
   ByteWidth:=0;
  end;
 end;
 RowSize:=aImageWidth*ByteWidth;
 ImageDataSize:=(RowSize+1)*aImageHeight;
{$if not defined(FPC_BIG_ENDIAN)}
 TemporaryImageData:=SwapEndian(ImageDataSize);
 try
{$ifend}
  GetMem(ImageData,ImageDataSize);
  try
   InByteIndex:=0;
   OutByteIndex:=0;
   for LineIndex:=1 to aImageHeight do begin
    BestFakeEntropy:=$ffffffff;
    BestLineFilterIndex:=0;
    if not aFast then begin
     for LineFilterIndex:=0 to 4 do begin
      if (LineIndex>1) or (LineFilterIndex in [0,1]) then begin
       if assigned(TemporaryImageData) then begin
        ProcessLineFilter(@PBytes(TemporaryImageData)^[InByteIndex],@PBytes(ImageData)^[OutByteIndex],RowSize,ByteWidth,LineFilterIndex);
       end else begin
        ProcessLineFilter(@PBytes(aImageData)^[InByteIndex],@PBytes(ImageData)^[OutByteIndex],RowSize,ByteWidth,LineFilterIndex);
       end;
       FakeEntropy:=0;
       for Index:=0 to RowSize do begin
        inc(FakeEntropy,PBytes(ImageData)^[OutByteIndex+Index]);
       end;
       if BestFakeEntropy>FakeEntropy then begin
        BestFakeEntropy:=FakeEntropy;
        BestLineFilterIndex:=LineFilterIndex;
       end;
      end else begin
       break;
      end;
     end;
    end;
    if assigned(TemporaryImageData) then begin
     ProcessLineFilter(@PBytes(TemporaryImageData)^[InByteIndex],@PBytes(ImageData)^[OutByteIndex],RowSize,ByteWidth,BestLineFilterIndex);
    end else begin
     ProcessLineFilter(@PBytes(aImageData)^[InByteIndex],@PBytes(ImageData)^[OutByteIndex],RowSize,ByteWidth,BestLineFilterIndex);
    end;
    inc(InByteIndex,RowSize);
    inc(OutByteIndex,RowSize+1);
   end;
   if aFast then begin
    DoDeflate(ImageData,ImageDataSize,IDATData,IDATDataSize,TpvDeflateMode.VeryFast,true);
   end else begin
    DoDeflate(ImageData,ImageDataSize,IDATData,IDATDataSize,TpvDeflateMode.Medium,true);
   end;
   if assigned(IDATData) then begin
    try
     if assigned(ImageData) then begin
      FreeMem(ImageData);
      ImageData:=nil;
     end;
     aDestDataSize:=TpvUInt32(TpvUInt32(SizeOf(TPNGHeader)+SizeOf(TPNGFooter))+IDATDataSize);
     GetMem(aDestData,aDestDataSize);
     PNGHeader:=TpvPointer(@PBytes(aDestData)^[0]);
     PNGHeader^:=PNGHeaderTemplate;
     case aImagePixelFormat of
      TpvPNGPixelFormat.R8G8B8A8:begin
       PNGHeader^.IHDRChunkBitDepth:=$08;
      end;
      TpvPNGPixelFormat.R16G16B16A16:begin
       PNGHeader^.IHDRChunkBitDepth:=$10;
      end;
      else begin
       Assert(false);
      end;
     end;
     PNGHeader^.IHDRChunkWidth[0]:=(aImageWidth shr 24) and $ff;
     PNGHeader^.IHDRChunkWidth[1]:=(aImageWidth shr 16) and $ff;
     PNGHeader^.IHDRChunkWidth[2]:=(aImageWidth shr 8) and $ff;
     PNGHeader^.IHDRChunkWidth[3]:=(aImageWidth shr 0) and $ff;
     PNGHeader^.IHDRChunkHeight[0]:=(aImageHeight shr 24) and $ff;
     PNGHeader^.IHDRChunkHeight[1]:=(aImageHeight shr 16) and $ff;
     PNGHeader^.IHDRChunkHeight[2]:=(aImageHeight shr 8) and $ff;
     PNGHeader^.IHDRChunkHeight[3]:=(aImageHeight shr 0) and $ff;
     CRC32ChecksumValue:=CRC32(@PNGHeader^.IHDRChunkSignature,{%H-}TpvPtrUInt(TpvPointer(@PPNGHeader(nil)^.IHDRChunkCRC32Checksum))-{%H-}TpvPtrUInt(TpvPointer(@PPNGHeader(nil)^.IHDRChunkSignature)));
     PNGHeader^.IHDRChunkCRC32Checksum[0]:=(CRC32ChecksumValue shr 24) and $ff;
     PNGHeader^.IHDRChunkCRC32Checksum[1]:=(CRC32ChecksumValue shr 16) and $ff;
     PNGHeader^.IHDRChunkCRC32Checksum[2]:=(CRC32ChecksumValue shr 8) and $ff;
     PNGHeader^.IHDRChunkCRC32Checksum[3]:=(CRC32ChecksumValue shr 0) and $ff;
     PNGHeader^.IDATChunkSize[0]:=(IDATDataSize shr 24) and $ff;
     PNGHeader^.IDATChunkSize[1]:=(IDATDataSize shr 16) and $ff;
     PNGHeader^.IDATChunkSize[2]:=(IDATDataSize shr 8) and $ff;
     PNGHeader^.IDATChunkSize[3]:=(IDATDataSize shr 0) and $ff;
     Move(IDATData^,PBytes(aDestData)^[SizeOf(TPNGHeader)],IDATDataSize);
     PNGFooter:=TpvPointer(@PBytes(aDestData)^[TpvUInt32(SizeOf(TPNGHeader))+IDATDataSize]);
     PNGFooter^:=PNGFooterTemplate;
     CRC32ChecksumValue:=CRC32(@PNGHeader^.IDATChunkSignature,IDATDataSize+SizeOf(PPNGHeader(nil)^.IDATChunkSignature));
     PNGFooter.IDATChunkCRC32Checksum[0]:=(CRC32ChecksumValue shr 24) and $ff;
     PNGFooter.IDATChunkCRC32Checksum[1]:=(CRC32ChecksumValue shr 16) and $ff;
     PNGFooter.IDATChunkCRC32Checksum[2]:=(CRC32ChecksumValue shr 8) and $ff;
     PNGFooter.IDATChunkCRC32Checksum[3]:=(CRC32ChecksumValue shr 0) and $ff;
     result:=true;
    finally
     FreeMem(IDATData);
    end;
   end;
  finally
   if assigned(ImageData) then begin
    FreeMem(ImageData);
   end;
  end;
{$if not defined(FPC_BIG_ENDIAN)}
 finally
  if assigned(TemporaryImageData) then begin
   FreeMem(TemporaryImageData);
  end;
 end;
{$ifend}
end;

function SavePNGImageAsStream(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aStream:TStream;const aImagePixelFormat:TpvPNGPixelFormat=TpvPNGPixelFormat.R8G8B8A8;const aFast:boolean=false):boolean;
var Data:TpvPointer;
    DataSize:TpvUInt32;
begin
 result:=SavePNGImage(aImageData,aImageWidth,aImageHeight,Data,DataSize,aImagePixelFormat,aFast);
 if assigned(Data) then begin
  try
   aStream.Write(Data^,DataSize);
  finally
   FreeMem(Data);
  end;
 end;
end;

function SavePNGImageAsFile(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aFileName:string;const aImagePixelFormat:TpvPNGPixelFormat=TpvPNGPixelFormat.R8G8B8A8;const aFast:boolean=false):boolean;
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  result:=SavePNGImageAsStream(aImageData,aImageWidth,aImageHeight,FileStream,aImagePixelFormat,aFast);
 finally
  FileStream.Free;
 end;
end;

end.
