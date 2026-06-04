#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec4 inColor;

layout(location = 0) out vec4 outColor;
layout(location = 1) out vec2 outEdgeDistances;

/* clang-format off */
layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint dummy;
  vec2 viewPortSize;
} pushConstants;

// Global descriptor set

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(std140, set = 1, binding = 0) uniform uboViews {
  View views[256]; // 65536 / (64 * 4) = 256
} uView;

out gl_PerVertex {
	vec4 gl_Position;
	float gl_PointSize;
  float gl_ClipDistance[];
};

/* clang-format on */

void main() {
  uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
  outColor = inColor;
  outEdgeDistances = vec2(0.0);
  gl_Position = (uView.views[viewIndex].projectionMatrix * uView.views[viewIndex].viewMatrix) * vec4(inPosition, 1.0);
  gl_PointSize = 1.0;
}
