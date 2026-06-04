#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
//#extension GL_AMD_vertex_shader_layer : enable
#extension GL_ARB_shader_viewport_layer_array : enable

layout(location = 0) out vec2 outTexCoord;
layout(location = 1) out vec4 outOffset;

layout(push_constant) uniform PushConstants {
  vec4 metrics;  //
} pushConstants;

void main() {
  vec4 SMAA_RT_METRICS = pushConstants.metrics;
  ivec2 uv = ivec2(ivec2(int(gl_VertexIndex)) << ivec2(0, 1)) & ivec2(2);
  outTexCoord = vec2(uv);
  gl_Position = vec4(vec2(ivec2((uv << ivec2(1)) - ivec2(1))), 0.0, 1.0);
  outOffset = fma(SMAA_RT_METRICS.xyxy, vec4(1.0, 0.0, 0.0, 1.0), outTexCoord.xyxy);
}
