#version 460 core

#define MESH_FRAGMENT_SHADER

#define CAN_HAVE_EXTENDED_PBR_MATERIAL

#if defined(VOXELIZATION)
  #undef LIGHTS
  #undef SHADOWS
#endif

#define LIGHTCLUSTERS
#define FRUSTUMCLUSTERGRID

#ifdef USE_MATERIAL_BUFFER_REFERENCE
#elif defined(USE_MATERIAL_SSBO)
#endif 

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#if defined(USEDEMOTE)
  #extension GL_EXT_demote_to_helper_invocation : enable
#endif
#extension GL_EXT_nonuniform_qualifier : enable
#if defined(USESHADERBUFFERFLOAT32ATOMICADD)
  #extension GL_EXT_shader_atomic_float : enable
#endif
#ifdef WETNESS
  #extension GL_EXT_samplerless_texture_functions : enable
#endif

/*#if defined(RAYTRACING)
  #extension GL_EXT_fragment_shader_barycentric : enable
  #define HAVE_PERVERTEX
#endif*/

#extension GL_EXT_control_flow_attributes : enable

#include "bufferreference_definitions.glsl"

#if defined(LOCKOIT) || defined(DFAOIT)
  #extension GL_ARB_post_depth_coverage : enable
  #ifdef INTERLOCK
    #extension GL_ARB_fragment_shader_interlock : enable
    #define beginInvocationInterlock beginInvocationInterlockARB
    #define endInvocationInterlock endInvocationInterlockARB
    #ifdef MSAA
      #if defined(DFAOIT)
        layout(early_fragment_tests, post_depth_coverage, sample_interlock_ordered) in;
      #else
        layout(early_fragment_tests, post_depth_coverage, pixel_interlock_ordered) in;
      #endif
    #else
      layout(early_fragment_tests, post_depth_coverage, pixel_interlock_ordered) in;
    #endif
  #else
    #if defined(ALPHATEST)
      layout(post_depth_coverage) in;
    #else
      layout(early_fragment_tests, post_depth_coverage) in;
    #endif
  #endif
#elif !defined(ALPHATEST)
  layout(early_fragment_tests) in;
#endif

#ifdef VOXELIZATION
#ifdef HAVE_PERVERTEX
layout(location = 0) pervertexEXT in vec3 inWorldSpacePositionPerVertex[];
#else
layout(location = 0) in vec3 inWorldSpacePosition;
#endif
layout(location = 1) in vec3 inViewSpacePosition;
layout(location = 2) in vec3 inCameraRelativePosition;
layout(location = 3) in vec4 inTangentSign;
layout(location = 4) in vec3 inNormal;
layout(location = 5) in vec2 inTexCoord0;
layout(location = 6) in vec2 inTexCoord1;
layout(location = 7) in vec4 inColor0;
layout(location = 8) in vec3 inModelScale;
layout(location = 9) flat in uint inMaterialID;
layout(location = 10) flat in uint inInstanceDataIndex;
layout(location = 11) flat in vec3 inAABBMin;
layout(location = 12) flat in vec3 inAABBMax;
layout(location = 13) flat in uint inCascadeIndex; 
layout(location = 14) in vec3 inVoxelPosition; 
layout(location = 15) flat in vec3 inVertex0;
layout(location = 16) flat in vec3 inVertex1;
layout(location = 17) flat in vec3 inVertex2;
#else
#ifdef HAVE_PERVERTEX
layout(location = 0) pervertexEXT in vec3 inWorldSpacePositionPerVertex[];
#else
layout(location = 0) in vec3 inWorldSpacePosition;
#endif
layout(location = 1) in vec3 inViewSpacePosition;
layout(location = 2) in vec3 inCameraRelativePosition;
layout(location = 3) in vec4 inTangentSign;
layout(location = 4) in vec3 inNormal;
layout(location = 5) in vec2 inTexCoord0;
layout(location = 6) in vec2 inTexCoord1;
layout(location = 7) in vec4 inColor0;
layout(location = 8) in vec3 inModelScale;
layout(location = 9) flat in uint inMaterialID;
layout(location = 10) flat in uint inInstanceDataIndex;
layout(location = 11) flat in int inViewIndex;
layout(location = 12) flat in uint inFrameIndex;

#ifdef VELOCITY
layout(location = 13) flat in vec4 inJitter;
layout(location = 14) in vec4 inPreviousClipSpace;
layout(location = 15) in vec4 inCurrentClipSpace;
#else
layout(location = 13) flat in vec2 inJitter;
#endif // VELOCITY

#endif // VOXELIZATION

#ifdef HAVE_PERVERTEX

// inWorldSpacePosition do need to be calculated in this case, since it is passed as a per-vertex attribute without interpolation.
vec3 inWorldSpacePosition = (inWorldSpacePositionPerVertex[0] * gl_BaryCoordEXT.x) + (inWorldSpacePositionPerVertex[1] * gl_BaryCoordEXT.y) + (inWorldSpacePositionPerVertex[2] * gl_BaryCoordEXT.z);

// Calculate the geometric normal from the per-vertex positions with consideration of the front facing flag for double-sided triangles 
vec3 inGeometricNormal = normalize(
                           cross(
                             inWorldSpacePositionPerVertex[1] - inWorldSpacePositionPerVertex[0], 
                             inWorldSpacePositionPerVertex[2] - inWorldSpacePositionPerVertex[0]
                           )
                         ) * (gl_FrontFacing ? 1.0 : -1.0);
#endif

#ifdef VOXELIZATION
  // Nothing in this case, since the fragment shader writes to the voxel grid directly.
#elif defined(DEPTHONLY)
#else
  #if defined(VELOCITY) && !(defined(MBOIT) && defined(MBOITPASS1))
    layout(location = 1) out vec2 outFragVelocity;
  #elif defined(EXTRAEMISSIONOUTPUT) && !(defined(WBOIT) || defined(MBOIT))
    layout(location = 1) out vec4 outFragEmission;
  #elif defined(REFLECTIVESHADOWMAPOUTPUT)
    layout(location = 1) out vec4 outFragNormalUsed; // xyz = normal, w = 1.0 if normal was used, 0.0 otherwise (by clearing the normal buffer to vec4(0.0))
    //layout(location = 2) out vec3 outFragPosition; // Can be reconstructed from depth and inversed model view projection matrix 
  #endif
#endif

// Specialization constants are sadly unusable due to dead slow shader stage compilation times with several minutes "per" pipeline, 
// when the validation layers and a debugger (GDB, LLDB, etc.) are active at the same time!
#undef USE_SPECIALIZATION_CONSTANTS
#ifdef USE_SPECIALIZATION_CONSTANTS
layout (constant_id = 0) const bool UseReversedZ = true;
#endif

const int TEXTURE_BRDF_GGX = 0;
const int TEXTURE_BRDF_CHARLIE = 1;
const int TEXTURE_BRDF_SHEEN_E = 2;
const int TEXTURE_ENVMAP_GGX = 3;
const int TEXTURE_ENVMAP_CHARLIE = 4;
const int TEXTURE_ENVMAP_LAMBERTIAN = 5;

const int TEXTURE_BASE_INDEX = 10;

// Push constants

#include "mesh_pushconstants.glsl" 

// Global descriptor set

#define MESHS
#include "globaldescriptorset.glsl"
#undef MESHS

// Pass descriptor set

#include "mesh_rendering_pass_descriptorset.glsl"

#ifdef FRUSTUMCLUSTERGRID
layout (set = 1, binding = 6, std140) readonly uniform FrustumClusterGridGlobals {
  uvec4 tileSizeZNearZFar; 
  vec4 viewRect;
  uvec4 countLightsViewIndexSizeOffsetedViewIndex;
  uvec4 clusterSize;
  vec4 scaleBiasMax;
} uFrustumClusterGridGlobals;

layout (set = 1, binding = 7, std430) readonly buffer FrustumClusterGridIndexList {
   uint frustumClusterGridIndexList[];
};

layout (set = 1, binding = 8, std430) readonly buffer FrustumClusterGridData {
  uvec4 frustumClusterGridData[]; // x = start light index, y = count lights, z = start decal index, w = count decals
};

#endif

#ifdef WETNESS
#ifdef MSAA
layout(set = 1, binding = 9) uniform utexture2DMSArray uWetnessMap;
#else
layout(set = 1, binding = 9) uniform utexture2DArray uWetnessMap;
#endif

layout(set = 1, binding = 10) uniform sampler2D uRainTextures[]; // 0 = rain texture, 1 = rain normal texture, 2 = rain streaks normal texture 

#define RainTexture uRainTextures[0]
#define RainNormalTexture uRainTextures[1]
#define RainStreaksNormalTexture uRainTextures[2]

#endif

#ifdef VOXELIZATION
  layout(location = 0) out vec4 outFragColor;
  #include "voxelization_globals.glsl"
#endif

// Extra global illumination descriptor set (optional, if global illumination is enabled) for more easily sharing the same 
// global illumination data between multiple passes (e.g. opaque and transparent passes).

#if defined(GLOBAL_ILLUMINATION_CASCADED_RADIANCE_HINTS)

  #define GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET 2
  #define GLOBAL_ILLUMINATION_VOLUME_UNIFORM_BINDING 0
  layout(set = GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET, binding = 1) uniform sampler3D uTexGlobalIlluminationCascadedRadianceHintsSHVolumes[];
  #define GLOBAL_ILLUMINATION_VOLUME_MESH_FRAGMENT
  #include "global_illumination_cascaded_radiance_hints.glsl"

#elif defined(GLOBAL_ILLUMINATION_CASCADED_VOXEL_CONE_TRACING) 

  layout (set = 2, binding = 0, std140) readonly uniform VoxelGridData {
    #include "voxelgriddata_uniforms.glsl"
  } voxelGridData;

  layout(set = 2, binding = 1) uniform sampler3D uVoxelGridOcclusion[];

  layout(set = 2, binding = 2) uniform sampler3D uVoxelGridRadiance[];

  #include "global_illumination_voxel_cone_tracing.glsl"

#endif

#ifndef VOXELIZATION
  #define TRANSPARENCY_DECLARATION
  #include "transparency.glsl"
  #undef TRANSPARENCY_DECLARATION
#endif

/* clang-format on */

vec3 workTangent, workBitangent, workNormal;

#include "math.glsl" 

#define TRANSPARENCY_GLOBALS
#include "transparency.glsl"
#undef TRANSPARENCY_GLOBALS

#ifdef VOXELIZATION
vec3 cartesianToBarycentric(vec3 p, vec3 a, vec3 b, vec3 c) {
  vec3 v0 = b - a, v1 = c - a, v2 = p - a;
  float d00 = dot(v0, v0), d01 = dot(v0, v1), d11 = dot(v1, v1), d20 = dot(v2, v0), d21 = dot(v2, v1);
  vec2 vw = vec2((d11 * d20) - (d01 * d21), (d00 * d21) - (d01 * d20)) / vec2((d00 * d11) - (d01 * d01));
  return vec3((1.0 - vw.x) - vw.y, vw.xy);
}
#endif

#ifdef RAYTRACING
  #include "raytracing.glsl"
#endif

#if !(defined(DEPTHONLY) || defined(VOXELIZATION))

#include "roughness.glsl"

#define UseEnvMap
#define UseEnvMapGGX
#define UseEnvMapCharlie
#define UseEnvMapLambertian

uint flags, shadingModel;

#if defined(BLEND) || defined(LOOPOIT) || defined(LOCKOIT) || defined(MBOIT) || defined(WBOIT) || defined(DFAOIT)
  #define TRANSMISSION
#endif

#if defined(TRANSMISSION)
float transmissionFactor = 0.0;
float volumeDispersion = 0.0;
#endif

float volumeThickness = 0.0;
float volumeAttenuationDistance = 1.0 / 0.0; // +INF
vec3 volumeAttenuationColor = vec3(1.0); 

float diffuseTransmissionFactor = 0.0;
vec3 diffuseTransmissionColorFactor = vec3(1.0);
float diffuseTransmissionThickness = 1.0; 

#include "blendnormals.glsl"

#define ENABLE_ANISOTROPIC
#include "pbr.glsl"
   
/////////////////////////////

#include "shadows.glsl"

#define LIGHTING_GLOBALS
#include "lighting.glsl"
#undef LIGHTING_GLOBALS

#endif // !defined(DEPTHONLY) || defined(VOXELIZATION) 

#if defined(USE_MATERIAL_BUFFER_REFERENCE)
  #ifdef USE_INT64
    Material material = uMaterials.materials[inMaterialID];
  #else
    Material material;
  #endif
#else
  #define material materials[inMaterialID]
//Material material = materials[inMaterialID];
#endif

const uint smPBRMetallicRoughness = 0u,  //
    smPBRSpecularGlossiness = 1u,        //
    smUnlit = 2u;                        //

#if defined(ALPHATEST) || defined(LOOPOIT) || defined(LOCKOIT) || defined(WBOIT) || defined(MBOIT) || defined(DFAOIT) || !defined(DEPTHONLY)

uvec2 textureFlags;
vec2 texCoords[2];
vec2 texCoords_dFdx[2];
vec2 texCoords_dFdy[2];

int getTexCoordID(const in int textureIndex){
  return material.textures[textureIndex]; 
}

vec2 textureUV(const in int textureIndex) {
  int textureID = getTexCoordID(textureIndex); 
  return (textureID >= 0) ? (material.textureTransforms[textureIndex] * vec3(texCoords[(textureID >> 16) & 0xf], 1.0)).xy : inTexCoord0;
}

ivec2 texture2DSize(const in int textureIndex) {
  int textureID = getTexCoordID(textureIndex); 
  return (textureID >= 0) ? ivec2(textureSize(u2DTextures[nonuniformEXT(textureID & 0x3fff) << 1], 0).xy) : ivec2(0);
}

vec4 textureFetch(const in int textureIndex, const in vec4 defaultValue, const bool sRGB) {
  int textureID = getTexCoordID(textureIndex);
  if(textureID >= 0){
    int texCoordIndex = int((textureID >> 16) & 0xf); 
    mat3x2 m = material.textureTransforms[textureIndex];
    return textureGrad(u2DTextures[nonuniformEXT(((textureID & 0x3fff) << 1) | (int(sRGB) & 1))], //
                        (m * vec3(texCoords[texCoordIndex], 1.0)).xy,   //
                        (m * vec3(texCoords_dFdx[texCoordIndex], 0.0)).xy,  //
                        (m * vec3(texCoords_dFdy[texCoordIndex], 0.0)).xy);
  }else{
    return defaultValue;
  } 
}

#endif

#if defined(VOXELIZATION)
  #include "rgb9e5.glsl"
#endif

float hologramNoiseFunction(float x, const in uint s){
  x *= float(s);
  uint i = uint(floor(x));
  float f = fract(x);
  f = f * f * (3.0 - (f * 2.0));
  uvec2 y = uvec2(i, (i + 1u) & (s - 1u));
  y ^= y >> uvec2(17u);
  y *= uvec2(0xed5ad4bbu);
  y ^= y >> uvec2(11u);
  y *= uvec2(0xac4c1b51u);
  y ^= y >> uvec2(15u);
  y *= uvec2(0x31848babu);
  y ^= y >> uvec2(14u);
  vec2 v = vec2(intBitsToFloat(ivec2(((y >> uvec2(9u)) & uvec2(0x007fffffu)) | uvec2(0x3f800000u))) - vec2(1.0));
  return mix(v.x, v.y, f);
}

float hologramNoise(float x){
  return smoothstep(0.0, 0.25, hologramNoiseFunction(x, 4096u));
}

#include "instancedataeffect.glsl"

#ifdef WETNESS
#include "octahedral.glsl"

vec4 getWetness(){ // x = wetness, yzw = normal to planet ground
#ifdef MSAA
  const uvec4 rawValues = texelFetch(uWetnessMap, ivec3(gl_FragCoord.xy, gl_ViewIndex), gl_SampleID);
#else
  const uvec4 rawValues = texelFetch(uWetnessMap, ivec3(gl_FragCoord.xy, gl_ViewIndex), 0);
#endif
  if(rawValues.x > 0u){
    // Unpack 12.12 bit from YZW 24 bit value, since it is encoded as an octahedral equal area unsigned normal vector.
    const uint value24bit = ((rawValues.y & 0xffu) << 0u) | ((rawValues.z & 0xffu) << 8u) | ((rawValues.w & 0xffu) << 16u);
    const uvec2 unpackedUInt = uvec2(value24bit & 0xfffu, value24bit >> 12u);
    const vec2 unpackedFloat = vec2(unpackedUInt) / 4095.0;
    return vec4(float(rawValues.x) / 255.0, octEqualAreaUnsignedDecode(unpackedFloat));
  }else{
    return vec4(0.0); // No wetness
  }
}  

#include "pbr_wetness.glsl"

#endif // WETNESS

void main() {
#ifdef VOXELIZATION
  if(any(lessThan(inWorldSpacePosition.xyz, inAABBMin.xyz)) || 
     any(greaterThan(inWorldSpacePosition.xyz, inAABBMax.xyz)) ||
     (uint(inCascadeIndex) >= uint(voxelGridData.countCascades))){
    outFragColor = vec4(0.0);
    return;
  }
#endif
  {
    // For double sided triangles in the back-facing case, the normal, tangent and bitangent vectors need to be flipped.
    float frontFacingSign = gl_FrontFacing ? 1.0 : -1.0;   

    // After vertex interpolation, the normal vector may not be normalized anymore, so it needs to be normalized. 
    vec3 normalizedNormal = normalize(inNormal); 

    // After vertex interpolation, the tangent vector may not be orthogonal to the normal vector anymore, so it needs to be orthonormalized in 
    // a quick&dirty but often good enough way.
    vec3 orthonormalizedTangent = normalize(inTangentSign.xyz - (normalizedNormal * dot(normalizedNormal, inTangentSign.xyz))); 

    workTangent = orthonormalizedTangent * frontFacingSign;
    workBitangent = cross(normalizedNormal, orthonormalizedTangent) * inTangentSign.w * frontFacingSign;
    workNormal = normalizedNormal * frontFacingSign;

  }
#ifdef RAYTRACING
  // The geometric normal is needed for raytracing ray offseting 
#if defined(HAVE_PERVERTEX)
  vec3 triangleNormal = inGeometricNormal;
#else 
  vec3 triangleNormal = normalize(cross(dFdyFine(inCameraRelativePosition), dFdxFine(inCameraRelativePosition)));
#endif // HAVE_PERVERTEX
#endif // RAYTRACING
#if defined(USE_MATERIAL_BUFFER_REFERENCE) && !defined(USE_INT64)
  material = uMaterials.materials;
  {
    uvec2 materialPointer = uvec2(material);  
    uint carry;
    materialPointer.x = uaddCarry(materialPointer.x, uint(inMaterialID * uint(sizeof(Material))), carry);
    materialPointer.y += carry;
    material = Material(materialPointer);
  }
#endif
#if defined(ALPHATEST) || defined(LOOPOIT) || defined(LOCKOIT) || defined(WBOIT) || defined(MBOIT) || defined(DFAOIT) || defined(VOXELIZATION) || !defined(DEPTHONLY)
  textureFlags = material.alphaCutOffFlagsTex0Tex1.zw;
  texCoords[0] = inTexCoord0;
  texCoords[1] = inTexCoord1;
  texCoords_dFdx[0] = dFdxFine(inTexCoord0);
  texCoords_dFdx[1] = dFdxFine(inTexCoord1);
  texCoords_dFdy[0] = dFdyFine(inTexCoord0);
  texCoords_dFdy[1] = dFdyFine(inTexCoord1);
#if !defined(VOXELIZATION)  
  /*if(!any(notEqual(inJitter.xy, vec2(0.0))))*/{
    texCoords[0] -= (texCoords_dFdx[0] * inJitter.x) + (texCoords_dFdy[0] * inJitter.y);
    texCoords[1] -= (texCoords_dFdx[1] * inJitter.x) + (texCoords_dFdy[1] * inJitter.y);
  }  
#endif
#endif
#if !(defined(DEPTHONLY) || defined(VOXELIZATION))
  flags = material.alphaCutOffFlagsTex0Tex1.y;
  shadingModel = (flags >> 0u) & 0xfu;
#endif
#if defined(VOXELIZATION)
  
  uint flags = material.alphaCutOffFlagsTex0Tex1.y;
  
  // For meta voxelization, a very simple BRDF is used, so the data can be reused for various purposes at the later stages, so that
  // new costly voxelization passes are not required to be performed for these cases. Hence also the name meta voxelization, as the
  // voxelization is just performed for to gather meta data, which is then used for various purposes.

  vec4 baseColor = textureFetch(0, vec4(1.0), true) * material.baseColorFactor * inColor0; 
  
  vec4 emissionColor = vec4(textureFetch(4, vec4(1.0), true).xyz * material.emissiveFactor.xyz * material.emissiveFactor.w * inColor0.xyz, baseColor.w);
  
  float alpha = ((flags & (1u << 31u)) != 0u) ? 1.0 : baseColor.w;
  
  vec3 normal;
  if ((textureFlags.x & (1 << 2)) != 0) {
    vec4 normalTexture = textureFetch(2, vec2(0.0, 1.0).xxyx, false);
    normal = normalize(                                                                                                                      //
        mat3(normalize(workTangent), normalize(workBitangent), normalize(workNormal)) *                                                            //
        normalize((normalTexture.xyz - vec3(0.5)) * (vec2(material.metallicRoughnessNormalScaleOcclusionStrengthFactor.z, 1.0).xxy * 2.0))  //
    );
  } else {
    normal = normalize(workNormal);
  }
  //normal *= (((flags & (1u << 6u)) != 0u) && !gl_FrontFacing) ? -1.0 : 1.0;

#elif defined(DEPTHONLY)
#if defined(ALPHATEST) || defined(LOOPOIT) || defined(LOCKOIT) || defined(WBOIT) || defined(MBOIT) || defined(DFAOIT)
  uint flags = material.alphaCutOffFlagsTex0Tex1.y;
  float alpha = ((flags & (1u << 31u)) != 0u) ? 1.0 : (textureFetch(0, vec4(1.0), true).w * material.baseColorFactor.w * inColor0.w);
  if((inInstanceDataIndex > 0u) && ((flags & (1u << 31u)) != 0u)){
    vec4 dummyColor = vec4(1.0);
    if(!applyInstanceDataEffect(uint(inInstanceDataIndex), dummyColor, vec2(texCoords[0]), uvec2(gl_FragCoord.xy), false)){
      alpha = 0.0;
    }
  }
#endif
#else
  
  vec4 color = vec4(0.0);
#ifdef EXTRAEMISSIONOUTPUT
  vec4 emissionColor = vec4(0.0);
#endif
#if 0
   // Just for debugging purposes
   color = textureFetch(0, vec4(1.0), true) * material.baseColorFactor;
#else
  float litIntensity = 1.0;
  switch (shadingModel) {
    case smPBRMetallicRoughness:
    case smPBRSpecularGlossiness: {
      vec4 baseColor = vec4(1.0);
      float metallic;
      float ior = material.iorIridescenceFactorIridescenceIorIridescenceThicknessMinimum.x;
      vec3 F0Dielectric = vec3((abs(ior - 1.5) < 1e-6) ? 0.04 : pow((ior - 1.0) / (ior + 1.0), 2.0));
      vec3 F90 = vec3(1.0);
      vec3 F90Dielectric = vec3(1.0);
      float perceptualRoughness = 1.0;
      float specularWeight = 1.0;
      switch (shadingModel) {
        case smPBRMetallicRoughness: {
          vec2 metallicRoughness = clamp(textureFetch(1, vec4(1.0), false).zy * material.metallicRoughnessNormalScaleOcclusionStrengthFactor.xy, vec2(0.0, 1e-3), vec2(1.0));
          metallic = metallicRoughness.x;
          perceptualRoughness = metallicRoughness.y;
          baseColor = textureFetch(0, vec4(1.0), true) * material.baseColorFactor;
          if((inInstanceDataIndex > 0u) && ((flags & (1u << 25u)) != 0u)){
            applyMaterialInstanceDataEffect(uint(inInstanceDataIndex), baseColor, vec2(texCoords[0]), uvec2(gl_FragCoord.xy), false);
          }
          vec3 specularColorFactor = material.specularFactor.xyz;
          specularWeight = material.specularFactor.w;
          if ((flags & (1u << 9u)) != 0u) {
            specularWeight *= textureFetch(10, vec4(1.0), false).w;
            specularColorFactor *= textureFetch(11, vec4(1.0), true).xyz;
          }
          F0Dielectric = min(F0Dielectric * specularColorFactor, vec3(1.0));
          F90Dielectric = vec3(specularWeight);
          break;
        }
        case smPBRSpecularGlossiness: {
          metallic = 0.0;
          ior = 0.0;
          vec4 specularGlossiness = textureFetch(1, vec4(1.0), true) * vec4(material.specularFactor.xyz, material.metallicRoughnessNormalScaleOcclusionStrengthFactor.y);
          baseColor = textureFetch(0, vec4(1.0), true) * material.baseColorFactor;
          if((inInstanceDataIndex > 0u) && ((flags & (1u << 25u)) != 0u)){
            applyMaterialInstanceDataEffect(uint(inInstanceDataIndex), baseColor, vec2(texCoords[0]), uvec2(gl_FragCoord.xy), false);
          }         
          perceptualRoughness = clamp(1.0 - specularGlossiness.w, 1e-3, 1.0);
          F0Dielectric = min(specularGlossiness.xyz * material.specularFactor.xyz, vec3(1.0));
          break;
        }
      }

      vec4 occlusionTexture = textureFetch(3, vec4(1.0), false);

      float occlusion = clamp(mix(1.0, occlusionTexture.x, material.metallicRoughnessNormalScaleOcclusionStrengthFactor.w), 0.0, 1.0);

#ifdef WETNESS
      vec4 wetnessNormal = vec4(0.0); 
      if((flags & (1u << 27u)) == 0u){
        const vec4 wetness = getWetness();  
        const float rainTime = float(uint(pushConstants.timeSecondsTimeFractionalSecondWidthHeight.x & 4095u)) + uintBitsToFloat(pushConstants.timeSecondsTimeFractionalSecondWidthHeight.y); 
        applyPBRWetness(
          wetness,
          inWorldSpacePosition,
          mat3(workTangent, workBitangent, workNormal),
          baseColor.xyz,       // base color
          wetnessNormal,
          metallic,            // metallic
          perceptualRoughness, // roughness 
          occlusion,           // occlusion
          RainTexture,
          RainNormalTexture,
          RainStreaksNormalTexture,
          rainTime,
          1.0,
          (flags & (1u << 26u)) != 0u // Extended effects
        );
      }
#endif

      vec3 normal;
      if (((textureFlags.x & (1 << 2)) != 0) 
#ifdef WETNESS
          || (wetnessNormal.w > 0.0)
#endif
         ) {
#ifdef WETNESS 
        const vec4 normalTexture = ((textureFlags.x & (1 << 2)) != 0) ? textureFetch(2, vec2(0.0, 1.0).xxyx, false) : vec4(0.5, 0.5, 1.0, 0.0);
#else
        const vec4 normalTexture = textureFetch(2, vec2(0.0, 1.0).xxyx, false);
#endif
        const vec3 normalToApply = normalize((normalTexture.xyz - vec3(0.5)) * (vec2(material.metallicRoughnessNormalScaleOcclusionStrengthFactor.z, 1.0).xxy * 2.0));
        normal = normalize(                                                                                                                      //
            mat3(normalize(workTangent), normalize(workBitangent), normalize(workNormal)) *      
#ifdef WETNESS
            blendNormals(normalToApply, wetnessNormal.xyz, wetnessNormal.w)
#else
            normalToApply
#endif
        );
      } else {
        normal = normalize(workNormal);
      }

      // The normal vector is flipped for back-facing triangles, so that the lighting is correct.
      //normal *= (((flags & (1u << 6u)) != 0u) && !gl_FrontFacing) ? -1.0 : 1.0;

      vec3 viewDirection = normalize(-inCameraRelativePosition);

      float NdotV;
      normal = getViewClampedNormal(normal, viewDirection, NdotV);
      NdotV = clamp(NdotV, 0.0, 1.0);

#undef UseGeometryRoughness
#ifdef UseGeometryRoughness

      const float minimumRoughness = 0.0525;
      float geometryRoughness;
      {
        vec3 dxy = max(abs(dFdx(workNormal)), abs(dFdy(workNormal)));
        geometryRoughness = max(max(dxy.x, dxy.y), dxy.z);
      }

      perceptualRoughness = min(max(perceptualRoughness, minimumRoughness) + geometryRoughness, 1.0);

#else 

      // Vlachos 2015, "Advanced VR Rendering"
      // Kaplanyan 2016, "Stable specular highlights"
      // Tokuyoshi 2017, "Error Reduction and Simplification for Shading Anti-Aliasing"
      // Tokuyoshi and Kaplanyan 2019, "Improved Geometric Specular Antialiasing"
      // Tokuyoshi and Kaplanyan 2021, "Stable Geometric Specular Antialiasing with Projected-Space NDF Filtering"
      // ===========================================================================================================
      // In the original paper, this implementation is intended for deferred rendering, but here it is also used 
      // for forward rendering (as described in Tokuyoshi and Kaplanyan 2019 and 2021). This is mainly because 
      // the forward version requires an expensive transformation of the half-vector by the tangent frame for each
      // light. Thus, this is an approximation based on world-space normals, but it works well enough for what is 
      // needed and is an clearly improvement over the implementation based on Vlachos 2015.
      float kernelRoughness;
      {
        const float SIGMA2 = 0.15915494, KAPPA = 0.18;       
        vec3 dx = dFdx(workNormal), dy = dFdy(workNormal);
        kernelRoughness = min(KAPPA, (2.0 * SIGMA2) * (dot(dx, dx) + dot(dy, dy)));
      }

      perceptualRoughness = sqrt(clamp((perceptualRoughness * perceptualRoughness) + kernelRoughness, 0.0, 1.0));

#endif

      float alphaRoughness = perceptualRoughness * perceptualRoughness;

      vec4 emissiveTexture = textureFetch(4, vec4(1.0), true);

      float transparency = 0.0;
      float refractiveAngle = 0.0;
      float shadow = 1.0;
  #if defined(ALPHATEST) || defined(LOOPOIT) || defined(LOCKOIT) || defined(WBOIT) || defined(MBOIT) || defined(DFAOIT) || defined(BLEND) || defined(ENVMAP)
      ambientOcclusion = 1.0;
  #else      
      ivec2 ambientOcclusionTextureSize = ivec2(textureSize(uPassTextures[0], 0).xy);
  #if defined(GLOBAL_ILLUMINATION_CASCADED_RADIANCE_HINTS) || defined(GLOBAL_ILLUMINATION_CASCADED_VOXEL_CONE_TRACING)
      ambientOcclusion = texelFetch(uPassTextures[0], ivec3(min(ivec2(gl_FragCoord.xy), ambientOcclusionTextureSize - ivec2(1)), int(gl_ViewIndex)), 0).x;
  #else
      ambientOcclusion = ((textureFlags.x & (1 << 3)) != 0) ? 1.0 : texelFetch(uPassTextures[0], ivec3(min(ivec2(gl_FragCoord.xy), ambientOcclusionTextureSize - ivec2(1)), int(gl_ViewIndex)), 0).x;
  #endif
  #endif

      diffuseOcclusion = occlusion * ambientOcclusion;
      specularOcclusion = getSpecularOcclusion(clamp(dot(normal, viewDirection), 0.0, 1.0), diffuseOcclusion, alphaRoughness);

      // Horizon specular occlusion
      {
        vec3 reflectedVector = reflect(-viewDirection, normal);
        float horizon = min(1.0 + dot(reflectedVector, normal), 1.0);
        specularOcclusion *= horizon * horizon;         
      }

      if ((flags & (1u << 10u)) != 0u) {
        iridescenceFactor = material.iorIridescenceFactorIridescenceIorIridescenceThicknessMinimum.y * (((textureFlags.x & (1 << 12)) != 0) ? textureFetch(12, vec4(1.0), false).x : 1.0);
        iridescenceIor = material.iorIridescenceFactorIridescenceIorIridescenceThicknessMinimum.z;
        if ((textureFlags.x & (1 << 12)) != 0){
          iridescenceThickness = mix(material.iorIridescenceFactorIridescenceIorIridescenceThicknessMinimum.w, material.iridescenceThicknessMaximumTransmissionFactorVolumeThicknessFactorVolumeAttenuationDistance.x, textureFetch(13, vec4(1.0), false).y);  
        }else{
          iridescenceThickness = material.iridescenceThicknessMaximumTransmissionFactorVolumeThicknessFactorVolumeAttenuationDistance.x;  
        }
        if(iridescenceThickness == 0.0){
          iridescenceFactor = 0.0;
        }  
        //if(iridescenceFactor > 0.0)
        {
//        float NdotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
          iridescenceFresnelDielectric = evalIridescence(1.0, iridescenceIor, NdotV, iridescenceThickness, F0Dielectric);
          iridescenceFresnelMetallic = evalIridescence(1.0, iridescenceIor, NdotV, iridescenceThickness, baseColor.xyz);
        }
      }

      // Transmission, diffuse transmission and volume 
      if ((flags & ((1u << 11u) | (1u << 16u))) != 0u) {

#if defined(TRANSMISSION)
        // Transmission
        if ((flags & (1u << 11u)) != 0u) {
          transmissionFactor = material.iridescenceThicknessMaximumTransmissionFactorVolumeThicknessFactorVolumeAttenuationDistance.y * (((textureFlags.x & (1 << 14)) != 0) ? textureFetch(14, vec4(1.0), false).x : 1.0);  
          if((flags & (1u << 14u)) != 0u){
            volumeDispersion = uintBitsToFloat(material.dispersionShadowCastMaskShadowReceiveMaskUnused.x);
          }
        }
#endif 

        // Volume
        if ((flags & (1u << 12u)) != 0u) {
          volumeThickness = material.iridescenceThicknessMaximumTransmissionFactorVolumeThicknessFactorVolumeAttenuationDistance.z * (((textureFlags.x & (1 << 15)) != 0) ? textureFetch(15, vec4(1.0), false).y : 1.0);  
          volumeAttenuationDistance = material.iridescenceThicknessMaximumTransmissionFactorVolumeThicknessFactorVolumeAttenuationDistance.w;        
          volumeAttenuationColor = uintBitsToFloat(material.volumeAttenuationColorAnisotropyStrengthAnisotropyRotation.xyz);        
        }

        // Diffuse transmission
        if ((flags & (1u << 16u)) != 0u) {
          diffuseTransmissionFactor = material.diffuseTransmissionColorFactor.w * (((textureFlags.x & (1 << 17)) != 0) ? textureFetch(17, vec4(1.0), false).x : 1.0); 
          diffuseTransmissionColorFactor = material.diffuseTransmissionColorFactor.xyz * (((textureFlags.x & (1 << 18)) != 0) ? textureFetch(18, vec4(1.0), true).xyz : vec3(1.0));
          diffuseTransmissionThickness = volumeThickness * dot(inModelScale.xyz, vec3(0.3333333333)); 
        }

      }  

      vec3 imageLightBasedLightDirection = vec3(0.0, 0.0, -1.0);

      vec3 sheenColor = vec3(0.0);
      float sheenRoughness = 0.0;
      if ((flags & (1u << 7u)) != 0u) {
        sheenColor = material.sheenColorFactorSheenRoughnessFactor.xyz;
        sheenRoughness = material.sheenColorFactorSheenRoughnessFactor.w;
        if ((textureFlags.x & (1 << 5)) != 0) {
          sheenColor *= textureFetch(5, vec4(1.0), true).xyz;
        }
        if ((textureFlags.x & (1 << 6)) != 0) {
          sheenRoughness *= textureFetch(6, vec4(1.0), true).x;
        }
#undef UseGeometryRoughness
#ifdef UseGeometryRoughness
        sheenRoughness = min(max(sheenRoughness, minimumRoughness) + geometryRoughness, 1.0);
#else        
        sheenRoughness = sqrt(clamp((sheenRoughness * sheenRoughness) + kernelRoughness, 0.0, 1.0));
#endif
        sheenRoughness = max(sheenRoughness, 1e-7);
      }

      vec3 clearcoatF0 = vec3(0.04);
      vec3 clearcoatF90 = vec3(0.0);
      vec3 clearcoatNormal = normal;
      float clearcoatFactor = 1.0;
      float clearcoatRoughness = 1.0;
      if ((flags & (1u << 8u)) != 0u) {
        clearcoatFactor = material.clearcoatFactorClearcoatRoughnessFactor.x;
        clearcoatRoughness = material.clearcoatFactorClearcoatRoughnessFactor.y;
        if ((textureFlags.x & (1 << 7)) != 0) {
          clearcoatFactor *= textureFetch(7, vec4(1.0), false).x;
        }
        if ((textureFlags.x & (1 << 8)) != 0) {
          clearcoatRoughness *= textureFetch(8, vec4(1.0), false).y;
        }
        if ((textureFlags.x & (1 << 9)) != 0) {
          vec4 normalTexture = textureFetch(9, vec2(0.0, 1.0).xxyx, false);
          clearcoatNormal = normalize(mat3(normalize(workTangent), normalize(workBitangent), normalize(workNormal)) * normalize((normalTexture.xyz - vec3(0.5)) * (vec2(material.metallicRoughnessNormalScaleOcclusionStrengthFactor.z, 1.0).xxy * 2.0)));
        } else {
          clearcoatNormal = normalize(workNormal);
        }
        //clearcoatNormal *= (((flags & (1u << 6u)) != 0u) && !gl_FrontFacing) ? -1.0 : 1.0;
#ifdef UseGeometryRoughness        
        clearcoatRoughness = min(max(clearcoatRoughness, minimumRoughness) + geometryRoughness, 1.0);
#else
        clearcoatRoughness = sqrt(clamp((clearcoatRoughness * clearcoatRoughness) + kernelRoughness, 0.0, 1.0));
#endif
      }

#ifdef ENABLE_ANISOTROPIC
      if (anisotropyActive = ((flags & (1u << 13u)) != 0u)) {
        vec2 ansitropicStrengthAnsitropicRotation = unpackHalf2x16(material.volumeAttenuationColorAnisotropyStrengthAnisotropyRotation.w);        
        vec2 directionRotation = vec2(sin(vec2(ansitropicStrengthAnsitropicRotation.y) + vec2(1.5707963267948966, 0.0)));
        mat2 rotationMatrix = mat2(directionRotation.x, directionRotation.y, -directionRotation.y, directionRotation.x);
        vec3 anisotropySample = textureFetch(16, vec4(1.0, 0.5, 1.0, 1.0), false).xyz;
        vec2 direction = rotationMatrix * fma(anisotropySample.xy, vec2(2.0), vec2(-1.0));
        anisotropyT = mat3(workTangent, workBitangent, normal) * normalize(vec3(direction, 0.0));
        anisotropyB = cross(workNormal, anisotropyT);
        anisotropyStrength = clamp(ansitropicStrengthAnsitropicRotation.x * anisotropySample.z, 0.0, 1.0);
        alphaRoughnessAnisotropyT = mix(alphaRoughness, 1.0, anisotropyStrength * anisotropyStrength);
        alphaRoughnessAnisotropyB = clamp(alphaRoughness, 1e-3, 1.0);
        anisotropyTdotV = dot(anisotropyT, viewDirection);
        anisotropyBdotV = dot(anisotropyB, viewDirection);   
      }
#endif

      if ((flags & (1u << 8u)) != 0u) {
        clearcoatFresnel = F_Schlick(clearcoatF0, clearcoatF90, clamp(dot(clearcoatNormal, viewDirection), 0.0, 1.0));
      }

#define LIGHTING_INITIALIZATION
#include "lighting.glsl"
#undef LIGHTING_INITIALIZATION

      const bool receiveShadows = (flags & (1u << 30u)) != 0u; 

#define LIGHTING_IMPLEMENTATION
#include "lighting.glsl"
#undef LIGHTING_IMPLEMENTATION

#if defined(GLOBAL_ILLUMINATION_CASCADED_RADIANCE_HINTS)
      {
        vec3 volumeSphericalHarmonics[9];
        globalIlluminationVolumeLookUp(volumeSphericalHarmonics, inWorldSpacePosition.xyz, vec3(0.0), normal.xyz);
#if 0
        vec3 shResidualDiffuse = max(vec3(0.0), globalIlluminationDecodeColor(globalIlluminationCompressedSphericalHarmonicsDecodeWithCosineLobe(normal, volumeSphericalHarmonics)));
        colorOutput += shResidualDiffuse * baseColor.xyz * diffuseOcclusion;
#else
        vec3 shAmbient = vec3(0.0), shDominantDirectionalLightColor = vec3(0.0), shDominantDirectionalLightDirection = vec3(0.0);
        globalIlluminationSphericalHarmonicsExtractAndSubtract(volumeSphericalHarmonics, shAmbient, shDominantDirectionalLightColor, shDominantDirectionalLightDirection);
        vec3 shResidualDiffuse = max(vec3(0.0), globalIlluminationDecodeColor(globalIlluminationCompressedSphericalHarmonicsDecodeWithCosineLobe(normal, volumeSphericalHarmonics)));
        colorOutput += shResidualDiffuse * baseColor.xyz * diffuseOcclusion;
        doSingleLight(shDominantDirectionalLightColor,                    //
                      vec3(specularOcclusion),                            //
                      -shDominantDirectionalLightDirection,               //
                      normal.xyz,                                         //
                      baseColor.xyz,                                      //
                      F0Dielectric,                                       //
                      F90,                                                //
                      F90Dielectric,                                      //
                      viewDirection,                                      //
                      refractiveAngle,                                    //
                      transparency,                                       //
                      alphaRoughness,                                     //
                      metallic,                                           //
                      sheenColor,                                         //
                      sheenRoughness,                                     //
                      clearcoatNormal,                                    //
                      clearcoatFresnel,                                   //
                      clearcoatFactor,                                    //
                      clearcoatRoughness,                                 //
                      specularWeight,                                     // 
                      vec3(0.0),                                        //
                      0.0);                                   
#endif
      }
#elif defined(GLOBAL_ILLUMINATION_CASCADED_VOXEL_CONE_TRACING)
      float iblWeight = 1.0; 
      {
        if(dot(baseColor.xyz, vec3(1.0)) > 1e-6){
          vec4 c = cvctIndirectDiffuseLight(inWorldSpacePosition.xyz, normal.xyz);
          colorOutput += c.xyz * baseColor.xyz * diffuseOcclusion * OneOverPI;
          iblWeight = clamp(1.0 - c.w, 0.0, 1.0);
        }
        if(dot(F0Dielectric, vec3(1.0)) > 1e-6){
          colorOutput += cvctIndirectSpecularLight(inWorldSpacePosition.xyz, normal.xyz, viewDirection, cvctRoughnessToVoxelConeTracingApertureAngle(perceptualRoughness), 1e+24) * F0Dielectric * specularOcclusion * OneOverPI;
        }
      }
#endif
#if !defined(REFLECTIVESHADOWMAPOUTPUT) 
#if !(defined(GLOBAL_ILLUMINATION_CASCADED_RADIANCE_HINTS))
#if defined(GLOBAL_ILLUMINATION_CASCADED_VOXEL_CONE_TRACING)
//    float iblWeight = 1.0; 
#else
      float iblWeight = 1.0; // for future sky occulsion 
#endif
      vec3 iblDiffuse = getIBLDiffuse(normal) * baseColor.xyz; 

      // Diffuse transmission
      if ((flags & (1u << 16u)) != 0u) {
        vec3 iblDiffuseTransmission = getIBLDiffuse(-normal) * diffuseTransmissionColorFactor;
        if((flags & (1u << 12u)) != 0u){
          iblDiffuseTransmission = applyVolumeAttenuation(iblDiffuseTransmission, diffuseTransmissionThickness, volumeAttenuationColor, volumeAttenuationDistance);
        }
        iblDiffuse = mix(iblDiffuse, iblDiffuseTransmission,  diffuseTransmissionFactor);
      }

#if defined(TRANSMISSION)

      // Transmission
      if ((flags & (1u << 11u)) != 0u) {
        vec3 iblSpecularTransmission = getIBLVolumeRefraction(normal.xyz, 
                                                              viewDirection,
                                                              perceptualRoughness,
                                                              baseColor.xyz, 
                                                              inWorldSpacePosition,
                                                              ior, 
                                                              volumeThickness, 
                                                              volumeAttenuationColor, 
                                                              volumeAttenuationDistance,
                                                              volumeDispersion);        
        iblDiffuse = mix(iblDiffuse, iblSpecularTransmission, transmissionFactor);                                               
      }
#endif
      vec3 iblSpecularMetal = getIBLRadianceGGX(normal, viewDirection, perceptualRoughness);
      vec3 iblSpecularDielectric = iblSpecularMetal;
      vec3 iblMetalFresnel = getIBLGGXFresnel(normal, viewDirection, perceptualRoughness, baseColor.xyz, 1.0);
      vec3 iblMetalBRDF = iblMetalFresnel * iblSpecularMetal;
      vec3 iblDielectricFresnel = getIBLGGXFresnel(normal, viewDirection, perceptualRoughness, F0Dielectric, specularWeight);
      vec3 iblDielectricBRDF = mix(iblDiffuse * diffuseOcclusion, iblSpecularDielectric * specularOcclusion, iblDielectricFresnel);
      if ((flags & (1u << 10u)) != 0u) {
        iblMetalBRDF = mix(iblMetalBRDF, iblSpecularMetal * iridescenceFresnelMetallic, iridescenceFactor);
        iblDielectricBRDF = mix(iblDielectricBRDF, rgbMix(iblDiffuse * diffuseOcclusion, iblSpecularDielectric * specularOcclusion, iridescenceFresnelDielectric), iridescenceFactor);
      }
      vec3 iblSheen = vec3(0.0);
      float iblAlbedoSheenScaling = 1.0; 
      if ((flags & (1u << 7u)) != 0u) {
        iblSheen = getIBLRadianceCharlie(normal, viewDirection, sheenRoughness, sheenColor) * diffuseOcclusion;
//      float NdotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
        iblAlbedoSheenScaling = 1.0 - (max(max(sheenColor.x, sheenColor.y), sheenColor.z) * albedoSheenScalingLUT(NdotV, sheenRoughness));
      }
      vec3 iblClearcoatBRDF = ((flags & (1u << 8u)) != 0u) ? (getIBLRadianceGGX(clearcoatNormal, viewDirection, clearcoatRoughness) * diffuseOcclusion) : vec3(0.0);
      vec3 iblResultColor = mix(iblDielectricBRDF, iblMetalBRDF * specularOcclusion, metallic); // Dielectric/metallic mix
      iblResultColor = fma(iblResultColor, vec3(iblAlbedoSheenScaling), iblSheen); // Sheen modulation
      iblResultColor = mix(iblResultColor, iblClearcoatBRDF, clearcoatFactor * clearcoatFresnel); // Clearcoat modulation
      colorOutput += iblResultColor; // Add to the color output
#endif
#endif
#if defined(REFLECTIVESHADOWMAPOUTPUT)
      vec3 emissiveOutput = vec3(0.0); // No emissive output for RSMs
#else
      vec3 emissiveOutput = emissiveTexture.xyz * material.emissiveFactor.xyz * material.emissiveFactor.w;
#endif
      color = vec4(colorOutput.xyz, baseColor.w);
#ifndef EXTRAEMISSIONOUTPUT
      color.xyz += emissiveOutput * (1.0 - (clearcoatFactor * clearcoatFresnel));
#endif
/*
#if defined(TRANSMISSION)
      color.xyz += mix(diffuseOutput, transmissionOutput, transmissionFactor);
#else
      color.xyz += diffuseOutput;
#endif
*/
#if defined(GLOBAL_ILLUMINATION_CASCADED_RADIANCE_HINTS)
#if 0
      color.xyz += globalIlluminationCascadeVisualizationColor(inWorldSpacePosition).xyz;
#endif
#elif defined(GLOBAL_ILLUMINATION_CASCADED_VOXEL_CONE_TRACING)
#if 0
      color.xyz += cvctCascadeVisualizationColor(inWorldSpacePosition).xyz;
#endif
#endif
/*    color.xyz += specularOutput;
      color.xyz = fma(color.xyz, vec3(albedoSheenScaling), sheenOutput);
      color.xyz = fma(color.xyz, vec3(1.0 - (clearcoatFactor * clearcoatFresnel)), clearcoatOutput);*/
#ifdef EXTRAEMISSIONOUTPUT
//      emissionColor.xyz = emissiveOutput * (1.0 - (clearcoatFactor * clearcoatFresnel));
#endif
      break;
    }
    case smUnlit: {
      color = textureFetch(0, vec4(1.0), true) * material.baseColorFactor;
      if((inInstanceDataIndex > 0u) && ((flags & (1u << 25u)) != 0u)){
        applyMaterialInstanceDataEffect(uint(inInstanceDataIndex), color, vec2(texCoords[0]), uvec2(gl_FragCoord.xy), false);
      }      
      color *= vec2((litIntensity * 0.25) + 0.75, 1.0).xxxy;
      break;
    }
  }
#ifndef VOXELIZATION
  {
    if((flags & (1u << 15u)) != 0u){
      
      // Holographic effect

      // Decode the hologram data from half floats to floats
      const vec4 decodedFloats0 = vec4(unpackHalf2x16(material.hologramBlock0.x), unpackHalf2x16(material.hologramBlock0.y));
      const vec4 decodedFloats1 = vec4(unpackHalf2x16(material.hologramBlock0.z), unpackHalf2x16(material.hologramBlock0.w));
      const vec4 decodedFloats2 = vec4(unpackHalf2x16(material.hologramBlock1.x), unpackHalf2x16(material.hologramBlock1.y));
      const vec4 decodedFloats3 = vec4(unpackHalf2x16(material.hologramBlock1.z), unpackHalf2x16(material.hologramBlock1.w));
      const vec4 decodedFloats4 = vec4(unpackHalf2x16(material.hologramBlock2.x), unpackHalf2x16(material.hologramBlock2.y));
      const vec4 decodedFloats5 = vec4(unpackHalf2x16(material.hologramBlock2.z), unpackHalf2x16(material.hologramBlock2.w));

      // Get the view
      const View view = uView.views[inViewIndex];

      // Calculate the vertex direction
      float vertexDirection;
      vec3 hologramDirection = vec3(decodedFloats0.xy, decodedFloats0.z);
      float hologramDirectionLength = dot(hologramDirection, hologramDirection); 
      if(hologramDirectionLength >= 4.0){
        if(hologramDirection.z >= -(1e-6)){ 
          // When the hologram direction is equal or larger than 2.0 unit length, it is assumed that it is a screen space based hologram (as a distinguishing criterion)
          // Not using gl_FragCoord.y here, because it is only a rounded integer value but not the correct floating point value, therefore using the view projection 
          // matrix to calculate the correct vertex direction. Indeed, the vertex shader could deliever also the clip space position, but this would require to
          // pass the clip space position to the fragment shader, which is not done here, because the clip space position is not needed for other purposes otherwise,
          // so it is calculated here in the fragment shader instead, only for the hologram effect, if enabled. Given that it's not used in excessive amounts.   
          vec4 clipSpace = (view.projectionMatrix * view.viewMatrix) * vec4(inWorldSpacePosition, 1.0);
          vertexDirection = fma(clipSpace.y / clipSpace.w, -0.5 * sign(hologramDirection.y), 0.5); // The sign of the y component of the hologram direction is used to determine the direction of the hologram effect
        }else{
          vertexDirection = float(gl_FragCoord.y) / float(pushConstants.timeSecondsTimeFractionalSecondWidthHeight.w); // The y component of the hologram direction is used to determine the direction of the hologram effect
        }
      }else{
        if(hologramDirectionLength < 1e-6){
          // When the hologram direction is zero or nearly zero, it is assumed that it is a view direction based hologram (as a distinguishing criterion) (it's similar to the screen space based hologram, but a bit different anyway) 
          hologramDirection = normalize(view.inverseViewMatrix[1].xyz); // Up vector of the view matrix as hologram direction 
        }else{ 
          // When the hologram direction is not zero and smaller than 2.0 unit length, it is assumed that it is a world space based hologram
          hologramDirection = normalize(hologramDirection.xyz);
        }
        // Assign the vertex direction based on the hologram direction
        vertexDirection = fma(dot(inWorldSpacePosition.xyz, hologramDirection), 0.5, 0.5);
      }

      // Assign the decoded values to the hologram parameters
      const float hologramFlickerSpeed = decodedFloats0.w;
      const float hologramFlickerMin = decodedFloats1.x;
      const float hologramFlickerMax = decodedFloats1.y;
      const vec4 hologramMainColorFactor = vec4(decodedFloats1.zw, decodedFloats2.xy);
      const vec4 hologramRimColorFactor = vec4(decodedFloats2.zw, decodedFloats3.xy);
      const float hologramRimPower = decodedFloats3.z;
      const float hologramRimThreshold = decodedFloats3.w;
      const float hologramScanTiling = (decodedFloats4.x < 0.0) ? (float(pushConstants.timeSecondsTimeFractionalSecondWidthHeight.w) * (-decodedFloats4.x)) : decodedFloats4.x;
      const float hologramScanSpeed = decodedFloats4.y;
      const float hologramScanMin = decodedFloats4.z;
      const float hologramScanMax = decodedFloats4.w;
      const float hologramGlowTiling = (decodedFloats5.x < 0.0) ? (float(pushConstants.timeSecondsTimeFractionalSecondWidthHeight.w) * (-decodedFloats5.x)) : decodedFloats5.x;
      const float hologramGlowSpeed = decodedFloats5.y;
      const float hologramGlowMin = decodedFloats5.z;
      const float hologramGlowMax = decodedFloats5.w;

      // Get the hologram time 
      const float hologramTime = float(uint(pushConstants.timeSecondsTimeFractionalSecondWidthHeight.x & 4095u)) + uintBitsToFloat(pushConstants.timeSecondsTimeFractionalSecondWidthHeight.y);

      // Calculate the scan line part of the hologram effect
      const float scanLine = (hologramScanMin < hologramScanMax) ? mix(hologramScanMin, hologramScanMax, clamp(fma(sin((vertexDirection * 6.283185307179586 * hologramScanTiling) + (hologramTime * hologramScanSpeed)), 0.75, 0.5), 0.0, 1.0)) : hologramScanMin;

      // Calculate the screen-retrace-like glow part of the hologram effect
      const float glow = (hologramGlowMin < hologramGlowMax) ? mix(hologramGlowMin, hologramGlowMax, fract((vertexDirection * hologramGlowTiling) - (hologramTime * hologramGlowSpeed))) : hologramGlowMin;

      // Calculate the flicker part of the hologram effect
      const float flicker = (hologramFlickerMin < hologramFlickerMax) ? mix(hologramFlickerMin, hologramFlickerMax, hologramNoise(fract(hologramTime * hologramFlickerSpeed))) : hologramFlickerMin;

      // Get the view direction from the inverse view matrix
      const vec3 viewDirection = normalize(view.inverseViewMatrix[2].xyz);

      // Calculate the rim part of the hologram effect
      const float rim = pow(1.0 - clamp((clamp(dot(workNormal, viewDirection), 0.0, 1.0) - hologramRimThreshold) / (1.0 - hologramRimThreshold), 0.0, 1.0), hologramRimPower);

      // Calculate the hologram color by combining the scan line, glow, flicker, and rim parts and multiplying it with the actual color
      color *= vec4(vec3(hologramMainColorFactor.xyz * (1.0 + (glow * 0.35))) + (rim * hologramRimColorFactor.xyz), (scanLine + (rim * hologramRimColorFactor.w) + glow) * flicker * hologramMainColorFactor.w);

      // Back-face culling for hologram effect
/*    if(dot(workNormal, viewDirection) < 0.0){
        color.w = 0.0;
      }*/

    } 
  }
#endif // !VOXELIZATION
#endif
  float alpha = ((flags & (1u << 31u)) != 0u) 
                   ? 1.0 // Force alpha to 1.0, if actually a opaque material is used, but with transmission in the transparency pass
                   : color.w * inColor0.w, 
        outputAlpha = ((flags & 32u) != 0) ? alpha : 1.0; // AMD GPUs under Linux doesn't like mix(1.0, alpha, float(int(uint((flags >> 5u) & 1u)))); due to the unsigned int stuff
  vec4 finalColor = vec4(color.xyz * inColor0.xyz, outputAlpha);
  if(inInstanceDataIndex > 0u){
    if(!applyInstanceDataEffect(uint(inInstanceDataIndex), finalColor, vec2(texCoords[0]), uvec2(gl_FragCoord.xy), false)){
      if((flags & (1u << 31u)) == 0u){ 
        finalColor.w = alpha = 0.0;
        if((flags & 32u) != 0){
          outputAlpha = 0.0;
        }
      }
    }
  }
#if !(defined(WBOIT) || defined(MBOIT) || defined(VOXELIZATION))
#ifndef BLEND 
  outFragColor = vec4(clamp(finalColor.xyz, vec3(-65504.0), vec3(65504.0)), finalColor.w);
#endif
#ifdef EXTRAEMISSIONOUTPUT
  outFragEmission = vec4(clamp(emissionColor.xyz * inColor0.xyz, vec3(-65504.0), vec3(65504.0)), outputAlpha);
#endif
#endif
#endif

#if defined(ALPHATEST)
  #if defined(NODISCARD)  
    float fragDepth;
  #endif
  if (alpha < uintBitsToFloat(material.alphaCutOffFlagsTex0Tex1.x)) {
  #if defined(WBOIT) || defined(LOCKOIT) || defined(DFAOIT) || defined(LOCKOIT_PASS2)
    finalColor = vec4(alpha = 0.0);    
  #elif defined(LOCKOIT_PASS1)
    alpha = 0.0;    
  #elif defined(MBOIT)
    #if defined(MBOIT) && defined(MBOITPASS1)    
      alpha = 0.0;    
    #else
      finalColor = vec4(alpha = 0.0);      
    #endif
  #else 
    #if defined(NODISCARD)  
      // Workaround for Intel (i)GPUs, which've problems with discarding fragments in 2x2 fragment blocks at alpha-test usage
#ifdef USE_SPECIALIZATION_CONSTANTS
      fragDepth = UseReversedZ ? -0.1 : 1.1;      
#else
      #if defined(REVERSEDZ)
        fragDepth = -0.1;
      #else
        fragDepth = 1.1;
      #endif
#endif
    #else
      #if defined(USEDEMOTE)
        demote;
      #else
        discard;
      #endif
    #endif
  #endif
  }else{
  #if defined(NODISCARD)  
    fragDepth = gl_FragCoord.z;
  #endif
  #if defined(WBOIT) || defined(MBOIT) || defined(LOCKOIT) || defined(LOOPOIT) || defined(DFAOIT)
    #if defined(WBOIT) || defined(LOCKOIT) || defined(LOOPOIT_PASS2) || defined(DFAOIT)
      finalColor.w = alpha = 1.0;    
    #elif defined(LOOPOIT_PASS1)
      alpha = 1.0;    
    #elif defined(MBOIT) && defined(MBOITPASS1)    
      alpha = 1.0;    
    #else
      finalColor.w = alpha = 1.0;    
    #endif
  #endif
  }
  #if defined(NODISCARD)  
    gl_FragDepth = fragDepth;
  #endif
  #if !(defined(WBOIT) || defined(MBOIT) || defined(LOCKOIT) || defined(LOOPOIT) || defined(DFAOIT))
    #ifdef MSAA
      #if 0
        vec2 alphaTextureSize = vec2(texture2DSize(0));
        vec2 alphaTextureUV = textureUV(0) * alphaTextureSize;
        vec4 alphaDUV = vec4(vec2(dFdx(alphaTextureUV)), vec2(dFdy(alphaTextureUV)));
        alpha *= 1.0 + (max(0.0, max(dot(alphaDUV.xy, alphaDUV.xy), dot(alphaDUV.zw, alphaDUV.zw)) * 0.5) * 0.25);
      #endif
      #if 1
        alpha = clamp(((alpha - uintBitsToFloat(material.alphaCutOffFlagsTex0Tex1.x)) / max(fwidth(alpha), 1e-4)) + 0.5, 0.0, 1.0);
      #endif  
      if (alpha < 1e-2) {
        alpha = 0.0;
      }
      #ifndef DEPTHONLY  
        outFragColor.w = finalColor.w = alpha;
      #endif
    #endif
  #endif
#endif

#if !defined(VOXELIZATION)
  const bool additiveBlending = false; // Mesh does never use additive blending currently, so static compile time constant folding is possible here.
   
#define TRANSPARENCY_IMPLEMENTATION
#include "transparency.glsl"
#undef TRANSPARENCY_IMPLEMENTATION

#if defined(VELOCITY)

  outFragVelocity = (((inCurrentClipSpace.xy / inCurrentClipSpace.w) - inJitter.xy) - ((inPreviousClipSpace.xy / inPreviousClipSpace.w) - inJitter.zw)) * 0.5;
  
#elif defined(REFLECTIVESHADOWMAPOUTPUT)

  vec3 normal = normalize(workNormal);
/*normal /= (abs(normal.x) + abs(normal.y) + abs(normal.z));
  outFragNormalUsed = vec4(vec3(fma(normal.xx, vec2(0.5, -0.5), vec2(fma(normal.y, 0.5, 0.5))), clamp(normal.z * 3.402823e+38, 0.0, 1.0)), 1.0);*/  
  outFragNormalUsed = vec4(vec3(fma(normal.xyz, vec3(0.5), vec3(0.5))), 1.0);  

  //outFragPosition = inWorldSpacePosition.xyz;

#endif
#endif

#ifdef VOXELIZATION
  #include "voxelization_fragment.glsl"   
#endif

} 

/*oid main() {
  outFragColor = vec4(vec3(mix(0.25, 1.0, max(0.0, dot(workNormal, vec3(0.0, 0.0, 1.0))))), 1.0);
//outFragColor = vec4(texture(uTexture, inTexCoord)) * vec4(vec3(mix(0.25, 1.0, max(0.0, dot(workNormal, vec3(0.0, 0.0, 1.0))))), 1.0);
}*/
