#version 460 core

// DDGI probe debug visualization — fragment shader.
//
// Colors each octahedral-sphere fragment with the probe's irradiance in the fragment's OUTWARD (sphere-normal) direction,
// using the SAME live DDGI sampling the renderer uses: ddgiEvaluateIrradiance() resolves the octahedral atlas OR the SH (L1/L2)
// representation depending on the build-time GI_DDGI_STORAGE constant, so the debug spheres show exactly "what is active".
// One probe -> one octahedral sphere whose surface is the probe's directional irradiance.

#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_multiview : enable
#extension GL_EXT_buffer_reference : enable
#extension GL_EXT_buffer_reference2 : enable
#extension GL_EXT_scalar_block_layout : enable
#extension GL_EXT_shader_explicit_arithmetic_types_int64 : enable
#extension GL_EXT_nonuniform_qualifier : enable

/* clang-format off */

#include "octahedral.glsl"

#define DDGI_DESCRIPTOR_SET 2
#include "global_illumination_ddgi_sampling.glsl" // ddgiData @ set 2 binding 0 + irradiance/visibility + ddgiEvaluateIrradiance()

layout(location = 0) in vec3 inDirection;          // outward direction at this fragment (interpolated sphere normal), world space
layout(location = 1) flat in ivec3 inProbeCoord;   // probe grid coordinate within its cascade
layout(location = 2) flat in int inCascadeIndex;
layout(location = 3) flat in float inActive;       // relocation state: 1 = active, 0 = inactive (inside geometry / empty space)

layout(location = 0) out vec4 outFragColor;

void main(){
  vec3 irradiance = ddgiEvaluateIrradiance(inProbeCoord, inCascadeIndex, normalize(inDirection));
  // Inactive (relocation-deactivated) probes are dimmed + tinted red so the debug view shows which probes the renderer skips.
  if(inActive < 0.5){
    irradiance = mix(irradiance * 0.1, vec3(0.25, 0.0, 0.0), 0.5);
  }
  outFragColor = vec4(irradiance, 1.0);
}
