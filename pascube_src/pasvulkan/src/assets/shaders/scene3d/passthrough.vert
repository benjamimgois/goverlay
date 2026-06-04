#version 450 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inPosition;

layout(location = 0) out vec2 outPosition;

void main(){
  outPosition = inPosition;
  gl_Position = vec4(inPosition, 0.0, 1.0);
}
