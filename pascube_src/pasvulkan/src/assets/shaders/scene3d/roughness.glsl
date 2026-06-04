#ifndef ROUGHNESS_GLSL
#define ROUGHNESS_GLSL

float roughnessToMipMapLevel(const in float roughness, const in float maxMipMapLevel) {
  return clamp(roughness, 0.0, 1.0) * maxMipMapLevel;  //
}

float mipMapLevelToRoughness(const in float mipMapLevel, const in float maxMipMapLevel) {
  return clamp(mipMapLevel / maxMipMapLevel, 0.0, 1.0);  //
}

float applyIORToRoughness(const in float roughness, const in float ior) {
  return roughness * clamp(fma(ior, 2.0, -2.0), 0.0, 1.0);  //
}

#endif