#version 450 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

const int numSamples = 1024;

#include "ibl.glsl"

void main(){
  float nDotV = inTexCoord.x;
  float roughness = inTexCoord.y;
  outFragColor = vec4(LUTCharlie(nDotV, roughness, numSamples));
}
