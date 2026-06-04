#ifndef PLANET_MAP_GLSL
#define PLANET_MAP_GLSL

#include "octahedral.glsl"

int totalResolution = int(uint(pushConstants.tileMapResolution * pushConstants.tileResolution));

vec3 correctedOctPlanetUnsignedDecode(ivec2 coordinate){
#if 1
  if(any(equal(coordinate, ivec2(totalResolution - 1)))){
    // Correct the coordinate at the border to avoid artifacts at the border that are caused by the octahedral wrapping 
    // when the normal is calculated because it is too dense at the border then.
    if(coordinate.x == (totalResolution - 1)){
      if(coordinate.y == (totalResolution - 1)){
        // TODO: Check if this is correct
        return octPlanetUnsignedDecode((vec2(coordinate) + vec2(-0.5)) / vec2(totalResolution)); 
      }else{
        return octPlanetUnsignedDecode((vec2(coordinate) + vec2(-0.5, 0.0)) / vec2(totalResolution)); 
      }
    }else{ //if(coordinate.y == (totalResolution - 1)){
      return octPlanetUnsignedDecode((vec2(coordinate) + vec2(0.0, -0.5)) / vec2(totalResolution)); 
    }
  }else{
    // Just pass through, because it's not at the border, so it's not corrected here to avoid artifacts at the border.
    return octPlanetUnsignedDecode(vec2(coordinate) / vec2(totalResolution));  
  }
#else
  return octPlanetUnsignedDecode(vec2(coordinate) / vec2(totalResolution));
#endif
}

#if defined(PLANET_GRASS)
  #define PLANET_TEX_HEIGHT_MAP uPlanetTextures[0]
#elif defined(PLANET_MESH)
  #define PLANET_TEX_HEIGHT_MAP uTextureHeightMap
#else
  #error "No shader type defined"
#endif

float getHeightAt(ivec2 coordinate){
#if 1
  ivec2 xy = coordinate << ivec2(pushConstants.lod);
  if(any(equal(xy, ivec2(totalResolution - 1)))){
    // Correct the coordinate at the border to avoid artifacts at the border that are caused by the octahedral wrapping 
    // when the normal is calculated because it is too dense at the border then.
    if(xy.x == (totalResolution - 1)){
      if(xy.y == (totalResolution - 1)){
        // TODO: Check if this is correct
        return mix(texelFetch(PLANET_TEX_HEIGHT_MAP, xy - ivec2(1), 0).x, texelFetch(PLANET_TEX_HEIGHT_MAP, xy, 0).x, 0.5);
      }else{
        return mix(texelFetch(PLANET_TEX_HEIGHT_MAP, xy - ivec2(1, 0), 0).x, texelFetch(PLANET_TEX_HEIGHT_MAP, xy, 0).x, 0.5);
      }
    }else{// if(xy.y == (totalResolution - 1)){
      return mix(texelFetch(PLANET_TEX_HEIGHT_MAP, xy - ivec2(0, 1), 0).x, texelFetch(PLANET_TEX_HEIGHT_MAP, xy, 0).x, 0.5);
    }
  }else{
    // Just pass through, because it's not at the border, so it's not corrected here to avoid artifacts at the border.
    return texelFetch(PLANET_TEX_HEIGHT_MAP, xy, 0).x;
  }
#else
  return texelFetch(PLANET_TEX_HEIGHT_MAP, coordinate << ivec2(pushConstants.lod), 0).x;
#endif
}

#endif // PLANET_MAP_GLSL