#version 460 core

#pragma shader_stage(fragment)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable
#ifdef WIREFRAME
  #extension GL_EXT_fragment_shader_barycentric : enable
  #define HAVE_PERVERTEX
#endif

#define LIGHTS 
#define SHADOWS

#define LIGHTCLUSTERS
#define FRUSTUMCLUSTERGRID

#include "bufferreference_definitions.glsl"

#if defined(RAYTRACING)

#if defined(WIREFRAME) 
layout(location = 0) pervertexEXT in vec3 inWorldSpacePositionPerVertex[];
#else
layout(location = 0) in vec3 inWorldSpacePosition;
#endif

layout(location = 1) in InBlock {
  vec3 position;
  vec3 normal;
  vec4 tangentSign;
  vec2 texCoord;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
  vec2 jitter;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
} inBlock;

#else

layout(location = 0) in InBlock {
  vec3 position;
  vec3 normal;
  vec4 tangentSign;
  vec2 texCoord;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
  vec2 jitter;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
} inBlock;

#endif

layout(location = 0) out vec4 outFragColor;
#if defined(VELOCITY)
  layout(location = 1) out vec2 outVelocity;
#elif defined(REFLECTIVESHADOWMAPOUTPUT)
  layout(location = 1) out vec4 outFragNormalUsed; // xyz = normal, w = 1.0 if normal was used, 0.0 otherwise (by clearing the normal buffer to vec4(0.0))
#endif

#define inViewSpacePosition inBlock.viewSpacePosition
#define inWorldSpacePosition inBlock.worldSpacePosition
#define inCameraRelativePosition inBlock.cameraRelativePosition

// Global descriptor set

#define PLANETS
#ifdef RAYTRACING
  #define USE_MATERIAL_BUFFER_REFERENCE // needed for raytracing
#endif
#include "globaldescriptorset.glsl"
#undef PLANETS

// Pass descriptor set

#include "mesh_rendering_pass_descriptorset.glsl"
  
layout(set = 1, binding = 6, std430) readonly buffer ImageBasedSphericalHarmonicsMetaData {
  vec4 dominantLightDirection;
  vec4 dominantLightColor;
  vec4 ambientLightColor;
} imageBasedSphericalHarmonicsMetaData;

#ifdef FRUSTUMCLUSTERGRID
layout (set = 1, binding = 8, std140) readonly uniform FrustumClusterGridGlobals {
  uvec4 tileSizeZNearZFar; 
  vec4 viewRect;
  uvec4 countLightsViewIndexSizeOffsetedViewIndex;
  uvec4 clusterSize;
  vec4 scaleBiasMax;
} uFrustumClusterGridGlobals;

layout (set = 1, binding = 9, std430) readonly buffer FrustumClusterGridIndexList {
   uint frustumClusterGridIndexList[];
};

layout (set = 1, binding = 10, std430) readonly buffer FrustumClusterGridData {
  uvec4 frustumClusterGridData[]; // x = start light index, y = count lights, z = start decal index, w = count decals
};
#endif

// Per planet descriptor set

layout(set = 2, binding = 0) uniform sampler2D uPlanetTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map
layout(set = 2, binding = 0) uniform sampler2DArray uPlanetArrayTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map

#include "planet_textures.glsl"

#define RainTexture uPlanetTextures[PLANET_TEXTURE_RAINTEXTURE]
#define RainNormalTexture uPlanetTextures[PLANET_TEXTURE_RAINNORMALTEXTURE]
#define RainStreaksNormalTexture uPlanetTextures[PLANET_TEXTURE_RAINSTREAKSNORMALTEXTURE]

#include "planet_wetness.glsl"
#include "planet_grass.glsl"

#define FRAGMENT_SHADER

#include "math.glsl"

#include "srgb.glsl"

#ifdef RAYTRACING
  #include "raytracing.glsl"
#endif

#include "octahedral.glsl"
#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 

#define LIGHTING_GLOBALS
#include "lighting.glsl"
#undef LIGHTING_GLOBALS

#define UseEnvMap
#define UseEnvMapGGX
#undef UseEnvMapCharlie
#undef UseEnvMapLambertian

#include "roughness.glsl"

vec3 imageLightBasedLightDirection = imageBasedSphericalHarmonicsMetaData.dominantLightDirection.xyz;

vec3 viewDirection = normalize(-inBlock.cameraRelativePosition);

#ifdef WIREFRAME 
float edgeFactor(){
  const float sqrt0d5Mul0d5 = 0.3535533905932738; // sqrt(0.5) * 0.5 - Half of the length of the diagonal of a square with a side length of 1.0
  const vec3 edge = gl_BaryCoordEXT, 
             edgeDX = dFdxFine(edge), 
             edgeDY = dFdyFine(edge), 
             edgeDXY = sqrt((edgeDX * edgeDX) + (edgeDY * edgeDY)),
             edgeRemapped = smoothstep(vec3(0.0), edgeDXY * sqrt0d5Mul0d5, fma(edgeDXY, vec3(-sqrt0d5Mul0d5), edge));
  return 1.0 - min(min(edgeRemapped.x, edgeRemapped.y), edgeRemapped.z);
}   
#endif

vec3 workNormal;

#define NOTEXCOORDS
#define inFrameIndex pushConstants.frameIndex
#include "shadows.glsl"

const vec3 inModelScale = vec3(1.0); 

#undef ENABLE_ANISOTROPIC
#include "pbr.glsl"
#include "pbr_wetness.glsl"
#include "blendnormals.glsl"

void main(){

  float sideSign = gl_FrontFacing ? 1.0 : -1.0;

  vec4 wetness = getWetness(inBlock.worldSpacePosition);

  // After vertex interpolation, the normal vector may not be normalized anymore, so it needs to be normalized. 
  vec3 normalizedNormal = normalize(inBlock.normal);

  // After vertex interpolation, the tangent vector may not be orthogonal to the normal vector anymore, so it needs to be orthonormalized in
  // a quick&dirty but often good enough way.
  vec3 orthonormalizedTangent = normalize(inBlock.tangentSign.xyz - (normalizedNormal * dot(normalizedNormal, inBlock.tangentSign.xyz)));

  vec3 workTangent = orthonormalizedTangent * sideSign;
  vec3 workBitangent = cross(normalizedNormal, orthonormalizedTangent) * inBlock.tangentSign.w * sideSign;
  vec3 workNormal = normalizedNormal * sideSign;

//workNormal = normalize(cross(dFdyFine(inBlock.cameraRelativePosition), dFdxFine(inBlock.cameraRelativePosition))); // * sideSign;
/*vec3 workTangent = normalize(cross((abs(workNormal.y) < 0.999999) ? vec3(0.0, 1.0, 0.0) : vec3(0.0, 0.0, 1.0), workNormal));
  vec3 workBitangent = normalize(cross(workNormal, workTangent));*/

#ifdef RAYTRACING 
  // The geometric normal is needed for raytracing ray offseting
#ifdef WIREFRAME
  vec3 triangleNormal = normalize(
                          cross(
                            inWorldSpacePositionPerVertex[1] - inWorldSpacePositionPerVertex[0], 
                            inWorldSpacePositionPerVertex[2] - inWorldSpacePositionPerVertex[0]
                          )
                        ) * sideSign;
#else
  vec3 triangleNormal = normalize(cross(dFdyFine(inBlock.cameraRelativePosition), dFdxFine(inBlock.cameraRelativePosition))) * sideSign;
#endif
#endif

  const vec3 baseColorSRGB = vec3(58.0, 105.0, 23.0); // vec3(74.0, 149.0, 0.0); 
  const vec3 baseColorLinearRGB = convertSRGBToLinearRGB(baseColorSRGB * 0.00392156862745098);

  const float fakeSelfShadowing = clamp(inBlock.texCoord.y, 0.1, 1.0); 

  vec4 albedo = vec4(baseColorLinearRGB * fakeSelfShadowing, 1.0);  
//vec3 baseColor = albedo.xyz;
  vec4 occlusionRoughnessMetallic = vec4(1.0, 0.3, 0.0, 0.0);

/*const vec3 baseColorSRGB = vec3(52.0, 106.0, 0.0); // vec3(74.0, 149.0, 0.0); 
  const vec3 baseColorLinearRGB = convertSRGBToLinearRGB(baseColorSRGB * 0.00392156862745098);

  const float fakeSelfShadowing = clamp(inBlock.texCoord.y, 0.1, 1.0); 

  vec4 albedo = vec4(baseColorLinearRGB, 1.0);  
  vec3 baseColor = albedo.xyz;
  vec4 occlusionRoughnessMetallic = vec4(fakeSelfShadowing, 0.25, 0.0, 0.0);*/

  vec4 wetnessNormal = vec4(0.0);
  const float rainTime = float(uint(pushConstants.timeSeconds & 4095u)) + pushConstants.timeFractionalSecond;         
  applyPBRWetness(
    wetness,
    inWorldSpacePosition,
    mat3(workTangent, workBitangent, workNormal),
    albedo.xyz,
    wetnessNormal,
    occlusionRoughnessMetallic.z, // metallic
    occlusionRoughnessMetallic.y, // roughness 
    occlusionRoughnessMetallic.x, // occlusion
    RainTexture,
    RainNormalTexture,
    RainStreaksNormalTexture,
    rainTime,
    1.0,
    true // Extended effect, which includes the rain streaks and puddles
  );

  // The blade normal is rotated slightly to the left or right depending on the x texture coordinate for
  // to fake roundness of the blade without real more complex geometry
  vec3 bladeRelativeNormal = normalize(vec3(0.0, sin(vec2(radians(mix(-60.0, 60.0, inBlock.texCoord.x))) + vec2(0.0, 1.5707963267948966))));
  vec3 normal = normalize(mat3(workTangent, workBitangent, workNormal) * blendNormals(bladeRelativeNormal.xyz, wetnessNormal.xyz, wetnessNormal.w));

  float NdotV;
  normal = getViewClampedNormal(normal, viewDirection, NdotV);
  NdotV = clamp(NdotV, 0.0, 1.0);

  vec3 baseColor = albedo.xyz;

  float occlusion = clamp(occlusionRoughnessMetallic.x, 0.0, 1.0);
    
  vec2 metallicRoughness = clamp(occlusionRoughnessMetallic.zy, vec2(0.0, 1e-3), vec2(1.0));

  float metallic = metallicRoughness.x;

  vec4 diffuseColorAlpha = vec4(max(vec3(0.0), albedo.xyz * (1.0 - metallicRoughness.x)), albedo.w);

  //vec3 F0Dielectric = mix(vec3(0.04), albedo.xyz, metallicRoughness.x);
  vec3 F0Dielectric = vec3(0.04);

  vec3 F90 = vec3(1.0);
  vec3 F90Dielectric = vec3(1.0);

  float transparency = 0.0;

  float refractiveAngle = 0.0;

  float perceptualRoughness = metallicRoughness.y;

  float kernelRoughness;
  {
    const float SIGMA2 = 0.15915494, KAPPA = 0.18;        
    vec3 dx = dFdx(workNormal), dy = dFdy(workNormal);
    kernelRoughness = min(KAPPA, (2.0 * SIGMA2) * (dot(dx, dx) + dot(dy, dy)));
    perceptualRoughness = sqrt(clamp((perceptualRoughness * perceptualRoughness) + kernelRoughness, 0.0, 1.0));
  }  

  float alphaRoughness = perceptualRoughness * perceptualRoughness;

  diffuseOcclusion = occlusion * ambientOcclusion;
  specularOcclusion = getSpecularOcclusion(clamp(dot(normal, viewDirection), 0.0, 1.0), diffuseOcclusion, alphaRoughness);

  // Horizon specular occlusion
  {
    vec3 reflectedVector = reflect(-viewDirection, normal);
    float horizon = min(1.0 + dot(reflectedVector, normal), 1.0);
    specularOcclusion *= horizon * horizon;         
  }

  const vec3 sheenColor = vec3(0.0);
  const float sheenRoughness = 0.0;

  const vec3 clearcoatF0 = vec3(0.04);
  const vec3 clearcoatF90 = vec3(0.0);
  vec3 clearcoatNormal = normal;
  const float clearcoatFactor = 1.0;
  const float clearcoatRoughness = 1.0;

  float litIntensity = 1.0;

  const float specularWeight = 1.0;

  const float iblWeight = 1.0;

#define LIGHTING_INITIALIZATION
#include "lighting.glsl"
#undef LIGHTING_INITIALIZATION

  const bool receiveShadows = true; 
  
#define LIGHTING_IMPLEMENTATION
#include "lighting.glsl"
#undef LIGHTING_IMPLEMENTATION

  vec3 iblDiffuse = getIBLDiffuse(normal) * baseColor.xyz;
  vec3 iblSpecularMetal = getIBLRadianceGGX(normal, viewDirection, perceptualRoughness);
  vec3 iblSpecularDielectric = iblSpecularMetal;
  vec3 iblMetalFresnel = getIBLGGXFresnel(normal, viewDirection, perceptualRoughness, baseColor.xyz, 1.0);
  vec3 iblMetalBRDF = iblMetalFresnel * iblSpecularMetal;
  vec3 iblDielectricFresnel = getIBLGGXFresnel(normal, viewDirection, perceptualRoughness, F0Dielectric, specularWeight);
  vec3 iblDielectricBRDF = mix(iblDiffuse * diffuseOcclusion, iblSpecularDielectric * specularOcclusion, iblDielectricFresnel);
  vec3 iblResultColor = mix(iblDielectricBRDF, iblMetalBRDF * specularOcclusion, metallic); // Dielectric/metallic mix
  colorOutput += iblResultColor;
      
  //vec3(0.015625) * edgeFactor() * fma(clamp(dot(normal, vec3(0.0, 1.0, 0.0)), 0.0, 1.0), 1.0, 0.0), 1.0);
  vec4 c = vec4(colorOutput, 1.0);
  
#ifdef WIREFRAME
/*if((planetData.flagsResolutions.x & (1u << 0u)) != 0){
    c.xyz = mix(c.xyz, mix(vec3(1.0) - clamp(c.zxy, vec3(1.0), vec3(1.0)), vec3(0.0, 1.0, 1.0), 0.5), edgeFactor());
  }*/
#endif  

#if defined(SHADOWS) && 0
  {
    vec4 d = shadowCascadeVisualizationColor();
    c = mix(c, d, d.w * 0.25);
  } 
#endif
   
  outFragColor = vec4(clamp(c.xyz, vec3(-65504.0), vec3(65504.0)), c.w);

#if defined(VELOCITY)
  outVelocity = (inBlock.currentClipSpace.xy / inBlock.currentClipSpace.w) - (inBlock.previousClipSpace.xy / inBlock.previousClipSpace.w);
#elif defined(REFLECTIVESHADOWMAPOUTPUT)
  outFragNormalUsed = vec4(vec3(fma(normalize(workNormal), vec3(0.5), vec3(0.5))), 1.0);  
#endif

}