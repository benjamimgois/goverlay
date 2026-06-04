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
      http://github.com/pv1985/pasvulkan                                    *
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
unit PasVulkan.Video.AVI.Writer;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$undef GoodCompilerForSIMD}
{$ifdef fpc}
 {$define caninline}
 {-$codealign 16}
 {$codealign CONSTMIN=16} // For SIMD-constants
 {$codealign CONSTMAX=16} // For SIMD-constants
{$else}
 {$undef caninline}
 {$ifdef ver180}
  {$define caninline}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define caninline}
   {$ifend}
   {$if compilerversion>=28}
    {$define GoodCompilerForSIMD} // For example: Delphi 7 isn't SIMD-friendly (since it doesn't align constant variables to 16-TpvUInt8 boundaries, and for example movdqa gives then exceptions), but XE7 is SIMD-friendly
    {$codealign 16}
   {$ifend}
  {$endif}
 {$endif}
{$endif}
{$ifndef cpu386}
 {$define PurePascal}
{$endif}
{$ifdef fpc}
 {-$define PasVulkanUseX264}
{$endif}
{-$define PurePascal} // Needed for example for PIC code

interface

uses SysUtils,Classes,Math,
     {$ifdef PasVulkanUseX264},x264{$endif}
     {$ifdef fpc}
      dynlibs,
     {$else}
      Windows,
     {$endif}
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Image.JPEG;

const MaxChunkDepth=16;

      MaxSuperIndex=1024;

      vcRGB2=0;
      vcI420=1;
      vcMJPG=2;
      vcMJPEG=vcMJPG;
      vcX264_420=3;
      vcX264_444=4;

{$ifdef fpc}
      pvAVINilLibHandle=NilHandle;
{$else}
      pvAVINilLibHandle=THandle(0);
{$endif}

type PpvAVIIndexEntry=^TpvAVIIndexEntry;
     TpvAVIIndexEntry=record
      Frame:TpvInt32;
      Type_:TpvInt32;
      Size:TpvInt32;
      Offset:TpvUInt32;
     end;

     TpvAVIIndexEntries=array of PpvAVIIndexEntry;

     PpvAVISegmentInfo=^TpvAVISegmentInfo;
     TpvAVISegmentInfo=record
      Offset:TpvInt64;
      VideoIndexOffset:TpvInt64;
      SoundIndexOffset:TpvInt64;
      FirstIndex:TpvInt32;
      VideoIndexSize:TpvUInt32;
      SoundIndexSize:TpvUInt32;
      IndexFrames:TpvUInt32;
      VideoFrames:TpvUInt32;
      SoundFrames:TpvUInt32;
     end;

     TpvAVISegmentInfos=array of PpvAVISegmentInfo;

     TpvAVIChunkSignature=array[0..3] of ansichar;

     TpvAVIIntegers=array of TpvInt32;

     PpvAVILibHandle=^TpvAVILibHandle;
{$ifdef fpc}
     TpvAVILibHandle=TLibHandle;
{$else}
     TpvAVILibHandle=THandle;
{$endif}

     EpvAVIWriter=class(Exception);

     TpvAVIWriter_tjInitCompress=function:pointer; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TpvAVIWriter_tjDestroy=function(handle:pointer):TpvInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TpvAVIWriter_tjAlloc=function(bytes:TpvInt32):pointer; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TpvAVIWriter_tjFree=procedure(buffer:pointer); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TpvAVIWriter_tjCompress2=function(handle:pointer;
                                       srcBuf:pointer;
                                       width:TpvInt32;
                                       pitch:TpvInt32;
                                       height:TpvInt32;
                                       pixelFormat:TpvInt32;
                                       var jpegBuf:pointer;
                                       var jpegSize:TpvUInt32;
                                       jpegSubsamp:TpvInt32;
                                       jpegQual:TpvInt32;
                                       flags:TpvInt32):TpvInt32; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}
     { TpvAVIWriter }
     TpvAVIWriter=class // OpenDML / AVI 2.0 compatible AVI writer
      private
       fStream:TStream;
       fDoFree:longbool;
       fMaxCompressedSize:TpvUInt32;
       fCompressed:Pointer;
       fRGB:Pointer;
       fRGB2:Pointer;
       fJPEGEncoder:TpvJPEGEncoder;
       fVideoFrames:TpvUInt32;
       fVideoWidth:TpvUInt32;
       fVideoHeight:TpvUInt32;
       fVideoFPS:TpvUInt32;
       fVideoCodec:TpvUInt32;
       fVideoFrameSize:TpvUInt32;
       fSoundSampleRate:TpvInt32;
       fSoundChannels:TpvInt32;
       fSoundBits:TpvInt32;
       fIndexEntries:TList;
       fSegmentInfos:TList;
       fFileFramesOffset:TpvInt64;
       fFileExtFramesOffset:TpvInt64;
       fFileVideoOffset:TpvInt64;
       fFileSoundOffset:TpvInt64;
       fSuperIndexVideoOffset:TpvInt64;
       fSuperIndexSoundOffset:TpvInt64;
       fChunkDepth:TpvInt32;
       fChunkOffsets:array[0..MaxChunkDepth-1] of TpvInt64;
       fQuality:TpvInt32;
       fFast:longbool;
       fChromaSubsampling:TpvInt32;
       fXCache:TpvAVIIntegers;
       fTurboJpegLibrary:TpvAVILibHandle;
       ftjInitCompress:TpvAVIWriter_tjInitCompress;
       ftjDestroy:TpvAVIWriter_tjDestroy;
       ftjAlloc:TpvAVIWriter_tjAlloc;
       ftjFree:TpvAVIWriter_tjFree;
       ftjCompress2:TpvAVIWriter_tjCompress2;
{$ifdef PasVulkanUseX264}
       fX264Param:Tx264_param_t;
       fX264Pic:Tx264_picture_t;
       fX264PicOut:Tx264_picture_t;
       fX264Handle:Px264_t;
       fX264NAL:Px264_nal_t;
       fX264INAL:PpvInt32;
{$endif}
      protected
       procedure WriteSigned8Bit(s8Bit:TpvInt8);
       procedure WriteSigned16Bit(s16Bit:TpvInt16);
       procedure WriteSigned32Bit(s32Bit:TpvInt32);
       procedure WriteUnsigned8Bit(us8Bit:TpvUInt8);
       procedure WriteUnsigned16Bit(us16Bit:TpvUInt16);
       procedure WriteUnsigned32Bit(us32Bit:TpvUInt32);
       function AddIndex(aFrame,aType,aSize:TpvInt32):PpvAVIIndexEntry;
       procedure StartChunk(const aChunkSignature:TpvAVIChunkSignature;aSize:TpvUInt32=0);
       procedure ListChunk(const aChunkSignature,aListChunkSignature:TpvAVIChunkSignature);
       procedure EndChunk;
       procedure EndListChunk;
       procedure WriteChunk(const aChunkSignature:TpvAVIChunkSignature;aData:pointer;aSize:TpvUInt32);
       procedure FlushSegment;
       function NextSegment:boolean;
      public
       constructor Create(aStream:TStream;aDoFree:longbool;aVideoCodec:TpvUInt32;aVideoWidth,aVideoHeight,aVideoFPS,aSoundSampleRate,aSoundChannels,aSoundBits:TpvInt32;aQuality:TpvInt32=95;aFast:boolean=false;aChromaSubsampling:TpvInt32=-1);
       destructor Destroy; override;
       function WriteVideoFrame(aPixels:pointer;aWidth,aHeight:TpvUInt32;aFrame:TpvUInt32):boolean;
       function WriteSoundFrame(aData:pointer;aFrameSize,aFrame:TpvUInt32):boolean;
     end;

implementation

type TAVIH=packed record
      dwMicroSecPerFrame:TpvUInt32;
      dwMaxBytesPerSec:TpvUInt32;
      dwPaddingGranularity:TpvUInt32;
      dwFlags:TpvUInt32;
      dwTotalFrames:TpvUInt32;
      dwInitialFrames:TpvUInt32;
      dwStreams:TpvUInt32; // 1 for just video, 2 for video and audio
      dwSuggestedBufferSize:TpvUInt32;
      dwWidth:TpvUInt32;
      dwHeight:TpvUInt32;
      dwReserved:array[0..3] of TpvUInt32;
     end;

     TSTRH=packed record
      fccType:TpvAVIChunkSignature;
      fccHandler:TpvAVIChunkSignature;
      dwFlags:TpvUInt32;
      wPriority:TpvUInt16;
      wLanguage:TpvUInt16;
      dwInitialFrames:TpvUInt32;
      dwScale:TpvUInt32;
      dwRate:TpvUInt32;
      dwStart:TpvUInt32;
      dwLength:TpvUInt32;
      dwSuggestedBufferSize:TpvUInt32;
      dwQuality:TpvUInt32;
      dwSampleSize:TpvUInt32;
      rcFrame:packed record
       Left:TpvInt16;
       Top:TpvInt16;
       Right:TpvInt16;
       Bottom:TpvInt16;
      end;
     end;

     TINDX=packed record
      wLongsPerEntry:TpvUInt16;
      bIndexSubType:TpvUInt8;
      bIndexType:TpvUInt8;
      nEntriesInUse:TpvUInt32;
      dwChunkId:TpvAVIChunkSignature;
      dwReserved:array[0..2] of TpvUInt32;
     end;

     TINDXEntry=packed record
      dwOffsetLow:TpvUInt32;
      dwOffsetHigh:TpvUInt32;
      dwSize:TpvUInt32;
      dwDuration:TpvUInt32;
     end;

     TVPRP=packed record
      dwVideoFormat:TpvUInt32;
      dwVideoStandard:TpvUInt32;
      dwVerticalRefreshRate:TpvUInt32;
      dwHorizontalTotal:TpvUInt32;
      dwVerticalTotal:TpvUInt32;
      wAspectDenominator:TpvUInt16;
      wAspectNumerator:TpvUInt16;
      dwFrameWidth:TpvUInt32;
      dwFrameHeight:TpvUInt32;
      dwFieldsPerFrame:TpvUInt32;
      dwCompressedBitmapWidth:TpvUInt32;
      dwCompressedBitmapHeight:TpvUInt32;
      dwValidBitmapWidth:TpvUInt32;
      dwValidBitmapHeight:TpvUInt32;
      dwValidBitmapXOffset:TpvUInt32;
      dwValidBitmapYOffset:TpvUInt32;
      dwVideoXOffset:TpvUInt32;
      dwVideoYOffset:TpvUInt32;
     end;

     TBitmapInfoHeader=packed record
      biSize:TpvUInt32;
      biWidth:TpvInt32;
      biHeight:TpvInt32;
      biPlanes:TpvUInt16;
      biBitCount:TpvUInt16;
      biCompression:TpvAVIChunkSignature;
      biSizeImage:TpvUInt32;
      biXPelsPerMeter:TpvInt32;
      biYPelsPerMeter:TpvInt32;
      biClrUsed:TpvUInt32;
      biClrImportant:TpvUInt32;
     end;

     TWaveFormatEx=packed record
      wFormatTag:TpvUInt16;
      nChannels:TpvUInt16;
      nSamplesPerSec:TpvUInt32;
      nAvgBytesPerSec:TpvUInt32;
      nBlockAlign:TpvUInt16;
      wBitsPerSample:TpvUInt16;
      cbSize:TpvUInt16;
     end;

const ISTFData:ansistring='PasVulkan.Video.AVI.Writer'+#0;

{$ifndef HasSAR}
function SARLongint(Value,Shift:TpvInt32):TpvInt32;
{$ifdef PurePascal}
{$ifdef caninline}inline;{$endif}
begin
{$ifdef HasSAR}
 result:=SARLongint(Value,Shift);
{$else}
 Shift:=Shift and 31;
 result:=(TpvUInt32(Value) shr Shift) or (TpvUInt32(TpvInt32(TpvUInt32(0-TpvUInt32(TpvUInt32(Value) shr 31)) and TpvUInt32(0-TpvUInt32(ord(Shift<>0))))) shl (32-Shift));
{$endif}
end;
{$else}
{$ifdef cpu386} assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 mov ecx,edx
 sar eax,cl
end;
{$else}
{$ifdef cpuarm} assembler; {$ifdef fpc}nostackframe;{$endif}
asm
 mov r0,r0,asr r1
{$if defined(cpuarmv3) or defined(cpuarmv4) or defined(cpuarmv5)}
 mov pc,lr
{$else}
 bx lr
{$ifend}
end;
{$else}
 {$error You must define PurePascal, since no inline assembler function variant doesn't exist for your target platform }
{$endif}
{$endif}
{$endif}
{$endif}

function GCD(a,b:TpvInt32):TpvInt32;
begin
 if a=0 then begin
  b:=a;
 end;
 if b=0 then begin
  a:=b;
 end;
 while a<>b do begin
  if a>b then begin
   dec(a,b);
  end;
  if b>a then begin
   dec(b,a);
  end;
 end;
 if a=0 then begin
  a:=1;
 end;
 result:=a;
end;

function ClampToByte(v:TpvInt32):TpvUInt8;
{$ifdef PurePascal}
begin
 if v<0 then begin
  result:=0;
 end else if v>255 then begin
  result:=255;
 end else begin
  result:=v;
 end;
end;
{$else}
{$ifdef cpu386} assembler; register;
asm
{cmp eax,255
 cmovgt eax,255
 test eax,eax
 cmovlt eax,0{}
 mov ecx,eax
 and ecx,$ffffff00
 neg ecx
 sbb ecx,ecx
 or eax,ecx{}
{mov ecx,255
 sub ecx,eax
 sar ecx,31
 or cl,al
 sar eax,31
 not al
 and al,cl{}
end;
{$else}
 {$error You must define PurePascal, since no inline assembler function variant doesn't exist for your target platform }
{$endif}
{$endif}

procedure ResizeRGB32(Src:pointer;SrcWidth,SrcHeight:TpvInt32;Dst:pointer;DstWidth,DstHeight:TpvInt32;var XCache:TpvAVIIntegers);
type PLongwords=^TLongwords;
     TLongwords=array[0..65535] of TpvUInt32;
var DstX,DstY,SrcX,SrcY:TpvInt32;
    r,g,b,w,Pixel,SrcR,SrcG,SrcB,SrcA,Weight,xUL,xUR,xLL,xLR,
    RedBlue,Green,Remainder,WeightX,WeightY:TpvUInt32;
    TempSrc,TempDst:PLongwords;
    UpsampleX,UpsampleY:longbool;
    WeightShift,xa,xb,xc,xd,ya,yb,yc,yd:TpvInt32;
    SourceTexelsPerOutPixel,WeightPerPixel,AccumlatorPerPixel,WeightDivider,fw,fh:single;
begin
 if (SrcWidth=(DstWidth*2)) and (SrcHeight=(DstHeight*2)) then begin
  Remainder:=0;
  TempDst:=pointer(Dst);
  for DstY:=0 to DstHeight-1 do begin
   SrcY:=DstY*2;
   TempSrc:=pointer(@pansichar(Src)[(SrcY*SrcWidth) shl 2]);
   for DstX:=0 to DstWidth-1 do begin
    xUL:=TempSrc^[0];
    xUR:=TempSrc^[1];
    xLL:=TempSrc^[SrcWidth];
    xLR:=TempSrc^[SrcWidth+1];
    RedBlue:=(xUL and $00ff00ff)+(xUR and $00ff00ff)+(xLL and $00ff00ff)+(xLR and $00ff00ff)+(Remainder and $00ff00ff);
    Green:=(xUL and $0000ff00)+(xUR and $0000ff00)+(xLL and $0000ff00)+(xLR and $0000ff00)+(Remainder and $0000ff00);
    Remainder:=(RedBlue and $00030003) or (Green and $00000300);
    TempDst[0]:=((RedBlue and $03fc03fc) or (Green and $0003fc00)) shr 2;
    TempDst:=pointer(@TempDst^[1]);
    TempSrc:=pointer(@TempSrc^[2]);
   end;
  end;
 end else begin
  UpsampleX:=SrcWidth<DstWidth;
  UpsampleY:=DstHeight<DstHeight;
  WeightShift:=0;
  SourceTexelsPerOutPixel:=((SrcWidth/DstWidth)+1)*((SrcHeight/DstHeight)+1);
  WeightPerPixel:=SourceTexelsPerOutPixel*65536;
  AccumlatorPerPixel:=WeightPerPixel*256;
  WeightDivider:=AccumlatorPerPixel/4294967000.0;
  if WeightDivider>1.0 then begin
   WeightShift:=trunc(ceil(ln(WeightDivider)/ln(2.0)));
  end;
  WeightShift:=min(WeightShift,15);
  fw:=(256*SrcWidth)/DstWidth;
  fh:=(256*SrcHeight)/DstHeight;
  if UpsampleX and UpsampleY then begin
   if length(XCache)<TpvInt32(DstWidth) then begin
    SetLength(XCache,TpvInt32(DstWidth));
   end;
   for DstX:=0 to DstWidth-1 do begin
    XCache[DstX]:=min(trunc(DstX*fw),(256*(SrcWidth-1))-1);
   end;
   for DstY:=0 to DstHeight-1 do begin
    ya:=min(trunc(DstY*fh),(256*(SrcHeight-1))-1);
    yc:=ya shr 8;
    TempDst:=pointer(@pansichar(Dst)[(DstY*DstWidth) shl 2]);
    for DstX:=0 to DstWidth-1 do begin
     xa:=XCache[DstX];
     xc:=xa shr 8;
     TempSrc:=pointer(@pansichar(Src)[((yc*SrcWidth)+xc) shl 2]);
     r:=0;
     g:=0;
     b:=0;
     WeightX:=TpvUInt32(TpvInt32(256-(xa and $ff)));
     WeightY:=TpvUInt32(TpvInt32(256-(ya and $ff)));
     for SrcY:=0 to 1 do begin
      for SrcX:=0 to 1 do begin
       Pixel:=TempSrc^[(SrcY*SrcWidth)+SrcX];
       SrcR:=(Pixel shr 0) and $ff;
       SrcG:=(Pixel shr 8) and $ff;
       SrcB:=(Pixel shr 16) and $ff;
       Weight:=(WeightX*WeightY) shr WeightShift;
       inc(r,SrcR*Weight);
       inc(g,SrcG*Weight);
       inc(b,SrcB*Weight);
       WeightX:=256-WeightX;
      end;
      WeightY:=256-WeightY;
     end;
     TempDst^[0]:=((r shr 16) and $ff) or ((g shr 8) and $ff00) or (b and $ff0000);
     TempDst:=pointer(@TempDst^[1]);
    end;
   end;
  end else begin
   if length(XCache)<(TpvInt32(DstWidth)*2) then begin
    SetLength(XCache,TpvInt32(DstWidth)*2);
   end;
   for DstX:=0 to DstWidth-1 do begin
    xa:=trunc(DstX*fw);
    if UpsampleX then begin
     xb:=xa+256;
    end else begin
     xb:=trunc((DstX+1)*fw);
    end;
    XCache[(DstX shl 1) or 0]:=min(xa,(256*SrcWidth)-1);
    XCache[(DstX shl 1) or 1]:=min(xb,(256*SrcWidth)-1);
   end;
   for DstY:=0 to DstHeight-1 do begin
    ya:=trunc(DstY*fh);
    if UpsampleY then begin
     yb:=ya+256;
    end else begin
     yb:=trunc((DstY+1)*fh);
    end;
    TempDst:=pointer(@pansichar(Dst)[(DstY*DstWidth) shl 2]);
    yc:=ya shr 8;
    yd:=yb shr 8;
    for DstX:=0 to DstWidth-1 do begin
     xa:=XCache[(DstX shl 1) or 0];
     xb:=XCache[(DstX shl 1) or 1];
     xc:=xa shr 8;
     xd:=xb shr 8;
     r:=0;
     g:=0;
     b:=0;
     w:=0;
     for SrcY:=yc to yd do begin
      if (SrcY<0) or (SrcY>=SrcHeight) then begin
       continue;
      end;
      WeightY:=256;
      if yc<>yd then begin
       if SrcY=yc then begin
        WeightY:=256-(ya and $ff);
       end else if SrcY=yd then begin
        WeightY:=yb and $ff;
       end;
      end;
      TempSrc:=pointer(@pansichar(Src)[((SrcY*SrcWidth)+xc) shl 2]);
      for SrcX:=xc to xd do begin
       if (SrcX<0) or (SrcX>=SrcWidth) then begin
        continue;
       end;
       WeightX:=256;
       if xc<>xd then begin
        if SrcX=xc then begin
         WeightX:=256-(xa and $ff);
        end else if SrcX=xd then begin
         WeightX:=xb and $ff;
        end;
       end;
       Pixel:=TempSrc^[0];
       inc(PAnsiChar(TempSrc),SizeOf(TpvUInt32));
       SrcR:=(Pixel shr 0) and $ff;
       SrcG:=(Pixel shr 8) and $ff;
       SrcB:=(Pixel shr 16) and $ff;
       Weight:=(WeightX*WeightY) shr WeightShift;
       inc(r,SrcR*Weight);
       inc(g,SrcG*Weight);
       inc(b,SrcB*Weight);
       inc(w,Weight);
      end;
     end;
     if w>0 then begin
      TempDst^[0]:=((r div w) and $ff) or (((g div w) shl 8) and $ff00) or (((b div w) shl 16) and $ff0000);
     end else begin
      TempDst^[0]:=0;
     end;
     TempDst:=pointer(@TempDst^[1]);
    end;
   end;
  end;
 end;
end;

procedure EncodeI420(RGB,I420:pointer;VideoWidth,VideoHeight:TpvInt32);
type PLongwords=^TLongwords;
     TLongwords=array[0..65535] of TpvUInt32;
var Src,TempSrc:PLongwords;
    x,y,PlaneSize:TpvInt32;
    Pixel,SrcR,SrcG,SrcB:TpvUInt32;
    PlaneY,PlaneU,PlaneV:pansichar;
begin
 PlaneSize:=VideoWidth*VideoHeight;
 PlaneY:=I420;
 PlaneU:=pointer(@pansichar(I420)[PlaneSize]);
 PlaneV:=pointer(@pansichar(I420)[PlaneSize+(PlaneSize shr 2)]);
 Src:=RGB;
 for y:=0 to VideoHeight-1 do begin
  TempSrc:=pointer(@Src[((VideoHeight-1)-y)*VideoWidth]);
  for x:=0 to VideoWidth-1 do begin
   Pixel:=TempSrc^[x];
   SrcR:=(Pixel shr 0) and $ff;
   SrcG:=(Pixel shr 8) and $ff;
   SrcB:=(Pixel shr 16) and $ff;
   TpvUInt8(PlaneY^):=ClampToByte(((16 shl 12)+(1052*SrcR)+(2065*SrcG)+(401*SrcB)) shr 12);
// TpvUInt8(PlaneY^):=ClampToByte(((16 shl 16)+(16763*SrcR)+(32910*SrcG)+(6391*SrcB)) shr 16);
   inc(PlaneY);
  end;
  if ((y and 1)=0) and ((y shr 1)<(VideoHeight shr 1)) then begin
   TempSrc:=pointer(@Src[(((VideoHeight-2)-y)*VideoWidth)]);
   for x:=0 to (VideoWidth shr 1)-1 do begin
    Pixel:=TempSrc^[0];
    SrcR:=(Pixel shr 0) and $ff;
    SrcG:=(Pixel shr 8) and $ff;
    SrcB:=(Pixel shr 16) and $ff;
    Pixel:=TempSrc^[1];
    inc(SrcR,(Pixel shr 0) and $ff);
    inc(SrcG,(Pixel shr 8) and $ff);
    inc(SrcB,(Pixel shr 16) and $ff);
    Pixel:=TempSrc^[VideoWidth];
    inc(SrcR,(Pixel shr 0) and $ff);
    inc(SrcG,(Pixel shr 8) and $ff);
    inc(SrcB,(Pixel shr 16) and $ff);
    Pixel:=TempSrc^[VideoWidth+1];
    inc(SrcR,(Pixel shr 0) and $ff);
    inc(SrcG,(Pixel shr 8) and $ff);
    inc(SrcB,(Pixel shr 16) and $ff);
    TpvUInt8(PlaneU^):=ClampToByte(SARLongint((((128 shl 12)-(152*SrcR))-(298*SrcG))+(450*SrcB),12));
    TpvUInt8(PlaneV^):=ClampToByte(SARLongint((((128 shl 12)+(450*SrcR))-(377*SrcG))-(73*SrcB),12));
{   TpvUInt8(PlaneU^):=ClampToByte(SARLongint((((128 shl 18)-(38704*SrcR))-(75984*SrcG))+(114688*SrcB),18));
    TpvUInt8(PlaneV^):=ClampToByte(SARLongint((((128 shl 18)+(114688*SrcR))-(96037*SrcG))-(18651*SrcB),18));}
    inc(PlaneU);
    inc(PlaneV);
    TempSrc:=pointer(@TempSrc^[2]);
   end;
  end;
 end;
end;

procedure EncodeI444(RGB,I444:pointer;VideoWidth,VideoHeight:TpvInt32);
type PLongwords=^TLongwords;
     TLongwords=array[0..65535] of TpvUInt32;
var Src,TempSrc:PLongwords;
    x,y,PlaneSize:TpvInt32;
    Pixel,SrcR,SrcG,SrcB:TpvUInt32;
    PlaneY,PlaneU,PlaneV:pansichar;
begin
 PlaneSize:=VideoWidth*VideoHeight;
 PlaneY:=I444;
 PlaneU:=pointer(@pansichar(I444)[PlaneSize]);
 PlaneV:=pointer(@pansichar(I444)[PlaneSize shl 1]);
 Src:=RGB;
 for y:=0 to VideoHeight-1 do begin
  TempSrc:=pointer(@Src[((VideoHeight-1)-y)*VideoWidth]);
  for x:=0 to VideoWidth-1 do begin
   Pixel:=TempSrc^[x];
   SrcR:=(Pixel shr 0) and $ff;
   SrcG:=(Pixel shr 8) and $ff;
   SrcB:=(Pixel shr 16) and $ff;
   TpvUInt8(PlaneY^):=ClampToByte(((16 shl 12)+(1052*SrcR)+(2065*SrcG)+(401*SrcB)) shr 12);
   TpvUInt8(PlaneU^):=ClampToByte(SARLongint((((128 shl 12)-(604*SrcR))-(1187*SrcG))+(1792*SrcB),12));
   TpvUInt8(PlaneV^):=ClampToByte(SARLongint((((128 shl 12)+(1792*SrcR))-(1501*SrcG))-(291*SrcB),12));
{  TpvUInt8(PlaneY^):=ClampToByte(((16 shl 16)+(16763*SrcR)+(32910*SrcG)+(6391*SrcB)) shr 16);
   TpvUInt8(PlaneU^):=ClampToByte(SARLongint((((128 shl 16)-(9676*SrcR))-(18996*SrcG))+(28672*SrcB),16));
   TpvUInt8(PlaneV^):=ClampToByte(SARLongint((((128 shl 16)+(28672*SrcR))-(24010*SrcG))-(4663*SrcB),16));}
   inc(PlaneY);
   inc(PlaneU);
   inc(PlaneV);
  end;
 end;
end;

procedure VerticalFlip(Pixels:pointer;VideoWidth,VideoHeight:TpvInt32); overload;
var x,y:TpvInt32;
    p0,p1:PpvUInt32;
    t:TpvUInt32;
begin
 p0:=Pixels;
 p1:=Pixels;
 inc(p1,VideoWidth*(VideoHeight-1));
 for y:=1 to VideoHeight div 2 do begin
  for x:=1 to VideoWidth do begin
   t:=p0^;
   p0^:=p1^;
   p1^:=t;
   inc(p0);
   inc(p1);
  end;
  dec(p1,VideoWidth shl 1);
 end;
end;

procedure VerticalFlip(Pixels,ToPixels:pointer;VideoWidth,VideoHeight:TpvInt32); overload;
var y:TpvInt32;
    p0,p1:PpvUInt32;
begin
 p0:=Pixels;
 p1:=ToPixels;
 inc(p1,VideoWidth*(VideoHeight-1));
 for y:=1 to VideoHeight do begin
  Move(p0^,p1^,VideoWidth shl 2);
  inc(p0,VideoWidth);
  dec(p1,VideoWidth);
 end;
end;

procedure RGBtoBGR(Pixels:pointer;VideoWidth,VideoHeight:TpvInt32);
var Counter:TpvInt32;
    Pixel:pansichar;
    t:ansichar;
begin
 Pixel:=Pixels;
 for Counter:=1 to VideoWidth*VideoHeight do begin
  t:=Pixel[0];
  Pixel[0]:=Pixel[2];
  Pixel[2]:=t;
  inc(Pixel,4);
 end;
end;

procedure RGBAtoBGR(Pixels:pointer;VideoWidth,VideoHeight:TpvInt32);
var Counter:TpvInt32;
    ip,op:pansichar;
    p:array[0..2] of ansichar;
begin
 ip:=Pixels;
 op:=Pixels;
 for Counter:=1 to VideoWidth*VideoHeight do begin
  p[0]:=ip[0];
  p[1]:=ip[1];
  p[2]:=ip[2];
  op[0]:=p[2];
  op[1]:=p[1];
  op[2]:=p[0];
  inc(ip,4);
  inc(op,3);
 end;
end;

procedure RGBAtoRGB(Pixels:pointer;VideoWidth,VideoHeight:TpvInt32);
var Counter:TpvInt32;
    ip,op:pansichar;
begin
 ip:=Pixels;
 op:=Pixels;
 for Counter:=1 to VideoWidth*VideoHeight do begin
  op[0]:=ip[0];
  op[1]:=ip[1];
  op[2]:=ip[2];
  inc(ip,4);
  inc(op,3);
 end;
end;

constructor TpvAVIWriter.Create(aStream:TStream;aDoFree:longbool;aVideoCodec:TpvUInt32;aVideoWidth,aVideoHeight,aVideoFPS,aSoundSampleRate,aSoundChannels,aSoundBits:TpvInt32;aQuality:TpvInt32=95;aFast:boolean=false;aChromaSubsampling:TpvInt32=-1);
var Counter,GCDValue:TpvInt32;
    AVIH:TAVIH;
    STRH:TSTRH;
    BitmapInfoHeader:TBitmapInfoHeader;
    INDX:TINDX;
    INDXEntry:TINDXEntry;
    VPRP:TVPRP;
    WaveFormatEx:TWaveFormatEx;
begin
 inherited Create;
 fXCache:=nil;
 fStream:=aStream;
 fDoFree:=aDoFree;
 fQuality:=aQuality;
 if fQuality<1 then begin
  fQuality:=1;
 end else if fQuality>100 then begin
  fQuality:=100;
 end;
 fFast:=aFast;
 fChromaSubsampling:=aChromaSubsampling;
 fCompressed:=nil;
 fRGB:=nil;
 fRGB2:=nil;
 fJPEGEncoder:=nil;
 begin
  fTurboJpegLibrary:=LoadLibrary({$ifdef Windows}'turbojpeg.dll'{$else}'libturbojpeg.so'{$endif});
  if fTurboJpegLibrary<>pvAVINilLibHandle then begin
   ftjInitCompress:=GetProcAddress(fTurboJpegLibrary,'tjInitCompress');
   ftjDestroy:=GetProcAddress(fTurboJpegLibrary,'tjDestroy');
   ftjAlloc:=GetProcAddress(fTurboJpegLibrary,'tjAlloc');
   ftjFree:=GetProcAddress(fTurboJpegLibrary,'tjFree');
   ftjCompress2:=GetProcAddress(fTurboJpegLibrary,'tjCompress2');
  end;
 end;
 fVideoFrames:=0;
 fVideoWidth:=aVideoWidth and not 1;
 fVideoHeight:=aVideoHeight and not 1;
 fVideoFPS:=aVideoFPS;
 fVideoCodec:=aVideoCodec;
 case fVideoCodec of
  vcI420:begin
   fVideoFrameSize:=(fVideoWidth*fVideoHeight)+(((fVideoWidth div 2)*(fVideoHeight div 2))*2);
  end;
  vcMJPG:begin
   fVideoFrameSize:=(fVideoWidth*fVideoHeight)*3;
   fJPEGEncoder:=TpvJPEGEncoder.Create;
  end;
  vcX264_420,vcX264_444:begin
   fVideoFrameSize:=(fVideoWidth*fVideoHeight)*4;
{$ifdef PasVulkanUseX264}
   if x264_param_default_preset(@fX264Param,'medium',nil)<0 then begin
    raise EpvAVIWriter.Create('x264_param_default_preset failed');
   end;
   fX264Param.i_threads:=X264_THREADS_AUTO;
   case fVideoCodec of
    vcX264_420:begin
     fX264Param.i_csp:=X264_CSP_I420;
    end;
    vcX264_444:begin
     fX264Param.i_csp:=X264_CSP_I444;
{    fX264Param.rc.i_rc_method:=X264_RC_CRF;
     fX264Param.rc.f_rf_constant:=0.0;}
    end;
    else begin
     fX264Param.i_csp:=X264_CSP_BGRA;
    end;
   end;

   fX264Param.i_width:=fVideoWidth;
   fX264Param.i_height:=fVideoHeight;
   fX264Param.i_fps_num:=fVideoFPS;
   fX264Param.i_fps_den:=1;
// fX264Param.i_log_level:=X264_LOG_ERROR;

   fX264Param.i_keyint_max:=Max(1,fX264Param.i_fps_num div (4*fX264Param.i_fps_den));
 //fX264Param.i_frame_reference:=1;
   fX264Param.b_intra_refresh:=1;

   fX264Param.rc.i_rc_method:=X264_RC_CRF;
   fX264Param.rc.f_rf_constant:=18.0;
// fX264Param.rc.f_rf_constant_max:=20.0;

   fX264Param.b_vfr_input:=0;
   fX264Param.b_repeat_headers:=1;
   fX264Param.b_annexb:=1;

   case fX264Param.i_csp of
    X264_CSP_I444,X264_CSP_YV24,X264_CSP_RGB,X264_CSP_BGR,X264_CSP_BGRA:begin
     if x264_param_apply_profile(@fX264Param,'high444')<0 then begin
      raise EpvAVIWriter.Create('x264_param_apply_profile failed');
     end;
    end;
    X264_CSP_I422,X264_CSP_YV16,X264_CSP_NV16,X264_CSP_V210:begin
     if x264_param_apply_profile(@fX264Param,'high422')<0 then begin
      raise EpvAVIWriter.Create('x264_param_apply_profile failed');
     end;
    end;
    else begin
     if x264_param_apply_profile(@fX264Param,'high')<0 then begin
      raise EpvAVIWriter.Create('x264_param_apply_profile failed');
     end;
    end;
   end;
   if x264_picture_alloc(@fX264Pic,fX264Param.i_csp,fX264Param.i_width,fX264Param.i_height)<0 then begin
    raise EpvAVIWriter.Create('x264_picture_alloc failed');
   end;
   fX264Handle:=x264_encoder_open(@fX264Param);
   if not assigned(fX264Handle) then begin
    raise EpvAVIWriter.Create('x264_encoder_open failed');
   end;
{$else}
   Assert(false,'X264 support not compiled in');
{$endif}
  end;
  else begin
   fVideoFrameSize:=(fVideoWidth*fVideoHeight) shl 2;
  end;
 end;
 fMaxCompressedSize:=fVideoWidth*fVideoHeight*8;
 GetMem(fCompressed,fMaxCompressedSize);
 GetMem(fRGB,fVideoWidth*fVideoHeight*4);
 GetMem(fRGB2,fVideoWidth*fVideoHeight*4);
 fSoundSampleRate:=aSoundSampleRate;
 fSoundChannels:=aSoundChannels;
 fSoundBits:=aSoundBits;
 fIndexEntries:=TList.Create;
 fSegmentInfos:=TList.Create;
 fFileFramesOffset:=0;
 fFileExtFramesOffset:=0;
 fFileVideoOffset:=0;
 fFileSoundOffset:=0;
 fSuperIndexVideoOffset:=0;
 fSuperIndexSoundOffset:=0;
 fChunkDepth:=-1;

 ListChunk('RIFF','AVI ');
 ListChunk('LIST','hdrl');

 StartChunk('avih',SizeOf(TAVIH));
 FillChar(AVIH,SizeOf(TAVIH),AnsiChar(#0));
 AVIH.dwMicroSecPerFrame:=1000000 div fVideoFPS;
 AVIH.dwMaxBytesPerSec:=0;
 AVIH.dwPaddingGranularity:=0;
 AVIH.dwFlags:=$10{Index} or $20{mustuseindex};
 fFileFramesOffset:=fStream.Position+TpvPtrInt(TpvPtrInt(pointer(@AVIH.dwTotalFrames))-TpvPtrInt(pointer(@AVIH)));
 AVIH.dwTotalFrames:=0;
 AVIH.dwInitialFrames:=0;
 if fSoundSampleRate>0 then begin
  AVIH.dwStreams:=2;
 end else begin
  AVIH.dwStreams:=1;
 end;
 AVIH.dwSuggestedBufferSize:=0;
 AVIH.dwWidth:=fVideoWidth;
 AVIH.dwHeight:=fVideoHeight;
 fStream.Write(AVIH,SizeOf(TAVIH));
 EndChunk;

 ListChunk('LIST','strl');

 StartChunk('strh',SizeOf(TSTRH));
 FillChar(STRH,SizeOf(TSTRH),AnsiChar(#0));
 STRH.fccType:='vids';
 case fVideoCodec of
  vcI420:begin
   STRH.fccHandler:='I420';
  end;
  vcMJPG:begin
   STRH.fccHandler:='MJPG';
  end;
  else begin
   STRH.fccHandler:='RGB2';
  end;
 end;
 STRH.dwFlags:=0;
 STRH.wPriority:=0;
 STRH.wLanguage:=0;
 STRH.dwInitialFrames:=0;
 STRH.dwScale:=1;
 STRH.dwRate:=fVideoFPS;
 STRH.dwStart:=0;
 fFileVideoOffset:=fStream.Position+TpvPtrInt(TpvPtrInt(pointer(@STRH.dwLength))-TpvPtrInt(pointer(@STRH)));
 STRH.dwLength:=0;
 case fVideoCodec of
  vcMJPG:begin
   STRH.dwSuggestedBufferSize:=1048576;
   STRH.dwQuality:=$ffffffff;
  end;
  else begin
   STRH.dwSuggestedBufferSize:=fVideoFrameSize;
   STRH.dwQuality:=0;
  end;
 end;
 STRH.dwSampleSize:=0;
 STRH.rcFrame.Left:=0;
 STRH.rcFrame.Top:=0;
 STRH.rcFrame.Right:=fVideoWidth;
 STRH.rcFrame.Bottom:=fVideoHeight;
 fStream.Write(STRH,SizeOf(TSTRH));
 EndChunk;

 StartChunk('strf',SizeOf(TBitmapInfoHeader));
 FillChar(BitmapInfoHeader,SizeOf(TBitmapInfoHeader),AnsiChar(#0));
 BitmapInfoHeader.biSize:=SizeOf(TBitmapInfoHeader);
 BitmapInfoHeader.biWidth:=fVideoWidth;
 BitmapInfoHeader.biHeight:=fVideoHeight;
 case fVideoCodec of
  vcI420:begin
   BitmapInfoHeader.biPlanes:=3;
   BitmapInfoHeader.biBitCount:=12;
   BitmapInfoHeader.biCompression:='I420';
  end;
  vcMJPG:begin
   BitmapInfoHeader.biPlanes:=1;
   BitmapInfoHeader.biBitCount:=24;
   BitmapInfoHeader.biCompression:='MJPG';
  end;
  vcX264_420,vcX264_444:begin
   BitmapInfoHeader.biPlanes:=1;
   BitmapInfoHeader.biBitCount:=24;
   BitmapInfoHeader.biCompression:='H264';
  end;
  else begin
   BitmapInfoHeader.biPlanes:=1;
   BitmapInfoHeader.biBitCount:=32;
   BitmapInfoHeader.biCompression:=#$00#$00#$00#$00;
  end;
 end;
 BitmapInfoHeader.biSizeImage:=fVideoFrameSize;
 BitmapInfoHeader.biXPelsPerMeter:=0;
 BitmapInfoHeader.biYPelsPerMeter:=0;
 BitmapInfoHeader.biClrUsed:=0;
 BitmapInfoHeader.biClrImportant:=0;
 fStream.Write(BitmapInfoHeader,SizeOf(TBitmapInfoHeader));
 EndChunk;

 StartChunk('indx',SizeOf(TINDX)+(MaxSuperIndex*SizeOf(TINDXEntry)));
 fSuperIndexVideoOffset:=fStream.Position;
 FillChar(INDX,SizeOf(TINDX),AnsiChar(#0));
 INDX.wLongsPerEntry:=4;
 INDX.bIndexSubType:=0;
 INDX.bIndexType:=0;
 INDX.nEntriesInUse:=0;
 if fVideoCodec=vcRGB2 then begin
  INDX.dwChunkId:='00db';
 end else begin
  INDX.dwChunkId:='00dc';
 end;
 INDX.dwReserved[0]:=0;
 INDX.dwReserved[1]:=0;
 INDX.dwReserved[2]:=0;
 fStream.Write(INDX,SizeOf(TINDX));
 FillChar(INDXEntry,SizeOf(TINDXEntry),AnsiChar(#0));
 for Counter:=1 to MaxSuperIndex do begin
  fStream.Write(INDXEntry,SizeOf(TINDXEntry));
 end;
 EndChunk;

 StartChunk('vprp',SizeOf(TVPRP));
 FillChar(VPRP,SizeOf(TVPRP),AnsiChar(#0));
 VPRP.dwVideoFormat:=0;
 VPRP.dwVideoStandard:=0;
 VPRP.dwVerticalRefreshRate:=fVideoFPS;
 VPRP.dwHorizontalTotal:=fVideoWidth;
 VPRP.dwVerticalTotal:=fVideoHeight;
 GCDValue:=GCD(fVideoWidth,fVideoHeight);
 VPRP.wAspectDenominator:=fVideoHeight div TpvUInt32(GCDValue);
 VPRP.wAspectNumerator:=fVideoWidth div TpvUInt32(GCDValue);
 VPRP.dwFrameWidth:=fVideoWidth;
 VPRP.dwFrameHeight:=fVideoHeight;
 VPRP.dwFieldsPerFrame:=1;
 VPRP.dwCompressedBitmapWidth:=fVideoWidth;
 VPRP.dwCompressedBitmapHeight:=fVideoHeight;
 VPRP.dwValidBitmapWidth:=fVideoWidth;
 VPRP.dwValidBitmapHeight:=fVideoHeight;
 VPRP.dwValidBitmapXOffset:=0;
 VPRP.dwValidBitmapYOffset:=0;
 VPRP.dwVideoXOffset:=0;
 VPRP.dwVideoYOffset:=0;
 fStream.Write(VPRP,SizeOf(TVPRP));
 EndChunk;

 EndListChunk;

 if fSoundSampleRate>0 then begin

  ListChunk('LIST','strl');

  StartChunk('strh',SizeOf(TSTRH));
  FillChar(STRH,SizeOf(TSTRH),AnsiChar(#0));
  STRH.fccType:='auds';
  STRH.fccHandler:=#$01#$00#0#$00;
  STRH.dwFlags:=0;
  STRH.wPriority:=0;
  STRH.wLanguage:=0;
  STRH.dwInitialFrames:=0;
  STRH.dwScale:=1;
  STRH.dwRate:=fSoundSampleRate;
  STRH.dwStart:=0;
  fFileSoundOffset:=fStream.Position+TpvPtrInt(TpvPtrInt(pointer(@STRH.dwLength))-TpvPtrInt(pointer(@STRH)));
  STRH.dwLength:=0;
  STRH.dwSuggestedBufferSize:=((fSoundSampleRate*fSoundBits*fSoundChannels)+7) shr (3+1);
  STRH.dwQuality:=0;
  STRH.dwSampleSize:=((fSoundBits*fSoundChannels)+7) shr 3;
  STRH.rcFrame.Left:=0;
  STRH.rcFrame.Top:=0;
  STRH.rcFrame.Right:=0;
  STRH.rcFrame.Bottom:=0;
  fStream.Write(STRH,SizeOf(TSTRH));
  EndChunk;

  StartChunk('strf',SizeOf(WaveFormatEx));
  FillChar(WaveFormatEx,SizeOf(WaveFormatEx),AnsiChar(#0));
  WaveFormatEx.wFormatTag:=1;
  WaveFormatEx.nChannels:=fSoundChannels;
  WaveFormatEx.nSamplesPerSec:=fSoundSampleRate;
  WaveFormatEx.nAvgBytesPerSec:=((fSoundSampleRate*fSoundBits*fSoundChannels)+7) shr 3;
  WaveFormatEx.nBlockAlign:=((fSoundBits*fSoundChannels)+7) shr 3;
  WaveFormatEx.wBitsPerSample:=fSoundBits;
  WaveFormatEx.cbSize:=0;
  fStream.Write(WaveFormatEx,SizeOf(WaveFormatEx));
  EndChunk;

  StartChunk('indx',SizeOf(TINDX)+(MaxSuperIndex*SizeOf(TINDXEntry)));
  fSuperIndexSoundOffset:=fStream.Position;
  FillChar(INDX,SizeOf(TINDX),AnsiChar(#0));
  INDX.wLongsPerEntry:=4;
  INDX.bIndexSubType:=0;
  INDX.bIndexType:=0;
  INDX.nEntriesInUse:=0;
  INDX.dwChunkId:='01wb';
  INDX.dwReserved[0]:=0;
  INDX.dwReserved[1]:=0;
  INDX.dwReserved[2]:=0;
  fStream.Write(INDX,SizeOf(TINDX));
  FillChar(INDXEntry,SizeOf(TINDXEntry),AnsiChar(#0));
  for Counter:=1 to MaxSuperIndex do begin
   fStream.Write(INDXEntry,SizeOf(TINDXEntry));
  end;
  EndChunk;

  EndListChunk;

 end;

 ListChunk('LIST','odml');
 StartChunk('dmlh',SizeOf(TpvUInt32));
 fFileExtFramesOffset:=fStream.Position;
 WriteUnsigned32Bit(0);
 EndChunk;
 EndListChunk;

 ListChunk('LIST','info');
 WriteChunk('ISTF',@ISTFData[1],length(ISTFData)*SizeOf(ansichar));
 EndListChunk;

 EndListChunk;

 NextSegment;

end;

destructor TpvAVIWriter.Destroy;
var Counter:TpvInt32;
    SoundIndices,VideoIndices{,SoundFrames,fVideoFrames{},IndexFrames:TpvUInt32;
    SegmentInfo:PpvAVISegmentInfo;
    IndexEntry:PpvAVIIndexEntry;
    INDX:TINDX;
    INDXEntry:TINDXEntry;
begin
 case fVideoCodec of
  vcX264_420,vcX264_444:begin
{$ifdef PasVulkanUseX264}
   if assigned(fX264Handle) then begin
    while x264_encoder_delayed_frames(fX264Handle)<>0 do begin
     WriteVideoFrame(nil,fVideoWidth,fVideoHeight,fVideoFrames);
    end;
   end;
{$else}
   Assert(false,'X264 support not compiled in');
{$endif}
  end;
 end;
 FlushSegment;
 SoundIndices:=0;
 VideoIndices:=0;
{SoundFrames:=0;
 fVideoFrames:=0;{}
 IndexFrames:=0;
 for Counter:=0 to fSegmentInfos.Count-1 do begin
  SegmentInfo:=fSegmentInfos[Counter];
  if assigned(SegmentInfo) then begin
   if SegmentInfo^.SoundIndexOffset<>0 then begin
    inc(SoundIndices);
   end;
   inc(VideoIndices);
{  inc(SoundFrames,SegmentInfo^.SoundFrames);
   inc(fVideoFrames,SegmentInfo^.VideoFrames);{}
   inc(IndexFrames,SegmentInfo^.IndexFrames);
  end;
 end;
 if fSegmentInfos.Count>0 then begin
  SegmentInfo:=fSegmentInfos[0];
  if assigned(SegmentInfo) then begin
   begin
    fStream.Seek(fFileFramesOffset,soBeginning);
    WriteUnsigned32Bit(SegmentInfo^.IndexFrames);
   end;
   begin
    fStream.Seek(fFileVideoOffset,soBeginning);
    WriteUnsigned32Bit(SegmentInfo^.VideoFrames);
   end;
   if SegmentInfo^.SoundFrames>0 then begin
    fStream.Seek(fFileSoundOffset,soBeginning);
    WriteUnsigned32Bit(SegmentInfo^.SoundFrames);
   end;
   begin
    fStream.Seek(fFileExtFramesOffset,soBeginning);
    WriteUnsigned32Bit(IndexFrames);
   end;                           
   begin
    fStream.Seek(fSuperIndexVideoOffset+TpvPtrInt(TpvPtrInt(pointer(@INDX.nEntriesInUse))-TpvPtrInt(pointer(@INDX))),soBeginning);
    WriteUnsigned32Bit(VideoIndices);
    fStream.Seek(fSuperIndexVideoOffset+SizeOf(TINDX),soBeginning);
    for Counter:=0 to fSegmentInfos.Count-1 do begin
     SegmentInfo:=fSegmentInfos[Counter];
     if assigned(SegmentInfo) then begin
      INDXEntry.dwOffsetLow:=SegmentInfo^.VideoIndexOffset and $ffffffff;
      INDXEntry.dwOffsetHigh:=(SegmentInfo^.VideoIndexOffset shr 32) and $ffffffff;
      INDXEntry.dwSize:=SegmentInfo^.VideoIndexSize;
      INDXEntry.dwDuration:=SegmentInfo^.IndexFrames;
      fStream.Write(INDXEntry,SizeOf(TINDXEntry));
     end;
    end;
   end;
   if SoundIndices>0 then begin
    fStream.Seek(fSuperIndexSoundOffset+TpvPtrInt(TpvPtrInt(pointer(@INDX.nEntriesInUse))-TpvPtrInt(pointer(@INDX))),soBeginning);
    WriteUnsigned32Bit(SoundIndices);
    fStream.Seek(fSuperIndexSoundOffset+SizeOf(TINDX),soBeginning);
    for Counter:=0 to fSegmentInfos.Count-1 do begin
     SegmentInfo:=fSegmentInfos[Counter];
     if assigned(SegmentInfo) then begin
      INDXEntry.dwOffsetLow:=SegmentInfo^.SoundIndexOffset and $ffffffff;
      INDXEntry.dwOffsetHigh:=(SegmentInfo^.SoundIndexOffset shr 32) and $ffffffff;
      INDXEntry.dwSize:=SegmentInfo^.SoundIndexSize;
      INDXEntry.dwDuration:=SegmentInfo^.SoundFrames;
      fStream.Write(INDXEntry,SizeOf(TINDXEntry));
     end;
    end;
   end;
   fStream.Seek(0,soEnd);
  end;
 end;
 for Counter:=0 to fIndexEntries.Count-1 do begin
  IndexEntry:=fIndexEntries[Counter];
  if assigned(IndexEntry) then begin
   FreeMem(IndexEntry);
  end;
 end;
 fIndexEntries.Free;
 for Counter:=0 to fSegmentInfos.Count-1 do begin
  SegmentInfo:=fSegmentInfos[Counter];
  if assigned(SegmentInfo) then begin
   FreeMem(SegmentInfo);
  end;
 end;
 fSegmentInfos.Free;
 if fDoFree then begin
  FreeAndNil(fStream);
 end;
 if assigned(fRGB) then begin
  FreeMem(fRGB);
 end;
 if assigned(fRGB2) then begin
  FreeMem(fRGB2);
 end;
 if assigned(fCompressed) then begin
  FreeMem(fCompressed);
 end;
 FreeAndNil(fJPEGEncoder);
 case fVideoCodec of
  vcX264_420,vcX264_444:begin
{$ifdef PasVulkanUseX264}
   if assigned(fX264Handle) then begin
    x264_encoder_close(fX264Handle);
   end;
   x264_picture_clean(@fX264Pic);
{$else}
   Assert(false,'X264 support not compiled in');
{$endif}
  end;
 end;
 SetLength(fXCache,0);
 if fTurboJpegLibrary<>pvAVINilLibHandle then begin
  FreeLibrary(fTurboJpegLibrary);
  fTurboJpegLibrary:=pvAVINilLibHandle;
 end;
 inherited Destroy;
end;

procedure TpvAVIWriter.WriteSigned8Bit(s8Bit:TpvInt8);
begin
 fStream.Write(s8Bit,SizeOf(TpvInt8));
end;

procedure TpvAVIWriter.WriteSigned16Bit(s16Bit:TpvInt16);
begin
 fStream.Write(s16Bit,SizeOf(TpvInt16));
end;

procedure TpvAVIWriter.WriteSigned32Bit(s32Bit:TpvInt32);
begin
 fStream.Write(s32Bit,SizeOf(TpvInt32));
end;

procedure TpvAVIWriter.WriteUnsigned8Bit(us8Bit:TpvUInt8);
begin
 fStream.Write(us8Bit,SizeOf(TpvUInt8));
end;

procedure TpvAVIWriter.WriteUnsigned16Bit(us16Bit:TpvUInt16);
begin
 fStream.Write(us16Bit,SizeOf(TpvUInt16));
end;

procedure TpvAVIWriter.WriteUnsigned32Bit(us32Bit:TpvUInt32);
begin
 fStream.Write(us32Bit,SizeOf(TpvUInt32));
end;

function TpvAVIWriter.AddIndex(aFrame,aType,aSize:TpvInt32):PpvAVIIndexEntry;
var Index:TpvInt32;
    SegmentInfo:PpvAVISegmentInfo;
    IndexEntry:PpvAVIIndexEntry;
begin
 SegmentInfo:=fSegmentInfos[fSegmentInfos.Count-1];
 Index:=fIndexEntries.Count;
 repeat
  dec(Index);
  if Index>=SegmentInfo.FirstIndex then begin
   IndexEntry:=fIndexEntries[Index];
   if (aFrame>IndexEntry^.Frame) or ((aFrame=IndexEntry^.Frame) and (aType<IndexEntry^.Type_)) then begin
    break;
   end;
  end else begin
   break;
  end;
 until false;
 New(result);
 FillChar(result^,SizeOf(TpvAVIIndexEntry),AnsiChar(#0));
 result^.Frame:=aFrame;
 result^.Type_:=aType;
 result^.Size:=aSize;
 result^.Offset:=fStream.Position-fChunkOffsets[fChunkDepth];
 fIndexEntries.Insert(Index+1,result);
end;

procedure TpvAVIWriter.StartChunk(const aChunkSignature:TpvAVIChunkSignature;aSize:TpvUInt32=0);
begin
 inc(fChunkDepth);
 fStream.Write(aChunkSignature,SizeOf(TpvAVIChunkSignature));
 fStream.Write(aSize,SizeOf(TpvUInt32));
 fChunkOffsets[fChunkDepth]:=fStream.Position;
end;

procedure TpvAVIWriter.ListChunk(const aChunkSignature,aListChunkSignature:TpvAVIChunkSignature);
begin
 StartChunk(aChunkSignature);
 fStream.Write(aListChunkSignature,SizeOf(TpvAVIChunkSignature));
end;

procedure TpvAVIWriter.EndChunk;
begin
 Assert(fChunkDepth>=0);
 dec(fChunkDepth);
end;

procedure TpvAVIWriter.EndListChunk;
var Size:TpvInt64;
    Size32Bit:TpvUInt32;
    Dummy:TpvUInt8;
begin
 Assert(fChunkDepth>=0);
 Size:=fStream.Position-fChunkOffsets[fChunkDepth];
 fStream.Seek(fChunkOffsets[fChunkDepth]-SizeOf(TpvUInt32),soBeginning);
 Size32Bit:=Size;
 fStream.Write(Size32Bit,SizeOf(TpvUInt32));
 fStream.Seek(0,soEnd);
 if (Size and 1)<>0 then begin
  Dummy:=0;
  fStream.Write(Dummy,SizeOf(TpvUInt8));
 end;
 EndChunk;
end;

procedure TpvAVIWriter.WriteChunk(const aChunkSignature:TpvAVIChunkSignature;aData:pointer;aSize:TpvUInt32);
begin
 fStream.Write(aChunkSignature,SizeOf(TpvAVIChunkSignature));
 fStream.Write(aSize,SizeOf(TpvUInt32));
 if aSize>0 then begin
  fStream.Write(aData^,aSize);
 end;
end;

procedure TpvAVIWriter.FlushSegment;
var Index:TpvInt32;
    IndexFrames,VideoFrames,SoundFrames:TpvInt32;
    SegmentInfo:PpvAVISegmentInfo;
    IndexEntry:PpvAVIIndexEntry;
    ChunkSignature:TpvAVIChunkSignature;
begin
 EndListChunk;

 SegmentInfo:=fSegmentInfos[fSegmentInfos.Count-1];

 IndexFrames:=0;
 VideoFrames:=0;
 SoundFrames:=0;
 for Index:=SegmentInfo^.FirstIndex to fIndexEntries.Count-1 do begin
  IndexEntry:=fIndexEntries[Index];
  if IndexEntry^.Type_<>0 then begin
   inc(SoundFrames);
  end else begin
   if (Index=SegmentInfo^.FirstIndex) or (PpvAVIIndexEntry(fIndexEntries[Index-1])^.Offset<>IndexEntry^.Offset) then begin
    inc(VideoFrames);
   end;
   inc(IndexFrames);
  end;
 end;

 SegmentInfo^.IndexFrames:=IndexFrames;

 if fSegmentInfos.Count=1 then begin
  StartChunk('idx1',fIndexEntries.Count*16);
  for Index:=0 to fIndexEntries.Count-1 do begin
   IndexEntry:=fIndexEntries[Index];
   if IndexEntry^.Type_<>0 then begin
    ChunkSignature:='01wb';
   end else begin
    if fVideoCodec=vcRGB2 then begin
     ChunkSignature:='00db';
    end else begin
     ChunkSignature:='00dc';
    end;
   end;
   fStream.Write(ChunkSignature,SizeOf(TpvAVIChunkSignature));
   WriteUnsigned32Bit($00000010);
   WriteUnsigned32Bit(IndexEntry^.Offset);
   WriteUnsigned32Bit(IndexEntry^.Size);
  end;
  EndChunk;
 end;

 SegmentInfo^.VideoFrames:=VideoFrames;
 SegmentInfo^.VideoIndexOffset:=fStream.Position;
 StartChunk('ix00',24+(IndexFrames*8));
 WriteUnsigned16Bit(2);
 WriteUnsigned16Bit($0100);
 WriteUnsigned32Bit(IndexFrames);
 if fVideoCodec=vcRGB2 then begin
  ChunkSignature:='00db';
 end else begin
  ChunkSignature:='00dc';
 end;
 fStream.Write(ChunkSignature,SizeOf(TpvAVIChunkSignature));
 WriteUnsigned32Bit(SegmentInfo^.Offset and $ffffffff);
 WriteUnsigned32Bit((SegmentInfo^.Offset shr 32) and $ffffffff);
 WriteUnsigned32Bit(0);
 for Index:=SegmentInfo^.FirstIndex to fIndexEntries.Count-1 do begin
  IndexEntry:=fIndexEntries[Index];
  if IndexEntry^.Type_=0 then begin
   WriteUnsigned32Bit(IndexEntry^.Offset+8);
   WriteUnsigned32Bit(IndexEntry^.Size);
  end;
 end;
 EndChunk;
 SegmentInfo^.VideoIndexSize:=fStream.Position-SegmentInfo^.VideoIndexOffset;

 if SoundFrames<>0 then begin
  SegmentInfo^.SoundFrames:=SoundFrames;
  SegmentInfo^.SoundIndexOffset:=fStream.Position;
  StartChunk('ix01',24+(SoundFrames*8));
  WriteUnsigned16Bit(2);
  WriteUnsigned16Bit($0100);
  WriteUnsigned32Bit(SoundFrames);
  ChunkSignature:='01wb';
  fStream.Write(ChunkSignature,SizeOf(TpvAVIChunkSignature));
  WriteUnsigned32Bit(SegmentInfo^.Offset and $ffffffff);
  WriteUnsigned32Bit((SegmentInfo^.Offset shr 32) and $ffffffff);
  WriteUnsigned32Bit(0);
  for Index:=SegmentInfo^.FirstIndex to fIndexEntries.Count-1 do begin
   IndexEntry:=fIndexEntries[Index];
   if IndexEntry^.Type_<>0 then begin
    WriteUnsigned32Bit(IndexEntry^.Offset+8);
    WriteUnsigned32Bit(IndexEntry^.Size);
   end;
  end;
  EndChunk;
  SegmentInfo^.SoundIndexSize:=fStream.Position-SegmentInfo^.SoundIndexOffset;
 end;

 EndListChunk;
end;

function TpvAVIWriter.NextSegment:boolean;
var SegmentInfo:PpvAVISegmentInfo;
begin
 result:=false;
 if fSegmentInfos.Count<>0 then begin
  if fSegmentInfos.Count>=MaxSuperIndex then begin
   exit;
  end;
  FlushSegment;
  ListChunk('RIFF','AVIX');
 end;
 ListChunk('LIST','movi');
 New(SegmentInfo);
 FillChar(SegmentInfo^,SizeOf(TpvAVISegmentInfo),AnsiChar(#0));
 SegmentInfo^.Offset:=fChunkOffsets[fChunkDepth];
 SegmentInfo^.FirstIndex:=fIndexEntries.Count;
 fSegmentInfos.Add(SegmentInfo);
 result:=true;
end;

function TpvAVIWriter.WriteVideoFrame(aPixels:pointer;aWidth,aHeight:TpvUInt32;aFrame:TpvUInt32):boolean;
const TJPF_RGB=0;
      TJPF_BGR=1;
      TJPF_RGBX=2;
      TJPF_BGRX=3;
      TJPF_XBGR=4;
      TJPF_XRGB=5;
      TJPF_GRAY=6;
      TJPF_RGBA=7;
      TJPF_BGRA=8;
      TJPF_ABGR=9;
      TJPF_ARGB=10;
      TJPF_CMYK=11;
      TJSAMP_444=0;
      TJSAMP_422=1;
      TJSAMP_420=2;
      TJSAMP_GRAY=3;
      TJSAMP_440=4;
      TJSAMP_411=5;
      TJFLAG_BGR=1;
      TJFLAG_BOTTOMUP=2;
      TJFLAG_FORCEMMX=8;
      TJFLAG_FORCESSE=16;
      TJFLAG_FORCESSE2=32;
      TJFLAG_ALPHAFIRST=64;
      TJFLAG_FORCESSE3=128;
      TJFLAG_FASTUPSAMPLE=256;
      TJFLAG_NOREALLOC=1024;
      TJFLAG_FASTDCT=2048;
      TJFLAG_ACCURATEDCT=4096;
var LocalVideoFrameSize{$ifdef PasVulkanUseX264},y{$endif},BlockEncodingMode:TpvInt32;
    LocalCompressed,tjCompressed,tjHandle,LocalCompressedAndFree:pointer;
    tjCompressedSize:TpvUInt32;
begin
 result:=false;
 if aFrame<fVideoFrames then begin
  result:=true;
  exit;
 end;
 if (aWidth<>fVideoWidth) or (aHeight<>fVideoHeight) then begin
  if assigned(aPixels) then begin
   ResizeRGB32(aPixels,aWidth,aHeight,fRGB,fVideoWidth,fVideoHeight,fXCache);
   aPixels:=fRGB;
  end;
 end;
 LocalVideoFrameSize:=fVideoFrameSize;
 LocalCompressed:=nil;
 LocalCompressedAndFree:=nil;
 case fVideoCodec of
  vcI420:begin
   if assigned(aPixels) then begin
    EncodeI420(aPixels,fCompressed,fVideoWidth,fVideoHeight);
   end;
  end;
  vcMJPG:begin
   if assigned(aPixels) then begin
    LocalVideoFrameSize:=0;
    if fTurboJpegLibrary<>pvAVINilLibHandle then begin
     tjHandle:=ftjInitCompress;
     if assigned(tjHandle) then begin
      try
       tjCompressed:=nil;
       try
        tjCompressedSize:=0;
        case fChromaSubsampling of
         0:begin
          BlockEncodingMode:=TJSAMP_444; // H1V1 4:4:4 (common for the most high-end digital cameras and professional image editing software)
         end;
         1:begin
          BlockEncodingMode:=TJSAMP_422; // H2V1 4:2:2 (common for the most mid-range digital cameras and consumer image editing software)
         end;
         2:begin
          BlockEncodingMode:=TJSAMP_420; // H2V2 4:2:0 (common for the most cheap digital cameras and other cheap stuff)
         end;
         else {-1:}begin
          if fQuality>=95 then begin
           BlockEncodingMode:=TJSAMP_444; // H1V1 4:4:4 (common for the most high-end digital cameras and professional image editing software)
          end else if fQuality>=50 then begin
           BlockEncodingMode:=TJSAMP_422; // H2V1 4:2:2 (common for the most mid-range digital cameras and consumer image editing software)
          end else begin
           BlockEncodingMode:=TJSAMP_420; // H2V2 4:2:0 (common for the most cheap digital cameras and other cheap stuff)
          end;
         end;
        end;
{       VerticalFlip(aPixels,
                     fRGB2,
                     fVideoWidth,
                     fVideoHeight);}
        ftjCompress2(tjHandle,
                     aPixels,//fRGB2,
                     fVideoWidth,
                     0,
                     fVideoHeight,
                     TJPF_RGBX,
                     tjCompressed,
                     tjCompressedSize,
                     BlockEncodingMode,
                     fQuality,
                     IfThen(fFast,TJFLAG_FASTDCT,TJFLAG_ACCURATEDCT)
                    );
        if assigned(tjCompressed) and (tjCompressedSize>0) then begin
         if tjCompressedSize<fMaxCompressedSize then begin
          Move(tjCompressed^,fCompressed^,tjCompressedSize);
         end else begin
          GetMem(LocalCompressedAndFree,tjCompressedSize);
          Move(tjCompressed^,LocalCompressedAndFree^,tjCompressedSize);
         end;
         LocalVideoFrameSize:=tjCompressedSize;
        end;
       finally
        if assigned(tjCompressed) then begin
         ftjFree(tjCompressed);
        end;
       end;
      finally
       ftjDestroy(tjHandle);
      end;
     end;
    end;
    if LocalVideoFrameSize=0 then begin
     LocalVideoFrameSize:=fJPEGEncoder.Encode(aPixels,fCompressed,fVideoWidth,fVideoHeight,fQuality,fMaxCompressedSize,fFast,fChromaSubsampling,false);
    end;
   end else begin
    LocalVideoFrameSize:=0;
   end;
  end;
  vcX264_420,vcX264_444:begin
{$ifdef PasVulkanUseX264}
   if assigned(Pixels) then begin
    case fX264Param.i_csp of
     X264_CSP_I420:begin
      EncodeI420(Pixels,Compressed,VideoWidth,VideoHeight);
      Move(PByteArray(Compressed)^[0],fX264Pic.img.plane[0]^,VideoWidth*VideoHeight);
      Move(PByteArray(Compressed)^[VideoWidth*VideoHeight],fX264Pic.img.plane[1]^,((VideoWidth*VideoHeight)+3) shr 2);
      Move(PByteArray(Compressed)^[(VideoWidth*VideoHeight)+(((VideoWidth*VideoHeight)+3) shr 2)],fX264Pic.img.plane[2]^,((VideoWidth*VideoHeight)+3) shr 2);
     end;
     X264_CSP_I444:begin
      EncodeI444(Pixels,Compressed,VideoWidth,VideoHeight);
      Move(PByteArray(Compressed)^[0],fX264Pic.img.plane[0]^,VideoWidth*VideoHeight);
      Move(PByteArray(Compressed)^[VideoWidth*VideoHeight],fX264Pic.img.plane[1]^,VideoWidth*VideoHeight);
      Move(PByteArray(Compressed)^[VideoWidth*VideoHeight*2],fX264Pic.img.plane[2]^,VideoWidth*VideoHeight);
     end;
     X264_CSP_RGB:begin
      RGBAtoRGB(Pixels,VideoWidth,VideoHeight);
      for y:=0 to VideoHeight-1 do begin
       Move(PByteArray(Pixels)^[VideoWidth*3*y],PByteArray(fX264Pic.img.plane[0])^[(VideoHeight-(y+1))*VideoWidth*3],VideoWidth*3);
      end;
     end;
     X264_CSP_BGR:begin
      RGBAtoBGR(Pixels,VideoWidth,VideoHeight);
      for y:=0 to VideoHeight-1 do begin
       Move(PByteArray(Pixels)^[VideoWidth*3*y],PByteArray(fX264Pic.img.plane[0])^[(VideoHeight-(y+1))*VideoWidth*3],VideoWidth*3);
      end;
     end;
     X264_CSP_BGRA:begin
      RGBtoBGR(Pixels,VideoWidth,VideoHeight);
      for y:=0 to VideoHeight-1 do begin
       Move(PByteArray(Pixels)^[VideoWidth*4*y],PByteArray(fX264Pic.img.plane[0])^[(VideoHeight-(y+1))*VideoWidth*4],VideoWidth*4);
      end;
     end;
    end;
    LocalVideoFrameSize:=x264_encoder_encode(fX264Handle,@fX264NAL,@fX264INAL,@fX264Pic,@fX264PicOut);
   end else begin
    LocalVideoFrameSize:=x264_encoder_encode(fX264Handle,@fX264NAL,@fX264INAL,nil,@fX264PicOut);
   end;
   if assigned(fX264NAL) and (LocalVideoFrameSize>0) then begin
    LocalCompressed:=pointer(fX264NAL^.p_payload);
   end else begin
    LocalVideoFrameSize:=0;
   end;
{$else}
   Assert(false,'X264 support not compiled in');
{$endif}
  end;
  else begin
   if assigned(aPixels) then begin
    RGBtoBGR(aPixels,fVideoWidth,fVideoHeight);
   end else begin
    LocalVideoFrameSize:=0;
   end;
  end;
 end;
 if (LocalVideoFrameSize=0) or not assigned(aPixels) then begin
  exit;
 end;
 if ((fStream.Position-PpvAVISegmentInfo(fSegmentInfos[fSegmentInfos.Count-1])^.Offset)+(LocalVideoFrameSize+8))>=$3ff00000{1000000000} then begin
  if not NextSegment then begin
   exit;
  end;
 end;
 while fVideoFrames<=aFrame do begin
  AddIndex(fVideoFrames,0,LocalVideoFrameSize);
  inc(fVideoFrames);
 end;
 if assigned(LocalCompressedAndFree) then begin
  if fVideoCodec=vcRGB2 then begin
   WriteChunk('00db',LocalCompressedAndFree,LocalVideoFrameSize);
  end else begin
   WriteChunk('00dc',LocalCompressedAndFree,LocalVideoFrameSize);
  end;
  FreeMem(LocalCompressedAndFree);
 end else begin
  case fVideoCodec of
   vcI420,vcMJPG:begin
    WriteChunk('00dc',fCompressed,LocalVideoFrameSize);
   end;
   vcX264_420,vcX264_444:begin
    WriteChunk('00dc',LocalCompressed,LocalVideoFrameSize);
   end;
   vcRGB2:begin
    WriteChunk('00db',aPixels,LocalVideoFrameSize);
   end;
   else begin
    WriteChunk('00dc',aPixels,LocalVideoFrameSize);
   end;
  end;
 end;
 result:=true;
end;

function TpvAVIWriter.WriteSoundFrame(aData:pointer;aFrameSize,aFrame:TpvUInt32):boolean;
begin
 result:=false;
 if ((fStream.Position-PpvAVISegmentInfo(fSegmentInfos[fSegmentInfos.Count-1])^.Offset)+(aFrameSize+8))>1000000000 then begin
  if not NextSegment then begin
   exit;
  end;
 end;
 AddIndex(aFrame,1,aFrameSize);
 WriteChunk('01wb',aData,aFrameSize);
 result:=true;
end;

end.
