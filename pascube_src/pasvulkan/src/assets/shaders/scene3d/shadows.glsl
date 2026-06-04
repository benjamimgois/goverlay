#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL 

#ifdef SHADOWS

#ifdef PCFPCSS

#ifndef UseReceiverPlaneDepthBias
#define UseReceiverPlaneDepthBias
#endif

#undef UseReceiverPlaneDepthBias // because it seems to crash Intel iGPUs   

#ifdef UseReceiverPlaneDepthBias
vec4 cascadedShadowMapPositions[NUM_SHADOW_CASCADES];
#endif

vec2 shadowMapSize;

vec3 shadowMapTexelSize;

const int SHADOW_TAP_COUNT = 16;

const vec2 PoissonDiskSamples[16] = vec2[](
  vec2(-0.94201624, -0.39906216), 
  vec2(0.94558609, -0.76890725), 
  vec2(-0.094184101, -0.92938870), 
  vec2(0.34495938, 0.29387760), 
  vec2(-0.91588581, 0.45771432), 
  vec2(-0.81544232, -0.87912464), 
  vec2(-0.38277543, 0.27676845), 
  vec2(0.97484398, 0.75648379), 
  vec2(0.44323325, -0.97511554), 
  vec2(0.53742981, -0.47373420), 
  vec2(-0.26496911, -0.41893023), 
  vec2(0.79197514, 0.19090188), 
  vec2(-0.24188840, 0.99706507), 
  vec2(-0.81409955, 0.91437590), 
  vec2(0.19984126, 0.78641367), 
  vec2(0.14383161, -0.14100790)
);

#ifdef UseReceiverPlaneDepthBias

vec2 shadowPositionReceiverPlaneDepthBias;

vec2 computeReceiverPlaneDepthBias(const vec3 position) {
  // see: GDC '06: Shadow Mapping: GPU-based Tips and Techniques
  // Chain rule to compute dz/du and dz/dv
  // |dz/du|   |du/dx du/dy|^-T   |dz/dx|
  // |dz/dv| = |dv/dx dv/dy|    * |dz/dy|
  vec3 duvz_dx = dFdx(position);
  vec3 duvz_dy = dFdy(position);
  vec2 dz_duv = inverse(transpose(mat2(duvz_dx.xy, duvz_dy.xy))) * vec2(duvz_dx.z, duvz_dy.z);
  return (any(isnan(dz_duv.xy)) || any(isinf(dz_duv.xy))) ? vec2(0.0) : dz_duv;
}

#endif

vec3 getOffsetedBiasedWorldPositionForShadowMapping(const in vec4 values, const in vec3 lightDirection){
  vec3 worldSpacePosition = inWorldSpacePosition;
  {
    vec3 worldSpaceNormal = workNormal;
    float cos_alpha = clamp(dot(worldSpaceNormal, lightDirection), 0.0, 1.0);
    float offset_scale_N = sqrt(1.0 - (cos_alpha * cos_alpha));   // sin(acos(L·N))
    float offset_scale_L = offset_scale_N / max(5e-4, cos_alpha); // tan(acos(L·N))
    vec2 offsets = fma(vec2(offset_scale_N, min(2.0, offset_scale_L)), vec2(values.yz), vec2(0.0, values.x));
    if(values.w > 1e-6){
      offsets.xy = clamp(offsets.xy, vec2(-values.w), vec2(values.w));
    }
    worldSpacePosition += (worldSpaceNormal * offsets.x) + (lightDirection * offsets.y);
  } 
  return worldSpacePosition;  
}

float CalculatePenumbraRatio(const in float zReceiver, const in float zBlocker, const in float nearOverFarMinusNear) {
#if 1
  return (zBlocker - zReceiver) / (1.0 - zBlocker);
#else
  return ((nearOverFarMinusNear + z_blocker) / (nearOverFarMinusNear + z_receiver)) - 1.0;
#endif
}

float doPCFSample(const in sampler2DArrayShadow shadowMapArray, const in vec3 pBaseUVS, const in float pU, const in float pV, const in float pZ, const in vec2 pShadowMapSizeInv){
#ifdef UseReceiverPlaneDepthBias  
  vec2 offset = vec2(pU, pV) * pShadowMapSizeInv;
  return texture(shadowMapArray, vec4(pBaseUVS + vec3(offset, 0.0), pZ + dot(offset, shadowPositionReceiverPlaneDepthBias)));
#else
  return texture(shadowMapArray, vec4(pBaseUVS + vec3(vec2(vec2(pU, pV) * pShadowMapSizeInv), 0.0), pZ));
#endif
}

float DoPCF(const in sampler2DArrayShadow shadowMapArray,
            const in int cascadedShadowMapIndex,
            const in vec4 shadowMapPosition){
#define OptimizedPCFFilterSize 7
#if OptimizedPCFFilterSize != 2
  
  vec2 shadowMapUV = shadowMapPosition.xy * shadowMapSize;

  vec3 shadowMapBaseUVS = vec3(floor(shadowMapUV + vec2(0.5)), floor(cascadedShadowMapIndex + 0.5));

  float shadowMapS = (shadowMapUV.x + 0.5) - shadowMapBaseUVS.x;
  float shadowMapT = (shadowMapUV.y + 0.5) - shadowMapBaseUVS.y;

  shadowMapBaseUVS.xy = (shadowMapBaseUVS.xy - vec2(0.5)) * shadowMapTexelSize.xy;
#endif
  float shadowMapSum = 0.0;
#if OptimizedPCFFilterSize == 2
  shadowMapSum = doPCFSample(shadowMapArray, vec3(shadowMapPosition.xy, float(pShadowMapSlice)), 0.0, 0.0, shadowMapPosition.z, vec2(0.0));
#elif OptimizedPCFFilterSize == 3

  float shadowMapBaseUW0 = 3.0 - (2.0 * shadowMapS);
  float shadowMapBaseUW1 = 1.0 + (2.0 * shadowMapS);

  float shadowMapBaseU0 = ((2.0 - shadowMapS) / shadowMapBaseUW0) - 1.0;
  float shadowMapBaseU1 = (shadowMapS / shadowMapBaseUW1) + 1.0;

  float shadowMapBaseVW0 = 3.0 - (2.0 * shadowMapT);
  float shadowMapBaseVW1 = 1.0 + (2.0 * shadowMapT);

  float shadowMapBaseV0 = ((2.0 - shadowMapT) / shadowMapBaseVW0) - 1.0;
  float shadowMapBaseV1 = (shadowMapT / shadowMapBaseVW1) + 1.0;

  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);

  shadowMapSum *= 1.0 / 16.0;
#elif OptimizedPCFFilterSize == 5

  float shadowMapBaseUW0 = 4.0 - (3.0 * shadowMapS);
  float shadowMapBaseUW1 = 7.0;
  float shadowMapBaseUW2 = 1.0 + (3.0 * shadowMapS);

  float shadowMapBaseU0 = ((3.0 - (2.0 * shadowMapS)) / shadowMapBaseUW0) - 2.0;
  float shadowMapBaseU1 = (3.0 + shadowMapS) / shadowMapBaseUW1;
  float shadowMapBaseU2 = (shadowMapS / shadowMapBaseUW2) + 2.0;

  float shadowMapBaseVW0 = 4.0 - (3.0 * shadowMapT);
  float shadowMapBaseVW1 = 7.0;
  float shadowMapBaseVW2 = 1.0 + (3.0 * shadowMapT);

  float shadowMapBaseV0 = ((3.0 - (2.0 * shadowMapT)) / shadowMapBaseVW0) - 2.0;
  float shadowMapBaseV1 = (3.0 + shadowMapT) / shadowMapBaseVW1;
  float shadowMapBaseV2 = (shadowMapT / shadowMapBaseVW2) + 2.0;

  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW2 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU2, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);

  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW2 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU2, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);

  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW2) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV2, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW2) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV2, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW2 * shadowMapBaseVW2) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU2, shadowMapBaseV2, shadowMapPosition.z, shadowMapTexelSize.xy);

  shadowMapSum *= 1.0 / 144.0;

#elif OptimizedPCFFilterSize == 7

  float shadowMapBaseUW0 = (5.0 * shadowMapS) - 6;
  float shadowMapBaseUW1 = (11.0 * shadowMapS) - 28.0;
  float shadowMapBaseUW2 = -((11.0 * shadowMapS) + 17.0);
  float shadowMapBaseUW3 = -((5.0 * shadowMapS) + 1.0);

  float shadowMapBaseU0 = ((4.0 * shadowMapS) - 5.0) / shadowMapBaseUW0 - 3.0;
  float shadowMapBaseU1 = ((4.0 * shadowMapS) - 16.0) / shadowMapBaseUW1 - 1.0;
  float shadowMapBaseU2 = (-(((7.0 * shadowMapS) + 5.0)) / shadowMapBaseUW2) + 1.0;
  float shadowMapBaseU3 = (-(shadowMapS / shadowMapBaseUW3)) + 3.0;

  float shadowMapBaseVW0 = ((5.0 * shadowMapT) - 6.0);
  float shadowMapBaseVW1 = ((11.0 * shadowMapT) - 28.0);
  float shadowMapBaseVW2 = -((11.0 * shadowMapT) + 17.0);
  float shadowMapBaseVW3 = -((5.0 * shadowMapT) + 1.0);

  float shadowMapBaseV0 = (((4.0 * shadowMapT) - 5.0) / shadowMapBaseVW0) - 3.0;
  float shadowMapBaseV1 = (((4.0 * shadowMapT) - 16.0) / shadowMapBaseVW1) - 1.0;
  float shadowMapBaseV2 = ((-((7.0 * shadowMapT) + 5)) / shadowMapBaseVW2) + 1.0;
  float shadowMapBaseV3 = (-(shadowMapT / shadowMapBaseVW3)) + 3.0;

  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW2 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU2, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW3 * shadowMapBaseVW0) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU3, shadowMapBaseV0, shadowMapPosition.z, shadowMapTexelSize.xy);

  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW2 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU2, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW3 * shadowMapBaseVW1) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU3, shadowMapBaseV1, shadowMapPosition.z, shadowMapTexelSize.xy);

  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW2) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV2, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW2) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV2, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW2 * shadowMapBaseVW2) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU2, shadowMapBaseV2, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW3 * shadowMapBaseVW2) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU3, shadowMapBaseV2, shadowMapPosition.z, shadowMapTexelSize.xy);

  shadowMapSum += (shadowMapBaseUW0 * shadowMapBaseVW3) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU0, shadowMapBaseV3, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW1 * shadowMapBaseVW3) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU1, shadowMapBaseV3, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW2 * shadowMapBaseVW3) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU2, shadowMapBaseV3, shadowMapPosition.z, shadowMapTexelSize.xy);
  shadowMapSum += (shadowMapBaseUW3 * shadowMapBaseVW3) * doPCFSample(shadowMapArray, shadowMapBaseUVS, shadowMapBaseU3, shadowMapBaseV3, shadowMapPosition.z, shadowMapTexelSize.xy);

  shadowMapSum *= 1.0 / 2704.0;

#endif

  return 1.0 - clamp(shadowMapSum, 0.0, 1.0);
}
                                
float ContactHardenPCFKernel(const float occluders,
                             const float occluderDistSum,
                             const float lightDistanceNormalized,
                             const float mul){

  if(occluderDistSum == 0.0){
    return 1.0;
  }else{

    float occluderAvgDist = occluderDistSum / occluders;

    float w = 1.0 / (mul * SHADOW_TAP_COUNT);

    float pcfWeight = clamp(occluderAvgDist / max(1e-6, lightDistanceNormalized), 0.0, 1.0);

    float percentageOccluded = clamp(occluders * w, 0.0, 1.0);

    percentageOccluded = fma(percentageOccluded, 2.0, -1.0);
    float occludedSign = sign(percentageOccluded);
    percentageOccluded = fma(percentageOccluded, -occludedSign, 1.0);

    return 1.0 - fma((1.0 - mix(percentageOccluded * percentageOccluded * percentageOccluded, percentageOccluded, pcfWeight)) * occludedSign, 0.5, 0.5);

  }  
}

float DoDPCF_PCSS(const in sampler2DArray shadowMapArray, 
                  const in int cascadedShadowMapIndex,
                  const in vec4 shadowPosition,
                  const in bool DPCF){

  float rotationAngle; 
  {
    const uint k = 1103515245u;
#if defined(NOTEXCOORDS)
    uvec3 v = uvec3(floatBitsToUint(inWorldSpacePosition.xy), uint(inFrameIndex)) ^ uvec3(0u, uvec2(gl_FragCoord.xy)); 
#else    
    uvec3 v = uvec3(floatBitsToUint(inTexCoord0.xy), uint(inFrameIndex)) ^ uvec3(0u, uvec2(gl_FragCoord.xy)); 
#endif
    v = ((v >> 8u) ^ v.yzx) * k;
    v = ((v >> 8u) ^ v.yzx) * k;
    v = ((v >> 8u) ^ v.yzx) * k;
    rotationAngle = ((uintBitsToFloat(uint(uint(((v.x >> 9u) & uint(0x007fffffu)) | uint(0x3f800000u))))) - 1.0) * 6.28318530718;    
  }
  vec2 rotation = vec2(sin(rotationAngle + vec2(0.0, 1.57079632679)));
  mat2 rotationMatrix = mat2(rotation.y, rotation.x, -rotation.x, rotation.y);
  
  float occluders = 0.0;  
  float occluderDistSum = 0.0;
  
  vec2 penumbraSize = uCascadedShadowMaps.shadowMapSplitDepthsScales[cascadedShadowMapIndex].w * shadowMapTexelSize.xy;

#if 0
  const float countFactor = 1.0;
  for(int tapIndex = 0; tapIndex < SHADOW_TAP_COUNT; tapIndex++){
    vec2 offset = PoissonDiskSamples[tapIndex] * rotationMatrix * penumbraSize;
    vec2 uv = shadowPosition.xy + offset;
    float sampleDepth = textureLod(shadowMapArray, vec3(uv, float(cascadedShadowMapIndex)), 0.0).x;
    float sampleDistance = sampleDepth - shadowPosition.z;
#ifdef UseReceiverPlaneDepthBias
    float sampleOccluder = step(dot(offset, shadowPositionReceiverPlaneDepthBias), sampleDistance);
#else
    float sampleOccluder = step(0.0, sampleDistance);
#endif
    occluders += sampleOccluder;
    occluderDistSum += sampleDistance * sampleOccluder;
  }
#else  
  const float countFactor = 4.0;
  for(int tapIndex = 0; tapIndex < SHADOW_TAP_COUNT; tapIndex++){
    vec2 offset = PoissonDiskSamples[tapIndex] * rotationMatrix * penumbraSize;
    vec4 samples = textureGather(shadowMapArray, vec3(shadowPosition.xy + offset, float(cascadedShadowMapIndex)), 0); // 01, 11, 10, 00  
    vec4 sampleDistances = samples - vec4(shadowPosition.z);
#ifdef UseReceiverPlaneDepthBias
    vec4 sampleOccluders = step(vec4(dot(offset + shadowMapTexelSize.zy, shadowPositionReceiverPlaneDepthBias),      // 01
                                     dot(offset + shadowMapTexelSize.xy, shadowPositionReceiverPlaneDepthBias),      // 11
                                     dot(offset + shadowMapTexelSize.xz, shadowPositionReceiverPlaneDepthBias),      // 10
                                     dot(offset, shadowPositionReceiverPlaneDepthBias)), sampleDistances);  // 00
#else
    vec4 sampleOccluders = step(0.0, sampleDistances);
#endif
    occluders += dot(sampleOccluders, vec4(1.0));
    occluderDistSum += dot(sampleDistances * sampleOccluders, vec4(1.0));
  }
#endif

  if(occluderDistSum == 0.0){
    return 0.0;
  }else{

    float penumbraRatio = CalculatePenumbraRatio(shadowPosition.z, occluderDistSum / occluders, 0.0);
    
    if(DPCF){

      // DPCF
      
      penumbraRatio = clamp(penumbraRatio, 0.0, 1.0);

      float percentageOccluded = occluders * (1.0 / (SHADOW_TAP_COUNT * countFactor));

      percentageOccluded = fma(percentageOccluded, 2.0, -1.0);
      float occludedSign = sign(percentageOccluded);
      percentageOccluded = fma(percentageOccluded, -occludedSign, 1.0);

      return fma((1.0 - mix(percentageOccluded * percentageOccluded * percentageOccluded, percentageOccluded, penumbraRatio)) * occludedSign, 0.5, 0.5);

    //return 1.0 - ContactHardenPCFKernel(occluders, occluderDistSum, shadowPosition.z, countFactor);

    }else{

      // PCSS

      penumbraSize *= CalculatePenumbraRatio(shadowPosition.z, occluderDistSum / occluders, 0.0);

      float occludedCount = 0.0;

      for(int tapIndex = 0; tapIndex < SHADOW_TAP_COUNT; tapIndex++){
        vec2 offset = PoissonDiskSamples[tapIndex] * rotationMatrix * penumbraSize;
        vec2 position = shadowPosition.xy + offset;
        vec2 gradient = fract((position * shadowMapSize) - 0.5);
        vec4 samples = textureGather(shadowMapArray, vec3(position, float(cascadedShadowMapIndex)), 0); // 01, 11, 10, 00  
        vec4 sampleDistances = samples - vec4(shadowPosition.z);
#ifdef UseReceiverPlaneDepthBias
        vec4 sampleOccluders = step(vec4(dot(offset + shadowMapTexelSize.zy, shadowPositionReceiverPlaneDepthBias),      // 01
                                         dot(offset + shadowMapTexelSize.xy, shadowPositionReceiverPlaneDepthBias),      // 11
                                         dot(offset + shadowMapTexelSize.xz, shadowPositionReceiverPlaneDepthBias),      // 10
                                         dot(offset, shadowPositionReceiverPlaneDepthBias)), sampleDistances);  // 00
#else
        vec4 sampleOccluders = step(vec4(0.0), sampleDistances);
#endif
        occludedCount += mix(mix(sampleOccluders.w, sampleOccluders.z, gradient.x), mix(sampleOccluders.x, sampleOccluders.y, gradient.x), gradient.y);
      }

      return occludedCount * (1.0 / float(SHADOW_TAP_COUNT));

    }  

  }

}  

float doCascadedShadowMapShadow(const in int cascadedShadowMapIndex, const in vec3 lightDirection, out vec3 shadowUVW) {
  float value = -1.0;
  shadowMapSize = (uCascadedShadowMaps.metaData.x == SHADOWMAP_MODE_PCF) ? vec2(textureSize(uCascadedShadowMapTextureShadow, 0).xy) :  vec2(textureSize(uCascadedShadowMapTexture, 0).xy);
  shadowMapTexelSize = vec3(vec2(1.0) / shadowMapSize, 0.0);
#ifdef UseReceiverPlaneDepthBias
  vec4 shadowPosition = cascadedShadowMapPositions[cascadedShadowMapIndex];
  shadowPositionReceiverPlaneDepthBias = computeReceiverPlaneDepthBias(shadowPosition.xyz); 
  shadowPosition.z -= min(2.0 * dot(shadowMapTexelSize.xy, abs(shadowPositionReceiverPlaneDepthBias)), 1e-2);
  shadowUVW = fma(shadowPosition.xyz, vec3(2.0), vec3(-1.0)); 
#else
  vec3 worldSpacePosition = getOffsetedBiasedWorldPositionForShadowMapping(uCascadedShadowMaps.constantBiasNormalBiasSlopeBiasClamp[cascadedShadowMapIndex], lightDirection);
  vec4 shadowPosition = uCascadedShadowMaps.shadowMapMatrices[cascadedShadowMapIndex] * vec4(worldSpacePosition, 1.0);
  shadowUVW = (shadowPosition /= shadowPosition.w).xyz;
  shadowPosition = fma(shadowPosition, vec2(0.5, 1.0).xxyy, vec2(0.5, 0.0).xxyy);
#endif
  if(all(greaterThanEqual(shadowPosition, vec4(0.0))) && all(lessThanEqual(shadowPosition, vec4(1.0)))){
    switch(uCascadedShadowMaps.metaData.x){
      case SHADOWMAP_MODE_PCF:{
        value = DoPCF(uCascadedShadowMapTextureShadow, cascadedShadowMapIndex, shadowPosition);
        break;
      }
      case SHADOWMAP_MODE_DPCF:{
        value = DoDPCF_PCSS(uCascadedShadowMapTexture, cascadedShadowMapIndex, shadowPosition, true);
        break;
      }
      case SHADOWMAP_MODE_PCSS:{
        value = DoDPCF_PCSS(uCascadedShadowMapTexture, cascadedShadowMapIndex, shadowPosition, false);
        break;
      }
      default:{
        break;
      }
    }
  }
  return value;
}

#else

float computeMSM(in vec4 moments, in float fragmentDepth, in float depthBias, in float momentBias) {
  vec4 b = mix(moments, vec4(0.5), momentBias);
  vec3 z;
  z[0] = fragmentDepth - depthBias;
  float L32D22 = fma(-b[0], b[1], b[2]);
  float D22 = fma(-b[0], b[0], b[1]);
  float squaredDepthVariance = fma(-b[1], b[1], b[3]);
  float D33D22 = dot(vec2(squaredDepthVariance, -L32D22), vec2(D22, L32D22));
  float InvD22 = 1.0 / D22;
  float L32 = L32D22 * InvD22;
  vec3 c = vec3(1.0, z[0], z[0] * z[0]);
  c[1] -= b.x;
  c[2] -= b.y + (L32 * c[1]);
  c[1] *= InvD22;
  c[2] *= D22 / D33D22;
  c[1] -= L32 * c[2];
  c[0] -= dot(c.yz, b.xy);
  float InvC2 = 1.0 / c[2];
  float p = c[1] * InvC2;
  float q = c[0] * InvC2;
  float D = (p * p * 0.25) - q;
  float r = sqrt(D);
  z[1] = (p * -0.5) - r;
  z[2] = (p * -0.5) + r;
  vec4 switchVal = (z[2] < z[0]) ? vec4(z[1], z[0], 1.0, 1.0) : ((z[1] < z[0]) ? vec4(z[0], z[1], 0.0, 1.0) : vec4(0.0));
  float quotient = (switchVal[0] * z[2] - b[0] * (switchVal[0] + z[2]) + b[1]) / ((z[2] - switchVal[1]) * (z[0] - z[1]));
  return 1.0 - clamp((switchVal[2] + (switchVal[3] * quotient)), 0.0, 1.0);
}

float reduceLightBleeding(float pMax, float amount) {
  return linearStep(amount, 1.0, pMax);  //
}

float getMSMShadowIntensity(vec4 moments, float depth, float depthBias, float momentBias) {
  vec4 b = mix(moments, vec4(0.5), momentBias);
  float                                                  //
      d = depth - depthBias,                             //
      l32d22 = fma(-b.x, b.y, b.z),                      //
      d22 = fma(-b.x, b.x, b.y),                         //
      squaredDepthVariance = fma(-b.y, b.y, b.w),        //
      d33d22 = dot(vec2(squaredDepthVariance, -l32d22),  //
                   vec2(d22, l32d22)),                   //
      invD22 = 1.0 / d22,                                //
      l32 = l32d22 * invD22;
  vec3 c = vec3(1.0, d - b.x, d * d);
  c.z -= b.y + (l32 * c.y);
  c.yz *= vec2(invD22, d22 / d33d22);
  c.y -= l32 * c.z;
  c.x -= dot(c.yz, b.xy);
  vec2 pq = c.yx / c.z;
  vec3 z = vec3(d, vec2(-(pq.x * 0.5)) + (vec2(-1.0, 1.0) * sqrt(((pq.x * pq.x) * 0.25) - pq.y)));
  vec4 s = (z.z < z.x) ? vec3(z.y, z.x, 1.0).xyzz : ((z.y < z.x) ? vec4(z.x, z.y, 0.0, 1.0) : vec4(0.0));
  return 1.0 - clamp((s.z + (s.w * ((((s.x * z.z) - (b.x * (s.x + z.z))) + b.y) / ((z.z - s.y) * (z.x - z.y))))), 0.0, 1.0); // * 1.03
}

float fastTanArcCos(const in float x){
  return sqrt(-fma(x, x, -1.0)) / x; // tan(acos(x)); sqrt(1.0 - (x * x)) / x 
}

float doCascadedShadowMapShadow(const in int cascadedShadowMapIndex, const in vec3 lightDirection, out vec3 shadowUVW) {
  mat4 shadowMapMatrix = uCascadedShadowMaps.shadowMapMatrices[cascadedShadowMapIndex];
  vec4 shadowNDC = shadowMapMatrix * vec4(inWorldSpacePosition, 1.0);
  shadowNDC.xy = fma((shadowUVW = ((shadowNDC /= shadowNDC.w).xyz)).xy, vec2(0.5), vec2(0.5));
  if (all(greaterThanEqual(shadowNDC, vec4(0.0))) && all(lessThanEqual(shadowNDC, vec4(1.0)))) {
    vec4 moments = (textureLod(uCascadedShadowMapTexture, vec3(shadowNDC.xy, float(int(cascadedShadowMapIndex))), 0.0) +  //
                    vec2(-0.035955884801, 0.0).xyyy) *                                                                    //
                   mat4(0.2227744146, 0.0771972861, 0.7926986636, 0.0319417555,                                           //
                        0.1549679261, 0.1394629426, 0.7963415838, -0.172282317,                                           //
                        0.1451988946, 0.2120202157, 0.7258694464, -0.2758014811,                                          //
                        0.163127443, 0.2591432266, 0.6539092497, -0.3376131734);
    float depthBias = clamp(0.005 * fastTanArcCos(clamp(dot(workNormal, -lightDirection), -1.0, 1.0)), 0.0, 0.1) * 0.15;
    return clamp(reduceLightBleeding(getMSMShadowIntensity(moments, shadowNDC.z, depthBias, 3e-4), 0.25), 0.0, 1.0);
  } else {
    return -1.0;
  }
}

#endif

vec4 shadowGetCascadeFactors(){
  int cascadedShadowMapIndex = 0;
  vec4 shadowPosition;
  while(cascadedShadowMapIndex < NUM_SHADOW_CASCADES){
    shadowPosition = uCascadedShadowMaps.shadowMapMatrices[cascadedShadowMapIndex] * vec4(inWorldSpacePosition.xyz, 1.0);
    if(all(lessThanEqual(abs(shadowPosition / shadowPosition.w), vec4(1.0)))){
      break; 
    }else{
      cascadedShadowMapIndex++;
    }
  }
  vec4 weights = vec4(0.0);
  if((cascadedShadowMapIndex >= 0) && (cascadedShadowMapIndex < NUM_SHADOW_CASCADES)){
#if 1
    // Fast variant, which processes only the current and the next shadow map.
    if((cascadedShadowMapIndex + 1) < NUM_SHADOW_CASCADES){
      // Calculate the factor by fading out the shadow map at the edges itself, with 20% corner threshold.
      vec3 edgeFactor = clamp((clamp(abs(shadowPosition.xyz / shadowPosition.w), vec3(0.0), vec3(1.0)) - vec3(0.8)) * 5.0, vec3(0.0), vec3(1.0)); 
      float factor = max(edgeFactor.x, max(edgeFactor.y, edgeFactor.z));
      weights[cascadedShadowMapIndex] = 1.0 - factor;
      weights[cascadedShadowMapIndex + 1] = factor;
    }else{
      weights[cascadedShadowMapIndex] = 1.0;
    }
#else    
    // More complex variant, which processes all shadow maps, by front-to-back-blending-style fading out the shadow maps at the edges.
    // But it should almost never really be needed, as the fast variant should be good enough. 
    float current = 1.0;    
    for(int currentCascadedShadowMapIndex = cascadedShadowMapIndex; currentCascadedShadowMapIndex < NUM_SHADOW_CASCADES; currentCascadedShadowMapIndex++){
      if(currentCascadedShadowMapIndex == (NUM_SHADOW_CASCADES - 1)){
        weights[currentCascadedShadowMapIndex] = current;
        break;
      }else{
        vec4 shadowPosition = uCascadedShadowMaps.shadowMapMatrices[cascadedShadowMapIndex] * vec4(inWorldSpacePosition.xyz, 1.0);
        if(all(lessThanEqual(abs(shadowPosition / shadowPosition.w), vec4(1.0)))){
          // Calculate the factor by fading out the shadow map at the edges itself, with 20% corner threshold.
          vec3 edgeFactor = clamp((clamp(abs(shadowPosition.xyz / shadowPosition.w), vec3(0.0), vec3(1.0)) - vec3(0.8)) * 5.0, vec3(0.0), vec3(1.0)); 
          float factor = 1.0 - max(edgeFactor.x, max(edgeFactor.y, edgeFactor.z));
          weights[currentCascadedShadowMapIndex] = current * factor;
          current *= 1.0 - factor;
          if(current < 1e-6){
            break;
          }
        }else{
          break;
        }
      }
    }    
    float sum = dot(weights, vec4(1.0));
    if(sum > 0.0){
      weights /= sum;
    }
#endif    
  }
  return weights;
}

vec4 shadowCascadeVisualizationColor(){
  vec4 weights = shadowGetCascadeFactors();
  return (vec4(0.125, 0.0, 0.0, 1.0) * weights.x) + 
         (vec4(0.0, 0.125, 0.0, 1.0) * weights.y) + 
         (vec4(0.0, 0.0, 0.125, 1.0) * weights.z) + 
         (vec4(0.125, 0.125, 0.0, 1.0) * weights.w);
}

#ifdef SPECIAL_SHADOWS

vec3 lightDirection;

float getCascadedShadow(float maxDistance){
#if defined(RAYTRACING)
  vec3 rayOrigin = inWorldSpacePosition, rayNormal = workNormal;
  float rayOffset = 0.0;
#ifdef RAYTRACED_SOFT_SHADOWS
  if(true){
    // Soft shadow
    const int countSamples = 8;
    vec3 lightNormal = normalize(-lightDirection);
    vec3 lightTangent = normalize(cross(lightNormal, getPerpendicularVector(lightNormal)));
    vec3 lightBitangent = cross(lightNormal, lightTangent);
    float shadow = 0.0;
    for(int i = 0; i < countSamples; i++){
      vec2 sampleXY = (shadowDiscRotationMatrix * BlueNoise2DDisc[(i + int(shadowDiscRandomValues.y)) & BlueNoise2DDiscMask]) * 1e-2;
      vec3 sampleDirection = normalize(lightNormal + (sampleXY.x * lightTangent) + (sampleXY.y * lightBitangent));
      shadow += getRaytracedHardShadow(rayOrigin, rayNormal, sampleDirection, rayOffset, maxDistance);
    }
    return shadow / float(countSamples);                    
  }else{
    // Hard shadow 
    return getRaytracedHardShadow(rayOrigin, rayNormal, normalize(-lightDirection), rayOffset, maxDistance);
  }
#else
  return getRaytracedHardShadow(rayOrigin, rayNormal, normalize(-lightDirection), rayOffset, maxDistance);
#endif
#else
#ifdef UseReceiverPlaneDepthBias
  // Outside of doCascadedShadowMapShadow as an own loop, for the reason, that the partial derivative based
  // computeReceiverPlaneDepthBias function can work correctly then, when all cascaded shadow map slice
  // position are already known in advance, and always at any time and at any real current cascaded shadow 
  // map slice. Because otherwise one can see dFdx/dFdy caused artefacts on cascaded shadow map border
  // transitions.  
  {
    for(int cascadedShadowMapIndex = 0; cascadedShadowMapIndex < NUM_SHADOW_CASCADES; cascadedShadowMapIndex++){
      vec3 worldSpacePosition = getOffsetedBiasedWorldPositionForShadowMapping(uCascadedShadowMaps.constantBiasNormalBiasSlopeBiasClamp[cascadedShadowMapIndex], -lightDirection);
      vec4 shadowPosition = uCascadedShadowMaps.shadowMapMatrices[cascadedShadowMapIndex] * vec4(worldSpacePosition, 1.0);
      shadowPosition = fma(shadowPosition / shadowPosition.w, vec2(0.5, 1.0).xxyy, vec2(0.5, 0.0).xxyy);
      cascadedShadowMapPositions[cascadedShadowMapIndex] = shadowPosition;
    }
  }
#endif

  float shadow = 1.0;

  vec3 shadowUVW;

  // Find the first cascaded shadow map slice, which is responsible for the current fragment.
  int cascadedShadowMapIndex = 0;
  while(cascadedShadowMapIndex < NUM_SHADOW_CASCADES) {
    shadow = doCascadedShadowMapShadow(cascadedShadowMapIndex, -lightDirection, shadowUVW);
    if (shadow < 0.0){
      // The current fragment is outside of the current cascaded shadow map slice, so try the next one.
      cascadedShadowMapIndex++;
    }else{
      // The current fragment is inside of the current cascaded shadow map slice, so use it.
      break;
    }
  }

  if((cascadedShadowMapIndex + 1) < NUM_SHADOW_CASCADES){
    // Calculate the factor by fading out the shadow map at the edges itself, with 20% corner threshold.
    // This gives better results than fading by view depth, which is used often elsewhere, where each 
    // cascaded shadow map slice has a different depth range.
    vec3 edgeFactor = clamp((clamp(abs(shadowUVW), vec3(0.0), vec3(1.0)) - vec3(0.8)) * 5.0, vec3(0.0), vec3(1.0)); 
    float factor = clamp(max(edgeFactor.x, max(edgeFactor.y, edgeFactor.z)) * 1.05, 0.0, 1.0); // 5% over the edgeFactor for reducing the shadow map transition artefacts at the cascaded shadow map slice borders.
    if(factor > 0.0){
      // The current fragment is inside of the current cascaded shadow map slice, but also inside of the next one.
      // So fade between the two shadow map slices. But notice that nextShadow can also -1.0, when the current fragment
      // is outside of the next cascaded shadow map slice. In this case we fade into the no shadow case for smooth
      // shadow map transitions even at the whole cascaded shadow map slice border.
      float nextShadow = doCascadedShadowMapShadow(cascadedShadowMapIndex + 1, -lightDirection, shadowUVW);
      shadow = mix(shadow, (nextShadow < 0.0) ? 1.0 : nextShadow, factor); 
    }
  }

  if(shadow < 0.0){
    shadow = 1.0; // The current fragment is outside of the cascaded shadow map range, so use no shadow then instead.
  } 

  return clamp(shadow, 0.0, 1.0); // Clamp just for safety, should not be necessary, but don't hurt either.
#endif // RAYTRACING
} 


float getFastCascadedShadow(float maxDistance, mat4 inverseOriginTransform){
#if defined(RAYTRACING)
  vec3 rayOrigin = (vec4(inWorldSpacePosition, 1.0) * inverseOriginTransform).xyz, rayNormal = (vec4(workNormal, 0.0) * inverseOriginTransform).xyz;
  float rayOffset = 0.0;
  return getRaytracedFastHardShadow(rayOrigin, rayNormal, normalize(-lightDirection), rayOffset, maxDistance);
#else
#ifdef UseReceiverPlaneDepthBias
  // Outside of doCascadedShadowMapShadow as an own loop, for the reason, that the partial derivative based
  // computeReceiverPlaneDepthBias function can work correctly then, when all cascaded shadow map slice
  // position are already known in advance, and always at any time and at any real current cascaded shadow 
  // map slice. Because otherwise one can see dFdx/dFdy caused artefacts on cascaded shadow map border
  // transitions.  
  {
    for(int cascadedShadowMapIndex = 0; cascadedShadowMapIndex < NUM_SHADOW_CASCADES; cascadedShadowMapIndex++){
      vec3 worldSpacePosition = getOffsetedBiasedWorldPositionForShadowMapping(uCascadedShadowMaps.constantBiasNormalBiasSlopeBiasClamp[cascadedShadowMapIndex], -lightDirection);
      vec4 shadowPosition = uCascadedShadowMaps.shadowMapMatrices[cascadedShadowMapIndex] * vec4(worldSpacePosition, 1.0);
      shadowPosition = fma(shadowPosition / shadowPosition.w, vec2(0.5, 1.0).xxyy, vec2(0.5, 0.0).xxyy);
      cascadedShadowMapPositions[cascadedShadowMapIndex] = shadowPosition;
    }
  }
#endif

  float shadow = 1.0;

  vec3 shadowUVW;

  // Find the first cascaded shadow map slice, which is responsible for the current fragment.
  int cascadedShadowMapIndex = 0;
  while(cascadedShadowMapIndex < NUM_SHADOW_CASCADES) {
    shadow = doCascadedShadowMapShadow(cascadedShadowMapIndex, -lightDirection, shadowUVW);
    if (shadow < 0.0){
      // The current fragment is outside of the current cascaded shadow map slice, so try the next one.
      cascadedShadowMapIndex++;
    }else{
      // The current fragment is inside of the current cascaded shadow map slice, so use it.
      break;
    }
  }

  if((cascadedShadowMapIndex + 1) < NUM_SHADOW_CASCADES){
    // Calculate the factor by fading out the shadow map at the edges itself, with 20% corner threshold.
    // This gives better results than fading by view depth, which is used often elsewhere, where each 
    // cascaded shadow map slice has a different depth range.
    vec3 edgeFactor = clamp((clamp(abs(shadowUVW), vec3(0.0), vec3(1.0)) - vec3(0.8)) * 5.0, vec3(0.0), vec3(1.0)); 
    float factor = clamp(max(edgeFactor.x, max(edgeFactor.y, edgeFactor.z)) * 1.05, 0.0, 1.0); // 5% over the edgeFactor for reducing the shadow map transition artefacts at the cascaded shadow map slice borders.
    if(factor > 0.0){
      // The current fragment is inside of the current cascaded shadow map slice, but also inside of the next one.
      // So fade between the two shadow map slices. But notice that nextShadow can also -1.0, when the current fragment
      // is outside of the next cascaded shadow map slice. In this case we fade into the no shadow case for smooth
      // shadow map transitions even at the whole cascaded shadow map slice border.
      float nextShadow = doCascadedShadowMapShadow(cascadedShadowMapIndex + 1, -lightDirection, shadowUVW);
      shadow = mix(shadow, (nextShadow < 0.0) ? 1.0 : nextShadow, factor); 
    }
  }

  if(shadow < 0.0){
    shadow = 1.0; // The current fragment is outside of the cascaded shadow map range, so use no shadow then instead.
  } 

  return clamp(shadow, 0.0, 1.0); // Clamp just for safety, should not be necessary, but don't hurt either.

#endif // RAYTRACING

} 

float getFastFurthestCascadedShadow(float maxDistance){
#if defined(RAYTRACING)
  vec3 rayOrigin = inWorldSpacePosition, rayNormal = workNormal;
  float rayOffset = 0.0;
  return getRaytracedFastHardShadow(rayOrigin, rayNormal, normalize(-lightDirection), rayOffset, maxDistance);
#else
  // Check just the furthest cascaded shadow map slice as requested.
  int cascadedShadowMapIndex = NUM_SHADOW_CASCADES - 1;
  vec3 shadowUVW;
  float shadow = doCascadedShadowMapShadow(cascadedShadowMapIndex, -lightDirection, shadowUVW);
  if(shadow < 0.0){
    shadow = 1.0; // The current fragment is outside of the cascaded shadow map range, so use no shadow then instead.
  }
  return clamp(shadow, 0.0, 1.0); // Clamp just for safety, should not be necessary, but don't hurt either.
#endif
}

#endif // ATMOSPHERE_SHADOWS

#endif // SHADOWS

#endif // SHADOWS_GLSL