#ifndef SKYBOX_GLSL
#define SKYBOX_GLSL

layout(push_constant) uniform PushConstants {

  vec4 currentOrientation;
  vec4 previousOrientation;
  
  vec4 lightDirection;

  uint viewBaseIndex;  //
  uint countViews;     //
  float skyBoxBrightnessFactor; //
  uint widthHeight;    // low 16 bits: width, high 16 bits: height

  uint mode;           // 0: cube map, 1: realtime starlight
  // Cached reprojection fields (always present, GLSL can truncate at pipeline layout level)
  uint countAllViews;  // Total view count, previous views stored at [viewBaseIndex + countAllViews]
  uint frameIndex;     // For stochastic refresh
  float skyBoxIntensityFactor;

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

#ifdef SKYBOX_CACHED_REPROJECTION

// History buffer from previous frame for reading
layout(set = 0, binding = 2) uniform sampler2DArray uHistoryTexture;

// History image for writing current frame result
#if defined(SKYBOX_CACHED_REPROJECTION_RGB9E5)
// R32_UINT alias for RGB9E5 encoding
layout(set = 0, binding = 3, r32ui) uniform writeonly uimage2DArray uHistoryImage;
#elif defined(SKYBOX_CACHED_REPROJECTION_RGBA16F)
// RGBA16F format
layout(set = 0, binding = 3, rgba16f) uniform writeonly image2DArray uHistoryImage;
#else
#error "SKYBOX_CACHED_REPROJECTION requires either SKYBOX_CACHED_REPROJECTION_RGB9E5 or SKYBOX_CACHED_REPROJECTION_RGBA16F"
#endif

#endif

#endif