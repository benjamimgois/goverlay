#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_EXT_buffer_reference : enable
#extension GL_EXT_buffer_reference2 : enable
#extension GL_EXT_buffer_reference_uvec2 : enable

/* clang-format off */

// Vertex shader for debug line rendering.
// Reads vertex data from a storage buffer via BDA using gl_VertexIndex.
// Each vertex: vec3 position (world-space) + uint color (packed ABGR8).

layout(buffer_reference, std430, buffer_reference_align = 4) readonly buffer DebugLineVertexBuffer {
  uint data[];
};

layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uvec2 vertexBufferBDA;
} pushConstants;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(std140, set = 0, binding = 0) uniform uboViews {
  View views[256];
} uView;

layout(location = 0) out vec4 outColor;

out gl_PerVertex {
  vec4 gl_Position;
};

/* clang-format on */

void main() {

  uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);

  DebugLineVertexBuffer vb = DebugLineVertexBuffer(pushConstants.vertexBufferBDA);

  // Vertex data starts at offset 4 uints (past VkDrawIndirectCommand header)
  // Each vertex = 4 uints (x, y, z, color)
  uint base = 4u + (uint(gl_VertexIndex) * 4u);
  vec3 position = vec3(
    uintBitsToFloat(vb.data[base + 0u]),
    uintBitsToFloat(vb.data[base + 1u]),
    uintBitsToFloat(vb.data[base + 2u])
  );
  uint packedColor = vb.data[base + 3u];

  outColor = vec4(
    float((packedColor >> 0u) & 0xffu) / 255.0,
    float((packedColor >> 8u) & 0xffu) / 255.0,
    float((packedColor >> 16u) & 0xffu) / 255.0,
    float((packedColor >> 24u) & 0xffu) / 255.0
  );

  mat4 viewProjectionMatrix = uView.views[viewIndex].projectionMatrix * uView.views[viewIndex].viewMatrix;
  gl_Position = viewProjectionMatrix * vec4(position, 1.0);

}
