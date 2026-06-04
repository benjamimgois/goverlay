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
unit PasVulkan.Image.BMP;
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
     PasVulkan.Types,
     PasVulkan.Math;

function LoadBMPImage(DataPointer:TpvPointer;DataSize:TpvUInt32;var ImageData:TpvPointer;var ImageWidth,ImageHeight:TpvInt32;const HeaderOnly:boolean):boolean;

implementation

{$if defined(fpc)}
function CTZDWord(Value:TpvUInt32):TpvUInt8; inline;
begin
 if Value=0 then begin
  result:=32;
 end else begin
  result:=BSFDWord(Value);
 end;
end;
{$elseif defined(cpu386)}
{$ifndef fpc}
function CTZDWord(Value:TpvUInt32):TpvUInt8; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsf eax,eax
 jnz @Done
 mov eax,32
@Done:
end;
{$endif}
{$elseif defined(cpux86_64)}
{$ifndef fpc}
function CTZDWord(Value:TpvUInt32):TpvUInt8; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsf eax,ecx
{$else}
 bsf eax,edi
{$endif}
 jnz @Done
 mov eax,32
@Done:
end;
{$endif}
{$elseif not defined(fpc)}
function CTZDWord(Value:TpvUInt32):TpvUInt8;
const CTZDebruijn32Multiplicator=TpvUInt32($077cb531);
      CTZDebruijn32Shift=27;
      CTZDebruijn32Mask=31;
      CTZDebruijn32Table:array[0..31] of TpvUInt8=(0,1,28,2,29,14,24,3,30,22,20,15,25,17,4,8,31,27,13,23,21,19,16,7,26,12,18,6,11,5,10,9);
begin
 if Value=0 then begin
  result:=32;
 end else begin
  result:=CTZDebruijn32Table[((TpvUInt32(Value and (-Value))*CTZDebruijn32Multiplicator) shr CTZDebruijn32Shift) and CTZDebruijn32Mask];
 end;
end;
{$ifend}

function LoadBMPImage(DataPointer:TpvPointer;DataSize:TpvUInt32;var ImageData:TpvPointer;var ImageWidth,ImageHeight:TpvInt32;const HeaderOnly:boolean):boolean;
const BI_RGB=0;
      BI_RLE8=1;
      BI_RLE4=2;
      BI_BITFIELDS=3;
      BI_ALPHABITFIELDS=6;
type PByteArray=^TByteArray;
     TByteArray=array[0..65535] of TpvUInt8;
     PBMPHeaderMagic=^TBMPHeaderMagic;
     TBMPHeaderMagic=array[0..1] of AnsiChar;
     PBMPHeader=^TBMPHeader;
     TBMPHeader=packed record
      Magic:TBMPHeaderMagic;
      FileSize:TpvUInt32;
      Unused:TpvUInt32;
      DataOffset:TpvUInt32;
     end;
     PBMPInfo=^TBMPInfo;
     TBMPInfo=packed record
      InfoSize:TpvUInt32;
      Width:TpvInt32;
      Height:TpvInt32;
      Planes:TpvUInt16;
      Bits:TpvUInt16;
      Compression:TpvUInt32;
      SizeImage:TpvUInt32;
      XPelsPerMeter:TpvInt32;
      YPelsPerMeter:TpvInt32;
      ClrUsed:TpvUInt32;
      ClrImportant:TpvUInt32;
     end;
     PBMPPaletteEntry=^TBMPPaletteEntry;
     TBMPPaletteEntry=packed record
      Blue:TpvUInt8;
      Green:TpvUInt8;
      Red:TpvUInt8;
      Unused:TpvUInt8;
     end;
     TBMPPalette=array of TBMPPaletteEntry;
     TDynamicByteArray=array of TpvUInt8;
var RawDataSize,LineSize,x,y,c,MaskSize,
    RedShiftLeft,RedShiftRight,
    GreenShiftLeft,GreenShiftRight,
    BlueShiftLeft,BlueShiftRight,
    AlphaShiftLeft,AlphaShiftRight:TpvInt32;
    BMPHeader:TBMPHeader;
    BMPInfo:TBMPInfo;
    BMPPalette:TBMPPalette;
    RedMask,BlueMask,GreenMask,AlphaMask:TpvUInt32;
    RawData,ip,op:PByteArray;
    VFlip:boolean;
    NewData:TDynamicByteArray;
 function Swap16IfBigEndian(const Value:TpvUInt16):TpvUInt16;
 begin
{$ifdef big_endian}
  result:=(((Value shr 8) and $ff) shl 0) or
          (((Value shr 0) and $ff) shl 8);
{$else}
  result:=Value;
{$endif}
 end;
 function Swap32IfBigEndian(const Value:TpvUInt32):TpvUInt32;
 begin
{$ifdef big_endian}
  result:=(((Value shr 24) and $ff) shl 0) or
          (((Value shr 16) and $ff) shl 8) or
          (((Value shr 8) and $ff) shl 16) or
          (((Value shr 0) and $ff) shl 24);
{$else}
  result:=Value;
{$endif}
 end;
 procedure DecompressRLE8(const Data:TpvPointer;const Size,Width,Height,Pitch:TpvInt32);
 var Line,Count:TpvInt32;
     p,d,DestEnd:PpvUInt8;
     Value:TpvUInt8;
 begin
  p:=Data;
  SetLength(NewData,(Width+Pitch)*Height);
  d:=@NewData[0];
  DestEnd:=@NewData[(Width+Pitch)*Height];
  Line:=0;
  while (TpvPtrInt(TpvPtrUInt(Data)-TpvPtrUInt(p))<Size) and (TpvPtrUInt(d)<TpvPtrUInt(DestEnd)) do begin
   if p^=0 then begin
    inc(p);
    case p^ of
     0:begin
      // End of line
      inc(p);
      inc(Line);
      d:=@NewData[(Width+Pitch)*Line];
     end;
     1:begin
      // End of bitmap
      exit;
     end;
     2:begin
      // Delta
      inc(p);
      inc(d,p^);
      inc(p);
      inc(d,p^*(Width+Pitch));
      inc(p);
     end;
     else begin
      // Absolute mode
      Count:=p^;
      inc(p);
      Move(p^,d^,Count);
      inc(p,Count+((2-(Count and 1)) and 1));
      inc(d,Count);
     end;
    end;
   end else begin
    Count:=p^;
    inc(p);
    Value:=p^;
    inc(p);
    FillChar(p^,Count,Value);
    inc(d,Count);
   end;
  end;
 end;
 procedure DecompressRLE4(const Data:TpvPointer;const Size,Width,Height,Pitch:TpvInt32);
 var LineWidth,Line,Shift,Count,x,y,ReadAdditional,ReadShift,i,Mask:TpvInt32;
     p,d,DestEnd:PpvUInt8;
     Value,OtherValue:TpvUInt8;
 begin
  LineWidth:=((Width+1) shr 1)+Pitch;
  p:=Data;
  SetLength(NewData,LineWidth*Height);
  d:=@NewData[0];
  DestEnd:=@NewData[LineWidth*Height];
  Line:=0;
  Shift:=4;
  while (TpvPtrInt(TpvPtrUInt(Data)-TpvPtrUInt(p))<Size) and (TpvPtrUInt(d)<TpvPtrUInt(DestEnd)) do begin
   if p^=0 then begin
    inc(p);
    case p^ of
     0:begin
      // End of line
      inc(p);
      inc(Line);
      d:=@NewData[LineWidth*Line];
      Shift:=4;
     end;
     1:begin
      // End of bitmap
      exit;
     end;
     2:begin
      // Delta
      inc(p);
      x:=p^;
      inc(p);
      y:=p^;
      inc(p);
      inc(d,(x shr 1)+(y*LineWidth));
      Shift:=(x and 1) shl 2;
     end;
     else begin
      // Absolute mode
      Count:=p^;
      inc(p);
      ReadAdditional:=(2-(Count and 1)) and 1;
      ReadShift:=4;
      for i:=1 to Count do begin
       Value:=(p^ shr ReadShift) and $0f;
       dec(ReadShift,4);
       if ReadShift<0 then begin
        inc(p);
        ReadShift:=4;
       end;
       Mask:=$0f shl Shift;
       d^:=(d^ and not Mask) or ((Value shl Shift) and Mask);
       dec(Shift,4);
       if Shift<0 then begin
        Shift:=4;
        inc(d);
       end;
      end;
      inc(p,ReadAdditional);
     end;
    end;
   end else begin
    Count:=p^;
    inc(p);
    Value:=p^;
    inc(p);
    OtherValue:=Value shr 4;
    Value:=Value and $0f;
    for i:=1 to Count do begin
     Mask:=$0f shl Shift;
     if Shift=0 then begin
      d^:=(d^ and not Mask) or ((Value shl Shift) and Mask);
     end else begin
      d^:=(d^ and not Mask) or ((OtherValue shl Shift) and Mask);
     end;
     dec(Shift,4);
     if Shift<0 then begin
      Shift:=4;
      inc(d);
     end;
    end;
   end;
  end;
 end;
begin
 result:=false;
 ImageData:=nil;
 if (DataSize>=(SizeOf(TBMPHeader)+SizeOf(TBMPInfo))) and
    (PBMPHeader(DataPointer)^.Magic[0]='B') and
    (PBMPHeader(DataPointer)^.Magic[1]='M') and
    (Swap32IfBigEndian(PBMPHeader(DataPointer)^.FileSize)<=DataSize) and
    (Swap32IfBigEndian(PBMPHeader(DataPointer)^.DataOffset)<Swap32IfBigEndian(PBMPHeader(DataPointer)^.FileSize)) then begin

  BMPPalette:=nil;
  try

   BMPHeader:=PBMPHeader(DataPointer)^;
   BMPHeader.FileSize:=Swap32IfBigEndian(BMPHeader.FileSize);
   BMPHeader.DataOffset:=Swap32IfBigEndian(BMPHeader.DataOffset);

   BMPInfo:=PBMPInfo(TpvPointer(@PByteArray(DataPointer)^[SizeOf(TBMPHeader)]))^;
   BMPInfo.InfoSize:=Swap32IfBigEndian(BMPInfo.InfoSize);
   BMPInfo.Width:=Swap32IfBigEndian(BMPInfo.Width);
   BMPInfo.Height:=Swap32IfBigEndian(BMPInfo.Height);
   BMPInfo.Planes:=Swap16IfBigEndian(BMPInfo.Planes);
   BMPInfo.Bits:=Swap16IfBigEndian(BMPInfo.Bits);
   BMPInfo.Compression:=Swap32IfBigEndian(BMPInfo.Compression);
   BMPInfo.SizeImage:=Swap32IfBigEndian(BMPInfo.SizeImage);
   BMPInfo.XPelsPerMeter:=Swap32IfBigEndian(BMPInfo.XPelsPerMeter);
   BMPInfo.YPelsPerMeter:=Swap32IfBigEndian(BMPInfo.YPelsPerMeter);
   BMPInfo.ClrUsed:=Swap32IfBigEndian(BMPInfo.ClrUsed);
   BMPInfo.ClrImportant:=Swap32IfBigEndian(BMPInfo.ClrImportant);

   if BMPInfo.Height<0 then begin
    BMPInfo.Height:=-BMPInfo.Height;
    VFlip:=true;
   end else begin
    VFlip:=false;
   end;

   if (BMPInfo.Width<=0) or (BMPInfo.Height<=0) or not (BMPInfo.Bits in [1,2,4,8,16,24,32]) then begin
    exit;
   end;

   case BMPInfo.Compression of
    BI_BITFIELDS:begin
     if not (BMPInfo.Bits in [16,32]) then begin
      exit;
     end;
     MaskSize:=SizeOf(TpvUInt32)*3;
     RedMask:=PpvUInt32(TpvPointer(@PByteArray(DataPointer)^[SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt32(SizeOf(TpvUInt32)*0)]))^;
     BlueMask:=PpvUInt32(TpvPointer(@PByteArray(DataPointer)^[SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt32(SizeOf(TpvUInt32)*1)]))^;
     GreenMask:=PpvUInt32(TpvPointer(@PByteArray(DataPointer)^[SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt32(SizeOf(TpvUInt32)*2)]))^;
     AlphaMask:=$ff000000;
     RedShiftRight:=CTZDWord(RedMask);
     GreenShiftRight:=CTZDWord(GreenMask);
     BlueShiftRight:=CTZDWord(BlueMask);
     AlphaShiftRight:=24;
     RedShiftLeft:=IntLog2(RedMask shr RedShiftRight);
     GreenShiftLeft:=IntLog2(GreenMask shr GreenShiftRight);
     BlueShiftLeft:=IntLog2(BlueMask shr BlueShiftRight);
     AlphaShiftLeft:=0;
    end;
    BI_ALPHABITFIELDS:begin
     if not (BMPInfo.Bits in [16,32]) then begin
      exit;
     end;
     MaskSize:=SizeOf(TpvUInt32)*4;
     RedMask:=PpvUInt32(TpvPointer(@PByteArray(DataPointer)^[SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt32(SizeOf(TpvUInt32)*0)]))^;
     BlueMask:=PpvUInt32(TpvPointer(@PByteArray(DataPointer)^[SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt32(SizeOf(TpvUInt32)*1)]))^;
     GreenMask:=PpvUInt32(TpvPointer(@PByteArray(DataPointer)^[SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt32(SizeOf(TpvUInt32)*2)]))^;
     AlphaMask:=PpvUInt32(TpvPointer(@PByteArray(DataPointer)^[SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt32(SizeOf(TpvUInt32)*3)]))^;
     RedShiftRight:=CTZDWord(RedMask);
     GreenShiftRight:=CTZDWord(GreenMask);
     BlueShiftRight:=CTZDWord(BlueMask);
     AlphaShiftRight:=CTZDWord(AlphaMask);
     RedShiftLeft:=IntLog2(RedMask shr RedShiftRight);
     GreenShiftLeft:=IntLog2(GreenMask shr GreenShiftRight);
     BlueShiftLeft:=IntLog2(BlueMask shr BlueShiftRight);
     AlphaShiftLeft:=IntLog2(AlphaMask shr AlphaShiftRight);
    end;
    else begin
     MaskSize:=0;
     RedMask:=$00ff0000;
     BlueMask:=$0000ff00;
     GreenMask:=$00000ff;
     AlphaMask:=$ff000000;
     RedShiftRight:=16;
     GreenShiftRight:=8;
     BlueShiftRight:=0;
     AlphaShiftRight:=24;
     RedShiftLeft:=0;
     GreenShiftLeft:=0;
     BlueShiftLeft:=0;
     AlphaShiftLeft:=0;
     case BMPInfo.Compression of
      BI_RLE8:begin
       if BMPInfo.Bits<>8 then begin
        exit;
       end;
      end;
      BI_RLE4:begin
       if not (BMPInfo.Bits in [1,4]) then begin
        exit;
       end;
      end;
     end;
    end;
   end;

   if BMPInfo.Bits<=8 then begin
    c:=BMPInfo.ClrUsed;
    if c=0 then begin
     c:=1 shl BMPInfo.Bits;
    end else if c>(1 shl BMPInfo.Bits) then begin
     exit;
    end;
    if TpvUInt64(SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt64(MaskSize)+TpvUInt64((1 shl BMPInfo.Bits)*SizeOf(TBMPPaletteEntry)))>=BMPHeader.FileSize then begin
     exit;
    end;
    if not HeaderOnly then begin
     SetLength(BMPPalette,1 shl BMPInfo.Bits);
     Move(PByteArray(DataPointer)^[SizeOf(TBMPHeader)+BMPInfo.InfoSize+TpvUInt64(MaskSize)],BMPPalette[0],length(BMPPalette)*SizeOf(TBMPPaletteEntry));
    end;
   end;

   if HeaderOnly then begin

    result:=true;

   end else begin

    try
     case BMPInfo.Compression of
      BI_RGB:begin
       LineSize:=(((BMPInfo.Width*BMPInfo.Bits)+31) and not TpvUInt32(31)) shr 3;
       RawDataSize:=LineSize*BMPInfo.Height;
       if TpvInt64(BMPHeader.DataOffset+TpvInt64(RawDataSize))>TpvInt64(BMPHeader.FileSize) then begin
        exit;
       end;
       ImageWidth:=BMPInfo.Width;
       ImageHeight:=BMPInfo.Height;
       GetMem(ImageData,ImageWidth*ImageHeight*4);
       RawData:=@PByteArray(DataPointer)^[BMPHeader.DataOffset];
       case BMPInfo.Bits of
        1:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip^[x shr 3] and (1 shl (x and 7));
           op^[0]:=BMPPalette[c].Red;
           op^[1]:=BMPPalette[c].Green;
           op^[2]:=BMPPalette[c].Blue;
           op^[3]:=$ff;
           op:=@op[4];
          end;
         end;
        end;
        2:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip^[x shr 2] and (1 shl (x and 3));
           op^[0]:=BMPPalette[c].Red;
           op^[1]:=BMPPalette[c].Green;
           op^[2]:=BMPPalette[c].Blue;
           op^[3]:=$ff;
           op:=@op[4];
          end;
         end;
        end;
        4:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip^[x shr 1] and (1 shl ((x and 1) shl 2));
           op^[0]:=BMPPalette[c].Red;
           op^[1]:=BMPPalette[c].Green;
           op^[2]:=BMPPalette[c].Blue;
           op^[3]:=$ff;
           op:=@op[4];
          end;
         end;
        end;
        8:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip^[x];
           op^[0]:=BMPPalette[c].Red;
           op^[1]:=BMPPalette[c].Green;
           op^[2]:=BMPPalette[c].Blue;
           op^[3]:=$ff;
           op:=@op[4];
          end;
         end;
        end;
        16:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip[0] or (TpvUInt16(TpvUInt8(ip^[1])) shl 8);
           op^[0]:=(c and $f800) shr 11;
           op^[1]:=(c and $07e0) shr 5;
           op^[2]:=(c and $001f) shr 0;
           op^[3]:=$ff;
           ip:=@ip[2];
           op:=@op[4];
          end;
         end;
        end;
        24:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           op^[0]:=ip^[2];
           op^[1]:=ip^[1];
           op^[2]:=ip^[0];
           op^[3]:=$ff;
           ip:=@ip[3];
           op:=@op[4];
          end;
         end;
        end;
        32:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           op^[0]:=ip^[2];
           op^[1]:=ip^[1];
           op^[2]:=ip^[0];
           op^[3]:=ip^[3];
           ip:=@ip[4];
           op:=@op[4];
          end;
         end;
        end;
       end;
      end;
      BI_RLE8:begin
       ImageWidth:=BMPInfo.Width;
       ImageHeight:=BMPInfo.Height;
       GetMem(ImageData,ImageWidth*ImageHeight*4);
       NewData:=nil;
       try
        LineSize:=(((BMPInfo.Width*BMPInfo.Bits)+31) and not TpvUInt32(31)) shr 3;
        DecompressRLE8(@PByteArray(DataPointer)^[BMPHeader.DataOffset],BMPHeader.FileSize-BMPHeader.DataOffset,ImageWidth,ImageHeight,LineSize-ImageWidth);
        RawData:=@NewData[0];
        for y:=ImageHeight-1 downto 0 do begin
         ip:=@PByteArray(RawData)^[y*LineSize];
         if VFlip then begin
          op:=@PByteArray(ImageData)^[y*ImageWidth*4];
         end else begin
          op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
         end;
         for x:=0 to ImageWidth-1 do begin
          c:=ip^[x];
          op^[0]:=BMPPalette[c].Red;
          op^[1]:=BMPPalette[c].Green;
          op^[2]:=BMPPalette[c].Blue;
          op^[3]:=$ff;
          op:=@op[4];
         end;
        end;
       finally
        NewData:=nil;
       end;
      end;
      BI_RLE4:begin
       ImageWidth:=BMPInfo.Width;
       ImageHeight:=BMPInfo.Height;
       GetMem(ImageData,ImageWidth*ImageHeight*4);
       NewData:=nil;
       try
        LineSize:=(((BMPInfo.Width*BMPInfo.Bits)+31) and not TpvUInt32(31)) shr 3;
        DecompressRLE4(@PByteArray(DataPointer)^[BMPHeader.DataOffset],BMPHeader.FileSize-BMPHeader.DataOffset,ImageWidth,ImageHeight,LineSize-ImageWidth);
        RawData:=@NewData[0];
        case BMPInfo.Bits of
         1:begin
          for y:=ImageHeight-1 downto 0 do begin
           ip:=@PByteArray(RawData)^[y*LineSize];
           if VFlip then begin
            op:=@PByteArray(ImageData)^[y*ImageWidth*4];
           end else begin
            op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
           end;
           for x:=0 to ImageWidth-1 do begin
            c:=ip^[x shr 3] and (1 shl (x and 7));
            op^[0]:=BMPPalette[c].Red;
            op^[1]:=BMPPalette[c].Green;
            op^[2]:=BMPPalette[c].Blue;
            op^[3]:=$ff;
            op:=@op[4];
           end;
          end;
         end;
         2:begin
          for y:=ImageHeight-1 downto 0 do begin
           ip:=@PByteArray(RawData)^[y*LineSize];
           if VFlip then begin
            op:=@PByteArray(ImageData)^[y*ImageWidth*4];
           end else begin
            op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
           end;
           for x:=0 to ImageWidth-1 do begin
            c:=ip^[x shr 2] and (1 shl (x and 3));
            op^[0]:=BMPPalette[c].Red;
            op^[1]:=BMPPalette[c].Green;
            op^[2]:=BMPPalette[c].Blue;
            op^[3]:=$ff;
            op:=@op[4];
           end;
          end;
         end;
         4:begin
          for y:=ImageHeight-1 downto 0 do begin
           ip:=@PByteArray(RawData)^[y*LineSize];
           if VFlip then begin
            op:=@PByteArray(ImageData)^[y*ImageWidth*4];
           end else begin
            op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
           end;
           for x:=0 to ImageWidth-1 do begin
            c:=ip^[x shr 1] and (1 shl ((x and 1) shl 2));
            op^[0]:=BMPPalette[c].Red;
            op^[1]:=BMPPalette[c].Green;
            op^[2]:=BMPPalette[c].Blue;
            op^[3]:=$ff;
            op:=@op[4];
           end;
          end;
         end;
        end;
       finally
        NewData:=nil;
       end;
      end;
      BI_BITFIELDS:begin
       LineSize:=(((BMPInfo.Width*BMPInfo.Bits)+31) and not TpvUInt32(31)) shr 3;
       RawDataSize:=LineSize*BMPInfo.Height;
       if TpvInt64(BMPHeader.DataOffset+TpvInt64(RawDataSize))>TpvInt64(BMPHeader.FileSize) then begin
        exit;
       end;
       ImageWidth:=BMPInfo.Width;
       ImageHeight:=BMPInfo.Height;
       GetMem(ImageData,ImageWidth*ImageHeight*4);
       RawData:=@PByteArray(DataPointer)^[BMPHeader.DataOffset];
       case BMPInfo.Bits of
        16:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip[0] or (TpvUInt16(TpvUInt8(ip^[1])) shl 8);
           op^[0]:=((c and RedMask) shr RedShiftRight) shl RedShiftLeft;
           op^[1]:=((c and GreenMask) shr GreenShiftRight) shl GreenShiftLeft;
           op^[2]:=((c and BlueMask) shr BlueShiftRight) shl BlueShiftLeft;
           op^[3]:=$ff;
           ip:=@ip[2];
           op:=@op[4];
          end;
         end;
        end;
        32:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip[0] or (TpvUInt16(TpvUInt8(ip^[1])) shl 8) or (TpvUInt16(TpvUInt8(ip^[2])) shl 16) or (TpvUInt16(TpvUInt8(ip^[3])) shl 24);
           op^[0]:=((c and RedMask) shr RedShiftRight) shl RedShiftLeft;
           op^[1]:=((c and GreenMask) shr GreenShiftRight) shl GreenShiftLeft;
           op^[2]:=((c and BlueMask) shr BlueShiftRight) shl BlueShiftLeft;
           op^[3]:=$ff;
           ip:=@ip[4];
           op:=@op[4];
          end;
         end;
        end;
       end;
      end;
      BI_ALPHABITFIELDS:begin
       LineSize:=(((BMPInfo.Width*BMPInfo.Bits)+31) and not TpvUInt32(31)) shr 3;
       RawDataSize:=LineSize*BMPInfo.Height;
       if TpvInt64(BMPHeader.DataOffset+TpvInt64(RawDataSize))>TpvInt64(BMPHeader.FileSize) then begin
        exit;
       end;
       ImageWidth:=BMPInfo.Width;
       ImageHeight:=BMPInfo.Height;
       GetMem(ImageData,ImageWidth*ImageHeight*4);
       RawData:=@PByteArray(DataPointer)^[BMPHeader.DataOffset];
       case BMPInfo.Bits of
        16:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip[0] or (TpvUInt16(TpvUInt8(ip^[1])) shl 8);
           op^[0]:=((c and RedMask) shr RedShiftRight) shl RedShiftLeft;
           op^[1]:=((c and GreenMask) shr GreenShiftRight) shl GreenShiftLeft;
           op^[2]:=((c and BlueMask) shr BlueShiftRight) shl BlueShiftLeft;
           op^[3]:=((c and AlphaMask) shr AlphaShiftRight) shl AlphaShiftLeft;
           ip:=@ip[2];
           op:=@op[4];
          end;
         end;
        end;
        32:begin
         for y:=ImageHeight-1 downto 0 do begin
          ip:=@PByteArray(RawData)^[y*LineSize];
          if VFlip then begin
           op:=@PByteArray(ImageData)^[y*ImageWidth*4];
          end else begin
           op:=@PByteArray(ImageData)^[(ImageHeight-(y+1))*ImageWidth*4];
          end;
          for x:=0 to ImageWidth-1 do begin
           c:=ip[0] or (TpvUInt16(TpvUInt8(ip^[1])) shl 8) or (TpvUInt16(TpvUInt8(ip^[2])) shl 16) or (TpvUInt16(TpvUInt8(ip^[3])) shl 24);
           op^[0]:=((c and RedMask) shr RedShiftRight) shl RedShiftLeft;
           op^[1]:=((c and GreenMask) shr GreenShiftRight) shl GreenShiftLeft;
           op^[2]:=((c and BlueMask) shr BlueShiftRight) shl BlueShiftLeft;
           op^[3]:=((c and AlphaMask) shr AlphaShiftRight) shl AlphaShiftLeft;
           ip:=@ip[4];
           op:=@op[4];
          end;
         end;
        end;
       end;
      end;
      else begin
       // Another compressions not supported (yet)
       exit;
      end;
     end;

     result:=true;

    except

     if assigned(ImageData) then begin
      FreeMem(ImageData);
      ImageData:=nil;
     end;

     raise

    end;

   end;

  finally
   BMPPalette:=nil;
  end;

 end;
end;

end.
