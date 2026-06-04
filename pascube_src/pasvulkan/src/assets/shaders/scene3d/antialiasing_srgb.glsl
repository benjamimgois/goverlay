#ifndef ANTIALIASING_SRGB_GLSL
#define ANTIALIASING_SRGB_GLSL

#include "bidirectional_tonemapping.glsl"

#include "srgb.glsl"

vec4 SRGBin(vec4 color) {
  return convertLinearRGBToSRGB(ApplyToneMapping(color));
}

vec4 SRGBout(vec4 color) {
  return ApplyInverseToneMapping(convertSRGBToLinearRGB(color));
}

vec4 SRGBTextureGet(const in sampler2DArray tex, const in vec3 texCoord, const in int lod, const in ivec2 offset, const in ivec2 texSize){
  const ivec2 maxTexCoord = texSize - ivec2(1);
  const vec3 uv = vec3(fma(texCoord.xy, vec2(texSize), vec2(-0.5)), texCoord.z);
  const ivec3 baseCoord = ivec3(floor(uv.xyz)) + ivec3(offset, 0);
  const vec2 fractionalPart = uv.xy - vec2(baseCoord.xy);
  vec4 t0 = SRGBin(texelFetch(tex, ivec3(clamp(baseCoord.xy + ivec2(0, 0), ivec2(0), maxTexCoord), baseCoord.z), lod));
  vec4 t1 = SRGBin(texelFetch(tex, ivec3(clamp(baseCoord.xy + ivec2(1, 0), ivec2(0), maxTexCoord), baseCoord.z), lod));
  vec4 t2 = SRGBin(texelFetch(tex, ivec3(clamp(baseCoord.xy + ivec2(0, 1), ivec2(0), maxTexCoord), baseCoord.z), lod));
  vec4 t3 = SRGBin(texelFetch(tex, ivec3(clamp(baseCoord.xy + ivec2(1, 1), ivec2(0), maxTexCoord), baseCoord.z), lod));
  return mix(mix(t0, t1, fractionalPart.x), mix(t2, t3, fractionalPart.x), fractionalPart.y);
}

vec4 SRGBawareTexture(sampler2DArray tex, vec3 texCoord, float lod) {

  const int intlod = int(lod);

  const ivec2 texSize = textureSize(tex, intlod).xy;

#if 1 
  
  return SRGBout(SRGBTextureGet(tex, texCoord, intlod, ivec2(0, 0), texSize));

#else  
  
  texCoord.xy *= vec2(texSize);
  
  vec2 texelCenter = floor(texCoord.xy - vec2(0.5)) + vec2(0.5);
  
  vec2 fracTexCoords = texCoord.xy - texelCenter;

  texCoord.xy = texelCenter / vec2(texSize);
  
  vec4 t0 = SRGBin(textureOffset(tex, texCoord, ivec2(0, 0), lod));
  vec4 t1 = SRGBin(textureOffset(tex, texCoord, ivec2(1, 0), lod));
  vec4 t2 = SRGBin(textureOffset(tex, texCoord, ivec2(0, 1), lod));
  vec4 t3 = SRGBin(textureOffset(tex, texCoord, ivec2(1, 1), lod));

  vec4 r = SRGBout(mix(mix(t0, t1, fracTexCoords.x), mix(t2, t3, fracTexCoords.x), fracTexCoords.y));
  return r;
#endif
}
 
vec4 SRGBGammaCorrectedTexture(sampler2DArray tex, vec3 texCoord, float lod) {
  
  const int intlod = int(lod);
  
  const ivec2 texSize = textureSize(tex, intlod).xy;

#if 1 

  return SRGBTextureGet(tex, texCoord, intlod, ivec2(0, 0), texSize);

#else

  texCoord.xy *= vec2(texSize);
  
  vec2 texelCenter = floor(texCoord.xy - vec2(0.5)) + vec2(0.5);
  
  vec2 fracTexCoords = texCoord.xy - texelCenter;

  texCoord.xy = texelCenter / vec2(texSize);
  
  vec4 t0 = SRGBin(textureOffset(tex, texCoord, ivec2(0, 0), lod));
  vec4 t1 = SRGBin(textureOffset(tex, texCoord, ivec2(1, 0), lod));
  vec4 t2 = SRGBin(textureOffset(tex, texCoord, ivec2(0, 1), lod));
  vec4 t3 = SRGBin(textureOffset(tex, texCoord, ivec2(1, 1), lod));

  vec4 r = mix(mix(t0, t1, fracTexCoords.x), mix(t2, t3, fracTexCoords.x), fracTexCoords.y);
  return r;

#endif
}
 
vec4 SRGBGammaCorrectedTextureOffset(sampler2DArray tex, vec3 texCoord, float lod, ivec2 offset) {

  const int intlod = int(lod);

  const ivec2 texSize = textureSize(tex, intlod).xy;

#if 1

  return SRGBTextureGet(tex, texCoord, intlod, offset, texSize);

#else
  
  texCoord.xy *= vec2(texSize);
  
  vec2 texelCenter = floor(texCoord.xy - vec2(0.5)) + vec2(0.5) + vec2(offset);
  
  vec2 fracTexCoords = texCoord.xy - texelCenter;

  texCoord.xy = texelCenter / vec2(texSize);
  
  vec4 t0 = SRGBin(textureOffset(tex, texCoord, ivec2(0, 0), lod));
  vec4 t1 = SRGBin(textureOffset(tex, texCoord, ivec2(1, 0), lod));
  vec4 t2 = SRGBin(textureOffset(tex, texCoord, ivec2(0, 1), lod));
  vec4 t3 = SRGBin(textureOffset(tex, texCoord, ivec2(1, 1), lod));

  vec4 r = mix(mix(t0, t1, fracTexCoords.x), mix(t2, t3, fracTexCoords.x), fracTexCoords.y);
  return r;

#endif
}
 
#endif 