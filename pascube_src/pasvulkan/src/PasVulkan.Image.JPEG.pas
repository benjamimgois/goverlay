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
unit PasVulkan.Image.JPEG;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(Darwin) or defined(CompileForWithPIC) or not defined(cpu386)}
 {$define PurePascal}
{$ifend}

interface

uses SysUtils,
     Classes,
     Math,
     {$ifdef fpc}
      FPImage,FPReadJPEG,FPWriteJPEG,
     {$endif}
     {$ifdef fpc}
      dynlibs,
     {$else}
      Windows,
     {$endif}
     PasVulkan.Types;

const JPEG_OUTPUT_BUFFER_SIZE=2048;

      JPEG_DC_LUMA_CODES=12;
      JPEG_AC_LUMA_CODES=256;
      JPEG_DC_CHROMA_CODES=12;
      JPEG_AC_CHROMA_CODES=256;

      JPEG_MAX_HUFFMAN_SYMBOLS=257;
      JPEG_MAX_HUFFMAN_CODE_SIZE=32;

type EpvLoadJPEGImage=class(Exception);

     PpvJPEGHuffmanSymbolFrequency=^TpvJPEGHuffmanSymbolFrequency;
     TpvJPEGHuffmanSymbolFrequency=record
      Key,Index:TpvUInt32;
     end;

     PpvJPEGHuffmanSymbolFrequencies=^TpvJPEGHuffmanSymbolFrequencies;
     TpvJPEGHuffmanSymbolFrequencies=array[0..65536] of TpvJPEGHuffmanSymbolFrequency;

     PpvJPEGEncoderInt8Array=^TpvJPEGEncoderUInt8Array;
     TpvJPEGEncoderInt8Array=array[0..65535] of TpvInt8;

     PpvJPEGEncoderUInt8Array=^TpvJPEGEncoderUInt8Array;
     TpvJPEGEncoderUInt8Array=array[0..65535] of TpvUInt8;

     PpvJPEGEncoderInt16Array=^TpvJPEGEncoderInt16Array;
     TpvJPEGEncoderInt16Array=array[0..65535] of TpvInt16;

     PpvJPEGEncoderUInt16Array=^TpvJPEGEncoderUInt16Array;
     TpvJPEGEncoderUInt16Array=array[0..65535] of TpvUInt16;

     PpvJPEGEncoderInt32Array=^TpvJPEGEncoderInt32Array;
     TpvJPEGEncoderInt32Array=array[0..65535] of TpvInt32;

     PpvJPEGEncoderUInt32Array=^TpvJPEGEncoderUInt32Array;
     TpvJPEGEncoderUInt32Array=array[0..65535] of TpvUInt32;

     TpvJPEGEncoder=class
      private
       fQuality:TpvInt32;
       fTwoPass:LongBool;
       fNoChromaDiscrimination:LongBool;
       fCountComponents:TpvInt32;
       fComponentHSamples:array[0..2] of TpvUInt8;
       fComponentVSamples:array[0..2] of TpvUInt8;
       fImageWidth:TpvInt32;
       fImageHeight:TpvInt32;
       fImageWidthMCU:TpvInt32;
       fImageHeightMCU:TpvInt32;
       fMCUsPerRow:TpvInt32;
       fMCUWidth:TpvInt32;
       fMCUHeight:TpvInt32;
       fMCUChannels:array[0..2] of PpvJPEGEncoderUInt8Array;
       fMCUYOffset:TpvInt32;
       fTempChannelWords:PpvJPEGEncoderUInt16Array;
       fTempChannelBytes:PpvJPEGEncoderUInt8Array;
       fTempChannelSize:TpvInt32;
       fSamples8Bit:array[0..63] of TpvUInt8;
       fSamples16Bit:array[0..63] of TpvInt16;
       fSamples32Bit:array[0..63] of TpvInt32;
       fCoefficients:array[0..63] of TpvInt16;
       fQuantizationTables:array[0..1,0..63] of TpvInt32;
       fHuffmanCodes:array[0..3,0..255] of TpvUInt32;
       fHuffmanCodeSizes:array[0..3,0..255] of TpvUInt8;
       fHuffmanBits:array[0..3,0..16] of TpvUInt8;
       fHuffmanValues:array[0..3,0..255] of TpvUInt8;
       fHuffmanCounts:array[0..3,0..255] of TpvUInt32;
       fLastDCValues:array[0..3] of TpvInt32;
       fOutputBuffer:array[0..JPEG_OUTPUT_BUFFER_SIZE-1] of TpvUInt8;
       fOutputBufferPointer:pbyte;
       fOutputBufferLeft:TpvUInt32;
       fOutputBufferCount:TpvUInt32;
       fBitsBuffer:TpvUInt32;
       fBitsBufferSize:TpvUInt32;
       fPassIndex:TpvInt32;
       fDataMemory:TpvPointer;
       fDataMemorySize:TpvUInt32;
       fCompressedData:TpvPointer;
       fCompressedDataPosition:TpvUInt32;
       fCompressedDataAllocated:TpvUInt32;
       fMaxCompressedDataSize:TpvUInt32;
       fBlockEncodingMode:TpvInt32;
       procedure EmitByte(b:TpvUInt8);
       procedure EmitWord(w:word);
       procedure EmitMarker(m:TpvUInt8);
       procedure EmitJFIFApp0;
       procedure EmitDQT;
       procedure EmitSOF;
       procedure EmitDHT(Bits,Values:pansichar;Index:TpvInt32;ACFlag:boolean);
       procedure EmitDHTs;
       procedure EmitSOS;
       procedure EmitMarkers;
       procedure ConvertRGBAToY(pDstY,pSrc:PpvJPEGEncoderUInt8Array;Count:TpvInt32); {$ifndef PurePascal}{$ifdef cpu386}stdcall;{$endif}{$endif}
       procedure ConvertRGBAToYCbCr(pDstY,pDstCb,pDstCr,pSrc:PpvJPEGEncoderUInt8Array;Count:TpvInt32); {$ifndef PurePascal}{$ifdef cpu386}stdcall;{$endif}{$endif}
       procedure ComputeHuffmanTable(Codes:PpvJPEGEncoderUInt32Array;CodeSizes,Bits,Values:PpvJPEGEncoderUInt8Array);
       function InitFirstPass:boolean;
       function InitSecondPass:boolean;
       procedure ComputeQuantizationTable(pDst:PpvJPEGEncoderInt32Array;pSrc:PpvJPEGEncoderInt16Array);
       function Setup(Width,Height:TpvInt32):boolean;
       procedure FlushOutputBuffer;
       procedure PutBits(Bits,Len:TpvUInt32);
       procedure LoadBlock8x8(x,y,c:TpvInt32);
       procedure LoadBlock16x8(x,c:TpvInt32);
       procedure LoadBlock16x8x8(x,c:TpvInt32);
       procedure DCT2D;
       procedure LoadQuantizedCoefficients(ComponentIndex:TpvInt32);
       procedure CodeCoefficientsPassOne(ComponentIndex:TpvInt32);
       procedure CodeCoefficientsPassTwo(ComponentIndex:TpvInt32);
       procedure CodeBlock(ComponentIndex:TpvInt32);
       procedure ProcessMCURow;
       procedure LoadMCU(p:TpvPointer);
       function RadixSortSymbols(CountSymbols:TpvUInt32;SymbolsA,SymbolsB:PpvJPEGHuffmanSymbolFrequencies):PpvJPEGHuffmanSymbolFrequency;
       procedure CalculateMinimumRedundancy(a:PpvJPEGHuffmanSymbolFrequencies;n:TpvInt32);
       procedure HuffmanEnforceMaxCodeSize(CountCodes:PpvJPEGEncoderInt32Array;CodeListLen,MaxCodeSize:TpvInt32);
       procedure OptimizeHuffmanTable(TableIndex,TableLen:TpvInt32);
       function TerminatePassOne:boolean;
       function TerminatePassTwo:boolean;
       function ProcessEndOfImage:boolean;
       function ProcessScanline(pScanline:TpvPointer):boolean;
      public
       constructor Create;
       destructor Destroy; override;
       function Encode(const FrameData:TpvPointer;var CompressedData:TpvPointer;Width,Height:TpvInt32;Quality,MaxCompressedDataSize:TpvUInt32;const Fast:boolean=false;const ChromaSubsampling:TpvInt32=-1;const aOwnCompressedData:Boolean=true):TpvUInt32;
     end;

function LoadJPEGImage(DataPointer:TpvPointer;DataSize:TpvUInt32;var ImageData:TpvPointer;var ImageWidth,ImageHeight:TpvInt32;const HeaderOnly:boolean):boolean;

function SaveJPEGImage(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;out aDestData:TpvPointer;out aDestDataSize:TpvUInt32;const aQuality:TpvInt32=99;const aFast:boolean=false;const aChromaSubsampling:TpvInt32=-1):boolean;

function SaveJPEGImageAsStream(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aStream:TStream;const aQuality:TpvInt32=99;const aFast:boolean=false;const aChromaSubsampling:TpvInt32=-1):boolean;

function SaveJPEGImageAsFile(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aFileName:string;const aQuality:TpvInt32=99;const aFast:boolean=false;const aChromaSubsampling:TpvInt32=-1):boolean;

implementation

const NilLibHandle={$ifdef fpc}NilHandle{$else}THandle(0){$endif};

var TurboJpegLibrary:{$ifdef fpc}TLibHandle{$else}THandle{$endif}=NilLibHandle;

type TtjInitCompress=function:pointer; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjInitDecompress=function:pointer; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjDestroy=function(handle:pointer):longint; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjAlloc=function(bytes:longint):pointer; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjFree=procedure(buffer:pointer); {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjCompress2=function(handle:pointer;
                           srcBuf:pointer;
                           width:longint;
                           pitch:longint;
                           height:longint;
                           pixelFormat:longint;
                           var jpegBuf:pointer;
                           var jpegSize:longword;
                           jpegSubsamp:longint;
                           jpegQual:longint;
                           flags:longint):longint; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjDecompressHeader=function(handle:pointer;
                                  jpegBuf:pointer;
                                  jpegSize:longword;
                                  out width:longint;
                                  out height:longint):longint; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjDecompressHeader2=function(handle:pointer;
                                   jpegBuf:pointer;
                                   jpegSize:longword;
                                   out width:longint;
                                   out height:longint;
                                   out jpegSubsamp:longint):longint; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjDecompressHeader3=function(handle:pointer;
                                   jpegBuf:pointer;
                                   jpegSize:longword;
                                   out width:longint;
                                   out height:longint;
                                   out jpegSubsamp:longint;
                                   out jpegColorSpace:longint):longint; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

     TtjDecompress2=function(handle:pointer;
                             jpegBuf:pointer;
                             jpegSize:longword;
                             dstBuf:pointer;
                             width:longint;
                             pitch:longint;
                             height:longint;
                             pixelFormat:longint;
                             flags:longint):longint; {$ifdef Windows}stdcall;{$else}cdecl;{$endif}

var tjInitCompress:TtjInitCompress=nil;
    tjInitDecompress:TtjInitDecompress=nil;
    tjDestroy:TtjDestroy=nil;
    tjAlloc:TtjAlloc=nil;
    tjFree:TtjFree=nil;
    tjCompress2:TtjCompress2=nil;
    tjDecompressHeader:TtjDecompressHeader=nil;
    tjDecompressHeader2:TtjDecompressHeader2=nil;
    tjDecompressHeader3:TtjDecompressHeader3=nil;
    tjDecompress2:TtjDecompress2=nil;

{$ifndef HasSAR}
function SARLongint(Value,Shift:TpvInt32):TpvInt32;
{$ifdef cpu386}
{$ifdef fpc} assembler; register; //inline;
asm
 mov ecx,edx
 sar eax,cl
end;// ['eax','edx','ecx'];
{$else} assembler; register;
asm
 mov ecx,edx
 sar eax,cl
end;
{$endif}
{$else}
{$ifdef cpuarm} assembler; //inline;
asm
 mov r0,r0,asr R1
end;// ['r0','R1'];
{$else}{$ifdef CAN_INLINE}inline;{$endif}
begin
 Shift:=Shift and 31;
 result:=(TpvUInt32(Value) shr Shift) or (TpvUInt32(TpvInt32(TpvUInt32(0-TpvUInt32(TpvUInt32(Value) shr 31)) and TpvUInt32(0-TpvUInt32(ord(Shift<>0) and 1)))) shl (32-Shift));
end;
{$endif}
{$endif}
{$endif}

function LoadJPEGImage(DataPointer:TpvPointer;DataSize:TpvUInt32;var ImageData:TpvPointer;var ImageWidth,ImageHeight:TpvInt32;const HeaderOnly:boolean):boolean;
{$ifdef fpc}
var Image:TFPMemoryImage;
    ReaderJPEG:TFPReaderJPEG;
    Stream:TMemoryStream;
    y,x:TpvInt32;
    c:TFPColor;
    pout:PAnsiChar;
    tjWidth,tjHeight,tjJpegSubsamp:TpvInt32;
    tjHandle:pointer;
begin
 result:=false;
 try
  Stream:=TMemoryStream.Create;
  try
   if (DataSize>2) and (((byte(PAnsiChar(pointer(DataPointer))[0]) xor $ff)=0) and ((byte(PAnsiChar(pointer(DataPointer))[1]) xor $d8)=0)) then begin
    if (TurboJpegLibrary<>NilLibHandle) and
       assigned(tjInitDecompress) and
       assigned(tjDecompressHeader2) and
       assigned(tjDecompress2) and
       assigned(tjDestroy) then begin
     tjHandle:=tjInitDecompress;
     if assigned(tjHandle) then begin
      try
       if tjDecompressHeader2(tjHandle,DataPointer,DataSize,tjWidth,tjHeight,tjJpegSubsamp)>=0 then begin
        ImageWidth:=tjWidth;
        ImageHeight:=tjHeight;
        if HeaderOnly then begin
         result:=true;
        end else begin
         GetMem(ImageData,ImageWidth*ImageHeight*SizeOf(longword));
         if tjDecompress2(tjHandle,DataPointer,DataSize,ImageData,tjWidth,0,tjHeight,7{TJPF_RGBA},2048{TJFLAG_FASTDCT})>=0 then begin
          result:=true;
         end else begin
          FreeMem(ImageData);
          ImageData:=nil;
         end;
        end;
       end;
      finally
       tjDestroy(tjHandle);
      end;
     end;
    end else begin
     if Stream.Write(DataPointer^,DataSize)=longint(DataSize) then begin
      if Stream.Seek(0,soFromBeginning)=0 then begin
       Image:=TFPMemoryImage.Create(20,20);
       try
        ReaderJPEG:=TFPReaderJPEG.Create;
        try
         Image.LoadFromStream(Stream,ReaderJPEG);
         ImageWidth:=Image.Width;
         ImageHeight:=Image.Height;
         GetMem(ImageData,ImageWidth*ImageHeight*4);
         pout:=ImageData;
         for y:=0 to ImageHeight-1 do begin
          for x:=0 to ImageWidth-1 do begin
           c:=Image.Colors[x,y];
           pout[0]:=ansichar(byte((c.red shr 8) and $ff));
           pout[1]:=ansichar(byte((c.green shr 8) and $ff));
           pout[2]:=ansichar(byte((c.blue shr 8) and $ff));
           pout[3]:=AnsiChar(#$ff);
           inc(pout,4);
          end;
         end;
         result:=true;
        finally
         ReaderJPEG.Free;
        end;
       finally
        Image.Free;
       end;
      end;
     end;
    end;
   end;
  finally
   Stream.Free;
  end;
 except
  result:=false;
 end;
end;
{$else}
type PIDCTInputBlock=^TIDCTInputBlock;
     TIDCTInputBlock=array[0..63] of TpvInt32;
     PIDCTOutputBlock=^TIDCTOutputBlock;
     TIDCTOutputBlock=array[0..65535] of TpvUInt8;
     PByteArray=^TByteArray;
     TByteArray=array[0..65535] of TpvUInt8;
     TPixels=array of TpvUInt8;
     PHuffmanCode=^THuffmanCode;
     THuffmanCode=record
      Bits:TpvUInt8;
      Code:TpvUInt8;
     end;
     PHuffmanCodes=^THuffmanCodes;
     THuffmanCodes=array[0..65535] of THuffmanCode;
     PComponent=^TComponent;
     TComponent=record
      Width:TpvInt32;
      Height:TpvInt32;
      Stride:TpvInt32;
      Pixels:TPixels;
      ID:TpvInt32;
      SSX:TpvInt32;
      SSY:TpvInt32;
      QTSel:TpvInt32;
      ACTabSel:TpvInt32;
      DCTabSel:TpvInt32;
      DCPred:TpvInt32;
     end;
     PContext=^TContext;
     TContext=record
      Valid:boolean;
      NoDecode:boolean;
      FastChroma:boolean;
      Len:TpvInt32;
      Size:TpvInt32;
      Width:TpvInt32;
      Height:TpvInt32;
      MBWidth:TpvInt32;
      MBHeight:TpvInt32;
      MBSizeX:TpvInt32;
      MBSizeY:TpvInt32;
      Components:array[0..2] of TComponent;
      CountComponents:TpvInt32;
      QTUsed:TpvInt32;
      QTAvailable:TpvInt32;
      QTable:array[0..3,0..63] of TpvUInt8;
      HuffmanCodeTable:array[0..3] of THuffmanCodes;
      Buf:TpvInt32;
      BufBits:TpvInt32;
      RSTInterval:TpvInt32;
      EXIFLE:boolean;
      CoSitedChroma:boolean;
      Block:TIDCTInputBlock;
     end;
const ZigZagOrderToRasterOrderConversionTable:array[0..63] of TpvUInt8=
       (
        0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,
        12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,
        35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,
        58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63
       );
      ClipTable:array[0..$3ff] of TpvUInt8=
       (
        // 0..255
        0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,
        32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,
        64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,
        96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,
        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,
        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,
        // 256..511
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
        255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
        // -512..-257
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        // -256..-1
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       );
      CF4A=-9;
      CF4B=111;
      CF4C=29;
      CF4D=-3;
      CF3A=28;
      CF3B=109;
      CF3C=-9;
      CF3X=104;
      CF3Y=27;
      CF3Z=-3;
      CF2A=139;
      CF2B=-11;
var Context:PContext;
    DataPosition:TpvUInt32;
 procedure RaiseError;
 begin
  raise EpvLoadJPEGImage.Create('Invalid or corrupt JPEG data stream');
 end;
 procedure ProcessIDCT(const aInputBlock:PIDCTInputBlock;const aOutputBlock:PIDCTOutputBlock;const aOutputStride:TpvInt32);
 const W1=2841;
       W2=2676;
       W3=2408;
       W5=1609;
       W6=1108;
       W7=565;
 var i,v0,v1,v2,v3,v4,v5,v6,v7,v8:TpvInt32;
     WorkBlock:PIDCTInputBlock;
     OutputBlock:PIDCTOutputBlock;
 begin
  for i:=0 to 7 do begin
   WorkBlock:=@aInputBlock^[i shl 3];
   v0:=WorkBlock^[0];
   v1:=WorkBlock^[4] shl 11;
   v2:=WorkBlock^[6];
   v3:=WorkBlock^[2];
   v4:=WorkBlock^[1];
   v5:=WorkBlock^[7];
   v6:=WorkBlock^[5];
   v7:=WorkBlock^[3];
   if (v1=0) and (v2=0) and (v3=0) and (v4=0) and (v5=0) and (v6=0) and (v7=0) then begin
    v0:=v0 shl 3;
    WorkBlock^[0]:=v0;
    WorkBlock^[1]:=v0;
    WorkBlock^[2]:=v0;
    WorkBlock^[3]:=v0;
    WorkBlock^[4]:=v0;
    WorkBlock^[5]:=v0;
    WorkBlock^[6]:=v0;
    WorkBlock^[7]:=v0;
   end else begin
    v0:=(v0 shl 11)+128;
    v8:=W7*(v4+v5);
    v4:=v8+((W1-W7)*v4);
    v5:=v8-((W1+W7)*v5);
    v8:=W3*(v6+v7);
    v6:=v8-((W3-W5)*v6);
    v7:=v8-((W3+W5)*v7);
    v8:=v0+v1;
    dec(v0,v1);
    v1:=W6*(v3+v2);
    v2:=v1-((W2+W6)*v2);
    v3:=v1+((W2-W6)*v3);
    v1:=v4+v6;
    dec(v4,v6);
    v6:=v5+v7;
    dec(v5,v7);
    v7:=v8+v3;
    dec(v8,v3);
    v3:=v0+v2;
    dec(v0,v2);
    v2:=SARLongint(((v4+v5)*181)+128,8);
    v4:=SARLongint(((v4-v5)*181)+128,8);
    WorkBlock^[0]:=SARLongint(v7+v1,8);
    WorkBlock^[1]:=SARLongint(v3+v2,8);
    WorkBlock^[2]:=SARLongint(v0+v4,8);
    WorkBlock^[3]:=SARLongint(v8+v6,8);
    WorkBlock^[4]:=SARLongint(v8-v6,8);
    WorkBlock^[5]:=SARLongint(v0-v4,8);
    WorkBlock^[6]:=SARLongint(v3-v2,8);
    WorkBlock^[7]:=SARLongint(v7-v1,8);
   end;
  end;
  for i:=0 to 7 do begin
   WorkBlock:=@aInputBlock^[i];
   v0:=WorkBlock^[0 shl 3];
   v1:=WorkBlock^[4 shl 3] shl 8;
   v2:=WorkBlock^[6 shl 3];
   v3:=WorkBlock^[2 shl 3];
   v4:=WorkBlock^[1 shl 3];
   v5:=WorkBlock^[7 shl 3];
   v6:=WorkBlock^[5 shl 3];
   v7:=WorkBlock^[3 shl 3];
   if (v1=0) and (v2=0) and (v3=0) and (v4=0) and (v5=0) and (v6=0) and (v7=0) then begin
    v0:=ClipTable[(SARLongint(v0+32,6)+128) and $3ff];
    OutputBlock:=@aOutputBlock^[i];
    OutputBlock^[aOutputStride*0]:=v0;
    OutputBlock^[aOutputStride*1]:=v0;
    OutputBlock^[aOutputStride*2]:=v0;
    OutputBlock^[aOutputStride*3]:=v0;
    OutputBlock^[aOutputStride*4]:=v0;
    OutputBlock^[aOutputStride*5]:=v0;
    OutputBlock^[aOutputStride*6]:=v0;
    OutputBlock^[aOutputStride*7]:=v0;
   end else begin
    v0:=(v0 shl 8)+8192;
    v8:=((v4+v5)*W7)+4;
    v4:=SARLongint(v8+((W1-W7)*v4),3);
    v5:=SARLongint(v8-((W1+W7)*v5),3);
    v8:=((v6+v7)*W3)+4;
    v6:=SARLongint(v8-((W3-W5)*v6),3);
    v7:=SARLongint(v8-((W3+W5)*v7),3);
    v8:=v0+v1;
    dec(v0,v1);
    v1:=((v3+v2)*w6)+4;
    v2:=SARLongint(v1-((W2+W6)*v2),3);
    v3:=SARLongint(v1+((W2-W6)*v3),3);
    v1:=v4+v6;
    dec(v4,v6);
    v6:=v5+v7;
    dec(v5,v7);
    v7:=v8+v3;
    dec(v8,v3);
    v3:=v0+v2;
    dec(v0,v2);
    v2:=SARLongint(((v4+v5)*181)+128,8);
    v4:=SARLongint(((v4-v5)*181)+128,8);
    OutputBlock:=@aOutputBlock^[i];
    OutputBlock^[aOutputStride*0]:=ClipTable[(SARLongint(v7+v1,14)+128) and $3ff];
    OutputBlock^[aOutputStride*1]:=ClipTable[(SARLongint(v3+v2,14)+128) and $3ff];
    OutputBlock^[aOutputStride*2]:=ClipTable[(SARLongint(v0+v4,14)+128) and $3ff];
    OutputBlock^[aOutputStride*3]:=ClipTable[(SARLongint(v8+v6,14)+128) and $3ff];
    OutputBlock^[aOutputStride*4]:=ClipTable[(SARLongint(v8-v6,14)+128) and $3ff];
    OutputBlock^[aOutputStride*5]:=ClipTable[(SARLongint(v0-v4,14)+128) and $3ff];
    OutputBlock^[aOutputStride*6]:=ClipTable[(SARLongint(v3-v2,14)+128) and $3ff];
    OutputBlock^[aOutputStride*7]:=ClipTable[(SARLongint(v7-v1,14)+128) and $3ff];
   end;
  end;
 end;
 function PeekBits(Bits:TpvInt32):TpvInt32;
 var NewByte,Marker:TpvInt32;
 begin
  if Bits>0 then begin
   while Context^.BufBits<Bits do begin
    if DataPosition>=DataSize then begin
     Context^.Buf:=(Context^.Buf shl 8) or $ff;
     inc(Context^.BufBits,8);
    end else begin
     NewByte:=PByteArray(DataPointer)^[DataPosition];
     inc(DataPosition);
     Context^.Buf:=(Context^.Buf shl 8) or NewByte;
     inc(Context^.BufBits,8);
     if NewByte=$ff then begin
      if DataPosition<DataSize then begin
       Marker:=PByteArray(DataPointer)^[DataPosition];
       inc(DataPosition);
       case Marker of
        $00,$ff:begin
        end;
        $d9:begin
         DataPosition:=DataSize;
        end;
        else begin
         if (Marker and $f8)=$d0 then begin
          Context^.Buf:=(Context^.Buf shl 8) or Marker;
          inc(Context^.BufBits,8);
         end else begin
          RaiseError;
         end;
        end;
       end;
      end else begin
       RaiseError;
      end;
     end;
    end;
   end;
   result:=(Context^.Buf shr (Context^.BufBits-Bits)) and ((1 shl Bits)-1);
  end else begin
   result:=0;
  end;
 end;
 procedure SkipBits(Bits:TpvInt32);
 begin
  if Context^.BufBits<Bits then begin
   PeekBits(Bits);
  end;
  dec(Context^.BufBits,Bits);
 end;
 function GetBits(Bits:TpvInt32):TpvInt32;
 begin
  result:=PeekBits(Bits);
  if Context^.BufBits<Bits then begin
   PeekBits(Bits);
  end;
  dec(Context^.BufBits,Bits);
 end;
 function GetHuffmanCode(const Huffman:PHuffmanCodes;const Code:PpvInt32):TpvInt32;
 var Bits:TpvInt32;
 begin
  result:=PeekBits(16);
  Bits:=Huffman^[result].Bits;
  if Bits=0 then begin
// writeln(result);
   RaiseError;
   result:=0;
  end else begin
   SkipBits(Bits);
   result:=Huffman^[result].Code;
   if assigned(Code) then begin
    Code^:=result and $ff;
   end;
   Bits:=result and $0f;
   if Bits=0 then begin
    result:=0;
   end else begin
    result:=GetBits(Bits);
    if result<(1 shl (Bits-1)) then begin
     inc(result,(TpvInt32(-1) shl Bits)+1);
    end;
   end;
  end;
 end;
 procedure UpsampleHCoSited(const Component:PComponent);
 var MaxX,x,y:TpvInt32;
     NewPixels:TPixels;
     ip,op:PByteArray;
 begin
  MaxX:=Component^.Width-1;
  NewPixels:=nil;
  try
   SetLength(NewPixels,(Component^.Width*Component^.Height) shl 1);
   ip:=@Component^.Pixels[0];
   op:=@NewPixels[0];
   for y:=0 to Component^.Height-1 do begin
    op^[0]:=ip^[0];
    op^[1]:=ClipTable[SARLongint(((((ip^[0] shl 3)+(9*ip^[1]))-ip^[2]))+8,4) and $3ff];
    op^[2]:=ip^[1];
    for x:=2 to MaxX-1 do begin
     op^[(x shl 1)-1]:=ClipTable[SARLongint(((9*(ip^[x-1]+ip^[x]))-(ip^[x-2]+ip^[x+1]))+8,4) and $3ff];
     op^[x shl 1]:=ip^[x];
    end;
    ip:=@ip^[Component^.Stride-3];
    op:=@op^[(Component^.Width shl 1)-3];
    op^[0]:=ClipTable[SARLongint(((((ip^[2] shl 3)+(9*ip^[1]))-ip^[0]))+8,4) and $3ff];
    op^[1]:=ip^[2];
    op^[2]:=ClipTable[SARLongint(((ip^[2]*17)-ip^[1])+8,4) and $3ff];
    ip:=@ip^[3];
    op:=@op^[3];
   end;
  finally
   Component^.Width:=Component^.Width shl 1;
   Component^.Stride:=Component^.Width;
   Component^.Pixels:=NewPixels;
   NewPixels:=nil;
  end;
 end;
 procedure UpsampleHCentered(const Component:PComponent);
 var MaxX,x,y:TpvInt32;
     NewPixels:TPixels;
     ip,op:PByteArray;
 begin
  MaxX:=Component^.Width-3;
  NewPixels:=nil;
  try
   SetLength(NewPixels,(Component^.Width*Component^.Height) shl 1);
   ip:=@Component^.Pixels[0];
   op:=@NewPixels[0];
   for y:=0 to Component^.Height-1 do begin
    op^[0]:=ClipTable[SARLongint(((CF2A*ip^[0])+(CF2B*ip^[1]))+64,7) and $3ff];
    op^[1]:=ClipTable[SARLongint(((CF3X*ip^[0])+(CF3Y*ip^[1])+(CF3Z*ip^[2]))+64,7) and $3ff];
    op^[2]:=ClipTable[SARLongint(((CF3A*ip^[0])+(CF3B*ip^[1])+(CF3C*ip^[2]))+64,7) and $3ff];
    for x:=0 to MaxX-1 do begin
     op^[(x shl 1)+3]:=ClipTable[SARLongint(((CF4A*ip^[x])+(CF4B*ip^[x+1])+(CF4C*ip^[x+2])+(CF4D*ip^[x+3]))+64,7) and $3ff];
     op^[(x shl 1)+4]:=ClipTable[SARLongint(((CF4D*ip^[x])+(CF4C*ip^[x+1])+(CF4B*ip^[x+2])+(CF4A*ip^[x+3]))+64,7) and $3ff];
    end;
    ip:=@ip^[Component^.Stride-3];
    op:=@op^[(Component^.Width shl 1)-3];
    op^[0]:=ClipTable[SARLongint(((CF3A*ip^[2])+(CF3B*ip^[1])+(CF3C*ip^[0]))+64,7) and $3ff];
    op^[1]:=ClipTable[SARLongint(((CF3X*ip^[2])+(CF3Y*ip^[1])+(CF3Z*ip^[0]))+64,7) and $3ff];
    op^[2]:=ClipTable[SARLongint(((CF2A*ip^[2])+(CF2B*ip^[1]))+64,7) and $3ff];
    ip:=@ip^[3];
    op:=@op^[3];
   end;
  finally
   Component^.Width:=Component^.Width shl 1;
   Component^.Stride:=Component^.Width;
   Component^.Pixels:=NewPixels;
   NewPixels:=nil;
  end;
 end;
 procedure UpsampleVCoSited(const Component:PComponent);
 var w,h,s1,s2,x,y:TpvInt32;
     NewPixels:TPixels;
     ip,op:PByteArray;
 begin
  w:=Component^.Width;
  h:=Component^.Height;
  s1:=Component^.Stride;
  s2:=s1 shl 1;
  NewPixels:=nil;
  try
   SetLength(NewPixels,(Component^.Width*Component^.Height) shl 1);
   for x:=0 to w-1 do begin
    ip:=@Component^.Pixels[x];
    op:=@NewPixels[x];
    op^[0]:=ip^[0];
    op:=@op^[w];
    op^[0]:=ClipTable[SARLongint(((((ip^[0] shl 3)+(9*ip^[s1]))-ip^[s2]))+8,4) and $3ff];
    op:=@op^[w];
    op^[0]:=ip^[s1];
    op:=@op^[w];
    ip:=@ip^[s1];
    for y:=0 to h-4 do begin
     op^[0]:=ClipTable[SARLongint((((9*(ip^[0]+ip^[s1]))-(ip^[-s1]+ip^[s2])))+8,4) and $3ff];
     op:=@op^[w];
     op^[0]:=ip^[s1];
     op:=@op^[w];
     ip:=@ip^[s1];
    end;
    op^[0]:=ClipTable[SARLongint(((ip^[s1] shl 3)+(9*ip^[0])-(ip^[-s1]))+8,4) and $3ff];
    op:=@op^[w];
    op^[0]:=ip[-s1];
    op:=@op^[w];
    op^[0]:=ClipTable[SARLongint(((17*ip^[s1])-ip^[0])+8,4) and $3ff];
   end;
  finally
   Component^.Height:=Component^.Height shl 1;
   Component^.Pixels:=NewPixels;
   NewPixels:=nil;
  end;
 end;
 procedure UpsampleVCentered(const Component:PComponent);
 var w,h,s1,s2,x,y:TpvInt32;
     NewPixels:TPixels;
     ip,op:PByteArray;
 begin
  w:=Component^.Width;
  h:=Component^.Height;
  s1:=Component^.Stride;
  s2:=s1 shl 1;
  NewPixels:=nil;
  try
   SetLength(NewPixels,(Component^.Width*Component^.Height) shl 1);
   for x:=0 to w-1 do begin
    ip:=@Component^.Pixels[x];
    op:=@NewPixels[x];
    op^[0]:=ClipTable[SARLongint(((CF2A*ip^[0])+(CF2B*ip^[s1]))+64,7) and $3ff];
    op:=@op^[w];
    op^[0]:=ClipTable[SARLongint(((CF3X*ip^[0])+(CF3Y*ip^[s1])+(CF3Z*ip^[s2]))+64,7) and $3ff];
    op:=@op^[w];
    op^[0]:=ClipTable[SARLongint(((CF3A*ip^[0])+(CF3B*ip^[s1])+(CF3C*ip^[s2]))+64,7) and $3ff];
    op:=@op^[w];
    ip:=@ip^[s1];
    for y:=0 to h-4 do begin
     op^[0]:=ClipTable[SARLongint(((CF4A*ip^[-s1])+(CF4B*ip^[0])+(CF4C*ip^[s1])+(CF4D*ip^[s2]))+64,7) and $3ff];
     op:=@op^[w];
     op^[0]:=ClipTable[SARLongint(((CF4D*ip^[-s1])+(CF4C*ip^[0])+(CF4B*ip^[s1])+(CF4A*ip^[s2]))+64,7) and $3ff];
     op:=@op^[w];
     ip:=@ip^[s1];
    end;
    ip:=@ip^[s1];
    op^[0]:=ClipTable[SARLongint(((CF3A*ip^[0])+(CF3B*ip^[-s1])+(CF3C*ip^[-s2]))+64,7) and $3ff];
    op:=@op^[w];
    op^[0]:=ClipTable[SARLongint(((CF3X*ip^[0])+(CF3Y*ip^[-s1])+(CF3Z*ip^[-s2]))+64,7) and $3ff];
    op:=@op^[w];
    op^[0]:=ClipTable[SARLongint(((CF2A*ip^[0])+(CF2B*ip^[-s1]))+64,7) and $3ff];
   end;
  finally
   Component^.Height:=Component^.Height shl 1;
   Component^.Pixels:=NewPixels;
   NewPixels:=nil;
  end;
 end;
var Index,SubIndex,Len,MaxSSX,MaxSSY,Value,Remain,Spread,CodeLen,DHTCurrentCount,Code,Coef,
    NextDataPosition,Count,v0,v1,v2,v3,mbx,mby,sbx,sby,RSTCount,NextRST,x,y,vY,vCb,vCr,
    tjWidth,tjHeight,tjJpegSubsamp:TpvInt32;
    ChunkTag:TpvUInt8;
    Component:PComponent;
    DHTCounts:array[0..15] of TpvUInt8;
    Huffman:PHuffmanCode;
    pY,aCb,aCr,oRGBX:PpvUInt8;
    tjHandle:pointer;
begin
 result:=false;
 ImageData:=nil;
 if (DataSize>=2) and (((PByteArray(DataPointer)^[0] xor $ff) or (PByteArray(DataPointer)^[1] xor $d8))=0) then begin
  if (TurboJpegLibrary<>NilLibHandle) and
     assigned(tjInitDecompress) and
     assigned(tjDecompressHeader2) and
     assigned(tjDecompress2) and
     assigned(tjDestroy) then begin
   tjHandle:=tjInitDecompress;
   if assigned(tjHandle) then begin
    try
     if tjDecompressHeader2(tjHandle,DataPointer,DataSize,tjWidth,tjHeight,tjJpegSubsamp)>=0 then begin
      ImageWidth:=tjWidth;
      ImageHeight:=tjHeight;
      if HeaderOnly then begin
       result:=true;
      end else begin
       GetMem(ImageData,ImageWidth*ImageHeight*SizeOf(longword));
       if tjDecompress2(tjHandle,DataPointer,DataSize,ImageData,tjWidth,0,tjHeight,7{TJPF_RGBA},2048{TJFLAG_FASTDCT})>=0 then begin
        result:=true;
       end else begin
        FreeMem(ImageData);
        ImageData:=nil;
       end;
      end;
     end;
    finally
     tjDestroy(tjHandle);
    end;
   end;
  end else begin
   DataPosition:=2;
   GetMem(Context,SizeOf(TContext));
   try
    FillChar(Context^,SizeOf(TContext),#0);
    Initialize(Context^);
    try
     while ((DataPosition+2)<DataSize) and (PByteArray(DataPointer)^[DataPosition]=$ff) do begin
      ChunkTag:=PByteArray(DataPointer)^[DataPosition+1];
      inc(DataPosition,2);
      case ChunkTag of
       $c0{SQF}:begin

        if (DataPosition+2)>=DataSize then begin
         RaiseError;
        end;

        Len:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if ((DataPosition+TpvUInt32(Len))>=DataSize) or
           (Len<9) or
           (PByteArray(DataPointer)^[DataPosition+2]<>8) then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        Context^.Width:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+1]) shl 8) or PByteArray(DataPointer)^[DataPosition+2];
        Context^.Height:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+3]) shl 8) or PByteArray(DataPointer)^[DataPosition+4];
        Context^.CountComponents:=PByteArray(DataPointer)^[DataPosition+5];

        if (Context^.Width=0) or (Context^.Height=0) or not (Context^.CountComponents in [1,3]) then begin
         RaiseError;
        end;

        inc(DataPosition,6);
        dec(Len,6);

        if Len<(Context^.CountComponents*3) then begin
         RaiseError;
        end;

        MaxSSX:=0;
        MaxSSY:=0;

        for Index:=0 to Context^.CountComponents-1 do begin
         Component:=@Context^.Components[Index];
         Component^.ID:=PByteArray(DataPointer)^[DataPosition+0];
         Component^.SSX:=PByteArray(DataPointer)^[DataPosition+1] shr 4;
         Component^.SSY:=PByteArray(DataPointer)^[DataPosition+1] and 15;
         Component^.QTSel:=PByteArray(DataPointer)^[DataPosition+2];
         inc(DataPosition,3);
         dec(Len,3);
         if (Component^.SSX=0) or ((Component^.SSX and (Component^.SSX-1))<>0) or
            (Component^.SSY=0) or ((Component^.SSY and (Component^.SSY-1))<>0) or
            ((Component^.QTSel and $fc)<>0) then begin
          RaiseError;
         end;
         Context^.QTUsed:=Context^.QTUsed or (1 shl Component^.QTSel);
         MaxSSX:=Max(MaxSSX,Component^.SSX);
         MaxSSY:=Max(MaxSSY,Component^.SSY);
        end;

        if Context^.CountComponents=1 then begin
         Component:=@Context^.Components[0];
         Component^.SSX:=1;
         Component^.SSY:=1;
         MaxSSX:=0;
         MaxSSY:=0;
        end;

        Context^.MBSizeX:=MaxSSX shl 3;
        Context^.MBSizeY:=MaxSSY shl 3;

        Context^.MBWidth:=(Context^.Width+(Context^.MBSizeX-1)) div Context^.MBSizeX;
        Context^.MBHeight:=(Context^.Height+(Context^.MBSizeY-1)) div Context^.MBSizeY;

        for Index:=0 to Context^.CountComponents-1 do begin
         Component:=@Context^.Components[Index];
         Component^.Width:=((Context^.Width*Component^.SSX)+(MaxSSX-1)) div MaxSSX;
         Component^.Height:=((Context^.Height*Component^.SSY)+(MaxSSY-1)) div MaxSSY;
         Component^.Stride:=(Context^.MBWidth*Component^.SSX) shl 3;
         if ((Component^.Width<3) and (Component^.SSX<>MaxSSX)) or
            ((Component^.Height<3) and (Component^.SSY<>MaxSSY)) then begin
          RaiseError;
         end;
         Count:=Component^.Stride*((Context^.MBHeight*Component^.ssy) shl 3);
 //       Count:=(Component^.Stride*((Context^.MBHeight*Context^.MBSizeY*Component^.ssy) div MaxSSY)) shl 3;
         if not HeaderOnly then begin
          SetLength(Component^.Pixels,Count);
          FillChar(Component^.Pixels[0],Count,#$80);
         end;
        end;

        inc(DataPosition,Len);

       end;
       $c4{DHT}:begin

        if (DataPosition+2)>=DataSize then begin
         RaiseError;
        end;

        Len:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if (DataPosition+TpvUInt32(Len))>=DataSize then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        while Len>=17 do begin

         Value:=PByteArray(DataPointer)^[DataPosition];
         if (Value and ($ec or $02))<>0 then begin
          RaiseError;
         end;

         Value:=(Value or (Value shr 3)) and 3;
         for CodeLen:=1 to 16 do begin
          DHTCounts[CodeLen-1]:=PByteArray(DataPointer)^[DataPosition+TpvUInt32(CodeLen)];
         end;
         inc(DataPosition,17);
         dec(Len,17);

         Huffman:=@Context^.HuffmanCodeTable[Value,0];
         Remain:=65536;
         Spread:=65536;
         for CodeLen:=1 to 16 do begin
          Spread:=Spread shr 1;
          DHTCurrentCount:=DHTCounts[CodeLen-1];
          if DHTCurrentCount<>0 then begin
           dec(Remain,DHTCurrentCount shl (16-CodeLen));
           if (Len<DHTCurrentCount) or
              (Remain<0) then begin
            RaiseError;
           end;
           for Index:=0 to DHTCurrentCount-1 do begin
            Code:=PByteArray(DataPointer)^[DataPosition+TpvUInt32(Index)];
            for SubIndex:=0 to Spread-1 do begin
             Huffman^.Bits:=CodeLen;
             Huffman^.Code:=Code;
             inc(Huffman);
            end;
           end;
           inc(DataPosition,DHTCurrentCount);
           dec(Len,DHTCurrentCount);
          end;
         end;
         while Remain>0 do begin
          dec(Remain);
          Huffman^.Bits:=0;
          inc(Huffman);
         end;
        end;

        if Len>0 then begin
         RaiseError;
        end;

        inc(DataPosition,Len);

       end;
       $da{SOS}:begin

        if (DataPosition+2)>=DataSize then begin
         RaiseError;
        end;

        Len:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if ((DataPosition+TpvUInt32(Len))>=DataSize) or (Len<2) then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        if (Len<(4+(2*Context^.CountComponents))) or
           (PByteArray(DataPointer)^[DataPosition+0]<>Context^.CountComponents) then begin
         RaiseError;
        end;

        inc(DataPosition);
        dec(Len);

        for Index:=0 to Context^.CountComponents-1 do begin
         Component:=@Context^.Components[Index];
         if (PByteArray(DataPointer)^[DataPosition+0]<>Component^.ID) or
            ((PByteArray(DataPointer)^[DataPosition+1] and $ee)<>0) then begin
          RaiseError;
         end;
         Component^.DCTabSel:=PByteArray(DataPointer)^[DataPosition+1] shr 4;
         Component^.ACTabSel:=(PByteArray(DataPointer)^[DataPosition+1] and 1) or 2;
         inc(DataPosition,2);
         dec(Len,2);
        end;

        if (PByteArray(DataPointer)^[DataPosition+0]<>0) or
           (PByteArray(DataPointer)^[DataPosition+1]<>63) or
           (PByteArray(DataPointer)^[DataPosition+2]<>0) then begin
         RaiseError;
        end;

        inc(DataPosition,Len);

        if not HeaderOnly then begin

         mbx:=0;
         mby:=0;
         RSTCount:=Context^.RSTInterval;
         NextRST:=0;
         repeat

          for Index:=0 to Context^.CountComponents-1 do begin
           Component:=@Context^.Components[Index];
           for sby:=0 to Component^.ssy-1 do begin
            for sbx:=0 to Component^.ssx-1 do begin
             Code:=0;
             Coef:=0;
             FillChar(Context^.Block,SizeOf(Context^.Block),#0);
             inc(Component^.DCPred,GetHuffmanCode(@Context^.HuffmanCodeTable[Component^.DCTabSel],nil));
             Context^.Block[0]:=Component^.DCPred*Context^.QTable[Component^.QTSel,0];
             repeat
              Value:=GetHuffmanCode(@Context^.HuffmanCodeTable[Component^.ACTabSel],@Code);
              if Code=0 then begin
               // EOB
               break;
              end else if ((Code and $0f)=0) and (Code<>$f0) then begin
               RaiseError;
              end else begin
               inc(Coef,(Code shr 4)+1);
               if Coef>63 then begin
                RaiseError;
               end else begin
                Context^.Block[ZigZagOrderToRasterOrderConversionTable[Coef]]:=Value*Context^.QTable[Component^.QTSel,Coef];
               end;
              end;
             until Coef>=63;
             ProcessIDCT(@Context^.Block,
                         @Component^.Pixels[((((mby*Component^.ssy)+sby)*Component^.Stride)+
                                             ((mbx*Component^.ssx)+sbx)) shl 3],
                         Component^.Stride);
            end;
           end;
          end;

          inc(mbx);
          if mbx>=Context^.MBWidth then begin
           mbx:=0;
           inc(mby);
           if mby>=Context^.MBHeight then begin
            mby:=0;
            ImageWidth:=Context^.Width;
            ImageHeight:=Context^.Height;
            GetMem(ImageData,(Context^.Width*Context^.Height) shl 2);
            FillChar(ImageData^,(Context^.Width*Context^.Height) shl 2,#0);
            for Index:=0 to Context^.CountComponents-1 do begin
             Component:=@Context^.Components[Index];
             while (Component^.Width<Context^.Width) or (Component^.Height<Context^.Height) do begin
              if Component^.Width<Context^.Width then begin
               if Context^.CoSitedChroma then begin
                UpsampleHCoSited(Component);
               end else begin
                UpsampleHCentered(Component);
               end;
              end;
              if Component^.Height<Context^.Height then begin
               if Context^.CoSitedChroma then begin
                UpsampleVCoSited(Component);
               end else begin
                UpsampleVCentered(Component);
               end;
              end;
             end;
             if (Component^.Width<Context^.Width) or (Component^.Height<Context^.Height) then begin
              RaiseError;
             end;
            end;
            case Context^.CountComponents of
             3:begin
              pY:=@Context^.Components[0].Pixels[0];
              aCb:=@Context^.Components[1].Pixels[0];
              aCr:=@Context^.Components[2].Pixels[0];
              oRGBX:=ImageData;
              for y:=0 to Context^.Height-1 do begin
               for x:=0 to Context^.Width-1 do begin
                vY:=PByteArray(pY)^[x] shl 8;
                vCb:=PByteArray(aCb)^[x]-128;
                vCr:=PByteArray(aCr)^[x]-128;
                PByteArray(oRGBX)^[0]:=ClipTable[SARLongint((vY+(vCr*359))+128,8) and $3ff];
                PByteArray(oRGBX)^[1]:=ClipTable[SARLongint(((vY-(vCb*88))-(vCr*183))+128,8) and $3ff];
                PByteArray(oRGBX)^[2]:=ClipTable[SARLongint((vY+(vCb*454))+128,8) and $3ff];
                PByteArray(oRGBX)^[3]:=$ff;
                inc(oRGBX,4);
               end;
               inc(pY,Context^.Components[0].Stride);
               inc(aCb,Context^.Components[1].Stride);
               inc(aCr,Context^.Components[2].Stride);
              end;
             end;
             else begin
              pY:=@Context^.Components[0].Pixels[0];
              oRGBX:=ImageData;
              for y:=0 to Context^.Height-1 do begin
               for x:=0 to Context^.Width-1 do begin
                vY:=ClipTable[PByteArray(pY)^[x] and $3ff];
                PByteArray(oRGBX)^[0]:=vY;
                PByteArray(oRGBX)^[1]:=vY;
                PByteArray(oRGBX)^[2]:=vY;
                PByteArray(oRGBX)^[3]:=$ff;
                inc(oRGBX,4);
               end;
               inc(pY,Context^.Components[0].Stride);
              end;
             end;
            end;
            result:=true;
            break;
           end;
          end;

          if Context^.RSTInterval<>0 then begin
           dec(RSTCount);
           if RSTCount=0 then begin
            Context^.BufBits:=Context^.BufBits and $f8;
            Value:=GetBits(16);
            if (((Value and $fff8)<>$ffd0) or ((Value and 7)<>NextRST)) then begin
             RaiseError;
            end;
            NextRST:=(NextRST+1) and 7;
            RSTCount:=Context^.RSTInterval;
            for Index:=0 to 2 do begin
             Context^.Components[Index].DCPred:=0;
            end;
           end;
          end;

         until false;

        end;

        break;

       end;
       $db{DQT}:begin

        if (DataPosition+2)>=DataSize then begin
         RaiseError;
        end;

        Len:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if (DataPosition+TpvUInt32(Len))>=DataSize then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        while Len>=65 do begin
         Value:=PByteArray(DataPointer)^[DataPosition];
         inc(DataPosition);
         dec(Len);
         if (Value and $fc)<>0 then begin
          RaiseError;
         end;
         Context^.QTUsed:=Context^.QTUsed or (1 shl Value);
         for Index:=0 to 63 do begin
          Context^.QTable[Value,Index]:=PByteArray(DataPointer)^[DataPosition];
          inc(DataPosition);
          dec(Len);
         end;
        end;

        inc(DataPosition,Len);

       end;
       $dd{DRI}:begin

        if (DataPosition+2)>=DataSize then begin
         RaiseError;
        end;

        Len:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if ((DataPosition+TpvUInt32(Len))>=DataSize) or
           (Len<4) then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        Context^.RSTInterval:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        inc(DataPosition,Len);

       end;
       $e1{EXIF}:begin

        if (DataPosition+2)>=DataSize then begin
         RaiseError;
        end;

        Len:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if ((DataPosition+TpvUInt32(Len))>=DataSize) or
           (Len<18) then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        NextDataPosition:=DataPosition+TpvUInt32(Len);

        if (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+0]))='E') and
           (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+1]))='x') and
           (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+2]))='i') and
           (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+3]))='f') and
           (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+4]))=#0) and
           (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+5]))=#0) and
           (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+6]))=TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+7]))) and
           (((TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+6]))='I') and
             (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+8]))='*') and
             (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+9]))=#0)) or
            ((TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+6]))='M') and
             (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+8]))=#0) and
             (TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+9]))='*'))) then begin
         Context^.EXIFLE:=TpvRawByteChar(TpvUInt8(PByteArray(DataPointer)^[DataPosition+6]))='I';
         if Len>=14 then begin
          if Context^.EXIFLE then begin
           Value:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+10]) shl 0) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+11]) shl 8) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+12]) shl 16) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+13]) shl 24);
          end else begin
           Value:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+10]) shl 24) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+11]) shl 16) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+12]) shl 8) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+13]) shl 0);
          end;
          inc(Value,6);
          if (Value>=14) and ((Value+2)<Len) then begin
           inc(DataPosition,Value);
           dec(Len,Value);
           if Context^.EXIFLE then begin
            Count:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+0]) shl 0) or
                   (TpvInt32(PByteArray(DataPointer)^[DataPosition+1]) shl 8);
           end else begin
            Count:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or
                   (TpvInt32(PByteArray(DataPointer)^[DataPosition+1]) shl 0);
           end;
           inc(DataPosition,2);
           dec(Len,2);
           if Count<=(Len div 12) then begin
            while Count>0 do begin
             dec(Count);
             if Context^.EXIFLE then begin
              v0:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+0]) shl 0) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+1]) shl 8);
              v1:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+2]) shl 0) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+3]) shl 8);
              v2:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+4]) shl 0) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+5]) shl 8) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+6]) shl 16) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+7]) shl 24);
              v3:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+8]) shl 0) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+9]) shl 8);
             end else begin
              v0:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+1]) shl 0);
              v1:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+2]) shl 8) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+3]) shl 0);
              v2:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+4]) shl 24) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+5]) shl 16) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+6]) shl 8) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+7]) shl 0);
              v3:=(TpvInt32(PByteArray(DataPointer)^[DataPosition+8]) shl 8) or
                  (TpvInt32(PByteArray(DataPointer)^[DataPosition+9]) shl 0);
             end;
             if (v0=$0213{YCbCrPositioning}) and (v1=$0003{SHORT}) and (v2=1{LENGTH}) then begin
              Context^.CoSitedChroma:=v3=2;
              break;
             end;
             inc(DataPosition,12);
             dec(Len,12);
            end;
           end;
          end;
         end;
        end;

        DataPosition:=NextDataPosition;

       end;
       $e0,$e2..$ef,$fe{Skip}:begin
        if (DataPosition+2)>=DataSize then begin
         RaiseError;
        end;
        Len:=(TpvUInt16(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];
        if (DataPosition+TpvUInt32(Len))>=DataSize then begin
         RaiseError;
        end;
        inc(DataPosition,Len);
       end;
       else begin
        RaiseError;
       end;
      end;
     end;
    except
     on e:EpvLoadJPEGImage do begin
      result:=false;
     end;
     on e:Exception do begin
      raise;
     end;
    end;
   finally
    if assigned(ImageData) and not result then begin
     FreeMem(ImageData);
     ImageData:=nil;
    end;
    Finalize(Context^);
    FreeMem(Context);
   end;
  end;
 end;
end;
{$endif}

function ClampToByte(v:longint):byte;
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

constructor TpvJPEGEncoder.Create;
begin
 inherited Create;
 fDataMemory:=nil;
 fDataMemorySize:=0;
 fTempChannelWords:=nil;
 fTempChannelBytes:=nil;
 fTempChannelSize:=0;
end;

destructor TpvJPEGEncoder.Destroy;
begin
 if assigned(fDataMemory) then begin
  FreeMem(fDataMemory);
 end;
 if assigned(fTempChannelWords) then begin
  FreeMem(fTempChannelWords);
 end;
 if assigned(fTempChannelBytes) then begin
  FreeMem(fTempChannelBytes);
 end;
 inherited Destroy;
end;

procedure TpvJPEGEncoder.EmitByte(b:TpvUInt8);
begin
 if fMaxCompressedDataSize>0 then begin
  if fCompressedDataPosition<fMaxCompressedDataSize then begin
   PpvJPEGEncoderUInt8Array(fCompressedData)^[fCompressedDataPosition]:=b;
   inc(fCompressedDataPosition);
  end;
 end else begin
  if fCompressedDataAllocated<(fCompressedDataPosition+1) then begin
   fCompressedDataAllocated:=(fCompressedDataPosition+1)*2;
   ReallocMem(fCompressedData,fCompressedDataAllocated);
  end;
  PpvJPEGEncoderUInt8Array(fCompressedData)^[fCompressedDataPosition]:=b;
  inc(fCompressedDataPosition);
 end;
end;

procedure TpvJPEGEncoder.EmitWord(w:word);
begin
 EmitByte(w shr 8);
 EmitByte(w and $ff);
end;

procedure TpvJPEGEncoder.EmitMarker(m:TpvUInt8);
begin
 EmitByte($ff);
 EmitByte(m);
end;

procedure TpvJPEGEncoder.EmitJFIFApp0;
const M_APP0=$e0;
begin
 EmitMarker(M_APP0);
 EmitWord(2+4+1+2+1+2+2+1+1);
 EmitByte($4a);
 EmitByte($46);
 EmitByte($49);
 EmitByte($46);
 EmitByte(0);
 EmitByte(1); // Major version
 EmitByte(1); // Minor version
 EmitByte(0); // Density unit
 EmitWord(1);
 EmitWord(1);
 EmitByte(0); // No thumbnail image
 EmitByte(0);
end;

procedure TpvJPEGEncoder.EmitDQT;
const M_DQT=$db;
var i,j,k:TpvInt32;
begin
 if fCountComponents=3 then begin
  k:=2;
 end else begin
  k:=1;
 end;
 for i:=0 to k-1 do begin
  EmitMarker(M_DQT);
  EmitWord(64+1+2);
  EmitByte(i);
  for j:=0 to 63 do begin
   EmitByte(fQuantizationTables[i,j]);
  end;
 end;
end;

procedure TpvJPEGEncoder.EmitSOF;
const M_SOF0=$c0;
var i:TpvInt32;
begin
 EmitMarker(M_SOF0); // baseline
 EmitWord((3*fCountComponents)+2+5+1);
 EmitByte(8); // precision
 EmitWord(fImageHeight);
 EmitWord(fImageWidth);
 EmitByte(fCountComponents);
 for i:=0 to fCountComponents-1 do begin
  EmitByte(i+1); // component ID
  EmitByte((fComponentHSamples[i] shl 4)+fComponentVSamples[i]); // h and v sampling
  if i>0 then begin // quant. table num
   EmitByte(1);
  end else begin
   EmitByte(0);
  end;
 end;
end;

procedure TpvJPEGEncoder.EmitDHT(Bits,Values:pansichar;Index:TpvInt32;ACFlag:boolean);
const M_DHT=$c4;
var i,l:TpvInt32;
begin
 EmitMarker(M_DHT);
 l:=0;
 for i:=1 to 16 do begin
  inc(l,TpvUInt8(ansichar(Bits[i])));
 end;
 EmitWord(l+2+1+16);
 if ACFlag then begin
  EmitByte(Index+16);
 end else begin
  EmitByte(Index);
 end;
 for i:=1 to 16 do begin
  EmitByte(TpvUInt8(ansichar(Bits[i])));
 end;
 for i:=0 to l-1 do begin
  EmitByte(TpvUInt8(ansichar(Values[i])));
 end;
end;

procedure TpvJPEGEncoder.EmitDHTs;
begin
 EmitDHT(TpvPointer(@fHuffmanBits[0+0]),TpvPointer(@fHuffmanValues[0+0]),0,false);
 EmitDHT(TpvPointer(@fHuffmanBits[2+0]),TpvPointer(@fHuffmanValues[2+0]),0,true);
 if fCountComponents=3 then begin
  EmitDHT(TpvPointer(@fHuffmanBits[0+1]),TpvPointer(@fHuffmanValues[0+1]),1,false);
  EmitDHT(TpvPointer(@fHuffmanBits[2+1]),TpvPointer(@fHuffmanValues[2+1]),1,true);
 end;
end;

procedure TpvJPEGEncoder.EmitSOS;
const M_SOS=$da;
var i:TpvInt32;
begin
 EmitMarker(M_SOS);
 EmitWord((2*fCountComponents)+2+1+3);
 EmitByte(fCountComponents);
 for i:=0 to fCountComponents-1 do begin
  EmitByte(i+1);
  if i=0 then begin
   EmitByte((0 shl 4)+0);
  end else begin
   EmitByte((1 shl 4)+1);
  end;
 end;
 EmitByte(0); // spectral selection
 EmitByte(63);
 EmitByte(0);
end;

procedure TpvJPEGEncoder.EmitMarkers;
const M_SOI=$d8;
begin
 EmitMarker(M_SOI);
 EmitJFIFApp0;
 EmitDQT;
 EmitSOF;
 EmitDHTS;
 EmitSOS;
end;

procedure TpvJPEGEncoder.ConvertRGBAToY(pDstY,pSrc:PpvJPEGEncoderUInt8Array;Count:TpvInt32); {$ifndef PurePascal}{$ifdef cpu386}stdcall;{$endif}{$endif}
{$ifdef PurePascal}
const YR=19595;
      YG=38470;
      YB=7471;
var x,r,g,b:TpvInt32;
begin
 for x:=1 to Count do begin
  r:=pSrc^[0];
  g:=pSrc^[1];
  b:=pSrc^[2];
  pSrc:=TpvPointer(@pSrc^[4]);
  pDstY^[0]:=ClampToByte(SARLongint((r*YR)+(g*YG)+(b*YB)+32768,16));
  pDstY:=TpvPointer(@pDstY^[1]);
 end;
end;
{$else}
{$ifdef cpu386}
{$ifdef UseAlternativeSIMDColorConversionImplementation}
const YR=19595;
      YG=38470;
      YB=7471;
      MaskRED:array[0..15] of TpvUInt8=($ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00);
      MaskGREEN:array[0..15] of TpvUInt8=($00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00);
      MaskBLUE:array[0..15] of TpvUInt8=($00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00);
      YRCoeffs:array[0..7] of word=(19595,19595,19595,19595,19595,19595,19595,19595);
      YGCoeffs:array[0..7] of word=(38470,38470,38470,38470,38470,38470,38470,38470);
      YBCoeffs:array[0..7] of word=(7471,7471,7471,7471,7471,7471,7471,7471);
{$else}
const YR=9798;
      YG=19235;
      YB=3736;
      YA=16384;
      MaskOffGA:array[0..15] of TpvUInt8=($ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00);
      YAGCoeffs:array[0..7] of TpvInt16=(19235,0,19235,0,19235,0,19235,0);
      YRBCoeffs:array[0..7] of TpvInt16=(9798,3736,9798,3736,9798,3736,9798,3736);
      Add16384:array[0..3] of TpvUInt32=(16384,16384,16384,16384);
{$endif}
asm
 push eax
 push ebx
 push esi
 push edi

  mov edi,dword ptr pSrc

  mov ecx,dword ptr pDstY

  mov esi,dword ptr Count
  mov edx,esi
  and edx,7
  shr esi,3
  test esi,esi
  jz @Done1

{$ifdef UseAlternativeSIMDColorConversionImplementation}
   // Get 16-bit aligned memory space on the stack
   lea ebx,[esp-128]
   and ebx,$fffffff0

   // Load constant stuff into 16-bit aligned memory offsets o the stack, since at least old delphi compiler versions puts these not always 16-TpvUInt8 aligned
   movdqu xmm0,dqword ptr MaskRED
   movdqa dqword ptr [ebx],xmm0
   movdqu xmm0,dqword ptr MaskGREEN
   movdqa dqword ptr [ebx+16],xmm0
   movdqu xmm0,dqword ptr MaskBLUE
   movdqa dqword ptr [ebx+32],xmm0
   movdqu xmm0,dqword ptr YRCoeffs
   movdqa dqword ptr [ebx+48],xmm0
   movdqu xmm0,dqword ptr YGCoeffs
   movdqa dqword ptr [ebx+64],xmm0
   movdqu xmm0,dqword ptr YBCoeffs
   movdqa dqword ptr [ebx+80],xmm0
{$else}
   // Get 16-bit aligned memory space on the stack
   lea ebx,[esp-64]
   and ebx,$fffffff0

   // Load constant stuff into 16-bit aligned memory offsets o the stack, since at least old delphi compiler versions puts these not always 16-TpvUInt8 aligned
   movdqu xmm0,dqword ptr MaskOffGA
   movdqa dqword ptr [ebx],xmm0
   movdqu xmm0,dqword ptr YAGCoeffs
   movdqa dqword ptr [ebx+16],xmm0
   movdqu xmm0,dqword ptr YRBCoeffs
   movdqa dqword ptr [ebx+32],xmm0
   movdqu xmm0,dqword ptr Add16384
   movdqa dqword ptr [ebx+48],xmm0
{$endif}

   test edi,$f
   jz @Loop1Aligned

    @Loop1Unaligned:

{$ifdef UseAlternativeSIMDColorConversionImplementation}
     movdqu xmm0,[edi]    // First four RGB32 pixel vector values
     movdqu xmm1,[edi+16] // Other four RGB32 pixel vector values
     add edi,32

     // xmm5 = Eight red values (from xmm0 and xmm1)
     movdqa xmm5,xmm0
     movdqa xmm6,xmm1
     pand xmm5,dqword ptr [ebx] // MaskRED
     pand xmm6,dqword ptr [ebx] // MaskRED
     packssdw xmm5,xmm6

     // xmm6 = Eight green values (from xmm0 and xmm1)
     movdqa xmm6,xmm0
     movdqa xmm7,xmm1
     pand xmm6,dqword ptr [ebx+16] // MaskGREEN
     psrld xmm6,8
     pand xmm7,dqword ptr [ebx+16] // MaskGREEN
     psrld xmm7,8
     packssdw xmm6,xmm7

     // xmm7 = Eight blue values (from xmm0 and xmm1)
     movdqa xmm7,xmm0
     movdqa xmm4,xmm1
     pand xmm7,dqword ptr [ebx+32] // MaskBLUE
     psrld xmm7,16
     pand xmm4,dqword ptr [ebx+32] // MaskBLUE
     psrld xmm4,16
     packssdw xmm7,xmm4

     // xmm0 = Eight Y values (from xmm5/red, xmm6/green and xmm7/blue)
     movdqu xmm0,xmm5
     pmulhuw xmm0,dqword ptr [ebx+48] // YRCoeffs
     movdqu xmm1,xmm6
     pmulhuw xmm1,dqword ptr [ebx+64] // YGCoeffs
     paddw xmm0,xmm1
     movdqu xmm1,xmm7
     pmulhuw xmm1,dqword ptr [ebx+80] // YBCoeffs
     paddw xmm0,xmm1
     packuswb xmm0,xmm0

     // Store the Y result values

     movq qword ptr [ecx],xmm0  // Y
     add ecx,8

{$else}

     // xmm0 .. xmm3 = ga br vectors
     movdqa xmm4,dqword ptr [ebx] // MaskOffGA
     movdqu xmm0,dqword ptr [edi]
     movdqa xmm1,xmm0
     psrlw xmm0,8
     pand xmm1,xmm4 // MaskOffGA
     movdqu xmm2,dqword ptr [edi+16]
     movdqa xmm3,xmm2
     psrlw xmm2,8
     pand xmm3,xmm4 // MaskOffGA
     add edi,32

     // Y
     movdqa xmm7,dqword ptr [ebx+16] // YAGCoeffs
     movdqa xmm4,xmm0
     pmaddwd xmm4,xmm7 // YAGCoeffs
     movdqa xmm5,xmm1
     pmaddwd xmm5,dqword ptr [ebx+32] // YRBCoeffs
     paddd xmm4,xmm5
     paddd xmm4,dqword ptr [ebx+48] // Add16384
     psrld xmm4,15
     movdqa xmm5,xmm2
     pmaddwd xmm5,xmm7 // YAGCoeffs
     movdqa xmm6,xmm3
     pmaddwd xmm6,dqword ptr [ebx+32] // YRBCoeffs
     paddd xmm5,xmm6
     paddd xmm5,dqword ptr [ebx+48] // Add16384
     psrld xmm5,15
     packssdw xmm4,xmm5
     packuswb xmm4,xmm4
     movq qword ptr [ecx],xmm4  // Y
     add ecx,8

{$endif}

     dec esi
    jnz @Loop1Unaligned
    jmp @Done1

    @Loop1Aligned:

{$ifdef UseAlternativeSIMDColorConversionImplementation}
     movdqa xmm0,[edi]    // First four RGB32 pixel vector values
     movdqa xmm1,[edi+16] // Other four RGB32 pixel vector values
     add edi,32

     // xmm5 = Eight red values (from xmm0 and xmm1)
     movdqa xmm5,xmm0
     movdqa xmm6,xmm1
     pand xmm5,dqword ptr [ebx] // MaskRED
     pand xmm6,dqword ptr [ebx] // MaskRED
     packssdw xmm5,xmm6

     // xmm6 = Eight green values (from xmm0 and xmm1)
     movdqa xmm6,xmm0
     movdqa xmm7,xmm1
     pand xmm6,dqword ptr [ebx+16] // MaskGREEN
     psrld xmm6,8
     pand xmm7,dqword ptr [ebx+16] // MaskGREEN
     psrld xmm7,8
     packssdw xmm6,xmm7

     // xmm7 = Eight blue values (from xmm0 and xmm1)
     movdqa xmm7,xmm0
     movdqa xmm4,xmm1
     pand xmm7,dqword ptr [ebx+32] // MaskBLUE
     psrld xmm7,16
     pand xmm4,dqword ptr [ebx+32] // MaskBLUE
     psrld xmm4,16
     packssdw xmm7,xmm4

     // xmm0 = Eight Y values (from xmm5/red, xmm6/green and xmm7/blue)
     movdqu xmm0,xmm5
     pmulhuw xmm0,dqword ptr [ebx+48] // YRCoeffs
     movdqu xmm1,xmm6
     pmulhuw xmm1,dqword ptr [ebx+64] // YGCoeffs
     paddw xmm0,xmm1
     movdqu xmm1,xmm7
     pmulhuw xmm1,dqword ptr [ebx+80] // YBCoeffs
     paddw xmm0,xmm1
     packuswb xmm0,xmm0

     // Store the Y result values

     movq qword ptr [ecx],xmm0  // Y
     add ecx,8

{$else}

     // xmm0 .. xmm3 = ga br vectors
     movdqa xmm4,dqword ptr [ebx] // MaskOffGA
     movdqa xmm0,dqword ptr [edi]
     movdqa xmm1,xmm0
     psrlw xmm0,8
     pand xmm1,xmm4 // MaskOffGA
     movdqu xmm2,dqword ptr [edi+16]
     movdqa xmm3,xmm2
     psrlw xmm2,8
     pand xmm3,xmm4 // MaskOffGA
     add edi,32

     // Y
     movdqa xmm7,dqword ptr [ebx+16] // YAGCoeffs
     movdqa xmm4,xmm0
     pmaddwd xmm4,xmm7 // YAGCoeffs
     movdqa xmm5,xmm1
     pmaddwd xmm5,dqword ptr [ebx+32] // YRBCoeffs
     paddd xmm4,xmm5
     paddd xmm4,dqword ptr [ebx+48] // Add16384
     psrld xmm4,15
     movdqa xmm5,xmm2
     pmaddwd xmm5,xmm7 // YAGCoeffs
     movdqa xmm6,xmm3
     pmaddwd xmm6,dqword ptr [ebx+32] // YRBCoeffs
     paddd xmm5,xmm6
     paddd xmm5,dqword ptr [ebx+48] // Add16384
     psrld xmm5,15
     packssdw xmm4,xmm5
     packuswb xmm4,xmm4
     movq qword ptr [ecx],xmm4  // Y
     add ecx,8

{$endif}

     dec esi
    jnz @Loop1Aligned

  @Done1:

  test edx,edx
  jz @Done2
   @Loop2:

{$ifdef UseAlternativeSIMDColorConversionImplementation}
    // Y
    movzx eax,TpvUInt8 ptr [edi+0]
    imul eax,eax,YR
    shr eax,16

    movzx ebx,TpvUInt8 ptr [edi+1]
    imul ebx,ebx,YG
    shr ebx,16
    add eax,ebx

    movzx ebx,TpvUInt8 ptr [edi+2]
    imul ebx,ebx,YB
    shr ebx,16
    add eax,ebx

    mov ebx,eax
    and ebx,$ffffff00
    neg ebx
    sbb ebx,ebx
    or eax,ebx

    mov TpvUInt8 ptr [ecx],al
    inc ecx

{$else}
    // Y
    movzx eax,TpvUInt8 ptr [edi+0]
    imul eax,eax,YR
    movzx ebx,TpvUInt8 ptr [edi+1]
    imul ebx,ebx,YG
    lea eax,[eax+ebx+YA]
    movzx ebx,TpvUInt8 ptr [edi+2]
    imul ebx,ebx,YB
    add eax,ebx
    shr ebx,15

    mov ebx,eax
    and ebx,$ffffff00
    neg ebx
    sbb ebx,ebx
    or eax,ebx

    mov TpvUInt8 ptr [ecx],al
    inc ecx
{$endif}

    add edi,4

    dec edx
   jnz @Loop2
  @Done2:

 pop edi
 pop esi
 pop ebx
 pop eax
end;
{$else}
 {$error You must define PurePascal, since no inline assembler function variant doesn't exist for your target platform }
{$endif}
{$endif}

procedure TpvJPEGEncoder.ConvertRGBAToYCbCr(pDstY,pDstCb,pDstCr,pSrc:PpvJPEGEncoderUInt8Array;Count:TpvInt32); {$ifndef PurePascal}{$ifdef cpu386}stdcall;{$endif}{$endif}
{$ifdef PurePascal}
const YR=19595;
      YG=38470;
      YB=7471;
      Cb_R=-11059;
      Cb_G=-21709;
      Cb_B=32768;
      Cr_R=32768;
      Cr_G=-27439;
      Cr_B=-5329;
var x,r,g,b:TpvInt32;
begin
 for x:=0 to Count-1 do begin
  r:=pSrc^[0];
  g:=pSrc^[1];
  b:=pSrc^[2];
  pSrc:=TpvPointer(@pSrc^[4]);
  pDstY^[x]:=ClampToByte(SARLongint((r*YR)+(g*YG)+(b*YB)+32768,16));
  pDstCb^[x]:=ClampToByte(128+SARLongint((r*Cb_R)+(g*Cb_G)+(b*Cb_B)+32768,16));
  pDstCr^[x]:=ClampToByte(128+SARLongint((r*Cr_R)+(g*Cr_G)+(b*Cr_B)+32768,16));
 end;
end;
{$else}
{$ifdef cpu386}
{$ifdef UseAlternativeSIMDColorConversionImplementation}
const YR=19595;
      YG=38470;
      YB=7471;
      Cb_R=-11059;
      Cb_G=-21709;
      Cb_B=32768;
      Cr_R=32768;
      Cr_G=-27439;
      Cr_B=-5329;
      MaskRED:array[0..15] of TpvUInt8=($ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00);
      MaskGREEN:array[0..15] of TpvUInt8=($00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00);
      MaskBLUE:array[0..15] of TpvUInt8=($00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00,$00,$00,$ff,$00);
      YRCoeffs:array[0..7] of word=(19595,19595,19595,19595,19595,19595,19595,19595);
      YGCoeffs:array[0..7] of word=(38470,38470,38470,38470,38470,38470,38470,38470);
      YBCoeffs:array[0..7] of word=(7471,7471,7471,7471,7471,7471,7471,7471);
      CbRCoeffs:array[0..7] of TpvInt16=(-11059,-11059,-11059,-11059,-11059,-11059,-11059,-11059);
      CbGCoeffs:array[0..7] of TpvInt16=(-21709,-21709,-21709,-21709,-21709,-21709,-21709,-21709);
      CbBCoeffs:array[0..7] of word=(32768,32768,32768,32768,32768,32768,32768,32768);
      CrRCoeffs:array[0..7] of word=(32768,32768,32768,32768,32768,32768,32768,32768);
      CrGCoeffs:array[0..7] of TpvInt16=(-27439,-27439,-27439,-27439,-27439,-27439,-27439,-27439);
      CrBCoeffs:array[0..7] of TpvInt16=(-5329,-5329,-5329,-5329,-5329,-5329,-5329,-5329);
      Add128:array[0..7] of word=($80,$80,$80,$80,$80,$80,$80,$80);
{$else}
const YR=9798;
      YG=19235;
      YB=3736;
      YA=16384;
      Cb_R=-11059;
      Cb_G=-21709;
      Cb_B=32767;
      Cb_A=32768;
      Cr_R=32767;
      Cr_G=-27439;
      Cr_B=-5329;
      Cr_A=32768;
      MaskOffGA:array[0..15] of TpvUInt8=($ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00);
      YAGCoeffs:array[0..7] of TpvInt16=(19235,0,19235,0,19235,0,19235,0);
      YRBCoeffs:array[0..7] of TpvInt16=(9798,3736,9798,3736,9798,3736,9798,3736);
      CbAGCoeffs:array[0..7] of TpvInt16=(-21709,0,-21709,0,-21709,0,-21709,0);
      CbRBCoeffs:array[0..7] of TpvInt16=(-11059,32767,-11059,32767,-11059,32767,-11059,32767);
      CrAGCoeffs:array[0..7] of TpvInt16=(-27439,0,-27439,0,-27439,0,-27439,0);
      CrRBCoeffs:array[0..7] of TpvInt16=(32767,-5329,32767,-5329,32767,-5329,32767,-5329);
      Add128:array[0..7] of word=(128,128,128,128,128,128,128,128);
      Add16384:array[0..3] of TpvUInt32=(16384,16384,16384,16384);
      Add32678:array[0..3] of TpvUInt32=(32768,32768,32768,32768);
{$endif}
asm
 push eax
 push ebx
 push esi
 push edi

  mov edi,dword ptr pSrc

  mov ecx,dword ptr pDstY

  mov esi,dword ptr Count
  shr esi,3
  test esi,esi
  jz @Done1

   mov edx,dword ptr pDstCb

   // Get 16-bit aligned memory space on the stack
   lea ebx,[esp-256]
   and ebx,$fffffff0

   // Load constant stuff into 16-bit aligned memory offsets o the stack, since at least old delphi compiler versions puts these not always 16-TpvUInt8 aligned
{$ifdef UseAlternativeSIMDColorConversionImplementation}
   movdqu xmm0,dqword ptr MaskRED
   movdqa dqword ptr [ebx],xmm0
   movdqu xmm0,dqword ptr MaskGREEN
   movdqa dqword ptr [ebx+16],xmm0
   movdqu xmm0,dqword ptr MaskBLUE
   movdqa dqword ptr [ebx+32],xmm0
   movdqu xmm0,dqword ptr YRCoeffs
   movdqa dqword ptr [ebx+48],xmm0
   movdqu xmm0,dqword ptr YGCoeffs
   movdqa dqword ptr [ebx+64],xmm0
   movdqu xmm0,dqword ptr YBCoeffs
   movdqa dqword ptr [ebx+80],xmm0
   movdqu xmm0,dqword ptr CbRCoeffs
   movdqa dqword ptr [ebx+96],xmm0
   movdqu xmm0,dqword ptr CbGCoeffs
   movdqa dqword ptr [ebx+112],xmm0
   movdqu xmm0,dqword ptr CbBCoeffs
   movdqa dqword ptr [ebx+128],xmm0
   movdqu xmm0,dqword ptr CrRCoeffs
   movdqa dqword ptr [ebx+144],xmm0
   movdqu xmm0,dqword ptr CrGCoeffs
   movdqa dqword ptr [ebx+160],xmm0
   movdqu xmm0,dqword ptr CrBCoeffs
   movdqa dqword ptr [ebx+176],xmm0
   movdqu xmm0,dqword ptr [Add128]
   movdqa dqword ptr [ebx+192],xmm0
{$else}
   movdqu xmm0,dqword ptr MaskOffGA
   movdqa dqword ptr [ebx],xmm0
   movdqu xmm0,dqword ptr YAGCoeffs
   movdqa dqword ptr [ebx+16],xmm0
   movdqu xmm0,dqword ptr YRBCoeffs
   movdqa dqword ptr [ebx+32],xmm0
   movdqu xmm0,dqword ptr CbAGCoeffs
   movdqa dqword ptr [ebx+48],xmm0
   movdqu xmm0,dqword ptr CbRBCoeffs
   movdqa dqword ptr [ebx+64],xmm0
   movdqu xmm0,dqword ptr CrAGCoeffs
   movdqa dqword ptr [ebx+80],xmm0
   movdqu xmm0,dqword ptr CrRBCoeffs
   movdqa dqword ptr [ebx+96],xmm0
   movdqu xmm0,dqword ptr Add128
   movdqa dqword ptr [ebx+112],xmm0
   movdqu xmm0,dqword ptr Add16384
   movdqa dqword ptr [ebx+128],xmm0
   movdqu xmm0,dqword ptr Add32678
   movdqa dqword ptr [ebx+144],xmm0
{$endif}

   test edi,$f
   jz @Loop1Aligned

    @Loop1Unaligned:

{$ifdef UseAlternativeSIMDColorConversionImplementation}
     movdqu xmm0,[edi]    // First four RGB32 pixel vector values
     movdqu xmm1,[edi+16] // Other four RGB32 pixel vector values
     add edi,32

     // xmm5 = Eight red values (from xmm0 and xmm1)
     movdqa xmm5,xmm0
     movdqa xmm6,xmm1
     pand xmm5,dqword ptr [ebx] // MaskRED
     pand xmm6,dqword ptr [ebx] // MaskRED
     packssdw xmm5,xmm6

     // xmm6 = Eight green values (from xmm0 and xmm1)
     movdqa xmm6,xmm0
     movdqa xmm7,xmm1
     pand xmm6,dqword ptr [ebx+16] // MaskGREEN
     psrld xmm6,8
     pand xmm7,dqword ptr [ebx+16] // MaskGREEN
     psrld xmm7,8
     packssdw xmm6,xmm7

     // xmm7 = Eight blue values (from xmm0 and xmm1)
     movdqa xmm7,xmm0
     movdqa xmm4,xmm1
     pand xmm7,dqword ptr [ebx+32] // MaskBLUE
     psrld xmm7,16
     pand xmm4,dqword ptr [ebx+32] // MaskBLUE
     psrld xmm4,16
     packssdw xmm7,xmm4

     // xmm0 = Eight Y values (from xmm5/red, xmm6/green and xmm7/blue)
     movdqu xmm0,xmm5
     pmulhuw xmm0,dqword ptr [ebx+48] // YRCoeffs
     movdqu xmm1,xmm6
     pmulhuw xmm1,dqword ptr [ebx+64] // YGCoeffs
     paddw xmm0,xmm1
     movdqu xmm1,xmm7
     pmulhuw xmm1,dqword ptr [ebx+80] // YBCoeffs
     paddw xmm0,xmm1
     packuswb xmm0,xmm0

     // xmm1 = Eight Cb values (from xmm5/red, xmm6/green and xmm7/blue)
     movdqu xmm1,xmm5
     pmulhw xmm1,dqword ptr [ebx+96] // CbRCoeffs
     movdqu xmm2,xmm6
     pmulhw xmm2,dqword ptr [ebx+112] // CbGCoeffs
     paddw xmm1,xmm2
     movdqu xmm2,xmm7
     pmulhuw xmm2,dqword ptr [ebx+128] // CbBCoeffs
     paddw xmm1,xmm2
     paddw xmm1,dqword ptr [ebx+192] // Add128
     packuswb xmm1,xmm1

     // xmm2 = Eight Cr values
     movdqu xmm2,xmm5
     pmulhuw xmm2,dqword ptr [ebx+144] // CrRCoeffs
     movdqu xmm3,xmm6
     pmulhw xmm3,dqword ptr [ebx+160] // CrGCoeffs
     paddw xmm2,xmm3
     movdqu xmm3,xmm7
     pmulhw xmm3,dqword ptr [ebx+176] // CrBCoeffs
     paddw xmm2,xmm3
     paddw xmm2,dqword ptr [ebx+192] // Add128
     packuswb xmm2,xmm2

     // Store the YCbCr result values to separate arrays at different memory locations

     movq qword ptr [ecx],xmm0  // Y
     add ecx,8

     movq qword ptr [edx],xmm1  // Cb
     add edx,8

     mov eax,dword ptr pDstCr
     movq qword ptr [eax],xmm2  // Ct
     add eax,8
     mov dword ptr pDstCr,eax
{$else}
     // xmm0 .. xmm3 = ga br vectors
     movdqa xmm4,dqword ptr [ebx] // MaskOffGA
     movdqu xmm0,dqword ptr [edi]
     movdqa xmm1,xmm0
     psrlw xmm0,8
     pand xmm1,xmm4 // MaskOffGA
     movdqu xmm2,dqword ptr [edi+16]
     movdqa xmm3,xmm2
     psrlw xmm2,8
     pand xmm3,xmm4 // MaskOffGA
     add edi,32

     // Y
     movdqa xmm7,dqword ptr [ebx+16] // YAGCoeffs
     movdqa xmm4,xmm0
     pmaddwd xmm4,xmm7 // YAGCoeffs
     movdqa xmm5,xmm1
     pmaddwd xmm5,dqword ptr [ebx+32] // YRBCoeffs
     paddd xmm4,xmm5
     paddd xmm4,dqword ptr [ebx+128] // Add16384
     psrld xmm4,15
     movdqa xmm5,xmm2
     pmaddwd xmm5,xmm7 // YAGCoeffs
     movdqa xmm6,xmm3
     pmaddwd xmm6,dqword ptr [ebx+32] // YRBCoeffs
     paddd xmm5,xmm6
     paddd xmm5,dqword ptr [ebx+128] // Add16384
     psrld xmm5,15
     packssdw xmm4,xmm5
     packuswb xmm4,xmm4
     movq qword ptr [ecx],xmm4  // Y
     add ecx,8

     // Cb
     movdqa xmm7,dqword ptr [ebx+48] // CbAGCoeffs
     movdqa xmm4,xmm0
     pmaddwd xmm4,xmm7 // CbAGCoeffs
     movdqa xmm5,xmm1
     pmaddwd xmm5,dqword ptr [ebx+64] // CbRBCoeffs
     paddd xmm4,xmm5
     paddd xmm4,dqword ptr [ebx+144] // Add32768
     psrad xmm4,16
     movdqa xmm5,xmm2
     pmaddwd xmm5,xmm7 // CbAGCoeffs
     movdqa xmm6,xmm3
     pmaddwd xmm6,dqword ptr [ebx+64] // CbRBCoeffs
     paddd xmm5,xmm6
     paddd xmm5,dqword ptr [ebx+144] // Add32768
     psrad xmm5,16
     packssdw xmm4,xmm5
     paddw xmm4,dqword ptr [ebx+112] // Add128
     packuswb xmm4,xmm4
     movq qword ptr [edx],xmm4  // Cb
     add edx,8

     // Cr
     movdqa xmm7,dqword ptr [ebx+80] // CrAGCoeffs
     movdqa xmm4,xmm0
     pmaddwd xmm4,xmm7 // CrAGCoeffs
     movdqa xmm5,xmm1
     pmaddwd xmm5,dqword ptr [ebx+96] // CrRBCoeffs
     paddd xmm4,xmm5
     paddd xmm4,dqword ptr [ebx+144] // Add32768
     psrad xmm4,16
     movdqa xmm5,xmm2
     pmaddwd xmm5,xmm7 // CrAGCoeffs
     movdqa xmm6,xmm3
     pmaddwd xmm6,dqword ptr [ebx+96] // CrRBCoeffs
     paddd xmm5,xmm6
     paddd xmm5,dqword ptr [ebx+144] // Add32768
     psrad xmm5,16
     packssdw xmm4,xmm5
     paddw xmm4,dqword ptr [ebx+112] // Add128
     packuswb xmm4,xmm4
     mov eax,dword ptr pDstCr
     movq qword ptr [eax],xmm4  // Ct
     add eax,8
     mov dword ptr pDstCr,eax
{$endif}

     dec esi
    jnz @Loop1Unaligned
    jmp @Loop1UnalignedDone
    @Loop1Aligned:

{$ifdef UseAlternativeSIMDColorConversionImplementation}
     movdqa xmm0,[edi]    // First four RGB32 pixel vector values
     movdqa xmm1,[edi+16] // Other four RGB32 pixel vector values
     add edi,32

     // xmm5 = Eight red values (from xmm0 and xmm1)
     movdqa xmm5,xmm0
     movdqa xmm6,xmm1
     pand xmm5,dqword ptr [ebx] // MaskRED
     pand xmm6,dqword ptr [ebx] // MaskRED
     packssdw xmm5,xmm6

     // xmm6 = Eight green values (from xmm0 and xmm1)
     movdqa xmm6,xmm0
     movdqa xmm7,xmm1
     pand xmm6,dqword ptr [ebx+16] // MaskGREEN
     psrld xmm6,8
     pand xmm7,dqword ptr [ebx+16] // MaskGREEN
     psrld xmm7,8
     packssdw xmm6,xmm7

     // xmm7 = Eight blue values (from xmm0 and xmm1)
     movdqa xmm7,xmm0
     movdqa xmm4,xmm1
     pand xmm7,dqword ptr [ebx+32] // MaskBLUE
     psrld xmm7,16
     pand xmm4,dqword ptr [ebx+32] // MaskBLUE
     psrld xmm4,16
     packssdw xmm7,xmm4

     // xmm0 = Eight Y values (from xmm5/red, xmm6/green and xmm7/blue)
     movdqu xmm0,xmm5
     pmulhuw xmm0,dqword ptr [ebx+48] // YRCoeffs
     movdqu xmm1,xmm6
     pmulhuw xmm1,dqword ptr [ebx+64] // YGCoeffs
     paddw xmm0,xmm1
     movdqu xmm1,xmm7
     pmulhuw xmm1,dqword ptr [ebx+80] // YBCoeffs
     paddw xmm0,xmm1
     packuswb xmm0,xmm0

     // xmm1 = Eight Cb values (from xmm5/red, xmm6/green and xmm7/blue)
     movdqu xmm1,xmm5
     pmulhw xmm1,dqword ptr [ebx+96] // CbRCoeffs
     movdqu xmm2,xmm6
     pmulhw xmm2,dqword ptr [ebx+112] // CbGCoeffs
     paddw xmm1,xmm2
     movdqu xmm2,xmm7
     pmulhuw xmm2,dqword ptr [ebx+128] // CbBCoeffs
     paddw xmm1,xmm2
     paddw xmm1,dqword ptr [ebx+192] // Add128
     packuswb xmm1,xmm1

     // xmm2 = Eight Cr values
     movdqu xmm2,xmm5
     pmulhuw xmm2,dqword ptr [ebx+144] // CrRCoeffs
     movdqu xmm3,xmm6
     pmulhw xmm3,dqword ptr [ebx+160] // CrGCoeffs
     paddw xmm2,xmm3
     movdqu xmm3,xmm7
     pmulhw xmm3,dqword ptr [ebx+176] // CrBCoeffs
     paddw xmm2,xmm3
     paddw xmm2,dqword ptr [ebx+192] // Add128
     packuswb xmm2,xmm2

     // Store the YCbCr result values to separate arrays at different memory locations

     movq qword ptr [ecx],xmm0  // Y
     add ecx,8

     movq qword ptr [edx],xmm1  // Cb
     add edx,8

     mov eax,dword ptr pDstCr
     movq qword ptr [eax],xmm2  // Ct
     add eax,8
     mov dword ptr pDstCr,eax

{$else}
     // xmm0 .. xmm3 = ga br vectors
     movdqa xmm4,dqword ptr [ebx] // MaskOffGA
     movdqa xmm0,dqword ptr [edi]
     movdqa xmm1,xmm0
     psrlw xmm0,8
     pand xmm1,xmm4 // MaskOffGA
     movdqa xmm2,dqword ptr [edi+16]
     movdqa xmm3,xmm2
     psrlw xmm2,8
     pand xmm3,xmm4 // MaskOffGA
     add edi,32

     // Y
     movdqa xmm7,dqword ptr [ebx+16] // YAGCoeffs
     movdqa xmm4,xmm0
     pmaddwd xmm4,xmm7 // YAGCoeffs
     movdqa xmm5,xmm1
     pmaddwd xmm5,dqword ptr [ebx+32] // YRBCoeffs
     paddd xmm4,xmm5
     paddd xmm4,dqword ptr [ebx+128] // Add16384
     psrld xmm4,15
     movdqa xmm5,xmm2
     pmaddwd xmm5,xmm7 // YAGCoeffs
     movdqa xmm6,xmm3
     pmaddwd xmm6,dqword ptr [ebx+32] // YRBCoeffs
     paddd xmm5,xmm6
     paddd xmm5,dqword ptr [ebx+128] // Add16384
     psrld xmm5,15
     packssdw xmm4,xmm5
     packuswb xmm4,xmm4
     movq qword ptr [ecx],xmm4  // Y
     add ecx,8

     // Cb
     movdqa xmm7,dqword ptr [ebx+48] // CbAGCoeffs
     movdqa xmm4,xmm0
     pmaddwd xmm4,xmm7 // CbAGCoeffs
     movdqa xmm5,xmm1
     pmaddwd xmm5,dqword ptr [ebx+64] // CbRBCoeffs
     paddd xmm4,xmm5
     paddd xmm4,dqword ptr [ebx+144] // Add32768
     psrad xmm4,16
     movdqa xmm5,xmm2
     pmaddwd xmm5,xmm7 // CbAGCoeffs
     movdqa xmm6,xmm3
     pmaddwd xmm6,dqword ptr [ebx+64] // CbRBCoeffs
     paddd xmm5,xmm6
     paddd xmm5,dqword ptr [ebx+144] // Add32768
     psrad xmm5,16
     packssdw xmm4,xmm5
     paddw xmm4,dqword ptr [ebx+112] // Add128
     packuswb xmm4,xmm4
     movq qword ptr [edx],xmm4  // Cb
     add edx,8

     // Cr
     movdqa xmm7,dqword ptr [ebx+80] // CrAGCoeffs
     movdqa xmm4,xmm0
     pmaddwd xmm4,xmm7 // CrAGCoeffs
     movdqa xmm5,xmm1
     pmaddwd xmm5,dqword ptr [ebx+96] // CrRBCoeffs
     paddd xmm4,xmm5
     paddd xmm4,dqword ptr [ebx+144] // Add32768
     psrad xmm4,16
     movdqa xmm5,xmm2
     pmaddwd xmm5,xmm7 // CrAGCoeffs
     movdqa xmm6,xmm3
     pmaddwd xmm6,dqword ptr [ebx+96] // CrRBCoeffs
     paddd xmm5,xmm6
     paddd xmm5,dqword ptr [ebx+144] // Add32768
     psrad xmm5,16
     packssdw xmm4,xmm5
     paddw xmm4,dqword ptr [ebx+112] // Add128
     packuswb xmm4,xmm4
     mov eax,dword ptr pDstCr
     movq qword ptr [eax],xmm4  // Ct
     add eax,8
     mov dword ptr pDstCr,eax
{$endif}

     dec esi
    jnz @Loop1Aligned
  @Loop1UnalignedDone:
   mov dword ptr pDstCb,edx
  @Done1:

  mov esi,dword ptr Count
  and esi,7
  test esi,esi
  jz @Done2
   @Loop2:

{$ifdef UseAlternativeSIMDColorConversionImplementation}
    // Y
    movzx eax,TpvUInt8 ptr [edi+0]
    imul eax,eax,YR
    shr eax,16

    movzx ebx,TpvUInt8 ptr [edi+1]
    imul ebx,ebx,YG
    shr ebx,16
    add eax,ebx

    movzx ebx,TpvUInt8 ptr [edi+2]
    imul ebx,ebx,YB
    shr ebx,16
    add eax,ebx

    mov ebx,eax
    and ebx,$ffffff00
    neg ebx
    sbb ebx,ebx
    or eax,ebx

    mov TpvUInt8 ptr [ecx],al
    inc ecx

    // Cb
    movzx eax,TpvUInt8 ptr [edi+0]
    imul eax,eax,Cb_R
    sar eax,16

    movzx ebx,TpvUInt8 ptr [edi+1]
    imul ebx,ebx,Cb_G
    sar ebx,16
    add eax,ebx

    movzx ebx,TpvUInt8 ptr [edi+2]
    imul ebx,ebx,Cb_B
    shr ebx,16
    lea eax,[eax+ebx+128]

    mov ebx,eax
    and ebx,$ffffff00
    neg ebx
    sbb ebx,ebx
    or eax,ebx

    mov edx,dword ptr pDstCb
    mov TpvUInt8 ptr [edx],al
    inc dword ptr pDstCb

    // Cr

    movzx eax,TpvUInt8 ptr [edi+0]
    imul eax,eax,Cr_R
    shr eax,16

    movzx ebx,TpvUInt8 ptr [edi+1]
    imul ebx,ebx,Cr_G
    sar ebx,16
    add eax,ebx

    movzx ebx,TpvUInt8 ptr [edi+2]
    imul ebx,ebx,Cr_B
    sar ebx,16
    lea eax,[eax+ebx+128]

    mov ebx,eax
    and ebx,$ffffff00
    neg ebx
    sbb ebx,ebx
    or eax,ebx

    mov edx,dword ptr pDstCr
    mov TpvUInt8 ptr [edx],al
    inc dword ptr pDstCr
{$else}
    // Y
    movzx eax,TpvUInt8 ptr [edi+0]
    imul eax,eax,YR
    movzx ebx,TpvUInt8 ptr [edi+1]
    imul ebx,ebx,YG
    lea eax,[eax+ebx+YA]
    movzx ebx,TpvUInt8 ptr [edi+2]
    imul ebx,ebx,YB
    add eax,ebx
    shr ebx,15

    mov ebx,eax
    and ebx,$ffffff00
    neg ebx
    sbb ebx,ebx
    or eax,ebx

    mov TpvUInt8 ptr [ecx],al
    inc ecx

    // Cb
    movzx eax,TpvUInt8 ptr [edi+0]
    imul eax,eax,Cb_R
    movzx ebx,TpvUInt8 ptr [edi+1]
    imul ebx,ebx,Cb_G
    lea eax,[eax+ebx+Cb_A]
    movzx ebx,TpvUInt8 ptr [edi+2]
    imul ebx,ebx,Cb_B
    add eax,ebx
    sar eax,16
    add eax,128

    mov ebx,eax
    and ebx,$ffffff00
    neg ebx
    sbb ebx,ebx
    or eax,ebx

    mov edx,dword ptr pDstCb
    mov TpvUInt8 ptr [edx],al
    inc dword ptr pDstCb

    // Cr
    movzx eax,TpvUInt8 ptr [edi+0]
    imul eax,eax,Cr_R
    movzx ebx,TpvUInt8 ptr [edi+1]
    imul ebx,ebx,Cr_G
    lea eax,[eax+ebx+Cr_A]
    movzx ebx,TpvUInt8 ptr [edi+2]
    imul ebx,ebx,Cr_B
    add eax,ebx
    sar eax,16
    add eax,128

    mov ebx,eax
    and ebx,$ffffff00
    neg ebx
    sbb ebx,ebx
    or eax,ebx

    mov edx,dword ptr pDstCr
    mov TpvUInt8 ptr [edx],al
    inc dword ptr pDstCr
{$endif}

    add edi,4

    dec esi
   jnz @Loop2
  @Done2:

 pop edi
 pop esi
 pop ebx
 pop eax
end;
{$else}
 {$error You must define PurePascal, since no inline assembler function variant doesn't exist for your target platform }
{$endif}
{$endif}

procedure TpvJPEGEncoder.ComputeHuffmanTable(Codes:PpvJPEGEncoderUInt32Array;CodeSizes,Bits,Values:PpvJPEGEncoderUInt8Array);
var i,l,LastP,si,p:TpvInt32;
    HuffmanSizes:array[0..256] of TpvUInt8;
    HuffmanCodes:array[0..256] of TpvUInt32;
    Code:TpvUInt32;
begin
 p:=0;
 for l:=1 to 16 do begin
  for i:=1 to Bits^[l] do begin
   HuffmanSizes[p]:=l;
   inc(p);
  end;
 end;
 HuffmanSizes[p]:=0;
 LastP:=p;
 Code:=0;
 si:=HuffmanSizes[0];
 p:=0;
 while HuffmanSizes[p]<>0 do begin
  while HuffmanSizes[p]=si do begin
   HuffmanCodes[p]:=Code;
   inc(p);
   inc(Code);
  end;
  Code:=Code shl 1;
  inc(si);
 end;
 FillChar(Codes^[0],SizeOf(TpvUInt32)*256,#0);
 FillChar(CodeSizes^[0],SizeOf(TpvUInt8)*256,#0);
 for p:=0 to LastP-1 do begin
  Codes^[Values^[p]]:=HuffmanCodes[p];
  CodeSizes^[Values^[p]]:=HuffmanSizes[p];
 end;
end;

function TpvJPEGEncoder.InitFirstPass:boolean;
begin
 fBitsBuffer:=0;
 fBitsBufferSize:=0;
 FillChar(fLastDCValues,SizeOf(fLastDCValues),#0);
 fMCUYOffset:=0;
 fPassIndex:=1;
 result:=true;
end;

function TpvJPEGEncoder.InitSecondPass:boolean;
begin
 ComputeHuffmanTable(TpvPointer(@fHuffmanCodes[0+0,0]),TpvPointer(@fHuffmanCodeSizes[0+0,0]),TpvPointer(@fHuffmanBits[0+0]),TpvPointer(@fHuffmanValues[0+0]));
 ComputeHuffmanTable(TpvPointer(@fHuffmanCodes[2+0,0]),TpvPointer(@fHuffmanCodeSizes[2+0,0]),TpvPointer(@fHuffmanBits[2+0]),TpvPointer(@fHuffmanValues[2+0]));
 if fCountComponents>1 then begin
  ComputeHuffmanTable(TpvPointer(@fHuffmanCodes[0+1,0]),TpvPointer(@fHuffmanCodeSizes[0+1,0]),TpvPointer(@fHuffmanBits[0+1]),TpvPointer(@fHuffmanValues[0+1]));
  ComputeHuffmanTable(TpvPointer(@fHuffmanCodes[2+1,0]),TpvPointer(@fHuffmanCodeSizes[2+1,0]),TpvPointer(@fHuffmanBits[2+1]),TpvPointer(@fHuffmanValues[2+1]));
 end;
 InitFirstPass;
 EmitMarkers;
 fPassIndex:=2;
 result:=true;
end;

procedure TpvJPEGEncoder.ComputeQuantizationTable(pDst:PpvJPEGEncoderInt32Array;pSrc:PpvJPEGEncoderInt16Array);
var q,i,j:TpvInt32;
begin
 if fQuality<50 then begin
  q:=5000 div fQuality;
 end else begin
  q:=200-(fQuality*2);
 end;
 for i:=0 to 63 do begin
  j:=((pSrc^[i]*q)+50) div 100;
  if j<1 then begin
   j:=1;
  end else if j>255 then begin
   j:=255;
  end;
  pDst^[i]:=j;
 end;
end;

function TpvJPEGEncoder.Setup(Width,Height:TpvInt32):boolean;
const StandardLumaQuantizationTable:array[0..63] of TpvInt16=(16,11,12,14,12,10,16,14,13,14,18,17,16,19,24,40,26,24,22,22,24,49,35,37,29,40,58,51,61,60,57,51,56,55,64,72,92,78,64,68,87,69,55,56,80,109,81,87,95,98,103,104,103,62,77,113,121,112,100,120,92,101,103,99);
      StandardChromaQuantizationTable:array[0..63] of TpvInt16=(17,18,18,24,21,24,47,26,26,47,99,66,56,66,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99);
      DCLumaBits:array[0..16] of TpvUInt8=(0,0,1,5,1,1,1,1,1,1,0,0,0,0,0,0,0);
      DCLumaValues:array[0..JPEG_DC_LUMA_CODES-1] of TpvUInt8=(0,1,2,3,4,5,6,7,8,9,10,11);
      ACLumaBits:array[0..16] of TpvUInt8=(0,0,2,1,3,3,2,4,3,5,5,4,4,0,0,1,$7d);
      ACLumaValues:array[0..JPEG_AC_LUMA_CODES-1] of TpvUInt8=(
        $01,$02,$03,$00,$04,$11,$05,$12,$21,$31,$41,$06,$13,$51,$61,$07,$22,$71,$14,$32,$81,$91,$a1,$08,$23,$42,$b1,$c1,$15,$52,$d1,$f0,
        $24,$33,$62,$72,$82,$09,$0a,$16,$17,$18,$19,$1a,$25,$26,$27,$28,$29,$2a,$34,$35,$36,$37,$38,$39,$3a,$43,$44,$45,$46,$47,$48,$49,
        $4a,$53,$54,$55,$56,$57,$58,$59,$5a,$63,$64,$65,$66,$67,$68,$69,$6a,$73,$74,$75,$76,$77,$78,$79,$7a,$83,$84,$85,$86,$87,$88,$89,
        $8a,$92,$93,$94,$95,$96,$97,$98,$99,$9a,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$aa,$b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9,$ba,$c2,$c3,$c4,$c5,
        $c6,$c7,$c8,$c9,$ca,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$da,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$e8,$e9,$ea,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,
        $f9,$fa,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
        $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
        $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       );
      DCChromaBits:array[0..16] of TpvUInt8=(0,0,3,1,1,1,1,1,1,1,1,1,0,0,0,0,0);
      DCChromaValues:array[0..JPEG_DC_CHROMA_CODES-1] of TpvUInt8=(0,1,2,3,4,5,6,7,8,9,10,11);
      ACChromaBits:array[0..16] of TpvUInt8=(0,0,2,1,2,4,4,3,4,7,5,4,4,0,1,2,$77);
      ACChromaValues:array[0..JPEG_AC_CHROMA_CODES-1] of TpvUInt8=(
        $00,$01,$02,$03,$11,$04,$05,$21,$31,$06,$12,$41,$51,$07,$61,$71,$13,$22,$32,$81,$08,$14,$42,$91,$a1,$b1,$c1,$09,$23,$33,$52,$f0,
        $15,$62,$72,$d1,$0a,$16,$24,$34,$e1,$25,$f1,$17,$18,$19,$1a,$26,$27,$28,$29,$2a,$35,$36,$37,$38,$39,$3a,$43,$44,$45,$46,$47,$48,
        $49,$4a,$53,$54,$55,$56,$57,$58,$59,$5a,$63,$64,$65,$66,$67,$68,$69,$6a,$73,$74,$75,$76,$77,$78,$79,$7a,$82,$83,$84,$85,$86,$87,
        $88,$89,$8a,$92,$93,$94,$95,$96,$97,$98,$99,$9a,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$aa,$b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9,$ba,$c2,$c3,
        $c4,$c5,$c6,$c7,$c8,$c9,$ca,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$da,$e2,$e3,$e4,$e5,$e6,$e7,$e8,$e9,$ea,$f2,$f3,$f4,$f5,$f6,$f7,$f8,
        $f9,$fa,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
        $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
        $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       );
var c:TpvInt32;
    DataSize:TpvUInt32;
begin
 case fBlockEncodingMode of
  0:begin
   // Greyscale
   fCountComponents:=1;
   fComponentHSamples[0]:=1;
   fComponentVSamples[0]:=1;
   fMCUWidth:=8;
   fMCUHeight:=8;
  end;
  1:begin
   // H1V1
   fCountComponents:=3;
   fComponentHSamples[0]:=1;
   fComponentVSamples[0]:=1;
   fComponentHSamples[1]:=1;
   fComponentVSamples[1]:=1;
   fComponentHSamples[2]:=1;
   fComponentVSamples[2]:=1;
   fMCUWidth:=8;
   fMCUHeight:=8;
  end;
  2:begin
   // H2V1
   fCountComponents:=3;
   fComponentHSamples[0]:=2;
   fComponentVSamples[0]:=1;
   fComponentHSamples[1]:=1;
   fComponentVSamples[1]:=1;
   fComponentHSamples[2]:=1;
   fComponentVSamples[2]:=1;
   fMCUWidth:=16;
   fMCUHeight:=8;
  end;
  else {3:}begin
   // H2V2
   fCountComponents:=3;
   fComponentHSamples[0]:=2;
   fComponentVSamples[0]:=2;
   fComponentHSamples[1]:=1;
   fComponentVSamples[1]:=1;
   fComponentHSamples[2]:=1;
   fComponentVSamples[2]:=1;
   fMCUWidth:=16;
   fMCUHeight:=16;
  end;
 end;
 fImageWidth:=Width;
 fImageHeight:=Height;
 fImageWidthMCU:=((fImageWidth+fMCUWidth)-1) and not (fMCUWidth-1);
 fImageHeightMCU:=((fImageHeight+fMCUHeight)-1) and not (fMCUHeight-1);
 fMCUsPerRow:=fImageWidthMCU div fMCUWidth;
 DataSize:=fImageWidthMCU*fMCUHeight*3;
 if (not assigned(fDataMemory)) or (fDataMemorySize<DataSize) then begin
  fDataMemorySize:=DataSize;
  if assigned(fDataMemory) then begin
   ReallocMem(fDataMemory,fDataMemorySize);
  end else begin
   GetMem(fDataMemory,fDataMemorySize);
  end;
 end;
 for c:=0 to 2 do begin
  fMCUChannels[c]:=@PpvJPEGEncoderUInt8Array(fDataMemory)^[fImageWidthMCU*fMCUHeight*c];
 end;
 if (not (assigned(fTempChannelWords) and assigned(fTempChannelBytes))) or (fTempChannelSize<fImageWidth) then begin
  fTempChannelSize:=fImageWidth;
  if assigned(fTempChannelBytes) then begin
   ReallocMem(fTempChannelBytes,SizeOf(TpvUInt8)*fTempChannelSize);
  end else begin
   GetMem(fTempChannelBytes,SizeOf(TpvUInt8)*fTempChannelSize);
  end;
  if assigned(fTempChannelWords) then begin
   ReallocMem(fTempChannelWords,SizeOf(word)*fTempChannelSize);
  end else begin
   GetMem(fTempChannelWords,SizeOf(word)*fTempChannelSize);
  end;
 end;
 ComputeQuantizationTable(TpvPointer(@fQuantizationTables[0]),TpvPointer(@StandardLumaQuantizationTable));
 if fNoChromaDiscrimination then begin
  ComputeQuantizationTable(TpvPointer(@fQuantizationTables[1]),TpvPointer(@StandardLumaQuantizationTable));
 end else begin
  ComputeQuantizationTable(TpvPointer(@fQuantizationTables[1]),TpvPointer(@StandardChromaQuantizationTable));
 end;
 fOutputBufferLeft:=JPEG_OUTPUT_BUFFER_SIZE;
 fOutputBufferCount:=0;
 fOutputBufferPointer:=TpvPointer(@fOutputBuffer[0]);
 if fTwoPass then begin
  FillChar(fHuffmanCounts,SizeOf(fHuffmanCounts),#0);
  InitFirstPass;
 end else begin
  Move(DCLumaBits,fHuffmanBits[0+0],17);
  Move(DCLumaValues,fHuffmanValues[0+0],JPEG_DC_LUMA_CODES);
  Move(ACLumaBits,fHuffmanBits[2+0],17);
  Move(ACLumaValues,fHuffmanValues[2+0],JPEG_AC_LUMA_CODES);
  Move(DCChromaBits,fHuffmanBits[0+1],17);
  Move(DCChromaValues,fHuffmanValues[0+1],JPEG_DC_CHROMA_CODES);
  Move(ACChromaBits,fHuffmanBits[2+1],17);
  Move(ACChromaValues,fHuffmanValues[2+1],JPEG_AC_CHROMA_CODES);
  if not InitSecondPass then begin
   result:=false;
   exit;
  end;
 end;
 result:=true;
end;

procedure TpvJPEGEncoder.FlushOutputBuffer;
var i:TpvInt32;
begin
 if fOutputBufferCount>0 then begin
  for i:=0 to fOutputBufferCount-1 do begin
   EmitByte(fOutputBuffer[i]);
  end;
 end;
 fOutputBufferPointer:=TpvPointer(@fOutputBuffer[0]);
 fOutputBufferLeft:=JPEG_OUTPUT_BUFFER_SIZE;
 fOutputBufferCount:=0;
end;

procedure TpvJPEGEncoder.PutBits(Bits,Len:TpvUInt32);
var c:TpvUInt32;
begin
 inc(fBitsBufferSize,Len);
 fBitsBuffer:=fBitsBuffer or (Bits shl (24-fBitsBufferSize));
 while fBitsBufferSize>=8 do begin
  c:=(fBitsBuffer shr 16) and $ff;
  fOutputBufferPointer^:=c;
  inc(fOutputBufferPointer);
  inc(fOutputBufferCount);
  dec(fOutputBufferLeft);
  if fOutputBufferLeft=0 then begin
   FlushOutputBuffer;
  end;
  if c=$ff then begin
   fOutputBufferPointer^:=0;
   inc(fOutputBufferPointer);
   inc(fOutputBufferCount);
   dec(fOutputBufferLeft);
   if fOutputBufferLeft=0 then begin
    FlushOutputBuffer;
   end;
  end;
  fBitsBuffer:=fBitsBuffer shl 8;
  dec(fBitsBufferSize,8);
 end;
end;

procedure TpvJPEGEncoder.LoadBlock8x8(x,y,c:TpvInt32);
{$ifdef PurePascal}
{$ifdef cpu64}
type PInt64=^int64;
var i,w:TpvInt32;
    pSrc:PpvJPEGEncoderUInt8Array;
    r0,r1,r2,r3,r4,r5,r6,r7,r8:int64;
begin
 pSrc:=TpvPointer(@fMCUChannels[c]^[((y shl 3)*fImageWidthMCU)+(x shl 3)]);
 w:=fImageWidthMCU;
 // Load into registers (hopefully, when the optimizer by the compiler isn't dumb)
 r0:=int64(TpvPointer(@pSrc^[0])^);
 r1:=int64(TpvPointer(@pSrc^[w])^);
 r2:=int64(TpvPointer(@pSrc^[w*2])^);
 r3:=int64(TpvPointer(@pSrc^[w*3])^);
 r4:=int64(TpvPointer(@pSrc^[w*4])^);
 r5:=int64(TpvPointer(@pSrc^[w*5])^);
 r6:=int64(TpvPointer(@pSrc^[w*6])^);
 r7:=int64(TpvPointer(@pSrc^[w*7])^);
 // Write back from registers (hopefully, when the optimizer by the compiler isn't dumb)
 int64(TpvPointer(@fSamples8Bit[0])^):=r0;
 int64(TpvPointer(@fSamples8Bit[8])^):=r1;
 int64(TpvPointer(@fSamples8Bit[16])^):=r2;
 int64(TpvPointer(@fSamples8Bit[24])^):=r3;
 int64(TpvPointer(@fSamples8Bit[32])^):=r4;
 int64(TpvPointer(@fSamples8Bit[40])^):=r5;
 int64(TpvPointer(@fSamples8Bit[48])^):=r6;
 int64(TpvPointer(@fSamples8Bit[56])^):=r7;
end;
{$else}
{$ifdef MoreCompact}
type PInt64=^int64;
var i,w:TpvInt32;
    pSrc:PpvJPEGEncoderUInt8Array;
    pDst:PInt64;
begin
 w:=fImageWidthMCU;
 pSrc:=TpvPointer(@fMCUChannels[c]^[((y shl 3)*w)+(x shl 3)]);
 pDst:=TpvPointer(@fSamples8Bit[0]);
 for i:=0 to 7 do begin
  pDst^:=int64(TpvPointer(pSrc)^);
  inc(pDst);
  pSrc:=TpvPointer(@pSrc^[w]);
 end;
end;
{$else}
type PInt64=^int64;
var i,w:TpvInt32;
    pSrc:PpvJPEGEncoderUInt8Array;
begin
 pSrc:=TpvPointer(@fMCUChannels[c]^[((y shl 3)*fImageWidthMCU)+(x shl 3)]);
 w:=fImageWidthMCU;
 TpvUInt32(TpvPointer(@fSamples8Bit[0])^):=TpvUInt32(TpvPointer(@pSrc^[0])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[4])^):=TpvUInt32(TpvPointer(@pSrc^[4])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[8])^):=TpvUInt32(TpvPointer(@pSrc^[w])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[12])^):=TpvUInt32(TpvPointer(@pSrc^[w+4])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[16])^):=TpvUInt32(TpvPointer(@pSrc^[w*2])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[20])^):=TpvUInt32(TpvPointer(@pSrc^[(w*2)+4])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[24])^):=TpvUInt32(TpvPointer(@pSrc^[w*3])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[28])^):=TpvUInt32(TpvPointer(@pSrc^[(w*3)+4])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[32])^):=TpvUInt32(TpvPointer(@pSrc^[w*4])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[36])^):=TpvUInt32(TpvPointer(@pSrc^[(w*4)+4])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[40])^):=TpvUInt32(TpvPointer(@pSrc^[w*5])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[44])^):=TpvUInt32(TpvPointer(@pSrc^[(w*5)+4])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[48])^):=TpvUInt32(TpvPointer(@pSrc^[w*6])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[52])^):=TpvUInt32(TpvPointer(@pSrc^[(w*6)+4])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[56])^):=TpvUInt32(TpvPointer(@pSrc^[w*7])^);
 TpvUInt32(TpvPointer(@fSamples8Bit[60])^):=TpvUInt32(TpvPointer(@pSrc^[(w*7)+4])^);
end;
{$endif}
{$endif}
{$else}
{$ifdef cpu386}
var pSrc,pDst:TpvPointer;
    w:TpvInt32;
begin
 pSrc:=TpvPointer(@fMCUChannels[c]^[((y shl 3)*fImageWidthMCU)+(x shl 3)]);
 pDst:=TpvPointer(@fSamples8Bit[0]);
 w:=fImageWidthMCU;
 asm
  mov eax,dword ptr pSrc
  mov edx,dword ptr pDst
  mov ecx,dword ptr w
{$ifdef MoreCompact}
  push esi
   mov esi,8
   @loop:
    movq xmm0,qword ptr [eax]
    add	eax,ecx
    movq qword ptr [edx],xmm0
    add edx,8
    dec esi
   jne @loop
  pop esi
{$else}
  // Load into registers
  movq xmm0,qword ptr [eax]
  add eax,ecx
  movq xmm1,qword ptr [eax]
  add eax,ecx
  movq xmm2,qword ptr [eax]
  add eax,ecx
  movq xmm3,qword ptr [eax]
  add eax,ecx
  movq xmm4,qword ptr [eax]
  add eax,ecx
  movq xmm5,qword ptr [eax]
  add eax,ecx
  movq xmm6,qword ptr [eax]
  movq xmm7,qword ptr [eax+ecx]
  // Write back from registers
  movq qword ptr [edx],xmm0
  movq qword ptr [edx+8],xmm1
  movq qword ptr [edx+16],xmm2
  movq qword ptr [edx+24],xmm3
  movq qword ptr [edx+32],xmm4
  movq qword ptr [edx+40],xmm5
  movq qword ptr [edx+48],xmm6
  movq qword ptr [edx+56],xmm7
{$endif}
 end;
end;
{$else}
 {$error You must define PurePascal, since no inline assembler function variant doesn't exist for your target platform }
{$endif}
{$endif}

procedure TpvJPEGEncoder.LoadBlock16x8(x,c:TpvInt32);
{$ifdef PurePascal}
var a,b,i,t,w:TpvInt32;
    pDst,pSrc,pSrc1,pSrc2:PpvJPEGEncoderUInt8Array;
begin
 a:=0;
 b:=2;
 w:=fImageWidthMCU;
 pDst:=TpvPointer(@fSamples8Bit[0]);
 pSrc:=TpvPointer(@fMCUChannels[c]^[x shl 4]);
 for i:=0 to 7 do begin
  pSrc1:=pSrc;
  pSrc2:=TpvPointer(@pSrc1^[w]);
  pSrc:=TpvPointer(@pSrc2^[w]);
  pDst^[0]:=(pSrc1^[0]+pSrc1^[1]+pSrc2^[0]+pSrc2^[1]+a) shr 2;
  pDst^[1]:=(pSrc1^[2]+pSrc1^[3]+pSrc2^[2]+pSrc2^[3]+b) shr 2;
  pDst^[2]:=(pSrc1^[4]+pSrc1^[5]+pSrc2^[4]+pSrc2^[5]+a) shr 2;
  pDst^[3]:=(pSrc1^[6]+pSrc1^[7]+pSrc2^[6]+pSrc2^[7]+b) shr 2;
  pDst^[4]:=(pSrc1^[8]+pSrc1^[9]+pSrc2^[8]+pSrc2^[9]+a) shr 2;
  pDst^[5]:=(pSrc1^[10]+pSrc1^[11]+pSrc2^[10]+pSrc2^[11]+b) shr 2;
  pDst^[6]:=(pSrc1^[12]+pSrc1^[13]+pSrc2^[12]+pSrc2^[13]+a) shr 2;
  pDst^[7]:=(pSrc1^[14]+pSrc1^[15]+pSrc2^[14]+pSrc2^[15]+b) shr 2;
  t:=a;
  a:=b;
  b:=t;
  pDst:=TpvPointer(@PDst[8]);
 end;
end;
{$else}
{$ifdef cpu386}
const xmm00ff00ff00ff00ff00ff00ff00ff00ff:array[0..15] of TpvUInt8=($ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00);
      xmm00020002000200020002000200020002:array[0..15] of TpvUInt8=($02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00);
var pSrc,pDst:TpvPointer;
    w:TpvInt32;
begin
 pSrc:=TpvPointer(@fMCUChannels[c]^[x shl 4]);
 pDst:=TpvPointer(@fSamples8Bit[0]);
 w:=fImageWidthMCU;
 asm
  push esi
   movdqu xmm4,[xmm00ff00ff00ff00ff00ff00ff00ff00ff]
   movdqu xmm5,[xmm00020002000200020002000200020002]
   mov eax,dword ptr pSrc
   mov edx,dword ptr pDst
   mov ecx,dword ptr w
   mov esi,4
   // for(int i = 0; i < 16; i += 4){
   @loop:
    movdqu xmm1,[eax] // r0 = _mm_loadu_si128((const __m128i*)pSrc);
    add eax,ecx // pSrc += w;
    movdqu xmm0,[eax] // r1 = _mm_loadu_si128((const __m128i*)pSrc);
    add eax,ecx // pSrc += w;
    movdqa xmm3,xmm0
    psrlw xmm0,8 // b1 = _mm_srli_epi16(r1, 8); // u1' 0 u3' 0 u5' 0 ...
    pand xmm3,xmm4 // a1 = _mm_and_si128(r1, mask); // u0' 0 u2' 0 u4' 0 ...
    movdqu xmm2,[eax] // r0 = _mm_loadu_si128((const __m128i*)pSrc);
    add eax,ecx // pSrc += w;
    paddw xmm3,xmm0 // a1b1 = _mm_add_epi16(a1, b1);
    movdqa xmm0,xmm1
    psrlw xmm1,8 // b0 = _mm_srli_epi16(r0, 8); // u1 0 u3 0 u5 0 ...
    pand xmm0,xmm4 // a0 = _mm_and_si128(r0, mask); // u0 0 u2 0 u4 0 ...
    paddw xmm0,xmm1 // a0b0 = _mm_add_epi16(a0, b0);
    paddw xmm3,xmm0 // res0 = _mm_add_epi16(a0b0, a1b1);
    movdqu xmm0,[eax] // r1 = _mm_loadu_si128((const __m128i*)pSrc);
    add eax,ecx // pSrc += w;
    paddw xmm3,xmm5 // res0 = _mm_add_epi16(res0, delta);
    psrlw xmm3,2 // res0 = _mm_srli_epi16(res0, 2);
    movdqa xmm1,xmm0
    psrlw xmm0,8 // b1 = _mm_srli_epi16(r1, 8); // u1' 0 u3' 0 u5' 0 ...
    pand xmm1,xmm4 // a1 = _mm_and_si128(r1, mask); // u0' 0 u2' 0 u4' 0 ...
    paddw xmm1,xmm0 // a1b1 = _mm_add_epi16(a1, b1);
    movdqa xmm0,xmm2
    psrlw xmm2,8 // b0 = _mm_srli_epi16(r0, 8); // u1 0 u3 0 u5 0 ...
    pand xmm0,xmm4 // a0 = _mm_and_si128(r0, mask); // u0 0 u2 0 u4 0 ...
    paddw xmm0,xmm2 // a0b0 = _mm_add_epi16(a0, b0);
    paddw xmm1,xmm0 // res1 = _mm_add_epi16(a0b0, a1b1);
    paddw xmm1,xmm5 // res1 = _mm_add_epi16(res1, delta);
    psrlw xmm1,2 // res1 = _mm_srli_epi16(res1, 2);
    packuswb xmm3,xmm1 // res0 = _mm_packus_epi16(res0, res1);
    movdqu [edx],xmm3 // _mm_storeu_si128((__m128i*)pDst, res0);
    add	edx,16 // pDst += 16
    dec esi
   jne @loop
  pop esi
 end;
end;
{$else}
 {$error You must define PurePascal, since no inline assembler function variant doesn't exist for your target platform }
{$endif}
{$endif}

procedure TpvJPEGEncoder.LoadBlock16x8x8(x,c:TpvInt32);
{$ifdef PurePascal}
var i,w:TpvInt32;
    pDst,pSrc:PpvJPEGEncoderUInt8Array;
begin
 w:=fImageWidthMCU;
 pDst:=TpvPointer(@fSamples8Bit[0]);
 pSrc:=TpvPointer(@fMCUChannels[c]^[x shl 4]);
 for i:=0 to 7 do begin
  pDst[0]:=(pSrc[0]+pSrc[1]) shr 1;
  pDst[1]:=(pSrc[2]+pSrc[3]) shr 1;
  pDst[2]:=(pSrc[4]+pSrc[5]) shr 1;
  pDst[3]:=(pSrc[6]+pSrc[7]) shr 1;
  pDst[4]:=(pSrc[8]+pSrc[9]) shr 1;
  pDst[5]:=(pSrc[10]+pSrc[11]) shr 1;
  pDst[6]:=(pSrc[12]+pSrc[13]) shr 1;
  pDst[7]:=(pSrc[14]+pSrc[15]) shr 1;
  pDst:=TpvPointer(@PDst[8]);
  pSrc:=TpvPointer(@pSrc^[w]);
 end;
end;
{$else}
{$ifdef cpu386}
const xmm00ff00ff00ff00ff00ff00ff00ff00ff:array[0..15] of TpvUInt8=($ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00,$ff,$00);
var pSrc,pDst:TpvPointer;
    w:TpvInt32;
begin
 pSrc:=TpvPointer(@fMCUChannels[c]^[x shl 4]);
 pDst:=TpvPointer(@fSamples8Bit[0]);
 w:=fImageWidthMCU;
 asm
  push esi
   movdqu xmm3,[xmm00ff00ff00ff00ff00ff00ff00ff00ff]
   mov eax,dword ptr pSrc
   mov edx,dword ptr pDst
   mov ecx,dword ptr w
   mov esi,4
   // for(int i = 0; i < 8; i += 2){
   @loop:
    movdqu xmm0,[eax] // r0 = _mm_loadu_si128((const __m128i*)pSrc);
    add eax,ecx // pSrc += w;
    movdqa xmm1,xmm0
    psrlw xmm0,8 // b0 = _mm_srli_epi16(r0, 8); // u1 0 u3 0 u5 0 ...
    pand xmm1,xmm3 // a0 = _mm_and_si128(r0, mask); // u0 0 u2 0 u4 0 ...
    movdqu xmm2,[eax] // r1 = _mm_loadu_si128((const __m128i*)pSrc);
    add eax,ecx // pSrc += w;
    paddw xmm1,xmm0 // _mm_add_epi16(a0, b0);
    psrlw xmm1,1 // r0 = _mm_srli_epi16(r0, 1);
    movdqa xmm0,xmm2
    psrlw xmm2,8 // b1 = _mm_srli_epi16(r1, 8); // u1 0 u3 0 u5 0 ...
    pand xmm0,xmm3 // a1 = _mm_and_si128(r1, mask); // u0 0 u2 0 u4 0 ...
    paddw xmm0,xmm2 // r1 = _mm_add_epi16(a1, b1);
    psrlw xmm0,1 // r1 = _mm_srli_epi16(r1, 1);
    packuswb xmm1,xmm0 // r0 = _mm_packus_epi16(r0, r1);
    movdqu [edx],xmm1 // _mm_storeu_si128((__m128i*)pDst, r0);
    add edx,16 // pDst += 16
    dec esi
   jne @loop
  pop esi
 end;
end;
{$else}
 {$error You must define PurePascal, since no inline assembler function variant doesn't exist for your target platform }
{$endif}
{$endif}

{$ifndef PurePascal}
{$ifdef cpu386}
{$ifdef UseAlternativeSIMDDCT2DImplementation}
procedure DCT2DSSE(InputData,OutputData:TpvPointer); assembler; stdcall;
const _FIX_6b_=-480;
      _rounder_11_=-464;
      _FIX_6a_=-448;
      _rounder_18_=-432;
      _FIX_1_=-416;
      _FIX_3a_=-400;
      _FIX_5a_=-384;
      _FIX_2_=-368;
      _FIX_5b_=-352;
      _FIX_4b_=-336;
      _FIX_4a_=-320;
      _FIX_3b_=-304;
      _k_128_=-288;
      _rounder_5_=-272;
      _data_=-256;
      _buffer_=-128;
      __xmm_00000400000004000000040000000400:array[0..15] of TpvUInt8=($00,$04,$00,$00,$00,$04,$00,$00,$00,$04,$00,$00,$00,$04,$00,$00);
      __xmm_00024000000240000002400000024000:array[0..15] of TpvUInt8=($00,$40,$02,$00,$00,$40,$02,$00,$00,$40,$02,$00,$00,$40,$02,$00);
      __xmm_00120012001200120012001200120012:array[0..15] of TpvUInt8=($12,$00,$12,$00,$12,$00,$12,$00,$12,$00,$12,$00,$12,$00,$12,$00);
      __xmm_115129cf115129cf115129cf115129cf:array[0..15] of TpvUInt8=($cf,$29,$51,$11,$cf,$29,$51,$11,$cf,$29,$51,$11,$cf,$29,$51,$11);
      __xmm_d6301151d6301151d6301151d6301151:array[0..15] of TpvUInt8=($51,$11,$30,$d6,$51,$11,$30,$d6,$51,$11,$30,$d6,$51,$11,$30,$d6);
      __xmm_08d4192508d4192508d4192508d41925:array[0..15] of TpvUInt8=($25,$19,$d4,$08,$25,$19,$d4,$08,$25,$19,$d4,$08,$25,$19,$d4,$08);
      __xmm_25a12c6325a12c6325a12c6325a12c63:array[0..15] of TpvUInt8=($63,$2c,$a1,$25,$63,$2c,$a1,$25,$63,$2c,$a1,$25,$63,$2c,$a1,$25);
      __xmm_e6dcd39ee6dcd39ee6dcd39ee6dcd39e:array[0..15] of TpvUInt8=($9e,$d3,$dc,$e6,$9e,$d3,$dc,$e6,$9e,$d3,$dc,$e6,$9e,$d3,$dc,$e6);
      __xmm_f72d25a1f72d25a1f72d25a1f72d25a1:array[0..15] of TpvUInt8=($a1,$25,$2d,$f7,$a1,$25,$2d,$f7,$a1,$25,$2d,$f7,$a1,$25,$2d,$f7);
      __xmm_25a108d525a108d525a108d525a108d5:array[0..15] of TpvUInt8=($d5,$08,$a1,$25,$d5,$08,$a1,$25,$d5,$08,$a1,$25,$d5,$08,$a1,$25);
      __xmm_d39e1925d39e1925d39e1925d39e1925:array[0..15] of TpvUInt8=($25,$19,$9e,$d3,$25,$19,$9e,$d3,$25,$19,$9e,$d3,$25,$19,$9e,$d3);
      __xmm_d39d25a1d39d25a1d39d25a1d39d25a1:array[0..15] of TpvUInt8=($a1,$25,$9d,$d3,$a1,$25,$9d,$d3,$a1,$25,$9d,$d3,$a1,$25,$9d,$d3);
      __xmm_e6dc08d4e6dc08d4e6dc08d4e6dc08d4:array[0..15] of TpvUInt8=($d4,$04,$dc,$e6,$d4,$04,$dc,$e6,$d4,$04,$dc,$e6,$d4,$04,$dc,$e6);
      __xmm_00800080008000800080008000800080:array[0..15] of TpvUInt8=($80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00);
asm
 mov ecx,esp
 sub esp,512
 and esp,$fffffff0
 movdqu xmm0,dqword ptr __xmm_00000400000004000000040000000400
 movdqa dqword ptr [esp+480+_rounder_11_],xmm0
 movdqu xmm0,dqword ptr __xmm_00024000000240000002400000024000
 movdqa dqword ptr [esp+480+_rounder_18_],xmm0
 movdqu xmm0,dqword ptr __xmm_00120012001200120012001200120012
 movdqa dqword ptr [esp+480+_rounder_5_],xmm0
 movdqu xmm0,dqword ptr __xmm_115129cf115129cf115129cf115129cf
 movdqa dqword ptr [esp+480+_FIX_1_],xmm0
 movdqu xmm0,dqword ptr __xmm_d6301151d6301151d6301151d6301151
 movdqa dqword ptr [esp+480+_FIX_2_],xmm0
 movdqu xmm0,dqword ptr __xmm_08d4192508d4192508d4192508d41925
 movdqa dqword ptr [esp+480+_FIX_3a_],xmm0
 movdqu xmm0,dqword ptr __xmm_25a12c6325a12c6325a12c6325a12c63
 movdqa dqword ptr [esp+480+_FIX_3b_],xmm0
 movdqu xmm0,dqword ptr __xmm_e6dcd39ee6dcd39ee6dcd39ee6dcd39e
 movdqa dqword ptr [esp+480+_FIX_4a_],xmm0
 movdqu xmm0,dqword ptr __xmm_f72d25a1f72d25a1f72d25a1f72d25a1
 movdqa dqword ptr [esp+480+_FIX_4b_],xmm0
 movdqu xmm0,dqword ptr __xmm_25a108d525a108d525a108d525a108d5
 movdqa dqword ptr [esp+480+_FIX_5a_],xmm0
 movdqu xmm0,dqword ptr __xmm_d39e1925d39e1925d39e1925d39e1925
 movdqa dqword ptr [esp+480+_FIX_5b_],xmm0
 movdqu xmm0,dqword ptr __xmm_d39d25a1d39d25a1d39d25a1d39d25a1
 movdqa dqword ptr [esp+480+_FIX_6a_],xmm0
 movdqu xmm0,dqword ptr __xmm_e6dc08d4e6dc08d4e6dc08d4e6dc08d4
 movdqa dqword ptr [esp+480+_FIX_6b_],xmm0
 movdqu xmm0,dqword ptr __xmm_00800080008000800080008000800080
 movdqa dqword ptr [esp+480+_k_128_],xmm0
 push eax
 push edx
 lea eax,dword ptr [esp+488+_data_]
 mov edx,dword ptr InputData
 pxor xmm7,xmm7
 movdqa xmm6,dqword ptr [esp+488+_k_128_]
 movq xmm0,qword ptr [edx]
 movq xmm1,qword ptr [edx+8]
 movq xmm2,qword ptr [edx+16]
 movq xmm3,qword ptr [edx+24]
 movq xmm4,qword ptr [edx+32]
 movq xmm5,qword ptr [edx+40]
 punpcklbw xmm0,xmm7
 punpcklbw xmm1,xmm7
 punpcklbw xmm2,xmm7
 punpcklbw xmm3,xmm7
 punpcklbw xmm4,xmm7
 punpcklbw xmm5,xmm7
 psubw xmm0,xmm6
 psubw xmm1,xmm6
 psubw xmm2,xmm6
 psubw xmm3,xmm6
 psubw xmm4,xmm6
 psubw xmm5,xmm6
 movdqa dqword ptr [eax],xmm0
 movdqa dqword ptr [eax+16],xmm1
 movq xmm0,qword ptr [edx+48]
 movq xmm1,qword ptr [edx+56]
 punpcklbw xmm0,xmm7
 punpcklbw xmm1,xmm7
 psubw xmm0,xmm6
 psubw xmm1,xmm6
 movdqa dqword ptr [eax+32],xmm2
 movdqa dqword ptr [eax+48],xmm3
 movdqa dqword ptr [eax+64],xmm4
 movdqa dqword ptr [eax+80],xmm5
 movdqa dqword ptr [eax+96],xmm0
 movdqa dqword ptr [eax+112],xmm1
 lea edx,dword ptr [esp+488+_buffer_]
 prefetchnta TpvUInt8 ptr [esp+488+_FIX_1_]
 prefetchnta TpvUInt8 ptr [esp+488+_FIX_3a_]
 prefetchnta TpvUInt8 ptr [esp+488+_FIX_5a_]
 movdqa xmm0,dqword ptr [eax]
 movdqa xmm6,dqword ptr [eax+32]
 movdqa xmm4,dqword ptr [eax+64]
 movdqa xmm7,dqword ptr [eax+96]
 punpckhwd xmm0,dqword ptr [eax+16]
 movdqa xmm2,xmm0
 punpckhwd xmm6,dqword ptr [eax+48]
 punpckhwd xmm4,dqword ptr [eax+80]
 movdqa xmm5,xmm4
 punpckhwd xmm7,dqword ptr [eax+112]
 punpckldq xmm0,xmm6
 movdqa xmm1,xmm0
 punpckldq xmm4,xmm7
 punpckhdq xmm2,xmm6
 movdqa xmm3,xmm2
 punpckhdq xmm5,xmm7
 punpcklqdq xmm0,xmm4
 punpcklqdq xmm2,xmm5
 punpckhqdq xmm1,xmm4
 punpckhqdq xmm3,xmm5
 movdqa dqword ptr [edx+64],xmm0
 movdqa dqword ptr [edx+80],xmm1
 movdqa dqword ptr [edx+96],xmm2
 movdqa dqword ptr [edx+112],xmm3
 movdqa xmm0,dqword ptr [eax]
 movdqa xmm6,dqword ptr [eax+32]
 movdqa xmm4,dqword ptr [eax+64]
 movdqa xmm7,dqword ptr [eax+96]
 punpcklwd xmm0,dqword ptr [eax+16]
 movdqa xmm2,xmm0
 punpcklwd xmm6,dqword ptr [eax+48]
 punpcklwd xmm4,dqword ptr [eax+80]
 movdqa xmm5,xmm4
 punpcklwd xmm7,dqword ptr [eax+112]
 punpckldq xmm0,xmm6
 movdqa xmm1,xmm0
 punpckldq xmm4,xmm7
 punpckhdq xmm2,xmm6
 movdqa xmm3,xmm2
 punpckhdq xmm5,xmm7
 punpcklqdq xmm0,xmm4
 punpcklqdq xmm2,xmm5
 punpckhqdq xmm1,xmm4
 punpckhqdq xmm3,xmm5
 movdqa dqword ptr [edx],xmm0
 movdqa dqword ptr [edx+16],xmm1
 movdqa dqword ptr [edx+32],xmm2
 movdqa dqword ptr [edx+48],xmm3
 paddsw xmm0,dqword ptr [edx+112]
 movdqa xmm4,xmm0
 paddsw xmm1,dqword ptr [edx+96]
 movdqa xmm5,xmm1
 paddsw xmm2,dqword ptr [edx+80]
 paddsw xmm3,dqword ptr [edx+64]
 paddsw xmm0,xmm3
 movdqa xmm6,xmm0
 paddsw xmm1,xmm2
 psubsw xmm4,xmm3
 psubsw xmm5,xmm2
 paddsw xmm0,xmm1
 psubsw xmm6,xmm1
 psllw xmm0,2
 psllw xmm6,2
 movdqa xmm1,xmm4
 movdqa xmm2,xmm4
 movdqa dqword ptr [eax],xmm0
 movdqa dqword ptr [eax+64],xmm6
 movdqa xmm7,dqword ptr [esp+488+_FIX_1_]
 punpckhwd xmm1,xmm5
 movdqa xmm6,xmm1
 punpcklwd xmm2,xmm5
 movdqa xmm0,xmm2
 movdqa xmm4,dqword ptr [esp+488+_FIX_2_]
 movdqa xmm5,dqword ptr [esp+488+_rounder_11_]
 pmaddwd xmm2,xmm7
 pmaddwd xmm1,xmm7
 pmaddwd xmm0,xmm4
 pmaddwd xmm6,xmm4
 paddd xmm2,xmm5
 paddd xmm1,xmm5
 psrad xmm2,11
 psrad xmm1,11
 packssdw xmm2,xmm1
 movdqa dqword ptr [eax+32],xmm2
 paddd xmm0,xmm5
 paddd xmm6,xmm5
 psrad xmm0,11
 psrad xmm6,11
 packssdw xmm0,xmm6
 movdqa dqword ptr [eax+96],xmm0
 movdqa xmm0,dqword ptr [edx]
 movdqa xmm1,dqword ptr [edx+16]
 movdqa xmm2,dqword ptr [edx+32]
 movdqa xmm3,dqword ptr [edx+48]
 psubsw xmm0,dqword ptr [edx+112]
 movdqa xmm4,xmm0
 psubsw xmm1,dqword ptr [edx+96]
 psubsw xmm2,dqword ptr [edx+80]
 movdqa xmm6,xmm2
 psubsw xmm3,dqword ptr [edx+64]
 punpckhwd xmm4,xmm1
 punpcklwd xmm0,xmm1
 punpckhwd xmm6,xmm3
 punpcklwd xmm2,xmm3
 movdqa xmm1,dqword ptr [esp+488+_FIX_3a_]
 movdqa xmm5,dqword ptr [esp+488+_FIX_3b_]
 movdqa xmm3,xmm1
 movdqa xmm7,xmm5
 pmaddwd xmm1,xmm2
 pmaddwd xmm5,xmm0
 paddd xmm1,xmm5
 movdqa xmm5,dqword ptr [esp+488+_rounder_11_]
 pmaddwd xmm3,xmm6
 pmaddwd xmm7,xmm4
 paddd xmm3,xmm7
 paddd xmm1,xmm5
 paddd xmm3,xmm5
 psrad xmm1,11
 psrad xmm3,11
 packssdw xmm1,xmm3
 movdqa dqword ptr [eax+16],xmm1
 movdqa xmm1,dqword ptr [esp+488+_FIX_4a_]
 movdqa xmm5,dqword ptr [esp+488+_FIX_4b_]
 movdqa xmm3,xmm1
 movdqa xmm7,xmm5
 pmaddwd xmm1,xmm2
 pmaddwd xmm5,xmm0
 paddd xmm1,xmm5
 movdqa xmm5,dqword ptr [esp+488+_rounder_11_]
 pmaddwd xmm3,xmm6
 pmaddwd xmm7,xmm4
 paddd xmm3,xmm7
 paddd xmm1,xmm5
 paddd xmm3,xmm5
 psrad xmm1,11
 psrad xmm3,11
 packssdw xmm1,xmm3
 movdqa dqword ptr [eax+48],xmm1
 movdqa xmm1,dqword ptr [esp+488+_FIX_5a_]
 movdqa xmm5,dqword ptr [esp+488+_FIX_5b_]
 movdqa xmm3,xmm1
 movdqa xmm7,xmm5
 pmaddwd xmm1,xmm2
 pmaddwd xmm5,xmm0
 paddd xmm1,xmm5
 movdqa xmm5,dqword ptr [esp+488+_rounder_11_]
 pmaddwd xmm3,xmm6
 pmaddwd xmm7,xmm4
 paddd xmm3,xmm7
 paddd xmm1,xmm5
 paddd xmm3,xmm5
 psrad xmm1,11
 psrad xmm3,11
 packssdw xmm1,xmm3
 movdqa dqword ptr [eax+80],xmm1
 pmaddwd xmm2,dqword ptr [esp+488+_FIX_6a_]
 pmaddwd xmm0,dqword ptr [esp+488+_FIX_6b_]
 paddd xmm2,xmm0
 pmaddwd xmm6,dqword ptr [esp+488+_FIX_6a_]
 pmaddwd xmm4,dqword ptr [esp+488+_FIX_6b_]
 paddd xmm6,xmm4
 paddd xmm2,xmm5
 paddd xmm6,xmm5
 psrad xmm2,11
 psrad xmm6,11
 packssdw xmm2,xmm6
 movdqa dqword ptr [eax+112],xmm2
 movdqa xmm0,dqword ptr [eax]
 movdqa xmm6,dqword ptr [eax+32]
 movdqa xmm4,dqword ptr [eax+64]
 movdqa xmm7,dqword ptr [eax+96]
 punpckhwd xmm0,dqword ptr [eax+16]
 movdqa xmm2,xmm0
 punpckhwd xmm6,dqword ptr [eax+48]
 punpckhwd xmm4,dqword ptr [eax+80]
 movdqa xmm5,xmm4
 punpckhwd xmm7,dqword ptr [eax+112]
 punpckldq xmm0,xmm6
 movdqa xmm1,xmm0
 punpckldq xmm4,xmm7
 punpckhdq xmm2,xmm6
 movdqa xmm3,xmm2
 punpckhdq xmm5,xmm7
 punpcklqdq xmm0,xmm4
 punpcklqdq xmm2,xmm5
 punpckhqdq xmm1,xmm4
 punpckhqdq xmm3,xmm5
 movdqa dqword ptr [edx+64],xmm0
 movdqa dqword ptr [edx+80],xmm1
 movdqa dqword ptr [edx+96],xmm2
 movdqa dqword ptr [edx+112],xmm3
 movdqa xmm0,dqword ptr [eax]
 movdqa xmm6,dqword ptr [eax+32]
 movdqa xmm4,dqword ptr [eax+64]
 movdqa xmm7,dqword ptr [eax+96]
 punpcklwd xmm0,dqword ptr [eax+16]
 movdqa xmm2,xmm0
 punpcklwd xmm6,dqword ptr [eax+48]
 punpcklwd xmm4,dqword ptr [eax+80]
 movdqa xmm5,xmm4
 punpcklwd xmm7,dqword ptr [eax+112]
 punpckldq xmm0,xmm6
 movdqa xmm1,xmm0
 punpckldq xmm4,xmm7
 punpckhdq xmm2,xmm6
 movdqa xmm3,xmm2
 punpckhdq xmm5,xmm7
 punpcklqdq xmm0,xmm4
 punpcklqdq xmm2,xmm5
 punpckhqdq xmm1,xmm4
 punpckhqdq xmm3,xmm5
 movdqa dqword ptr [edx],xmm0
 movdqa dqword ptr [edx+16],xmm1
 movdqa dqword ptr [edx+32],xmm2
 movdqa dqword ptr [edx+48],xmm3
 movdqa xmm7,dqword ptr [esp+488+_rounder_5_]
 paddsw xmm0,dqword ptr [edx+112]
 movdqa xmm4,xmm0
 paddsw xmm1,dqword ptr [edx+96]
 movdqa xmm5,xmm1
 paddsw xmm2,dqword ptr [edx+80]
 paddsw xmm3,dqword ptr [edx+64]
 paddsw xmm0,xmm3
 paddsw xmm0,xmm7
 psraw xmm0,5
 movdqa xmm6,xmm0
 paddsw xmm1,xmm2
 psubsw xmm4,xmm3
 psubsw xmm5,xmm2
 paddsw xmm1,xmm7
 psraw xmm1,5
 paddsw xmm0,xmm1
 psubsw xmm6,xmm1
 movdqa xmm1,xmm4
 movdqa xmm2,xmm4
 movdqa dqword ptr [eax],xmm0
 movdqa dqword ptr [eax+64],xmm6
 movdqa xmm7,dqword ptr [esp+488+_FIX_1_]
 punpckhwd xmm1,xmm5
 movdqa xmm6,xmm1
 punpcklwd xmm2,xmm5
 movdqa xmm0,xmm2
 movdqa xmm4,dqword ptr [esp+488+_FIX_2_]
 movdqa xmm5,dqword ptr [esp+488+_rounder_18_]
 pmaddwd xmm2,xmm7
 pmaddwd xmm1,xmm7
 pmaddwd xmm0,xmm4
 pmaddwd xmm6,xmm4
 paddd xmm2,xmm5
 paddd xmm1,xmm5
 psrad xmm2,18
 psrad xmm1,18
 packssdw xmm2,xmm1
 movdqa dqword ptr [eax+32],xmm2
 paddd xmm0,xmm5
 paddd xmm6,xmm5
 psrad xmm0,18
 psrad xmm6,18
 packssdw xmm0,xmm6
 movdqa dqword ptr [eax+96],xmm0
 movdqa xmm0,dqword ptr [edx]
 movdqa xmm1,dqword ptr [edx+16]
 movdqa xmm2,dqword ptr [edx+32]
 movdqa xmm3,dqword ptr [edx+48]
 psubsw xmm0,dqword ptr [edx+112]
 movdqa xmm4,xmm0
 psubsw xmm1,dqword ptr [edx+96]
 psubsw xmm2,dqword ptr [edx+80]
 movdqa xmm6,xmm2
 psubsw xmm3,dqword ptr [edx+64]
 punpckhwd xmm4,xmm1
 punpcklwd xmm0,xmm1
 punpckhwd xmm6,xmm3
 punpcklwd xmm2,xmm3
 movdqa xmm1,dqword ptr [esp+488+_FIX_3a_]
 movdqa xmm5,dqword ptr [esp+488+_FIX_3b_]
 movdqa xmm3,xmm1
 movdqa xmm7,xmm5
 pmaddwd xmm1,xmm2
 pmaddwd xmm5,xmm0
 paddd xmm1,xmm5
 movdqa xmm5,dqword ptr [esp+488+_rounder_18_]
 pmaddwd xmm3,xmm6
 pmaddwd xmm7,xmm4
 paddd xmm3,xmm7
 paddd xmm1,xmm5
 paddd xmm3,xmm5
 psrad xmm1,18
 psrad xmm3,18
 packssdw xmm1,xmm3
 movdqa dqword ptr [eax+16],xmm1
 movdqa xmm1,dqword ptr [esp+488+_FIX_4a_]
 movdqa xmm5,dqword ptr [esp+488+_FIX_4b_]
 movdqa xmm3,xmm1
 movdqa xmm7,xmm5
 pmaddwd xmm1,xmm2
 pmaddwd xmm5,xmm0
 paddd xmm1,xmm5
 movdqa xmm5,dqword ptr [esp+488+_rounder_18_]
 pmaddwd xmm3,xmm6
 pmaddwd xmm7,xmm4
 paddd xmm3,xmm7
 paddd xmm1,xmm5
 paddd xmm3,xmm5
 psrad xmm1,18
 psrad xmm3,18
 packssdw xmm1,xmm3
 movdqa dqword ptr [eax+48],xmm1
 movdqa xmm1,dqword ptr [esp+488+_FIX_5a_]
 movdqa xmm5,dqword ptr [esp+488+_FIX_5b_]
 movdqa xmm3,xmm1
 movdqa xmm7,xmm5
 pmaddwd xmm1,xmm2
 pmaddwd xmm5,xmm0
 paddd xmm1,xmm5
 movdqa xmm5,dqword ptr [esp+488+_rounder_18_]
 pmaddwd xmm3,xmm6
 pmaddwd xmm7,xmm4
 paddd xmm3,xmm7
 paddd xmm1,xmm5
 paddd xmm3,xmm5
 psrad xmm1,18
 psrad xmm3,18
 packssdw xmm1,xmm3
 movdqa dqword ptr [eax+80],xmm1
 pmaddwd xmm2,dqword ptr [esp+488+_FIX_6a_]
 pmaddwd xmm0,dqword ptr [esp+488+_FIX_6b_]
 paddd xmm2,xmm0
 pmaddwd xmm6,dqword ptr [esp+488+_FIX_6a_]
 pmaddwd xmm4,dqword ptr [esp+488+_FIX_6b_]
 paddd xmm6,xmm4
 paddd xmm2,xmm5
 paddd xmm6,xmm5
 psrad xmm2,18
 psrad xmm6,18
 packssdw xmm2,xmm6
 movdqa dqword ptr [eax+112],xmm2
 mov edx,dword ptr OutputData
 movdqa xmm0,dqword ptr [eax]
 movdqa xmm1,dqword ptr [eax+16]
 movdqa xmm2,dqword ptr [eax+32]
 movdqa xmm3,dqword ptr [eax+48]
 movdqa xmm4,dqword ptr [eax+64]
 movdqa xmm5,dqword ptr [eax+80]
 movdqa xmm6,dqword ptr [eax+96]
 movdqa xmm7,dqword ptr [eax+112]
 movdqu dqword ptr [edx],xmm0
 movdqu dqword ptr [edx+16],xmm1
 movdqu dqword ptr [edx+32],xmm2
 movdqu dqword ptr [edx+48],xmm3
 movdqu dqword ptr [edx+64],xmm4
 movdqu dqword ptr [edx+80],xmm5
 movdqu dqword ptr [edx+96],xmm6
 movdqu dqword ptr [edx+112],xmm7
 pop edx
 pop eax
 mov esp,ecx
end;
{$else}
{$ifdef GoodCompilerForSIMD}
procedure DCT2DSSE(InputData,OutputData:TpvPointer); assembler; stdcall;
const _x7_1_=-128;
      _t5_1_=-112;
      _b7_1_=-112;
      _a7_1_=-96;
      _y4_1_=-80;
      _y6_1_=-64;
      _y7_1_=-48;
      _b5_1_=-32;
      _t9_1_=-16;
      _y5_1_=-16;
      __xmm_00800080008000800080008000800080:array[0..15] of TpvUInt8=($80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00);
      __xmm_00004000000040000000400000004000:array[0..15] of TpvUInt8=($00,$40,$00,$00,$00,$40,$00,$00,$00,$40,$00,$00,$00,$40,$00,$00);
      __xmm_35053505350535053505350535053505:array[0..15] of TpvUInt8=($05,$35,$05,$35,$05,$35,$05,$35,$05,$35,$05,$35,$05,$35,$05,$35);
      __xmm_5a825a825a825a825a825a825a825a82:array[0..15] of TpvUInt8=($82,$5a,$82,$5a,$82,$5a,$82,$5a,$82,$5a,$82,$5a,$82,$5a,$82,$5a);
      __xmm_a57ea57ea57ea57ea57ea57ea57ea57e:array[0..15] of TpvUInt8=($7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5);
      __xmm_19761976197619761976197619761976:array[0..15] of TpvUInt8=($76,$19,$76,$19,$76,$19,$76,$19,$76,$19,$76,$19,$76,$19,$76,$19);
      __xmm_55875587558755875587558755875587:array[0..15] of TpvUInt8=($87,$55,$87,$55,$87,$55,$87,$55,$87,$55,$87,$55,$87,$55,$87,$55);
      __xmm_aa79aa79aa79aa79aa79aa79aa79aa79:array[0..15] of TpvUInt8=($79,$aa,$79,$aa,$79,$aa,$79,$aa,$79,$aa,$79,$aa,$79,$aa,$79,$aa);
      __xmm_163114e712d00fff12d014e716310fff:array[0..15] of TpvUInt8=($ff,$0f,$31,$16,$e7,$14,$d0,$12,$ff,$0f,$d0,$12,$e7,$14,$31,$16);
      __xmm_1ec81cfe1a1816311a181cfe1ec81631:array[0..15] of TpvUInt8=($31,$16,$c8,$1e,$fe,$1c,$18,$1a,$31,$16,$18,$1a,$fe,$1c,$c8,$1e);
      __xmm_1cfe1b50189414e718941b501cfe14e7:array[0..15] of TpvUInt8=($e7,$14,$fe,$1c,$50,$1b,$94,$18,$e7,$14,$94,$18,$50,$1b,$fe,$1c);
      __xmm_1a181894161f12d0161f18941a1812d0:array[0..15] of TpvUInt8=($d0,$12,$18,$1a,$94,$18,$1f,$16,$d0,$12,$1f,$16,$94,$18,$18,$1a);
asm
 mov edx,esp
 sub esp,160
 and esp,$fffffff0
 mov eax,dword ptr InputData
 xorps xmm1,xmm1
 movdqu xmm0,dqword ptr __xmm_00800080008000800080008000800080
 movq xmm2,qword ptr [eax+32]
 movq xmm5,qword ptr [eax]
 movq xmm6,qword ptr [eax+8]
 movq xmm4,qword ptr [eax+16]
 movq xmm3,qword ptr [eax+24]
 movq xmm7,qword ptr [eax+40]
 punpcklbw xmm2,xmm1
 psubw xmm2,xmm0
 punpcklbw xmm5,xmm1
 movdqa dqword ptr [esp+128+_y4_1_],xmm2
 psubw xmm5,xmm0
 movq xmm2,qword ptr [eax+48]
 punpcklbw xmm2,xmm1
 psubw xmm2,xmm0
 punpcklbw xmm6,xmm1
 movdqa dqword ptr [esp+128+_y6_1_],xmm2
 psubw xmm6,xmm0
 movq xmm2,qword ptr [eax+56]
 mov eax,2
 punpcklbw xmm2,xmm1
 punpcklbw xmm4,xmm1
 psubw xmm2,xmm0
 punpcklbw xmm3,xmm1
 psubw xmm4,xmm0
 punpcklbw xmm7,xmm1
 psubw xmm3,xmm0
 movdqa dqword ptr [esp+128+_x7_1_],xmm5
 psubw xmm7,xmm0
 movdqa dqword ptr [esp+128+_y7_1_],xmm2
 jmp @LoopEntry
 nop
 @Loop:
  movdqa xmm7,dqword ptr [esp+128+_y5_1_]
 @LoopEntry:
  movdqa xmm0,dqword ptr [esp+128+_x7_1_]
  movdqa xmm1,xmm3
  punpckhwd xmm0,dqword ptr [esp+128+_y4_1_]
  movdqa xmm2,xmm6
  punpckhwd xmm3,dqword ptr [esp+128+_y7_1_]
  punpcklwd xmm5,dqword ptr [esp+128+_y4_1_]
  punpcklwd xmm1,dqword ptr [esp+128+_y7_1_]
  movdqa dqword ptr [esp+128+_x7_1_],xmm0
  movdqa xmm0,xmm4
  punpcklwd xmm0,dqword ptr [esp+128+_y6_1_]
  punpckhwd xmm4,dqword ptr [esp+128+_y6_1_]
  punpckhwd xmm6,xmm7
  punpcklwd xmm2,xmm7
  movdqa xmm7,xmm5
  punpckhwd xmm5,xmm0
  punpcklwd xmm7,xmm0
  movdqa xmm0,dqword ptr [esp+128+_x7_1_]
  movdqa dqword ptr [esp+128+_b7_1_],xmm3
  movdqa xmm3,xmm0
  punpckhwd xmm0,xmm4
  movdqa dqword ptr [esp+128+_x7_1_],xmm0
  movdqa xmm0,xmm2
  punpcklwd xmm0,xmm1
  punpcklwd xmm3,xmm4
  movdqa xmm4,xmm5
  punpckhwd xmm2,xmm1
  movdqa xmm1,xmm6
  punpckhwd xmm6,dqword ptr [esp+128+_b7_1_]
  punpcklwd xmm1,dqword ptr [esp+128+_b7_1_]
  punpckhwd xmm5,xmm2
  movdqa dqword ptr [esp+128+_a7_1_],xmm6
  movdqa xmm6,xmm7
  punpcklwd xmm6,xmm0
  punpckhwd xmm7,xmm0
  movdqa dqword ptr [esp+128+_t5_1_],xmm5
  movdqa xmm5,dqword ptr [esp+128+_x7_1_]
  movdqa xmm0,xmm5
  punpcklwd xmm4,xmm2
  punpcklwd xmm0,dqword ptr [esp+128+_a7_1_]
  movdqa xmm2,xmm3
  punpckhwd xmm5,dqword ptr [esp+128+_a7_1_]
  punpckhwd xmm3,xmm1
  punpcklwd xmm2,xmm1
  movdqa xmm1,xmm3
  movdqa dqword ptr [esp+128+_x7_1_],xmm5
  paddsw xmm1,xmm4
  paddsw xmm5,xmm6
  psubsw xmm4,xmm3
  psubsw xmm6,dqword ptr [esp+128+_x7_1_]
  movdqa xmm3,dqword ptr [esp+128+_t5_1_]
  movdqa dqword ptr [esp+128+_t9_1_],xmm6
  movdqa xmm6,xmm0
  paddsw xmm6,xmm7
  psubsw xmm7,xmm0
  movdqa xmm0,xmm2
  paddsw xmm0,xmm3
  psubsw xmm3,xmm2
  movdqa dqword ptr [esp+128+_t5_1_],xmm3
  movdqa xmm2,xmm4
  movdqa xmm3,xmm0
  paddsw xmm2,xmm7
  paddsw xmm3,xmm5
  psubsw xmm7,xmm4
  movdqa xmm4,dqword ptr __xmm_00004000000040000000400000004000
  psubsw xmm5,xmm0
  movdqa xmm0,xmm1
  paddsw xmm0,xmm6
  psubsw xmm6,xmm1
  movdqa xmm1,xmm3
  psubsw xmm3,xmm0
  paddsw xmm1,xmm0
  movdqa dqword ptr [esp+128+_y4_1_],xmm3
  movdqa dqword ptr [esp+128+_x7_1_],xmm1
  movdqa xmm1,dqword ptr __xmm_35053505350535053505350535053505
  movdqa xmm0,xmm1
  pmullw xmm1,xmm6
  pmulhw xmm0,xmm6
  movdqa xmm3,xmm1
  punpcklwd xmm3,xmm0
  paddd xmm3,xmm4
  psrad xmm3,15
  punpckhwd xmm1,xmm0
  paddd xmm1,xmm4
  pslld xmm3,16
  psrad xmm1,15
  psrad xmm3,16
  pslld xmm1,16
  psrad xmm1,16
  packssdw xmm3,xmm1
  movdqa xmm1,dqword ptr __xmm_35053505350535053505350535053505
  paddsw xmm3,xmm5
  movdqa xmm0,xmm1
  movdqa dqword ptr [esp+128+_b5_1_],xmm3
  pmullw xmm1,xmm5
  pmulhw xmm0,xmm5
  movdqa xmm3,xmm1
  punpckhwd xmm1,xmm0
  paddd xmm1,xmm4
  punpcklwd xmm3,xmm0
  paddd xmm3,xmm4
  psrad xmm1,15
  psrad xmm3,15
  pslld xmm1,16
  pslld xmm3,16
  psrad xmm1,16
  psrad xmm3,16
  packssdw xmm3,xmm1
  movdqa xmm1,dqword ptr __xmm_5a825a825a825a825a825a825a825a82
  psubsw xmm3,xmm6
  movdqa xmm0,xmm1
  movdqa xmm6,dqword ptr __xmm_a57ea57ea57ea57ea57ea57ea57ea57e
  pmullw xmm1,xmm7
  pmulhw xmm0,xmm7
  movdqa dqword ptr [esp+128+_y6_1_],xmm3
  movdqa xmm3,xmm1
  punpckhwd xmm1,xmm0
  paddd xmm1,xmm4
  punpcklwd xmm3,xmm0
  psrad xmm1,15
  paddd xmm3,xmm4
  psrad xmm3,15
  movdqa xmm0,xmm6
  pslld xmm1,16
  pslld xmm3,16
  psrad xmm1,16
  psrad xmm3,16
  pmulhw xmm0,xmm7
  packssdw xmm3,xmm1
  movdqa xmm1,xmm6
  pmullw xmm1,xmm7
  movdqa xmm7,dqword ptr __xmm_00004000000040000000400000004000
  paddsw xmm3,dqword ptr [esp+128+_t5_1_]
  movdqa xmm5,xmm1
  punpckhwd xmm1,xmm0
  punpcklwd xmm5,xmm0
  paddd xmm1,xmm7
  psrad xmm1,15
  paddd xmm5,xmm7
  psrad xmm5,15
  movdqa xmm0,xmm6
  pslld xmm1,16
  pslld xmm5,16
  psrad xmm1,16
  psrad xmm5,16
  pmulhw xmm0,xmm2
  packssdw xmm5,xmm1
  movdqa xmm1,xmm6
  paddsw xmm5,dqword ptr [esp+128+_t5_1_]
  pmullw xmm1,xmm2
  movdqa xmm4,xmm1
  punpckhwd xmm1,xmm0
  punpcklwd xmm4,xmm0
  paddd xmm1,xmm7
  paddd xmm4,xmm7
  psrad xmm1,15
  psrad xmm4,15
  pslld xmm1,16
  pslld xmm4,16
  psrad xmm1,16
  psrad xmm4,16
  packssdw xmm4,xmm1
  paddsw xmm4,dqword ptr [esp+128+_t9_1_]
  movdqa xmm1,dqword ptr __xmm_5a825a825a825a825a825a825a825a82
  movdqa xmm0,xmm1
  pmullw xmm1,xmm2
  pmulhw xmm0,xmm2
  movdqa xmm2,xmm1
  punpckhwd xmm1,xmm0
  punpcklwd xmm2,xmm0
  paddd xmm1,xmm7
  psrad xmm1,15
  paddd xmm2,xmm7
  psrad xmm2,15
  pslld xmm1,16
  pslld xmm2,16
  psrad xmm1,16
  psrad xmm2,16
  packssdw xmm2,xmm1
  movdqa xmm1,dqword ptr __xmm_19761976197619761976197619761976
  paddsw xmm2,dqword ptr [esp+128+_t9_1_]
  movdqa xmm0,xmm1
  pmullw xmm1,xmm3
  pmulhw xmm0,xmm3
  movdqa xmm6,xmm1
  punpckhwd xmm1,xmm0
  paddd xmm1,xmm7
  punpcklwd xmm6,xmm0
  psrad xmm1,15
  paddd xmm6,xmm7
  psrad xmm6,15
  pslld xmm1,16
  pslld xmm6,16
  psrad xmm1,16
  psrad xmm6,16
  packssdw xmm6,xmm1
  movdqa xmm1,dqword ptr __xmm_19761976197619761976197619761976
  paddsw xmm6,xmm2
  movdqa xmm0,xmm1
  movdqa dqword ptr [esp+128+_a7_1_],xmm6
  pmullw xmm1,xmm2
  pmulhw xmm0,xmm2
  movdqa xmm2,xmm1
  punpcklwd xmm2,xmm0
  punpckhwd xmm1,xmm0
  paddd xmm2,xmm7
  paddd xmm1,xmm7
  psrad xmm2,15
  psrad xmm1,15
  pslld xmm2,16
  pslld xmm1,16
  psrad xmm2,16
  psrad xmm1,16
  packssdw xmm2,xmm1
  movdqa xmm1,dqword ptr __xmm_55875587558755875587558755875587
  psubsw xmm2,xmm3
  movdqa xmm0,xmm1
  movdqa dqword ptr [esp+128+_y7_1_],xmm2
  pmullw xmm1,xmm4
  pmulhw xmm0,xmm4
  movdqa xmm2,xmm1
  punpcklwd xmm2,xmm0
  punpckhwd xmm1,xmm0
  paddd xmm2,xmm7
  paddd xmm1,xmm7
  psrad xmm2,15
  psrad xmm1,15
  pslld xmm2,16
  pslld xmm1,16
  psrad xmm2,16
  psrad xmm1,16
  packssdw xmm2,xmm1
  movdqa xmm1,dqword ptr __xmm_aa79aa79aa79aa79aa79aa79aa79aa79
  paddsw xmm2,xmm5
  movdqa xmm0,xmm1
  movdqa dqword ptr [esp+128+_y5_1_],xmm2
  pmullw xmm1,xmm5
  pmulhw xmm0,xmm5
  movdqa xmm3,xmm1
  punpcklwd xmm3,xmm0
  paddd xmm3,xmm7
  psrad xmm3,15
  pslld xmm3,16
  psrad xmm3,16
  movdqa xmm5,dqword ptr [esp+128+_x7_1_]
  punpckhwd xmm1,xmm0
  paddd xmm1,xmm7
  psrad xmm1,15
  pslld xmm1,16
  psrad xmm1,16
  packssdw xmm3,xmm1
  paddsw xmm3,xmm4
  movdqa xmm4,dqword ptr [esp+128+_b5_1_]
  movdqa dqword ptr [esp+128+_b7_1_],xmm3
  dec eax
 jne @Loop
 movdqa xmm3,dqword ptr __xmm_163114e712d00fff12d014e716310fff
 mov eax,dword ptr OutputData
 movdqa xmm2,xmm3
 pmullw xmm2,dqword ptr [esp+128+_x7_1_]
 movdqa xmm1,xmm3
 pmulhw xmm1,dqword ptr [esp+128+_x7_1_]
 movdqa xmm6,dqword ptr __xmm_1ec81cfe1a1816311a181cfe1ec81631
 movdqa xmm5,dqword ptr __xmm_1cfe1b50189414e718941b501cfe14e7
 movdqa xmm4,dqword ptr __xmm_1a181894161f12d0161f18941a1812d0
 movdqa xmm0,xmm2
 punpckhwd xmm2,xmm1
 punpcklwd xmm0,xmm1
 paddd xmm2,xmm7
 psrad xmm2,15
 xorps xmm1,xmm1
 paddd xmm0,xmm7
 pslld xmm2,16
 psrad xmm0,15
 psrad xmm2,16
 pslld xmm0,16
 psrad xmm0,16
 packssdw xmm0,xmm2
 movdqa xmm2,xmm6
 pmullw xmm2,dqword ptr [esp+128+_a7_1_]
 paddsw xmm0,xmm1
 movdqu dqword ptr [eax],xmm0
 movdqa xmm0,xmm6
 pmulhw xmm0,dqword ptr [esp+128+_a7_1_]
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm7
 psrad xmm1,15
 paddd xmm2,xmm7
 psrad xmm2,15
 xorps xmm0,xmm0
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 movdqa xmm2,xmm5
 pmullw xmm2,dqword ptr [esp+128+_b5_1_]
 paddsw xmm1,xmm0
 movdqu dqword ptr [eax+16],xmm1
 movdqa xmm0,xmm5
 pmulhw xmm0,dqword ptr [esp+128+_b5_1_]
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm7
 paddd xmm2,xmm7
 psrad xmm1,15
 psrad xmm2,15
 xorps xmm0,xmm0
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 movdqa xmm2,xmm4
 pmullw xmm2,dqword ptr [esp+128+_b7_1_]
 paddsw xmm1,xmm0
 movdqu dqword ptr [eax+32],xmm1
 movdqa xmm0,xmm4
 pmulhw xmm0,dqword ptr [esp+128+_b7_1_]
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm7
 paddd xmm2,xmm7
 psrad xmm1,15
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 xorps xmm2,xmm2
 paddsw xmm1,xmm2
 movdqu dqword ptr [eax+48],xmm1
 movdqa xmm0,xmm3
 pmullw xmm3,dqword ptr [esp+128+_y4_1_]
 pmulhw xmm0,dqword ptr [esp+128+_y4_1_]
 movdqa xmm1,xmm3
 punpcklwd xmm1,xmm0
 paddd xmm1,xmm7
 punpckhwd xmm3,xmm0
 psrad xmm1,15
 paddd xmm3,xmm7
 psrad xmm3,15
 movdqa xmm0,xmm4
 pmullw xmm4,dqword ptr [esp+128+_y5_1_]
 pmulhw xmm0,dqword ptr [esp+128+_y5_1_]
 pslld xmm1,16
 pslld xmm3,16
 psrad xmm1,16
 psrad xmm3,16
 packssdw xmm1,xmm3
 paddsw xmm1,xmm2
 movdqu dqword ptr [eax+64],xmm1
 movdqa xmm1,xmm4
 punpckhwd xmm4,xmm0
 punpcklwd xmm1,xmm0
 paddd xmm4,xmm7
 paddd xmm1,xmm7
 psrad xmm4,15
 psrad xmm1,15
 movdqa xmm0,xmm5
 pmullw xmm5,dqword ptr [esp+128+_y6_1_]
 pmulhw xmm0,dqword ptr [esp+128+_y6_1_]
 pslld xmm1,16
 pslld xmm4,16
 psrad xmm1,16
 psrad xmm4,16
 packssdw xmm1,xmm4
 paddsw xmm1,xmm2
 movdqu dqword ptr [eax+80],xmm1
 movdqa xmm1,xmm5
 punpckhwd xmm5,xmm0
 punpcklwd xmm1,xmm0
 paddd xmm5,xmm7
 paddd xmm1,xmm7
 psrad xmm5,15
 psrad xmm1,15
 movdqa xmm0,xmm6
 pmullw xmm6,dqword ptr [esp+128+_y7_1_]
 pmulhw xmm0,dqword ptr [esp+128+_y7_1_]
 pslld xmm1,16
 pslld xmm5,16
 psrad xmm1,16
 psrad xmm5,16
 packssdw xmm1,xmm5
 paddsw xmm1,xmm2
 movdqu dqword ptr [eax+96],xmm1
 movdqa xmm1,xmm6
 punpckhwd xmm6,xmm0
 punpcklwd xmm1,xmm0
 paddd xmm6,xmm7
 paddd xmm1,xmm7
 psrad xmm6,15
 psrad xmm1,15
 pslld xmm6,16
 pslld xmm1,16
 psrad xmm6,16
 psrad xmm1,16
 packssdw xmm1,xmm6
 paddsw xmm1,xmm2
 movdqu dqword ptr [eax+112],xmm1
 mov esp,edx
end;
{$else}
procedure DCT2DSSE(InputData,OutputData:TpvPointer); assembler; stdcall;
const _tmp_lo_1=-224;
      _c_=-208;
      _vx_16_=-192;
      _vx_15_=-192;
      _vy_15_=-192;
      _t5_2_=-176;
      _b5_2_=-176;
      _k__128_=-176;
      _t9_2_=-160;
      _t9_1_=-160;
      _a7_1_=-160;
      _t5_1_=-144;
      _vy_20_=-128;
      _vy_1_=-128;
      _vy_14_=-112;
      _vy_9_=-112;
      _a7_2_=-112;
      _vy_21_=-96;
      _c13573_=-96;
      _c23170_=-80;
      _vy_24_=-64;
      _c6518_=-64;
      _cNeg21895_=-48;
      _c21895_=-32;
      _cNeg23170_=-16;
      __xmm_35053505350535053505350535053505:array[0..15] of TpvUInt8=($05,$35,$05,$35,$05,$35,$05,$35,$05,$35,$05,$35,$05,$35,$05,$35);
      __xmm_55875587558755875587558755875587:array[0..15] of TpvUInt8=($87,$55,$87,$55,$87,$55,$87,$55,$87,$55,$87,$55,$87,$55,$87,$55);
      __xmm_aa79aa79aa79aa79aa79aa79aa79aa79:array[0..15] of TpvUInt8=($79,$aa,$79,$aa,$79,$aa,$79,$aa,$79,$aa,$79,$aa,$79,$aa,$79,$aa);
      __xmm_5a825a825a825a825a825a825a825a82:array[0..15] of TpvUInt8=($82,$5a,$82,$5a,$82,$5a,$82,$5a,$82,$5a,$82,$5a,$82,$5a,$82,$5a);
      __xmm_a57ea57ea57ea57ea57ea57ea57ea57e:array[0..15] of TpvUInt8=($7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5,$7e,$a5);
      __xmm_19761976197619761976197619761976:array[0..15] of TpvUInt8=($76,$19,$76,$19,$76,$19,$76,$19,$76,$19,$76,$19,$76,$19,$76,$19);
      __xmm_00004000000040000000400000004000:array[0..15] of TpvUInt8=($00,$40,$00,$00,$00,$40,$00,$00,$00,$40,$00,$00,$00,$40,$00,$00);
      __xmm_00800080008000800080008000800080:array[0..15] of TpvUInt8=($80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00);
      PostScaleArray:array[0..63] of TpvInt16=(
       4095,5681,5351,4816,4095,4816,5351,5681,
       5681,7880,7422,6680,5681,6680,7422,7880,
       5351,7422,6992,6292,5351,6292,6992,7422,
       4816,6680,6292,5663,4816,5663,6292,6680,
       4095,5681,5351,4816,4095,4816,5351,5681,
       4816,6680,6292,5663,4816,5663,6292,6680,
       5351,7422,6992,6292,5351,6292,6992,7422,
       5681,7880,7422,6680,5681,6680,7422,7880
      );
asm
 mov edx,esp
 sub esp,272
 and esp,$fffffff0
 movdqu xmm0,dqword ptr __xmm_35053505350535053505350535053505
 xorps xmm5,xmm5
 movdqa dqword ptr [esp+256+_c13573_],xmm0
 movdqu xmm0,dqword ptr __xmm_55875587558755875587558755875587
 movdqa dqword ptr [esp+256+_c21895_],xmm0
 movdqu xmm0,dqword ptr __xmm_aa79aa79aa79aa79aa79aa79aa79aa79
 mov eax,dword ptr InputData
 movdqa dqword ptr [esp+256+_cNeg21895_],xmm0
 movdqu xmm0,dqword ptr __xmm_5a825a825a825a825a825a825a825a82
 movdqa dqword ptr [esp+256+_c23170_],xmm0
 movdqu xmm0,dqword ptr __xmm_a57ea57ea57ea57ea57ea57ea57ea57e
 movdqa dqword ptr [esp+256+_cNeg23170_],xmm0
 movdqu xmm0,dqword ptr __xmm_19761976197619761976197619761976
 movdqa dqword ptr [esp+256+_c6518_],xmm0
 movdqu xmm0,dqword ptr __xmm_00004000000040000000400000004000
 movdqa dqword ptr [esp+256+_c_],xmm0
 movdqu xmm0,dqword ptr __xmm_00800080008000800080008000800080
 movq xmm6,qword ptr [eax+16]
 movq xmm7,qword ptr [eax+24]
 movq xmm1,qword ptr [eax+40]
 movq xmm2,qword ptr [eax+48]
 movq xmm3,qword ptr [eax+56]
 movdqa dqword ptr [esp+256+_k__128_],xmm0
 movdqa xmm4,dqword ptr [esp+256+_k__128_]
 movq xmm0,qword ptr [eax]
 punpcklbw xmm0,xmm5
 psubw xmm0,xmm4
 punpcklbw xmm1,xmm5
 movdqa dqword ptr [esp+256+_vx_15_],xmm0
 psubw xmm1,xmm4
 movq xmm0,qword ptr [eax+8]
 punpcklbw xmm0,xmm5
 psubw xmm0,xmm4
 punpcklbw xmm3,xmm5
 movdqa dqword ptr [esp+256+_a7_1_],xmm0
 psubw xmm3,xmm4
 movq xmm0,qword ptr [eax+32]
 punpcklbw xmm0,xmm5
 psubw xmm0,xmm4
 punpcklbw xmm7,xmm5
 punpcklbw xmm2,xmm5
 psubw xmm7,xmm4
 psubw xmm2,xmm4
 punpcklbw xmm6,xmm5
 psubw xmm6,xmm4
 movdqa xmm4,dqword ptr [esp+256+_vx_15_]
 movdqa xmm5,xmm4
 punpckhwd xmm4,xmm0
 punpcklwd xmm5,xmm0
 movdqa xmm0,xmm6
 movdqa dqword ptr [esp+256+_t5_1_],xmm5
 movdqa xmm5,dqword ptr [esp+256+_a7_1_]
 movdqa dqword ptr [esp+256+_vx_15_],xmm4
 movdqa xmm4,xmm5
 punpcklwd xmm4,xmm1
 punpckhwd xmm5,xmm1
 movdqa xmm1,xmm7
 punpcklwd xmm1,xmm3
 punpckhwd xmm7,xmm3
 movdqa xmm3,dqword ptr [esp+256+_t5_1_]
 punpcklwd xmm0,xmm2
 punpckhwd xmm6,xmm2
 movdqa xmm2,xmm3
 punpckhwd xmm3,xmm0
 punpcklwd xmm2,xmm0
 movdqa xmm0,dqword ptr [esp+256+_vx_15_]
 movdqa dqword ptr [esp+256+_t5_1_],xmm3
 movdqa xmm3,xmm0
 punpckhwd xmm0,xmm6
 movdqa dqword ptr [esp+256+_vx_15_],xmm0
 movdqa xmm0,xmm4
 punpcklwd xmm0,xmm1
 punpckhwd xmm4,xmm1
 movdqa xmm1,xmm5
 punpckhwd xmm5,xmm7
 punpcklwd xmm1,xmm7
 movdqa xmm7,xmm2
 punpcklwd xmm3,xmm6
 movdqa dqword ptr [esp+256+_a7_1_],xmm5
 punpcklwd xmm7,xmm0
 punpckhwd xmm2,xmm0
 movdqa xmm0,dqword ptr [esp+256+_t5_1_]
 movdqa xmm5,xmm0
 movdqa dqword ptr [esp+256+_tmp_lo_1],xmm2
 punpckhwd xmm0,xmm4
 movdqa xmm2,xmm3
 punpckhwd xmm3,xmm1
 punpcklwd xmm2,xmm1
 movdqa xmm1,dqword ptr [esp+256+_tmp_lo_1]
 movdqa dqword ptr [esp+256+_t5_1_],xmm0
 punpcklwd xmm5,xmm4
 movdqa xmm4,dqword ptr [esp+256+_vx_15_]
 movdqa xmm0,xmm4
 punpckhwd xmm4,dqword ptr [esp+256+_a7_1_]
 punpcklwd xmm0,dqword ptr [esp+256+_a7_1_]
 movdqa xmm6,xmm4
 paddsw xmm6,xmm7
 psubsw xmm7,xmm4
 movdqa xmm4,xmm0
 movdqa dqword ptr [esp+256+_t9_1_],xmm7
 paddsw xmm4,xmm1
 psubsw xmm1,xmm0
 movdqa dqword ptr [esp+256+_tmp_lo_1],xmm1
 movdqa xmm0,xmm2
 movdqa xmm1,xmm3
 paddsw xmm1,xmm5
 psubsw xmm5,xmm3
 movdqa xmm3,dqword ptr [esp+256+_t5_1_]
 movdqa xmm7,xmm5
 paddsw xmm0,xmm3
 psubsw xmm3,xmm2
 movdqa xmm2,dqword ptr [esp+256+_tmp_lo_1]
 movdqa dqword ptr [esp+256+_t5_1_],xmm3
 paddsw xmm7,xmm2
 movdqa xmm3,xmm0
 psubsw xmm2,xmm5
 movdqa xmm5,dqword ptr [esp+256+_c13573_]
 paddsw xmm3,xmm6
 psubsw xmm6,xmm0
 movdqa xmm0,xmm1
 paddsw xmm0,xmm4
 psubsw xmm4,xmm1
 movdqa xmm1,xmm3
 psubsw xmm3,xmm0
 paddsw xmm1,xmm0
 movdqa dqword ptr [esp+256+_vy_14_],xmm3
 movdqa dqword ptr [esp+256+_vx_16_],xmm1
 movdqa xmm0,xmm4
 pmulhw xmm0,xmm5
 movdqa xmm1,xmm4
 pmullw xmm1,xmm5
 movdqa xmm3,xmm1
 punpckhwd xmm1,xmm0
 paddd xmm1,dqword ptr [esp+256+_c_]
 punpcklwd xmm3,xmm0
 movdqa xmm0,xmm6
 paddd xmm3,dqword ptr [esp+256+_c_]
 psrad xmm1,15
 psrad xmm3,15
 pslld xmm1,16
 pslld xmm3,16
 psrad xmm1,16
 psrad xmm3,16
 pmulhw xmm0,xmm5
 packssdw xmm3,xmm1
 paddsw xmm3,xmm6
 pmullw xmm6,xmm5
 movdqa xmm5,dqword ptr [esp+256+_c_]
 movdqa dqword ptr [esp+256+_b5_2_],xmm3
 movdqa xmm1,xmm6
 punpckhwd xmm6,xmm0
 punpcklwd xmm1,xmm0
 paddd xmm6,xmm5
 paddd xmm1,xmm5
 psrad xmm6,15
 psrad xmm1,15
 pslld xmm6,16
 pslld xmm1,16
 psrad xmm6,16
 psrad xmm1,16
 packssdw xmm1,xmm6
 psubsw xmm1,xmm4
 movdqa xmm4,dqword ptr [esp+256+_cNeg23170_]
 movdqa xmm0,xmm2
 pmulhw xmm0,dqword ptr [esp+256+_c23170_]
 movdqa dqword ptr [esp+256+_vy_20_],xmm1
 movdqa xmm1,xmm2
 pmullw xmm1,dqword ptr [esp+256+_c23170_]
 movdqa xmm3,xmm1
 punpckhwd xmm1,xmm0
 paddd xmm1,xmm5
 punpcklwd xmm3,xmm0
 paddd xmm3,xmm5
 psrad xmm1,15
 movdqa xmm0,xmm2
 psrad xmm3,15
 pmullw xmm2,xmm4
 pslld xmm1,16
 pmulhw xmm0,xmm4
 psrad xmm1,16
 pslld xmm3,16
 movdqa xmm5,xmm2
 psrad xmm3,16
 punpckhwd xmm2,xmm0
 paddd xmm2,dqword ptr [esp+256+_c_]
 packssdw xmm3,xmm1
 movdqa xmm1,xmm7
 punpcklwd xmm5,xmm0
 movdqa xmm0,xmm7
 paddd xmm5,dqword ptr [esp+256+_c_]
 paddsw xmm3,dqword ptr [esp+256+_t5_1_]
 pmullw xmm1,xmm4
 pmulhw xmm0,xmm4
 movdqa xmm4,dqword ptr [esp+256+_c_]
 psrad xmm2,15
 psrad xmm5,15
 movdqa xmm6,xmm1
 pslld xmm2,16
 punpckhwd xmm1,xmm0
 punpcklwd xmm6,xmm0
 paddd xmm1,xmm4
 movdqa xmm0,xmm7
 psrad xmm2,16
 pmullw xmm7,dqword ptr [esp+256+_c23170_]
 paddd xmm6,xmm4
 pmulhw xmm0,dqword ptr [esp+256+_c23170_]
 pslld xmm5,16
 psrad xmm1,15
 psrad xmm5,16
 psrad xmm6,15
 packssdw xmm5,xmm2
 movdqa xmm2,xmm7
 punpckhwd xmm7,xmm0
 punpcklwd xmm2,xmm0
 paddd xmm7,xmm4
 paddsw xmm5,dqword ptr [esp+256+_t5_1_]
 paddd xmm2,xmm4
 movdqa xmm4,dqword ptr [esp+256+_c6518_]
 movdqa xmm0,xmm3
 pslld xmm1,16
 pslld xmm6,16
 psrad xmm7,15
 psrad xmm1,16
 psrad xmm6,16
 psrad xmm2,15
 pslld xmm7,16
 packssdw xmm6,xmm1
 movdqa xmm1,xmm3
 paddsw xmm6,dqword ptr [esp+256+_t9_1_]
 psrad xmm7,16
 pslld xmm2,16
 pmullw xmm1,xmm4
 psrad xmm2,16
 pmulhw xmm0,xmm4
 packssdw xmm2,xmm7
 paddsw xmm2,dqword ptr [esp+256+_t9_1_]
 movdqa xmm7,xmm1
 punpcklwd xmm7,xmm0
 paddd xmm7,dqword ptr [esp+256+_c_]
 psrad xmm7,15
 punpckhwd xmm1,xmm0
 pslld xmm7,16
 psrad xmm7,16
 paddd xmm1,dqword ptr [esp+256+_c_]
 movdqa xmm0,xmm2
 psrad xmm1,15
 pmulhw xmm0,xmm4
 pslld xmm1,16
 psrad xmm1,16
 packssdw xmm7,xmm1
 movdqa xmm1,xmm6
 pmullw xmm1,dqword ptr [esp+256+_c21895_]
 paddsw xmm7,xmm2
 pmullw xmm2,xmm4
 movdqa xmm4,xmm2
 punpckhwd xmm2,xmm0
 paddd xmm2,dqword ptr [esp+256+_c_]
 punpcklwd xmm4,xmm0
 movdqa xmm0,xmm6
 paddd xmm4,dqword ptr [esp+256+_c_]
 pmulhw xmm0,dqword ptr [esp+256+_c21895_]
 psrad xmm2,15
 psrad xmm4,15
 pslld xmm2,16
 pslld xmm4,16
 psrad xmm2,16
 psrad xmm4,16
 packssdw xmm4,xmm2
 movdqa xmm2,xmm1
 punpckhwd xmm1,xmm0
 psubsw xmm4,xmm3
 movdqa xmm3,dqword ptr [esp+256+_c_]
 punpcklwd xmm2,xmm0
 paddd xmm1,xmm3
 paddd xmm2,xmm3
 psrad xmm1,15
 psrad xmm2,15
 movdqa xmm0,xmm5
 pmulhw xmm0,dqword ptr [esp+256+_cNeg21895_]
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm2,xmm1
 paddsw xmm2,xmm5
 pmullw xmm5,dqword ptr [esp+256+_cNeg21895_]
 movdqa dqword ptr [esp+256+_tmp_lo_1],xmm5
 movdqa xmm1,dqword ptr [esp+256+_tmp_lo_1]
 punpckhwd xmm1,xmm0
 punpcklwd xmm5,xmm0
 paddd xmm1,xmm3
 paddd xmm5,xmm3
 psrad xmm1,15
 psrad xmm5,15
 movdqa xmm3,xmm7
 pslld xmm1,16
 pslld xmm5,16
 psrad xmm1,16
 psrad xmm5,16
 punpckhwd xmm7,xmm2
 packssdw xmm5,xmm1
 movdqa xmm1,dqword ptr [esp+256+_vx_16_]
 paddsw xmm5,xmm6
 movdqa xmm6,xmm1
 punpcklwd xmm3,xmm2
 punpckhwd xmm1,dqword ptr [esp+256+_vy_14_]
 movdqa xmm2,dqword ptr [esp+256+_b5_2_]
 punpcklwd xmm6,dqword ptr [esp+256+_vy_14_]
 movdqa xmm0,xmm2
 punpckhwd xmm2,dqword ptr [esp+256+_vy_20_]
 punpcklwd xmm0,dqword ptr [esp+256+_vy_20_]
 movdqa dqword ptr [esp+256+_vx_16_],xmm1
 movdqa xmm1,xmm5
 movdqa dqword ptr [esp+256+_b5_2_],xmm2
 movdqa xmm2,xmm6
 movdqa dqword ptr [esp+256+_a7_2_],xmm7
 movdqa xmm7,dqword ptr [esp+256+_vx_16_]
 punpckhwd xmm7,dqword ptr [esp+256+_b5_2_]
 punpcklwd xmm1,xmm4
 punpckhwd xmm5,xmm4
 movdqa xmm4,dqword ptr [esp+256+_vx_16_]
 punpcklwd xmm4,dqword ptr [esp+256+_b5_2_]
 punpcklwd xmm2,xmm0
 punpckhwd xmm6,xmm0
 movdqa dqword ptr [esp+256+_vx_16_],xmm7
 movdqa xmm0,xmm3
 movdqa xmm7,dqword ptr [esp+256+_a7_2_]
 punpcklwd xmm0,xmm1
 punpckhwd xmm3,xmm1
 movdqa xmm1,xmm7
 punpcklwd xmm1,xmm5
 punpckhwd xmm7,xmm5
 movdqa xmm5,xmm2
 punpckhwd xmm2,xmm0
 punpcklwd xmm5,xmm0
 movdqa dqword ptr [esp+256+_tmp_lo_1],xmm2
 movdqa xmm2,xmm4
 punpcklwd xmm2,xmm1
 punpckhwd xmm4,xmm1
 movdqa dqword ptr [esp+256+_t9_2_],xmm5
 movdqa xmm5,xmm6
 movdqa xmm1,dqword ptr [esp+256+_t9_2_]
 punpckhwd xmm6,xmm3
 punpcklwd xmm5,xmm3
 movdqa xmm3,dqword ptr [esp+256+_vx_16_]
 movdqa xmm0,xmm3
 movdqa dqword ptr [esp+256+_t5_2_],xmm6
 punpckhwd xmm3,xmm7
 punpcklwd xmm0,xmm7
 movdqa xmm6,xmm3
 movdqa xmm7,dqword ptr [esp+256+_tmp_lo_1]
 paddsw xmm6,xmm1
 psubsw xmm1,xmm3
 movdqa xmm3,xmm0
 movdqa dqword ptr [esp+256+_t9_2_],xmm1
 paddsw xmm3,xmm7
 psubsw xmm7,xmm0
 movdqa xmm1,xmm4
 paddsw xmm1,xmm5
 movdqa xmm0,xmm2
 psubsw xmm5,xmm4
 movdqa xmm4,dqword ptr [esp+256+_t5_2_]
 paddsw xmm0,xmm4
 psubsw xmm4,xmm2
 movdqa xmm2,xmm0
 movdqa dqword ptr [esp+256+_t5_2_],xmm4
 paddsw xmm2,xmm6
 movdqa xmm4,xmm5
 psubsw xmm6,xmm0
 paddsw xmm4,xmm7
 movdqa xmm0,xmm1
 psubsw xmm7,xmm5
 movdqa xmm5,dqword ptr [esp+256+_c13573_]
 paddsw xmm0,xmm3
 psubsw xmm3,xmm1
 movdqa xmm1,xmm2
 paddsw xmm1,xmm0
 psubsw xmm2,xmm0
 movdqa dqword ptr [esp+256+_vy_1_],xmm1
 movdqa xmm0,xmm3
 movdqa dqword ptr [esp+256+_vy_15_],xmm2
 movdqa xmm1,xmm3
 pmullw xmm1,xmm5
 pmulhw xmm0,xmm5
 movdqa xmm2,xmm1
 punpckhwd xmm1,xmm0
 paddd xmm1,dqword ptr [esp+256+_c_]
 punpcklwd xmm2,xmm0
 movdqa xmm0,xmm6
 paddd xmm2,dqword ptr [esp+256+_c_]
 psrad xmm1,15
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 pmulhw xmm0,xmm5
 packssdw xmm2,xmm1
 paddsw xmm2,xmm6
 pmullw xmm6,xmm5
 movdqa xmm5,dqword ptr [esp+256+_c_]
 movdqa dqword ptr [esp+256+_vy_9_],xmm2
 movdqa xmm1,xmm6
 punpcklwd xmm1,xmm0
 paddd xmm1,xmm5
 punpckhwd xmm6,xmm0
 movdqa xmm0,xmm7
 pmulhw xmm0,dqword ptr [esp+256+_c23170_]
 paddd xmm6,xmm5
 psrad xmm1,15
 psrad xmm6,15
 pslld xmm1,16
 movdqa xmm2,dqword ptr [esp+256+_cNeg23170_]
 psrad xmm1,16
 pslld xmm6,16
 psrad xmm6,16
 packssdw xmm1,xmm6
 psubsw xmm1,xmm3
 movdqa dqword ptr [esp+256+_vy_21_],xmm1
 movdqa xmm1,xmm7
 pmullw xmm1,dqword ptr [esp+256+_c23170_]
 movdqa xmm3,xmm1
 punpckhwd xmm1,xmm0
 paddd xmm1,xmm5
 punpcklwd xmm3,xmm0
 paddd xmm3,xmm5
 psrad xmm1,15
 movdqa xmm0,xmm7
 psrad xmm3,15
 pmullw xmm7,xmm2
 pmulhw xmm0,xmm2
 pslld xmm1,16
 pslld xmm3,16
 psrad xmm1,16
 movdqa xmm6,xmm7
 psrad xmm3,16
 punpcklwd xmm6,xmm0
 punpckhwd xmm7,xmm0
 paddd xmm6,xmm5
 packssdw xmm3,xmm1
 paddd xmm7,xmm5
 movdqa xmm1,xmm4
 paddsw xmm3,dqword ptr [esp+256+_t5_2_]
 pmullw xmm1,xmm2
 movdqa xmm0,xmm4
 pmulhw xmm0,xmm2
 psrad xmm6,15
 psrad xmm7,15
 pslld xmm6,16
 movdqa xmm5,xmm1
 pslld xmm7,16
 punpcklwd xmm5,xmm0
 punpckhwd xmm1,xmm0
 movdqa xmm0,xmm4
 pmullw xmm4,dqword ptr [esp+256+_c23170_]
 pmulhw xmm0,dqword ptr [esp+256+_c23170_]
 psrad xmm7,16
 psrad xmm6,16
 movdqa xmm2,xmm4
 packssdw xmm6,xmm7
 movdqa xmm7,dqword ptr [esp+256+_c_]
 paddsw xmm6,dqword ptr [esp+256+_t5_2_]
 paddd xmm5,xmm7
 punpcklwd xmm2,xmm0
 paddd xmm1,xmm7
 punpckhwd xmm4,xmm0
 paddd xmm2,xmm7
 paddd xmm4,xmm7
 psrad xmm5,15
 movdqa xmm7,dqword ptr [esp+256+_c6518_]
 movdqa xmm0,xmm3
 psrad xmm2,15
 psrad xmm1,15
 psrad xmm4,15
 pslld xmm5,16
 pslld xmm2,16
 pslld xmm1,16
 pslld xmm4,16
 psrad xmm5,16
 psrad xmm2,16
 psrad xmm1,16
 psrad xmm4,16
 packssdw xmm5,xmm1
 paddsw xmm5,dqword ptr [esp+256+_t9_2_]
 packssdw xmm2,xmm4
 paddsw xmm2,dqword ptr [esp+256+_t9_2_]
 pmulhw xmm0,xmm7
 movdqa xmm1,xmm3
 pmullw xmm1,xmm7
 mov eax,OFFSET PostScaleArray
 movdqa xmm4,xmm1
 punpckhwd xmm1,xmm0
 paddd xmm1,dqword ptr [esp+256+_c_]
 punpcklwd xmm4,xmm0
 movdqa xmm0,xmm2
 paddd xmm4,dqword ptr [esp+256+_c_]
 psrad xmm1,15
 pmulhw xmm0,xmm7
 pslld xmm1,16
 psrad xmm4,15
 psrad xmm1,16
 pslld xmm4,16
 psrad xmm4,16
 packssdw xmm4,xmm1
 paddsw xmm4,xmm2
 pmullw xmm2,xmm7
 movdqa xmm1,xmm2
 punpckhwd xmm2,xmm0
 paddd xmm2,dqword ptr [esp+256+_c_]
 punpcklwd xmm1,xmm0
 movdqa xmm0,xmm5
 paddd xmm1,dqword ptr [esp+256+_c_]
 pmulhw xmm0,dqword ptr [esp+256+_c21895_]
 psrad xmm1,15
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 movdqa xmm2,dqword ptr [esp+256+_c_]
 psubsw xmm1,xmm3
 movdqa dqword ptr [esp+256+_vy_24_],xmm1
 movdqa xmm1,xmm5
 pmullw xmm1,dqword ptr [esp+256+_c21895_]
 movdqa xmm7,xmm1
 punpckhwd xmm1,xmm0
 punpcklwd xmm7,xmm0
 paddd xmm1,xmm2
 paddd xmm7,xmm2
 psrad xmm1,15
 psrad xmm7,15
 movdqa xmm0,xmm6
 pmulhw xmm0,dqword ptr [esp+256+_cNeg21895_]
 pslld xmm7,16
 pslld xmm1,16
 psrad xmm7,16
 psrad xmm1,16
 packssdw xmm7,xmm1
 paddsw xmm7,xmm6
 pmullw xmm6,dqword ptr [esp+256+_cNeg21895_]
 movdqa xmm3,xmm6
 punpckhwd xmm6,xmm0
 punpcklwd xmm3,xmm0
 paddd xmm6,xmm2
 paddd xmm3,xmm2
 psrad xmm6,15
 movdqu xmm2,dqword ptr [eax]
 mov eax,dword ptr OutputData
 psrad xmm3,15
 movdqa xmm1,xmm2
 pslld xmm6,16
 pmullw xmm2,dqword ptr [esp+256+_vy_1_]
 pmulhw xmm1,dqword ptr [esp+256+_vy_1_]
 pslld xmm3,16
 psrad xmm6,16
 psrad xmm3,16
 movdqa xmm0,xmm2
 punpcklwd xmm0,xmm1
 packssdw xmm3,xmm6
 movdqa xmm6,dqword ptr [esp+256+_c_]
 paddsw xmm3,xmm5
 paddd xmm0,xmm6
 xorps xmm5,xmm5
 psrad xmm0,15
 pslld xmm0,16
 psrad xmm0,16
 punpckhwd xmm2,xmm1
 mov ecx,OFFSET PostScaleArray+16
 paddd xmm2,xmm6
 psrad xmm2,15
 pslld xmm2,16
 psrad xmm2,16
 packssdw xmm0,xmm2
 paddsw xmm0,xmm5
 movdqu dqword ptr [eax],xmm0
 movdqu xmm2,dqword ptr [ecx]
 mov ecx,OFFSET PostScaleArray+32
 movdqa xmm0,xmm2
 pmullw xmm2,xmm4
 pmulhw xmm0,xmm4
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm6
 psrad xmm1,15
 paddd xmm2,xmm6
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 paddsw xmm1,xmm5
 movdqu dqword ptr [eax+16],xmm1
 movdqu xmm2,dqword ptr [ecx]
 mov ecx,OFFSET PostScaleArray+48
 movdqa xmm0,xmm2
 pmullw xmm2,dqword ptr [esp+256+_vy_9_]
 pmulhw xmm0,dqword ptr [esp+256+_vy_9_]
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm6
 paddd xmm2,xmm6
 psrad xmm1,15
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 paddsw xmm1,xmm5
 movdqu dqword ptr [eax+32],xmm1
 movdqu xmm2,dqword ptr [ecx]
 mov ecx,OFFSET PostScaleArray+64
 movdqa xmm0,xmm2
 pmullw xmm2,xmm3
 pmulhw xmm0,xmm3
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm6
 paddd xmm2,xmm6
 psrad xmm1,15
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 paddsw xmm1,xmm5
 movdqu dqword ptr [eax+48],xmm1
 movdqu xmm2,dqword ptr [ecx]
 movdqa xmm0,xmm2
 pmullw xmm2,dqword ptr [esp+256+_vy_15_]
 pmulhw xmm0,dqword ptr [esp+256+_vy_15_]
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm6
 paddd xmm2,xmm6
 psrad xmm1,15
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 mov ecx,OFFSET PostScaleArray+80
 paddsw xmm1,xmm5
 movdqu dqword ptr [eax+64],xmm1
 movdqu xmm2,dqword ptr [ecx]
 mov ecx,OFFSET PostScaleArray+96
 movdqa xmm0,xmm2
 pmullw xmm2,xmm7
 pmulhw xmm0,xmm7
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm6
 psrad xmm1,15
 paddd xmm2,xmm6
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 paddsw xmm1,xmm5
 movdqu dqword ptr [eax+80],xmm1
 movdqu xmm2,dqword ptr [ecx]
 mov ecx,OFFSET PostScaleArray+112
 movdqa xmm0,xmm2
 pmullw xmm2,dqword ptr [esp+256+_vy_21_]
 pmulhw xmm0,dqword ptr [esp+256+_vy_21_]
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm6
 psrad xmm1,15
 paddd xmm2,xmm6
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 paddsw xmm1,xmm5
 movdqu dqword ptr [eax+96],xmm1
 movdqu xmm2,dqword ptr [ecx]
 movdqa xmm0,xmm2
 pmullw xmm2,dqword ptr [esp+256+_vy_24_]
 pmulhw xmm0,dqword ptr [esp+256+_vy_24_]
 movdqa xmm1,xmm2
 punpcklwd xmm1,xmm0
 punpckhwd xmm2,xmm0
 paddd xmm1,xmm6
 paddd xmm2,xmm6
 psrad xmm1,15
 psrad xmm2,15
 pslld xmm1,16
 pslld xmm2,16
 psrad xmm1,16
 psrad xmm2,16
 packssdw xmm1,xmm2
 paddsw xmm1,xmm5
 movdqu dqword ptr [eax+112],xmm1
 mov esp,edx
end;
{$endif}
{$endif}
{$endif}
{$endif}

procedure TpvJPEGEncoder.DCT2D;
const CONST_BITS=13;
      ROW_BITS=2;
      SHIFT0=CONST_BITS-ROW_BITS;
      SHIFT0ADD=1 shl (SHIFT0-1);
      SHIFT1=ROW_BITS+3;
      SHIFT1ADD=1 shl (SHIFT1-1);
      SHIFT2=CONST_BITS+ROW_BITS+3;
      SHIFT2ADD=1 shl (SHIFT2-1);
var s0,s1,s2,s3,s4,s5,s6,s7,t0,t1,t2,t3,t4,t5,t6,t7,t10,t13,t11,t12,u1,u2,u3,u4,z5,c:TpvInt32;
    b:PpvJPEGEncoderUInt8Array;
    q:PpvJPEGEncoderInt32Array;
    s:PpvJPEGEncoderInt16Array;
begin
 b:=TpvPointer(@fSamples8Bit);
 q:=TpvPointer(@fSamples32Bit);
 for c:=0 to 7 do begin
  s0:=TpvInt32(b^[0])-128;
  s1:=TpvInt32(b^[1])-128;
  s2:=TpvInt32(b^[2])-128;
  s3:=TpvInt32(b^[3])-128;
  s4:=TpvInt32(b^[4])-128;
  s5:=TpvInt32(b^[5])-128;
  s6:=TpvInt32(b^[6])-128;
  s7:=TpvInt32(b^[7])-128;
  b:=TpvPointer(@b[8]);
  t0:=s0+s7;
  t7:=s0-s7;
  t1:=s1+s6;
  t6:=s1-s6;
  t2:=s2+s5;
  t5:=s2-s5;
  t3:=s3+s4;
  t4:=s3-s4;
  t10:=t0+t3;
  t13:=t0-t3;
  t11:=t1+t2;
  t12:=t1-t2;
  u1:=TpvInt16(t12+t13)*TpvInt32(4433);
  s2:=u1+(TpvInt16(t13)*TpvInt32(6270));
  s6:=u1+(TpvInt16(t12)*TpvInt32(-15137));
  u1:=t4+t7;
  u2:=t5+t6;
  u3:=t4+t6;
  u4:=t5+t7;
  z5:=TpvInt16(u3+u4)*TpvInt32(9633);
  t4:=TpvInt16(t4)*TpvInt32(2446);
  t5:=TpvInt16(t5)*TpvInt32(16819);
  t6:=TpvInt16(t6)*TpvInt32(25172);
  t7:=TpvInt16(t7)*TpvInt32(12299);
  u1:=TpvInt16(u1)*TpvInt32(-7373);
  u2:=TpvInt16(u2)*TpvInt32(-20995);
  u3:=(TpvInt16(u3)*TpvInt32(-16069))+z5;
  u4:=(TpvInt16(u4)*TpvInt32(-3196))+z5;
  s0:=t10+t11;
  s1:=t7+u1+u4;
  s3:=t6+u2+u3;
  s4:=t10-t11;
  s5:=t5+u2+u4;
  s7:=t4+u1+u3;
  q^[0]:=s0 shl ROW_BITS;
  q^[1]:=SARLongint(s1+SHIFT0ADD,SHIFT0);
  q^[2]:=SARLongint(s2+SHIFT0ADD,SHIFT0);
  q^[3]:=SARLongint(s3+SHIFT0ADD,SHIFT0);
  q^[4]:=s4 shl ROW_BITS;
  q^[5]:=SARLongint(s5+SHIFT0ADD,SHIFT0);
  q^[6]:=SARLongint(s6+SHIFT0ADD,SHIFT0);
  q^[7]:=SARLongint(s7+SHIFT0ADD,SHIFT0);
  q:=TpvPointer(@q[8]);
 end;
 q:=TpvPointer(@fSamples32Bit);
 s:=TpvPointer(@fSamples16Bit);
 for c:=0 to 7 do begin
  s0:=q^[0*8];
  s1:=q^[1*8];
  s2:=q^[2*8];
  s3:=q^[3*8];
  s4:=q^[4*8];
  s5:=q^[5*8];
  s6:=q^[6*8];
  s7:=q^[7*8];
  q:=TpvPointer(@q[1]);
  t0:=s0+s7;
  t7:=s0-s7;
  t1:=s1+s6;
  t6:=s1-s6;
  t2:=s2+s5;
  t5:=s2-s5;
  t3:=s3+s4;
  t4:=s3-s4;
  t10:=t0+t3;
  t13:=t0-t3;
  t11:=t1+t2;
  t12:=t1-t2;
  u1:=TpvInt16(t12+t13)*TpvInt32(4433);
  s2:=u1+(TpvInt16(t13)*TpvInt32(6270));
  s6:=u1+(TpvInt16(t12)*TpvInt32(-15137));
  u1:=t4+t7;
  u2:=t5+t6;
  u3:=t4+t6;
  u4:=t5+t7;
  z5:=TpvInt16(u3+u4)*TpvInt32(9633);
  t4:=TpvInt16(t4)*TpvInt32(2446);
  t5:=TpvInt16(t5)*TpvInt32(16819);
  t6:=TpvInt16(t6)*TpvInt32(25172);
  t7:=TpvInt16(t7)*TpvInt32(12299);
  u1:=TpvInt16(u1)*TpvInt32(-7373);
  u2:=TpvInt16(u2)*TpvInt32(-20995);
  u3:=(TpvInt16(u3)*TpvInt32(-16069))+z5;
  u4:=(TpvInt16(u4)*TpvInt32(-3196))+z5;
  s0:=t10+t11;
  s1:=t7+u1+u4;
  s3:=t6+u2+u3;
  s4:=t10-t11;
  s5:=t5+u2+u4;
  s7:=t4+u1+u3;
  s^[0*8]:=SARLongint(s0+SHIFT1ADD,SHIFT1);
  s^[1*8]:=SARLongint(s1+SHIFT2ADD,SHIFT2);
  s^[2*8]:=SARLongint(s2+SHIFT2ADD,SHIFT2);
  s^[3*8]:=SARLongint(s3+SHIFT2ADD,SHIFT2);
  s^[4*8]:=SARLongint(s4+SHIFT1ADD,SHIFT1);
  s^[5*8]:=SARLongint(s5+SHIFT2ADD,SHIFT2);
  s^[6*8]:=SARLongint(s6+SHIFT2ADD,SHIFT2);
  s^[7*8]:=SARLongint(s7+SHIFT2ADD,SHIFT2);
  s:=TpvPointer(@s[1]);
 end;
end;

procedure TpvJPEGEncoder.LoadQuantizedCoefficients(ComponentIndex:TpvInt32);
const ZigZagTable:array[0..63] of TpvUInt8=(0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63);
var q:PpvInt32;
    pDst:PpvInt16;
    i,j:TpvInt32;
begin
 if ComponentIndex>0 then begin
  q:=TpvPointer(@fQuantizationTables[1]);
 end else begin
  q:=TpvPointer(@fQuantizationTables[0]);
 end;
 pDst:=TpvPointer(@fCoefficients[0]);
 for i:=0 to 63 do begin
  j:=fSamples16Bit[ZigZagTable[i]];
  if j<0 then begin
   j:=SARLongint(q^,1)-j;
   if j<q^ then begin
    pDst^:=0;
   end else begin
    pDst^:=-(j div q^);
   end;
  end else begin
   inc(j,SARLongint(q^,1));
   if j<q^ then begin
    pDst^:=0;
   end else begin
    pDst^:=j div q^;
   end;
  end;
  inc(pDst);
  inc(q);
 end;
end;

procedure TpvJPEGEncoder.CodeCoefficientsPassOne(ComponentIndex:TpvInt32);
var i,RunLen,CountBits,t1:TpvInt32;
    src:PpvJPEGEncoderInt16Array;
    DCCounts,ACCounts:PpvJPEGEncoderUInt32Array;
begin
 src:=TpvPointer(@fCoefficients[0]);
 if ComponentIndex<>0 then begin
  DCCounts:=TpvPointer(@fHuffmanCounts[0+1]);
  ACCounts:=TpvPointer(@fHuffmanCounts[2+1]);
 end else begin
  DCCounts:=TpvPointer(@fHuffmanCounts[0+0]);
  ACCounts:=TpvPointer(@fHuffmanCounts[2+0]);
 end;
 t1:=src^[0]-fLastDCValues[ComponentIndex];
 fLastDCValues[ComponentIndex]:=src^[0];
 if t1<0 then begin
  t1:=-t1;
 end;
 CountBits:=0;
 while t1<>0 do begin
  inc(CountBits);
  t1:=t1 shr 1;
 end;
 inc(DCCounts[CountBits]);
 RunLen:=0;
 for i:=1 to 63 do begin
  t1:=fCoefficients[i];
  if t1=0 then begin
   inc(RunLen);
  end else begin
   while RunLen>=16 do begin
    inc(ACCounts^[$f0]);
    dec(RunLen,16);
   end;
   if t1<0 then begin
    t1:=-t1;
   end;
   CountBits:=1;
   repeat
    t1:=t1 shr 1;
    if t1<>0 then begin
     inc(CountBits);
    end else begin
     break;
    end;
   until false;
   inc(ACCounts^[(RunLen shl 4)+CountBits]);
   RunLen:=0;
  end;
 end;
 if RunLen<>0 then begin
  inc(ACCounts^[0]);
 end;
end;

procedure TpvJPEGEncoder.CodeCoefficientsPassTwo(ComponentIndex:TpvInt32);
var i,j,RunLen,CountBits,t1,t2:TpvInt32;
    pSrc:PpvJPEGEncoderInt16Array;
    Codes:array[0..1] of PpvJPEGEncoderUInt32Array;
    CodeSizes:array[0..1] of PpvJPEGEncoderUInt8Array;
begin
 if ComponentIndex=0 then begin
  Codes[0]:=TpvPointer(@fHuffmanCodes[0+0]);
  Codes[1]:=TpvPointer(@fHuffmanCodes[2+0]);
  CodeSizes[0]:=TpvPointer(@fHuffmanCodeSizes[0+0]);
  CodeSizes[1]:=TpvPointer(@fHuffmanCodeSizes[2+0]);
 end else begin
  Codes[0]:=TpvPointer(@fHuffmanCodes[0+1]);
  Codes[1]:=TpvPointer(@fHuffmanCodes[2+1]);
  CodeSizes[0]:=TpvPointer(@fHuffmanCodeSizes[0+1]);
  CodeSizes[1]:=TpvPointer(@fHuffmanCodeSizes[2+1]);
 end;
 pSrc:=TpvPointer(@fCoefficients[0]);
 t1:=pSrc^[0]-fLastDCValues[ComponentIndex];
 t2:=t1;
 fLastDCValues[ComponentIndex]:=pSrc^[0];
 if t1<0 then begin
  t1:=-t1;
  dec(t2);
 end;
 CountBits:=0;
 while t1<>0 do begin
  inc(CountBits);
  t1:=t1 shr 1;
 end;
 PutBits(Codes[0]^[CountBits],CodeSizes[0]^[CountBits]);
 if CountBits<>0 then begin
  PutBits(t2 and ((1 shl CountBits)-1),CountBits);
 end;
 RunLen:=0;
 for i:=1 to 63 do begin
  t1:=fCoefficients[i];
  if t1=0 then begin
   inc(RunLen);
  end else begin
   while RunLen>=16 do begin
    PutBits(Codes[1]^[$f0],CodeSizes[1]^[$f0]);
    dec(RunLen,16);
   end;
   t2:=t1;
   if t2<0 then begin
    t1:=-t1;
    dec(t2);
   end;
   CountBits:=1;
   repeat
    t1:=t1 shr 1;
    if t1<>0 then begin
     inc(CountBits);
    end else begin
     break;
    end;
   until false;
   j:=(RunLen shl 4)+CountBits;
   PutBits(Codes[1]^[j],CodeSizes[1]^[j]);
   PutBits(t2 and ((1 shl CountBits)-1),CountBits);
   RunLen:=0;
  end;
 end;
 if RunLen<>0 then begin
  PutBits(Codes[1]^[0],CodeSizes[1]^[0]);
 end;
end;

procedure TpvJPEGEncoder.CodeBlock(ComponentIndex:TpvInt32);
begin
{$ifdef PurePascal}
 DCT2D;
{$else}
{$ifdef cpu386}
 DCT2DSSE(@fSamples8Bit,@fSamples16Bit);
{$else}
 DCT2D;
{$endif}
{$endif}
 LoadQuantizedCoefficients(ComponentIndex);
 if fPassIndex=1 then begin
  CodeCoefficientsPassOne(ComponentIndex);
 end else begin
  CodeCoefficientsPassTwo(ComponentIndex);
 end;
end;

procedure TpvJPEGEncoder.ProcessMCURow;
var i:TpvInt32;
begin
 if fCountComponents=1 then begin
  for i:=0 to fMCUsPerRow-1 do begin
   LoadBlock8x8(i,0,0);
   CodeBlock(0);
  end;
 end else if (fComponentHSamples[0]=1) and (fComponentVSamples[0]=1) then begin
  for i:=0 to fMCUsPerRow-1 do begin
   LoadBlock8x8(i,0,0);
   CodeBlock(0);
   LoadBlock8x8(i,0,1);
   CodeBlock(1);
   LoadBlock8x8(i,0,2);
   CodeBlock(2);
  end;
 end else if (fComponentHSamples[0]=2) and (fComponentVSamples[0]=1) then begin
  for i:=0 to fMCUsPerRow-1 do begin
   LoadBlock8x8((i*2)+0,0,0);
   CodeBlock(0);
   LoadBlock8x8((i*2)+1,0,0);
   CodeBlock(0);
   LoadBlock16x8x8(i,1);
   CodeBlock(1);
   LoadBlock16x8x8(i,2);
   CodeBlock(2);
  end;
 end else if (fComponentHSamples[0]=2) and (fComponentVSamples[0]=2) then begin
  for i:=0 to fMCUsPerRow-1 do begin
   LoadBlock8x8((i*2)+0,0,0);
   CodeBlock(0);
   LoadBlock8x8((i*2)+1,0,0);
   CodeBlock(0);
   LoadBlock8x8((i*2)+0,1,0);
   CodeBlock(0);
   LoadBlock8x8((i*2)+1,1,0);
   CodeBlock(0);
   LoadBlock16x8(i,1);
   CodeBlock(1);
   LoadBlock16x8(i,2);
   CodeBlock(2);
  end;
 end;
end;

procedure TpvJPEGEncoder.LoadMCU(p:TpvPointer);
var pDst:PpvJPEGEncoderUInt8Array;
    c:TpvInt32;
begin
 if fCountComponents=1 then begin
  ConvertRGBAToY(TpvPointer(@fMCUChannels[0]^[fMCUYOffset*fImageWidthMCU]),TpvPointer(p),fImageWidth);
 end else begin
  ConvertRGBAToYCbCr(TpvPointer(@fMCUChannels[0]^[fMCUYOffset*fImageWidthMCU]),TpvPointer(@fMCUChannels[1]^[fMCUYOffset*fImageWidthMCU]),TpvPointer(@fMCUChannels[2]^[fMCUYOffset*fImageWidthMCU]),TpvPointer(p),fImageWidth);
 end;
 if fImageWidth<fImageWidthMCU then begin
  for c:=0 to fCountComponents-1 do begin
   pDst:=TpvPointer(@fMCUChannels[c]^[fMCUYOffset*fImageWidthMCU]);
   FillChar(pDst^[fImageWidth],fImageWidthMCU-fImageWidth,AnsiChar(TpvUInt8(pDst^[fImageWidth-1])));
  end;
 end;
 inc(fMCUYOffset);
 if fMCUYOffset=fMCUHeight then begin
  ProcessMCURow;
  fMCUYOffset:=0;
 end;
end;

function TpvJPEGEncoder.RadixSortSymbols(CountSymbols:TpvUInt32;SymbolsA,SymbolsB:PpvJPEGHuffmanSymbolFrequencies):PpvJPEGHuffmanSymbolFrequency;
const MaxPasses=4;
var i,freq,TotalPasses,CurrentOffset:TpvUInt32;
    PassShift,Pass:TpvInt32;
    CurrentSymbols,NewSymbols,t:PpvJPEGHuffmanSymbolFrequencies;
    Histogramm:array[0..(256*MaxPasses)-1] of TpvUInt32;
    Offsets:array[0..255] of TpvUInt32;
    pHistogramm:PpvJPEGEncoderUInt32Array;
begin
 FillChar(Histogramm,SizeOf(Histogramm),#0);
 for i:=1 to CountSymbols do begin
  freq:=SymbolsA^[i-1].key;
  inc(Histogramm[freq and $ff]);
  inc(Histogramm[256+((freq shr 8) and $ff)]);
  inc(Histogramm[(256*2)+((freq shr 16) and $ff)]);
  inc(Histogramm[(256*3)+((freq shr 24) and $ff)]);
 end;
 CurrentSymbols:=SymbolsA;
 NewSymbols:=SymbolsB;
 TotalPasses:=MaxPasses;
 while (TotalPasses>1) and (CountSymbols=Histogramm[(TotalPasses-1)*256]) do begin
  dec(TotalPasses);
 end;
 PassShift:=0;
 for Pass:=0 to TpvInt32(TotalPasses)-1 do begin
  pHistogramm:=@Histogramm[Pass shl 8];
  CurrentOffset:=0;
  for i:=0 to 255 do begin
   Offsets[i]:=CurrentOffset;
   inc(CurrentOffset,pHistogramm^[i]);
  end;
  for i:=1 to CountSymbols do begin
   NewSymbols^[Offsets[(CurrentSymbols^[i-1].key shr PassShift) and $ff]]:=CurrentSymbols^[i-1];
   inc(Offsets[(CurrentSymbols^[i-1].key shr PassShift) and $ff]);
  end;
  t:=CurrentSymbols;
  CurrentSymbols:=NewSymbols;
  NewSymbols:=t;
  inc(PassShift,8);
 end;
 result:=TpvPointer(CurrentSymbols);
end;

procedure TpvJPEGEncoder.CalculateMinimumRedundancy(a:PpvJPEGHuffmanSymbolFrequencies;n:TpvInt32);
var Root,Leaf,Next,Avaliable,Used,Depth:TpvInt32;
begin
 if n=0 then begin
  exit;
 end else if n=1 then begin
  A^[0].key:=1;
  exit;
 end;
 inc(A^[0].key,A^[1].key);
 Root:=0;
 Leaf:=2;
 for Next:=1 to n-2 do begin
  if (Leaf>=n) or (A^[Root].key<A^[Leaf].key) then begin
   A^[Next].key:=A^[Root].key;
   A^[Root].key:=Next;
   inc(Root);
  end else begin
   A^[Next].key:=A^[Leaf].key;
   inc(Leaf);
  end;
  if (Leaf>=n) or ((Root<Next) and (A^[Root].key<A^[Leaf].key)) then begin
   inc(A^[Next].key,A^[Root].key);
   A^[Root].key:=Next;
   inc(Root);
  end else begin
   inc(A^[Next].key,A^[Leaf].key);
   inc(Leaf);
  end;
 end;
 A^[n-2].key:=0;
 for Next:=n-3 downto 0 do begin
  A^[Next].key:=A^[A^[Next].key].key+1;
 end;
 Avaliable:=1;
 Used:=0;
 Depth:=0;
 Root:=n-2;
 Next:=n-1;
 while Avaliable>0 do begin
  while (Root>=0) and (TpvUInt32(A^[Root].key)=TpvUInt32(Depth)) do begin
   inc(Used);
   dec(Root);
  end;
  while Avaliable>Used do begin
   A^[Next].key:=Depth;
   dec(Next);
   dec(Avaliable);
  end;
  Avaliable:=2*Used;
  inc(Depth);
  Used:=0;
 end;
end;

procedure TpvJPEGEncoder.HuffmanEnforceMaxCodeSize(CountCodes:PpvJPEGEncoderInt32Array;CodeListLen,MaxCodeSize:TpvInt32);
var i:TpvInt32;
    Total:TpvUInt32;
begin
 if CodeListLen<=1 then begin
  exit;
 end;
 for i:=MaxCodeSize+1 to JPEG_MAX_HUFFMAN_CODE_SIZE do begin
  inc(CountCodes^[MaxCodeSize],CountCodes^[i]);
 end;
 Total:=0;
 for i:=MaxCodeSize downto 1 do begin
  inc(Total,TpvUInt32(CountCodes[i]) shl (MaxCodeSize - i));
 end;
 while Total<>(1 shl MaxCodeSize) do begin
  dec(CountCodes[MaxCodeSize]);
  for i:=MaxCodeSize-1 downto 1 do begin
   if CountCodes[i]<>0 then begin
    dec(CountCodes[i]);
    inc(CountCodes[i+1],2);
    break;
   end;
  end;
  dec(Total);
 end;
end;

procedure TpvJPEGEncoder.OptimizeHuffmanTable(TableIndex,TableLen:TpvInt32);
const CODE_SIZE_LIMIT=16;
var CountUsedSymbols,i:TpvInt32;
    CountSymbols:PpvJPEGEncoderUInt32Array;
    SymbolFreqs:PpvJPEGHuffmanSymbolFrequency;
    SymbolsA,SymbolsB:array[0..JPEG_MAX_HUFFMAN_SYMBOLS] of TpvJPEGHuffmanSymbolFrequency;
    CountCodes:array[0..JPEG_MAX_HUFFMAN_CODE_SIZE] of TpvInt32;
begin
 SymbolsA[0].key:=1;
 SymbolsA[0].Index:=0;
 CountUsedSymbols:=1;
 CountSymbols:=TpvPointer(@fHuffmanCounts[TableIndex,0]);
 for i:=1 to TableLen do begin
  if CountSymbols^[i-1]>0 then begin
   SymbolsA[CountUsedSymbols].key:=CountSymbols^[i-1];
   SymbolsA[CountUsedSymbols].Index:=i;
   inc(CountUsedSymbols);
  end;
 end;
 SymbolFreqs:=RadixSortSymbols(CountUsedSymbols,TpvPointer(@SymbolsA[0]),TpvPointer(@SymbolsB[0]));
 CalculateMinimumRedundancy(TpvPointer(SymbolFreqs),CountUsedSymbols);
 FillChar(CountCodes,SizeOf(CountCodes),#0);
 for i:=1 to CountUsedSymbols do begin
  inc(CountCodes[PpvJPEGHuffmanSymbolFrequencies(SymbolFreqs)^[i-1].key]);
 end;
 HuffmanEnforceMaxCodeSize(TpvPointer(@CountCodes),CountUsedSymbols,CODE_SIZE_LIMIT);
 FillChar(fHuffmanBits[TableIndex],SizeOf(fHuffmanBits[TableIndex]),#0);
 for i:=1 to CODE_SIZE_LIMIT do begin
  fHuffmanBits[TableIndex,i]:=CountCodes[i];
 end;
 for i:=CODE_SIZE_LIMIT downto 1 do begin
  if fHuffmanBits[TableIndex,i]<>0 then begin
   dec(fHuffmanBits[TableIndex,i]);
   break;
  end;
 end;
 for i:=CountUsedSymbols-1 downto 1 do begin
  fHuffmanValues[TableIndex, CountUsedSymbols-(i+1)]:=PpvJPEGHuffmanSymbolFrequencies(SymbolFreqs)^[i].Index-1;
 end;
end;

function TpvJPEGEncoder.TerminatePassOne:boolean;
begin
 OptimizeHuffmanTable(0+0,JPEG_DC_LUMA_CODES);
 OptimizeHuffmanTable(2+0,JPEG_AC_LUMA_CODES);
 if fCountComponents>1 then begin
  OptimizeHuffmanTable(0+1,JPEG_DC_CHROMA_CODES);
  OptimizeHuffmanTable(2+1,JPEG_AC_CHROMA_CODES);
 end;
 result:=InitSecondPass;
end;

function TpvJPEGEncoder.TerminatePassTwo:boolean;
const M_EOI=$d9;
begin
 PutBits($7f,7);
 FlushOutputBuffer;
 EmitMarker(M_EOI);
 inc(fPassIndex);
 result:=true;
end;

function TpvJPEGEncoder.ProcessEndOfImage:boolean;
var i,c:TpvInt32;
begin
 if fMCUYOffset<>0 then begin
  if fMCUYOffset<16 then begin
   for c:=0 to fCountComponents-1 do begin
    for i:=fMCUYOffset to fMCUHeight-1 do begin
     Move(fMCUChannels[c]^[(fMCUYOffset-1)*fImageWidthMCU],fMCUChannels[c]^[i*fImageWidthMCU],fImageWidthMCU);
    end;
   end;
  end;
  ProcessMCURow;
 end;
 if fPassIndex=1 then begin
  result:=TerminatePassOne;
 end else begin
  result:=TerminatePassTwo;
 end;
end;

function TpvJPEGEncoder.ProcessScanline(pScanline:TpvPointer):boolean;
begin
 result:=false;
 if (fPassIndex<1) or (fPassIndex>2) then begin
  exit;
 end;
 if assigned(pScanline) then begin
  LoadMCU(pScanline);
 end else begin
  if not ProcessEndOfImage then begin
   exit;
  end;
 end;
 result:=true;
end;

function TpvJPEGEncoder.Encode(const FrameData:TpvPointer;var CompressedData:TpvPointer;Width,Height:TpvInt32;Quality,MaxCompressedDataSize:TpvUInt32;const Fast:boolean=false;const ChromaSubsampling:TpvInt32=-1;const aOwnCompressedData:Boolean=true):TpvUInt32;
type PPixel=^TPixel;
     TPixel=packed record
      r,g,b,a:TpvUInt8;
     end;
var PassIndex,Passes,x,y:TpvInt32;
    Pixel:PPixel;
    OK,HasColor:LongBool;
begin
 result:=0;
 fCompressedData:=CompressedData;
 fCompressedDataPosition:=0;
 fCompressedDataAllocated:=0;
 fMaxCompressedDataSize:=MaxCompressedDataSize;
 fQuality:=Quality;
 fTwoPass:=not Fast;
 fNoChromaDiscrimination:=false;
 fMCUChannels[0]:=nil;
 fMCUChannels[1]:=nil;
 fMCUChannels[2]:=nil;
 fPassIndex:=0;
 case ChromaSubsampling of
  0:begin
   fBlockEncodingMode:=1; // H1V1 4:4:4 (common for the most high-end digital cameras and professional image editing software)
  end;
  1:begin
   fBlockEncodingMode:=2; // H2V1 4:2:2 (common for the most mid-range digital cameras and consumer image editing software)
  end;
  2:begin
   fBlockEncodingMode:=3; // H2V2 4:2:0 (common for the most cheap digital cameras and other cheap stuff)
  end;
  else {-1:}begin
   if fQuality>=95 then begin
    fBlockEncodingMode:=1; // H1V1 4:4:4 (common for the most high-end digital cameras and professional image editing software)
   end else if fQuality>=50 then begin
    fBlockEncodingMode:=2; // H2V1 4:2:2 (common for the most mid-range digital cameras and consumer image editing software)
   end else begin
    fBlockEncodingMode:=3; // H2V2 4:2:0 (common for the most cheap digital cameras and other cheap stuff)
   end;
  end;
 end;
 if assigned(FrameData) and not Fast then begin
  HasColor:=false;
  Pixel:=FrameData;
  for y:=0 to Height-1 do begin
   for x:=0 to Width-1 do begin
    if (Pixel^.r<>Pixel^.g) or (Pixel^.r<>Pixel^.b) or (Pixel^.g<>Pixel^.b) then begin
     HasColor:=true;
     break;
    end;
    inc(Pixel);
   end;
   if HasColor then begin
    break;
   end;
  end;
  if not HasColor then begin
   fBlockEncodingMode:=0; // Greyscale
  end;
 end;
 try
  if Setup(Width,Height) then begin
   OK:=true;
   if fTwoPass then begin
    Passes:=2;
   end else begin
    Passes:=1;
   end;
   for PassIndex:=0 to Passes-1 do begin
    for y:=0 to Height-1 do begin
     OK:=ProcessScanline(TpvPointer(@PpvJPEGEncoderUInt8Array(FrameData)^[(y*Width) shl 2]));
     if not OK then begin
      break;
     end;
    end;
    if OK then begin
     OK:=ProcessScanline(nil);
    end;
    if not OK then begin
     break;
    end;
   end;
   if OK then begin
    result:=fCompressedDataPosition;
   end;
  end;
 finally
  fMCUChannels[0]:=nil;
  fMCUChannels[1]:=nil;
  fMCUChannels[2]:=nil;
  if aOwnCompressedData then begin
   if result>0 then begin
    ReallocMem(fCompressedData,fCompressedDataPosition);
   end else if assigned(fCompressedData) then begin
    FreeMem(fCompressedData);
    fCompressedData:=nil;
   end;
  end;
  CompressedData:=fCompressedData;
 end;
end;

function SaveJPEGImage(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;out aDestData:TpvPointer;out aDestDataSize:TpvUInt32;const aQuality:TpvInt32=99;const aFast:boolean=false;const aChromaSubsampling:TpvInt32=-1):boolean;
var JPEGEncoder:TpvJPEGEncoder;
begin
 JPEGEncoder:=TpvJPEGEncoder.Create;
 try
  aDestData:=nil;
  aDestDataSize:=JPEGEncoder.Encode(aImageData,aDestData,aImageWidth,aImageHeight,aQuality,0,aFast,aChromaSubsampling);
  result:=aDestDataSize>0;
 finally
  JPEGEncoder.Free;
 end;
end;

function SaveJPEGImageAsStream(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aStream:TStream;const aQuality:TpvInt32=99;const aFast:boolean=false;const aChromaSubsampling:TpvInt32=-1):boolean;
var Data:TpvPointer;
    DataSize:TpvUInt32;
begin
 result:=SaveJPEGImage(aImageData,aImageWidth,aImageHeight,Data,DataSize,aQuality,aFast,aChromaSubsampling);
 if assigned(Data) then begin
  try
   aStream.Write(Data^,DataSize);
  finally
   FreeMem(Data);
  end;
 end;
end;

function SaveJPEGImageAsFile(const aImageData:TpvPointer;const aImageWidth,aImageHeight:TpvUInt32;const aFileName:string;const aQuality:TpvInt32=99;const aFast:boolean=false;const aChromaSubsampling:TpvInt32=-1):boolean;
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  result:=SaveJPEGImageAsStream(aImageData,aImageWidth,aImageHeight,FileStream,aQuality,aFast,aChromaSubsampling);
 finally
  FileStream.Free;
 end;
end;

procedure LoadTurboJPEG;
begin
 TurboJpegLibrary:=LoadLibrary({$ifdef Windows}{$ifdef cpu386}'turbojpeg32.dll'{$else}'turbojpeg64.dll'{$endif}{$else}'turbojpeg.so'{$endif});
 if TurboJpegLibrary<>NilLibHandle then begin
  tjInitCompress:=GetProcAddress(TurboJpegLibrary,'tjInitCompress');
  tjInitDecompress:=GetProcAddress(TurboJpegLibrary,'tjInitDecompress');
  tjDestroy:=GetProcAddress(TurboJpegLibrary,'tjDestroy');
  tjAlloc:=GetProcAddress(TurboJpegLibrary,'tjAlloc');
  tjFree:=GetProcAddress(TurboJpegLibrary,'tjFree');
  tjCompress2:=GetProcAddress(TurboJpegLibrary,'tjCompress2');
  tjDecompressHeader:=GetProcAddress(TurboJpegLibrary,'tjDecompressHeader');
  tjDecompressHeader2:=GetProcAddress(TurboJpegLibrary,'tjDecompressHeader2');
  tjDecompressHeader3:=GetProcAddress(TurboJpegLibrary,'tjDecompressHeader3');
  tjDecompress2:=GetProcAddress(TurboJpegLibrary,'tjDecompress2');
 end;
end;

procedure UnloadTurboJPEG;
begin
 if TurboJpegLibrary<>NilLibHandle then begin
  FreeLibrary(TurboJpegLibrary);
  TurboJpegLibrary:=NilLibHandle;
 end;
end;

initialization
 LoadTurboJPEG;
finalization
 UnloadTurboJPEG;
end.
