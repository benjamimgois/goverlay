unit UnitOpenGLImage;
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

uses {$ifdef fpcgl}gl,glext{$else}dglOpenGL{$endif};

function LoadImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;HeaderOnly:boolean=false;MipMapLevel:longint=0;IsFloat:pboolean=nil):boolean;

implementation

uses Math,UnitOpenGLImagePNG,UnitOpenGLImageJPEG;

function LoadImage(DataPointer:pointer;DataSize:longword;var ImageData:pointer;var ImageWidth,ImageHeight:longint;HeaderOnly:boolean=false;MipMapLevel:longint=0;IsFloat:pboolean=nil):boolean;
var IsFloatTemp:boolean;
    i:longint;
    pf:psingle;
    pb:pbyte;
begin
 if assigned(IsFloat) then begin
  IsFloat^:=false;
 end;
 IsFloatTemp:=false;
 if (MipMapLevel=0) and LoadPNGImage(DataPointer,DataSize,ImageData,ImageWidth,ImageHeight,HeaderOnly) then begin
  result:=true;
 end else begin
  if assigned(IsFloat) then begin
   IsFloat^:=false;
  end;
  result:=LoadJPEGImage(DataPointer,DataSize,ImageData,ImageWidth,ImageHeight,HeaderOnly);
 end;
 if assigned(IsFloat) then begin
  IsFloat^:=IsFloatTemp;
 end else begin
  if IsFloatTemp then begin
   pf:=ImageData;
   pb:=ImageData;
   for i:=1 to (ImageWidth*ImageHeight)*4 do begin
    pb^:=Min(Max(round(pf^*255.0),0),255);
    inc(pf);
    inc(pb);
   end;
  end;
 end;
end;

initialization
finalization
end.
