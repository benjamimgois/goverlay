#ifndef PLANET_GRASS_GLSL
#define PLANET_GRASS_GLSL

layout(push_constant) uniform PushConstants {

  vec4 modelMatrixPositionScale; // xyz: position, w: scale

  vec4 modelMatrixOrientation; // quaternion

  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint maximalCountBladesPerPatch;
  
  float maximumDistance;
  float grassHeight;
  float grassThickness;
  float time;

  uint tileMapResolution;
  uint tileResolution;  
  uint flags; // bit 0: meshlet debug colors
  int frameIndex; 

  uint timeSeconds; // The current time in seconds
  float timeFractionalSecond; // The current time in fractional seconds
  float previousTime; // Previous time - used by VELOCITY to recalculate previous frame's wind/animation state
  uint raytracingFlags;

  uint maximalCountTaskIndices;
  uint maximalCountVertices;
  uint maximalCountIndices;
  uint invocationVariants;

  vec4 jitter;

} pushConstants;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endif
