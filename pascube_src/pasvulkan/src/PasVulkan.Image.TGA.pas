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
unit PasVulkan.Image.TGA;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PasVulkan.Types;

function LoadTGAImage(DataPointer:TpvPointer;DataSize:TpvUInt32;var ImageData:TpvPointer;var ImageWidth,ImageHeight:TpvInt32;const HeaderOnly:boolean):boolean;

implementation

uses PasVulkan.Streams;

function LoadTGAImage(DataPointer:TpvPointer;DataSize:TpvUInt32;var ImageData:TpvPointer;var ImageWidth,ImageHeight:TpvInt32;const HeaderOnly:boolean):boolean;
type PLongwords=^TLongwords;
     TLongwords=array[0..65536] of TpvUInt32;
     TTGAHeader=packed record
      ImageID:TpvUInt8;
      ColorMapType:TpvUInt8;
      ImageType:TpvUInt8;
      CMapSpec:packed record
       FirstEntryIndex:TpvUInt16;
       Length:TpvUInt16;
       EntrySize:TpvUInt8;
      end;
      OrigX:array[0..1] of TpvUInt8;
      OrigY:array[0..1] of TpvUInt8;
      Width:array[0..1] of TpvUInt8;
      Height:array[0..1] of TpvUInt8;
      BPP:TpvUInt8;
      ImageInfo:TpvUInt8;
     end;
     TBGR=packed record
      b,g,r:TpvUInt8;
     end;
     TBGRA=packed record
      b,g,r,a:TpvUInt8;
     end;
     TRGBA=packed record
      r,g,b,a:TpvUInt8;
     end;
var TGAHeader:TTGAHeader;
    ImageSize,Width,Height:TpvUInt32;
    ImagePointer,NewImagePointer,Pixel:PpvUInt32;
    B8:TpvUInt8;
    Palette:array of TpvUInt8;
    Stream:TpvDataStream;
 function PaletteEncode(Index:TpvUInt32):TpvUInt32;
 var r:TRGBA;
     l:TpvUInt32 ABSOLUTE r;
     Offset:TpvUInt32;
     w:TpvUInt16;
 begin
  l:=0;
  if (B8+TGAHeader.CMapSpec.FirstEntryIndex)<TGAHeader.CMapSpec.Length then begin
   Offset:=Index*(TGAHeader.CMapSpec.EntrySize div 8);
   case TGAHeader.CMapSpec.EntrySize of
    8:begin
     l:=Palette[Offset];
    end;
    16:begin
     w:=Palette[Offset] or (Palette[Offset+1] shl 8);
     l:=(((w and $8000) shl 16) or ((w and $7C00) shl 9) or ((w and $3e0) shl 6) or ((w and $1f) shl 3)) or $0f0f0f0f;
    end;
    24:begin
     r.r:=Palette[Offset+2];
     r.g:=Palette[Offset+1];
     r.b:=Palette[Offset];
     if TGAHeader.ImageType=3 then begin
      r.a:=(r.r+r.g+r.b) div 3;
     end else begin
      r.a:=255;
     end;
    end;
    32:begin
     r.r:=Palette[Offset+3];
     r.g:=Palette[Offset+2];
     r.b:=Palette[Offset+1];
     r.a:=Palette[Offset];
    end;
   end;
  end;
  result:=(r.a shl 24) or (r.b shl 16) or (r.g shl 8) or r.r;
 end;
 procedure FlipAndCorrectImage;
 var x,y,o:TpvUInt32;
     Line,NewLine:PLongwords;
 begin
  if (Width<>0) and (Height<>0) then begin
   if (TGAHeader.ImageInfo and $10)<>0 then begin
    GetMem(NewImagePointer,ImageSize);
    for y:=0 to Height-1 do begin
     o:=y*Width*SizeOf(TpvUInt32);
     Line:=PLongwords(TpvPointer(@PpvRawByteChar(TpvPointer(ImagePointer))[o]));
     NewLine:=PLongwords(TpvPointer(@PpvRawByteChar(TpvPointer(NewImagePointer))[o]));
     for x:=0 to Width-1 do begin
      NewLine^[Width-(x+1)]:=Line^[x];
     end;
    end;
    FreeMem(ImagePointer);
    ImagePointer:=NewImagePointer;
   end;
   if (TGAHeader.ImageInfo and $20)=0 then begin
    GetMem(NewImagePointer,ImageSize);
    for y:=0 to Height-1 do begin
     Move(TpvPointer(@PpvRawByteChar(TpvPointer(ImagePointer))[y*Width*SizeOf(TpvUInt32)])^,
          TpvPointer(@PpvRawByteChar(TpvPointer(NewImagePointer))[(Height-(y+1))*Width*SizeOf(TpvUInt32)])^,
          Width*SizeOf(TpvUInt32));
    end;
    FreeMem(ImagePointer);
    ImagePointer:=NewImagePointer;
   end;
  end;
 end;
 function DoIt:boolean;
 var PixelCounter,i,l,j:TpvUInt32;
     BGR:TBGR;
     BGRA:TBGRA;
     b,B1:TpvUInt8;
     w:TpvUInt16;
     HasPalette:BOOLEAN;
 begin
  result:=false;
  if Stream.Read(TGAHeader,SizeOf(TGAHeader))<>SizeOf(TGAHeader) then begin
   exit;
  end;
  if (not (TGAHeader.ColorMapType in [0,1])) or (not (TGAHeader.ImageType in [1,2,3,9,10,11])) then begin
   exit;
  end;
  Stream.Seek(TGAHeader.ImageID,soCurrent);
  Palette:=nil;
  HasPalette:=TGAHeader.ColorMapType=1;
  if HasPalette then begin
   SetLength(Palette,TGAHeader.CMapSpec.Length*TGAHeader.CMapSpec.EntrySize div 8);
   if Stream.Read(Palette[0],length(Palette))<>length(Palette) then begin
    exit;
   end;
  end;
  if HasPalette and not (TGAHeader.CMapSpec.EntrySize in [8,16,24,32]) then begin
   SetLength(Palette,0);
   result:=false;
   exit;
  end;
  Width:=(TGAHeader.Width[1] shl 8) or TGAHeader.Width[0];
  Height:=(TGAHeader.Height[1] shl 8) or TGAHeader.Height[0];
  if HeaderOnly then begin
   result:=true;
   exit;
  end;
  if TGAHeader.ImageType in [1,2,3] then begin
   ImageSize:=(Width*Height)*SizeOf(TBGRA);
   GetMem(ImagePointer,ImageSize);
   Pixel:=ImagePointer;
   if TGAHeader.BPP=8 then begin
    if (Width*Height)>0 then begin
     case TGAHeader.ImageType of
      1:begin
       for i:=0 to (Width*Height)-1 do begin
        Stream.Read(B8,SizeOf(TpvUInt8));
        Pixel^:=PaletteEncode(B8);
        inc(Pixel);
       end;
      end;
      2:begin
       for i:=0 to (Width*Height)-1 do begin
        Stream.Read(B8,SizeOf(TpvUInt8));
        Pixel^:=B8;
        inc(Pixel);
       end;
      end;
      3:begin
       for i:=0 to (Width*Height)-1 do begin
        Stream.Read(B8,SizeOf(TpvUInt8));
        Pixel^:=(B8 shl 24) or (B8 shl 16) or (B8 shl 8) or B8;
        inc(Pixel);
       end;
      end;
     end;
    end;
   end else if TGAHeader.BPP=16 then begin
    if (Width*Height)>0 then begin
     for i:=0 to (Width*Height)-1 do begin
      Stream.Read(w,SizeOf(TpvUInt16));
      Pixel^:=(((w and $8000) shl 16) or ((w and $7C00) shl 9) or ((w and $3E0) shl 6) or ((w and $1F) shl 3)) or $0F0F0F0F;
      inc(Pixel);
     end;
    end;
   end else if TGAHeader.BPP=24 then begin
    if (Width*Height)>0 then begin
     for i:=0 to (Width*Height)-1 do begin
      Stream.Read(BGR,SizeOf(TBGR));
      if TGAHeader.ImageType=3 then begin
       Pixel^:=(((BGR.r+BGR.g+BGR.b) div 3)  shl 24) or (BGR.b shl 16) or (BGR.g shl 8) or BGR.r;
      end else begin
       Pixel^:=(255 shl 24) or (BGR.b shl 16) or (BGR.g shl 8) or BGR.r;
      end;
      inc(Pixel);
     end;
    end;
   end else if TGAHeader.BPP=32 then begin
    if (Width*Height)>0 then begin
     for i:=0 to (Width*Height)-1 do begin
      Stream.Read(BGRA,SizeOf(TBGRA));
      Pixel^:=(BGRA.a shl 24) or (BGRA.b shl 16) or (BGRA.g shl 8) or BGRA.r;
      inc(Pixel);
     end;
    end;
   end;
   FlipAndCorrectImage;
  end else if TGAHeader.ImageType in [9,10,11] then begin
   ImageSize:=(Width*Height)*SizeOf(TBGRA);
   GetMem(ImagePointer,ImageSize);
   Pixel:=ImagePointer;
   PixelCounter:=0;
   j:=Width*Height;
   if TGAHeader.BPP=8 then begin
    while PixelCounter<j do begin
     Stream.Read(B1,SizeOf(TpvUInt8));
     b:=(B1 and $7f)+1;
     if (B1 and $80)<>0 then begin
      Stream.Read(B8,SizeOf(TpvUInt8));
      case TGAHeader.ImageType of
       9:begin
        l:=PaletteEncode(B8);
       end;
       10:begin
        l:=B8;
       end;
       11:begin
        BGR.b:=B8;
        BGR.g:=B8;
        BGR.r:=B8;
        l:=(255 shl 24) or (BGR.b shl 16) or (BGR.g shl 8) or BGR.r;
       end;
       else begin
        l:=0;
       end;
      end;
      i:=0;
      while i<b do begin
       Pixel^:=l;
       inc(Pixel);
       inc(PixelCounter);
       inc(i);
      end;
     end else begin
      i:=0;
      while i<b do begin
       Stream.Read(B8,SizeOf(TpvUInt8));
       case TGAHeader.ImageType of
        9:begin
         l:=PaletteEncode(B8);
        end;
        10:begin
         l:=B8;
        end;
        11:begin
         BGR.b:=B8;
         BGR.g:=B8;
         BGR.r:=B8;
         l:=(255 shl 24) or (BGR.b shl 16) or (BGR.g shl 8) or BGR.r;
        end;
        else begin
         l:=0;
        end;
       end;
       Pixel^:=l;
       inc(Pixel);
       inc(PixelCounter);
       inc(i);
      end;
     end;
    end;
   end else if TGAHeader.BPP=16 then begin
    while PixelCounter<j do begin
     Stream.Read(B1,SizeOf(TpvUInt8));
     b:=(B1 and $7f)+1;
     if (B1 and $80)<>0 then begin
      Stream.Read(w,SizeOf(TpvUInt16));
      l:=(((w and $8000) shl 16) or ((w and $7C00) shl 9) or ((w and $3E0) shl 6) or ((w and $1F) shl 3)) or $0F0F0F0F;
      i:=0;
      while i<b do begin
       Pixel^:=l;
       inc(Pixel);
       inc(PixelCounter);
       inc(i);
      end;
     end else begin
      i:=0;
      while i<b do begin
       Stream.Read(w,SizeOf(TpvUInt16));
       Pixel^:=(((w and $8000) shl 16) or ((w and $7C00) shl 9) or ((w and $3E0) shl 6) or ((w and $1F) shl 3)) or $0F0F0F0F;
       inc(Pixel);
       inc(PixelCounter);
       inc(i);
      end;
     end;
    end;
   end else if TGAHeader.BPP=24 then begin
    while PixelCounter<j do begin
     Stream.Read(B1,SizeOf(TpvUInt8));
     b:=(B1 and $7f)+1;
     if (B1 and $80)<>0 then begin
      Stream.Read(BGR,SizeOf(TBGR));
      l:=(255 shl 24) or (BGR.b shl 16) or (BGR.g shl 8) or BGR.r;;
      i:=0;
      while i<b do begin
       Pixel^:=l;
       inc(Pixel);
       inc(PixelCounter);
       inc(i);
      end;
     end else begin
      i:=0;
      while i<b do begin
       Stream.Read(BGR,SizeOf(TBGR));
       Pixel^:=(255 shl 24) or (BGR.b shl 16) or (BGR.g shl 8) or BGR.r;;
       inc(Pixel);
       inc(PixelCounter);
       inc(i);
      end;
     end;
    end;
   end else if TGAHeader.BPP=32 then begin
    while PixelCounter<j do begin
     Stream.Read(B1,SizeOf(TpvUInt8));
     b:=(B1 and $7f)+1;
     if (B1 and $80)<>0 then begin
      Stream.Read(BGRA,SizeOf(TBGRA));
      l:=(BGRA.a shl 24) or (BGRA.b shl 16) or (BGRA.g shl 8) or BGRA.r;
      i:=0;
      while i<b do begin
       Pixel^:=l;
       inc(Pixel);
       inc(PixelCounter);
       inc(i);
      end;
     end else begin
      i:=0;
      while i<b do begin
       Stream.Read(BGRA,SizeOf(TBGRA));
       Pixel^:=(BGRA.a shl 24) or (BGRA.b shl 16) or (BGRA.g shl 8) or BGRA.r;
       inc(Pixel);
       inc(PixelCounter);
       inc(i);
      end;
     end;
    end;
   end;
   FlipAndCorrectImage;
  end;
  SetLength(Palette,0);
  ImageData:=ImagePointer;
  ImageWidth:=Width;
  ImageHeight:=Height;
  result:=true;
 end;
begin
 result:=false;
 if DataSize>0 then begin
  Stream:=TpvDataStream.Create(DataPointer,DataSize);
  try
   result:=DoIt;
  finally
   Stream.Free;
  end;
 end;
end;

end.
