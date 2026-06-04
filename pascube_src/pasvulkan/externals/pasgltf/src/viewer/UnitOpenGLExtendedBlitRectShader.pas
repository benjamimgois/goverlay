unit UnitOpenGLExtendedBlitRectShader;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpuamd64}
  {$define cpux86_64}
 {$endif}
 {$ifdef cpu386}
  {$define cpux86}
  {$define cpu32}
  {$asmmode intel}
 {$endif}
 {$ifdef cpux86_64}
  {$define cpux64}
  {$define cpu64}
  {$asmmode intel}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
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
 {$if declared(RawByteString)}
  {$define HAS_TYPE_RAWBYTESTRING}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$ifend}
 {$if declared(UTF8String)}
  {$define HAS_TYPE_UTF8STRING}
 {$else}
  {$undef HAS_TYPE_UTF8STRING}
 {$ifend}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$ifdef cpux64}
  {$define cpux86_64}
  {$define cpu64}
 {$else}
  {$ifdef cpu386}
   {$define cpux86}
   {$define cpu32}
  {$endif}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$ifdef conditionalexpressions}
  {$if declared(RawByteString)}
   {$define HAS_TYPE_RAWBYTESTRING}
  {$else}
   {$undef HAS_TYPE_RAWBYTESTRING}
  {$ifend}
  {$if declared(UTF8String)}
   {$define HAS_TYPE_UTF8STRING}
  {$else}
   {$undef HAS_TYPE_UTF8STRING}
  {$ifend}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
  {$undef HAS_TYPE_UTF8STRING}
 {$endif}
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

interface

uses {$ifdef fpcgl}gl,glext,{$else}dglOpenGL,{$endif}UnitOpenGLShader;

type TExtendedBlitRectShader=class(TShader)
      public
       uTexture:glInt;
      public
       constructor Create;
       destructor Destroy; override;
       procedure BindAttributes; override;
       procedure BindVariables; override;
      end;

var ExtendedBlitRectShader:TExtendedBlitRectShader=nil;

implementation

constructor TExtendedBlitRectShader.Create;
var f,v:ansistring;
begin
 v:='#version 330'+#13#10+
    'attribute vec2 aPosition;'+#10+
    'attribute vec2 aTexCoord;'+#10+
    'attribute vec4 aColor;'+#10+
    'out vec2 vTexCoord;'+#10+
    'out vec4 vColor;'+#10+
    'void main(){'+#10+
    '  vTexCoord = aTexCoord.xy;'+#10+
    '  vColor = aColor;'+#10+
    '  gl_Position = vec4(vec3(aPosition.xy, 0.0), 1.0);'+#10+
    '}'+#10;
 f:='#version 330'+#13#10+
    'in vec2 vTexCoord;'+#10+
    'in vec4 vColor;'+#10+
    'layout(location = 0) out vec4 oOutput;'+#13#10+
    'uniform sampler2D uTexture;'+#13#10+
    'void main(){'+#13#10+
    '  oOutput = texture(uTexture, vTexCoord) * vColor;'+#13#10+
    '}'+#13#10;
 inherited Create(v,f);
end;

destructor TExtendedBlitRectShader.Destroy;
begin
 inherited Destroy;
end;

procedure TExtendedBlitRectShader.BindAttributes;
begin
 inherited BindAttributes;
 glBindAttribLocation(ProgramHandle,0,pointer(pansichar('aPosition')));
 glBindAttribLocation(ProgramHandle,1,pointer(pansichar('aTexCoord')));
 glBindAttribLocation(ProgramHandle,2,pointer(pansichar('aColor')));
end;

procedure TExtendedBlitRectShader.BindVariables;
begin
 inherited BindVariables;
 uTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uTexture')));
end;

end.
