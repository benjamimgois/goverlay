#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
//#extension GL_AMD_vertex_shader_layer : enable
#extension GL_ARB_shader_viewport_layer_array : enable

layout(location = 0) out vec2 outTexCoord;
layout(location = 1) out vec2 outPixCoord;
layout(location = 2) out vec4 outOffset0;
layout(location = 3) out vec4 outOffset1;
layout(location = 4) out vec4 outOffset2;

#define SMAA_MAX_SEARCH_STEPS 16

layout(push_constant) uniform PushConstants {
  vec4 metrics;  //
  vec4 subsampleIndices;  // Just pass zero for SMAA 1x, see @SUBSAMPLE_INDICES.
} pushConstants;

void main() {
  vec4 SMAA_RT_METRICS = pushConstants.metrics;
  ivec2 uv = ivec2(ivec2(int(gl_VertexIndex)) << ivec2(0, 1)) & ivec2(2);
  outTexCoord = vec2(uv);
  gl_Position = vec4(vec2(ivec2((uv << ivec2(1)) - ivec2(1))), 0.0, 1.0);
  outPixCoord = outTexCoord * SMAA_RT_METRICS.zw;
  outOffset0 = fma(SMAA_RT_METRICS.xyxy, vec4(-0.25, -0.125, 1.25, -0.125), outTexCoord.xyxy);
  outOffset1 = fma(SMAA_RT_METRICS.xyxy, vec4(-0.125, -0.25, -0.125, 1.25), outTexCoord.xyxy);
  outOffset2 = fma(SMAA_RT_METRICS.xxyy, vec2(-2.0, 2.0).xyxy * float(SMAA_MAX_SEARCH_STEPS), vec4(outOffset0.xz, outOffset1.yw));
}
