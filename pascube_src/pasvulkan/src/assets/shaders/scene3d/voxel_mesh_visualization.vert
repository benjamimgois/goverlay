#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable

#if defined(USEGEOMETRYSHADER)
layout(location = 0) out vec3 outPosition; 
layout(location = 1) flat out int outCascadeIndex;
layout(location = 2) flat out mat4 outViewProjectionMatrix;
#else
layout(location = 0) out vec4 outColor;  
#endif

/* clang-format off */

layout(push_constant) uniform PushConstants {
  uint viewBaseIndex; 
  uint countViews;    
  uint gridSizeBits;     
  uint cascadeIndex;   
} pushConstants;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 0, binding = 0, std140) uniform uboViews {
   View views[256];
} uView;

#if !defined(USEGEOMETRYSHADER)
layout (set = 1, binding = 0, std140) readonly uniform VoxelGridData {
  #include "voxelgriddata_uniforms.glsl"
} voxelGridData;

layout(set = 1, binding = 1) uniform sampler3D uVoxelGridOcclusion[];

layout(set = 1, binding = 2) uniform sampler3D uVoxelGridRadiance[];

// Unlit base-colour + emission visualization volume (E5B9G9R9 sample view), filled by gi_voxel_radiance_transfer.comp while the
// voxel debug visualization is active. This is what the resolved (non-raw) path shows: surface albedo + emission, no lighting.
layout(set = 1, binding = 3) uniform sampler3D uVoxelGridVisualization[];

#ifdef VOXEL_MESH_VIS_RAW_CONTENT
// Diagnostic: read the RAW voxelization content (per-voxel linked list) instead of the resolved uVoxelGridRadiance, to tell
// whether a missing voxel is a voxelization (writer) problem or a radiance-resolve problem. Bound on the viz's own set 0.
// The accumulation mirrors gi_voxel_radiance_transfer.comp's anisotropic axis-direction weighting, so each cube side shows the
// same albedo the resolve would write -> a discrepancy then points at the resolve, not the content.
#include "rgb9e5.glsl"
layout(set = 0, binding = 1, std430) readonly buffer VoxelGridContentMetaData { uint data[]; } voxelGridContentMetaData;
layout(set = 0, binding = 2, std430) readonly buffer VoxelGridContentData { uvec4 data[]; } voxelGridContentData;
// Same octahedral normal decode as the radiance transfer (RGB9E5 content stores the normal octahedral; FP16 stores it raw).
vec3 voxelRawOctDecode(vec2 oct){
  vec3 v = vec3(oct.xy, 1.0 - (abs(oct.x) + abs(oct.y)));
  float t = max(-v.z, 0.0);
  v.xy += vec2((v.x >= 0.0) ? -t : t, (v.y >= 0.0) ? -t : t);
  return normalize(v);
}
#endif
#endif

/* clang-format on */

void main() {
#if defined(USEGEOMETRYSHADER)

  outPosition = vec3(ivec3((ivec3(int(gl_VertexIndex)) >> (ivec3(0, 1, 2) * ivec3(int(pushConstants.gridSizeBits)))) & ivec3(int(uint((1u << pushConstants.gridSizeBits) - 1u)))));
  outCascadeIndex = int(pushConstants.cascadeIndex);
  outViewProjectionMatrix = uView.views[pushConstants.viewBaseIndex + uint(gl_ViewIndex)].projectionMatrix * uView.views[pushConstants.viewBaseIndex + uint(gl_ViewIndex)].viewMatrix;

#else

  uint cascadeIndex = pushConstants.cascadeIndex;
 
  uint vertexIndex = uint(gl_VertexIndex);

  // 6 vertices per quad of a cube side of a voxel with two triangles per quad, where each triangle has 3 vertices      
  uint quadIndex = vertexIndex / 6u;
  uint quadVertexIndex = (uint[6](0, 1, 2, 0, 2, 3))[vertexIndex - (quadIndex * 6u)];
  
  // 6 cube sides per voxel
  uint cubeIndex = quadIndex / 6u;
  uint cubeSideIndex = quadIndex - (cubeIndex * 6u);

  ivec3 voxelPosition = ivec3(uvec3(uvec3(uvec3(cubeIndex) >> (uvec3(0u, 1u, 2u) * uint(pushConstants.gridSizeBits))) & uvec3(uint((1u << pushConstants.gridSizeBits) - 1u))));

#ifdef VOXEL_MESH_VIS_RAW_CONTENT
  // Raw voxelization content for THIS cube side: traverse the voxel's fragment linked list and accumulate base colour into the
  // anisotropic axis-direction side matching cubeSideIndex (weighted by abs(normal[axis])), then divide by the fragment count
  // -> exactly what gi_voxel_radiance_transfer.comp writes (albedo path), but read straight from the content, skipping the resolve.
  vec4 voxel = vec4(0.0);
  // Skip coarser-cascade voxels that fall inside a finer cascade's region (same cascade-avoid test as the resolved path), so
  // the higher cascades don't overdraw the finer ground here.
  if((cascadeIndex == 0u) ||
     !(all(greaterThanEqual(voxelPosition, voxelGridData.cascadeAvoidAABBGridMin[cascadeIndex].xyz)) &&
       all(lessThan(voxelPosition, voxelGridData.cascadeAvoidAABBGridMax[cascadeIndex].xyz)))){
    uint vgs = voxelGridData.gridSizes[cascadeIndex >> 2u][cascadeIndex & 3u];
    uint volumeBaseIndex = ((((uint(voxelPosition.z) * vgs) + uint(voxelPosition.y)) * vgs) + uint(voxelPosition.x)) + voxelGridData.dataOffsets[cascadeIndex >> 2u][cascadeIndex & 3u];
    uint volumeIndex = volumeBaseIndex << 1u;
    float rawCount = 0.0;
    uint rawCountVoxelFragments = min(1024u, voxelGridContentMetaData.data[volumeIndex + 2u]);
    for(uint frag = voxelGridContentMetaData.data[volumeIndex + 3u], i = 0u; (frag != 0u) && (i < rawCountVoxelFragments); i++){
      vec3 baseRGB;
      float baseA;
      vec3 nrm;
      uint nextFrag;
#ifdef GI_VOXEL_CONTENT_FP16
      uvec4 f0 = voxelGridContentData.data[((frag - 1u) << 1u) | 0u];
      uvec4 f1 = voxelGridContentData.data[((frag - 1u) << 1u) | 1u];
      nextFrag = f0.x;
      vec2 brg = unpackHalf2x16(f0.y);
      vec2 bzer = unpackHalf2x16(f0.z);
      vec2 anx = unpackSnorm2x16(f1.x);
      vec2 nyz = unpackSnorm2x16(f1.y);
      baseRGB = vec3(brg, bzer.x);
      baseA = clamp(anx.x, 0.0, 1.0);
      nrm = normalize(vec3(anx.y, nyz));
#else
      uvec4 vf = voxelGridContentData.data[frag - 1u];
      nextFrag = vf.x;
      baseRGB = decodeRGB9E5(vf.y);
      baseA = clamp(float(uint(vf.w & 0xffu)) * (1.0 / 255.0), 0.0, 1.0);
      nrm = voxelRawOctDecode(vec2((ivec2(uvec2((vf.ww >> uvec2(8u, 20u)) & uvec2(0xfffu))) - ivec2(2048)) / 2047.0));
#endif
      // Which anisotropic side does each axis of this fragment's normal map to (0=X+,1=Y+,2=Z+,3=X-,4=Y-,5=Z-)?
      uvec3 sideIndices = uvec3((nrm.x > 0.0) ? 0u : 3u, (nrm.y > 0.0) ? 1u : 4u, (nrm.z > 0.0) ? 2u : 5u);
      vec3 axisWeights = abs(nrm);
      float sideWeight = ((sideIndices.x == cubeSideIndex) ? axisWeights.x : 0.0) +
                         ((sideIndices.y == cubeSideIndex) ? axisWeights.y : 0.0) +
                         ((sideIndices.z == cubeSideIndex) ? axisWeights.z : 0.0);
      voxel += (vec4(baseRGB, 1.0) * baseA) * sideWeight; // premultiplied-alpha base colour, anisotropically weighted
      rawCount += 1.0;
      frag = nextFrag;
    }
    if(rawCount > 0.0){
      voxel /= rawCount;
    }
  } // cascade-avoid guard
  bool voxelNonEmpty = dot(voxel, voxel) > 0.0;
#else
  vec4 voxel = ((cascadeIndex == 0u) || // First cascade is always the highest resolution cascade, so no further check is needed here
                !(all(greaterThanEqual(voxelPosition, voxelGridData.cascadeAvoidAABBGridMin[cascadeIndex].xyz)) &&
                  all(lessThan(voxelPosition, voxelGridData.cascadeAvoidAABBGridMax[cascadeIndex].xyz)))) ?
                   texelFetch(uVoxelGridVisualization[(cascadeIndex * 6u) + cubeSideIndex], voxelPosition, 0) :
                   vec4(0.0);
  // The E5B9G9R9 sample has no alpha (always 1.0), so emptiness must be tested on rgb only.
  bool voxelNonEmpty = dot(voxel.xyz, voxel.xyz) > 0.0;
#endif

  if(voxelNonEmpty){

    outColor = voxel;

    const ivec3 vertices[8] = ivec3[8](
      ivec3(0, 0, 0), // -1 -1 -1
      ivec3(1, 0, 0), // +1 -1 -1 
      ivec3(0, 1, 0), // -1 +1 -1
      ivec3(1, 1, 0), // +1 +1 -1
      ivec3(0, 0, 1), // -1 -1 +1
      ivec3(1, 0, 1), // +1 -1 +1
      ivec3(0, 1, 1), // -1 +1 +1
      ivec3(1, 1, 1)  // +1 +1 +1
    );

    const ivec4 quadIndicesArray[6] = ivec4[6](
      ivec4(1, 5, 7, 3), // +X
      ivec4(2, 3, 7, 6), // +Y
      ivec4(4, 6, 7, 5), // +Z
      ivec4(0, 2, 6, 4), // -X
      ivec4(0, 4, 5, 1), // -Y
      ivec4(0, 1, 3, 2)  // -Z
    );

    gl_Position = (uView.views[pushConstants.viewBaseIndex + uint(gl_ViewIndex)].projectionMatrix * 
                   uView.views[pushConstants.viewBaseIndex + uint(gl_ViewIndex)].viewMatrix) * 
                   vec4(fma(vec3(ivec3(voxelPosition + vertices[quadIndicesArray[cubeSideIndex][quadVertexIndex]])), 
                            vec3(voxelGridData.cascadeCellSizes[cascadeIndex >> 2u][cascadeIndex & 3u]), 
                            voxelGridData.cascadeAABBMin[cascadeIndex].xyz), 
                        1.0);

  }else{

    outColor = vec4(0.0);

    // Generate degenerated out-of-clip-space gl_Position to avoid rendering
    gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
    
  }    

#endif
}
