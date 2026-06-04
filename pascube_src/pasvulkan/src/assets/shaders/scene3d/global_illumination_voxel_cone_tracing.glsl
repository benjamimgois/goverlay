#ifndef GLOBAL_ILLUMINATION_VOXEL_CONE_TRACING_GLSL
#define GLOBAL_ILLUMINATION_VOXEL_CONE_TRACING_GLSL

/*
layout (set = 1, binding = 8, std140) readonly uniform VoxelGridData {
  #include "voxelgriddata_uniforms.glsl"
} voxelGridData;

layout(set = 1, binding = 9) uniform sampler3D uVoxelGridOcclusion[];

layout(set = 1, binding = 10) uniform sampler3D uVoxelGridRadiance[];
*/

const float CVCT_INDIRECT_DIST_K = 0.01;

// Converts the PBR roughness to a voxel cone tracing aperture angle  
#define CVCT_ROUGHNESSTOVOXELCONETRACINGAPERTUREANGLE_METHOD 0
float cvctRoughnessToVoxelConeTracingApertureAngle(float roughness){
  roughness = clamp(roughness, 0.0, 1.0);
#if ROUGHNESSTOVOXELCONETRACINGAPERTUREANGLE_METHOD == 0
  return tan(0.0003474660443456835 + (roughness * (1.3331290497744692 - (roughness * 0.5040552688878546))));
#elif ROUGHNESSTOVOXELCONETRACINGAPERTUREANGLE_METHOD == 1
  return tan(acos(pow(0.244, 1.0 / (clamp(2.0 / max(1e-4, (roughness * roughness)) - 2.0, 4.0, 1024.0 * 16.0) + 1.0))));
#else
  return clamp(tan((PI * (0.5 * 0.75)) * max(0.0, roughness)), 0.00174533102, 3.14159265359);
#endif  
}              

// Calculate the direction weights for a given direction
#define CVCT_GETDIRECTIONWEIGHTS_METHOD 1
vec3 cvctGetDirectionWeights(vec3 direction){
#if CVCT_GETDIRECTIONWEIGHTS_METHOD == 0
  vec3 d = abs(normalize(direction));
  return d / dot(d, vec3(1.0));
#elif CVCT_GETDIRECTIONWEIGHTS_METHOD == 1
  return abs(direction);
#else
  return direction * direction;
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////

// Calculate the voxel grid position for a given world position in clip space
vec3 cvctWorldToClipSpace(const in vec3 position, const in uint cascadeIndex){
  vec4 cascade = voxelGridData.cascadeCenterHalfExtents[cascadeIndex];
  return (position - cascade.xyz) / cascade.w;
}

// Calculate the voxel grid position for a given world position in texture space
vec3 cvctWorldToTextureSpace(const in vec3 position, const in uint cascadeIndex){
  vec4 cascade = voxelGridData.cascadeCenterHalfExtents[cascadeIndex];
  return fma((position - cascade.xyz) / cascade.w, vec3(0.5), vec3(0.5));
//return (voxelGridData.worldToNormalizedCascades[cascadeIndex] * vec4(position.xyz, 1.0)).xyz; 
}

///////////////////////////////////////////////////////////////////////////////////////////

// Occlusion is isotropic, so we only need to sample one direction

// Fetch a voxel from the voxel grid
float cvctFetchVoxelOcclusion(const in ivec3 position, const in vec3 direction, const in int mipMapLevel, const in int cascadeIndex){
  return texelFetch(uVoxelGridOcclusion[cascadeIndex], position, mipMapLevel).x;
}  

// Fetch a voxel from the voxel grid per trilinear interpolation
float cvctGetTrilinearInterpolatedVoxelOcclusion(const in vec3 position, const in vec3 direction, const in float mipMapLevel, const in int cascadeIndex){
  return textureLod(uVoxelGridOcclusion[cascadeIndex], position, mipMapLevel).x;
}

///////////////////////////////////////////////////////////////////////////////////////////

// Radiance is anisotropic, so we need to sample 3 directions

// Fetch a voxel from the voxel grid
vec4 cvctFetchVoxelRadiance(const in ivec3 position, const in vec3 direction, const in int mipMapLevel, const in int cascadeIndex){
  bvec3 negativeDirection = lessThan(direction, vec3(0.0));
  vec3 directionWeights = cvctGetDirectionWeights(direction);
  ivec3 textureIndices = ivec3(negativeDirection.x ? 1 : 0, negativeDirection.y ? 3 : 2, negativeDirection.z ? 5 : 4) + ivec3(cascadeIndex * 6);
  return (texelFetch(uVoxelGridRadiance[textureIndices.x], position, mipMapLevel) * directionWeights.x) +
         (texelFetch(uVoxelGridRadiance[textureIndices.y], position, mipMapLevel) * directionWeights.y) +
         (texelFetch(uVoxelGridRadiance[textureIndices.z], position, mipMapLevel) * directionWeights.z);
}        

// Fetch a voxel from the voxel grid per trilinear interpolation
vec4 cvctGetTrilinearInterpolatedVoxelRadiance(const in vec3 position, const in vec3 direction, const in float mipMapLevel, const in int cascadeIndex){
  bvec3 negativeDirection = lessThan(direction, vec3(0.0));
  vec3 directionWeights = cvctGetDirectionWeights(direction);
  ivec3 textureIndices = ivec3(negativeDirection.x ? 1 : 0, negativeDirection.y ? 3 : 2, negativeDirection.z ? 5 : 4) + ivec3(cascadeIndex * 6);
  return (textureLod(uVoxelGridRadiance[textureIndices.x], position, mipMapLevel) * directionWeights.x) +
         (textureLod(uVoxelGridRadiance[textureIndices.y], position, mipMapLevel) * directionWeights.y) +
         (textureLod(uVoxelGridRadiance[textureIndices.z], position, mipMapLevel) * directionWeights.z);
}        

///////////////////////////////////////////////////////////////////////////////////////////

// Generate jitter noise for a given position
vec4 cvctVoxelJitterNoise(vec4 p4){
  p4 = fract(p4 * vec4(443.897, 441.423, 437.195, 444.129));
  p4 += dot(p4, p4.wzxy + vec4(19.19));
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}               

// Trace a radiance cone for a given position and direction, and return the accumulated occlusion
vec4 cvctTraceRadianceCone(vec3 from, 
                           vec3 normal,  
                           vec3 direction,
                           float aperture,
                           float offset,
                           float maxDistance){
  
  uint cascadeIndex = 0;

  float voxelSize = voxelGridData.cascadeCellSizes[cascadeIndex >> 2u][cascadeIndex & 3u];
  float oneOverVoxelSize = 1.0 / voxelSize;

  float doubledAperture = 2.0 * aperture;

  float dist = voxelSize;
  float stepDist = dist;

  vec3 startPosition = fma(normal, vec3(voxelSize), from);

  vec3 directionWeights = cvctGetDirectionWeights(direction);
  bvec3 negativeDirection = lessThan(direction, vec3(0.0));  
  ivec3 textureIndices = ivec3(negativeDirection.x ? 1 : 0, negativeDirection.y ? 3 : 2, negativeDirection.z ? 5 : 4);

  vec4 accumulator = vec4(0.0);

  while((dist < maxDistance) && (accumulator.w < 1.0) && (cascadeIndex < voxelGridData.countCascades)){

    vec3 position = fma(direction, vec3(dist), startPosition);

    float diameter = max(voxelSize, doubledAperture * dist);
    float cascadeLOD = clamp(log2(diameter * oneOverVoxelSize), cascadeIndex, float(voxelGridData.countCascades - 1u));
    uint cascadeIndexEx = uint(floor(cascadeLOD));
    float cascadeBlend = fract(cascadeLOD); 

    vec3 cascadePosition = (voxelGridData.worldToCascadeNormalizedMatrices[cascadeIndexEx] * vec4(position.xyz, 1.0)).xyz;
    if(any(lessThan(cascadePosition, vec3(0.0))) || any(greaterThan(cascadePosition, vec3(1.0)))){
      cascadeIndex++;
      continue;
    }

    vec4 value;

    {
      int textureIndexOffset = int(cascadeIndexEx) * 6;
      float mipMapLevel = 0.0; //max(0.0, log2((diameter * worldToCascadeScaleFactors[cascadeIndexEx] * voxelGridData.gridSize) + 1.0));   
      value = ((textureLod(uVoxelGridRadiance[textureIndexOffset + textureIndices.x], cascadePosition, mipMapLevel) * directionWeights.x) +
               (textureLod(uVoxelGridRadiance[textureIndexOffset + textureIndices.y], cascadePosition, mipMapLevel) * directionWeights.y) +
               (textureLod(uVoxelGridRadiance[textureIndexOffset + textureIndices.z], cascadePosition, mipMapLevel) * directionWeights.z));// * (stepDist / voxelSize);
    }

    if((cascadeBlend > 0.0) && ((cascadeIndexEx + 1u) < voxelGridData.countCascades)){
      vec3 cascadePosition = (voxelGridData.worldToCascadeNormalizedMatrices[cascadeIndexEx + 1u] * vec4(position.xyz, 1.0)).xyz;
      int textureIndexOffset = int(cascadeIndexEx + 1u) * 6;
      float mipMapLevel = 0.0; //max(0.0, log2((diameter * worldToCascadeScaleFactors[cascadeIndexEx + 1u] * voxelGridData.gridSize) + 1.0));   
      value = mix(value,
                  ((textureLod(uVoxelGridRadiance[textureIndexOffset + textureIndices.x], cascadePosition, mipMapLevel) * directionWeights.x) +
                   (textureLod(uVoxelGridRadiance[textureIndexOffset + textureIndices.y], cascadePosition, mipMapLevel) * directionWeights.y) +
                   (textureLod(uVoxelGridRadiance[textureIndexOffset + textureIndices.z], cascadePosition, mipMapLevel) * directionWeights.z)),// * (stepDist / voxelSize),
                 cascadeBlend);
    }

    accumulator += value * (1.0 - accumulator.w);

    dist += (stepDist = ((voxelGridData.cascadeCellSizes[cascadeIndexEx >> 2u][cascadeIndexEx & 3u] * 0.5) * diameter)); 

  }

	return max(vec4(0.0), accumulator);
   
}

vec4 cvctTraceCascadeCone(uint cascadeIndex,
                          vec3 coneOrigin, 
                          vec3 coneDirection,
                          float aperture,
                          float offset,
                          float maxDistance){
  
  coneDirection = normalize(coneDirection);                    

  coneOrigin = (voxelGridData.worldToCascadeNormalizedMatrices[cascadeIndex] * vec4(coneOrigin, 1.0)).xyz;

  float worldToCascadeScale = voxelGridData.worldToCascadeScales[cascadeIndex >> 2u][cascadeIndex & 3u];

  float voxelVolumeSize = float(voxelGridData.gridSizes[cascadeIndex >> 2u][cascadeIndex & 3u]); 

  float voxelVolumeInverseSize = 1.0 / voxelVolumeSize;

  offset *= worldToCascadeScale;

  maxDistance *= worldToCascadeScale; 

  vec3 oneOverConeDirection = vec3(1.0) / coneDirection;
  vec3 t0 = (vec3(0.0) - coneOrigin) * oneOverConeDirection;
  vec3 t1 = (vec3(1.0) - coneOrigin) * oneOverConeDirection;
  vec2 tminmax = vec2(
    max(max(min(t0.x, t1.x), min(t0.y, t1.y)), min(t0.z, t1.z)), 
    min(min(max(t0.x, t1.x), max(t0.y, t1.y)), max(t0.z, t1.z))
  );  
  if((tminmax.y < 0.0) || (tminmax.x > tminmax.y)){
    return vec4(0.0);    
  }

  float dist = max(offset, tminmax.x);

  maxDistance = min(maxDistance, tminmax.y);

  float doubledAperture = max(voxelVolumeInverseSize, 2.0 * aperture);
    
  bvec3 negativeDirection = lessThan(coneDirection, vec3(0.0));
  vec3 directionWeights = cvctGetDirectionWeights(coneDirection);
  ivec3 textureIndices = ivec3(
    negativeDirection.x ? 1 : 0, 
    negativeDirection.y ? 3 : 2, 
    negativeDirection.z ? 5 : 4
  ) + ivec3(int(cascadeIndex) * 6);

  vec4 accumulator = vec4(0.0);      

  while((dist < maxDistance) && (accumulator.w < 1.0)){
    vec3 position = coneOrigin + (dist * coneDirection);
    float diameter = max(voxelVolumeInverseSize * 0.5, doubledAperture * dist);
    float mipMapLevel = max(0.0, log2((diameter * float(voxelVolumeSize)) + 0.0));   
    vec4 voxel = (textureLod(uVoxelGridRadiance[textureIndices.x], position, mipMapLevel) * directionWeights.x) +
                 (textureLod(uVoxelGridRadiance[textureIndices.y], position, mipMapLevel) * directionWeights.y) +
                 (textureLod(uVoxelGridRadiance[textureIndices.z], position, mipMapLevel) * directionWeights.z);
  	accumulator += (1.0 - accumulator.w) * voxel;     
		dist += max(diameter, voxelVolumeInverseSize);
	}

	return max(vec4(0.0), accumulator);

}

vec4 cvctTraceRadianceCone(vec3 from, 
                           vec3 direction,
                           float aperture,
                           float offset,
                           float maxDistance){
 
  // Calculate the doubled aperture angle for the cone
  float doubledAperture = max(voxelGridData.oneOverGridSizes[0][0], 2.0 * aperture);

  // Set the starting distance
  float dist = offset;
  
  direction = normalize(direction);                    

  // Setup the texture indices and direction weights
  bvec3 negativeDirection = lessThan(direction, vec3(0.0));  
  vec3 directionWeights = cvctGetDirectionWeights(direction);
  
  //maxDistance = min(maxDistance, 1.41421356237);
  //dist += cvctVoxelJitterNoise(vec4(from.xyz + to.xyz + normal.xyz, 0.0)).x * s;

  vec3 currentCascadeAAABMin = vec3(uintBitsToFloat(0x7f800000u)); // +inf
  vec3 currentCascadeAAABMax = vec3(uintBitsToFloat(0xff800000u)); // -inf

  int cascadeIndex = -1;

  // Initialize the accumulator to zero, since we start at the beginning of the cone
  vec4 accumulator = vec4(0.0);                       

  // The actual tracing loop
  while((accumulator.w < 1.0) && (dist < maxDistance)){
    
    // Get the new position
    vec3 position = from + (direction * dist);

    // Check if we are still in the current clipmap
    if((cascadeIndex < 0) || any(lessThan(position, currentCascadeAAABMin)) || any(greaterThan(position, currentCascadeAAABMax))){

      // If not, find the next clipmap
      cascadeIndex = -1;
      for(uint cascadeIndexCounter = 0, countCascades = voxelGridData.countCascades; cascadeIndexCounter < countCascades; cascadeIndexCounter++){
        if(all(greaterThanEqual(position, voxelGridData.cascadeAABBMin[cascadeIndexCounter].xyz)) && 
           all(lessThanEqual(position, voxelGridData.cascadeAABBMax[cascadeIndexCounter].xyz))){
          cascadeIndex = int(cascadeIndexCounter);
          currentCascadeAAABMin = voxelGridData.cascadeAABBMin[cascadeIndex].xyz;
          currentCascadeAAABMax = voxelGridData.cascadeAABBMax[cascadeIndex].xyz;
          break;
        }
      }

      // If we didn't find a clipmap anymore, we are done and can break out of the loop
      if(cascadeIndex < 0){
        break;
      }

    }

    // Calculate the diameter of the cone at the current position 
    float diameter = max(voxelGridData.oneOverGridSizes[cascadeIndex >> 2u][cascadeIndex & 3u] * 0.5, doubledAperture * (dist * voxelGridData.worldToCascadeScales[cascadeIndex >> 2u][cascadeIndex & 3u]));

    // Calculate the mip map level to use for the current position
    float mipMapLevel = max(0.0, log2((diameter * voxelGridData.gridSizes[cascadeIndex >> 2u][cascadeIndex & 3u])));   

    // Calculate the texture position
    vec3 cascadePosition = cvctWorldToTextureSpace(position, uint(cascadeIndex));

    // Accumulate the occlusion from the ansitropic radiance texture, where the ansitropic occlusion is stored in the alpha channel
    ivec3 textureIndices = ivec3(negativeDirection.x ? 1 : 0, negativeDirection.y ? 3 : 2, negativeDirection.z ? 5 : 4) + ivec3(cascadeIndex * 6);
    accumulator += (1.0 - accumulator) * ((textureLod(uVoxelGridRadiance[textureIndices.x], cascadePosition, mipMapLevel) * directionWeights.x) +
                                          (textureLod(uVoxelGridRadiance[textureIndices.y], cascadePosition, mipMapLevel) * directionWeights.y) +
                                          (textureLod(uVoxelGridRadiance[textureIndices.z], cascadePosition, mipMapLevel) * directionWeights.z));

    // Move the position forward
    dist += max(diameter, voxelGridData.oneOverGridSizes[cascadeIndex >> 2u][cascadeIndex & 3u]) * voxelGridData.cascadeToWorldScales[cascadeIndex >> 2u][cascadeIndex & 3u];

  } 

  // Return the accumulated value
  return accumulator;

}	

// Create a rotation matrix from an axis and an angle
mat3 cvctRotationMatrix(vec3 axis, float angle){
  axis = normalize(axis);
  vec2 sc = sin(vec2(angle) + vec2(0.0, 1.57079632679)); // sin and cos
  float oc = 1.0 - sc.y;    
  vec3 as = axis * sc.x;
  return (mat3(axis.x * axis,
               axis.y * axis,
               axis.z * axis) * oc) + 
          mat3(sc.y, -as.z,
               as.y, as.z,
               sc.y, -as.x,
               -as.y, 
               as.x,
               sc.y);                
}                     

// Calculate the radiance for a starting position and a direction
vec4 cvctIndirectDiffuseLight(vec3 from, 
                              vec3 normal){
#ifndef NUM_CONES 
 #define NUM_CONES 5
#endif
//$define indirectDiffuseLightJitter
#if NUM_CONES == 9
  const float angleMix = 0.5, 
              coneOffset = -0.01,
              aperture = tan(radians(22.5)),
              offset = 4.0 * voxelGridData.cascadeCellSizes[0][0],
              maxDistance = 2.0 * voxelGridData.cellSizes[(voxelGridData.cascadeCountCascades - 1) >> 2][(voxelGridData.cascadeCountCascades - 1) & 3] * float(voxelGridData.gridSizes[(voxelGridData.cascadeCountCascades - 1) >> 2][(voxelGridData.cascadeCountCascades - 1) & 3]);
  vec3 u = normalize(normal),
#if 0
       v = cross(vec3(0.0, 1.0, 0.0), u),
       w = cross(vec3(0.0, 0.0, 1.0), u),
       ortho = normalize((length(v) < length(w)) ? w : v),
#else
       v = normalize(vec3(0.99146, 0.11664, 0.05832)),
       ortho = normalize((abs(dot(u, v)) > 0.99999) ? cross(vec3(0.0, 1.0, 0.0), u) : cross(v, u)),
#endif
       ortho2 = normalize(cross(ortho, normal)),
       corner = 0.5 * (ortho + ortho2), 
       corner2 = 0.5 * (ortho - ortho2);
  vec3 normalOffset = normal * (1.0 + (4.0 * 0.70710678118)) * voxelGridData.cascadeCellSizes[0][0], 
       coneOrigin = from + normalOffset;       
  return ((cvctTraceRadianceCone(coneOrigin + (coneOffset * normal), normal, aperture, offset, maxDistance) * 1.0) +
           ((cvctTraceRadianceCone(coneOrigin + (coneOffset * ortho), mix(normal, ortho, angleMix), aperture, offset, maxDistance) +
             cvctTraceRadianceCone(coneOrigin - (coneOffset * ortho), mix(normal, -ortho, angleMix), aperture, offset, maxDistance) +
             cvctTraceRadianceCone(coneOrigin + (coneOffset * ortho2), mix(normal, ortho2, angleMix), aperture, offset, maxDistance) +
             cvctTraceRadianceCone(coneOrigin - (coneOffset * ortho2), mix(normal, -ortho2, angleMix), aperture, offset, maxDistance)) * 1.0) +
           ((cvctTraceRadianceCone(coneOrigin + (coneOffset * corner), mix(normal, corner, angleMix), aperture, offset, maxDistance) +
             cvctTraceRadianceCone(coneOrigin - (coneOffset * corner), mix(normal, -corner, angleMix), aperture, offset, maxDistance) +
             cvctTraceRadianceCone(coneOrigin + (coneOffset * corner2), mix(normal, corner2, angleMix), aperture, offset, maxDistance) +
             cvctTraceRadianceCone(coneOrigin - (coneOffset * corner2), mix(normal, -corner2, angleMix), aperture, offset, maxDistance)) * 1.0)) / 9.0;
#else
#if NUM_CONES == 1
  const vec3 coneDirections[1] = vec3[1](
                                   vec3(0.0, 0.0, 1.0)
                                 );  
  const float coneWeights[1] = float[1](
                                 1.0
                               );  
  const float coneApertures[1] = float[1]( // tan(63.4349488)
                                   2.0
                                 );  
#elif NUM_CONES == 5
  const vec3 coneDirections[5] = vec3[5](
                                   vec3(0.0, 0.0, 1.0),
                                   vec3(0.0, 0.707106781, 0.707106781),
                                   vec3(0.0, -0.707106781, 0.707106781),
                                   vec3(0.707106781, 0.0, 0.707106781),
                                   vec3(-0.707106781, 0.0, 0.707106781)
                                 );  
  const float coneWeights[5] = float[5](
                                 0.28, 
                                 0.18, 
                                 0.18, 
                                 0.18, 
                                 0.18
                               );  
  const float coneApertures[5] = float[5]( // tan(45)
                                   1.0, 
                                   1.0, 
                                   1.0, 
                                   1.0, 
                                   1.0 
                                 );  
#elif NUM_CONES == 6
#if 0
  const vec3 coneDirections[6] = vec3[6](
                                   normalize(vec3(0.0, 0.0, 1.0)),
                                   normalize(vec3(-0.794654, 0.607062, 0.000000)),
                                   normalize(vec3(0.642889, 0.607062, 0.467086)), 
                                   normalize(vec3(0.642889, 0.607062, -0.467086)),
                                   normalize(vec3(-0.245562, 0.607062, 0.755761)),
                                   normalize(vec3(-0.245562, 0.607062, -0.755761))
                                 );  
  const float coneWeights[6] = float[6](
                                 1.0, 
                                 0.607,
                                 0.607, 
                                 0.607, 
                                 0.607, 
                                 0.607
                               );  
  const float coneApertures[6] = float[6]( 
                                   0.5, 
                                   0.549092, 
                                   0.549092, 
                                   0.549092, 
                                   0.549092, 
                                   0.549092
                                 );  
#else
  const vec3 coneDirections[6] = vec3[6](
                                   vec3(0.0, 0.0, 1.0),
                                   vec3(0.0, 0.866025, 0.5),
                                   vec3(0.823639, 0.267617, 0.5),
                                   vec3(0.509037, -0.700629, 0.5),
                                   vec3(-0.509037, -0.700629, 0.5),
                                   vec3(-0.823639, 0.267617, 0.5)
                                 );  
  const float coneWeights[6] = float[6](
#if 0
                                 3.14159 * 0.25, 
                                 (3.14159 * 3.0) / 20.0, 
                                 (3.14159 * 3.0) / 20.0, 
                                 (3.14159 * 3.0) / 20.0, 
                                 (3.14159 * 3.0) / 20.0, 
                                 (3.14159 * 3.0) / 20.0
#else
                                 0.25, 
                                 0.15,
                                 0.15, 
                                 0.15, 
                                 0.15, 
                                 0.15
#endif
                               );  
  const float coneApertures[6] = float[6]( // tan(30)
                                   0.57735026919, 
                                   0.57735026919, 
                                   0.57735026919, 
                                   0.57735026919, 
                                   0.57735026919, 
                                   0.57735026919 
                                 );  
#endif
#elif NUM_CONES == 8
  const vec3 coneDirections[8] = vec3[8](
                                    vec3(0.57735, 0.57735, 0.57735),      
                                    vec3(-0.57735, -0.57735, 0.57735),     
                                    vec3(-0.903007, 0.182696, 0.388844),    
                                    vec3(0.903007, -0.182696, 0.388844),     
                                    vec3(0.388844, -0.903007, 0.182696),      
                                    vec3(-0.388844, 0.903007, 0.182696),       
                                    vec3(-0.182696, 0.388844, 0.903007),        
                                    vec3(0.182696, -0.388844, 0.903007)          
                                  );  
  const float coneWeights[8] = float[8](
                                 1.0 / 8.0, 
                                 1.0 / 8.0, 
                                 1.0 / 8.0, 
                                 1.0 / 8.0, 
                                 1.0 / 8.0, 
                                 1.0 / 8.0, 
                                 1.0 / 8.0, 
                                 1.0 / 8.0
                               );  
  const float coneApertures[8] = float[8]( 
                                   0.4363325, 
                                   0.4363325, 
                                   0.4363325, 
                                   0.4363325, 
                                   0.4363325, 
                                   0.4363325, 
                                   0.4363325, 
                                   0.4363325
                                 );  
#elif NUM_CONES == 16
  const vec3 coneDirections[16] = vec3[16](
                                    vec3(0.898904, 0.435512, 0.0479745),
                                    vec3(0.898904, -0.0479745, 0.435512),
                                    vec3(-0.898904, -0.435512, 0.0479745),
                                    vec3(-0.898904, 0.0479745, 0.435512),
                                    vec3(0.0479745, 0.898904, 0.435512),
                                    vec3(-0.435512, 0.898904, 0.0479745),
                                    vec3(-0.0479745, -0.898904, 0.435512),
                                    vec3(0.435512, -0.898904, 0.0479745),
                                    vec3(0.435512, 0.0479745, 0.898904),
                                    vec3(-0.435512, -0.0479745, 0.898904),
                                    vec3(0.0479745, -0.435512, 0.898904),
                                    vec3(-0.0479745, 0.435512, 0.898904),
                                    vec3(0.57735, 0.57735, 0.57735),
                                    vec3(0.57735, -0.57735, 0.57735),
                                    vec3(-0.57735, 0.57735, 0.57735),
                                    vec3(-0.57735, -0.57735, 0.57735)
                                  );  
  const float coneWeights[16] = float[16](
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0, 
                                  1.0 / 16.0
                                );  
  const float coneApertures[16] = float[16]( 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595, 
                                    0.3141595
                                 );  
#endif
  const float coneOffset = -0.01,
              offset = 1.0 * voxelGridData.cascadeCellSizes[0][0],
              maxDistance = 2.0 * voxelGridData.cascadeCellSizes[(voxelGridData.countCascades - 1) >> 2][(voxelGridData.countCascades - 1) & 3] * float(voxelGridData.gridSizes[(voxelGridData.countCascades - 1) >> 2][(voxelGridData.countCascades - 1) & 3]);
  normal = normalize(normal);
  vec3 normalOffset = normal * (1.0 + (1.0 * 0.70710678118)) * voxelGridData.cascadeCellSizes[0][0], 
       coneOrigin = from + normalOffset,
       t0 = cross(vec3(0.0, 1.0, 0.0), normal),
       t1 = cross(vec3(0.0, 0.0, 1.0), normal),
       tangent = normalize((length(t0) < length(t1)) ? t1 : t0),
       bitangent = normalize(cross(tangent, normal));
  tangent = normalize(cross(bitangent, normal));      
  mat3 tangentSpace =
#ifdef CVCT_INDIRECT_DIRECT_LIGHT_JITTER
                      cvctRotationMatrix(normal, cvctVoxelJitterNoise(vec4(from + normal, 0.0)).x) *
#endif
                      mat3(tangent, 
                           bitangent, 
                           normal);
  vec4 color = vec4(0.0);
  float weightSum = 0.0;
  [[unroll]] for(int i = 0; i < NUM_CONES; i++){
    vec3 direction = tangentSpace * coneDirections[i].xyz;
/*  if(dot(direction, tangentSpace[2]) >= 0.0)*/{
      color += cvctTraceRadianceCone(coneOrigin + (coneOffset * direction), 
                                     //normal,
                                     direction, 
                                     coneApertures[i], 
                                     offset, 
                                     maxDistance) * coneWeights[i];
      weightSum += coneWeights[i]; 
    }
  }
  return color / max(weightSum, 1e-6);
#endif
}

// Calculate the specular light for a starting position, a normal, the view direction, the aperture angle and the maximal distance
vec3 cvctIndirectSpecularLight(vec3 from, 
                               vec3 normal, 
                               vec3 viewDirection,
                               float aperture, 
                               float maxDistance){
  normal = normalize(normal);
  return cvctTraceRadianceCone(from + (normal * 2.0 * voxelGridData.cascadeCellSizes[0][0]), 
                               //normal,  
                               normalize(reflect(normalize(viewDirection), normal)), 
                               aperture, 
                               2.0 * voxelGridData.cascadeCellSizes[0][0], 
                               maxDistance).xyz;
}

// Calculate the refractive light for a starting position, a normal, the view direction, the aperture angle, the index of refraction and the maximal distance
vec3 cvctIndirectRefractiveLight(vec3 from, 
                                 vec3 normal, 
                                 vec3 viewDirection, 
                                 float aperture, 
                                 float indexOfRefraction, 
                                 float maxDistance){
  normal = normalize(normal);
  return cvctTraceRadianceCone(from + (normal * voxelGridData.cascadeCellSizes[0][0]), 
                               //normal,
                               normalize(refract(normalize(viewDirection), normal, 1.0 / indexOfRefraction)), 
                               aperture, 
                               voxelGridData.cascadeCellSizes[0][0], 
                               maxDistance).xyz;
}                                   

vec4 cvctGlobalIlluminationCascadeVisualizationColor(const vec3 worldPosition){
  uint cascadeIndex = 0u, countCascades = voxelGridData.countCascades;      
  while(((cascadeIndex + 1u) < countCascades) &&
        (any(lessThan(worldPosition, voxelGridData.cascadeAABBMin[cascadeIndex].xyz)) ||
         any(greaterThan(worldPosition, voxelGridData.cascadeAABBMax[cascadeIndex].xyz)))){
    cascadeIndex++;
  }
  vec4 color = vec4(0.0);
  if((cascadeIndex >= 0u) && (cascadeIndex < countCascades)){
    vec4 colors[4] = vec4[4](
      vec4(0.125, 0.0, 0.0, 1.0),
      vec4(0.0, 0.125, 0.0, 1.0),
      vec4(0.0, 0.0, 0.125, 1.0),
      vec4(0.125, 0.125, 0.0, 1.0)      
    ); 
    float current = 1.0;    
    for(uint currentCascadeIndex = cascadeIndex; currentCascadeIndex < countCascades; currentCascadeIndex++){
      if(currentCascadeIndex == (countCascades - 1u)){
        color += colors[currentCascadeIndex] * current; 
        break;
      }else if(all(greaterThanEqual(worldPosition, voxelGridData.cascadeAABBMin[currentCascadeIndex].xyz)) &&
               all(lessThanEqual(worldPosition, voxelGridData.cascadeAABBMax[currentCascadeIndex].xyz))){
        vec3 aabbFadeDistances = smoothstep(voxelGridData.cascadeAABBFadeStart[currentCascadeIndex].xyz, 
                                            voxelGridData.cascadeAABBFadeEnd[currentCascadeIndex].xyz, 
                                            abs(worldPosition.xyz - voxelGridData.cascadeCenterHalfExtents[currentCascadeIndex].xyz));
        float factor = 1.0 - clamp(max(max(aabbFadeDistances.x, aabbFadeDistances.y), aabbFadeDistances.z), 0.0, 1.0);
        color += colors[currentCascadeIndex] * (current * factor); 
        current *= 1.0 - factor;
        if(current < 1e-6){
          break;
        }
      }else{
        break;
      }
    }   
  }
  return color;
}

#endif // GLOBAL_ILLUMINATION_VOXEL_CONE_TRACING_GLSL