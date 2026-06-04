#ifndef PLANET_PLANTS_GLSL
#define PLANET_PLANTS_GLSL

struct PlantType {
  uvec4 colorFactorTextureSetIndex;  // xyz = colorFactor, w = textureSetIndex
  uvec4 growthSpeedSoundIndexFlags;  // x = growthSpeed, y = soundIndex, z = flags
  vec4 boundingCapsuleRadiusHeight; // x = radius, y = height, zw = unused
  vec4 reserved;
};

#if 1
#define PlantInstance uvec4
#define PlantInstanceGetPosition(p) (uintBitsToFloat(p.xy))
#define PlantInstanceGetTime(p) (uintBitsToFloat(p.z))
#define PlantInstanceGetType(p) (uint(p.w & 0xffffu))
#define PlantInstanceGetHealth(p) (uint((p.w >> 16) & 0x3u))
#define PlantInstanceGetInfected(p) (uint((p.w >> 18) & 0x1u))
#else
struct PlantInstance { 
  vec2 position; 
  float time; 
  uint typeHealthInfected;
};
#define PlantInstanceGetPosition(p) (p.position)
#define PlantInstanceGetTime(p) (p.time)
#define PlantInstanceGetType(p) (uint(p.typeHealthInfected & 0xffffu))
#define PlantInstanceGetHealth(p) (uint((p.typeHealthInfected >> 16) & 0x3u))
#define PlantInstanceGetInfected(p) (uint((p.typeHealthInfected >> 18) & 0x1u))
#endif

#endif

