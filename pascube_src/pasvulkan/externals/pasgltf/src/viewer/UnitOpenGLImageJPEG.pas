unit UnitOpenGLImageJPEG; // from PasVulkan, so zlib-license and Copyright (C), Benjamin 'BeRo' Rosseaux (benjamin@rosseaux.de)
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
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
 {-$pic off}
 {$define caninline}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define delphi} 
 {$undef HasSAR}
 {$define UseDIV}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
{$endif}
{$ifdef cpu386}
 {$define cpux86}
{$endif}
{$ifdef cpuamd64}
 {$define cpux86}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef wince}
 {$define windows}
{$endif}
{$ifdef windows}
 {$define win}
{$endif}
{$ifdef sdl20}
 {$define sdl}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
{$endif}
{$ifdef fpc}
 {$define caninline}
{$else}
 {$undef caninline}
 {$ifdef ver180}
  {$define caninline}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define caninline}
   {$ifend}
  {$endif}
 {$endif}
{$endif}

interface

uses SysUtils,Classes,Math,
     {$ifdef fpc}
      FPImage,FPReadJPEG,
     {$endif}
     {$ifdef fpc}
      dynlibs,
     {$else}
      Windows,
     {$endif}
     UnitOpenGLImage,
     {$ifdef fpcgl}gl,glext{$else}dglOpenGL{$endif};

type ELoadJPEGImage=class(Exception);

function LoadJPEGImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;const HeaderOnly:boolean):boolean;

implementation

const NilLibHandle={$ifdef fpc}NilHandle{$else}THandle(0){$endif};

var TurboJpegLibrary:{$ifdef fpc}TLibHandle{$else}THandle{$endif}=NilLibHandle;

type TtjInitCompress=function:pointer; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

     TtjInitDecompress=function:pointer; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

     TtjDestroy=function(handle:pointer):longint; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

     TtjAlloc=function(bytes:longint):pointer; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

     TtjFree=procedure(buffer:pointer); {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

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
                           flags:longint):longint; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

     TtjDecompressHeader=function(handle:pointer;
                                  jpegBuf:pointer;
                                  jpegSize:longword;
                                  out width:longint;
                                  out height:longint):longint; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

     TtjDecompressHeader2=function(handle:pointer;
                                   jpegBuf:pointer;
                                   jpegSize:longword;
                                   out width:longint;
                                   out height:longint;
                                   out jpegSubsamp:longint):longint; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

     TtjDecompressHeader3=function(handle:pointer;
                                   jpegBuf:pointer;
                                   jpegSize:longword;
                                   out width:longint;
                                   out height:longint;
                                   out jpegSubsamp:longint;
                                   out jpegColorSpace:longint):longint; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

     TtjDecompress2=function(handle:pointer;
                             jpegBuf:pointer;
                             jpegSize:longword;
                             dstBuf:pointer;
                             width:longint;
                             pitch:longint;
                             height:longint;
                             pixelFormat:longint;
                             flags:longint):longint; {$ifdef WindowsLibJPEGTurboWithSTDCALL}stdcall;{$else}cdecl;{$endif}

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
function SARLongint(Value,Shift:longint):longint;
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
{$ifdef cpux64} assembler;
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 mov eax,ecx
 mov ecx,edx
 sar eax,cl
{$else}
 push rcx
 mov eax,edi
 mov ecx,esi
 sar eax,cl
 pop rcx
{$endif}
end;// ['r0','R1'];
{$else}{$ifdef CAN_INLINE}inline;{$endif}
begin
 Shift:=Shift and 31;
 result:=(longword(Value) shr Shift) or (longword(longint(longword(0-longword(longword(Value) shr 31)) and longword(0-longword(ord(Shift<>0) and 1)))) shl (32-Shift));
end;
{$endif}
{$endif}
{$endif}

function LoadJPEGImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;const HeaderOnly:boolean):boolean;
{$ifdef fpc}
var Image:TFPMemoryImage;
    ReaderJPEG:TFPReaderJPEG;
    Stream:TMemoryStream;
    y,x:longint;
    c:TFPColor;
    pout:PAnsiChar;
    tjWidth,tjHeight,tjJpegSubsamp:longint;
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
     TIDCTInputBlock=array[0..63] of longint;
     PIDCTOutputBlock=^TIDCTOutputBlock;
     TIDCTOutputBlock=array[0..65535] of byte;
     PByteArray=^TByteArray;
     TByteArray=array[0..65535] of byte;
     TPixels=array of byte;
     PHuffmanCode=^THuffmanCode;
     THuffmanCode=record
      Bits:byte;
      Code:byte;
     end;
     PLongint=^longint;
     PByte=^Byte;
     PHuffmanCodes=^THuffmanCodes;
     THuffmanCodes=array[0..65535] of THuffmanCode;
     PComponent=^TComponent;
     TComponent=record
      Width:longint;
      Height:longint;
      Stride:longint;
      Pixels:TPixels;
      ID:longint;
      SSX:longint;
      SSY:longint;
      QTSel:longint;
      ACTabSel:longint;
      DCTabSel:longint;
      DCPred:longint;
     end;
     PContext=^TContext;
     TContext=record
      Valid:boolean;
      NoDecode:boolean;
      FastChroma:boolean;
      Len:longint;
      Size:longint;
      Width:longint;
      Height:longint;
      MBWidth:longint;
      MBHeight:longint;
      MBSizeX:longint;
      MBSizeY:longint;
      Components:array[0..2] of TComponent;
      CountComponents:longint;
      QTUsed:longint;
      QTAvailable:longint;
      QTable:array[0..3,0..63] of byte;
      HuffmanCodeTable:array[0..3] of THuffmanCodes;
      Buf:longint;
      BufBits:longint;
      RSTInterval:longint;
      EXIFLE:boolean;
      CoSitedChroma:boolean;
      Block:TIDCTInputBlock;
     end;
const ZigZagOrderToRasterOrderConversionTable:array[0..63] of byte=
       (
        0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,
        12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,
        35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,
        58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63
       );
      ClipTable:array[0..$3ff] of byte=
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
    DataPosition:longword;
 procedure RaiseError;
 begin
  raise ELoadJPEGImage.Create('Invalid or corrupt JPEG data stream');
 end;
 procedure ProcessIDCT(const aInputBlock:PIDCTInputBlock;const aOutputBlock:PIDCTOutputBlock;const aOutputStride:longint);
 const W1=2841;
       W2=2676;
       W3=2408;
       W5=1609;
       W6=1108;
       W7=565;
 var i,v0,v1,v2,v3,v4,v5,v6,v7,v8:longint;
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
 function PeekBits(Bits:longint):longint;
 var NewByte,Marker:longint;
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
 procedure SkipBits(Bits:longint);
 begin
  if Context^.BufBits<Bits then begin
   PeekBits(Bits);
  end;
  dec(Context^.BufBits,Bits);
 end;
 function GetBits(Bits:longint):longint;
 begin
  result:=PeekBits(Bits);
  if Context^.BufBits<Bits then begin
   PeekBits(Bits);
  end;
  dec(Context^.BufBits,Bits);
 end;
 function GetHuffmanCode(const Huffman:PHuffmanCodes;const Code:Plongint):longint;
 var Bits:longint;
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
     inc(result,(longint(-1) shl Bits)+1);
    end;
   end;
  end;
 end;
 procedure UpsampleHCoSited(const Component:PComponent);
 var MaxX,x,y:longint;
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
 var MaxX,x,y:longint;
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
 var w,h,s1,s2,x,y:longint;
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
 var w,h,s1,s2,x,y:longint;
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
    tjWidth,tjHeight,tjJpegSubsamp:longint;
    ChunkTag:byte;
    Component:PComponent;
    DHTCounts:array[0..15] of byte;
    Huffman:PHuffmanCode;
    pY,aCb,aCr,oRGBX:PByte;
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

        Len:=(word(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if ((DataPosition+longword(Len))>=DataSize) or
           (Len<9) or
           (PByteArray(DataPointer)^[DataPosition+2]<>8) then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        Context^.Width:=(word(PByteArray(DataPointer)^[DataPosition+1]) shl 8) or PByteArray(DataPointer)^[DataPosition+2];
        Context^.Height:=(word(PByteArray(DataPointer)^[DataPosition+3]) shl 8) or PByteArray(DataPointer)^[DataPosition+4];
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

        Len:=(word(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if (DataPosition+longword(Len))>=DataSize then begin
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
          DHTCounts[CodeLen-1]:=PByteArray(DataPointer)^[DataPosition+longword(CodeLen)];
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
            Code:=PByteArray(DataPointer)^[DataPosition+longword(Index)];
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

        Len:=(word(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if ((DataPosition+longword(Len))>=DataSize) or (Len<2) then begin
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

        Len:=(word(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if (DataPosition+longword(Len))>=DataSize then begin
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

        Len:=(word(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if ((DataPosition+longword(Len))>=DataSize) or
           (Len<4) then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        Context^.RSTInterval:=(word(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        inc(DataPosition,Len);

       end;
       $e1{EXIF}:begin

        if (DataPosition+2)>=DataSize then begin
         RaiseError;
        end;

        Len:=(word(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];

        if ((DataPosition+longword(Len))>=DataSize) or
           (Len<18) then begin
         RaiseError;
        end;

        inc(DataPosition,2);
        dec(Len,2);

        NextDataPosition:=DataPosition+longword(Len);

        if (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+0]))='E') and
           (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+1]))='x') and
           (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+2]))='i') and
           (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+3]))='f') and
           (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+4]))=#0) and
           (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+5]))=#0) and
           (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+6]))=AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+7]))) and
           (((AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+6]))='I') and
             (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+8]))='*') and
             (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+9]))=#0)) or
            ((AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+6]))='M') and
             (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+8]))=#0) and
             (AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+9]))='*'))) then begin
         Context^.EXIFLE:=AnsiChar(byte(PByteArray(DataPointer)^[DataPosition+6]))='I';
         if Len>=14 then begin
          if Context^.EXIFLE then begin
           Value:=(longint(PByteArray(DataPointer)^[DataPosition+10]) shl 0) or
                  (longint(PByteArray(DataPointer)^[DataPosition+11]) shl 8) or
                  (longint(PByteArray(DataPointer)^[DataPosition+12]) shl 16) or
                  (longint(PByteArray(DataPointer)^[DataPosition+13]) shl 24);
          end else begin
           Value:=(longint(PByteArray(DataPointer)^[DataPosition+10]) shl 24) or
                  (longint(PByteArray(DataPointer)^[DataPosition+11]) shl 16) or
                  (longint(PByteArray(DataPointer)^[DataPosition+12]) shl 8) or
                  (longint(PByteArray(DataPointer)^[DataPosition+13]) shl 0);
          end;
          inc(Value,6);
          if (Value>=14) and ((Value+2)<Len) then begin
           inc(DataPosition,Value);
           dec(Len,Value);
           if Context^.EXIFLE then begin
            Count:=(longint(PByteArray(DataPointer)^[DataPosition+0]) shl 0) or
                   (longint(PByteArray(DataPointer)^[DataPosition+1]) shl 8);
           end else begin
            Count:=(longint(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or
                   (longint(PByteArray(DataPointer)^[DataPosition+1]) shl 0);
           end;
           inc(DataPosition,2);
           dec(Len,2);
           if Count<=(Len div 12) then begin
            while Count>0 do begin
             dec(Count);
             if Context^.EXIFLE then begin
              v0:=(longint(PByteArray(DataPointer)^[DataPosition+0]) shl 0) or
                  (longint(PByteArray(DataPointer)^[DataPosition+1]) shl 8);
              v1:=(longint(PByteArray(DataPointer)^[DataPosition+2]) shl 0) or
                  (longint(PByteArray(DataPointer)^[DataPosition+3]) shl 8);
              v2:=(longint(PByteArray(DataPointer)^[DataPosition+4]) shl 0) or
                  (longint(PByteArray(DataPointer)^[DataPosition+5]) shl 8) or
                  (longint(PByteArray(DataPointer)^[DataPosition+6]) shl 16) or
                  (longint(PByteArray(DataPointer)^[DataPosition+7]) shl 24);
              v3:=(longint(PByteArray(DataPointer)^[DataPosition+8]) shl 0) or
                  (longint(PByteArray(DataPointer)^[DataPosition+9]) shl 8);
             end else begin
              v0:=(longint(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or
                  (longint(PByteArray(DataPointer)^[DataPosition+1]) shl 0);
              v1:=(longint(PByteArray(DataPointer)^[DataPosition+2]) shl 8) or
                  (longint(PByteArray(DataPointer)^[DataPosition+3]) shl 0);
              v2:=(longint(PByteArray(DataPointer)^[DataPosition+4]) shl 24) or
                  (longint(PByteArray(DataPointer)^[DataPosition+5]) shl 16) or
                  (longint(PByteArray(DataPointer)^[DataPosition+6]) shl 8) or
                  (longint(PByteArray(DataPointer)^[DataPosition+7]) shl 0);
              v3:=(longint(PByteArray(DataPointer)^[DataPosition+8]) shl 8) or
                  (longint(PByteArray(DataPointer)^[DataPosition+9]) shl 0);
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
        Len:=(word(PByteArray(DataPointer)^[DataPosition+0]) shl 8) or PByteArray(DataPointer)^[DataPosition+1];
        if (DataPosition+longword(Len))>=DataSize then begin
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
     on e:ELoadJPEGImage do begin
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
