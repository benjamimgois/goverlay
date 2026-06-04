#version 460 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_multiview : enable
#extension GL_EXT_samplerless_texture_functions : enable
#extension GL_EXT_nonuniform_qualifier : enable
#ifdef RAYTRACING
  #extension GL_EXT_buffer_reference : enable
  #define USE_BUFFER_REFERENCE
  #define USE_MATERIAL_BUFFER_REFERENCE
#endif

#include "bufferreference_definitions.glsl"

/* clang-format off */

//layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

/* clang-format on */

#define MULTISCATAPPROX_ENABLED
#ifdef SHADOWS
 #define SHADOWS_ENABLED
 #define NOTEXCOORDS
#else
 #undef SHADOWS_ENABLED
#endif
#define ATMOSPHEREMAP_ENABLED 

// Push constants
layout(push_constant, std140) uniform PushConstants {
  int baseViewIndex;
  int countViews;
  int frameIndex;
  uint flags;
  uint countSamples;
} pushConstants;

#include "globaldescriptorset.glsl"

#include "math.glsl"

#ifdef SHADOWS
#define SPECIAL_SHADOWS

#if defined(RAYTRACING)
  #include "raytracing.glsl"
#endif

#if 1 //!defined(RAYTRACING)
#define NUM_SHADOW_CASCADES 4
const uint SHADOWMAP_MODE_NONE = 1;
const uint SHADOWMAP_MODE_PCF = 2;
const uint SHADOWMAP_MODE_DPCF = 3;
const uint SHADOWMAP_MODE_PCSS = 4;
const uint SHADOWMAP_MODE_MSM = 5;

#define inFrameIndex pushConstants.frameIndex

layout(set = 2, binding = 9, std140) uniform uboCascadedShadowMaps {
  mat4 shadowMapMatrices[NUM_SHADOW_CASCADES];
  vec4 shadowMapSplitDepthsScales[NUM_SHADOW_CASCADES];
  vec4 constantBiasNormalBiasSlopeBiasClamp[NUM_SHADOW_CASCADES];
  uvec4 metaData; // x = type
} uCascadedShadowMaps;

layout(set = 2, binding = 10) uniform sampler2DArray uCascadedShadowMapTexture;

#ifdef PCFPCSS

// Yay! Binding Aliasing! :-)
layout(set = 2, binding = 10) uniform sampler2DArrayShadow uCascadedShadowMapTextureShadow;

#endif // PCFPCSS
#endif // !RAYTRACING 

vec3 inWorldSpacePosition, workNormal;
#endif // SHADOWS

#include "shadows.glsl"

#include "atmosphere_common.glsl"

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outInscattering;

#ifdef DUALBLEND
layout(location = 1) out vec4 outTransmittance; // component-wise transmittance
#endif

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256]; // 65536 / (64 * 4) = 256
} uView;

#ifdef MSAA

#ifdef MULTIVIEW
layout(set = 2, binding = 0) uniform texture2DMSArray uDepthTexture;
#else
layout(set = 2, binding = 0) uniform texture2DMS uDepthTexture;
#endif

#else

#ifdef MULTIVIEW
layout(set = 2, binding = 0) uniform texture2DArray uDepthTexture; 
#else
layout(set = 2, binding = 0) uniform texture2D uDepthTexture;
#endif

#endif

#ifdef MULTIVIEW
layout(set = 2, binding = 11) uniform texture2DArray uCloudsInscatteringTexture;
layout(set = 2, binding = 12) uniform texture2DArray uCloudsTransmittanceTexture;
layout(set = 2, binding = 13) uniform texture2DArray uCloudsDepthTexture;
#else
layout(set = 2, binding = 11) uniform texture2D uCloudsInscatteringTexture;
layout(set = 2, binding = 12) uniform texture2D uCloudsTransmittanceTexture;
layout(set = 2, binding = 13) uniform texture2D uCloudsDepthTexture;
#endif

/*
#ifdef MSAA
layout(input_attachment_index = 0, set = 2, binding = 0) uniform subpassInputMS uSubpassDepth;
#else  
layout(input_attachment_index = 0, set = 2, binding = 0) uniform subpassInput uSubpassDepth;
#endif
*/

layout(set = 2, binding = 1) uniform sampler2D uTransmittanceLutTexture;

layout(set = 2, binding = 2) uniform sampler2D uMultiScatteringTexture;

layout(set = 2, binding = 3) uniform sampler2DArray uSkyViewLUT;

layout(set = 2, binding = 4) uniform sampler2DArray uCameraVolume;

layout(set = 2, binding = 5) uniform samplerCube uAtmosphereMapTexture;

layout(set = 2, binding = 6) uniform sampler2D uBlueNoise;

layout(set = 2, binding = 7, std430) buffer AtmosphereMapMinMaxBuffer {
  float minValue;
  float maxValue;
} uAtmosphereMapMinMax;

layout(set = 2, binding = 8, std430) buffer AtmosphereParametersBuffer {
  AtmosphereParameters atmosphereParameters;
} uAtmosphereParameters;

#include "projectsphere.glsl"

#include "textureutils.glsl"

vec2 intersectSphere(vec3 rayOrigin, vec3 rayDirection, vec4 sphere){
  vec3 v = rayOrigin - sphere.xyz;
  float b = dot(v, rayDirection),
        c = dot(v, v) - (sphere.w * sphere.w),
        d = (b * b) - c;
  return (d < 0.0) 
             ? vec2(-1.0)                                // No intersection
             : ((vec2(-1.0, 1.0) * sqrt(d)) - vec2(b));  // Intersection
}        

int countScatteringSamples = 0;
mat2x3 scatteringSamples[8] = mat2x3[8](
  mat2x3(vec3(0.0), vec3(1.0)),
  mat2x3(vec3(0.0), vec3(1.0)),
  mat2x3(vec3(0.0), vec3(1.0)),
  mat2x3(vec3(0.0), vec3(1.0)),
  mat2x3(vec3(0.0), vec3(1.0)),
  mat2x3(vec3(0.0), vec3(1.0)),
  mat2x3(vec3(0.0), vec3(1.0)),
  mat2x3(vec3(0.0), vec3(1.0))
);
  
void addScatteringSample(const in vec3 inscattering, const in vec3 transmittance){
  int index = countScatteringSamples;
  if(index < 8){
    countScatteringSamples++;
    scatteringSamples[index] = mat2x3(inscattering, transmittance);
  }
} 

void main() {

  // Early out if the atmosphere is not present 
  if(uAtmosphereParameters.atmosphereParameters.AbsorptionExtinction.w < 1e-7){
    outInscattering = vec4(0.0, 0.0, 0.0, 0.0);
#ifdef DUALBLEND
    outTransmittance = vec4(1.0, 1.0, 1.0, 0.0);
#endif
    return;
  }

  int viewIndex = pushConstants.baseViewIndex + int(gl_ViewIndex);
  View view = uView.views[viewIndex];

/*vec2 pixPos = vec2(gl_FragCoord.xy) + vec2(0.5);
  vec2 uv = pixPos / pushConstants.resolution;*/

  vec2 uv = inTexCoord; 

  if((pushConstants.flags & FLAGS_USE_BLUE_NOISE) != 0u){
    seedSampleSeedT(uBlueNoise, ivec2(gl_FragCoord.xy), pushConstants.frameIndex);
  }

  vec3 rayOrigin, rayDirection;
  GetCameraPositionDirection(rayOrigin, rayDirection, view.viewMatrix, view.projectionMatrix, view.inverseViewMatrix, view.inverseProjectionMatrix, uv);
  
  vec3 worldPos = (uAtmosphereParameters.atmosphereParameters.inverseTransform * vec4(rayOrigin, 1.0)).xyz;
  vec3 worldDir = normalize((uAtmosphereParameters.atmosphereParameters.inverseTransform * vec4(rayDirection, 0.0)).xyz);

  vec3 originalWorldPos = worldPos; 

  //worldPos += vec3(0.0, uAtmosphereParameters.atmosphereParameters.BottomRadius, 0.0);

  float viewHeight = max(length(worldPos), uAtmosphereParameters.atmosphereParameters.BottomRadius + 1e-4);  
  vec3 L = vec3(0.0);

  vec4 cloudsInscattering = vec4(0.0), cloudsTransmittance = vec4(1.0, 1.0, 1.0, 0.0);

#if 0
  // This seems not working correctly, so deactivated for now. Edge cases are not handled correctly yet.
#ifdef MSAA
  // At MSAA we must find the farthest depth value, since clouds are rendered without MSAA but applied to the opaque pass content with MSAA,
  // so we must find the farthest depth value to avoid or at least minimize artifacts at the merging stage.
  float depthBufferValue;
  if((pushConstants.flags & PUSH_CONSTANT_FLAG_REVERSE_DEPTH) != 0u){
    depthBufferValue = uintBitsToFloat(0x7f800000u); // +inf as marker for the farthest depth value, so the minimum value is always less than this
    for(int sampleIndex = 0; sampleIndex < pushConstants.countSamples; sampleIndex++){
#ifdef MULTIVIEW
      float depthValue = texelFetch(uDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), sampleIndex).x;
#else
      float depthValue = texelFetch(uDepthTexture, ivec2(gl_FragCoord.xy), sampleIndex).x;
#endif
/*    if((depthValue > 0.0) && (depthValue < depthBufferValue)){
        depthBufferValue = depthValue;
      }*/
      depthBufferValue = min(depthBufferValue, depthValue);
    }
    if(isinf(depthBufferValue)){
      // Replace +inf with 0.0 with the real farthest depth value 
      depthBufferValue = 0.0;
    }
  }else{
    depthBufferValue = uintBitsToFloat(0xff800000u); // -inf as marker for the farthest depth value, so the maximum value is always greater than this
    for(int sampleIndex = 0; sampleIndex < pushConstants.countSamples; sampleIndex++){
#ifdef MULTIVIEW
      float depthValue = texelFetch(uDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), sampleIndex).x;
#else
      float depthValue = texelFetch(uDepthTexture, ivec2(gl_FragCoord.xy), sampleIndex).x;
#endif
/*    if((depthValue < 1.0) && (depthValue > depthBufferValue)){
        depthBufferValue = depthValue;
      }*/
      depthBufferValue = max(depthBufferValue, depthValue);
    }
    if(isinf(depthBufferValue)){
      // Replace -inf with 1.0 with the real farthest depth value
      depthBufferValue = 1.0;
    }
  }
#else
  // Without MSAA we can just use the depth value directly. Easy peasy. :-)
#ifdef MULTIVIEW
  float depthBufferValue = texelFetch(uDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), 0).x;
#else
  float depthBufferValue = texelFetch(uDepthTexture, ivec2(gl_FragCoord.xy), 0).x;
#endif
#endif

#else

  // The brute force way, since the above seems not working correctly, better safe than sorry.

#ifdef MSAA
#ifdef MULTIVIEW
  float depthBufferValue = texelFetch(uDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), gl_SampleID).x;
#else
  float depthBufferValue = texelFetch(uDepthTexture, ivec2(gl_FragCoord.xy), gl_SampleID).x;
#endif
#else
#ifdef MULTIVIEW
  float depthBufferValue = texelFetch(uDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), 0).x;
#else
  float depthBufferValue = texelFetch(uDepthTexture, ivec2(gl_FragCoord.xy), 0).x;
#endif
#endif

#endif

  bool atmosphereVisible;

  bool reversedZ = ProjectionMatrixIsReversedZ(view.projectionMatrix);
 
  // Get the ray length to the farthest depth value
  float rayLength = uintBitsToFloat(0x7f800000u); // +inf
  {
    vec4 ClipSpace = vec4(fma(uv, vec2(2.0), vec2(-1.0)), depthBufferValue, 1.0);
    if((reversedZ && (ClipSpace.z > 0.0)) || (!reversedZ && (ClipSpace.z < 1.0))){
      vec4 p = (uAtmosphereParameters.atmosphereParameters.inverseTransform * view.inverseViewMatrix * view.inverseProjectionMatrix) * ClipSpace;
      p.xyz /= p.w;
      if(!(any(isinf(p)) || any(isnan(p)))){
        rayLength = length(p.xyz - worldPos);
      }
    }
  }

  // Check if the camera is outside the atmosphere or inside the atmosphere
  if(length(worldPos) > uAtmosphereParameters.atmosphereParameters.TopRadius){
    
    // The camera is outside the atmosphere, so we must check if the ray intersects the atmosphere at all

    // It is visible if rayLength intersects the atmosphere at all and the ray is not behind the farthest depth value
    vec2 tTopSolutions = intersectSphere(worldPos, worldDir, vec2(0.0, uAtmosphereParameters.atmosphereParameters.TopRadius).xxxy);
    atmosphereVisible = (tTopSolutions.x > 0.0) && (tTopSolutions.x < rayLength);

  }else{
    
    // Otherwise the camera is inside the atmosphere, so it is always visible, since the atmosphere is a sphere

    atmosphereVisible = true;

  }
  
  vec3 sunDirection = normalize(getSunDirection(uAtmosphereParameters.atmosphereParameters));

#ifdef SHADOWS
  lightDirection = -sunDirection;
#endif

  bool depthIsZFar = depthBufferValue == GetZFarDepthValue(view.projectionMatrix);

  // Clouds are always without MSAA for performance reasons. These are low-freuquent shapes anyway, so it should be fine.
#ifdef MULTIVIEW
  float cloudsDepth = texelFetch(uCloudsDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), 0).x;
  bool cloudsValid = !isinf(cloudsDepth);
#else
  float cloudsDepth = texelFetch(uCloudsDepthTexture, ivec2(gl_FragCoord.xy), 0).x;
  bool cloudsValid = !isinf(cloudsDepth);
#endif

#ifdef MSAA
  // When MSAA is used, we must check if the clouds are valid and if the depth value is less than the clouds depth value, otherwise 
  // the clouds are not valid. This is necessary because clouds are rendered without MSAA but applied to the opaque pass content with 
  // MSAA.
  if(cloudsValid && !depthIsZFar){
    vec4 t = view.inverseProjectionMatrix * vec4(fma(uv, vec2(2.0), vec2(-1.0)), depthBufferValue, 1.0);
    float linearDepth = -(t.z / t.w);
    if(cloudsDepth > linearDepth){
      cloudsValid = false;
    }
  }
#endif

#ifdef MULTIVIEW
  if(cloudsValid){
    cloudsInscattering = texelFetch(uCloudsInscatteringTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), 0);
    cloudsTransmittance = texelFetch(uCloudsTransmittanceTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), 0);
  }
#else
  if(cloudsValid){
    cloudsInscattering = texelFetch(uCloudsInscatteringTexture, ivec2(gl_FragCoord.xy), 0);
    cloudsTransmittance = texelFetch(uCloudsTransmittanceTexture, ivec2(gl_FragCoord.xy), 0);
  }
#endif

  //bool rayHitsAtmosphere = any(greaterThanEqual(raySphereIntersect(worldPos, worldDir, vec3(0.0), atmosphereParameters.TopRadius), vec2(0.0)));

  bool needToRayMarch = false, 
       needAerialPerspective = false, 
       applyFastCloudIntegration = false, 
       useAtmosphereMap = (uAtmosphereParameters.atmosphereParameters.flags & FLAGS_USE_ATMOSPHERE_MAP) != 0u,
       needToProcess = (uAtmosphereParameters.atmosphereParameters.AbsorptionExtinction.w > 0.0) &&
                       // When atmosphere map is used, but the min and max are near zero, then the atmosphere is not visible, so we can skip the processing
                       !(useAtmosphereMap && 
                         ((abs(0.0 - uAtmosphereMapMinMax.minValue) < 1e-4) && (abs(0.0 - uAtmosphereMapMinMax.maxValue) < 1e-4))),
       // Fast sky and fast aerial perspective can only be used when the atmosphere map is not used or when the min and max values are near 1.0,
       // because the fast sky and fast aerial perspective are not compatible with the atmosphere map, since they use systematically some
       // aspects of the atmosphere, which are not compatible with the atmosphere map.
       canUseFastStuff = useAtmosphereMap 
                            ? ((abs(1.0 - uAtmosphereMapMinMax.minValue) < 1e-4) && (abs(1.0 - uAtmosphereMapMinMax.maxValue) < 1e-4))
                            : true;
  
  float targetDepth = uintBitsToFloat(0x7F800000u); // +inf

  float atmosphereCullingFactor;
  if(((((pushConstants.flags & FLAGS_USE_FAST_AERIAL_PERSPECTIVE) != 0u) && canUseFastStuff) || 
      ((pushConstants.flags & FLAGS_SHADOWS) == 0u)) && 
      (uAtmosphereParameters.atmosphereParameters.CullingParameters.innerOuterFadeDistancesCountFacesMode.w != 0u)){ 
    if(depthIsZFar){
      atmosphereCullingFactor = 1.0;
    }else{
      vec4 t = (view.inverseViewMatrix * view.inverseProjectionMatrix) * vec4(fma(uv, vec2(2.0), vec2(-1.0)), depthBufferValue, 1.0);
      atmosphereCullingFactor = getAtmosphereCullingFactor(uAtmosphereParameters.atmosphereParameters.CullingParameters, t.xyz /= t.w, worldPos);
    }
  }else{
    atmosphereCullingFactor = 1.0;
  }

  if(/*rayHitsAtmosphere &&*/ depthIsZFar){

    // When fast sky is used, we can use a precomputed sky view LUT to get the inscattering and transmittance values 
    if(((pushConstants.flags & FLAGS_USE_FAST_SKY) != 0u) && needToProcess && canUseFastStuff){
      
      vec2 localUV;
      vec3 UpVector = normalize(worldPos);
      float viewZenithCosAngle = dot(worldDir, UpVector);

      vec3 sideVector = normalize(cross(UpVector, worldDir));		// assumes non parallel vectors
      vec3 forwardVector = normalize(cross(sideVector, UpVector));	// aligns toward the sun light but perpendicular to up vector
      vec2 lightOnPlane = vec2(dot(sunDirection, forwardVector), dot(sunDirection, sideVector));
      lightOnPlane = normalize(lightOnPlane);
      float lightViewCosAngle = lightOnPlane.x;

      bool IntersectGround = raySphereIntersectNearest(worldPos, worldDir, vec3(0.0), uAtmosphereParameters.atmosphereParameters.BottomRadius) >= 0.0;
  
      SkyViewLutParamsToUv(uAtmosphereParameters.atmosphereParameters, IntersectGround, viewZenithCosAngle, lightViewCosAngle, viewHeight, localUV);

#if 0
      localUV = getNiceTextureUV(localUV, vec2(textureSize(uSkyViewLUT, 0).xy));
#endif      

      vec4 inscattering = textureLod(uSkyViewLUT, vec3(localUV, float(int(gl_ViewIndex))), 0.0).xyzw; // xyz = inscatter, w = transmittance (monochromatic)

#ifdef DUALBLEND
      vec3 transmittance = textureLod(uSkyViewLUT, vec3(localUV, float(int(int(gl_ViewIndex) + pushConstants.countViews))), 0.0).xyz; // xyz = transmittance, w = non-used
#else
      vec3 transmittance = vec3(inscattering.w); // convert from monochromatic transmittance, not optimal but better than nothing 
#endif

      if(!IntersectGround){
        addScatteringSample(GetSunLuminance(originalWorldPos, worldDir, sunDirection, uAtmosphereParameters.atmosphereParameters.BottomRadius).xyz, vec3(1.0));
      }

      addScatteringSample(inscattering.xyz, transmittance.xyz);

      applyFastCloudIntegration = true;

    }else{

      addScatteringSample(GetSunLuminance(originalWorldPos, worldDir, sunDirection, uAtmosphereParameters.atmosphereParameters.BottomRadius).xyz, vec3(1.0));

      needToRayMarch = true;
      
    }

    needAerialPerspective = false;

  }else{ 

    needAerialPerspective = true;

  }

#if 0 

  // Not used currently, since there are yet some issues with the clouds integration inbetween the atmosphere slices when using fast sky and fast aerial perspective
  // TODO: Fix the issues with the clouds integration inbetween the atmosphere slices when using fast sky and fast aerial perspective
  
  // Integrate clouds if they are present and not already integrated and if either fast sky or fast aerial perspective is used, otherwise
  // they are integrated in the ray marching later on
  if(cloudsValid && 
     (!needToRayMarch) && // When ray marching, clouds are integrated inbetween the atmosphere slices
     canUseFastStuff && // Wenn fast sky or fast aerial perspective can be used
     ((((pushConstants.flags & FLAGS_USE_FAST_SKY) != 0u) && !needAerialPerspective) /*||
      (((pushConstants.flags & FLAGS_USE_FAST_AERIAL_PERSPECTIVE) != 0u) && needAerialPerspective)*/)){
    addScatteringSample(cloudsInscattering.xyz, cloudsTransmittance.xyz);      
    targetDepth = cloudsDepth;  
    cloudsValid = false; // clouds are already integrated, so no need to do it again
  }

#endif
  
  if(needAerialPerspective && needToProcess && atmosphereVisible){

    // When fast aerial perspective is used and no clouds are present at this fragment pixel, we can use a precomputed camera volume to get the
    // inscattering and transmittance values
    if(((pushConstants.flags & FLAGS_USE_FAST_AERIAL_PERSPECTIVE) != 0u) && canUseFastStuff){

      // Fast aerial perspective approximation using a 3D texture

      // (BeRo): Check if we can use the fast aerial perspective approximation, given the camera volume constraints the planet in a way that
      // the voxel resolution is not too inaccurate
      bool fitsInCameraVolume = true;
      if(length(worldPos) >= uAtmosphereParameters.atmosphereParameters.TopRadius){

        vec4 aabb;     
        vec3 transformedCenter = ((view.viewMatrix * uAtmosphereParameters.atmosphereParameters.transform) * vec4(vec3(0.0), 1.0)).xyz;
        if(projectSphere(transformedCenter, uAtmosphereParameters.atmosphereParameters.TopRadius, 0.01, view.projectionMatrix, aabb, false)){

          // camera volume is 32x32 by width and height and 32 by depth, by default

          vec2 aabbSize = (aabb.zw - aabb.xy) * vec2(textureSize(uCameraVolume, 0).xy);

          fitsInCameraVolume = all(greaterThanEqual(aabbSize, vec2(4.0))); // 4x4 pixels minimum, otherwise the voxel resolution is too inaccurate

        }

      }   
  
      if(fitsInCameraVolume){

        // (BeRo): Move ray marching start up to top atmosphere, for to avoid missing the atmosphere in the special case of the camera being
        // far outside the atmosphere.
        //if(length(worldPos) >= uAtmosphereParameters.atmosphereParameters.TopRadius)
        {
          vec2 t = raySphereIntersect(worldPos, worldDir, vec3(0.0), uAtmosphereParameters.atmosphereParameters.TopRadius);
          if(all(greaterThanEqual(t, vec2(0.0)))){
            worldPos += worldDir * min(t.x, t.y);
          }
        }

        mat4 inverseViewProjectionMatrix = view.inverseViewMatrix * view.inverseProjectionMatrix;

        vec4 depthBufferWorldPos = inverseViewProjectionMatrix * vec4(fma(vec2(uv), vec2(2.0), vec2(-1.0)), depthBufferValue, 1.0);
        depthBufferWorldPos /= depthBufferWorldPos.w;

        float tDepth = min(length((uAtmosphereParameters.atmosphereParameters.inverseTransform * vec4(depthBufferWorldPos.xyz, 1.0)).xyz - worldPos), targetDepth);
        float slice = AerialPerspectiveDepthToSlice(tDepth);
        float Weight = 1.0;
        if(slice < 0.5){
          Weight = clamp(slice * 2.0, 0.0, 1.0);
          slice = 0.5;
        } 
        float w = sqrt(slice / AP_SLICE_COUNT); // squared distribution

#if 0
        vec3 uvw = getNiceTextureUVW(vec3(uv, w), vec3(textureSize(uCameraVolume, 0).xy, float(AP_SLICE_COUNT)));

        uv = uvw.xy;
        w = uvw.z;
#endif

        float baseSlice = w * AP_SLICE_COUNT;
        int sliceIndex = int(floor(baseSlice));
        float sliceWeight = baseSlice - float(sliceIndex);
        int nextSliceIndex = clamp(sliceIndex + 1, 0, AP_SLICE_COUNT_INT - 1);
        sliceIndex = clamp(sliceIndex, 0, AP_SLICE_COUNT_INT - 1);

        // Manual 3D texture lookup from a 2D array texture, since multiview is not supported for 3D textures (no 3D array textures) 
        vec4 inscattering = mix(
                          textureLod(uCameraVolume, vec3(uv, sliceIndex + (int(gl_ViewIndex) * AP_SLICE_COUNT_INT)), 0.0),
                          textureLod(uCameraVolume, vec3(uv, nextSliceIndex + (int(gl_ViewIndex) * AP_SLICE_COUNT_INT)), 0.0),
                          sliceWeight
                        ) * Weight;

#ifdef DUALBLEND
        vec3 transmittance = mix(
                              textureLod(uCameraVolume, vec3(uv, sliceIndex + ((int(gl_ViewIndex) + pushConstants.countViews) * AP_SLICE_COUNT_INT)), 0.0).xyz,
                              textureLod(uCameraVolume, vec3(uv, nextSliceIndex + ((int(gl_ViewIndex) + pushConstants.countViews) * AP_SLICE_COUNT_INT)), 0.0).xyz,
                              sliceWeight
                             ) * Weight;
#else
        vec3 transmittance = vec3(inscattering.w); // convert from monochromatic transmittance, not optimal but better than nothing
#endif

        addScatteringSample(mix(vec3(0.0), inscattering.xyz, atmosphereCullingFactor), mix(vec3(1.0), transmittance.xyz, atmosphereCullingFactor));

        applyFastCloudIntegration = true;

        needToRayMarch = false;

      }  

    }else{

      needToRayMarch = true;

    }

  }

  // When fast cloud integration is used, we apply the precomputed cloud inscattering and transmittance values directly after the fast sky or
  // fast aerial perspective, even when it isn't correct, since the clouds are not integrated inbetween the atmosphere slices when using fast sky
  // or fast aerial perspective, but better than nothing 
/*if(applyFastCloudIntegration){
    if(cloudsValid){
      cloudsValid = false;
      addScatteringSample(cloudsInscattering.xyz, cloudsTransmittance.xyz);
    }
    needToRayMarch = false;
  }*/

  if(needToRayMarch && needToProcess && atmosphereVisible){
/*
    if(cloudsValid){

      // When clouds are present, we need to handle them inbetween the atmosphere slices, so therefore we need to ray march the first
      // part of the atmosphere before the clouds, then the clouds, then the rest of the atmosphere after the clouds. 

      // Move to top atmosphere as the starting point for ray marching.
      // This is critical to be after the above to not disrupt above atmosphere tests and voxel selection.      
      vec3 localWorldPos = worldPos + (worldDir * cloudsDepth); // move to the clouds depth as starting point
      if(MoveToTopAtmosphere(localWorldPos, worldDir, uAtmosphereParameters.atmosphereParameters.TopRadius)){

        mat4 skyInvViewProjMat = view.inverseViewMatrix * view.inverseProjectionMatrix;
        const bool ground = false;
        const float sampleCountIni = 0.0;
        const bool variableSampleCount = true;
        const bool mieRayPhase = true;
        SingleScatteringResult ss = IntegrateScatteredLuminance(
          uTransmittanceLutTexture,
          uMultiScatteringTexture,
          uAtmosphereMapTexture,
          uv, 
          localWorldPos, 
          worldDir, 
          sunDirection, 
          uAtmosphereParameters.atmosphereParameters, 
          ground, 
          sampleCountIni, 
          depthBufferValue, 
          variableSampleCount,  
          mieRayPhase,
          skyInvViewProjMat,
          -1.0, // infinite depth for ray length threshold
          reversedZ
        );

        addScatteringSample(ss.L, ss.Transmittance);

      }

      // Integrate clouds
      addScatteringSample(cloudsInscattering.xyz, cloudsTransmittance.xyz);
      targetDepth = cloudsDepth;

      // And then continue with the rest of the atmosphere as usual as if the clouds were not there 

    }//*/

    // Move to top atmosphere as the starting point for ray marching.
    // This is critical to be after the above to not disrupt above atmosphere tests and voxel selection.
    if(MoveToTopAtmosphere(worldPos, worldDir, uAtmosphereParameters.atmosphereParameters.TopRadius)){

      mat4 skyInvViewProjMat = view.inverseViewMatrix * view.inverseProjectionMatrix; 
      const bool ground = false;
      const float sampleCountIni = 0.0;
      const bool variableSampleCount = true;
      const bool mieRayPhase = true;
      SingleScatteringResult ss = IntegrateScatteredLuminance(
        uTransmittanceLutTexture,
        uMultiScatteringTexture,
        uAtmosphereMapTexture,
        uv, 
        worldPos, 
        worldDir, 
        sunDirection, 
        uAtmosphereParameters.atmosphereParameters, 
        ground, 
        sampleCountIni, 
        depthBufferValue, 
        variableSampleCount,  
        mieRayPhase,
        skyInvViewProjMat,
        targetDepth,
        reversedZ
      );

      addScatteringSample(ss.L, ss.Transmittance);
      
    }

  }

  if(cloudsValid){
    cloudsValid = false;
    addScatteringSample(cloudsInscattering.xyz, cloudsTransmittance.xyz);
  }

  if(countScatteringSamples > 0){

    vec3 inscattering = vec3(0.0);
    vec3 transmittance = vec3(1.0);

    // Important: The scatteringSamples array item order is from back to front

#if 1
    // Front to back
    for(int scatteringSampleIndex = countScatteringSamples - 1; scatteringSampleIndex >= 0; scatteringSampleIndex--){
      mat2x3 scatteringSample = scatteringSamples[scatteringSampleIndex];
      inscattering += scatteringSample[0] * transmittance;
      transmittance *= scatteringSample[1];
    }
#else
    // Back to front
    for(int scatteringSampleIndex = 0; scatteringSampleIndex < countScatteringSamples; scatteringSampleIndex++){
      mat2x3 scatteringSample = scatteringSamples[scatteringSampleIndex];
        inscattering = (inscattering * scatteringSample[1]) + scatteringSample[0];
        transmittance *= scatteringSample[1];
    }
#endif

    {
      float fadeFactor = clamp(uAtmosphereParameters.atmosphereParameters.AbsorptionExtinction.w, 0.0, 1.0);
      inscattering *= fadeFactor;
      transmittance = mix(vec3(1.0), transmittance, fadeFactor); 
    } 

    if(atmosphereCullingFactor < 1.0){
      inscattering = mix(vec3(0.0), inscattering, atmosphereCullingFactor);
      transmittance = mix(vec3(1.0), transmittance, atmosphereCullingFactor);
    }

#ifdef DUALBLEND
    outInscattering = vec4(clamp(inscattering, vec3(0.0), vec3(65504.0)), 1.0 - clamp(dot(transmittance, vec3(1.0 / 3.0)), 0.0, 1.0)); // clamp to 16-bit floating point range, alpha = 1.0 - transmittance sine it is applied directly to the actual content, where alpha is used in its usual normal way and not as monochromatic transmittance
    outTransmittance = vec4(vec3(clamp(transmittance, vec3(0.0), vec3(1.0))), 1.0); // clamp to normalized range
#else
    outInscattering = vec4(max(vec3(0.0), inscattering), 1.0 - clamp(dot(transmittance, vec3(1.0 / 3.0)), 0.0, 1.0)); // alpha = 1.0 - transmittance sine it is applied directly to the actual content, where alpha is used in its usual normal way and not as monochromatic transmittance
#endif

  }else{

    outInscattering = vec4(0.0, 0.0, 0.0, 0.0);
#ifdef DUALBLEND
    outTransmittance = vec4(1.0, 1.0, 1.0, 0.0);
#endif

  }
  
}