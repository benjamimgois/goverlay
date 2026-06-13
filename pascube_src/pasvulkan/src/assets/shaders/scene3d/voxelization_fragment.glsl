#ifndef VOXELIZATION_FRAGMENT_GLSL
#define VOXELIZATION_FRAGMENT_GLSL

#ifdef VOXELIZATION
  vec4 cascade = voxelGridData.cascadeCenterHalfExtents[inCascadeIndex];

  uint voxelGridSize = voxelGridData.gridSizes[inCascadeIndex >> 2u][inCascadeIndex & 3u];
  
  uvec3 volumePosition = uvec3(inVoxelPosition * float(voxelGridSize)); 

// uvec3 volumePosition = uvec3(ivec3((inWorldSpacePosition - vec3(cascade.xyz)) / float(voxelGridData.cellSizes[inCascadeIndex]))) + uvec3(voxelGridSize >> 1u); 

  mat4 gridToWorldMatrix = voxelGridData.cascadeGridToWorldMatrices[inCascadeIndex];

  if(all(greaterThanEqual(volumePosition, ivec3(0))) &&
    all(lessThan(volumePosition, ivec3(voxelGridSize))) &&
    (baseColor.w >= 0.00392156862) /*/&&
    aabbTriangleIntersection((gridToWorldMatrix * vec4(volumePosition, 1.0)).xyz, (gridToWorldMatrix * vec4(volumePosition + vec3(1.0), 1.0)).xyz, inVertex0, inVertex1, inVertex2)/**/){ 

    uint volumeBaseIndex = 
      (
        (
          (
            (
              uint(volumePosition.z) * voxelGridSize
            ) + uint(volumePosition.y)
          ) * voxelGridSize
        ) + uint(volumePosition.x) 
      ) + voxelGridData.dataOffsets[inCascadeIndex >> 2u][inCascadeIndex & 3u];

    uint volumeIndex = volumeBaseIndex << 1u;

    // Single-sided surfaces store one fragment with the geometric normal; double-sided ones (voxelDoubleSided, set by the
    // consumer from material flag bit 6) store a SECOND fragment with the flipped normal too, so the surface is voxelized for
    // BOTH anisotropic directions. The dominant-axis voxelization projection only captures a surface from one side, so without
    // this a double-sided floor/wall would be lit/visible from one side only. voxelNormal must not mutate the shared `normal`.
    uint voxelDirectionCount = voxelDoubleSided ? 2u : 1u;
    for(uint voxelDirectionIndex = 0u; voxelDirectionIndex < voxelDirectionCount; voxelDirectionIndex++){

      vec3 voxelNormal = (voxelDirectionIndex == 0u) ? normal : -normal;

      if(atomicAdd(voxelGridContentMetaData.data[volumeIndex + 2], 1u) < voxelGridData.maxLocalFragmentCount){

        uint volumeCellIndex = atomicAdd(voxelGridContentMetaData.data[0], 1u);

        if(volumeCellIndex < voxelGridData.maxGlobalFragmentCount){

#ifdef GI_VOXEL_CONTENT_FP16
          // FP16 content storage (2 uvec4 per cell, stride 2): base/emission as packHalf2x16 -> keeps very high HDR values that
          // RGB9E5 (the #else default) clamps/breaks. The content data buffer is already sized for 2 uvec4 per cell (32 bytes).
          // The radiance + occlusion transfer readers must decode the matching layout under the same define.

          uvec4 data[2] = uvec4[2](
            uvec4(
              atomicExchange(voxelGridContentMetaData.data[volumeIndex + 3], volumeCellIndex + 1u), // next cell index (1-based, because 0 is the end of the list)
              packHalf2x16(vec2(baseColor.xy)), // base color red and green as 16 bit floats
              packHalf2x16(vec2(baseColor.z, emissionColor.x)), // base color blue and emission color red as 16 bit floats
              packHalf2x16(vec2(emissionColor.yz)) // emission color green and blue as 16 bit floats
            ),
            uvec4(
              packSnorm2x16(vec2(baseColor.w, voxelNormal.x)), // base color alpha and normal x as 16 bit signed normalized integers
              packSnorm2x16(vec2(voxelNormal.yz)), // normal y and z as 16 bit signed normalized integers
              0u, // unused
              0u  // unused
            )
          );

          voxelGridContentData.data[(volumeCellIndex << 1u) | 0u] = data[0];
          voxelGridContentData.data[(volumeCellIndex << 1u) | 1u] = data[1];

#else

          vec3 octN = voxelNormal / (abs(voxelNormal.x) + abs(voxelNormal.y) + abs(voxelNormal.z));
          vec2 octNormal = (octN.z >= 0.0) ? octN.xy : ((vec2(1.0) - abs(octN.yx)) * vec2((octN.x >= 0.0) ? 1.0 : -1.0, (octN.y >= 0.0) ? 1.0 : -1.0));

          voxelGridContentData.data[volumeCellIndex] = uvec4(

            // next cell index (1-based, because 0 is the end of the list)
            atomicExchange(voxelGridContentMetaData.data[volumeIndex + 3], volumeCellIndex + 1u),

            // base color as RGB9E5
            encodeRGB9E5(baseColor.xyz),

            // emission color as RGB9E5
            encodeRGB9E5(emissionColor.xyz),

            // base color alpha as 8 bit unsigned integer, normal as spherical coordinates with 12 bit normalized integers, for a total of 32 bits
            ((uint(float(clamp(baseColor.w, 0.0, 1.0) * 255.0)) & 0xffu) << 0u) |
            ((uint(float((clamp(octNormal.x, -1.0, 1.0) * 2047.0) + 2048.0)) & 0xfffu) << 8u) |
            ((uint(float((clamp(octNormal.y, -1.0, 1.0) * 2047.0) + 2048.0)) & 0xfffu) << 20u)

          );

#endif

        }

      }

    }

  }else{
    outFragColor = vec4(0.0);
  }  
 
#endif

#endif