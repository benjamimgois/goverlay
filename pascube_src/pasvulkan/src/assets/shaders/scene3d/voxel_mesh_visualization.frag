#version 450 core

#extension GL_EXT_multiview : enable

layout(location = 0) in vec4 inColor;

layout(location = 0) out vec4 outColor;

void main() {
  outColor = inColor; 
}