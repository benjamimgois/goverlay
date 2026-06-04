unit UnitOpenGLImagePNG; // from PasVulkan, so zlib-license and Copyright (C), Benjamin 'BeRo' Rosseaux (benjamin@rosseaux.de)
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
 //{$define delphi}
 {$undef delphi}
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

uses SysUtils,Classes,Math,{$ifdef delphi}PNGImage,{$else}{$ifdef fpc}FPImage,FPReadPNG,{$endif}{$endif}UnitOpenGLImage,{$ifdef fpcgl}gl,glext{$else}dglOpenGL{$endif};

type PPNGPixel=^TPNGPixel;
     TPNGPixel=packed record
      r,g,b,a:{$ifdef PNGHighDepth}word{$else}byte{$endif};
     end;

function LoadPNGImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;HeaderOnly:boolean):boolean;

implementation

{$ifdef android}
//uses SysUtils,RenderBase;
{$endif}

type TPNGHeader=array[0..7] of byte;

{$ifdef fpc}
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
type qword=uint64;
     ptruint=NativeUInt;
     ptrint=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
type qword=int64;
{$ifdef cpu64}
     ptruint=qword;
     ptrint=int64;
{$else}
     ptruint=longword;
     ptrint=longint;
{$endif}
{$endif}

{$if defined(delphi)}
function LoadPNGImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;HeaderOnly:boolean):boolean;
var Stream:TMemoryStream;
    PNG:TPNGImage;
    y,x:longint;
    pin,pout,ain:PAnsiChar;
    c:longword;
begin
 result:=false;
 try
  if (assigned(DataPointer) and (DataSize>8)) and
     ((pansichar(DataPointer)[0]=#$89) and (pansichar(DataPointer)[1]=#$50) and (pansichar(DataPointer)[2]=#$4e) and (pansichar(DataPointer)[3]=#$47) and
      (pansichar(DataPointer)[4]=#$0d) and (pansichar(DataPointer)[5]=#$0a) and (pansichar(DataPointer)[6]=#$1a) and (pansichar(DataPointer)[7]=#$0a)) then begin
   Stream:=TMemoryStream.Create;
   try
    if Stream.Write(DataPointer^,DataSize)=longint(DataSize) then begin
     if Stream.Seek(0,soFromBeginning)=0 then begin
      PNG:=TPNGImage.Create;
      try
       PNG.LoadFromStream(Stream);
       ImageWidth:=PNG.Width;
       ImageHeight:=PNG.Height;
       if not HeaderOnly then begin
        GetMem(ImageData,ImageWidth*ImageHeight*4);
        pout:=ImageData;
        case PNG.Header.ColorType of
{        COLOR_GRAYSCALE,COLOR_GRAYSCALEALPHA:begin
          for y:=0 to ImageHeight-1 do begin
           pin:=PNG.Scanline[y];
           if PNG.Header.ColorType=COLOR_GRAYSCALEALPHA then begin
            ain:=pointer(PNG.AlphaScanline[y]);
           end else begin
            ain:=nil;
           end;
           for x:=0 to ImageWidth-1 do begin
            pout[0]:=pin[0];
            pout[1]:=pin[0];
            pout[2]:=pin[0];
            if assigned(ain) then begin
             pout[3]:=ain[x];
            end else begin
             pout[3]:=#255;
            end;
            inc(pin,1);
            inc(pout,4);
           end;
          end;
         end;}
         COLOR_RGB,COLOR_RGBALPHA:begin
          for y:=0 to ImageHeight-1 do begin
           pin:=PNG.Scanline[y];
           if PNG.Header.ColorType=COLOR_RGBALPHA then begin
            ain:=pointer(PNG.AlphaScanline[y]);
           end else begin
            ain:=nil;
           end;
           for x:=0 to ImageWidth-1 do begin
            pout[0]:=pin[2];
            pout[1]:=pin[1];
            pout[2]:=pin[0];
            if assigned(ain) then begin
             pout[3]:=ain[x];
            end else begin
             pout[3]:=#255;
            end;
            inc(pin,3);
            inc(pout,4);
           end;
          end;
         end;
         else begin
          for y:=0 to ImageHeight-1 do begin
           if PNG.Header.ColorType in [COLOR_PALETTE,COLOR_GRAYSCALEALPHA] then begin
            ain:=pointer(PNG.AlphaScanline[y]);
           end else begin
            ain:=nil;
           end;
           for x:=0 to ImageWidth-1 do begin
            c:=PNG.Pixels[x,y];
            pout[0]:=ansichar(byte((c shr 0) and $ff));
            pout[1]:=ansichar(byte((c shr 8) and $ff));
            pout[2]:=ansichar(byte((c shr 16) and $ff));
            pout[3]:=ansichar(byte((c shr 24) and $ff));
            if assigned(ain) then begin
             pout[3]:=ain[x];
            end else begin
             pout[3]:=#255;
            end;
            inc(pout,4);
           end;
          end;
         end;
        end;
       end;
       result:=true;
      finally
       PNG.Free;
      end;
     end;
    end;
   finally
    Stream.Free;
   end;
  end;
 except
  result:=false;
 end;
end;
{$elseif defined(fpc)}
function LoadPNGImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;HeaderOnly:boolean):boolean;
var Image:TFPMemoryImage;
    ReaderPNG:TFPReaderPNG;
    Stream:TMemoryStream;
    y,x:longint;
    c:TFPColor;
    pout:PAnsiChar;
begin
 result:=false;
 try
  Stream:=TMemoryStream.Create;
  try
   if (assigned(DataPointer) and (DataSize>8)) and
      ((pansichar(DataPointer)[0]=#$89) and (pansichar(DataPointer)[1]=#$50) and (pansichar(DataPointer)[2]=#$4e) and (pansichar(DataPointer)[3]=#$47) and
       (pansichar(DataPointer)[4]=#$0d) and (pansichar(DataPointer)[5]=#$0a) and (pansichar(DataPointer)[6]=#$1a) and (pansichar(DataPointer)[7]=#$0a)) then begin
    if Stream.Write(DataPointer^,DataSize)=longint(DataSize) then begin
     if Stream.Seek(0,soFromBeginning)=0 then begin
      Image:=TFPMemoryImage.Create(20,20);
      try
       ReaderPNG:=TFPReaderPNG.Create;
       try
        Image.LoadFromStream(Stream,ReaderPNG);
        ImageWidth:=Image.Width;
        ImageHeight:=Image.Height;
        if not HeaderOnly then begin
         GetMem(ImageData,ImageWidth*ImageHeight*4);
         pout:=ImageData;
         for y:=0 to ImageHeight-1 do begin
          for x:=0 to ImageWidth-1 do begin
           c:=Image.Colors[x,y];
           pout[0]:=ansichar(byte((c.red shr 8) and $ff));
           pout[1]:=ansichar(byte((c.green shr 8) and $ff));
           pout[2]:=ansichar(byte((c.blue shr 8) and $ff));
           pout[3]:=ansichar(byte((c.alpha shr 8) and $ff));
           inc(pout,4);
          end;
         end;
        end;
        result:=true;
       finally
        ReaderPNG.Free;
       end;
      finally
       Image.Free;
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
{$elseif defined(android)}
type POwnStream=^TOwnStream;
     TOwnStream=record
      Data:pansichar;
     end;

procedure PNGReadData(png_ptr:png_structp;OutData:png_bytep;Bytes:png_size_t); cdecl;
var p:POwnStream;
begin
 p:=png_get_io_ptr(png_ptr);
 Move(p^.Data^,OutData^,Bytes);
 inc(p^.Data,Bytes);
end;

function LoadPNGImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;HeaderOnly:boolean):boolean;
type pword=^word;
const kPngSignatureLength=8;
var png_ptr:png_structp;
    info_ptr:png_infop;
    Stream:TOwnStream;
    Width,Height,BytesPerRow:longword;
    BitDepth,ColorType,x,y,NumPasses,Pass:longint;
    Row,Src,Dst:pansichar;
    Src16:pword;
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

// png_set_sig_bytes(png_ptr,kPngSignatureLength);

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

 if ColorType in [PNG_COLOR_TYPE_GRAY,PNG_COLOR_TYPE_GRAY_ALPHA,PNG_COLOR_TYPE_PALETTE,PNG_COLOR_TYPE_RGB,PNG_COLOR_TYPE_RGBA] then begin
  if not HeaderOnly then begin
   png_set_strip_16(png_ptr);
   png_set_packing(png_ptr);
   if (ColorType=PNG_COLOR_TYPE_PALETTE) or
     ((ColorType=PNG_COLOR_TYPE_GRAY) and (BitDepth<8)) then begin
    png_set_expand(png_ptr);
   end;
   if png_get_valid(png_ptr,info_ptr,PNG_INFO_tRNS)=PNG_INFO_tRNS then begin
    png_set_expand(png_ptr);
   end;
   png_set_gray_to_rgb(png_ptr);
   png_set_filler(png_ptr,$ff,PNG_FILLER_AFTER);
   png_read_update_info(png_ptr,info_ptr);
   if png_get_IHDR(png_ptr,info_ptr,@Width,@Height,@BitDepth,@ColorType,nil,nil,nil)<>1 then begin
    png_destroy_read_struct(@png_Ptr,nil,nil);
    exit;
   end;
   GetMem(ImageData,ImageWidth*ImageHeight*4);
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
          Value:=byte(Src^);
          inc(Src);
          Dst^:=ansichar(byte(Value));
          inc(Dst);
          Dst^:=ansichar(byte(Value));
          inc(Dst);
          Dst^:=ansichar(byte(Value));
          inc(Dst);
          Dst^:=#$ff;
          inc(Dst);
         end;
        end;
       end;
       16:begin
        Dst:=ImageData;
        for y:=0 to ImageHeight-1 do begin
         png_read_row(png_ptr,pointer(Row),nil);
         Src16:=pointer(Row);
         for x:=0 to ImageWidth-1 do begin
          Value:=Src16^ shr 8;
          inc(Src16);
          Dst^:=ansichar(byte(Value));
          inc(Dst);
          Dst^:=ansichar(byte(Value));
          inc(Dst);
          Dst^:=ansichar(byte(Value));
          inc(Dst);
          Dst^:=#$ff;
          inc(Dst);
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
        inc(color,byte(Src^));
        inc(Src);
        Dst^:=ansichar(byte(color^.red));
        inc(Dst);
        Dst^:=ansichar(byte(color^.green));
        inc(Dst);
        Dst^:=ansichar(byte(color^.blue));
        inc(Dst);
        Dst^:=#$ff;
        inc(Dst);
       end;
      end;
     end;
     PNG_COLOR_TYPE_RGB:begin
      case BitDepth of
       8:begin
        Dst:=ImageData;
        for y:=0 to ImageHeight-1 do begin
         png_read_row(png_ptr,pointer(Row),nil);
         Src:=Row;
         for x:=0 to ImageWidth-1 do begin
          Dst^:=Src^;
          inc(Src);
          inc(Dst);
          Dst^:=Src^;
          inc(Src);
          inc(Dst);
          Dst^:=Src^;
          inc(Src);
          inc(Dst);
          Dst^:=Src^;
          inc(Src);
          inc(Dst);
         end;
        end;
       end;
       16:begin
        Dst:=ImageData;
        for y:=0 to ImageHeight-1 do begin
         png_read_row(png_ptr,pointer(Row),nil);
         Src16:=pointer(Row);
         for x:=0 to ImageWidth-1 do begin
          Dst^:=ansichar(byte(Src16^ shr 8));
          inc(Src16);
          inc(Dst);
          Dst^:=ansichar(byte(Src16^ shr 8));
          inc(Src16);
          inc(Dst);
          Dst^:=ansichar(byte(Src16^ shr 8));
          inc(Src16);
          inc(Dst);
          Dst^:=ansichar(byte(Src16^ shr 8));
          inc(Src16);
          inc(Dst);
         end;
        end;
       end;
       else begin
        png_destroy_read_struct(@png_Ptr,nil,nil);
        exit;
       end;
      end;
     end;
     PNG_COLOR_TYPE_RGBA:begin
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
         Src16:=pointer(Row);
         for x:=0 to ImageWidth-1 do begin
          Dst^:=ansichar(byte(Src16^ shr 8));
          inc(Src16);
          inc(Dst);
          Dst^:=ansichar(byte(Src16^ shr 8));
          inc(Src16);
          inc(Dst);
          Dst^:=ansichar(byte(Src16^ shr 8));
          inc(Src16);
          inc(Dst);
          Dst^:=ansichar(byte(Src16^ shr 8));
          inc(Src16);
          inc(Dst);
         end;
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
{$else}

//const PNGHeader:TPNGHeader=($89,$50,$4e,$47,$0d,$0a,$1a,$0a);

function CRC32(data:pointer;length:longword):longword;
const CRC32Table:array[0..15] of longword=($00000000,$1db71064,$3b6e20c8,$26d930ac,$76dc4190,
                                           $6b6b51f4,$4db26158,$5005713c,$edb88320,$f00f9344,
                                           $d6d6a3e8,$cb61b38c,$9b64c2b0,$86d3d2d4,$a00ae278,
                                           $bdbdf21c);

var buf:pansichar;
    i:longword;
begin
 if length=0 then begin
  result:=0;
 end else begin
  buf:=data;
  result:=$ffffffff;
  for i:=1 to length do begin
   result:=result xor byte(buf^);
   result:=CRC32Table[result and $f] xor (result shr 4);
   result:=CRC32Table[result and $f] xor (result shr 4);
   inc(buf);
  end;
  result:=result xor $ffffffff;
 end;
end;

function Swap16(x:word):word;
begin
 result:=((x and $ff) shl 8) or ((x and $ff00) shr 8);
end;

function Swap32(x:longword):longword;
begin
 result:=(Swap16(x and $ffff) shl 16) or Swap16((x and $ffff0000) shr 16);
end;

function Swap64(x:int64):int64;
begin
 result:=(Swap32(x and $ffffffff) shl 32) or Swap32((x and $ffffffff00000000) shr 32);
end;

{$ifdef android}
function DoInflate(InData:pointer;InLen:longword;var DestData:pointer;var DestLen:longword;ParseHeader:boolean):boolean;
var d_stream:z_stream;
    r:longint;
    Delta:longword;
begin
 Delta:=4096;
 while Delta<=InLen do begin
  inc(Delta,Delta);
 end;
 DestLen:=Delta;
 GetMem(DestData,DestLen);
 FillChar(d_stream,SizeOf(z_stream),AnsiChar(#0));
 d_stream.next_in:=InData;
 d_stream.avail_in:=InLen;
 d_stream.next_out:=DestData;
 d_stream.avail_out:=DestLen;
 if ParseHeader then begin
  r:=inflateInit(d_stream);
 end else begin
  r:=inflateInit2(d_stream,-14{MAX_WBITS});
 end;
 if r<>Z_OK then begin
  FreeMem(DestData);
  DestData:=nil;
  result:=false;
  exit;
 end;
 while true do begin
  r:=Inflate(d_stream,Z_NO_FLUSH);
  if r=Z_STREAM_END then begin
   break;
  end else if r<Z_OK then begin
   InflateEnd(d_stream);
   FreeMem(DestData);
   DestData:=nil;
   result:=false;
   exit;
  end;
  inc(DestLen,Delta);
  ReallocMem(DestData,DestLen);
  d_stream.next_out:=pointer(@PAnsiChar(DestData)[d_stream.total_out]);
  d_stream.avail_out:=Delta;
 end;
 DestLen:=d_stream.total_out;
 ReallocMem(DestData,DestLen);
 InflateEnd(d_stream);
 result:=true;
end;
{$else}
function DoInflate(InData:pointer;InLen:longword;var DestData:pointer;var DestLen:longword;ParseHeader:boolean):boolean;
const CLCIndex:array[0..18] of byte=(16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15);
type pword=^word;
     PTree=^TTree;
     TTree=packed record
      Table:array[0..15] of word;
      Translation:array[0..287] of word;
     end;
     PBuffer=^TBuffer;
     TBuffer=array[0..65535] of byte;
     PLengths=^TLengths;
     TLengths=array[0..288+32-1] of byte;
     POffsets=^TOffsets;
     TOffsets=array[0..15] of word;
     PBits=^TBits;
     TBits=array[0..29] of byte;
     PBase=^TBase;
     TBase=array[0..29] of word;
var Tag,BitCount,DestSize:longword;
    SymbolLengthTree,DistanceTree,FixedSymbolLengthTree,FixedDistanceTree:PTree;
    LengthBits,DistanceBits:PBits;
    LengthBase,DistanceBase:PBase;
    Source,SourceEnd:pansichar;
    Dest:pansichar;
 procedure IncSize(length:longword);
 var j:longword;
 begin
  if (DestLen+length)>=DestSize then begin
   if DestSize=0 then begin
    DestSize:=1;
   end;
   while (DestLen+length)>=DestSize do begin
    inc(DestSize,DestSize);
   end;
   j:=ptruint(Dest)-ptruint(DestData);
   ReAllocMem(DestData,DestSize);
   ptruint(Dest):=ptruint(DestData)+j;
  end;
 end;           
 function adler32(data:pointer;length:longword):longword;
 const BASE=65521;
       NMAX=5552;
 var buf:pansichar;
     s1,s2,k,i:longword;
 begin
  s1:=1;
  s2:=0;
  buf:=data;
  while length>0 do begin
   if length<NMAX then begin
    k:=length;
   end else begin
    k:=NMAX;
   end;
   dec(length,k);
   for i:=1 to k do begin
    inc(s1,byte(buf^));
    inc(s2,s1);
    inc(buf);
   end;
   s1:=s1 mod BASE;
   s2:=s2 mod BASE;
  end;
  result:=(s2 shl 16) or s1;
 end;
 procedure BuildBitsBase(Bits:pansichar;Base:pword;Delta,First:longint);
 var i,Sum:longint;
 begin
  for i:=0 to Delta-1 do begin
   Bits[i]:=ansichar(#0);
  end;
  for i:=0 to (30-Delta)-1 do begin
   Bits[i+Delta]:=ansichar(byte(i div Delta));
  end;
  Sum:=First;
  for i:=0 to 29 do begin
   Base^:=Sum;
   inc(Base);
   inc(Sum,1 shl byte(Bits[i]));
  end;
 end;
 procedure BuildFixedTrees(var lt,dt:TTree);
 var i:longint;
 begin
  for i:=0 to 6 do begin
   lt.Table[i]:=0;
  end;
  lt.Table[7]:=24;
  lt.Table[8]:=152;
  lt.Table[9]:=112;
  for i:=0 to 23 do begin
   lt.Translation[i]:=256+i;
  end;
  for i:=0 to 143 do begin
   lt.Translation[24+i]:=i;
  end;
  for i:=0 to 7 do begin
   lt.Translation[168+i]:=280+i;
  end;
  for i:=0 to 111 do begin
   lt.Translation[176+i]:=144+i;
  end;
  for i:=0 to 4 do begin
   dt.Table[i]:=0;
  end;
  dt.Table[5]:=32;
  for i:=0 to 31 do begin
   dt.Translation[i]:=i;
  end;
 end;
 procedure BuildTree(var t:TTree;Lengths:pansichar;Num:longint);
 var Offsets:POffsets;
     i:longint;
     Sum:longword;
 begin
  New(Offsets);
  try
   for i:=0 to 15 do begin
    t.Table[i]:=0;
   end;
   for i:=0 to Num-1 do begin
    inc(t.Table[byte(Lengths[i])]);
   end;
   t.Table[0]:=0;
   Sum:=0;
   for i:=0 to 15 do begin
    Offsets^[i]:=Sum;
    inc(Sum,t.Table[i]);
   end;
   for i:=0 to Num-1 do begin
    if lengths[i]<>ansichar(#0) then begin
     t.Translation[Offsets^[byte(lengths[i])]]:=i;
     inc(Offsets^[byte(lengths[i])]);
    end;
   end;
  finally
   Dispose(Offsets);
  end;
 end;
 function GetBit:longword;
 begin
  if BitCount=0 then begin
   Tag:=byte(Source^);
   inc(Source);
   BitCount:=7;
  end else begin
   dec(BitCount);
  end;
  result:=Tag and 1;
  Tag:=Tag shr 1;
 end;
 function ReadBits(Num,Base:longword):longword;
 var Limit,Mask:longword;
 begin
  result:=0;
  if Num<>0 then begin
   Limit:=1 shl Num;
   Mask:=1;
   while Mask<Limit do begin
    if GetBit<>0 then begin
     inc(result,Mask);
    end;
    Mask:=Mask shl 1;
   end;
  end;
  inc(result,Base);
 end;
 function DecodeSymbol(var t:TTree):longword;
 var Sum,c,l:longint;
 begin
  Sum:=0;
  c:=0;
  l:=0;
  repeat
   c:=(c*2)+longint(GetBit);
   inc(l);
   inc(Sum,t.Table[l]);
   dec(c,t.Table[l]);
  until not (c>=0);
  result:=t.Translation[Sum+c];
 end;
 procedure DecodeTrees(var lt,dt:TTree);
 var CodeTree:PTree;
     Lengths:PLengths;
     hlit,hdist,hclen,i,num,length,clen,Symbol,Prev:longword;
 begin
  New(CodeTree);
  New(Lengths);
  try
   FillChar(CodeTree^,sizeof(TTree),ansichar(#0));
   FillChar(Lengths^,sizeof(TLengths),ansichar(#0));
   hlit:=ReadBits(5,257);
   hdist:=ReadBits(5,1);
   hclen:=ReadBits(4,4);
   for i:=0 to 18 do begin
    lengths^[i]:=0;
   end;
   for i:=1 to hclen do begin
    clen:=ReadBits(3,0);
    lengths^[CLCIndex[i-1]]:=clen;
   end;
   BuildTree(CodeTree^,pansichar(pointer(@lengths^[0])),19);
   num:=0;
   while num<(hlit+hdist) do begin
    Symbol:=DecodeSymbol(CodeTree^);
    case Symbol of
     16:begin
      prev:=lengths^[num-1];
      length:=ReadBits(2,3);
      while length>0 do begin
       lengths^[num]:=prev;
       inc(num);
       dec(length);
      end;
     end;
     17:begin
      length:=ReadBits(3,3);
      while length>0 do begin
       lengths^[num]:=0;
       inc(num);
       dec(length);
      end;
     end;
     18:begin
      length:=ReadBits(7,11);
      while length>0 do begin
       lengths^[num]:=0;
       inc(num);
       dec(length);
      end;
     end;
     else begin
      lengths^[num]:=Symbol;
      inc(num);
     end;
    end;
   end;
   BuildTree(lt,pansichar(pointer(@lengths^[0])),hlit);
   BuildTree(dt,pansichar(pointer(@lengths^[hlit])),hdist);
  finally
   Dispose(CodeTree);
   Dispose(Lengths);
  end;
 end;
 function InflateBlockData(var lt,dt:TTree):boolean;
 var Symbol:longword;
     Length,Distance,Offset,i:longint;
 begin
  result:=false;
  while (Source<SourceEnd) or (BitCount>0) do begin
   Symbol:=DecodeSymbol(lt);
   if Symbol=256 then begin
    result:=true;
    break;
   end;
   if Symbol<256 then begin
    IncSize(1);
    Dest^:=ansichar(byte(Symbol));
    inc(Dest);
    inc(DestLen);
   end else begin
    dec(Symbol,257);
    Length:=ReadBits(LengthBits^[Symbol],LengthBase^[Symbol]);
    Distance:=DecodeSymbol(dt);
    Offset:=ReadBits(DistanceBits^[Distance],DistanceBase^[Distance]);
    IncSize(length);
    for i:=0 to length-1 do begin
     Dest[i]:=Dest[i-Offset];
    end;
    inc(Dest,Length);
    inc(DestLen,Length);
   end;
  end;
 end;
 function InflateUncompressedBlock:boolean;
 var length,invlength:longword;
 begin
  result:=false;
  length:=(byte(source[1]) shl 8) or byte(source[0]);
  invlength:=(byte(source[3]) shl 8) or byte(source[2]);
  if length<>((not invlength) and $ffff) then begin
   exit;
  end;
  IncSize(length);
  inc(Source,4);
  if Length>0 then begin
   Move(Source^,Dest^,Length);
   inc(Source,Length);
   inc(Dest,Length);
  end;
  BitCount:=0;
  inc(DestLen,Length);
  result:=true;
 end;
 function InflateFixedBlock:boolean;
 begin
  result:=InflateBlockData(FixedSymbolLengthTree^,FixedDistanceTree^);
 end;
 function InflateDynamicBlock:boolean;
 begin
  DecodeTrees(SymbolLengthTree^,DistanceTree^);
  result:=InflateBlockData(SymbolLengthTree^,DistanceTree^);
 end;
 function Uncompress:boolean;
 var Final,r:boolean;
     BlockType:longword;
 begin
  result:=false;
  BitCount:=0;
  Final:=false;
  while not Final do begin
   Final:=GetBit<>0;
   BlockType:=ReadBits(2,0);
   case BlockType of
    0:begin
     r:=InflateUncompressedBlock;
    end;
    1:begin
     r:=InflateFixedBlock;
    end;
    2:begin
     r:=InflateDynamicBlock;
    end;
    else begin
     r:=false;
    end;
   end;
   if not r then begin
    exit;
   end;
  end;
  result:=true;
 end;
 function UncompressZLIB:boolean;
 var cmf,flg:byte;
     a32:longword;
 begin
  result:=false;
  Source:=InData;
  cmf:=byte(Source[0]);
  flg:=byte(Source[1]);
  if ((((cmf shl 8)+flg) mod 31)<>0) or ((cmf and $f)<>8) or ((cmf shr 4)>7) or ((flg and $20)<>0) then begin
   exit;
  end;
  a32:=(byte(Source[InLen-4]) shl 24) or (byte(Source[InLen-3]) shl 16) or (byte(Source[InLen-2]) shl 8) or (byte(Source[InLen-1]) shl 0);
  inc(Source,2);
  dec(InLen,6);
  SourceEnd:=@Source[InLen];
  result:=Uncompress;
  if not result then begin
   exit;
  end;
  result:=adler32(DestData,DestLen)=a32;
 end;
 function UncompressDirect:boolean;
 begin
  Source:=InData;
  SourceEnd:=@Source[InLen];
  result:=Uncompress;
 end;
begin
 DestData:=nil;
 LengthBits:=nil;
 DistanceBits:=nil;
 LengthBase:=nil;
 DistanceBase:=nil;
 SymbolLengthTree:=nil;
 DistanceTree:=nil;
 FixedSymbolLengthTree:=nil;
 FixedDistanceTree:=nil;
 try
  New(LengthBits);
  New(DistanceBits);
  New(LengthBase);
  New(DistanceBase);
  New(SymbolLengthTree);
  New(DistanceTree);
  New(FixedSymbolLengthTree);
  New(FixedDistanceTree);
  try
   begin
    FillChar(LengthBits^,sizeof(TBits),ansichar(#0));
    FillChar(DistanceBits^,sizeof(TBits),ansichar(#0));
    FillChar(LengthBase^,sizeof(TBase),ansichar(#0));
    FillChar(DistanceBase^,sizeof(TBase),ansichar(#0));
    FillChar(SymbolLengthTree^,sizeof(TTree),ansichar(#0));
    FillChar(DistanceTree^,sizeof(TTree),ansichar(#0));
    FillChar(FixedSymbolLengthTree^,sizeof(TTree),ansichar(#0));
    FillChar(FixedDistanceTree^,sizeof(TTree),ansichar(#0));
   end;
   begin
    BuildFixedTrees(FixedSymbolLengthTree^,FixedDistanceTree^);
    BuildBitsBase(pansichar(pointer(@LengthBits^[0])),pword(pointer(@LengthBase^[0])),4,3);
    BuildBitsBase(pansichar(pointer(@DistanceBits^[0])),pword(pointer(@DistanceBase^[0])),2,1);
    LengthBits^[28]:=0;
    LengthBase^[28]:=258;
   end;
   begin
    GetMem(DestData,4096);
    DestSize:=4096;
    Dest:=DestData;
    DestLen:=0;
    if ParseHeader then begin
     result:=UncompressZLIB;
    end else begin
     result:=UncompressDirect;
    end;
    if result then begin
     ReAllocMem(DestData,DestLen);
    end else if assigned(DestData) then begin
     FreeMem(DestData);
     DestData:=nil;
    end;
   end;
  finally
   if assigned(LengthBits) then begin
    Dispose(LengthBits);
   end;
   if assigned(DistanceBits) then begin
    Dispose(DistanceBits);
   end;
   if assigned(LengthBase) then begin
    Dispose(LengthBase);
   end;
   if assigned(DistanceBase) then begin
    Dispose(DistanceBase);
   end;
   if assigned(SymbolLengthTree) then begin
    Dispose(SymbolLengthTree);
   end;
   if assigned(DistanceTree) then begin
    Dispose(DistanceTree);
   end;
   if assigned(FixedSymbolLengthTree) then begin
    Dispose(FixedSymbolLengthTree);
   end;
   if assigned(FixedDistanceTree) then begin
    Dispose(FixedDistanceTree);
   end;
  end;
 except
  result:=false;
 end;
end;
{$endif}

type PPNGPixelEx=^TPNGPixelEx;
     TPNGPixelEx=packed record
      r,g,b,a:word;
     end;

     TPNGColorFunc=function(x:int64):TPNGPixelEx;

function ColorGray1(x:int64):TPNGPixelEx;
begin
 result.r:=(0-(x and 1)) and $ffff;
 result.g:=(0-(x and 1)) and $ffff;
 result.b:=(0-(x and 1)) and $ffff;
 result.a:=$ffff;
end;

function ColorGray2(x:int64):TPNGPixelEx;
begin
 result.r:=(x and 3) or ((x and 3) shl 2) or ((x and 3) shl 4) or ((x and 3) shl 6) or ((x and 3) shl 8) or ((x and 3) shl 10) or ((x and 3) shl 12) or ((x and 3) shl 14);
 result.g:=(x and 3) or ((x and 3) shl 2) or ((x and 3) shl 4) or ((x and 3) shl 6) or ((x and 3) shl 8) or ((x and 3) shl 10) or ((x and 3) shl 12) or ((x and 3) shl 14);
 result.b:=(x and 3) or ((x and 3) shl 2) or ((x and 3) shl 4) or ((x and 3) shl 6) or ((x and 3) shl 8) or ((x and 3) shl 10) or ((x and 3) shl 12) or ((x and 3) shl 14);
 result.a:=$ffff;
end;

function ColorGray4(x:int64):TPNGPixelEx;
begin
 result.r:=(x and $f) or ((x and $f) shl 4) or ((x and $f) shl 8) or ((x and $f) shl 12);
 result.g:=(x and $f) or ((x and $f) shl 4) or ((x and $f) shl 8) or ((x and $f) shl 12);
 result.b:=(x and $f) or ((x and $f) shl 4) or ((x and $f) shl 8) or ((x and $f) shl 12);
 result.a:=$ffff;
end;

function ColorGray8(x:int64):TPNGPixelEx;
begin
 result.r:=(x and $ff) or ((x and $ff) shl 8);
 result.g:=(x and $ff) or ((x and $ff) shl 8);
 result.b:=(x and $ff) or ((x and $ff) shl 8);
 result.a:=$ffff;
end;

function ColorGray16(x:int64):TPNGPixelEx;
begin
 result.r:=x and $ffff;
 result.g:=x and $ffff;
 result.b:=x and $ffff;
 result.a:=$ffff;
end;

function ColorGrayAlpha8(x:int64):TPNGPixelEx;
begin
 result.r:=(x and $00ff) or ((x and $00ff) shl 8);
 result.g:=(x and $00ff) or ((x and $00ff) shl 8);
 result.b:=(x and $00ff) or ((x and $00ff) shl 8);
 result.a:=(x and $ff00) or ((x and $ff00) shr 8);
end;

function ColorGrayAlpha16(x:int64):TPNGPixelEx;
begin
 result.r:=(x shr 16) and $ffff;
 result.g:=(x shr 16) and $ffff;
 result.b:=(x shr 16) and $ffff;
 result.a:=x and $ffff;
end;

function ColorColor8(x:int64):TPNGPixelEx;
begin
 result.r:=(x and $ff) or ((x and $ff) shl 8);
 result.g:=((x shr 8) and $ff) or (((x shr 8) and $ff) shl 8);
 result.b:=((x shr 16) and $ff) or (((x shr 16) and $ff) shl 8);
 result.a:=$ffff;
end;

function ColorColor16(x:int64):TPNGPixelEx;
begin
 result.r:=x and $ffff;
 result.g:=(x shr 16) and $ffff;
 result.b:=(x shr 32) and $ffff;
 result.a:=$ffff;
end;

function ColorColorAlpha8(x:int64):TPNGPixelEx;
begin
 result.r:=(x and $ff) or ((x and $ff) shl 8);
 result.g:=((x shr 8) and $ff) or (((x shr 8) and $ff) shl 8);
 result.b:=((x shr 16) and $ff) or (((x shr 16) and $ff) shl 8);
 result.a:=((x shr 24) and $ff) or (((x shr 24) and $ff) shl 8);
end;

function ColorColorAlpha16(x:int64):TPNGPixelEx;
begin
 result.r:=x and $ffff;
 result.g:=(x shr 16) and $ffff;
 result.b:=(x shr 32) and $ffff;
 result.a:=(x shr 48) and $ffff;
end;

function Paeth(a,b,c:longint):longint;
var p,pa,pb,pc:longint;
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

function LoadPNGImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;HeaderOnly:boolean):boolean;
type TBitsUsed=array[0..7] of longword;
     PByteArray=^TByteArray;
     TByteArray=array[0..65535] of byte;
     TColorData=int64;
const StartPoints:array[0..7,0..1] of word=((0,0),(0,0),(4,0),(0,4),(2,0),(0,2),(1,0),(0,1));
      Delta:array[0..7,0..1] of word=((1,1),(8,8),(8,8),(4,8),(4,4),(2,4),(2,2),(1,2));
      BitsUsed1Depth:TBitsUsed=($80,$40,$20,$10,$08,$04,$02,$01);
      BitsUsed2Depth:TBitsUsed=($c0,$30,$0c,$03,0,0,0,0);
      BitsUsed4Depth:TBitsUsed=($f0,$0f,0,0,0,0,0,0);
var DataEnd,DataPtr,DataNextChunk,DataPtrEx:pointer;
    ConvertColor:TPNGColorFunc;
    ByteWidth:longint;
    CountBitsUsed,BitShift,UsingBitGroup,DataIndex:longword;
    DataBytes:TColorData;
    DataBytes32:longword;
    BitDepth,StartX,StartY,DeltaX,DeltaY,{ImageBytesPerPixel,}WidthHeight:longint;
    BitsUsed:TBitsUsed;
    SwitchLine,CurrentLine,PreviousLine:PByteArray;
    CountScanlines,ScanLineLength:array[0..7] of longword;
    ChunkLength,ChunkType,Width,Height,ColorType,Comp,Filter,Interlace,CRC,
    PalImgBytes,ImgBytes,PaletteSize,l,ml:longword;
    First,HasTransparent,CgBI:boolean;
    Palette:array of array[0..3] of byte;
    TransparentColor:array of word;
    i,rx,ry,y{,BitsPerPixel,ImageLineWidth,ImageSize},StartPass,EndPass,d:longint;
    idata,DecompressPtr:pointer;
    idatasize,idatacapacity,idataexpandedsize,LineFilter:longword;
    idataexpanded:pointer;
 function GetU8(var p:pointer):byte;
 begin
  result:=byte(p^);
  inc(pansichar(p),sizeof(byte));
 end;
 function GetU16(var p:pointer):word;
 begin
  result:=GetU8(p) shl 8;
  result:=result or GetU8(p);
 end;
 function GetU32(var p:pointer):longword;
 begin
  result:=GetU16(p) shl 16;
  result:=result or GetU16(p);
 end;
 function CalcColor:TColorData;
 var r:word;
     b:byte;
 begin
  if UsingBitGroup=0 then begin
   DataBytes:=0;
   if BitDepth=16 then begin
    r:=1;
    while r<ByteWidth do begin
     b:=CurrentLine^[DataIndex+r];
     CurrentLine^[DataIndex+r]:=CurrentLine^[DataIndex+longword(r-1)];
     CurrentLine^[DataIndex+longword(r-1)]:=b;
     inc(r,2);
    end;
   end;
   Move(CurrentLine^[DataIndex],DataBytes,ByteWidth);
{$ifdef big_endian}
   DataBytes:=Swap64(DataBytes);
{$endif}
   inc(DataIndex,ByteWidth);
  end;
  if ByteWidth=1 then begin
   result:=(longword(DataBytes and BitsUsed[UsingBitGroup]) and $ffffffff) shr (((CountBitsUsed-UsingBitGroup)-1)*BitShift);
   inc(UsingBitgroup);
   if UsingBitGroup>=CountBitsUsed then begin
    UsingBitGroup:=0;
   end;
  end else begin
   result:=DataBytes;
  end;
 end;
 procedure HandleScanLine(const y,CurrentPass:longint;const ScanLine:PByteArray);
 var x,l:longint;
     c:TColorData;
     pe:TPNGPixelEx;
     p:PPNGPixel;
 begin
  UsingBitGroup:=0;
  DataIndex:=0;
  if length(Palette)<>0 then begin
   l:=length(Palette);
   for x:=0 to ScanlineLength[CurrentPass]-1 do begin
    c:=CalcColor;
    if c<l then begin
     p:=PPNGPixel(pointer(@pansichar(ImageData)[((y*longint(Width))+(StartX+(x*DeltaX)))*sizeof(TPNGPixel)]));
{$ifdef PNGHighDepth}
     p^.r:=Palette[c,0] or (Palette[c,0] shl 8);
     p^.g:=Palette[c,1] or (Palette[c,1] shl 8);
     p^.b:=Palette[c,2] or (Palette[c,2] shl 8);
     p^.a:=Palette[c,3] or (Palette[c,3] shl 8);
{$else}
     p^.r:=Palette[c,0];
     p^.g:=Palette[c,1];
     p^.b:=Palette[c,2];
     p^.a:=Palette[c,3];
{$endif}
    end;
   end;
  end else begin
   if addr(ConvertColor)=@ColorColorAlpha8 then begin
    l:=length(TransparentColor);
    for x:=0 to ScanlineLength[CurrentPass]-1 do begin
     DataBytes32:=longword(pointer(@CurrentLine^[DataIndex])^);
{$ifdef big_endian}
     DataBytes32:=Swap32(DataBytes32);
{$endif}
     inc(DataIndex,4);
     pe.r:=(DataBytes32 and $ff) or ((DataBytes32 and $ff) shl 8);
     pe.g:=((DataBytes32 shr 8) and $ff) or (((DataBytes32 shr 8) and $ff) shl 8);
     pe.b:=((DataBytes32 shr 16) and $ff) or (((DataBytes32 shr 16) and $ff) shl 8);
     pe.a:=((DataBytes32 shr 24) and $ff) or (((DataBytes32 shr 24) and $ff) shl 8);
     p:=PPNGPixel(pointer(@pansichar(ImageData)[((y*longint(Width))+(StartX+(x*DeltaX)))*sizeof(TPNGPixel)]));
     if (((l=1) and ((pe.r=TransparentColor[0]) and (pe.r=TransparentColor[0]) and (pe.b=TransparentColor[0])))) or
        (((l=3) and ((pe.r=TransparentColor[0]) and (pe.r=TransparentColor[1]) and (pe.b=TransparentColor[2])))) then begin
      pe.a:=0;
     end;
{$ifdef PNGHighDepth}
     p^.r:=pe.r;
     p^.g:=pe.g;
     p^.b:=pe.b;
     p^.a:=pe.a;
{$else}
     p^.r:=pe.r shr 8;
     p^.g:=pe.g shr 8;
     p^.b:=pe.b shr 8;
     p^.a:=pe.a shr 8;
{$endif}
    end;
   end else if addr(ConvertColor)=@ColorColor8 then begin
    l:=length(TransparentColor);
    for x:=0 to ScanlineLength[CurrentPass]-1 do begin
     DataBytes32:=longword(pointer(@CurrentLine^[DataIndex])^) and $00ffffff;
{$ifdef big_endian}
     DataBytes32:=Swap32(DataBytes32);
{$endif}
     inc(DataIndex,3);
     pe.r:=(DataBytes32 and $ff) or ((DataBytes32 and $ff) shl 8);
     pe.g:=((DataBytes32 shr 8) and $ff) or (((DataBytes32 shr 8) and $ff) shl 8);
     pe.b:=((DataBytes32 shr 16) and $ff) or (((DataBytes32 shr 16) and $ff) shl 8);
     pe.a:=$ffff;
     p:=PPNGPixel(pointer(@pansichar(ImageData)[((y*longint(Width))+(StartX+(x*DeltaX)))*sizeof(TPNGPixel)]));
     if (((l=1) and ((pe.r=TransparentColor[0]) and (pe.r=TransparentColor[0]) and (pe.b=TransparentColor[0])))) or
        (((l=3) and ((pe.r=TransparentColor[0]) and (pe.r=TransparentColor[1]) and (pe.b=TransparentColor[2])))) then begin
      pe.a:=0;
     end;
{$ifdef PNGHighDepth}
     p^.r:=pe.r;
     p^.g:=pe.g;
     p^.b:=pe.b;
     p^.a:=pe.a;
{$else}
     p^.r:=pe.r shr 8;
     p^.g:=pe.g shr 8;
     p^.b:=pe.b shr 8;
     p^.a:=pe.a shr 8;
{$endif}
    end;
   end else if assigned(ConvertColor) then begin
    l:=length(TransparentColor);
    for x:=0 to ScanlineLength[CurrentPass]-1 do begin
     pe:=ConvertColor(CalcColor);
     p:=PPNGPixel(pointer(@pansichar(ImageData)[((y*longint(Width))+(StartX+(x*DeltaX)))*sizeof(TPNGPixel)]));
     if (((l=1) and ((pe.r=TransparentColor[0]) and (pe.r=TransparentColor[0]) and (pe.b=TransparentColor[0])))) or
        (((l=3) and ((pe.r=TransparentColor[0]) and (pe.r=TransparentColor[1]) and (pe.b=TransparentColor[2])))) then begin
      pe.a:=0;
     end;
{$ifdef PNGHighDepth}
     p^.r:=pe.r;
     p^.g:=pe.g;
     p^.b:=pe.b;
     p^.a:=pe.a;
{$else}
     p^.r:=pe.r shr 8;
     p^.g:=pe.g shr 8;
     p^.b:=pe.b shr 8;
     p^.a:=pe.a shr 8;
{$endif}
    end;
   end;
  end;
 end;
 procedure CgBISwapBGR2RGBandUnpremultiply;
 const UnpremultiplyFactor={$ifdef PNGHighDepth}65535{$else}255{$endif};
       FullAlpha={$ifdef PNGHighDepth}65535{$else}255{$endif};
 var i,b,a:longint;
     p:PPNGPixel;
 begin
  a:=FullAlpha;
  p:=PPNGPixel(pointer(@pansichar(ImageData)[0]));
  for i:=0 to WidthHeight-1 do begin
   a:=a and p^.a;
   inc(p);
  end;
  if ((ColorType and 4)<>0) or (a<>FullAlpha) or HasTransparent then begin
   p:=PPNGPixel(pointer(@pansichar(ImageData)[0]));
   for i:=0 to WidthHeight-1 do begin
    a:=p^.a;
    if a<>0 then begin
     b:=p^.b;
     p^.b:=(p^.r*UnpremultiplyFactor) div a;
     p^.r:=(b*UnpremultiplyFactor) div a;
     p^.g:=(p^.g*UnpremultiplyFactor) div a;
    end else begin
     b:=p^.b;
     p^.b:=p^.r;
     p^.r:=b;
    end;
    inc(p);
   end;
  end else begin
   p:=PPNGPixel(pointer(@pansichar(ImageData)[0]));
   for i:=0 to WidthHeight-1 do begin
    b:=p^.b;
    p^.b:=p^.r;
    p^.r:=b;
    inc(p);
   end;
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
   if (assigned(DataPointer) and (DataSize>8)) and
      ((pansichar(DataPointer)[0]=#$89) and (pansichar(DataPointer)[1]=#$50) and (pansichar(DataPointer)[2]=#$4e) and (pansichar(DataPointer)[3]=#$47) and
       (pansichar(DataPointer)[4]=#$0d) and (pansichar(DataPointer)[5]=#$0a) and (pansichar(DataPointer)[6]=#$1a) and (pansichar(DataPointer)[7]=#$0a)) then begin
    DataEnd:=@pansichar(DataPointer)[DataSize];
    First:=true;
    PalImgBytes:=0;
    ImgBytes:=0;
    DataPtr:=@pansichar(DataPointer)[8];
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
    DataBytes:=0;
    CgBI:=false;
    HasTransparent:=false;
    while (pansichar(DataPtr)+11)<pansichar(DataEnd) do begin
     ChunkLength:=GetU32(DataPtr);
     if (pansichar(DataPtr)+(4+ChunkLength))>pansichar(DataEnd) then begin
      result:=false;
      break;
     end;
     DataPtrEx:=DataPtr;
     ChunkType:=GetU32(DataPtr);
     DataNextChunk:=@pansichar(DataPtr)[ChunkLength];
     CRC:=GetU32(DataNextChunk);
     if CRC32(DataPtrEx,ChunkLength+4)<>CRC then begin
      result:=false;
      break;
     end;
     case ChunkType of
      longword((ord('C') shl 24) or (ord('g') shl 16) or (ord('B') shl 8) or ord('I')):begin // CgBI
       CgBI:=true;
      end;
      longword((ord('I') shl 24) or (ord('H') shl 16) or (ord('D') shl 8) or ord('R')):begin // IHDR
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
      longword((ord('P') shl 24) or (ord('L') shl 16) or (ord('T') shl 8) or ord('E')):begin // PLTE
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
          Palette[i,0]:=GetU8(DataPtr);
          Palette[i,1]:=GetU8(DataPtr);
          Palette[i,2]:=GetU8(DataPtr);
          Palette[i,3]:=$ff;
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
          Palette[i,0]:=GetU8(DataPtr);
          Palette[i,1]:=GetU8(DataPtr);
          Palette[i,2]:=GetU8(DataPtr);
          Palette[i,3]:=GetU8(DataPtr);
         end;
        end;
        else begin
         result:=false;
         break;
        end;
       end;
      end;
      longword((ord('t') shl 24) or (ord('R') shl 16) or (ord('N') shl 8) or ord('S')):begin // tRNS
       if First or assigned(idata) then begin
        result:=false;
        break;
       end;
       if PalImgBytes<>0 then begin
        if (length(Palette)=0) or (longint(ChunkLength)>length(Palette)) then begin
         result:=false;
         break;
        end;
        PalImgBytes:=4;
        for i:=0 to PaletteSize-1 do begin
         Palette[i,3]:=GetU8(DataPtr);
        end;
       end else begin
        if ChunkLength=ImgBytes then begin
         SetLength(TransparentColor,longint(ImgBytes));
         for i:=0 to longint(ImgBytes)-1 do begin
          d:=GetU8(DataPtr);
          TransparentColor[i]:=d or (d shl 8);
         end;
        end else begin
         if ((ImgBytes and 1)=0) or (ChunkLength<>(ImgBytes*2)) then begin
          result:=false;
          break;
         end;
         HasTransparent:=true;
         SetLength(TransparentColor,longint(ImgBytes));
         for i:=0 to longint(ImgBytes)-1 do begin
          TransparentColor[i]:=GetU16(DataPtr);
         end;
        end;
       end;
      end;
      longword((ord('I') shl 24) or (ord('D') shl 16) or (ord('A') shl 8) or ord('T')):begin // IDAT
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
        Move(DataPtr^,pansichar(idata)[idatasize],ChunkLength);
        inc(idatasize,ChunkLength);
       end;
      end;
      longword((ord('I') shl 24) or (ord('E') shl 16) or (ord('N') shl 8) or ord('D')):begin // IEND
       if First or ((PalImgBytes<>0) and (length(Palette)=0)) or not assigned(idata) then begin
        result:=false;
        break;
       end;
       if not DoInflate(idata,idatasize,idataexpanded,idataexpandedsize,not CgBI) then begin
        result:=false;
        break;
       end;
//     BitsPerPixel:=longint(ImgBytes)*BitDepth;
       ImageWidth:=Width;
       ImageHeight:=Height;
       WidthHeight:=Width*Height;
//     ImageBytesPerPixel:=((longint(ImgBytes)*longint(BitDepth))+7) shr 3;
//     ImageLineWidth:=((ImageWidth*BitsPerPixel)+7) shr 3;
//     ImageSize:=(((ImageWidth*ImageHeight)*BitsPerPixel)+7) shr 3;
       GetMem(ImageData,(ImageWidth*ImageHeight)*sizeof(TPNGPixel));
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
        ConvertColor:=nil;
        case ColorType of
         0:begin
          case BitDepth of
           1:begin
            ConvertColor:=@ColorGray1;
            ByteWidth:=1;
           end;
           2:begin
            ConvertColor:=@ColorGray2;
            ByteWidth:=1;
           end;
           4:begin
            ConvertColor:=@ColorGray4;
            ByteWidth:=1;
           end;
           8:begin
            ConvertColor:=@ColorGray8;
            ByteWidth:=1;
           end;
           16:begin
            ConvertColor:=@ColorGray16;
            ByteWidth:=2;
           end;
          end;
         end;
         2:begin
          if BitDepth=8 then begin
           ConvertColor:=@ColorColor8;
           ByteWidth:=3;
          end else begin
           ConvertColor:=@ColorColor16;
           ByteWidth:=6;
          end;
         end;
         3:begin
          if BitDepth=16 then begin
           ByteWidth:=2;
          end else begin
           ByteWidth:=1;
          end;
         end;
         4:begin
          if BitDepth=8 then begin
           ConvertColor:=@ColorGrayAlpha8;
           ByteWidth:=2;
          end else begin
           ConvertColor:=@ColorGrayAlpha16;
           ByteWidth:=4;
          end;
         end;
         6:begin
          if BitDepth=8 then begin
           ConvertColor:=@ColorColorAlpha8;
           ByteWidth:=4;
          end else begin
           ConvertColor:=@ColorColorAlpha16;
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
           l:=ScanLineLength[i]*longword(ByteWidth);
          end;
          if ml=0 then begin
           GetMem(PreviousLine,l);
           GetMem(CurrentLine,l);
          end else if ml<l then begin
           ReallocMem(PreviousLine,l);
           ReallocMem(CurrentLine,l);
          end;
          ml:=l;
          FillChar(CurrentLine^,l,ansichar(#0));
          for ry:=0 to CountScanlines[i]-1 do begin
           SwitchLine:=CurrentLine;
           CurrentLine:=PreviousLine;
           PreviousLine:=SwitchLine;
           y:=StartY+(ry*DeltaY);
           LineFilter:=GetU8(DecompressPtr);
           Move(DecompressPtr^,CurrentLine^,l);
           inc(pansichar(DecompressPtr),l);
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

end.
