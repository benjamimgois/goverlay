#ifndef PLANET_WATER_SIMULATION_GLSL
#define PLANET_WATER_SIMULATION_GLSL

#extension GL_GOOGLE_include_directive : enable

#undef USE_COMPACT_FLOW // don't work correctly yet, so disabled for now

layout(push_constant) uniform PushConstants {

  float attenuation; // The attenuation factor for the water flow, used to scale the water flow based on the height difference
  float strength; // The strength of the water flow, used to scale the water flow based on the height difference
  float minTotalFlow; // The minimum total flow, used to prevent the water flow from being too low
  float initialWaterLevel; // The initial water level, used to set the initial water height in the simulation     

  float pipeLengthSquared; // The squared length of the pipe, used to calculate the water flow based on the height difference
  float crossSectionalPipeArea; // The cross-sectional area of the pipe, used to calculate the water flow based on the height difference
  float gravity; // The gravitational acceleration, used to calculate the water flow based on the height difference
  float evaporation; // The evaporation rate, used to calculate the evaporation based on the water height   
  
  float evaporationHeightCoefficient; // The coefficient for the evaporation height, used to calculate the evaporation based on the water height (not in the original paper, but added for more controllable evaporation in game-related scenarios)
  float compensationFactor; // The compensation factor for the
  float bottomRadius; // The radius of the bottom of the planet height map
  float topRadius; // The radius of the top of the planet height map
  
  float deltaTime; // The time step in seconds, used to scale the simulation time
  float rainIntensity; // The rain intensity, used to scale the rain map values
  float scale; // The scale of the noise, used to scale the noise values for the rain fall noise 
  float timeScale; // The time scale for the rain fall simulation, used to scale the time step
  
  uint planetHeightMapResolution; // The resolution of the planet height map, used to calculate the indices for the height map  
  uint waterHeightMapResolution; // The resolution of the water height map, used to calculate the indices for the water height map
  uint waterHeightMapBorder; // The border size for the water height map, so that the solver does not need to handle the border cases of a octahedral map
  uint precipitationAtmosphereMapResolution; // The resolution of the precipitation atmosphere map

  uint precipitationAtmosphereMapShift; // The shift for the precipitation atmosphere map relative to the water height map
  uint frameIndex; // The current frame index, used for random number generation

} pushConstants;

uint waterHeightMapResolutionWithBorder = pushConstants.waterHeightMapResolution + (pushConstants.waterHeightMapBorder * 2);

#ifdef USE_HEIGHTMAP_BUFFER
// For Non-NVIDIA GPUs where VK_SHARING_MODE_CONCURRENT on images costs performance, where the planet height map is hold in an additional buffer
// and the height map is read from the buffer instead of the image. Costs more memory, but is faster on those GPUs. It must be a complete copy of the
// planet height map, because the actual height map is also used  at the rendering pass for the planet at the same time, so we need to have a copy of 
// it in form of a buffer for the simulation pass for to be able to work it in parallel with the rendering pass. 
layout(set = 0, binding = 0) readonly buffer InPlanetHeightMap {
  float values[];
} inPlanetHeightMap;
#else
// For NVIDIA GPUs where VK_SHARING_MODE_CONCURRENT on images is practically free. And we can save the ownershiip transfer overhead by using
// the image directly.
layout(set = 0, binding = 0) uniform sampler2D uPlanetHeightmap;
#endif

#if 0
#define _float float16_t
#define _vec4 f16vec4
#else
#define _float float
#ifdef USE_FP16
#define _vec4 f16vec4
#else
#define _vec4 vec4
#endif
#endif

layout(set = 0, binding = 1, std430) readonly buffer InWaterHeightMap {
  _float values[];
} inWaterHeightMap;

layout(set = 0, binding = 2, std430) writeonly buffer OutWaterHeightMap {
  _float values[];
} outWaterHeightMap;

#ifdef READONLY_WATERFLOW
layout(set = 0, binding = 3, std430) readonly buffer WaterFlowMap {
  _vec4 values[];
} waterFlowMap;
#else
layout(set = 0, binding = 3, std430) coherent buffer WaterFlowMap {
  _vec4 values[];
} waterFlowMap;
#endif

layout(set = 0, binding = 4, std430) coherent buffer WaterMaxHeightDifference {
  uint value;
} waterMaxHeightDifference;

layout(set = 0, binding = 5, std430) buffer PrecipitationAtmosphereMap {
  _float values[];
} precipitationAtmosphereMap;

#include "pcg.glsl"

#include "octahedral.glsl"
#include "octahedralmap.glsl"

vec2 texelSize = 1.0 / vec2(pushConstants.waterHeightMapResolution);

uint getIndex(ivec2 position){
  const ivec2 intPosition = wrapOctahedralTexelCoordinates(ivec2(position), ivec2(pushConstants.waterHeightMapResolution));  
  return (intPosition.y * pushConstants.waterHeightMapResolution) + intPosition.x;
}

uint getFlowMapIndex(ivec2 position){
  position = (((position + ivec2(int(pushConstants.waterHeightMapBorder))) % ivec2(int(waterHeightMapResolutionWithBorder))) + ivec2(int(waterHeightMapResolutionWithBorder))) % ivec2(int(waterHeightMapResolutionWithBorder));
  return (position.y * waterHeightMapResolutionWithBorder) + position.x;
}

#endif