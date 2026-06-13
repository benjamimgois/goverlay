#ifndef DRAWINFO_GLSL
#define DRAWINFO_GLSL

//#extension GL_EXT_shader_explicit_arithmetic_types_int64 : enable
//#extension GL_EXT_buffer_reference : enable
#extension GL_EXT_buffer_reference2 : enable
#extension GL_EXT_buffer_reference_uvec2 : enable

// Packed vertex types matching TGPUCachedVertex and TGPUStaticVertex

struct PackedCachedVertex {
  float posX, posY, posZ;         // 12 bytes - position (3x float32)
  uint normalXY;                  //  4 bytes - snorm16(normal.x) | snorm16(normal.y)
  uint normalZSign;               //  4 bytes - snorm16(normal.z) | snorm16(bitangentSign)
  uint tangentXY;                 //  4 bytes - snorm16(tangent.x) | snorm16(tangent.y)
  uint tangentZModelScaleX;       //  4 bytes - snorm16(tangent.z) | half(modelScaleX)
  uint modelScaleYZ;              //  4 bytes - half(modelScaleY) | half(modelScaleZ)
}; // 32 bytes

struct PackedStaticVertex {
  vec2 texCoord0;                 //  8 bytes - (2x float32)
  vec2 texCoord1;                 //  8 bytes - (2x float32)
  uint colorRG;                   //  4 bytes - half(r) | half(g)
  uint colorBA;                   //  4 bytes - half(b) | half(a)
  uint materialID;                //  4 bytes - uint32
  uint _unused;                   //  4 bytes
}; // 32 bytes

// Buffer reference types for vertex pulling via BDA

layout(buffer_reference, std430, buffer_reference_align = 32) readonly buffer CachedVertexBuffer {
  PackedCachedVertex vertices[];
};

layout(buffer_reference, std430, buffer_reference_align = 32) readonly buffer StaticVertexBuffer {
  PackedStaticVertex vertices[];
};

layout(buffer_reference, std430, buffer_reference_align = 4) readonly buffer GenerationBuffer {
  uint generations[];
};

// GlobalBDAPointers - 112 bytes, single instance in SSBO at binding 7
// Contains the global buffer device addresses shared by all draws (big-buffer mode).
// For future per-group buffers, these would move back into DrawInfo or become per-group.
// Layout (std430):
//   offset  0: cachedVerticesBDA          (uvec2, 8 bytes)
//   offset  8: staticVerticesBDA          (uvec2, 8 bytes)
//   offset 16: previousCachedVerticesBDA  (uvec2, 8 bytes, velocity)
//   offset 24: generationBDA              (uvec2, 8 bytes, velocity)
//   offset 32: previousGenerationBDA      (uvec2, 8 bytes, velocity)
//   offset 40: matrixPairBDA              (uvec2, 8 bytes, BDA to MatrixPair buffer)
//   offset 48: lodInfoBDA                 (uvec2, 8 bytes, BDA to LODInfo buffer)
//   offset 56: lodNeededCurrentBDA        (uvec2, 8 bytes, BDA to lodNeeded[currentIFF])
//   offset 64: meshletDescriptorBDA       (uvec2, 8 bytes, BDA to meshlet descriptor buffer)
//   offset 72: meshletVertexBDA           (uvec2, 8 bytes, BDA to meshlet vertex buffer)
//   offset 80: meshletPrimitiveBDA        (uvec2, 8 bytes, BDA to meshlet primitive buffer)
//   offset 88: meshletBoundingSphereBDA   (uvec2, 8 bytes, BDA to per-instance meshlet bounding sphere buffer)
//   offset 96: nodeMatricesBDA            (uvec2, 8 bytes, BDA to per-IFF node matrices buffer)
//   offset 104: cloudsShadowMapBDA        (uvec2, 8 bytes, BDA to CloudsShadowMapData buffer)
// Total: 112 bytes

struct GlobalBDAPointers {
  uvec2 cachedVerticesBDA;
  uvec2 staticVerticesBDA;
  uvec2 previousCachedVerticesBDA;
  uvec2 generationBDA;
  uvec2 previousGenerationBDA;
  uvec2 matrixPairBDA;
  uvec2 lodInfoBDA;
  uvec2 lodNeededCurrentBDA;
  uvec2 meshletDescriptorBDA;
  uvec2 meshletVertexBDA;
  uvec2 meshletPrimitiveBDA;
  uvec2 meshletBoundingSphereBDA;
  uvec2 nodeMatricesBDA;
  uvec2 cloudsShadowMapBDA;
};

// MatrixPair struct - 128 bytes, two full mat4 matrices
// Stored in a separate BDA buffer, indexed by DrawInfo.matrixID
// MatrixPair[0] = Identity sentinel (non-instanced draws)
struct MatrixPair {
  mat4 modelMatrix;           // 64 bytes - current frame world transform
  mat4 previousModelMatrix;   // 64 bytes - previous frame (velocity)
};

// Buffer reference for MatrixPair via BDA
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer MatrixPairBuffer {
  MatrixPair pairs[];
};

// DrawInfo struct - 32 bytes per draw, stored in SSBO at binding 0
// Matrices moved to separate MatrixPairBuffer, accessed via matrixID
// Layout (std430):
//   offset   0: matrixID                 (uint, 4 bytes - index into MatrixPairBuffer, 0=Identity)
//   offset   4: instanceDataIndex        (uint, 4 bytes)
//   offset   8: meshObjectID             (uint, 4 bytes)
//   offset  12: flags                    (uint, 4 bytes)
//   offset  16: nodeMatricesIndex        (uint, 4 bytes)
//   offset  20: meshletDescriptorBase    (uint, 4 bytes - instance-level base into global meshlet descriptor buffer)
//   offset  24: meshletBoundingSphereBase (uint, 4 bytes - base into per-instance meshlet bounding sphere buffer, 0xFFFFFFFF=invalid)
//   offset  28: _reserved                (uint, 4 bytes - padding to 32 for power-of-two alignment)
// Total: 32 bytes

struct DrawInfo {
  uint matrixID;
  uint instanceDataIndex;
  uint meshObjectID;
  uint flags;
  uint nodeMatricesIndex;
  uint meshletDescriptorBase;
  uint meshletBoundingSphereBase;
  uint meshletVisibilityBase;
};

// LODInfo struct - 128 bytes per LOD-enabled submesh (8x uvec4 active = 128 bytes)
// Stores per-LOD geometry data for command-rewriting in mesh_cull.comp
// countLODs=1 means no LOD (noop), 2..4 means active LOD levels
// Also stores per-LOD meshlet descriptor offsets/counts for mesh shader path
// Layout (std430):
//   offset   0: countLODs          (uint, 4 bytes)
//   offset   4: reserved0          (uint, 4 bytes)
//   offset   8: reserved1          (uint, 4 bytes)
//   offset  12: reserved2          (uint, 4 bytes)
//   offset  16: thresholds         (vec4, 16 bytes - screenCoverage thresholds)
//   offset  32: firstIndices       (uvec4, 16 bytes - per LOD level 0..3)
//   offset  48: countIndices       (uvec4, 16 bytes - per LOD level 0..3)
//   offset  64: firstVertices      (ivec4, 16 bytes - vertexOffset per LOD, signed)
//   offset  80: meshletLocalOffsets(uvec4, 16 bytes - per LOD meshlet descriptor local offset within instance range)
//   offset  96: meshletCounts      (uvec4, 16 bytes - per LOD meshlet count)
//   offset 112: padding            (uvec4, 16 bytes - padding to 128)
// Total: 128 bytes

struct LODInfo {
  uint countLODs;
  uint reserved0;
  uint reserved1;
  uint reserved2;
  vec4 thresholds;
  uvec4 firstIndices;
  uvec4 countIndices;
  ivec4 firstVertices;
  uvec4 meshletLocalOffsets;
  uvec4 meshletCounts;
  uvec4 _padding0;
}; // 128 bytes = 8x vec4

// Buffer reference for LODInfo via BDA
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer LODInfoBuffer {
  LODInfo items[];
};

// Buffer reference for lodNeeded (per nodeMatricesIndex, uint32 bitfield)
layout(buffer_reference, std430, buffer_reference_align = 4) buffer LODNeededBuffer {
  uint needed[];
};

// Buffer reference for lodLevel (per nodeMatricesIndex, uint32 LOD level)
layout(buffer_reference, std430, buffer_reference_align = 4) buffer LODLevelBuffer {
  uint levels[];
};

// GPU Meshlet Descriptor — 32 bytes, matches TGPUMeshletDescriptor in Pascal
struct MeshletDescriptor {
  vec4 boundingSphere;   // xyz=center (object-space), w=radius
  uint vertexOffset;     // into global meshlet vertex buffer
  uint vertexCount;      // unique vertices in this meshlet
  uint primitiveOffset;  // into global meshlet primitive buffer
  uint primitiveCount;   // triangles in this meshlet
};

// Buffer reference for meshlet descriptors via BDA
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer MeshletDescriptorBuffer {
  MeshletDescriptor descriptors[];
};

// Buffer reference for meshlet vertex remap table via BDA (uint32 global vertex indices)
layout(buffer_reference, std430, buffer_reference_align = 4) readonly buffer MeshletVertexBuffer {
  uint vertices[];
};

// Buffer reference for meshlet packed primitive indices via BDA (3×uint8 per uint32)
layout(buffer_reference, std430, buffer_reference_align = 4) readonly buffer MeshletPrimitiveBuffer {
  uint primitives[];
};

// Buffer reference for per-instance meshlet bounding spheres via BDA (vec4 per meshlet)
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer MeshletBoundingSphereBuffer {
  vec4 spheres[];
};

// Buffer reference for node matrices via BDA (mat4 per node, indexed by drawInfo.nodeMatricesIndex)
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer NodeMatricesBDABuffer {
  mat4 matrices[];
};

// Cloud shadow map data, accessed via BDA from globalBDAPointers.cloudsShadowMapBDA
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer CloudsShadowMapDataBDABuffer {
  vec4 planetCenter; // xyz = planet center world position, w = unused
  vec4 params;       // x = enabled (1.0) or disabled (0.0), y = sunAngularRadius, z = cloud shell radius (LayerLow.StartHeight, absolute from planet center), w = unused
  vec4 lightDir;     // xyz = sun direction (world space), w = unused
};

// Indirect command metadata for mesh shader path — 32 bytes, matches TGPUDrawMeshTasksIndirectCommand
struct MeshDrawCommand {
  uvec4 cmd0; // x=groupCountX, y=1, z=1, w=meshletBaseIndex
  uvec4 cmd1; // x=meshletCount, y=meshObjectID, z=boundingSphereIndex, w=flags
};

// Buffer reference for mesh draw commands (indirect command buffer) via BDA
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer MeshDrawCommandBuffer {
  MeshDrawCommand commands[];
};

// Reconstruct a full mat4 from a packed mat3x4 affine transform.
// The mat3x4 stores the first 3 columns' xyz in .xyz and translation in .w:
//   m[0] = vec4(col0.xyz, translation.x)
//   m[1] = vec4(col1.xyz, translation.y)
//   m[2] = vec4(col2.xyz, translation.z)
mat4 mat3x4ToMat4(const in mat3x4 m) {
  return mat4(
    vec4(m[0].xyz, 0.0),
    vec4(m[1].xyz, 0.0),
    vec4(m[2].xyz, 0.0),
    vec4(m[0].w, m[1].w, m[2].w, 1.0)
  );
}

// Unpacking helpers for PackedCachedVertex

vec3 unpackPosition(in PackedCachedVertex v) {
  return vec3(v.posX, v.posY, v.posZ);
}

vec4 unpackNormalSign(in PackedCachedVertex v) {
  vec2 xy = unpackSnorm2x16(v.normalXY);
  vec2 zw = unpackSnorm2x16(v.normalZSign);
  return vec4(xy, zw);
}

vec3 unpackTangent(in PackedCachedVertex v) {
  vec2 xy = unpackSnorm2x16(v.tangentXY);
  float z = unpackSnorm2x16(v.tangentZModelScaleX).x;
  return vec3(xy, z);
}

vec3 unpackModelScale(in PackedCachedVertex v) {
  float scaleX = unpackHalf2x16(v.tangentZModelScaleX).y;
  vec2 scaleYZ = unpackHalf2x16(v.modelScaleYZ);
  return vec3(scaleX, scaleYZ);
}

// Unpacking helpers for PackedStaticVertex

vec4 unpackColor0(in PackedStaticVertex v) {
  return vec4(unpackHalf2x16(v.colorRG), unpackHalf2x16(v.colorBA));
}

#endif // DRAWINFO_GLSL
