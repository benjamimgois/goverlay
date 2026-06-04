#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec4 inColor;
layout(location = 1) in vec2 inEdgeDistances;

layout(location = 0) out vec4 outputColor;

layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint dummy;
  vec2 viewPortSize;
} pushConstants;

vec2 clipSpaceToScreenSpace(const vec2 clipSpace) {
  return fma(clipSpace, vec2(0.5), vec2(0.5)) * pushConstants.viewPortSize;
}

void main(){

  float thickness = 4.0;

  float alpha = 1.0 - clamp(length(inEdgeDistances) / thickness, 0.0, 1.0);

  outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

}
