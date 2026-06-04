#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec3 inNormal;
layout (location = 1) in vec2 inTexCoord;

layout (binding = 1) uniform sampler2D uTexture;

layout (location = 0) out vec4 outFragColor;

void main() {
  outFragColor = texture(uTexture, inTexCoord) * vec4(vec3(mix(0.25, 1.0, max(0.0, dot(inNormal, vec3(0.0, 0.0, 1.0))))), 1.0);
}