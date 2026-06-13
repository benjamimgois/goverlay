#ifndef PLANET_RENDERPASS_GLSL
#define PLANET_RENDERPASS_GLSL

#if !defined(USE_BUFFER_REFERENCE) 
#undef USE_PLANET_BUFFER_REFERENCE
#include "planet_data.glsl"
#endif

#if defined(PLANET_WATER)
layout(push_constant) uniform PushConstants {

  // First uvec4
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint countQuadPointsInOneDirection; 
  
  // Second uvec4
  uint resolutionXY;  
  float tessellationFactor; // = factor / referenceMinEdgeSize, for to avoid at least one division in the shader 
  uint tileMapResolution;
  uint flags; // General flags (raytracing, debug, etc.)

  // Third uvec4
  int frameIndex; 
  float time;
#if defined(USE_BUFFER_REFERENCE) 
  PlanetData planetData;
#else
  uvec2 unusedPlanetData; // Ignored in this case  
#endif

  // Fourth uvec4 
  vec4 jitter;

  // Fifth uvec4
  float splashDensity;
  float rainIntensity;
  float paddingWater0;
  float paddingWater1;
  
} pushConstants;

#else
layout(push_constant) uniform PushConstants {

  // First uvec4
  uint viewBaseIndex;
  uint countViews;
  uint countQuadPointsInOneDirection; 
  uint countAllViews;
  
  // Second uvec4
  uint resolutionXY;  
  float tessellationFactor; // = factor / referenceMinEdgeSize, for to avoid at least one division in the shader 
  uint timeSeconds; // The current time in seconds
  float timeFractionalSecond; // The current time in fractional seconds

  // Third uvec4 
  int frameIndex; 
  uint flags; // General flags (raytracing, debug, etc.)
#if defined(USE_BUFFER_REFERENCE) 
  PlanetData planetData;
#else
  uvec2 unusedPlanetData; // Ignored in this case  
#endif

  // Fourth uvec4
  vec4 jitter;

  // Fifth uvec4
  vec4 raytracingOffsetConstants; // x: origin, y: floatScale, z: intScale, w: directionScale

} pushConstants;
#endif // defined(PLANET_WATER)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if defined(USE_BUFFER_REFERENCE) 
PlanetData planetData = pushConstants.planetData; // For to avoid changing the code below
#endif

#if !defined(PLANET_WATER)
#include "planet_displacement.glsl"
#endif // !defined(PLANET_WATER)

#endif
