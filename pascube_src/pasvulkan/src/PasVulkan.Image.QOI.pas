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
unit PasVulkan.Image.QOI;
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
     PasVulkan.Types,
     PasVulkan.Compression.Deflate;

type EpvLoadOOIImage=class(Exception);

     TpvQOIMagic=array[0..3] of AnsiChar;
     PpvQOIMagic=^TpvQOIMagic;

const pvQOIMagic:TpvQOIMagic=('q','o','i','f');

function LoadQOIImage(aDataPointer:TpvPointer;aDataSize:TpvUInt32;var aImageData:TpvPointer;var aImageWidth,aImageHeight:TpvInt32;const aHeaderOnly:boolean;out aSRGB:boolean):boolean;

function SaveQOIImage(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;out aDestData:TpvPointer;out aDestDataSize:TpvUInt32;const aSRGB:boolean=true):boolean;

function SaveQOIImageAsStream(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aStream:TStream;const aSRGB:boolean=true):boolean;

function SaveQOIImageAsFile(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aFileName:string;const aSRGB:boolean=true):boolean;

implementation

const QOI_MAGIC=TpvUInt32((TpvUInt32(TpvUInt8(AnsiChar('q'))) shl 24) or
                          (TpvUInt32(TpvUInt8(AnsiChar('o'))) shl 16) or
                          (TpvUInt32(TpvUInt8(AnsiChar('i'))) shl 8) or
                          (TpvUInt32(TpvUInt8(AnsiChar('f'))) shl 0));

      QOI_OP_INDEX=$00; // 00xxxxxx
      QOI_OP_DIFF=$40;  // 01xxxxxx
      QOI_OP_LUMA=$80;  // 10xxxxxx
      QOI_OP_RUN=$c0;   // 11xxxxxx
      QOI_OP_RGB=$fe;   // 11111110
      QOI_OP_RGBA=$ff;  // 11111111
      QOI_MASK_2=$c0;   // 11000000

      QOI_SRGB=0;
      QOI_LINEAR=1;

      QOI_HEADER_SIZE=14;

      QOI_PIXELS_MAX=TpvUInt32(400000000);

type TQOIDesc=record
      Width:TpvUInt32;
      Height:TpvUInt32;
      Channels:TpvUInt8;
      ColorSpace:TpvUInt8;
     end;
     PQOIDesc=^TQOIDesc;

     TQOIRGBA=packed record
      case boolean of
       false:(
        r:TpvUInt8;
        g:TpvUInt8;
        b:TpvUInt8;
        a:TpvUInt8;
       );
       true:(
        v:TpvUInt32;
       );
     end;
     PQOIRGBA=^TQOIRGBA;

const QOIPadding:array[0..7] of TpvUInt8=(0,0,0,0,0,0,0,1);

function QOIColorHash(const aColor:TQOIRGBA):TpvUInt32; inline;
begin
 result:=(aColor.r*3)+(aColor.g*5)+(aColor.b*7)++(aColor.a*11);
end;

function QOIRead8(const aBytes:PpvUInt8Array;var aPosition:TpvUInt32):TpvUInt32; inline;
begin
 result:=TpvUInt32(aBytes^[aPosition]);
 inc(aPosition);
end;

function QOIRead32(const aBytes:PpvUInt8Array;var aPosition:TpvUInt32):TpvUInt32; inline;
begin
 result:=(TpvUInt32(aBytes^[aPosition]) shl 24) or (TpvUInt32(aBytes^[aPosition+1]) shl 16) or (TpvUInt32(aBytes^[aPosition+2]) shl 8) or (TpvUInt32(aBytes^[aPosition+3]) shl 0);
 inc(aPosition,4);
end;

procedure QOIWrite8(const aBytes:PpvUInt8Array;var aPosition:TpvUInt32;const aValue:TpvUInt32); inline;
begin
 aBytes^[aPosition]:=aValue and $ff;
 inc(aPosition);
end;

procedure QOIWrite32(const aBytes:PpvUInt8Array;var aPosition:TpvUInt32;const aValue:TpvUInt32); inline;
begin
 aBytes^[aPosition+0]:=(aValue shr 24) and $ff;
 aBytes^[aPosition+1]:=(aValue shr 16) and $ff;
 aBytes^[aPosition+2]:=(aValue shr 8) and $ff;
 aBytes^[aPosition+3]:=(aValue shr 0) and $ff;
 inc(aPosition,4);
end;

function LoadQOIImage(aDataPointer:TpvPointer;aDataSize:TpvUInt32;var aImageData:TpvPointer;var aImageWidth,aImageHeight:TpvInt32;const aHeaderOnly:boolean;out aSRGB:boolean):boolean;
var DataPosition,HeaderMagic,PixelSize,PixelPosition,Run,ChunksLen,
    b1,b2:TpvUInt32;
    vg:TpvInt32;
    DataPointer:PpvUInt8Array;
    Desc:TQOIDesc;
    Pixel:TQOIRGBA;
    IndexPixels:array[0..63] of TQOIRGBA;
begin

 if aDataSize>=(QOI_HEADER_SIZE+SizeOf(QOIPadding)) then begin

  DataPointer:=aDataPointer;
  DataPosition:=0;

  HeaderMagic:=QOIRead32(DataPointer,DataPosition);
  Desc.Width:=QOIRead32(DataPointer,DataPosition);
  Desc.Height:=QOIRead32(DataPointer,DataPosition);
  Desc.Channels:=QOIRead8(DataPointer,DataPosition);
  Desc.ColorSpace:=QOIRead8(DataPointer,DataPosition);

  if (HeaderMagic=QOI_MAGIC) and
     (Desc.Width>0) and
     (Desc.Height>0) and
     (Desc.Channels in [3,4]) and
     (Desc.ColorSpace in [0,1]) and
     ((TpvUInt64(Desc.Width)*Desc.Height)<=QOI_PIXELS_MAX) then begin

   aImageWidth:=Desc.Width;
   aImageHeight:=Desc.Height;
   aSRGB:=Desc.ColorSpace=QOI_SRGB;

   if aHeaderOnly then begin
    result:=true;
    exit;
   end;

   PixelSize:=aImageWidth*aImageHeight*4;

   GetMem(aImageData,PixelSize);
   FillChar(aImageData^,PixelSize,#0);

   FillChar(IndexPixels,SizeOf(IndexPixels),#0);

   Pixel.r:=0;
   Pixel.g:=0;
   Pixel.b:=0;
   Pixel.a:=255;

   ChunksLen:=aDataSize-SizeOf(QOIPadding);

   Run:=0;

   PixelPosition:=0;
   while PixelPosition<PixelSize do begin

    if Run>0 then begin
     dec(Run);
    end else if DataPosition<ChunksLen then begin
     b1:=QOIRead8(DataPointer,DataPosition);
     case b1 of
      QOI_OP_RGB:begin
       Pixel.r:=QOIRead8(DataPointer,DataPosition);
       Pixel.g:=QOIRead8(DataPointer,DataPosition);
       Pixel.b:=QOIRead8(DataPointer,DataPosition);
      end;
      QOI_OP_RGBA:begin
       Pixel.r:=QOIRead8(DataPointer,DataPosition);
       Pixel.g:=QOIRead8(DataPointer,DataPosition);
       Pixel.b:=QOIRead8(DataPointer,DataPosition);
       Pixel.a:=QOIRead8(DataPointer,DataPosition);
      end;
      else begin
       case b1 and QOI_MASK_2 of
        QOI_OP_INDEX:begin
         Pixel:=IndexPixels[b1 and 63];
        end;
        QOI_OP_DIFF:begin
         Pixel.r:=Pixel.r+(((b1 shr 4) and 3)-2);
         Pixel.g:=Pixel.g+(((b1 shr 2) and 3)-2);
         Pixel.b:=Pixel.b+(((b1 shr 0) and 3)-2);
        end;
        QOI_OP_LUMA:begin
         b2:=QOIRead8(DataPointer,DataPosition);
         vg:=(b1 and 63)-32;
         Pixel.r:=Pixel.r+((vg-8)+((b2 shr 4) and 15));
         Pixel.g:=Pixel.g+vg;
         Pixel.b:=Pixel.b+((vg-8)+((b2 shr 0) and 15));
        end;
        else {QOI_OP_RUN:}begin
         Run:=b1 and 63;
        end;
       end;
      end;
     end;
     IndexPixels[QOIColorHash(Pixel) and 63]:=Pixel;
    end;
    PQOIRGBA(Pointer(@PpvUInt8Array(aImageData)^[PixelPosition]))^:=Pixel;
    inc(PixelPosition,4);
   end;

   result:=true;
   exit;

  end;

  result:=false;

 end;

end;

function SaveQOIImage(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;out aDestData:TpvPointer;out aDestDataSize:TpvUInt32;const aSRGB:boolean=true):boolean;
var DataPosition,HeaderMagic,PixelSize,PixelPosition,LastPixelPosition,
    IndexPosition,Run,ChunksLen,Size,b1,b2:TpvUInt32;
    vr,vg,vb,vgr,vgb:TpvInt32;
    DataPointer:PpvUInt8Array;
    Desc:TQOIDesc;
    PreviousPixel,Pixel:TQOIRGBA;
    IndexPixels:array[0..63] of TQOIRGBA;
begin

 Desc.Width:=aImageWidth;
 Desc.Height:=aImageHeight;
 Desc.Channels:=4;
 Desc.ColorSpace:=IfThen(aSRGB,QOI_SRGB,QOI_LINEAR);

 if (Desc.Width>0) and
    (Desc.Height>0) and
    (Desc.Channels in [3,4]) and
    (Desc.ColorSpace in [0,1]) and
    ((TpvUInt64(Desc.Width)*Desc.Height)<=QOI_PIXELS_MAX) then begin

  Size:=(QOI_HEADER_SIZE+SizeOf(QOIPadding))+(aImageWidth*aImageHeight*6);
  GetMem(aDestData,Size);
  try

   DataPointer:=aDestData;
   DataPosition:=0;

   QOIWrite32(DataPointer,DataPosition,QOI_MAGIC);
   QOIWrite32(DataPointer,DataPosition,Desc.Width);
   QOIWrite32(DataPointer,DataPosition,Desc.Height);
   QOIWrite8(DataPointer,DataPosition,Desc.Channels);
   QOIWrite8(DataPointer,DataPosition,Desc.ColorSpace);

   FillChar(IndexPixels,SizeOf(IndexPixels),#0);

   Pixel.r:=0;
   Pixel.g:=0;
   Pixel.b:=0;
   Pixel.a:=255;

   PreviousPixel:=Pixel;

   Run:=0;

   PixelSize:=aImageWidth*aImageHeight*4;

   PixelPosition:=0;
   LastPixelPosition:=PixelSize-4;
   while PixelPosition<PixelSize do begin
    Pixel:=PQOIRGBA(Pointer(@PpvUInt8Array(aImageData)^[PixelPosition]))^;
    inc(PixelPosition,4);
    if Pixel.v=PreviousPixel.v then begin
     inc(Run);
     if (Run=62) or (PixelPosition=LastPixelPosition) then begin
      QOIWrite8(DataPointer,DataPosition,QOI_OP_RUN or (Run-1));
      Run:=0;
     end;
    end else begin
     if Run>0 then begin
      QOIWrite8(DataPointer,DataPosition,QOI_OP_RUN or (Run-1));
      Run:=0;
     end;
     IndexPosition:=QOIColorHash(Pixel) and 63;
     if IndexPixels[IndexPosition].v=Pixel.v then begin
      QOIWrite8(DataPointer,DataPosition,QOI_OP_INDEX or IndexPosition);
     end else begin
      IndexPixels[IndexPosition]:=Pixel;
      if Pixel.a=PreviousPixel.a then begin
       vr:=TpvInt32(Pixel.r)-TpvInt32(PreviousPixel.r);
       vg:=TpvInt32(Pixel.g)-TpvInt32(PreviousPixel.g);
       vb:=TpvInt32(Pixel.b)-TpvInt32(PreviousPixel.b);
       if ((vr>-3) and (vr<2)) and ((vg>-3) and (vg<2)) and ((vb>-3) and (vb<2)) then begin
         QOIWrite8(DataPointer,DataPosition,QOI_OP_DIFF or (((vr+2) shl 4) or ((vg+2) shl 2) or ((vb+2) shl 0)));
       end else begin
        vgr:=vr-vg;
        vgb:=vb-vg;
        if ((vgr>-9) and (vgr<8)) and ((vg>-33) and (vg<2)) and ((vgb>-9) and (vgb<8)) then begin
         QOIWrite8(DataPointer,DataPosition,QOI_OP_LUMA or (vg+32));
         QOIWrite8(DataPointer,DataPosition,(((vgr+8) and $f) shl 4) or ((vgb+8) and $f));
        end else begin
         QOIWrite8(DataPointer,DataPosition,QOI_OP_RGB);
         QOIWrite8(DataPointer,DataPosition,Pixel.r);
         QOIWrite8(DataPointer,DataPosition,Pixel.g);
         QOIWrite8(DataPointer,DataPosition,Pixel.b);
        end;
       end;
      end else begin
       QOIWrite8(DataPointer,DataPosition,QOI_OP_RGBA);
       QOIWrite8(DataPointer,DataPosition,Pixel.r);
       QOIWrite8(DataPointer,DataPosition,Pixel.g);
       QOIWrite8(DataPointer,DataPosition,Pixel.b);
       QOIWrite8(DataPointer,DataPosition,Pixel.a);
      end;
     end;
    end;
    PreviousPixel:=Pixel;
   end;

   for vr:=0 to length(QOIPadding)-1 do begin
    QOIWrite8(DataPointer,DataPosition,QOIPadding[vr]);
   end;

  finally
   ReallocMem(aDestData,DataPosition);
  end;

  aDestDataSize:=DataPosition;

  result:=true;
  exit;

 end;

 result:=false;

end;

function SaveQOIImageAsStream(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aStream:TStream;const aSRGB:boolean=true):boolean;
var Data:TpvPointer;
    DataSize:TpvUInt32;
begin
 result:=SaveQOIImage(aImageData,aImageWidth,aImageHeight,Data,DataSize,aSRGB);
 if assigned(Data) then begin
  try
   aStream.Write(Data^,DataSize);
  finally
   FreeMem(Data);
  end;
 end;
end;

function SaveQOIImageAsFile(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aFileName:string;const aSRGB:boolean=true):boolean;
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  result:=SaveQOIImageAsStream(aImageData,aImageWidth,aImageHeight,FileStream,aSRGB);
 finally
  FileStream.Free;
 end;
end;

end.
