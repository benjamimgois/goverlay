#version 450 core

#extension GL_EXT_multiview : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outColor;

#ifdef MSAA
layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInputMS uSubpassInputOpaque;

#ifdef NO_MSAA_WATER
layout(input_attachment_index = 1, set = 0, binding = 1) uniform subpassInput uSubpassInputWater;
#else
layout(input_attachment_index = 1, set = 0, binding = 1) uniform subpassInputMS uSubpassInputWater;
#endif

layout(input_attachment_index = 2, set = 0, binding = 2) uniform subpassInputMS uSubpassInputAccumulation;

layout(input_attachment_index = 3, set = 0, binding = 3) uniform subpassInputMS uSubpassInputRevealage;
#else
layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInput uSubpassInputOpaque;

layout(input_attachment_index = 1, set = 0, binding = 1) uniform subpassInput uSubpassInputWater;

layout(input_attachment_index = 2, set = 0, binding = 2) uniform subpassInput uSubpassInputAccumulation;

layout(input_attachment_index = 3, set = 0, binding = 3) uniform subpassInput uSubpassInputRevealage;
#endif

/* clang-format on */

void main() {
#ifdef MSAA
  vec4 opaque = subpassLoad(uSubpassInputOpaque, gl_SampleID);
#ifdef NO_MSAA_WATER
  vec4 water = subpassLoad(uSubpassInputWater);
#else  
  vec4 water = subpassLoad(uSubpassInputWater, gl_SampleID);
#endif
  vec4 accumulation = subpassLoad(uSubpassInputAccumulation, gl_SampleID);
  float revealage = subpassLoad(uSubpassInputRevealage, gl_SampleID).x;
#else
  vec4 opaque = subpassLoad(uSubpassInputOpaque);
  vec4 water = subpassLoad(uSubpassInputWater);
  vec4 accumulation = subpassLoad(uSubpassInputAccumulation);
  float revealage = subpassLoad(uSubpassInputRevealage).x;
#endif

  // Blend water into opaque
  opaque = mix(opaque, water, water.w);
 
  vec4 color = vec4(0.0);

  if (revealage >= 1.0) {
    color = vec4(opaque.xyz, (water.w < 1e-4) ? 1.0 : 0.0);
  } else {
    vec4 transparent = vec4(accumulation.xyz / clamp(accumulation.w, 1e-4f, 5e4f), 1.0f - revealage);
    color = vec4(mix(opaque.xyz, transparent.xyz, transparent.w), (max(transparent.w, water.w) < 1e-4) ? 1.0 : 0.0);
  }

  outColor = vec4(clamp(color.xyz, vec3(-65504.0), vec3(65504.0)), color.w);

#ifdef MSAA
  // In case of MSAA, a extra resolve pass will generate the final color, together with tone mapping and inverse tone mapping for correct HDR handling,
  // instead to do it in this same shader, for to simplify the complete process.
#endif    

}