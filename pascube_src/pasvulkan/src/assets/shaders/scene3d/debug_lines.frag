#version 450 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

/* clang-format off */

layout(location = 0) in vec4 inColor;

layout(location = 0) out vec4 outFragColor;

/* clang-format on */

void main() {
  outFragColor = inColor;
}
