#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

#include "space_lines.glsl"

layout(location = 0) in vec4 inColor;
layout(location = 1) in vec2 inPosition;
layout(location = 2) in vec2 inPosition0;
layout(location = 3) in vec2 inPosition1;
layout(location = 4) in float inLineThickness;
layout(location = 5) in float outZ;
layout(location = 6) flat in vec2 outZMinMax;

layout(location = 0) out vec4 outFragColor;

layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint dummy;
  vec2 viewPortSize;
} pushConstants;

void main(){
  
  vec4 outputColor = vec4(0.0);
  
  vec2 p = inPosition, a = inPosition0, b = inPosition1;

#if 0
  // Rounded line
  vec2 pa = p - a, ba = b - a;
  float d = length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThickness * 0.5);
#else
  // Line with square ends 
  float l = length(b - a);
  vec2 c = (b - a) / l, q = (p - ((a + b) * 0.5));
  q = abs(mat2(c.x, -c.y, c.y, c.x) * q) - vec2(l, inLineThickness) * 0.5;
  float d = length(max(q, 0.0)) + min(max(q.x, q.y),0.0);          
#endif

  float alpha = 1.0 - clamp(d / fwidth(d), 0.0, 1.0);

  if((outZ < outZMinMax.x) || (outZ > outZMinMax.y)){
    alpha = 0.0; 
  }

  outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

  outFragColor = outputColor;

}
