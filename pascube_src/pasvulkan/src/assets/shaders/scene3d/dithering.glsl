#ifndef DITHERING_GLSL
#define DITHERING_GLSL

#include "srgb.glsl"

vec3 ditheringWhiteNoise(ivec3 p){
  const uint k = 1103515245u;
  uvec3 v = uvec3(p); 
  v = ((v >> 8u) ^ v.yzx) * k;
  v = ((v >> 8u) ^ v.yzx) * k;
  v = ((v >> 8u) ^ v.yzx) * k;
  return fma(vec3(vec3(uintBitsToFloat(uvec3(uvec3(((v >> 9u) & uvec3(0x007fffffu)) | uvec3(0x3f800000u))))) - vec3(1.0)), vec3(2.0), vec3(-1.0));
}
   
vec3 ditheringPseudoBlueNoise(ivec3 p) {
  return clamp((vec3(
                ditheringWhiteNoise(p + ivec3(-1, -1, 0)) + 
                ditheringWhiteNoise(p + ivec3(0, -1, 0)) + 
                ditheringWhiteNoise(p + ivec3(1, -1, 0)) +
                ditheringWhiteNoise(p + ivec3(-1, 0, 0)) +
                (ditheringWhiteNoise(p) * (-8.0)) +
                 ditheringWhiteNoise(p + ivec3(1, 0, 0)) +
                ditheringWhiteNoise(p + ivec3(-1, 1, 0)) + 
                ditheringWhiteNoise(p + ivec3(0, 1, 0)) + 
                ditheringWhiteNoise(p + ivec3(1, 1, 0))
               ) * ((0.5 * 2.1) / 9.0)
              ) + vec3(0.5), vec3(0.0), vec3(1.0));
}

vec3 ditherSRGB(vec3 c, ivec2 coord, int frameCounter){
  vec3 n = fma(ditheringPseudoBlueNoise(ivec3(coord + ivec2(frameCounter), 0)).xyz, vec3(2.0), vec3(-1.0));
  n = sign(n) * (vec3(1.0) - sqrt(vec3(1.0) - abs(n)));
  return convertSRGBToLinearRGB(convertLinearRGBToSRGB(c) + vec3(n * (1.0 / 255.0)));  
}

vec4 ditherSRGB(vec4 c, ivec2 coord, int frameCounter){
  return vec4(ditherSRGB(c.xyz, coord, frameCounter), c.z);
}

#endif // DITHERING_GLSL