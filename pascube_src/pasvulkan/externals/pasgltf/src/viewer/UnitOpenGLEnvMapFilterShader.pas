unit UnitOpenGLEnvMapFilterShader;
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

type TEnvMapFilterShader=class(TShader)
      public
       uTexture:glInt;
       uMipMapLevel:glInt;
       uMaxMipMapLevel:glInt;
      public
       constructor Create;
       destructor Destroy; override;
       procedure BindAttributes; override;
       procedure BindVariables; override;
      end;

implementation

constructor TEnvMapFilterShader.Create;
var f,v:ansistring;
begin
 v:='#version 330'+#13#10+
    '#extension GL_AMD_vertex_shader_layer : enable'+#13#10+
    'out vec2 vTexCoord;'+#13#10+
    'flat out int vFaceIndex;'+#13#10+
    'void main(){'+#13#10+
    '  // For 18 vertices (6x attribute-less-rendered "full-screen" triangles)'+#13#10+
    '  int vertexID = int(gl_VertexID),'+#13#10+
    '      vertexIndex = vertexID % 3,'+#13#10+
    '      faceIndex = vertexID / 3;'+#13#10+
    '  vTexCoord = vec2((vertexIndex >> 1) * 2.0, (vertexIndex & 1) * 2.0);'+#13#10+
    '  vFaceIndex = faceIndex;'+#13#10+
    '  gl_Position = vec4(((vertexIndex >> 1) * 4.0) - 1.0, ((vertexIndex & 1) * 4.0) - 1.0, 0.0, 1.0);'+#13#10+
    '  gl_Layer = faceIndex;'+#13#10+
    '}'+#13#10;
 f:='#version 330'+#13#10+
    'layout(location = 0) out vec4 oOutput;'+#13#10+
    'in vec2 vTexCoord;'+#13#10+
    'flat in int vFaceIndex;'+#13#10+
    'uniform int uMipMapLevel;'+#13#10+
    'uniform int uMaxMipMapLevel;'+#13#10+
    'uniform samplerCube uTexture;'+#13#10+
    'vec2 Hammersley(const in int index, const in int numSamples){'+#13#10+
//  '  uint reversedIndex = bitfieldReverse(uint(index));'+#13#10+ // >= OpenGL 4.0
    '  uint reversedIndex = uint(index);'+#13#10+
    '  reversedIndex = (reversedIndex << 16u) | (reversedIndex >> 16u);'+#13#10+
    '  reversedIndex = ((reversedIndex & 0x00ff00ffu) << 8u) | ((reversedIndex & 0xff00ff00u) >> 8u);'+#13#10+
    '  reversedIndex = ((reversedIndex & 0x0f0f0f0fu) << 4u) | ((reversedIndex & 0xf0f0f0f0u) >> 4u);'+#13#10+
    '  reversedIndex = ((reversedIndex & 0x33333333u) << 2u) | ((reversedIndex & 0xccccccccu) >> 2u);'+#13#10+
    '  reversedIndex = ((reversedIndex & 0x55555555u) << 1u) | ((reversedIndex & 0xaaaaaaaau) >> 1u);'+#13#10+
    '  return vec2(fract(float(index) / float(numSamples)), float(reversedIndex) * 2.3283064365386963e-10);'+#13#10+
    '}'+#13#10+
    'vec3 ImportanceSampleGGX(const in vec2 e, const in float roughness, const in vec3 normal){'+#13#10+
    '  float m = roughness * roughness;'+#13#10+
    '  float m2 = m * m;'+#13#10+
    '  float phi = 2.0 * 3.1415926535897932384626433832795 * e.x;'+#13#10+
    '  float cosTheta = sqrt((1.0 - e.y) / (1.0 + ((m2 - 1.0) * e.y)));'+#13#10+
    '  float sinTheta = sqrt(1.0 - (cosTheta * cosTheta));'+#13#10+
    '  vec3 h = vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);'+#13#10+
    '  vec3 tangentZ = normalize(normal);'+#13#10+
    '  vec3 upVector = (abs(tangentZ.z) < 0.999) ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);'+#13#10+
    '  vec3 tangentX = normalize(cross(upVector, tangentZ));'+#13#10+
    '  vec3 tangentY = cross(tangentZ, tangentX);'+#13#10+
    '  return (tangentX * h.x) + (tangentY * h.y) + (tangentZ * h.z);'+#13#10+
    '}'+#13#10+
    'vec3 getCubeMapDirection(in vec2 uv,'+#13#10+
    '                         in int faceIndex){'+#13#10+
    '  vec3 zDir = vec3(ivec3((faceIndex <= 1) ? 1 : 0,'+#13#10+
    '                         (faceIndex & 2) >> 1,'+#13#10+
    '                         (faceIndex & 4) >> 2)) *'+#13#10+
    '             (((faceIndex & 1) == 1) ? -1.0 : 1.0),'+#13#10+
    '       yDir = (faceIndex == 2)'+#13#10+
    '                ? vec3(0.0, 0.0, 1.0)'+#13#10+
    '                : ((faceIndex == 3)'+#13#10+
    '                     ? vec3(0.0, 0.0, -1.0)'+#13#10+
    '                     : vec3(0.0, -1.0, 0.0)),'+#13#10+
    '       xDir = cross(zDir, yDir);'+#13#10+
    '  return normalize((mix(-1.0, 1.0, uv.x) * xDir) +'+#13#10+
    '                   (mix(-1.0, 1.0, uv.y) * yDir) +'+#13#10+
    '                   zDir);'+#13#10+
    '}'+#13#10+
    'void main(){'+#13#10+
    '  vec3 direction = getCubeMapDirection(vTexCoord, vFaceIndex);'+#13#10+
    '  if(uMipMapLevel == 0){'+#13#10+
    '    oOutput = textureLod(uTexture, direction, 0.0);'+#13#10+
    '	}else{'+#13#10+
    '	  float roughness = clamp(exp2((1.0 - float((uMaxMipMapLevel - 1) - uMipMapLevel)) / 1.2), 0.0, 1.0);'+#13#10+
    '	  const int numSamples = 64;'+#13#10+
    '	  vec3 R = direction;'+#13#10+
    '	  vec3 N = R;'+#13#10+
    '	  vec3 V = R;'+#13#10+
    '	  vec4 r = vec4(0.0);'+#13#10+
    '	  float w = 0.0;'+#13#10+
    '	  for(int i = 0; i < numSamples; i++){'+#13#10+
    '	    vec3 H = ImportanceSampleGGX(Hammersley(i, numSamples), roughness, N);'+#13#10+
    '	    vec3 L = -reflect(V, H);'+#13#10+ //((2.0 * dot(V, H )) * H) - V;
    '	    float nDotL = clamp(dot(N, L), 0.0, 1.0);'+#13#10+
    '	    if(nDotL > 0.0){'+#13#10+
    '	      vec3 rayDirection = normalize(L);'+#13#10+
    '	      r += textureLod(uTexture, rayDirection, 0.0) * nDotL;'+#13#10+
    '	      w += nDotL;'+#13#10+
    '	    }'+#13#10+
    '	  }'+#13#10+
    '	  oOutput = r / max(w, 1e-4);'+#13#10+
    '  }'+#13#10+
    '}'+#13#10;
 inherited Create(v,f);
end;

destructor TEnvMapFilterShader.Destroy;
begin
 inherited Destroy;
end;

procedure TEnvMapFilterShader.BindAttributes;
begin
 inherited BindAttributes;
end;

procedure TEnvMapFilterShader.BindVariables;
begin
 inherited BindVariables;
 uTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uTexture')));
 uMipMapLevel:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uMipMapLevel')));
 uMaxMipMapLevel:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uMaxMipMapLevel')));
end;

end.
