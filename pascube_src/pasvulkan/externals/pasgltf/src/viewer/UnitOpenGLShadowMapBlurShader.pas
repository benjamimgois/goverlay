unit UnitOpenGLShadowMapBlurShader;
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

type TShadowMapBlurShader=class(TShader)
      public
       uTexture:glInt;
       uDirection:glInt;
      public
       constructor Create;
       destructor Destroy; override;
       procedure BindAttributes; override;
       procedure BindVariables; override;
      end;

implementation

constructor TShadowMapBlurShader.Create;
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
    'uniform vec2 uDirection;'+#13#10+
    'vec4 GaussianBlur(const in sampler2D pTexSource, const in vec2 pCenterUV, const in float pLOD, const in vec2 pPixelOffset){'+#13#10+
    '  return ((textureLod(pTexSource, pCenterUV + (pPixelOffset * 0.5949592424752924), pLOD) +'+#13#10+
    '           textureLod(pTexSource, pCenterUV - (pPixelOffset * 0.5949592424752924), pLOD)) * 0.3870341767000849)+'+#13#10+
    '         ((textureLod(pTexSource, pCenterUV + (pPixelOffset * 2.176069137573487), pLOD) +'+#13#10+
    '           textureLod(pTexSource, pCenterUV - (pPixelOffset * 2.176069137573487), pLOD)) * 0.11071876711891004);'+#13#10+
{   '  return ((textureLod(pTexSource, pCenterUV + (pPixelOffset * 0.6591712451751888), pLOD) +'+#13#10+
    '           textureLod(pTexSource, pCenterUV - (pPixelOffset * 0.6591712451751888), pLOD)) * 0.15176565679402804)+'+#13#10+
    '         ((textureLod(pTexSource, pCenterUV + (pPixelOffset * 2.4581680281192115), pLOD) +'+#13#10+
    '           textureLod(pTexSource, pCenterUV - (pPixelOffset * 2.4581680281192115), pLOD)) * 0.16695645822541735)+'+#13#10+
    '         ((textureLod(pTexSource, pCenterUV + (pPixelOffset * 4.425094078679077), pLOD) +'+#13#10+
    '           textureLod(pTexSource, pCenterUV - (pPixelOffset * 4.425094078679077), pLOD)) * 0.10520961571427603)+'+#13#10+
    '         ((textureLod(pTexSource, pCenterUV + (pPixelOffset * 6.39267736227941), pLOD) +'+#13#10+
    '           textureLod(pTexSource, pCenterUV - (pPixelOffset * 6.39267736227941), pLOD)) * 0.05091823661517932)+'+#13#10+
    '         ((textureLod(pTexSource, pCenterUV + (pPixelOffset * 8.361179642955081), pLOD) +'+#13#10+
    '           textureLod(pTexSource, pCenterUV - (pPixelOffset * 8.361179642955081), pLOD)) * 0.01892391240315673)+'+#13#10+
    '         ((textureLod(pTexSource, pCenterUV + (pPixelOffset * 10.330832149360727), pLOD) +'+#13#10+
    '           textureLod(pTexSource, pCenterUV - (pPixelOffset * 10.330832149360727), pLOD)) * 0.005400173381332095);'+#13#10+}
    '}'+#13#10+
    'void main(){'+#13#10+
    '  oOutput = GaussianBlur(uTexture, vTexCoord, 0.0, (vec2(1.0) / textureSize(uTexture, 0)) * uDirection);'+#13#10+
    '}'+#13#10;
 inherited Create(v,f);
end;

destructor TShadowMapBlurShader.Destroy;
begin
 inherited Destroy;
end;

procedure TShadowMapBlurShader.BindAttributes;
begin
 inherited BindAttributes;
end;

procedure TShadowMapBlurShader.BindVariables;
begin
 inherited BindVariables;
 uTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uTexture')));
 uDirection:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uDirection')));
end;

end.
