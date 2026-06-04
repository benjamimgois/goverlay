#ifndef GLOBAL_DESCRIPTOR_SET_GLSL
#define GLOBAL_DESCRIPTOR_SET_GLSL 

#ifdef RAYTRACING
  #extension GL_EXT_ray_tracing : enable
  #extension GL_EXT_ray_query : enable
  #extension GL_EXT_ray_flags_primitive_culling : enable
#endif

//#ifdef MESHS
#if !defined(USE_MATERIAL_BUFFER_REFERENCE)
struct Material {
  vec4 baseColorFactor;
  vec4 specularFactor;
  vec4 emissiveFactor;
  vec4 metallicRoughnessNormalScaleOcclusionStrengthFactor;
  vec4 sheenColorFactorSheenRoughnessFactor;
  vec4 clearcoatFactorClearcoatRoughnessFactor;
  vec4 iorIridescenceFactorIridescenceIorIridescenceThicknessMinimum;
  vec4 iridescenceThicknessMaximumTransmissionFactorVolumeThicknessFactorVolumeAttenuationDistance;
  vec4 diffuseTransmissionColorFactor;
  uvec4 volumeAttenuationColorAnisotropyStrengthAnisotropyRotation;
  uvec4 dispersionShadowCastMaskShadowReceiveMaskUnused;
  uvec4 hologramBlock0;
  uvec4 hologramBlock1;
  uvec4 hologramBlock2;
  uvec4 alphaCutOffFlagsTex0Tex1;
  int textures[20];
  mat3x2 textureTransforms[20];
};
#endif

layout(set = 0, binding = 0, std430) readonly buffer InstanceMatrices {
  mat4 instanceMatrices[];
};
//#endif // MESHS

#ifdef LIGHTS
struct Light {
  uvec4 metaData; // x = type, y = ShadowMapIndex, z = LightAngleScale, w = LightAngleOffset
  vec4 colorIntensity;
  vec4 positionRadius;
  vec4 directionRange;
  mat4 transformMatrix;
};

layout(set = 0, binding = 1, std430) readonly buffer LightItemData {
//uvec4 lightMetaData;
  Light lights[];
};

struct LightTreeNode {
  uvec4 aabbMinSkipCount;
  uvec4 aabbMaxUserData;
};

layout(set = 0, binding = 2, std430) readonly buffer LightTreeNodeData {
  LightTreeNode lightTreeNodes[];
};

#endif // LIGHTS

//#ifdef MESHS
#if defined(USE_MATERIAL_BUFFER_REFERENCE)

layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer Material {
  vec4 baseColorFactor;
  vec4 specularFactor;
  vec4 emissiveFactor;
  vec4 metallicRoughnessNormalScaleOcclusionStrengthFactor;
  vec4 sheenColorFactorSheenRoughnessFactor;
  vec4 clearcoatFactorClearcoatRoughnessFactor;
  vec4 iorIridescenceFactorIridescenceIorIridescenceThicknessMinimum;
  vec4 iridescenceThicknessMaximumTransmissionFactorVolumeThicknessFactorVolumeAttenuationDistance;
  vec4 diffuseTransmissionColorFactor;
  uvec4 volumeAttenuationColorAnisotropyStrengthAnisotropyRotation;
  uvec4 dispersionShadowCastMaskShadowReceiveMaskUnused;
  uvec4 hologramBlock0;
  uvec4 hologramBlock1;
  uvec4 hologramBlock2;
  uvec4 alphaCutOffFlagsTex0Tex1;
  int textures[20];
  mat3x2 textureTransforms[20];
};

layout(set = 0, binding = 3, std140) uniform Materials {
  Material materials;
} uMaterials;

#else

layout(set = 0, binding = 3, std430) readonly buffer Materials {
  Material materials[];
};
#endif // defined(USE_MATERIAL_BUFFER_REFERENCE)
//#endif // MESHS

#if defined(USE_BUFFER_REFERENCE) 
#define USE_PLANET_BUFFER_REFERENCE
#include "planet_data.glsl"
#endif

struct InstanceData { 
  
  uvec4 SelectedDissolveDitheredTransparencyFlags;
  
  vec4 SelectedColorIntensity;
  
  vec4 DissolveColor0Scale;
  vec4 DissolveColor1Width;  

  uvec4 colorKeysRG; // 2x half float RGBA
  uvec4 colorKeysBA; // 2x half float RGBA

  // For alignment
  uvec4 unused0;
  uvec4 unused1;
};

layout(set = 0, binding = 4, std430) readonly buffer InstanceDataBuffer {
  InstanceData instanceDataItems[];
};

layout(set = 0, binding = 5, std430) readonly buffer InstanceDataIndexBuffer {
  uint instanceDataIndices[];
};

#ifdef RAYTRACING

layout(buffer_reference, std430, buffer_reference_align = 8) readonly buffer ReferencedPlanetDataArray {
  PlanetData planetData[];
};

layout(buffer_reference, std430, buffer_reference_align = 4) readonly buffer RaytracingGeometryInstanceOffsets {
  uint geometryInstanceOffsets[];
};

struct RaytracingGeometryItem {
  uint objectType;
  uint objectIndex;
  uint materialIndex;
  uint indexOffset;
};

layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer RaytracingGeometryItems {
  RaytracingGeometryItem geometryItems[];
};

struct RaytracingMeshStaticVertex {
  vec4 texCoords; // xy = texCoord A0, zw = texCoord 1
  uvec4 color0MaterialID; // xy = color (half float RGBA), z = material ID, w = unused
};

struct RaytracingMeshDynamicVertex {
  uvec4 positionNormalXY; // xyz = position (32-bit float), w = normal x y (16-bit signed normalized)
  uvec4 normalZSignTangentXYZModelScaleXYZ; // x = normal z + sign of tangent z (16-bit signed normalized), y = tangent x y (16-bit signed normalized), z = tangent z + model scale x (16-bit float), w = model scale y z (16-bit float)
};

layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer RaytracingMeshStaticVertices {
  RaytracingMeshStaticVertex meshStaticVertices[];
};

layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer RaytracingMeshDynamicVertices {
  RaytracingMeshDynamicVertex meshDynamicVertices[];
};

layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer RaytracingMeshIndices {
  uint meshIndices[];
};

struct RaytracingParticleVertex {
  vec4 positionRotation; // xyz = position (32-bit float), w = rotation (32-bit float)
  uvec4 quadCoordTextureID; // x = quadCoord (half float XY), y = textureID (32-bit unsigned int), zw = size XY (32-bit floats)
  uvec4 colorUnused; // xy = color (half float RGBA), zw = unused 
}; // 48 bytes per vertex

layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer RaytracingParticleVertices {
  RaytracingParticleVertex particleVertices[];
};

#define RaytracingPlanetVertex uvec4 // xyz = position (32-bit float), w = octahedral normal (2x signed normalized 16-bit)

layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer RaytracingPlanetVertices {
  RaytracingPlanetVertex planetVertices[];
};

layout(buffer_reference, std430, buffer_reference_align = 4) readonly buffer RaytracingPlanetIndices {
  uint planetIndices[];
};

layout(set = 0, binding = 6) uniform accelerationStructureEXT uRaytracingTopLevelAccelerationStructure;

layout(set = 0, binding = 7, std140) uniform RaytracingData {
  RaytracingGeometryInstanceOffsets geometryInstanceOffsets;
  RaytracingGeometryItems geometryItems;
  RaytracingMeshStaticVertices meshStaticVertices;
  RaytracingMeshDynamicVertices meshDynamicVertices;
  RaytracingMeshIndices meshIndices;  
  RaytracingParticleVertices particleVertices;
  ReferencedPlanetDataArray referencedPlanetDataArray;
} uRaytracingData;

layout(set = 0, binding = 8) uniform sampler2D u2DTextures[];

layout(set = 0, binding = 8) uniform sampler3D u3DTextures[];

layout(set = 0, binding = 8) uniform samplerCube uCubeTextures[];

#else

layout(set = 0, binding = 6) uniform sampler2D u2DTextures[];

layout(set = 0, binding = 6) uniform sampler3D u3DTextures[];

layout(set = 0, binding = 6) uniform samplerCube uCubeTextures[];

#endif // RAYTRACING

#endif