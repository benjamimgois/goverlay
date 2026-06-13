#ifndef PLANET_NOISE_GLSL
#define PLANET_NOISE_GLSL

#include "hash.glsl"

// Shared planet-domain noise helpers. Sampled in local-planet space so patterns
// stay stable on the sphere surface while being cheap.

// Quintic C2 smoothstep (Perlin's improved fade).
vec3 planetNoiseFade(vec3 t){
  return t * t * t * (t * ((t * 6.0) - 15.0) + 10.0);
}

// 3D gradient noise. Output range roughly [-1, 1].
// Avoids the axis-aligned grid artefacts of naive value-noise by projecting
// eight pseudo-random gradient vectors (derived from hash44ChaCha20) onto the
// fractional offsets at each lattice corner.
float planetGradientNoise(vec3 p){
  vec3 i = floor(p);
  vec3 f = p - i;
  vec3 u = planetNoiseFade(f);

  // Pre-compute gradient bases from a single seeded hash of the cell corner.
  // For each of the eight corners we derive a unit-ish gradient vector from
  // three hash lanes and take its dot product with the relative offset.
  #define PLANET_NOISE_GRAD(oxyz) \
    (dot((hash44ChaCha20(vec4(i + vec3(oxyz), 0.0)).xyz * 2.0 - 1.0), f - vec3(oxyz)))

  float n000 = PLANET_NOISE_GRAD(vec3(0.0, 0.0, 0.0));
  float n100 = PLANET_NOISE_GRAD(vec3(1.0, 0.0, 0.0));
  float n010 = PLANET_NOISE_GRAD(vec3(0.0, 1.0, 0.0));
  float n110 = PLANET_NOISE_GRAD(vec3(1.0, 1.0, 0.0));
  float n001 = PLANET_NOISE_GRAD(vec3(0.0, 0.0, 1.0));
  float n101 = PLANET_NOISE_GRAD(vec3(1.0, 0.0, 1.0));
  float n011 = PLANET_NOISE_GRAD(vec3(0.0, 1.0, 1.0));
  float n111 = PLANET_NOISE_GRAD(vec3(1.0, 1.0, 1.0));

  #undef PLANET_NOISE_GRAD

  return mix(mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
             mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y),
             u.z);
}

// FBM on top of planetGradientNoise. Returns roughly [0, 1].
float planetNoiseFBM(vec3 p, int aOctaves, float aLacunarity, float aGain){
  float f = 0.0;
  float a = 0.5;
  float norm = 0.0;
  for(int i = 0; i < aOctaves; i++){
    f += planetGradientNoise(p) * a;
    norm += a;
    p = (p * aLacunarity) + vec3(17.13, 23.71, 29.17);
    a *= aGain;
  }
  return ((f / max(norm, 1e-6)) * 0.5) + 0.5;
}

float planetNoiseFBM(vec3 p){
  return planetNoiseFBM(p, 5, 2.03, 0.55);
}

#endif
