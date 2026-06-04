  mat4 worldToCascadeClipSpaceMatrices[8]; // world-to-cascade matrices (in clip space)
  mat4 worldToCascadeNormalizedMatrices[8]; // world-to-cascade matrices (normalized to [0, 1] in x, y and z)
  mat4 worldToCascadeGridMatrices[8]; // world-to-cascade matrices in grid space
  mat4 cascadeGridToWorldMatrices[8]; // cascade-to-world matrices (in world space)
  ivec4 cascadeAvoidAABBGridMin[8]; // in grid-space
  ivec4 cascadeAvoidAABBGridMax[8]; // in grid-space
  vec4 cascadeAABBMin[8]; // in world-space
  vec4 cascadeAABBMax[8]; // in world-space
  vec4 cascadeAABBFadeStart[8];
  vec4 cascadeAABBFadeEnd[8];
  vec4 cascadeCenterHalfExtents[8]; // xyz = center in world-space, w = half-extent of a voxel 
  vec4 worldToCascadeScales[2]; // a world-to-cascade-scale component per cascade
  vec4 cascadeToWorldScales[2]; // a cascade-to-world-scale component per cascade
  vec4 cascadeCellSizes[2]; // size of a voxel in world-space
  vec4 oneOverGridSizes[2]; // 1.0 / gridSize, component per cascade
  uvec4 gridSizes[2]; // number of voxels in a cascade in a single dimension, component per cascade
  uvec4 dataOffsets[2]; // cascade offsets, component per cascade
  uint countCascades; // maximum 4 cascades
  uint hardwareConservativeRasterization; // 0 = false, 1 = true
  uint maxGlobalFragmentCount; // maximum number of fragments per voxel globally
  uint maxLocalFragmentCount; // maximum number of fragments per voxel locally