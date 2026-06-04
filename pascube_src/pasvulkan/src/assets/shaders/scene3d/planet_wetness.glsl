#ifndef PLANET_WETNESS_GLSL
#define PLANET_WETNESS_GLSL

#include "octahedral.glsl"
#include "octahedralmap.glsl"
 
vec4 getWetness(vec3 position){

  vec3 normalizedPosition = normalize(position);
  
  float precipitation = texturePlanetOctahedralMap(uPlanetTextures[PLANET_TEXTURE_PRECIPITATIONMAP], normalizedPosition).x;
  float atmosphere = texturePlanetOctahedralMap(uPlanetTextures[PLANET_TEXTURE_ATMOSPHEREMAP], normalizedPosition).x; 

  return vec4(max(0.0, precipitation) * atmosphere, normalizedPosition); 

}

#endif