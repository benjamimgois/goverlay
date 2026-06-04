#ifndef OCTAHEDRALMAP_GLSL
#define OCTAHEDRALMAP_GLSL

#include "textureutils.glsl"

#include "octahedral.glsl"

vec4 textureOctahedralMap(const in sampler2D tex, vec3 direction) {
  direction = normalize(direction); // just for to make sure that it is normalized 
  vec2 uv = direction.xy / (abs(direction.x) + abs(direction.y) + abs(direction.z));
  uv = fma((direction.z < 0.0) ? ((1.0 - abs(uv.yx)) * vec2((uv.x >= 0.0) ? 1.0 : -1.0, (uv.y >= 0.0) ? 1.0 : -1.0)) : uv, vec2(0.5), vec2(0.5));
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
   // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   return mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), 0), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), 0), fractionalPart.x), 
              mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), 0), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), 0), fractionalPart.x), fractionalPart.y);
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, uv, 0.0);
  }
}

vec4 textureOctahedralMap(const in sampler2D tex, vec3 direction, const in int lod) {
  direction = normalize(direction); // just for to make sure that it is normalized 
  vec2 uv = direction.xy / (abs(direction.x) + abs(direction.y) + abs(direction.z));
  uv = fma((direction.z < 0.0) ? ((1.0 - abs(uv.yx)) * vec2((uv.x >= 0.0) ? 1.0 : -1.0, (uv.y >= 0.0) ? 1.0 : -1.0)) : uv, vec2(0.5), vec2(0.5));
  ivec2 texSize = textureSize(tex, lod).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
   // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   return mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), lod), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), lod), fractionalPart.x), 
              mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), lod), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), lod), fractionalPart.x), fractionalPart.y);
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, uv, float(lod));
  }
}

#ifdef FRAGMENT_SHADER
vec4 textureMipMapOctahedralMap(const in sampler2D tex, vec3 direction) {
  direction = normalize(direction); // just for to make sure that it is normalized 
  vec2 uv = direction.xy / (abs(direction.x) + abs(direction.y) + abs(direction.z));
  uv = fma((direction.z < 0.0) ? ((1.0 - abs(uv.yx)) * vec2((uv.x >= 0.0) ? 1.0 : -1.0, (uv.y >= 0.0) ? 1.0 : -1.0)) : uv, vec2(0.5), vec2(0.5));
  vec2 uvInt = uv * vec2(textureSize(tex, 0).xy);
  vec2 uvdx = dFdx(uv);
  vec2 uvdy = dFdy(uv);  
  float mipMapLevel = max(0.0, log2(max(dot(uvdx, uvdx), dot(uvdy, uvdy))) * 0.5); //textureQueryLod(tex, uv).x;
  ivec2 texSize = textureSize(tex, int(mipMapLevel)).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
    // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
    uv = fma(uv, texSize, vec2(-0.5));
    int maxMipMapLevel = int(floor(log2(max(float(texSize.x), float(texSize.y)))));
    ivec2 baseCoord = ivec2(floor(uv));
    vec2 fractionalPart = uv - vec2(baseCoord);   
    int mipMapLevelInt = int(mipMapLevel);
    float mipMapLevelFraction = mipMapLevel - float(mipMapLevelInt);
    int nextMipMapLevelInt = min(mipMapLevelInt + 1, maxMipMapLevel);
    if((mipMapLevelFraction == 0.0) || (nextMipMapLevelInt == mipMapLevelInt)){
      return mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), mipMapLevelInt), 
                     texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), mipMapLevelInt), fractionalPart.x), 
                 mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), mipMapLevelInt), 
                     texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), mipMapLevelInt), fractionalPart.x), fractionalPart.y);
    }else{
      return mix(mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), mipMapLevelInt), 
                         texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), mipMapLevelInt), fractionalPart.x), 
                     mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), mipMapLevelInt), 
                         texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), mipMapLevelInt), fractionalPart.x), fractionalPart.y), 
                 mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), nextMipMapLevelInt), 
                         texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), nextMipMapLevelInt), fractionalPart.x), 
                     mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), nextMipMapLevelInt), 
                         texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), nextMipMapLevelInt), fractionalPart.x), fractionalPart.y), mipMapLevelFraction);
    }
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, uv, mipMapLevel);
  }
}
#endif

vec4 textureCatmullRomOctahedralMap(const in sampler2D tex, vec3 direction) {
  direction = normalize(direction); // just for to make sure that it is normalized 
  vec2 uv = direction.xy / (abs(direction.x) + abs(direction.y) + abs(direction.z));
  uv = fma((direction.z < 0.0) ? ((1.0 - abs(uv.yx)) * vec2((uv.x >= 0.0) ? 1.0 : -1.0, (uv.y >= 0.0) ? 1.0 : -1.0)) : uv, vec2(0.5), vec2(0.5));
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if(any(lessThanEqual(uv, invTexSize * 2.0)) || any(greaterThanEqual(uv, vec2(1.0) - (invTexSize * 2.0)))){
   // Handle edges with manual catmull rom interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   vec4 xCoefficients = textureCatmullRomCoefficents(fractionalPart.x);
   vec4 yCoefficients = textureCatmullRomCoefficents(fractionalPart.y);
   return (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1, -1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0, -1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1, -1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2, -1), texSize), 0) * xCoefficients.w)) * yCoefficients.x) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  0), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  0), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  0), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  0), texSize), 0) * xCoefficients.w)) * yCoefficients.y) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  1), texSize), 0) * xCoefficients.w)) * yCoefficients.z) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  2), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  2), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  2), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  2), texSize), 0) * xCoefficients.w)) * yCoefficients.w);
  }else{
    // Non-edge texels can be sampled directly with an optimized catmull rom interpolation using just nine bilinear textureLod calls
    return textureCatmullRom(tex, uv, 0);
  }
}

vec4 textureCatmullRomOctahedralMap(const in sampler2D tex, vec3 direction, const in int lod) {
  direction = normalize(direction); // just for to make sure that it is normalized 
  vec2 uv = direction.xy / (abs(direction.x) + abs(direction.y) + abs(direction.z));
  uv = fma((direction.z < 0.0) ? ((1.0 - abs(uv.yx)) * vec2((uv.x >= 0.0) ? 1.0 : -1.0, (uv.y >= 0.0) ? 1.0 : -1.0)) : uv, vec2(0.5), vec2(0.5));
  ivec2 texSize = textureSize(tex, lod).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if(any(lessThanEqual(uv, invTexSize * 2.0)) || any(greaterThanEqual(uv, vec2(1.0) - (invTexSize * 2.0)))){
   // Handle edges with manual catmull rom interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   vec4 xCoefficients = textureCatmullRomCoefficents(fractionalPart.x);
   vec4 yCoefficients = textureCatmullRomCoefficents(fractionalPart.y);
   return (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1, -1), texSize), lod) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0, -1), texSize), lod) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1, -1), texSize), lod) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2, -1), texSize), lod) * xCoefficients.w)) * yCoefficients.x) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  0), texSize), lod) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  0), texSize), lod) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  0), texSize), lod) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  0), texSize), lod) * xCoefficients.w)) * yCoefficients.y) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  1), texSize), lod) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  1), texSize), lod) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  1), texSize), lod) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  1), texSize), lod) * xCoefficients.w)) * yCoefficients.z) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  2), texSize), lod) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  2), texSize), lod) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  2), texSize), lod) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  2), texSize), lod) * xCoefficients.w)) * yCoefficients.w);
  }else{
    // Non-edge texels can be sampled directly with an optimized catmull rom interpolation using just nine bilinear textureLod calls
    return textureCatmullRom(tex, uv, lod);
  }
}

// ---

vec4 texturePlanetOctahedralMap(const in sampler2D tex, vec3 direction) {
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  vec2 uv = octPlanetUnsignedEncode(direction) + (vec2(0.5) * invTexSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
   // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   return mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), 0), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), 0), fractionalPart.x), 
              mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), 0), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), 0), fractionalPart.x), fractionalPart.y);
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, uv, 0.0);
  }
}

vec4 texturePlanetOctahedralMap(const in sampler2D tex, vec2 uv) {
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
   // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   return mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), 0), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), 0), fractionalPart.x), 
              mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), 0), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), 0), fractionalPart.x), fractionalPart.y);
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, uv, 0.0);
  }
}

vec4 texturePlanetOctahedralMap(const in sampler2D tex, vec3 direction, const in int lod) {
  ivec2 texSize = textureSize(tex, lod).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  vec2 uv = octPlanetUnsignedEncode(direction) + (vec2(0.5) * invTexSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
   // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   return mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), lod), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), lod), fractionalPart.x), 
              mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), lod), 
                  texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), lod), fractionalPart.x), fractionalPart.y);
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, uv, float(lod));
  }
}

vec4 texturePlanetOctahedralMapArray(const in sampler2DArray tex, vec3 direction, const int arrayIndex) {
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  vec2 uv = octPlanetUnsignedEncode(direction) + (vec2(0.5) * invTexSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
   // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   return mix(mix(texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), arrayIndex), 0), 
                  texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), arrayIndex), 0), fractionalPart.x), 
              mix(texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), arrayIndex), 0), 
                  texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), arrayIndex), 0), fractionalPart.x), fractionalPart.y);
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, vec3(uv, float(arrayIndex)), 0.0);
  }
}

vec4 texturePlanetOctahedralMapArray(const in sampler2DArray tex, vec2 uv, const int arrayIndex) {
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
   // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   return mix(mix(texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), arrayIndex), 0), 
                  texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), arrayIndex), 0), fractionalPart.x), 
              mix(texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), arrayIndex), 0), 
                  texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), arrayIndex), 0), fractionalPart.x), fractionalPart.y);
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, vec3(uv, float(arrayIndex)), 0.0);
  }
}

vec4 texturePlanetOctahedralMapArray(const in sampler2DArray tex, vec3 direction, const int arrayIndex, const in int lod) {
  ivec2 texSize = textureSize(tex, lod).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  vec2 uv = octPlanetUnsignedEncode(direction) + (vec2(0.5) * invTexSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
   // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   return mix(mix(texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), arrayIndex), lod), 
                  texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), arrayIndex), lod), fractionalPart.x), 
              mix(texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), arrayIndex), lod), 
                  texelFetch(tex, ivec3(wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), arrayIndex), lod), fractionalPart.x), fractionalPart.y);
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, vec3(uv, float(arrayIndex)), float(lod));
  }
}

#ifdef FRAGMENT_SHADER
vec4 textureMipMapPlanetOctahedralMap(const in sampler2D tex, vec3 direction) {
  ivec2 texSize = textureSize(tex, 0).xy; 
  vec2 uv = octPlanetUnsignedEncode(direction) + (vec2(0.5) / vec2(texSize)); 
  vec2 uvInt = uv * vec2(texSize);
  vec2 uvdx = dFdx(uv);
  vec2 uvdy = dFdy(uv);  
  float mipMapLevel = max(0.0, log2(max(dot(uvdx, uvdx), dot(uvdy, uvdy))) * 0.5); //textureQueryLod(tex, uv).x;
  texSize = textureSize(tex, int(mipMapLevel)).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if(any(lessThanEqual(uv, invTexSize)) || any(greaterThanEqual(uv, vec2(1.0) - invTexSize))){
    // Handle edges with manual bilinear interpolation using texelFetch for correct octahedral texel edge mirroring 
    uv = fma(uv, texSize, vec2(-0.5));
    int maxMipMapLevel = int(floor(log2(max(float(texSize.x), float(texSize.y)))));
    ivec2 baseCoord = ivec2(floor(uv));
    vec2 fractionalPart = uv - vec2(baseCoord);   
    int mipMapLevelInt = int(mipMapLevel);
    float mipMapLevelFraction = mipMapLevel - float(mipMapLevelInt);
    int nextMipMapLevelInt = min(mipMapLevelInt + 1, maxMipMapLevel);
    if((mipMapLevelFraction == 0.0) || (nextMipMapLevelInt == mipMapLevelInt)){
      return mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), mipMapLevelInt), 
                     texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), mipMapLevelInt), fractionalPart.x), 
                 mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), mipMapLevelInt), 
                     texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), mipMapLevelInt), fractionalPart.x), fractionalPart.y);
    }else{
      return mix(mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), mipMapLevelInt), 
                         texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), mipMapLevelInt), fractionalPart.x), 
                     mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), mipMapLevelInt), 
                         texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), mipMapLevelInt), fractionalPart.x), fractionalPart.y), 
                 mix(mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 0), texSize), nextMipMapLevelInt), 
                         texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 0), texSize), nextMipMapLevelInt), fractionalPart.x), 
                     mix(texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(0, 1), texSize), nextMipMapLevelInt), 
                         texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(1, 1), texSize), nextMipMapLevelInt), fractionalPart.x), fractionalPart.y), mipMapLevelFraction);
    }
  }else{
    // Non-edge texels can be sampled directly with textureLod
    return textureLod(tex, uv, mipMapLevel);
  }
}
#endif

vec4 textureCatmullRomPlanetOctahedralMap(const in sampler2D tex, vec3 direction) {
  ivec2 texSize = textureSize(tex, 0).xy; 
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  vec2 uv = octPlanetUnsignedEncode(direction) + (vec2(0.5) * invTexSize); 
  if(any(lessThanEqual(uv, invTexSize * 2.0)) || any(greaterThanEqual(uv, vec2(1.0) - (invTexSize * 2.0)))){
   // Handle edges with manual catmull rom interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   vec4 xCoefficients = textureCatmullRomCoefficents(fractionalPart.x);
   vec4 yCoefficients = textureCatmullRomCoefficents(fractionalPart.y);
   return (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1, -1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0, -1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1, -1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2, -1), texSize), 0) * xCoefficients.w)) * yCoefficients.x) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  0), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  0), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  0), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  0), texSize), 0) * xCoefficients.w)) * yCoefficients.y) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  1), texSize), 0) * xCoefficients.w)) * yCoefficients.z) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  2), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  2), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  2), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  2), texSize), 0) * xCoefficients.w)) * yCoefficients.w);
  }else{
    // Non-edge texels can be sampled directly with an optimized catmull rom interpolation using just nine bilinear textureLod calls
    return textureCatmullRom(tex, uv, 0);
  }
}

vec4 textureCatmullRomPlanetOctahedralMap(const in sampler2D tex, vec3 direction, const in int lod) {
  ivec2 texSize = textureSize(tex, lod).xy; 
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  vec2 uv = octPlanetUnsignedEncode(direction) + (vec2(0.5) * invTexSize); 
  if(any(lessThanEqual(uv, invTexSize * 2.0)) || any(greaterThanEqual(uv, vec2(1.0) - (invTexSize * 2.0)))){
   // Handle edges with manual catmull rom interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, texSize, vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   vec4 xCoefficients = textureCatmullRomCoefficents(fractionalPart.x);
   vec4 yCoefficients = textureCatmullRomCoefficents(fractionalPart.y);
   return (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1, -1), texSize), lod) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0, -1), texSize), lod) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1, -1), texSize), lod) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2, -1), texSize), lod) * xCoefficients.w)) * yCoefficients.x) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  0), texSize), lod) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  0), texSize), lod) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  0), texSize), lod) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  0), texSize), lod) * xCoefficients.w)) * yCoefficients.y) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  1), texSize), lod) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  1), texSize), lod) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  1), texSize), lod) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  1), texSize), lod) * xCoefficients.w)) * yCoefficients.z) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  2), texSize), lod) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  2), texSize), lod) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  2), texSize), lod) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  2), texSize), lod) * xCoefficients.w)) * yCoefficients.w);
  }else{
    // Non-edge texels can be sampled directly with an optimized catmull rom interpolation using just nine bilinear textureLod calls
    return textureCatmullRom(tex, uv, lod);
  }
}

vec4 textureBicubicOctahedralMap(const in sampler2D tex, vec3 direction) {
  direction = normalize(direction); // just for to make sure that it is normalized 
  vec2 uv = direction.xy / max(1e-6, abs(direction.x) + abs(direction.y) + abs(direction.z));
  uv = fma((direction.z < 0.0) ? ((1.0 - abs(uv.yx)) * vec2((uv.x >= 0.0) ? 1.0 : -1.0, (uv.y >= 0.0) ? 1.0 : -1.0)) : uv, vec2(0.5), vec2(0.5));
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if((any(lessThanEqual(uv, invTexSize * 2.0)) || any(greaterThanEqual(uv, vec2(1.0) - (invTexSize * 2.0))))){
   // Handle edges with manual catmull rom interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, vec2(texSize), vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   vec4 xCoefficients = textureBicubicCoefficents(fractionalPart.x);
   vec4 yCoefficients = textureBicubicCoefficents(fractionalPart.y);
   return (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1, -1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0, -1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1, -1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2, -1), texSize), 0) * xCoefficients.w)) * yCoefficients.x) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  0), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  0), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  0), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  0), texSize), 0) * xCoefficients.w)) * yCoefficients.y) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  1), texSize), 0) * xCoefficients.w)) * yCoefficients.z) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  2), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  2), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  2), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  2), texSize), 0) * xCoefficients.w)) * yCoefficients.w);
  }else{
    // Non-edge texels can be sampled directly with an optimized catmull rom interpolation using just nine bilinear textureLod calls
    return textureBicubic(tex, uv, 0);
  }
}

vec4 textureBicubicPlanetOctahedralMap(const in sampler2D tex, vec3 direction) {
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  direction = normalize(direction); // just for to make sure that it is normalized 
  vec2 uv = octPlanetUnsignedEncode(direction) + (vec2(0.5) * invTexSize); 
  if((any(lessThanEqual(uv, invTexSize * 2.0)) || any(greaterThanEqual(uv, vec2(1.0) - (invTexSize * 2.0))))){
   // Handle edges with manual catmull rom interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, vec2(texSize), vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   vec4 xCoefficients = textureBicubicCoefficents(fractionalPart.x);
   vec4 yCoefficients = textureBicubicCoefficents(fractionalPart.y);
   return (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1, -1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0, -1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1, -1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2, -1), texSize), 0) * xCoefficients.w)) * yCoefficients.x) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  0), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  0), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  0), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  0), texSize), 0) * xCoefficients.w)) * yCoefficients.y) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  1), texSize), 0) * xCoefficients.w)) * yCoefficients.z) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  2), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  2), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  2), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  2), texSize), 0) * xCoefficients.w)) * yCoefficients.w);
  }else{
    // Non-edge texels can be sampled directly with an optimized catmull rom interpolation using just nine bilinear textureLod calls
    return textureBicubic(tex, uv, 0);
  }
}

vec4 textureBicubicPlanetOctahedralMap(const in sampler2D tex, vec2 uv) {
  ivec2 texSize = textureSize(tex, 0).xy;
  vec2 invTexSize = vec2(1.0) / vec2(texSize);
  if((any(lessThanEqual(uv, invTexSize * 2.0)) || any(greaterThanEqual(uv, vec2(1.0) - (invTexSize * 2.0))))){
   // Handle edges with manual catmull rom interpolation using texelFetch for correct octahedral texel edge mirroring 
   uv = fma(uv, vec2(texSize), vec2(-0.5));
   ivec2 baseCoord = ivec2(floor(uv));
   vec2 fractionalPart = uv - vec2(baseCoord);
   vec4 xCoefficients = textureBicubicCoefficents(fractionalPart.x);
   vec4 yCoefficients = textureBicubicCoefficents(fractionalPart.y);
   return (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1, -1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0, -1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1, -1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2, -1), texSize), 0) * xCoefficients.w)) * yCoefficients.x) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  0), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  0), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  0), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  0), texSize), 0) * xCoefficients.w)) * yCoefficients.y) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  1), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  1), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  1), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  1), texSize), 0) * xCoefficients.w)) * yCoefficients.z) + 
          (((texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2(-1,  2), texSize), 0) * xCoefficients.x) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 0,  2), texSize), 0) * xCoefficients.y) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 1,  2), texSize), 0) * xCoefficients.z) + 
            (texelFetch(tex, wrapOctahedralTexelCoordinates(baseCoord + ivec2( 2,  2), texSize), 0) * xCoefficients.w)) * yCoefficients.w);
  }else{
    // Non-edge texels can be sampled directly with an optimized catmull rom interpolation using just nine bilinear textureLod calls
    return textureBicubic(tex, uv, 0);
  }
}

#endif
