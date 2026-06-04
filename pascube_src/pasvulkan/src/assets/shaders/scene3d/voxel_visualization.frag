#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable
#if defined(USEDEMOTE)
  #extension GL_EXT_demote_to_helper_invocation : enable
#endif

layout(location = 0) in vec3 inRayOrigin;
layout(location = 1) in vec3 inRayDirection;

layout(location = 0) out vec4 outFragColor;

layout (set = 1, binding = 0, std140) readonly uniform VoxelGridData {
  #include "voxelgriddata_uniforms.glsl"
} voxelGridData;

 layout(set = 1, binding = 1) uniform sampler3D uVoxelGridOcclusion[];

 layout(set = 1, binding = 2) uniform sampler3D uVoxelGridRadiance[];

struct Intersection {
   float dist;
   vec4 voxel;
};

bool voxelTrace(const in int cascadeIndex,
                in vec3 rayOrigin, 
                in vec3 rayDirection,
                inout Intersection intersection){
 
  rayDirection = normalize(rayDirection);

  vec3 inversedRayDirection = vec3(1.0) / rayDirection;

  vec3 t0 = (voxelGridData.cascadeAABBMin[cascadeIndex].xyz - rayOrigin) / rayDirection;
  vec3 t1 = (voxelGridData.cascadeAABBMax[cascadeIndex].xyz - rayOrigin) / rayDirection;
  vec3 tMin = min(t0, t1);
  vec3 tMax = max(t0, t1);
  vec2 tNearFar = vec2(max(max(tMin.x, tMin.y), tMin.z), min(min(tMax.x, tMax.y), tMax.z));
  if((tNearFar.x > tNearFar.y) || (tNearFar.y < 0.0) || (tNearFar.x > intersection.dist)){
    return false;
  }
    
  tNearFar.x = max(0.0, tNearFar.x);
  
  intersection.dist = clamp(intersection.dist, tNearFar.x, tNearFar.y);
  
  rayOrigin = (voxelGridData.worldToCascadeGridMatrices[cascadeIndex] * vec4(fma(rayDirection, tNearFar.xxx, rayOrigin), 1.0)).xyz;

  ivec3 position = ivec3(floor(rayOrigin)),
        positionStep = ivec3(sign(rayDirection));

  vec3 sideDistanceStep = vec3(1.0) / abs(rayDirection),
       sideDistance = (((vec3(position) - rayOrigin) * sign(rayDirection)) + (sign(rayDirection) * 0.5) + vec3(0.5)) * sideDistanceStep;   
      
  const uint gridSize = voxelGridData.gridSizes[cascadeIndex >> 2][cascadeIndex & 3];

  const float timeScale = voxelGridData.cascadeToWorldScales[cascadeIndex >> 2][cascadeIndex & 3] / float(gridSize); // Assuming that all the cascade grid bound axes are equally-sized

  const int maxSteps = int(2 * ceil(length(vec3(float(gridSize)))));

  float time = 0.0;

  for(int stepIndex = 0; (stepIndex < maxSteps) && (time <= intersection.dist); stepIndex++){      
      
    vec4 voxel = vec4(0.0);
    if((cascadeIndex == 0) || // First cascade is always the highest resolution cascade, so no further check is needed here
        !(all(greaterThanEqual(position, voxelGridData.cascadeAvoidAABBGridMin[cascadeIndex].xyz)) &&
          all(lessThan(position, voxelGridData.cascadeAvoidAABBGridMax[cascadeIndex].xyz)))){

      int mipMapLevel = 0;
      ivec3 samplePosition = position >> mipMapLevel;
      bvec3 negativeDirection = lessThan(rayDirection, vec3(0.0));
      vec3 directionWeights = abs(rayDirection);
      ivec3 textureIndices = ivec3(negativeDirection.x ? 1 : 0, negativeDirection.y ? 3 : 2, negativeDirection.z ? 5 : 4) + ivec3(cascadeIndex * 6);
      voxel = (texelFetch(uVoxelGridRadiance[textureIndices.x], position, mipMapLevel) * directionWeights.x) +
              (texelFetch(uVoxelGridRadiance[textureIndices.y], position, mipMapLevel) * directionWeights.y) +
              (texelFetch(uVoxelGridRadiance[textureIndices.z], position, mipMapLevel) * directionWeights.z);

      if(length(voxel) > 0.0){
        intersection.dist = time;
        intersection.voxel = voxel / voxel.w;
        return true;
      }

    }
      
    ivec3 mask = ivec3(lessThanEqual(sideDistance.xyz, min(sideDistance.yzx, sideDistance.zxy)));
    sideDistance += sideDistanceStep * mask;
    position += positionStep * mask; 

    vec3 times = (((position - rayOrigin) + vec3(0.5)) - (positionStep * 0.5)) * inversedRayDirection;
    time = fma(max(times.x, max(times.y, times.z)), timeScale, tNearFar.x);
      
  }
 
	return false;    

}


void main(){

  vec3 rayOrigin = inRayOrigin;

  // This normalization is necessary because the vertex shader outputs cubic coordinates which are not normalized. By normalizing the ray direction, 
  // the cubic to spherical conversion is compatible with any projection matrix, independent of the near and far planes and their Z-directions 
  // (e.g. 0 to 1, -1 to 1, 1 to -1 or even 1 to 0) and of perspective or orthographic projection.
  vec3 rayDirection = normalize(inRayDirection);

  const float infinity = uintBitsToFloat(0x7f800000u); // +infinity

  bool hasBestIntersection = false;

  Intersection bestIntersection = { infinity, vec4(0.0) };

  for(uint cascadeIndex = 0u; cascadeIndex < voxelGridData.countCascades; cascadeIndex++){
    Intersection intersection = { infinity, vec4(0.0) };
    if(voxelTrace(int(cascadeIndex), rayOrigin, rayDirection, intersection)){
      if((!hasBestIntersection) || (intersection.dist < bestIntersection.dist)){
        hasBestIntersection = true;
        bestIntersection = intersection;
      }
    }    
  }

  if(hasBestIntersection){
    outFragColor = bestIntersection.voxel;
  }else{
#if defined(USEDEMOTE)
    demote;
#else
    discard;  
#endif
  } 
  
}