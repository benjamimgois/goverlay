#ifndef PLANET_TERRAIN_GLSL
#define PLANET_TERRAIN_GLSL

#define MESHLET_K 8u
#define MESHLET_VERT_COUNT ((MESHLET_K + 1u) * (MESHLET_K + 1u))
#define MESHLET_PRIM_COUNT (MESHLET_K * MESHLET_K * 2u)

// flags bit 3: meshlet debug colors
#define PLANET_TERRAIN_FLAG_MESHLET_DEBUG_COLORS 3u
// flags bit 4: enable per-tile frustum culling via visibility bitmap (only set for FinalView passes)
#define PLANET_TERRAIN_FLAG_FRUSTUM_CULL 4u
// flags bit 5: enable task-shader LOD (distance-based vertex stride; only set for FinalView passes)
#define PLANET_TERRAIN_FLAG_TASK_LOD 5u

#if defined(USE_BUFFER_REFERENCE)
  #define USE_PLANET_BUFFER_REFERENCE
#endif

#include "planet_data.glsl"

layout(push_constant) uniform PushConstants {

  // First uvec4
  uint viewBaseIndex;
  uint countViews;
  uint countQuadPointsInOneDirection;
  uint countAllViews;

  // Second uvec4
  uint resolutionXY;
  float tessellationFactor;
  uint timeSeconds;
  float timeFractionalSecond;

  // Third uvec4
  int frameIndex;
  uint flags;
#if defined(USE_BUFFER_REFERENCE)
  PlanetData planetData;
#else
  uvec2 unusedPlanetData;
#endif

  // Fourth uvec4
  vec4 jitter;

  // Fifth uvec4
  vec4 raytracingOffsetConstants;

} pushConstants;

#if defined(USE_BUFFER_REFERENCE)
PlanetData planetData = pushConstants.planetData;
#endif

#endif // PLANET_TERRAIN_GLSL
