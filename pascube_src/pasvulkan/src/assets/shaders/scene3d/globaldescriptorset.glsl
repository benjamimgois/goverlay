#ifndef GLOBAL_DESCRIPTOR_SET_GLSL
#define GLOBAL_DESCRIPTOR_SET_GLSL 

#ifdef RAYTRACING
  #extension GL_EXT_ray_tracing : enable
  #extension GL_EXT_ray_query : enable
  #extension GL_EXT_ray_flags_primitive_culling : enable
#endif

//#ifdef MESHS

#include "drawinfo.glsl"

layout(set = 0, binding = 0, std430) readonly buffer DrawInfoBuffer {
  DrawInfo drawInfoItems[];
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

struct Decal {
  
  // World to decal OBB transform (3x4 matrix) - 48 bytes - here as three vec4 instead mat4x3 for 
  // better alignment and compatibility with buffer reference  
  vec4 matrix0;                
  vec4 matrix1;                
  vec4 matrix2;                

  vec4 uvScaleOffset;          // xy=scale, zw=offset - 16 bytes
  uvec4 blendParams;           // x=opacity(float bits), y=angleFade(float bits), z=edgeFade(float bits), w=pbrBlendFactor(float bits) - 16 bytes
  ivec4 textureIndices;        // albedo, normal, ORM, specular texture indices (-1 = none) - 16 bytes
  ivec4 textureIndices2;       // emissive, unused, unused, unused - 16 bytes
  uvec4 decalUpFlags;          // xyz=up direction for angle fade(float bits), w=flags(uint bits) - 16 bytes
};                             // Total: 128 bytes

layout(set = 0, binding = 3, std430) readonly buffer DecalItemData {
  Decal decals[];
};

struct DecalTreeNode {
  uvec4 aabbMinSkipCount;
  uvec4 aabbMaxUserData;
};

layout(set = 0, binding = 4, std430) readonly buffer DecalTreeNodeData {
  DecalTreeNode decalTreeNodes[];
};

#endif // LIGHTS

//#ifdef MESHS

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

layout(set = 0, binding = 5, std140) uniform Materials {
  Material materials;
} uMaterials;

//#endif // MESHS

#if defined(USE_BUFFER_REFERENCE) 
#define USE_PLANET_BUFFER_REFERENCE
#include "planet_data.glsl"
#endif

#include "instance_data_struct.glsl"

layout(set = 0, binding = 6, std430) readonly buffer InstanceDataBuffer {
  InstanceData instanceDataItems[];
};

// InstanceDataIndexBuffer removed — instanceDataIndex is now in DrawInfo
// layout(set = 0, binding = 7, std430) readonly buffer InstanceDataIndexBuffer {
//   uint instanceDataIndices[];
// };

layout(set = 0, binding = 7, std430) readonly buffer GlobalBDAPointersBuffer {
  GlobalBDAPointers globalBDAPointers;
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

layout(set = 0, binding = 8) uniform accelerationStructureEXT uRaytracingTopLevelAccelerationStructure;

layout(set = 0, binding = 9, std140) uniform RaytracingData {
  RaytracingGeometryInstanceOffsets geometryInstanceOffsets;
  RaytracingGeometryItems geometryItems;
  RaytracingMeshStaticVertices meshStaticVertices;
  RaytracingMeshDynamicVertices meshDynamicVertices;
  RaytracingMeshIndices meshIndices;  
  RaytracingParticleVertices particleVertices;
  ReferencedPlanetDataArray referencedPlanetDataArray;
} uRaytracingData;

layout(set = 0, binding = 10) uniform sampler2D u2DTextures[];

layout(set = 0, binding = 10) uniform sampler3D u3DTextures[];

layout(set = 0, binding = 10) uniform samplerCube uCubeTextures[];

#else

layout(set = 0, binding = 8) uniform sampler2D u2DTextures[];

layout(set = 0, binding = 8) uniform sampler3D u3DTextures[];

layout(set = 0, binding = 8) uniform samplerCube uCubeTextures[];

#endif // RAYTRACING

#endif