#ifndef OCTAHEDRAL_GLSL
#define OCTAHEDRAL_GLSL

#define OCT_PLANET_BASE_AXIS_X 0
#define OCT_PLANET_BASE_AXIS_Y 1
#define OCT_PLANET_BASE_AXIS_Z 2

#define OCT_PLANET_BASE_AXIS OCT_PLANET_BASE_AXIS_Z

#define OCT_EQUAL_AREA_FOR_PLANET

#ifndef OCT_EQUAL_AREA_VARIANT
  #define OCT_EQUAL_AREA_VARIANT 0
#endif

#ifdef OCT_EQUAL_AREA_AS_DEFAULT
  #define octEncode octEqualAreaSignedEncode
  #define octDecode octEqualAreaSignedDecode
  #define octSignedEncode octEqualAreaSignedEncode
  #define octSignedDecode octEqualAreaSignedDecode
  #define octUnsignedEncode octEqualAreaUnsignedEncode
  #define octUnsignedDecode octEqualAreaUnsignedDecode
#else
  #define octEncode octNonEqualAreaSignedEncode
  #define octDecode octNonEqualAreaSignedDecode
  #define octSignedEncode octNonEqualAreaSignedEncode
  #define octSignedDecode octNonEqualAreaSignedDecode
  #define octUnsignedEncode octNonEqualAreaUnsignedEncode
  #define octUnsignedDecode octNonEqualAreaUnsignedDecode
#endif

vec2 wrapOctahedralCoordinates(vec2 uv){
  return ((((int(floor(abs(uv.x))) + int(bool(uv.x < 0.0))) ^ (int(floor(abs(uv.y))) + int(bool(uv.y < 0.0)))) & 1) != 0) ? (vec2(1.0) - fract(uv)) : fract(uv);
}

ivec2 wrapOctahedralTexelCoordinates(const in ivec2 texel, const in ivec2 texSize) {
  ivec2 tiledSize = texSize * 2; 
  ivec2 tiledWrapped = ((texel % tiledSize) + tiledSize) % tiledSize;
  ivec2 isWrapped = ivec2(greaterThanEqual(tiledWrapped, texSize));
  if((isWrapped.x ^ isWrapped.y) != 0){
    tiledWrapped = texSize - ((tiledWrapped % texSize) + ivec2(1));
  }
  return ((tiledWrapped % texSize) + texSize) % texSize;
}  
 
/*ivec2 wrapOctahedralTexelCoordinates2(const in ivec2 texel, const in ivec2 texSize) {
  ivec2 wrapped = ((texel % texSize) + texSize) % texSize;
  return ((((abs(texel.x / texSize.x) + int(texel.x < 0)) ^ (abs(texel.y / texSize.y) + int(texel.y < 0))) & 1) != 0) ? (((texSize - (wrapped + ivec2(1))) + texSize) % texSize) : wrapped;
}*/

/*ivec2 wrapOctahedralTexelCoordinates(const in ivec2 texel, const in ivec2 texSize) {
  ivec2 wrapped = ((texel % texSize) + texSize) % texSize;
  return ((((abs(texel.x / texSize.x) + int(texel.x < 0)) ^ (abs(texel.y / texSize.y) + int(texel.y < 0))) & 1) != 0) ? (texSize - (wrapped + ivec2(1))) : wrapped;
}*/

vec2 octNonEqualAreaSignedEncode(vec3 vector) {
  vector = normalize(vector); // just for to make sure that it is normalized
  vec2 result = vector.xy / (abs(vector.x) + abs(vector.y) + abs(vector.z));
  return (vector.z < 0.0) ? ((1.0 - abs(result.yx)) * fma(step(vec2(0.0), result.xy), vec2(2.0), vec2(-1.0))) : result;
}

vec2 octNonEqualAreaUnsignedEncode(vec3 vector) {
  return fma(octNonEqualAreaSignedEncode(vector), vec2(0.5), vec2(0.5));
}

vec3 octNonEqualAreaSignedDecode(vec2 uv) {
  vec3 v = vec3(uv.xy, 1.0 - (abs(uv.x) + abs(uv.y)));
  return normalize((v.z < 0.0) ? vec3((1.0 - abs(v.yx)) * fma(step(vec2(0.0), v.xy), vec2(2.0), vec2(-1.0)), v.z) : v);
}

vec3 octNonEqualAreaUnsignedDecode(vec2 uv) {
  return octNonEqualAreaSignedDecode(fma(uv, vec2(2.0), vec2(-1.0)));
}

vec2 octEqualAreaSignedEncode(vec3 vector){
  vector = normalize(vector); // just for to make sure that it is normalized
  const float oneOverHalfPi = 0.6366197723675814;
#if OCT_EQUAL_AREA_VARIANT == 0
  //More optimized version of variant 1 
  vec2 uv = vec2(sqrt(1.0 - abs(vector.z)));
  uv.y *= atan(abs(vector.y), max(1e-17, abs(vector.x))) * oneOverHalfPi;
  uv.x -= uv.y;
  return ((vector.z < 0.0) ? (vec2(1.0) - uv.yx) : uv.xy) * fma(step(vec2(0.0), vector.xy), vec2(2.0), vec2(-1.0));
#elif OCT_EQUAL_AREA_VARIANT == 1
  vec3 absVector = abs(vector);
  vec2 phiTheta = vec2(atan(absVector.x, max(1e-17, absVector.y)) * oneOverHalfPi, sqrt(1.0 - absVector.z));
  vec2 s = fma(vec2(lessThan(vector.xy, vec2(0.0))), vec2(-2.0), vec2(1.0)); // vec2 s = fma(step(vec2(0.0), vector.xy), vec2(2.0), vec2(-1.0));
  vec2 uv = (vec2(phiTheta.x, 1.0 - phiTheta.x) * phiTheta.y) * s.xy;
  return (vector.z < 0.0) ? fma(abs(uv.yx), -s, s) : uv;
#else 
  // The latitude isn't equal area in this variant
  vec3 absVector = abs(vector);
  vec2 phiTheta = vec2(atan(absVector.x, max(1e-17, absVector.y)), acos(absVector.z)) * oneOverHalfPi;
  vec2 s = fma(vec2(lessThan(vector.xy, vec2(0.0))), vec2(-2.0), vec2(1.0)); // vec2 s = fma(step(vec2(0.0), vector.xy), vec2(2.0), vec2(-1.0));
  vec2 uv = (vec2(phiTheta.x, 1.0 - phiTheta.x) * phiTheta.y) * s.xy;
  return (vector.z < 0.0) ? fma(abs(uv.yx), -s, s) : uv;
#endif
}

vec2 octEqualAreaUnsignedEncode(vec3 vector){
  return fma(octEqualAreaSignedEncode(vector), vec2(0.5), vec2(0.5));
}

vec3 octEqualAreaSignedDecode(vec2 uv){
  const float halfPI = 1.5707963267948966;
  vec2 absUV = abs(uv);
#if OCT_EQUAL_AREA_VARIANT == 0
  // More optimized version of variant 1 
  const float PIover4 = 0.7853981633974483;
  float d = 1.0 - (absUV.x + absUV.y), r = 1.0 - abs(d);
  vec2 phiCosSin = sin(vec2((r != 0.0) ? (((absUV.y - absUV.x) / max(1e-17, r)) + 1.0) * PIover4 : 0.0) + vec2(halfPI, 0.0));
  return normalize(vec3(abs(phiCosSin * (r * sqrt(2.0 - (r * r)))), 1.0 - (r * r)) * fma(step(vec3(0.0), vec3(uv, d)), vec3(2.0), vec3(-1.0)));  
#elif OCT_EQUAL_AREA_VARIANT == 1
  float absUVSum = absUV.x + absUV.y;
  vec2 s = fma(step(vec2(0.0), uv), vec2(2.0), vec2(-1.0));
  uv = (absUVSum > 1.0) ? ((vec2(1.0) - abs(uv.yx)) * s) : uv;
  float d = 1.0 - absUVSum, r = 1.0 - abs(d);   
  vec4 phiThetaSinCos = vec4(sin(vec2((abs(uv.x) / max(1e-17, abs(uv.x) + abs(uv.y))) * halfPI) + vec2(0.0, halfPI)), r * sqrt(2.0 - (r * r)), 1.0 - (r * r)); 
  return normalize(vec3(phiThetaSinCos.xy * phiThetaSinCos.zz * s.xy, (d < 0.0) ? -phiThetaSinCos.w : phiThetaSinCos.w));
#else
  // The latitude isn't equal area in this variant, just the longitude
  float absUVSum = absUV.x + absUV.y;
  vec2 s = fma(step(vec2(0.0), uv), vec2(2.0), vec2(-1.0));
  uv = (absUVSum > 1.0) ? ((vec2(1.0) - abs(uv.yx)) * s) : uv;
  vec4 phiThetaSinCos = sin(vec2(vec2(abs(uv.x) / max(1e-17, abs(uv.x) + abs(uv.y)), absUVSum) * halfPI).xxyy + vec2(0.0, halfPI).xyxy); 
  return normalize(vec3(phiThetaSinCos.xy * phiThetaSinCos.zz * s.xy, phiThetaSinCos.w));
#endif
}

vec3 octEqualAreaUnsignedDecode(vec2 uv){
  return octEqualAreaSignedDecode(fma(uv, vec2(2.0), vec2(-1.0)));
}

#if (OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_X) || (OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_Y)

vec2 octPlanetSignedEncode(vec3 vector){
#if OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_X
  vector = vector.zxy;
#elif OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_Y
  vector = vector.yzx; 
#elif OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_Z
  // Nothing to do in this case
#endif
#ifdef OCT_EQUAL_AREA_FOR_PLANET
  return octEqualAreaSignedEncode(vector);
#else
  return octNonEqualAreaSigneEncode(vector);
#endif
}

vec2 octPlanetUnsignedEncode(vec3 vector){
  return fma(octPlanetSignedEncode(vector), vec2(0.5), vec2(0.5));
}

vec3 octPlanetSignedDecode(vec2 uv){
#ifdef OCT_EQUAL_AREA_FOR_PLANET
  vec3 vector = octEqualAreaSignedDecode(uv);
#else
  vec3 vector = octNonEqualAreaSignedDecode(uv);
#endif
#if OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_X
  return vector.yzx;
#elif OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_Y
  return vector.zxy;
#elif OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_Z
  return vector;
#endif
}

vec3 octPlanetUnsignedDecode(vec2 uv){
  return octPlanetSignedDecode(fma(uv, vec2(2.0), vec2(-1.0)));
}

#define octPlanetDecode octPlanetSignedDecode
#define octPlanetEncode octPlanetSignedEncode

#elif OCT_PLANET_BASE_AXIS == OCT_PLANET_BASE_AXIS_Z

  #ifdef OCT_EQUAL_AREA_FOR_PLANET
    #define octPlanetDecode octEqualAreaSignedDecode    
    #define octPlanetEncode octEqualAreaSignedEncode
    #define octPlanetUnsignedDecode octEqualAreaUnsignedDecode
    #define octPlanetUnsignedEncode octEqualAreaUnsignedEncode
    #define octPlanetSignedDecode octEqualAreaSignedDecode
    #define octPlanetSignedEncode octEqualAreaSignedEncode
  #else
    #define octPlanetDecode octNonEqualAreaSignedDecode
    #define octPlanetEncode octNonEqualAreaSignedEncode
    #define octPlanetUnsignedDecode octNonEqualAreaUnsignedDecode
    #define octPlanetUnsignedEncode octNonEqualAreaUnsignedEncode
    #define octPlanetSignedDecode octNonEqualAreaSignedDecode
    #define octPlanetSignedEncode octNonEqualAreaSignedEncode
  #endif

#endif

#endif
