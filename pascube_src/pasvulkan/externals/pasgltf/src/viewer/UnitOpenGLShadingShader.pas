unit UnitOpenGLShadingShader;
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
 {$legacyifend on}
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

uses SysUtils,Classes,{$ifdef fpcgl}gl,glext,{$else}dglOpenGL,{$endif}UnitOpenGLShader;

type TShadingShader=class(TShader)
      public
       const uboFrameGlobals=0;
             uboMaterial=1;
             ssboJointMatrices=2;
             ssboMorphTargetVertices=3;
             ssboNodeMeshPrimitiveMetaData=4;
             ssboLightData=5;
{$ifdef PasGLTFUseExternalData}
             ssboExternalData=6;
{$endif}
      public
       uBRDFLUTTexture:glInt;
       uNormalShadowMapArrayTexture:glInt;
       uCubeMapShadowMapArrayTexture:glInt;
       uEnvMapTexture:glInt;
{$if not defined(PasGLTFBindlessTextures)}
       uTextures:glInt;
{$ifend}
       uEnvMapMaxLevel:glInt;
       uShadows:glInt;
       constructor Create(const aSkinned,aAlphaTest,aShadowMap:boolean);
       destructor Destroy; override;
       procedure BindAttributes; override;
       procedure BindVariables; override;
      end;

implementation

constructor TShadingShader.Create(const aSkinned,aAlphaTest,aShadowMap:boolean);
var f0,f1,f2,f,v:ansistring;
begin
 if aSkinned then begin
  f0:='layout(std140, binding = '+IntToStr(ssboJointMatrices)+') buffer ssboJointMatrices {'+#13#10+
      '  mat4 jointMatrices[];'+#13#10+
      '};'+#13#10;
  f1:='  uint jointMatrixOffset = primitiveMetaData.y;'+#13#10+
      '  mat4 inverseMatrix = inverse(nodeMatrix);'+#13#10+
      '  mat4 skinMatrix = ((inverseMatrix * jointMatrices[jointMatrixOffset + uint(aJoints0.x)]) * aWeights0.x) +'+#13#10+
      '                    ((inverseMatrix * jointMatrices[jointMatrixOffset + uint(aJoints0.y)]) * aWeights0.y) +'+#13#10+
      '                    ((inverseMatrix * jointMatrices[jointMatrixOffset + uint(aJoints0.z)]) * aWeights0.z) +'+#13#10+
      '                    ((inverseMatrix * jointMatrices[jointMatrixOffset + uint(aJoints0.w)]) * aWeights0.w);'+#13#10+
      '  if(any(not(equal(aWeights1, vec4(0.0))))){'+#13#10+
      '    skinMatrix += ((inverseMatrix * jointMatrices[jointMatrixOffset + uint(aJoints1.x)]) * aWeights1.x) +'+#13#10+
      '                  ((inverseMatrix * jointMatrices[jointMatrixOffset + uint(aJoints1.y)]) * aWeights1.y) +'+#13#10+
      '                  ((inverseMatrix * jointMatrices[jointMatrixOffset + uint(aJoints1.z)]) * aWeights1.z) +'+#13#10+
      '                  ((inverseMatrix * jointMatrices[jointMatrixOffset + uint(aJoints1.w)]) * aWeights1.w);'+#13#10+
      '  }'+#13#10;
  f2:=' * skinMatrix';
 end else begin
  f0:='';
  f1:='';
  f2:='';
 end;
 v:='#version 430'+#13#10+
    'layout(location = 0) in vec3 aPosition;'+#13#10+
    'layout(location = 1) in vec3 aNormal;'+#13#10+
    'layout(location = 2) in vec4 aTangent;'+#13#10+
    'layout(location = 3) in vec2 aTexCoord0;'+#13#10+
    'layout(location = 4) in vec2 aTexCoord1;'+#13#10+
    'layout(location = 5) in vec4 aColor0;'+#13#10+
    'layout(location = 6) in uvec4 aJoints0;'+#13#10+
    'layout(location = 7) in uvec4 aJoints1;'+#13#10+
    'layout(location = 8) in vec4 aWeights0;'+#13#10+
    'layout(location = 9) in vec4 aWeights1;'+#13#10+
    'layout(location = 10) in uint aVertexIndex;'+#13#10+
    'out vec3 vWorldSpacePosition;'+#13#10;
 if not aShadowMap then begin
  v:=v+'out vec3 vCameraRelativePosition;'+#13#10;
 end;
 v:=v+
    'out vec2 vTexCoord0;'+#13#10+
    'out vec2 vTexCoord1;'+#13#10+
    'out vec3 vNormal;'+#13#10+
    'out vec3 vTangent;'+#13#10+
    'out vec3 vBitangent;'+#13#10+
    'out vec4 vColor;'+#13#10+
    'layout(std140, binding = '+IntToStr(uboFrameGlobals)+') uniform uboFrameGlobals {'+#13#10+
    '  mat4 inverseViewMatrix;'+#13#10+
    '  mat4 modelMatrix;'+#13#10+
    '  mat4 viewProjectionMatrix;'+#13#10+
    '  mat4 normalMatrix;'+#13#10+
    '} uFrameGlobals;'+#13#10+
    'struct MorphTargetVertex {'+#13#10+
    '  vec4 position;'+#13#10+
    '  vec4 normal;'+#13#10+
    '  vec4 tangent;'+#13#10+
    '  vec4 reversed;'+#13#10+
    '};'+#13#10+
    'layout(std430, binding = '+IntToStr(ssboMorphTargetVertices)+') buffer ssboMorphTargetVertices {'+#13#10+
    '  MorphTargetVertex morphTargetVertices[];'+#13#10+
    '};'+#13#10+
    'layout(std430, binding = '+IntToStr(ssboNodeMeshPrimitiveMetaData)+') buffer ssboNodeMeshPrimitiveMetaData {'+#13#10+
    '  mat4 nodeMatrix;'+#13#10+
    '  uvec4 primitiveMetaData;'+#13#10+
    '  float morphTargetWeights[];'+#13#10+
    '};'+#13#10+
{$ifdef PasGLTFUseExternalData}
    'layout(std430, binding = '+IntToStr(ssboExternalData)+') buffer ssboExternalData {'+#13#10+
    '  mat4 externalModelMatrix;'+#13#10+
    '};'+#13#10+
{$endif}
    f0+
    'void main(){'+#13#10+
    f1+
    '  vec3 position = aPosition,'+#13#10+
    '       normal = aNormal,'+#13#10+
    '       tangent = aTangent.xyz;'+#13#10+
    '  for(uint index = 0, count = primitiveMetaData.w; index < count; index++){'+#13#10+
    '    float morphTargetWeight = morphTargetWeights[index];'+#13#10+
    '    uint morphTargetVertexIndex = (index * primitiveMetaData.z) + uint(aVertexIndex);'+#13#10+
    '    position += morphTargetVertices[morphTargetVertexIndex].position.xyz * morphTargetWeight;'+#13#10+
    '    normal += morphTargetVertices[morphTargetVertexIndex].normal.xyz * morphTargetWeight;'+#13#10+
    '    tangent += morphTargetVertices[morphTargetVertexIndex].tangent.xyz * morphTargetWeight;'+#13#10+
    '  }'+#13#10+
    '  mat4 modelMatrix = uFrameGlobals.modelMatrix * nodeMatrix'+f2+';'+#13#10+
{$ifdef PasGLTFUseExternalData}
    '  modelMatrix = externalModelMatrix * modelMatrix;'+#13#10+
{$endif}
    '  mat3 normalMatrix = transpose(inverse(mat3(modelMatrix)));'+#13#10+
    '  vNormal = normalize(normalMatrix * normal);'+#13#10+
    '  vTangent = normalize(normalMatrix * tangent);'+#13#10+
    '  vBitangent = cross(vNormal, vTangent) * aTangent.w;'+#13#10+
    '  vTexCoord0 = aTexCoord0;'+#13#10+
    '  vTexCoord1 = aTexCoord1;'+#13#10+
    '  vColor = aColor0;'+#13#10+
    '  vec4 worldSpacePosition = modelMatrix * vec4(position, 1.0);'+#13#10+
    '  vWorldSpacePosition = worldSpacePosition.xyz / worldSpacePosition.w;'+#13#10;
 if not aShadowMap then begin
  v:=v+'  vCameraRelativePosition = (worldSpacePosition.xyz / worldSpacePosition.w) - uFrameGlobals.inverseViewMatrix[3].xyz;'+#13#10;
 end;
 v:=v+
    '  gl_Position = uFrameGlobals.viewProjectionMatrix * worldSpacePosition;'+#13#10+
    '}'+#13#10;
 f:='#version 430'+#13#10+
{$ifdef PasGLTFBindlessTextures}
    '#extension GL_ARB_bindless_texture : require'+#13#10+
{$endif}
    'layout(location = 0) out vec4 oOutput;'+#13#10+
{$ifdef PasGLTFExtraEmissionOutput}
    'layout(location = 1) out vec4 oEmission;'+#13#10+
{$endif}
    'in vec3 vWorldSpacePosition;'+#13#10;
 if aShadowMap then begin
 end else begin
  f:=f+'in vec3 vCameraRelativePosition;'+#13#10;
 end;
 f:=f+
    'in vec2 vTexCoord0;'+#13#10+
    'in vec2 vTexCoord1;'+#13#10+
    'in vec3 vNormal;'+#13#10+
    'in vec3 vTangent;'+#13#10+
    'in vec3 vBitangent;'+#13#10+
    'in vec4 vColor;'+#13#10+
    'uniform sampler2D uBRDFLUTTexture;'+#13#10+
    'uniform samplerCube uEnvMapTexture;'+#13#10+
    'uniform sampler2DArray uNormalShadowMapArrayTexture;'+#13#10+
    'uniform samplerCubeArray uCubeMapShadowMapArrayTexture;'+#13#10+
    'uniform sampler2D uTextures[16];'+#13#10+
    'uniform int uEnvMapMaxLevel;'+#13#10+
    'uniform int uShadows;'+#13#10+
    'layout(std140, binding = '+IntToStr(uboFrameGlobals)+') uniform uboFrameGlobals {'+#13#10+
    '  mat4 inverseViewMatrix;'+#13#10+
    '  mat4 modelMatrix;'+#13#10+
    '  mat4 viewProjectionMatrix;'+#13#10+
    '  mat4 normalMatrix;'+#13#10+
    '} uFrameGlobals;'+#13#10+
    'layout(std140, binding = '+IntToStr(uboMaterial)+') uniform uboMaterial {'+#13#10+
    '  vec4 baseColorFactor;'+#13#10+
    '  vec4 specularFactor;'+#13#10+
    '  vec4 emissiveFactor;'+#13#10+
    '  vec4 metallicRoughnessNormalScaleOcclusionStrengthFactor;'+#13#10+
    '  vec4 sheenColorFactorSheenIntensityFactor;'+#13#10+
    '  vec4 clearcoatFactorClearcoatRoughnessFactor;'+#13#10+
    '  uvec4 alphaCutOffFlagsTex0Tex1;'+#13#10+
    '  mat4 textureTransforms[16];'+#13#10+
{$if defined(PasGLTFBindlessTextures)}
    '  uvec4 textureHandles[8];'+#13#10+
{$elseif defined(PasGLTFIndicatedTextures) and not defined(PasGLTFBindlessTextures)}
    '  ivec4 textureIndices[4];'+#13#10+
{$ifend}
    '} uMaterial;'+#13#10+
    'struct Light {'+#13#10+
    '  uvec4 metaData;'+#13#10+
    '  vec4 colorIntensity;'+#13#10+
    '  vec4 positionRange;'+#13#10+
    '  vec4 directionZFar;'+#13#10+
    '  mat4 shadowMapMatrix;'+#13#10+
    '};'+#13#10+
    'layout(std430, binding = '+IntToStr(ssboLightData)+') buffer ssboLightData {'+#13#10+
    '  uvec4 lightMetaData;'+#13#10+
    '  Light lights[];'+#13#10+
    '};'+#13#10+
    'vec3 convertLinearRGBToSRGB(vec3 c){'+#13#10+
    '  return mix((pow(c, vec3(1.0 / 2.4)) * vec3(1.055)) - vec3(5.5e-2),'+#13#10+
    '             c * vec3(12.92),'+#13#10+
    '             lessThan(c, vec3(3.1308e-3)));'+#13#10+
    '}'+#13#10+
    'vec3 convertSRGBToLinearRGB(vec3 c){'+#13#10+
    '  return mix(pow((c + vec3(5.5e-2)) / vec3(1.055), vec3(2.4)),'+#13#10+
    '             c / vec3(12.92),'+#13#10+
    '             lessThan(c, vec3(4.045e-2)));'+#13#10+
    '}'+#13#10+
    'const float PI = 3.14159265358979323846,'+#13#10+
    '            PI2 = 6.283185307179586476925286766559,'+#13#10+
    '            OneOverPI = 1.0 / PI;'+#13#10+
    'float sheenRoughness, cavity, transparency, refractiveAngle, ambientOcclusion,'+#13#10+
     '     shadow, reflectance, clearcoatFactor, clearcoatRoughness;'+#13#10+
    'vec4 sheenColorIntensityFactor;'+#13#10+
    'vec3 clearcoatF0, clearcoatNormal, imageLightBasedLightDirection;'+#13#10+
    'uint flags, shadingModel;'+#13#10+
    'vec3 diffuseLambert(vec3 diffuseColor){'+#13#10+
    '  return diffuseColor * OneOverPI;'+#13#10+
    '}'+#13#10+
    'vec3 diffuseFunction(vec3 diffuseColor, float roughness, float nDotV, float nDotL, float vDotH){'+#13#10+
    '  float FD90 = 0.5 + (2.0 * (vDotH * vDotH * roughness)),'+#13#10+
    '        FdV = 1.0 + ((FD90 - 1.0) * pow(1.0 - nDotV, 5.0)),'+#13#10+
    '        FdL = 1.0 + ((FD90 - 1.0) * pow(1.0 - nDotL, 5.0));'+#13#10+
    '  return diffuseColor * (OneOverPI * FdV * FdL);'+#13#10+
    '}'+#13#10+
    'vec3 specularF(const in vec3 specularColor, const in float vDotH){'+#13#10+
    '  float fc = pow(1.0 - vDotH, 5.0);'+#13#10+
    '  return vec3(clamp(max(max(specularColor.x, specularColor.y), specularColor.z) * 50.0, 0.0, 1.0) * fc) + ((1.0 - fc) * specularColor);'+#13#10+
    '}'+#13#10+
    'float specularD(const in float roughness, const in float nDotH){'+#13#10+
    '  float a = roughness * roughness;'+#13#10+
    '  float a2 = a * a;'+#13#10+
    '  float d = (((nDotH * a2) - nDotH) * nDotH) + 1.0;'+#13#10+
    '  return a2 / (PI * (d * d));'+#13#10+
    '}'+#13#10+
    'float specularG(const in float roughness, const in float nDotV, const in float nDotL){'+#13#10+
    '  float k = (roughness * roughness) * 0.5;'+#13#10+
    '  vec2 GVL = (vec2(nDotV, nDotL) * (1.0 - k)) + vec2(k);'+#13#10+
    '  return 0.25 / (GVL.x * GVL.y);'+#13#10+
    '}'+#13#10+
    'float visibilityNeubelt(float NdotL, float NdotV){'+#13#10+
    '  return clamp(1.0 / (4.0 * ((NdotL + NdotV) - (NdotL * NdotV))), 0.0, 1.0);'+#13#10+
    '}'+#13#10+
    'float sheenDistributionCarlie(float sheenRoughness, float NdotH){'+#13#10+
    '  float invR = 1.0 / (sheenRoughness * sheenRoughness);'+#13#10+
    '  return (2.0 + invR) * pow(1.0 - (NdotH * NdotH), invR * 0.5) / PI2;'+#13#10+
    '}'+#13#10+
    'vec3 diffuseOutput, specularOutput, sheenOutput, clearcoatOutput, clearcoatBlendFactor;'+#13#10+
    'void doSingleLight(const in vec3 lightColor,'+#13#10+
    '                   const in vec3 lightLit,'+#13#10+
    '                   const in vec3 lightDirection,'+#13#10+
    '                   const in vec3 normal,'+#13#10+
    '                   const in vec3 diffuseColor,'+#13#10+
    '                   const in vec3 specularColor,'+#13#10+
    '                   const in vec3 viewDirection,'+#13#10+
    '                   const in float refractiveAngle,'+#13#10+
    '                   const in float materialTransparency,'+#13#10+
    '                   const in float materialRoughness,'+#13#10+
    '                   const in float materialCavity){'+#13#10+
    '  vec3 halfVector = normalize(viewDirection + lightDirection);'+#13#10+
    '  float nDotL = clamp(dot(normal, lightDirection), 1e-5, 1.0);'+#13#10+
    '  float nDotV = clamp(abs(dot(normal, viewDirection)) + 1e-5, 0.0, 1.0);'+#13#10+
    '  float nDotH = clamp(dot(normal, halfVector), 0.0, 1.0);'+#13#10+
    '  float vDotH = clamp(dot(viewDirection, halfVector), 0.0, 1.0);'+#13#10+
    '  vec3 lit = vec3((materialCavity * nDotL * lightColor) * lightLit);'+#13#10+
    '  diffuseOutput += diffuseFunction(diffuseColor, materialRoughness, nDotV, nDotL, vDotH) * (1.0 - materialTransparency) * lit;'+#13#10+
    '  specularOutput += specularF(specularColor, max(vDotH, refractiveAngle)) *'+#13#10+
    '                    specularD(materialRoughness, nDotH) *'+#13#10+
    '                    specularG(materialRoughness, nDotV, nDotL) *'+#13#10+
    '                    lit;'+#13#10+
    '  if((flags & (1u << 6u)) != 0u){'+#13#10+
    '    float sheenDistribution = sheenDistributionCarlie(sheenRoughness, nDotH);'+#13#10+
    '    float sheenVisibility = visibilityNeubelt(nDotL, nDotV);'+#13#10+
    '    sheenOutput += (sheenColorIntensityFactor.xyz * sheenColorIntensityFactor.w * sheenDistribution * sheenVisibility * PI) * lit;'+#13#10+
    '  }'+#13#10+
    '  if((flags & (1u << 7u)) != 0u){'+#13#10+
    '    float nDotL = clamp(dot(clearcoatNormal, lightDirection), 1e-5, 1.0);'+#13#10+
    '    float nDotV = clamp(abs(dot(clearcoatNormal, viewDirection)) + 1e-5, 0.0, 1.0);'+#13#10+
    '    float nDotH = clamp(dot(clearcoatNormal, halfVector), 0.0, 1.0);'+#13#10+
    '    vec3 lit = vec3((materialCavity * nDotL * lightColor) * lightLit);'+#13#10+
    '    clearcoatOutput += specularF(clearcoatF0, max(vDotH, refractiveAngle)) *'+#13#10+
    '                       specularD(clearcoatRoughness, nDotH) *'+#13#10+
    '                       specularG(clearcoatRoughness, nDotV, nDotL) *'+#13#10+
    '                       lit;'+#13#10+
    '  }'+#13#10+
    '}'+#13#10+
    'vec4 getEnvMap(sampler2D texEnvMap, float texLOD, vec3 rayDirection){'+#13#10+
    '  rayDirection = normalize(rayDirection);'+#13#10+
    '  return textureLod(texEnvMap, (vec2((atan(rayDirection.z, rayDirection.x) / PI2) + 0.5, acos(rayDirection.y) / 3.1415926535897932384626433832795)), texLOD);'+#13#10+
    '}'+#13#10+
    'vec3 getDiffuseImageBasedLight(const in vec3 normal, const in vec3 diffuseColor){'+#13#10+
    '  float ao = cavity * ambientOcclusion;'+#13#10+
    '  return (textureLod(uEnvMapTexture, normal.xyz, float(uEnvMapMaxLevel)).xyz * diffuseColor * ao) * OneOverPI;'+#13#10+
    '}'+#13#10+
    'vec3 getSpecularImageBasedLight(const in vec3 normal, const in vec3 specularColor, const in float roughness, const in vec3 viewDirection, const in float litIntensity){'+#13#10+
    '  vec3 reflectionVector = normalize(reflect(viewDirection, normal.xyz));'+#13#10+
    '  float NdotV = clamp(abs(dot(normal.xyz, viewDirection)) + 1e-5, 0.0, 1.0),'+#13#10+
    '        ao = cavity * ambientOcclusion,'+#13#10+
    '        lit = mix(1.0, litIntensity, max(0.0, dot(reflectionVector, -imageLightBasedLightDirection) * (1.0 - (roughness * roughness)))),'+#13#10+
    '        specularOcclusion = clamp((pow(NdotV + (ao * lit), roughness * roughness) - 1.0) + (ao * lit), 0.0, 1.0);'+#13#10+
    '  vec2 brdf = textureLod(uBRDFLUTTexture, vec2(roughness, NdotV), 0.0).xy;'+#13#10+
    '  return (textureLod(uEnvMapTexture, reflectionVector,'+' clamp((float(uEnvMapMaxLevel) - 1.0) - (1.0 - (1.2 * log2(roughness))), 0.0, float(uEnvMapMaxLevel))).xyz * ((specularColor.xyz * brdf.x) +'+' (brdf.yyy * clamp(max(max(specularColor.x, specularColor.y), specularColor.z) * 50.0, 0.0, 1.0))) * specularOcclusion) * OneOverPI;'+#13#10+
    '}'+#13#10+
    'float computeMSM(in vec4 moments, in float fragmentDepth, in float depthBias, in float momentBias){'+#13#10+
    '  vec4 b = mix(moments, vec4(0.5), momentBias);'+#13#10+
    '  vec3 z;'+#13#10+
    '  z[0] = fragmentDepth - depthBias;'+#13#10+
    '  float L32D22 = fma(-b[0], b[1], b[2]);'+#13#10+
    '  float D22 = fma(-b[0], b[0], b[1]);'+#13#10+
    '  float squaredDepthVariance = fma(-b[1], b[1], b[3]);'+#13#10+
    '  float D33D22 = dot(vec2(squaredDepthVariance, -L32D22), vec2(D22, L32D22));'+#13#10+
    '  float InvD22 = 1.0 / D22;'+#13#10+
    '  float L32 = L32D22 * InvD22;'+#13#10+
    '  vec3 c = vec3(1.0, z[0], z[0] * z[0]);'+#13#10+
    '  c[1] -= b.x;'+#13#10+
    '  c[2] -= b.y + (L32 * c[1]);'+#13#10+
    '  c[1] *= InvD22;'+#13#10+
    '  c[2] *= D22 / D33D22;'+#13#10+
    '  c[1] -= L32 * c[2];'+#13#10+
    '  c[0] -= dot(c.yz, b.xy);'+#13#10+
    '  float InvC2 = 1.0 / c[2];'+#13#10+
    '  float p = c[1] * InvC2;'+#13#10+
    '  float q = c[0] * InvC2;'+#13#10+
    '  float D = (p * p * 0.25) - q;'+#13#10+
    '  float r = sqrt(D);'+#13#10+
    '  z[1] = (p * -0.5) - r;'+#13#10+
    '  z[2] = (p * -0.5) + r;'+#13#10+
    '  vec4 switchVal = (z[2] < z[0]) ? vec4(z[1], z[0], 1.0, 1.0) :'+#13#10+
    '                   ((z[1] < z[0]) ? vec4(z[0], z[1], 0.0, 1.0) :'+#13#10+
    '                   vec4(0.0));'+#13#10+
    '  float quotient = (switchVal[0] * z[2] - b[0] * (switchVal[0] + z[2]) + b[1])/((z[2] - switchVal[1]) * (z[0] - z[1]));'+#13#10+
    '  return clamp((switchVal[2] + (switchVal[3] * quotient)), 0.0, 1.0);'+#13#10+
    '}'+#13#10+
    'vec2 getShadowOffsets(const in vec3 p, const in vec3 N, const in vec3 L){'+#13#10+
    '  float cos_alpha = clamp(dot(N, L), 0.0, 1.0);'+#13#10+
    '  float offset_scale_N = sqrt(1.0 - (cos_alpha * cos_alpha));'+#13#10+ // sin(acos(L?N))
    '  float offset_scale_L = offset_scale_N / cos_alpha;'+#13#10+          // tan(acos(L?N))
    '  return (vec2(offset_scale_N, min(2.0, offset_scale_L)) * vec2(0.0002, 0.00005)) + vec2(0.0, 0.0);'+#13#10+
    '}'+#13#10+
    'float linearStep(float a, float b, float v){'+#13#10+
    '  return clamp((v - a) / (b - a), 0.0, 1.0);'+#13#10+
    '}'+#13#10+
    'float reduceLightBleeding(float pMax, float amount){'+#13#10+
    '  return linearStep(amount, 1.0, pMax);'+#13#10+
    '}'+#13#10+
    'float getMSMShadowIntensity(vec4 moments, float depth, float depthBias, float momentBias){'+#13#10+
    '  vec4 b = mix(moments, vec4(0.5), momentBias);'+#13#10+
    '  float d = depth - depthBias,'+#13#10+
    '        l32d22 = fma(-b.x, b.y, b.z),'+#13#10+
    '        d22 = fma(-b.x, b.x, b.y),'+#13#10+
    '        squaredDepthVariance = fma(-b.y, b.y, b.w),'+#13#10+
    '        d33d22 = dot(vec2(squaredDepthVariance, -l32d22), vec2(d22, l32d22)),'+#13#10+
    '        invD22 = 1.0 / d22,'+#13#10+
    '        l32 = l32d22 * invD22;'+#13#10+
    '  vec3 c = vec3(1.0, d - b.x, d * d);'+#13#10+
    '  c.z -= b.y + (l32 * c.y);'+#13#10+
    '  c.yz *= vec2(invD22, d22 / d33d22);'+#13#10+
    '  c.y -= l32 * c.z;'+#13#10+
    '  c.x -= dot(c.yz, b.xy);'+#13#10+
    '  vec2 pq = c.yx / c.z;'+#13#10+
    '  vec3 z = vec3(d, vec2(-(pq.x * 0.5)) + (vec2(-1.0, 1.0) * sqrt(((pq.x * pq.x) * 0.25) - pq.y)));'+#13#10+
    '  vec4 s = (z.z < z.x)'+#13#10+
    '             ? vec3(z.y, z.x, 1.0).xyzz'+#13#10+
    '                 : ((z.y < z.x)'+#13#10+
    '                     ? vec4(z.x, z.y, 0.0, 1.0)'+#13#10+
    '                     : vec4(0.0));'+#13#10+
    '  return clamp((s.z + (s.w * ((((s.x * z.z) - (b.x * (s.x + z.z))) + b.y) / ((z.z - s.y) * (z.x - z.y))))) * 1.03, 0.0, 1.0);'+#13#10+
    '}'+#13#10+
    'const uint smPBRMetallicRoughness = 0u,'+#13#10+
    '           smPBRSpecularGlossiness = 1u,'+#13#10+
    '           smUnlit = 2u;'+#13#10+
    'uvec2 texCoordIndices = uMaterial.alphaCutOffFlagsTex0Tex1.zw;'+#13#10+
    'vec2 texCoords[2] = vec2[2](vTexCoord0, vTexCoord1);'+#13#10+
    'vec4 textureFetch(const in int textureIndex, const in vec4 defaultValue){'+#13#10+
    '  uint which = (texCoordIndices[textureIndex >> 3] >> ((uint(textureIndex) & 7u) << 2u)) & 0xfu;'+#13#10+
{$if defined(PasGLTFBindlessTextures)}
    '  uvec4 textureHandleContainer = uMaterial.textureHandles[textureIndex >> 1];'+#13#10+
    '  int textureHandleBaseIndex = (textureIndex & 1) << 1;'+#13#10+
    '  uvec2 textureHandleUVec2 = uvec2(textureHandleContainer[textureHandleBaseIndex], textureHandleContainer[textureHandleBaseIndex + 1]);'+#13#10+
    '  return (which < 0x2u) ? texture(sampler2D(textureHandleUVec2), (uMaterial.textureTransforms[textureIndex] * vec3(texCoords[int(which)], 1.0).xyzz).xy) : defaultValue;'+#13#10+
{$elseif defined(PasGLTFIndicatedTextures) and not defined(PasGLTFBindlessTextures)}
    '  return (which < 0x2u) ? texture(uTextures[uMaterial.textureIndices[textureIndex >> 2][textureIndex & 3]], (uMaterial.textureTransforms[textureIndex] * vec3(texCoords[int(which)], 1.0).xyzz).xy) : defaultValue;'+#13#10+
{$else}
    '  return (which < 0x2u) ? texture(uTextures[textureIndex], (uMaterial.textureTransforms[textureIndex] * vec3(texCoords[int(which)], 1.0).xyzz).xy) : defaultValue;'+#13#10+
{$ifend}
    '}'+#13#10+
    'vec4 textureFetchSRGB(const in int textureIndex, const in vec4 defaultValue){'+#13#10+
    '  uint which = (texCoordIndices[textureIndex >> 3] >> ((uint(textureIndex) & 7u) << 2u)) & 0xfu;'+#13#10+
    '  vec4 texel;'+#13#10+
    '  if(which < 0x2u){'+#13#10+
{$if defined(PasGLTFBindlessTextures)}
    '    uvec4 textureHandleContainer = uMaterial.textureHandles[textureIndex >> 1];'+#13#10+
    '    int textureHandleBaseIndex = (textureIndex & 1) << 1;'+#13#10+
    '    uvec2 textureHandleUVec2 = uvec2(textureHandleContainer[textureHandleBaseIndex], textureHandleContainer[textureHandleBaseIndex + 1]);'+#13#10+
    '    texel = texture(sampler2D(textureHandleUVec2), (uMaterial.textureTransforms[textureIndex] * vec3(texCoords[int(which)], 1.0).xyzz).xy);'+#13#10+
{$elseif defined(PasGLTFIndicatedTextures) and not defined(PasGLTFBindlessTextures)}
    '    texel = texture(uTextures[uMaterial.textureIndices[textureIndex >> 2][textureIndex & 3]], (uMaterial.textureTransforms[textureIndex] * vec3(texCoords[int(which)], 1.0).xyzz).xy);'+#13#10+
{$else}
    '    texel = texture(uTextures[textureIndex], (uMaterial.textureTransforms[textureIndex] * vec3(texCoords[int(which)], 1.0).xyzz).xy);'+#13#10+
{$ifend}
    '    texel.xyz = convertSRGBToLinearRGB(texel.xyz);'+#13#10+
    '  }else{'+#13#10+
    '    texel = defaultValue;'+#13#10+
    '  }'+#13#10+
    '  return texel;'+#13#10+
    '}'+#13#10+
    'void main(){'+#13#10+
    '  flags = uMaterial.alphaCutOffFlagsTex0Tex1.y;'+#13#10+
    '  shadingModel = (flags >> 0u) & 0xfu;'+#13#10;
 if aShadowMap then begin
  f:=f+
       '  vec4 t = uFrameGlobals.viewProjectionMatrix * vec4(vWorldSpacePosition, 1.0);'+#13#10+
       '  float d = fma(t.z / t.w, 0.5, 0.5);'+#13#10+
       '  float s = d * d;'+#13#10+
       '  vec4 m = vec4(d, s, s * d, s * s);'+#13#10+
       '  oOutput = m;'+#13#10+
       '  float alpha = textureFetch(0, vec4(1.0)).w * uMaterial.baseColorFactor.w * vColor.w;'+#13#10;
 end else begin
  f:=f+'  vec4 color = vec4(0.0);'+#13#10;
{$ifdef PasGLTFExtraEmissionOutput}
  f:=f+'  vec4 emissionColor = vec4(0.0);'+#13#10;
{$endif}
  f:=f+
     '  float litIntensity = 1.0;'+#13#10+
     '  switch(shadingModel){'+#13#10+
     '    case smPBRMetallicRoughness:'+#13#10+
     '    case smPBRSpecularGlossiness:{'+#13#10+
     '      vec4 diffuseColorAlpha, specularColorRoughness;'+#13#10+
     '      switch(shadingModel){'+#13#10+
     '        case smPBRMetallicRoughness:{'+#13#10+
     '          const vec3 f0 = vec3(0.04);'+#13#10+ // dielectricSpecular
     '          vec4 baseColor = textureFetchSRGB(0, vec4(1.0)) *'+#13#10+
     '                           uMaterial.baseColorFactor;'+#13#10+
     '          vec2 metallicRoughness = clamp(textureFetch(1, vec4(1.0)).zy *'+#13#10+
     '                                         uMaterial.metallicRoughnessNormalScaleOcclusionStrengthFactor.xy,'+#13#10+
     '                                         vec2(0.0, 1e-3),'+#13#10+
     '                                         vec2(1.0));'+#13#10+
     '          diffuseColorAlpha = vec4((baseColor.xyz * (vec3(1.0) - f0) * (1.0 - metallicRoughness.x)) * PI,'+#13#10+
     '                                   baseColor.w);'+#13#10+
     '          specularColorRoughness = vec4(mix(f0, baseColor.xyz, metallicRoughness.x) * PI,'+#13#10+
     '                                        metallicRoughness.y);'+#13#10+
     '          break;'+#13#10+
     '        }'+#13#10+
     '        case smPBRSpecularGlossiness:{'+#13#10+
     '          vec4 specularGlossiness = textureFetchSRGB(1, vec4(1.0)) *'+#13#10+
     '                                    vec4(uMaterial.specularFactor.xyz,'+#13#10+
     '                                         uMaterial.metallicRoughnessNormalScaleOcclusionStrengthFactor.y);'+#13#10+
     '          diffuseColorAlpha = textureFetchSRGB(0, vec4(1.0)) *'+#13#10+
     '                              uMaterial.baseColorFactor *'+#13#10+
     '                              vec2((1.0 - max(max(specularGlossiness.x,'+#13#10+
     '                                                  specularGlossiness.y),'+#13#10+
     '                                              specularGlossiness.z)) * PI,'+#13#10+
     '                                   1.0).xxxy;'+#13#10+
     '          specularColorRoughness = vec4(specularGlossiness.xyz * PI,'+#13#10+
     '                                        clamp(1.0 - specularGlossiness.w, 1e-3, 1.0));'+#13#10+
     '          break;'+#13#10+
     '        }'+#13#10+
     '      }'+#13#10+
     '      vec3 normal;'+#13#10+
     '      if((texCoordIndices.x & 0x00000f00u) != 0x00000f00u){'+#13#10+
     '        vec4 normalTexture = textureFetch(2, vec2(0.0, 1.0).xxyx);'+#13#10+
     '        normal = normalize(mat3(normalize(vTangent), normalize(vBitangent), normalize(vNormal)) * normalize((normalTexture.xyz - vec3(0.5)) * (vec2(uMaterial.metallicRoughnessNormalScaleOcclusionStrengthFactor.z, 1.0).xxy * 2.0)));'+#13#10+
     '      }else{'+#13#10+
     '        normal = normalize(vNormal);'+#13#10+
     '      }'+#13#10+
     '      normal *= (((flags & (1u << 5u)) != 0u) && !gl_FrontFacing) ? -1.0 : 1.0;'+#13#10+
     '      vec4 occlusionTexture = textureFetch(3, vec4(1.0));'+#13#10+
     '      vec4 emissiveTexture = textureFetchSRGB(4, vec4(1.0)); '+#13#10+
     '      cavity = clamp(mix(1.0, occlusionTexture.x, uMaterial.metallicRoughnessNormalScaleOcclusionStrengthFactor.w), 0.0, 1.0);'+#13#10+
     '      transparency = 0.0;'+#13#10+
     '      refractiveAngle = 0.0;'+#13#10+
     '      ambientOcclusion = 1.0;'+#13#10+
     '      shadow = 1.0;'+#13#10+
     '      reflectance = max(max(specularColorRoughness.x, specularColorRoughness.y), specularColorRoughness.z);'+#13#10+
     '      vec3 viewDirection = normalize(vCameraRelativePosition);'+#13#10+
     '      imageLightBasedLightDirection = (lightMetaData.x != 0u) ? lights[0].directionZFar.xyz : vec3(0.0, 0.0, -1.0);'+#13#10+
     '      diffuseOutput = specularOutput = sheenOutput = clearcoatOutput = vec3(0.0);'+#13#10+
     '      if((flags & (1u << 6u)) != 0u){'+#13#10+
     '        sheenColorIntensityFactor = uMaterial.sheenColorFactorSheenIntensityFactor;'+#13#10+
     '        if((texCoordIndices.x & 0x00f00000u) != 0x00f00000u){'+#13#10+
     '          sheenColorIntensityFactor *= textureFetchSRGB(5, vec4(1.0));'+#13#10+
     '        }'+#13#10+
     '        sheenRoughness = max(specularColorRoughness.w, 1e-7);'+#13#10+
     '      }'+#13#10+
     '      if((flags & (1u << 7u)) != 0u){'+#13#10+
     '        clearcoatFactor = uMaterial.clearcoatFactorClearcoatRoughnessFactor.x;'+#13#10+
     '        clearcoatRoughness = uMaterial.clearcoatFactorClearcoatRoughnessFactor.y;'+#13#10+
     '        clearcoatF0 = vec3(0.04);'+#13#10+
     '        if((texCoordIndices.x & 0x0f000000u) != 0x0f000000u){'+#13#10+
     '          clearcoatFactor *= textureFetch(6, vec4(1.0)).x;'+#13#10+
     '        }'+#13#10+
     '        if((texCoordIndices.x & 0xf0000000u) != 0xf0000000u){'+#13#10+
     '          clearcoatRoughness *= textureFetch(7, vec4(1.0)).y;'+#13#10+
     '        }'+#13#10+
     '        if((texCoordIndices.y & 0x0000000fu) != 0x0000000fu){'+#13#10+
     '          vec4 normalTexture = textureFetch(8, vec2(0.0, 1.0).xxyx);'+#13#10+
     '          clearcoatNormal = normalize(mat3(normalize(vTangent), normalize(vBitangent), normalize(vNormal)) * normalize((normalTexture.xyz - vec3(0.5)) * (vec2(uMaterial.metallicRoughnessNormalScaleOcclusionStrengthFactor.z, 1.0).xxy * 2.0)));'+#13#10+
     '        }else{'+#13#10+
     '          clearcoatNormal = normalize(vNormal);'+#13#10+
     '        }'+#13#10+
     '        clearcoatNormal *= (((flags & (1u << 5u)) != 0u) && !gl_FrontFacing) ? -1.0 : 1.0;'+#13#10+
     '        clearcoatRoughness = clamp(clearcoatRoughness, 0.0, 1.0);'+#13#10+
     '      }'+#13#10+
     '      if(lightMetaData.x != 0u){'+#13#10+
     '        for(int lightIndex = 0, lightCount = int(lightMetaData.x); lightIndex < lightCount; lightIndex++){'+#13#10+
     '          Light light = lights[lightIndex];'+#13#10+
     '          float lightAttenuation = 1.0;'+#13#10+
     '          vec3 lightDirection;'+#13#10+
     '          vec3 lightVector = light.positionRange.xyz - vWorldSpacePosition.xyz;'+#13#10+
     '          vec3 normalizedLightVector = normalize(lightVector);'+#13#10+
     '          if((uShadows != 0) && ((light.metaData.y & 0x80000000u) == 0u)){'+#13#10+
     '            switch(light.metaData.x){'+#13#10+
     '              case 1u:'+#13#10+  // Directional
     '              case 3u:{'+#13#10+ // Spot
     '                vec4 shadowNDC = light.shadowMapMatrix * vec4(vWorldSpacePosition, 1.0);'+#13#10+
     '                shadowNDC /= shadowNDC.w;'+#13#10+
     '                if(all(greaterThanEqual(shadowNDC, vec4(-1.0))) && all(lessThanEqual(shadowNDC, vec4(1.0)))){'+#13#10+
     '                  shadowNDC.xyz = fma(shadowNDC.xyz, vec3(0.5), vec3(0.5));'+#13#10+
     '                  vec4 moments = (textureLod(uNormalShadowMapArrayTexture, vec3(shadowNDC.xy, float(int(light.metaData.y))), 0.0) + vec2(-0.035955884801, 0.0).xyyy) *'+#13#10+
     '                                 mat4(0.2227744146, 0.0771972861, 0.7926986636, 0.0319417555,'+#13#10+
     '                                      0.1549679261, 0.1394629426, 0.7963415838, -0.172282317,'+#13#10+
     '                                      0.1451988946, 0.2120202157, 0.7258694464, -0.2758014811,'+#13#10+
     '                                      0.163127443, 0.2591432266, 0.6539092497, -0.3376131734);'+#13#10+
     '                  lightAttenuation *= 1.0 - reduceLightBleeding(getMSMShadowIntensity(moments, shadowNDC.z, 5e-3, 1e-2), 0.0);'+#13#10+
     '                }'+#13#10+
     '                break;'+#13#10+
     '              }'+#13#10+
     '              case 2u:{'+#13#10+ // Point
     '                float znear = 1e-2, zfar = max(1.0, light.directionZFar.w);'+#13#10+
     '                vec3 vector = light.positionRange.xyz - vWorldSpacePosition;'+#13#10+
     '                vec4 moments = (textureLod(uCubeMapShadowMapArrayTexture, vec4(vec3(normalize(vector)), float(int(light.metaData.y))), 0.0) + vec2(-0.035955884801, 0.0).xyyy) *'+#13#10+
     '                               mat4(0.2227744146, 0.0771972861, 0.7926986636, 0.0319417555,'+#13#10+
     '                                    0.1549679261, 0.1394629426, 0.7963415838, -0.172282317,'+#13#10+
     '                                    0.1451988946, 0.2120202157, 0.7258694464, -0.2758014811,'+#13#10+
     '                                    0.163127443, 0.2591432266, 0.6539092497, -0.3376131734);'+#13#10+
     '                lightAttenuation *= 1.0 - reduceLightBleeding(getMSMShadowIntensity(moments, clamp((length(vector) - znear) / (zfar - znear), 0.0, 1.0), 5e-3, 1e-2), 0.0);'+#13#10+
     '                break;'+#13#10+
     '              }'+#13#10+
     '            }'+#13#10+
     '            if(lightIndex == 0){'+#13#10+
     '              litIntensity = lightAttenuation;'+#13#10+
     '            }'+#13#10+
     '          }'+#13#10+
     '          switch(light.metaData.x){'+#13#10+
     '            case 1u:{'+#13#10+  // Directional
     '              lightDirection = -light.directionZFar.xyz;'+#13#10+
     '              break;'+#13#10+
     '            }'+#13#10+
     '            case 2u:{'+#13#10+ // Point
     '              lightDirection = normalizedLightVector;'+#13#10+
     '              break;'+#13#10+
     '            }'+#13#10+
     '            case 3u:{'+#13#10+ // Spot
{$if true}
     '              float angularAttenuation = clamp(fma(dot(normalize(light.directionZFar.xyz), -normalizedLightVector), uintBitsToFloat(light.metaData.z), uintBitsToFloat(light.metaData.w)), 0.0, 1.0);'+#13#10+
{$else}
     // Just for as reference
     '              float innerConeCosinus = uintBitsToFloat(light.metaData.z);'+#13#10+
     '              float outerConeCosinus = uintBitsToFloat(light.metaData.w);'+#13#10+
     '              float actualCosinus = dot(normalize(light.directionZFar.xyz), -normalizedLightVector);'+#13#10+
     '              float angularAttenuation = mix(0.0, mix(smoothstep(outerConeCosinus, innerConeCosinus, actualCosinus), 1.0, step(innerConeCosinus, actualCosinus)), step(outerConeCosinus, actualCosinus));'+#13#10+
{$ifend}
     '              lightAttenuation *= angularAttenuation * angularAttenuation;'+#13#10+
     '              lightDirection = normalizedLightVector;'+#13#10+
     '              break;'+#13#10+
     '            }'+#13#10+
     '            default:{'+#13#10+
     '              continue;'+#13#10+
     '            }'+#13#10+
     '          }'+#13#10+
     '          switch(light.metaData.x){'+#13#10+
     '            case 2u:'+#13#10+  // Point
     '            case 3u:{'+#13#10+ // Spot
     '              if(light.positionRange.w >= 0.0){'+#13#10+
     '                float currentDistance = length(lightVector);'+#13#10+
     '                if(currentDistance > 0.0){'+#13#10+
     '                  lightAttenuation *= 1.0 / (currentDistance * currentDistance);'+#13#10+
     '                  if(light.positionRange.w > 0.0){'+#13#10+
     '                    float distanceByRange = currentDistance / light.positionRange.w;'+#13#10+
     '                    lightAttenuation *= clamp(1.0 - (distanceByRange * distanceByRange * distanceByRange * distanceByRange), 0.0, 1.0);'+#13#10+
     '                  }'+#13#10+
     '                }'+#13#10+
     '              }'+#13#10+
     '              break;'+#13#10+
     '            }'+#13#10+
     '          }'+#13#10+
     '          if(lightAttenuation > 0.0){'+#13#10+
     '            doSingleLight(light.colorIntensity.xyz * light.colorIntensity.w,'+#13#10+
     '                          vec3(lightAttenuation),'+#13#10+
     '                          lightDirection,'+#13#10+
     '                          normal.xyz,'+#13#10+
     '                          diffuseColorAlpha.xyz,'+#13#10+
     '                          specularColorRoughness.xyz,'+#13#10+
     '                          -viewDirection,'+#13#10+
     '                          refractiveAngle,'+#13#10+
     '                          transparency,'+#13#10+
     '                          specularColorRoughness.w,'+#13#10+
     '                          cavity);'+#13#10+
     '          }'+#13#10+
     '        }'+#13#10+
     '      }'+#13#10+
     '      diffuseOutput += getDiffuseImageBasedLight(normal.xyz, diffuseColorAlpha.xyz);'+#13#10+
     '      specularOutput += getSpecularImageBasedLight(normal.xyz, specularColorRoughness.xyz, specularColorRoughness.w, viewDirection, litIntensity);'+#13#10+
     '      if((flags & (1u << 7u)) != 0u){'+#13#10+
     '        clearcoatOutput += getSpecularImageBasedLight(clearcoatNormal.xyz, clearcoatF0.xyz, clearcoatRoughness, viewDirection, litIntensity);'+#13#10+
     '        clearcoatBlendFactor = vec3(clearcoatFactor * specularF(clearcoatF0, clamp(dot(clearcoatNormal, -viewDirection), 0.0, 1.0)));'+#13#10+
     '      }'+#13#10+
     '      color = vec4(vec3(((diffuseOutput +'+#13#10+
{$ifndef PasGLTFExtraEmissionOutput}
     '                          (emissiveTexture.xyz * uMaterial.emissiveFactor.xyz) +'+#13#10+
{$endif}
     '                          (sheenOutput * (1.0 - reflectance))) * '+#13#10+
     '                         (vec3(1.0) - clearcoatBlendFactor)) +'+#13#10+
     '                        mix(specularOutput,'+#13#10+
     '                            clearcoatOutput,'+#13#10+
     '                            clearcoatBlendFactor)),'+#13#10+
     '                   diffuseColorAlpha.w);'+#13#10+
//   '      color = vec4(clearcoatOutput * clearcoatBlendFactor, diffuseColorAlpha.w);'+#13#10+
{$ifdef PasGLTFExtraEmissionOutput}
     '      emissionColor.xyz = vec4((emissiveTexture.xyz * uMaterial.emissiveFactor.xyz) * (vec3(1.0) - clearcoatBlendFactor), 1.0);'+#13#10+
{$endif}
     '      break;'+#13#10+
     '    }'+#13#10+
     '    case smUnlit:{'+#13#10+
     '      color = textureFetchSRGB(0, vec4(1.0)) * uMaterial.baseColorFactor * vec2((litIntensity * 0.25) + 0.75, 1.0).xxxy;'+#13#10+
     '      break;'+#13#10+
     '    }'+#13#10+
     '  }'+#13#10+
     '  float alpha = color.w * vColor.w, outputAlpha = mix(1.0, color.w * vColor.w, float(int(uint((flags >> 4u) & 1u))));'+#13#10+
     '  oOutput = vec4(color.xyz * vColor.xyz, outputAlpha);'+#13#10+
{$ifdef PasGLTFExtraEmissionOutput}
     '  oEmission = vec4(emissionColor.xyz * vColor.xyz, outputAlpha);'+#13#10+
{$endif}
     '';
 end;
 if aAlphaTest then begin
  f:=f+'  if(alpha < uintBitsToFloat(uMaterial.alphaCutOffFlagsTex0Tex1.x)){'+#13#10+
       '    discard;'+#13#10+
       '  }'+#13#10;
 end;
 f:=f+'}'+#13#10;
 inherited Create(v,f);
end;

destructor TShadingShader.Destroy;
begin
 inherited Destroy;
end;

procedure TShadingShader.BindAttributes;
begin
 inherited BindAttributes;
 glBindAttribLocation(ProgramHandle,0,'aPosition');
 glBindAttribLocation(ProgramHandle,1,'aNormal');
 glBindAttribLocation(ProgramHandle,2,'aTangent');
 glBindAttribLocation(ProgramHandle,3,'aTexCoord0');
 glBindAttribLocation(ProgramHandle,4,'aTexCoord1');
 glBindAttribLocation(ProgramHandle,5,'aColor0');
 glBindAttribLocation(ProgramHandle,6,'aJoints0');
 glBindAttribLocation(ProgramHandle,7,'aJoints1');
 glBindAttribLocation(ProgramHandle,8,'aWeights0');
 glBindAttribLocation(ProgramHandle,9,'aWeights1');
 glBindAttribLocation(ProgramHandle,10,'aVertexIndex');
end;

procedure TShadingShader.BindVariables;
{$if not defined(PasGLTFBindlessTextures)}
const Textures:array[0..15] of glInt=(4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
{$ifend}
begin
 inherited BindVariables;
 uBRDFLUTTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uBRDFLUTTexture')));
 uNormalShadowMapArrayTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uNormalShadowMapArrayTexture')));
 uCubeMapShadowMapArrayTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uCubeMapShadowMapArrayTexture')));
 uEnvMapTexture:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uEnvMapTexture')));
{$if not defined(PasGLTFBindlessTextures)}
 uTextures:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uTextures')));
{$ifend}
 uEnvMapMaxLevel:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uEnvMapMaxLevel')));
 uShadows:=glGetUniformLocation(ProgramHandle,pointer(pansichar('uShadows')));
 glUniform1i(uBRDFLUTTexture,0);
 glUniform1i(uEnvMapTexture,1);
 glUniform1i(uNormalShadowMapArrayTexture,2);
 glUniform1i(uCubeMapShadowMapArrayTexture,3);
{$if not defined(PasGLTFBindlessTextures)}
 glUniform1iv(uTextures,16,@Textures[0]);
{$ifend}
end;

end.
