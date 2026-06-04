unit UnitOpenGLShadowMapMultisampleResolveShader;
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

type TShadowMapMultisampleResolveShader=class(TShader)
      public
       uTexture:glInt;
       uSamples:glInt;
      public
       constructor Create;
       destructor Destroy; override;
       procedure BindAttributes; override;
       procedure BindVariables; override;
      end;

implementation

constructor TShadowMapMultisampleResolveShader.Create;
var f,v:ansistring;
begin
 v:='#version 430'+#13#10+
    'out vec2 vTexCoord;'+#13#10+
    'void main(){'+#13#10+
    '  vTexCoord = vec2((gl_VertexID >> 1) * 2.0, (gl_VertexID & 1) * 2.0);'+#13#10+
    '  gl_Position = vec4(((gl_VertexID >> 1) * 4.0) - 1.0, ((gl_VertexID & 1) * 4.0) - 1.0, 0.0, 1.0);'+#13#10+
    '}'+#13#10;
 f:='#version 430'+#13#10+
    'in vec2 vTexCoord;'+#13#10+
    'layout(location = 0) out vec4 oOutput;'+#13#10+
    'uniform sampler2DMS uTexture;'+#13#10+
    'uniform int uSamples;'+#13#10+
    'void main(){'+#13#10+
    '  ivec2 position = ivec2(gl_FragCoord.xy);'+#13#10+
    '  vec4 sum = vec4(0.0);'+#13#10+
    '  for(int i = 0; i < uSamples; i++){'+#13#10+
    '    float d = texelFetch(uTexture, position, i).x, d2 = d * d;'+#13#10+
    '    sum += vec4(d, d2, d2 * d, d2 * d2);'+#13#10+
    '  }'+#13#10+
//  '  oOutput = sum / float(uSamples);'+#13#10+
    '  oOutput = ((sum / float(uSamples)) *'+#13#10+
    '             mat4(-2.07224649, 32.23703778, -68.571074599, 39.3703274134,'+#13#10+
    '                  13.7948857237, -59.4683975703, 82.0359750338, -35.364903257,'+#13#10+
    '                  0.105877704, -1.9077466311, 9.3496555107, -6.6543490743,'+#13#10+
    '                  9.7924062118, -33.7652110555, 47.9456096605, -23.9728048165)) + vec2(0.035955884801, 0.0).xyyy;'+#13#10+{}
    '}'+#13#10;
 inherited Create(v,f);
end;

destructor TShadowMapMultisampleResolveShader.Destroy;
begin
 inherited Destroy;
end;

procedure TShadowMapMultisampleResolveShader.BindAttributes;
begin
 inherited BindAttributes;
end;

procedure TShadowMapMultisampleResolveShader.BindVariables;
begin
 inherited BindVariables;
 uTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uTexture')));
 uSamples:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uSamples')));
end;

end.
