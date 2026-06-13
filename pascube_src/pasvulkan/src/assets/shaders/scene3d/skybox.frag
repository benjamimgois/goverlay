#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec3 inPosition;
#ifdef SKYBOX_CACHED_REPROJECTION
layout(location = 1) in vec4 inPreviousClipSpacePosition;
#endif

layout(location = 0) out vec4 outFragColor;

layout (set = 0, binding = 1) uniform samplerCube uTexture;

#include "skybox.glsl"
#include "env_starlight.glsl"

float skyBoxFactor = pushConstants.skyBoxIntensityFactor * pushConstants.skyBoxBrightnessFactor;

#ifdef SKYBOX_CACHED_REPROJECTION
#ifdef SKYBOX_CACHED_REPROJECTION_RGB9E5
#include "rgb9e5.glsl"
#endif

#undef SKYBOX_CACHED_REPROJECTION_DEBUG       

#ifdef SKYBOX_CACHED_REPROJECTION_DEBUG       
#define getStarlight getStarlightDebug
vec3 getStarlightDebug(const vec3 worldDirection){
  return vec3(fma(vec3(normalize(worldDirection)), vec3(0.5), vec3(0.5))); // Debug: visualize direction as color
}
#endif

// Reprojection for cached starlight rendering
// Uses previous clip space position from vertex shader (interpolated)
vec4 reprojectStarlight(const vec3 worldDirection, const vec2 currentUV, const ivec2 screenSize) {
  
  // Previous clip position comes from vertex shader, properly interpolated
  vec4 previousClip = inPreviousClipSpacePosition;
  
  // Perspective divide
  vec2 previousNDC = previousClip.xy / previousClip.w;
  
  // Convert to UV [0,1]
  vec2 previousUV = fma(previousNDC, vec2(0.5), vec2(0.5));
  
  // Check if the previous UV is within valid screen bounds
  // Using a 1-pixel margin to avoid edge artifacts
  vec2 margin = 1.0 / vec2(screenSize);
  bool isValid = all(greaterThanEqual(previousUV, margin)) && 
                 all(lessThanEqual(previousUV, vec2(1.0) - margin));
  
  // Also reject if behind camera in previous frame
  // For direction vectors with w=0, clip.w = -viewDir.z, so positive w means forward-facing (viewDir.z < 0)
  isValid = isValid && (previousClip.w > 0.0);

  // Reject if the reprojection moved too far (indicates large rotation or feedback risk)
  vec2 motionVector = abs(previousUV - currentUV);
  bool tooMuchMotion = any(greaterThan(motionVector, vec2(0.15))); // 15% of screen max movement
  isValid = isValid && !tooMuchMotion;
  
  // Stochastic refresh: periodically recompute some pixels to avoid precision drift
  // Using a simple pattern based on frame index and pixel position
  uvec2 pixelCoord = uvec2(currentUV * vec2(screenSize));
  uint refreshPattern = (pixelCoord.x ^ pixelCoord.y ^ pushConstants.frameIndex) & 0x3fu; // Every 64 frames per pixel
  bool forceRefresh = (refreshPattern == 0u);
  
  if(isValid && !forceRefresh){
    // Sample from history buffer
    vec3 historyCoord = vec3(previousUV, float(gl_ViewIndex));
    vec4 historySample = texture(uHistoryTexture, historyCoord);
#ifdef SKYBOX_CACHED_REPROJECTION_RGBA16F
    // For RGBA16F: alpha = 0 means pixel was never written (cleared before draw)
    // This catches hidden/off-screen pixels from previous frame
    if(historySample.a < 0.5){
      // Pixel was not rendered in previous frame, recompute
      return vec4(clamp(getStarlight(worldDirection) * skyBoxFactor, vec3(-65504.0), vec3(65504.0)), 1.0);
    }else{
#ifdef SKYBOX_CACHED_REPROJECTION_DEBUG       
      historySample.xy = vec2(0.0); // debug scaling to visualize history usage 
#endif
      return historySample;
    }
#elif defined(SKYBOX_CACHED_REPROJECTION_RGB9E5)
    // For RGB9E5: all zeros means pixel was never written (cleared before draw)
    // Pure black sky is physically impossible, so this is a safe sentinel
    if(all(equal(historySample.rgb, vec3(0.0)))){
      // Pixel was not rendered in previous frame, recompute
      return vec4(clamp(getStarlight(worldDirection) * skyBoxFactor, vec3(-65504.0), vec3(65504.0)), 1.0);
    }else{
#ifdef SKYBOX_CACHED_REPROJECTION_DEBUG       
      historySample.xy = vec2(0.0); // debug scaling to visualize history usage 
#endif
      return historySample;
    }
#else    
    return historySample;
#endif
  }else{
    // Compute fresh starlight for this pixel (alpha = 1.0 marks as valid)
    return vec4(clamp(getStarlight(worldDirection) * skyBoxFactor, vec3(-65504.0), vec3(65504.0)), 1.0);
  }
}

#endif

void main(){
  const vec3 direction = normalize(inPosition);
  switch(pushConstants.mode){
    case 1u:{
      // Realtime starlight
#ifdef SKYBOX_CACHED_REPROJECTION
      // Cached reprojection mode: reuse previous frame where possible
      ivec2 screenSize = ivec2(pushConstants.widthHeight & 0xFFFFu, pushConstants.widthHeight >> 16u);
      vec2 currentUV = gl_FragCoord.xy / vec2(screenSize);
      outFragColor = reprojectStarlight(direction, currentUV, screenSize);
      // Store result to history image for next frame
#if defined(SKYBOX_CACHED_REPROJECTION_RGB9E5)
      // Use max() to ensure we never encode to zero (our sentinel for unwritten pixels)
      const vec3 minRGB9E5 = vec3(6.1e-5); // Minimum non-zero RGB9E5 representable value
      imageStore(uHistoryImage, ivec3(gl_FragCoord.xy, gl_ViewIndex), uvec4(encodeRGB9E5(max(outFragColor.rgb, minRGB9E5))));
#elif defined(SKYBOX_CACHED_REPROJECTION_RGBA16F)
      imageStore(uHistoryImage, ivec3(gl_FragCoord.xy, gl_ViewIndex), outFragColor);
#else
#error "SKYBOX_CACHED_REPROJECTION requires either SKYBOX_CACHED_REPROJECTION_RGB9E5 or SKYBOX_CACHED_REPROJECTION_RGBA16F"
#endif
#else
      // Full computation every frame
      outFragColor = vec4(clamp(getStarlight(direction) * skyBoxFactor, vec3(-65504.0), vec3(65504.0)), 1.0);
#endif
      break;
    }
    case 2u:{
      // Transparent color key magenta 
      outFragColor = vec4(1.0, 0.0, 1.0, 1.0);
      break;
    }
    default:{
      // Cube map
      vec4 color = texture(uTexture, direction) * vec2(pushConstants.skyBoxBrightnessFactor, 1.0).xxxy; // no pre-multiplied skyBoxIntensityFactor here, because it is already baked into the cube map
      outFragColor = vec4(clamp(color.xyz, vec3(-65504.0), vec3(65504.0)), color.w);
#ifdef SKYBOX_CACHED_REPROJECTION
      // Also store cube map result to history for consistency
#if defined(SKYBOX_CACHED_REPROJECTION_RGB9E5)
      // Use max() to ensure we never encode to zero (our sentinel for unwritten pixels)
      const vec3 minRGB9E5 = vec3(6.1e-5); // Minimum non-zero RGB9E5 representable value
      imageStore(uHistoryImage, ivec3(gl_FragCoord.xy, gl_ViewIndex), uvec4(encodeRGB9E5(max(outFragColor.rgb, minRGB9E5))));
#elif defined(SKYBOX_CACHED_REPROJECTION_RGBA16F)
      imageStore(uHistoryImage, ivec3(gl_FragCoord.xy, gl_ViewIndex), outFragColor);
#else
#error "SKYBOX_CACHED_REPROJECTION requires either SKYBOX_CACHED_REPROJECTION_RGB9E5 or SKYBOX_CACHED_REPROJECTION_RGBA16F"
#endif
#endif
      break;
    } 
  }
}