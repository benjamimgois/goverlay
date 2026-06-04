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

    if(atomicAdd(voxelGridContentMetaData.data[volumeIndex + 2], 1u) < voxelGridData.maxLocalFragmentCount){

      uint volumeCellIndex = atomicAdd(voxelGridContentMetaData.data[0], 1u);

      if(volumeCellIndex < voxelGridData.maxGlobalFragmentCount){

#if 0

        uvec4 data[2] = uvec4[2](
          uvec4(
            atomicExchange(voxelGridContentMetaData.data[volumeIndex + 3], volumeCellIndex + 1u), // next cell index (1-based, because 0 is the end of the list)
            packHalf2x16(vec2(baseColor.xy)), // base color red and green as 16 bit floats
            packHalf2x16(vec2(baseColor.z, emissionColor.x)), // base color blue and emission color red as 16 bit floats
            packHalf2x16(vec2(emissionColor.yz)) // emission color green and blue as 16 bit floats
          ),
          uvec4(
            packSnorm2x16(vec2(baseColor.w, normal.x)), // base color alpha and normal x as 16 bit signed normalized integers
            packSnorm2x16(vec2(normal.yz)), // normal y and z as 16 bit signed normalized integers
            0u, // unused
            0u  // unused
          )
        );

        voxelGridContentData.data[(volumeCellIndex << 1u) | 0u] = data[0];
        voxelGridContentData.data[(volumeCellIndex << 1u) | 1u] = data[1];

#else

        normal /= abs(normal.x) + abs(normal.y) + abs(normal.z);
        vec2 octNormal = (normal.z >= 0.0) ? normal.xy : ((vec2(1.0) - abs(normal.yx)) * vec2((normal.x >= 0.0) ? 1.0 : -1.0, (normal.y >= 0.0) ? 1.0 : -1.0)); 

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

  }else{
    outFragColor = vec4(0.0);
  }  
 
#endif

#endif