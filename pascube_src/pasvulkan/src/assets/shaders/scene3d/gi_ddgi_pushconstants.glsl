#ifndef GI_DDGI_PUSHCONSTANTS_GLSL
#define GI_DDGI_PUSHCONSTANTS_GLSL

// Shared push-constant block for all DDGI compute passes — the trace PRODUCER and the per-stage update CORE (irradiance,
// visibility, border, relocation, classification). Holds only the transient per-frame parameters; the DDGI field data
// (cascade globals + the sub-buffer pointers) is reached through the `ddgiData` SSBO (gi_ddgi_data.glsl) at the set's
// binding 0, NOT the push. Must byte-match TPushConstants on the Pascal side
// (PasVulkan.Scene3D.Renderer.Passes.GlobalIlluminationDDGITraceComputePass / ...DDGIStageComputePass).
layout(push_constant) uniform PushConstants {
  vec4 randomRotation0;          // per-frame ray rotation, mat3 column 0 (xyz)
  vec4 randomRotation1;          // mat3 column 1 (xyz)
  vec4 randomRotation2;          // mat3 column 2 (xyz)
  uvec4 params;                  // x = frameIndex, y = countCascades, z = probesPerCascade, w = raysPerProbe
  vec4 blend;                    // x = temporal hysteresis, y = multi-bounce feedback strength (trace), z = firstFrame flag; exact use varies per pass
  vec4 emissiveGIParticleCount;  // x = global GI emissive scale, y = global GI emissive max, z = particle count (trace only; update stages ignore)
  uvec4 particleBVH;             // particle LBVH device addresses (trace only): xy = emitter buffer (uvec2), zw = node buffer (uvec2); 0 when inactive
} pushConstants;

#endif // GI_DDGI_PUSHCONSTANTS_GLSL
