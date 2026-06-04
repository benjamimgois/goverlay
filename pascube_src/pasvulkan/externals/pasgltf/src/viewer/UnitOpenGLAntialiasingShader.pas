unit UnitOpenGLAntialiasingShader;
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

type TAntialiasingShader=class(TShader)
      public
       uTexture:glInt;
      public
       constructor Create;
       destructor Destroy; override;
       procedure BindAttributes; override;
       procedure BindVariables; override;
      end;

implementation

constructor TAntialiasingShader.Create;
var f,v:ansistring;
begin
 v:='#version 330'+#13#10+
    'out vec2 vTexCoord;'+#13#10+
    'void main(){'+#13#10+
    '  vTexCoord = vec2((gl_VertexID >> 1) * 2.0, (gl_VertexID & 1) * 2.0);'+#13#10+
    '  gl_Position = vec4(((gl_VertexID >> 1) * 4.0) - 1.0, ((gl_VertexID & 1) * 4.0) - 1.0, 0.0, 1.0);'+#13#10+
    '}'+#13#10;
 f:='#version 330'+#13#10+
    'in vec2 vTexCoord;'+#13#10+
    'layout(location = 0) out vec4 oOutput;'+#13#10+
    'uniform sampler2D uTexture;'+#13#10+
    'void main(){'+#13#10+
    '  vec2 uFragCoordInvScale = vec2(1.0) / vec2(textureSize(uTexture, 0).xy);'+#13#10+
    '  vec4 p = vec4(vTexCoord, vec2(vTexCoord - (uFragCoordInvScale * (0.5 + (1.0 / 4.0)))));'+#13#10+
    '  const float FXAA_SPAN_MAX = 8.0,'+#13#10+
    '              FXAA_REDUCE_MUL = 1.0 / 8.0,'+#13#10+
    '              FXAA_REDUCE_MIN = 1.0 / 128.0;'+#13#10+
    '  vec3 rgbNW = textureLod(uTexture, p.zw, 0.0).xyz,'+#13#10+
    '       rgbNE = textureLodOffset(uTexture, p.zw, 0.0, ivec2(1, 0)).xyz,'+#13#10+
    '       rgbSW = textureLodOffset(uTexture, p.zw, 0.0, ivec2(0, 1)).xyz,'+#13#10+
    '       rgbSE = textureLodOffset(uTexture, p.zw, 0.0, ivec2(1, 1)).xyz,'+#13#10+
    '       rgbM = textureLod(uTexture, p.xy, 0.0).xyz,'+#13#10+
    '       luma = vec3(0.299, 0.587, 0.114);'+#13#10+
    '  float lumaNW = dot(rgbNW, luma),'+#13#10+
    '        lumaNE = dot(rgbNE, luma),'+#13#10+
    '        lumaSW = dot(rgbSW, luma),'+#13#10+
    '        lumaSE = dot(rgbSE, luma),'+#13#10+
    '        lumaM = dot(rgbM, luma),'+#13#10+
    '        lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE))), '+#13#10+
    '        lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));'+#13#10+
    '  vec2 dir = vec2(-((lumaNW + lumaNE) - (lumaSW + lumaSE)), ((lumaNW + lumaSW) - (lumaNE + lumaSE)));'+#13#10+
    '  float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN), '+#13#10+
    '  rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);'+#13#10+
    '  dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)) * uFragCoordInvScale;'+#13#10+
    '  vec4 rgbA = (1.0 / 2.0) * (textureLod(uTexture, p.xy + (dir * ((1.0 / 3.0) - 0.5)), 0.0).xyzw + textureLod(uTexture, p.xy + (dir * ((2.0 / 3.0) - 0.5)), 0.0).xyzw),'+#13#10+
    '       rgbB = (rgbA * (1.0 / 2.0)) + ((1.0 / 4.0) * (textureLod(uTexture, p.xy + (dir * ((0.0 / 3.0) - 0.5)), 0.0).xyzw + textureLod(uTexture, p.xy + (dir * ((3.0 / 3.0) - 0.5)), 0.0).xyzw));'+#13#10+
    '  float lumaB = dot(rgbB.xyz, luma);'+#13#10+
    '  oOutput = ((lumaB < lumaMin) || (lumaB > lumaMax)) ? rgbA : rgbB;'+#13#10+
    '}'+#13#10;
 inherited Create(v,f);
end;

destructor TAntialiasingShader.Destroy;
begin
 inherited Destroy;
end;

procedure TAntialiasingShader.BindAttributes;
begin
 inherited BindAttributes;
end;

procedure TAntialiasingShader.BindVariables;
begin
 inherited BindVariables;
 uTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uTexture')));
end;

end.
