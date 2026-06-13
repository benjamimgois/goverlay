#ifndef PLANET_CAUSTICS_GLSL
#define PLANET_CAUSTICS_GLSL

// Three-octave Voronoi caustic pattern.
// Returns a caustic intensity in [0, +inf].
// uv: 2D position in planet-local XZ space (scaled by causticScale before calling)
// t:  animated time (time * causticSpeed)
float getCausticPattern(vec2 uv, float t){
  // Column-major mat3 equivalent of row-major float3x3(-2,-1,2, 3,-2,1, 1,2,2)
  // with mul(k, M) semantics: col0=(-2,-1,2), col1=(3,-2,1), col2=(1,2,2)
  const mat3 m = mat3(-2.0, -1.0, 2.0,  3.0, -2.0, 1.0,  1.0, 2.0, 2.0);
  vec3 k = vec3(uv, t);
  vec3 a = m * k * 0.5;
  vec3 b = m * a * 0.4;
  vec3 c = m * b * 0.3;
  float d = min(min(length(vec3(0.5) - fract(a)),
                    length(vec3(0.5) - fract(b))),
                    length(vec3(0.5) - fract(c)));
  return pow(d, 7.0) * 25.0;
}

// Returns a [0, +inf] caustic intensity for a planet-local 3D position.
// pos:        planet-local 3D fragment position
// time:       current time in seconds
// scale:      spatial frequency (inverse position units); larger = finer pattern
// speed:      animation speed multiplier
// fadeDepth:  depth (position units) at which intensity falls to 1/e (~0.37)
// waterDepth: water column height at this point; <= 0 means dry
float getCausticIntensity(vec3 pos, float time, float scale, float speed, 
                          float fadeDepth, float waterDepth, 
                          float depthThresholdLow, float depthThresholdHigh){
  float fade = exp(-waterDepth / max(fadeDepth, 0.01)) * // exponential depth fade
               smoothstep(depthThresholdLow, depthThresholdHigh, waterDepth); // depth threshold fade
  return (fade < 1e-4) 
           ? 0.0 
           : (getCausticPattern(pos.xz * scale, time * speed) * fade);
}

#endif // PLANET_CAUSTICS_GLSL
