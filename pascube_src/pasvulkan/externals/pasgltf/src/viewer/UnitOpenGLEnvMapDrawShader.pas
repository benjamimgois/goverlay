unit UnitOpenGLEnvMapDrawShader;
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

type TEnvMapDrawShader=class(TShader)
      public
       uTexture:glInt;
       uViewProjectionMatrix:glInt;
      public
       constructor Create;
       destructor Destroy; override;
       procedure BindAttributes; override;
       procedure BindVariables; override;
      end;

implementation

constructor TEnvMapDrawShader.Create;
var f,v:ansistring;
begin
 v:='#version 330'+#13#10+
    'out vec3 vPosition;'+#13#10+
    'uniform mat4 uViewProjectionMatrix;'+#13#10+
    'void main(){'+#13#10+
    '  int vertexID = int(gl_VertexID),'+#13#10+
    '      vertexIndex = vertexID % 3,'+#13#10+
    '      faceIndex = vertexID / 3,'+#13#10+
    '      stripVertexID = faceIndex + (((faceIndex & 1) == 0) ? (2 - vertexIndex) : vertexIndex),'+#13#10+
    '	     reversed = int(stripVertexID > 6),'+#13#10+
    '	     index = (reversed == 1) ? (13 - stripVertexID) : stripVertexID;'+#13#10+
    '  vPosition = (vec3(ivec3(int((index < 3) || (index == 4)), reversed ^ int((index > 0) && (index < 4)), reversed ^ int((index < 2) || (index > 5)))) * 2.0) - vec3(1.0);'+#13#10+
    '	 gl_Position = (uViewProjectionMatrix * vec4(vPosition, 1.0)).xyww;'+#13#10+
    '}'+#13#10;
 f:='#version 330'+#13#10+
    'in vec3 vPosition;'+#13#10+
    'layout(location = 0) out vec4 oOutput;'+#13#10+
    'uniform samplerCube uTexture;'+#13#10+
    'void main(){'+#13#10+
    '	 oOutput = texture(uTexture, normalize(vPosition));'+#13#10+
    '}'+#13#10;
 inherited Create(v,f);
end;

destructor TEnvMapDrawShader.Destroy;
begin
 inherited Destroy;
end;

procedure TEnvMapDrawShader.BindAttributes;
begin
 inherited BindAttributes;
end;

procedure TEnvMapDrawShader.BindVariables;
begin
 inherited BindVariables;
 uTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uTexture')));
 uViewProjectionMatrix:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uViewProjectionMatrix')));
end;

end.
