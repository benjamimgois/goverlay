#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec4 inColor;
layout(location = 1) in vec2 inPosition;
layout(location = 2) in vec2 inPosition0;
layout(location = 3) in vec2 inPosition1;
layout(location = 4) in float inLineThickness;
layout(location = 5) in float outZ;
layout(location = 6) flat in vec2 outZMinMax;
layout(location = 7) in vec3 inPosition3D;

layout(location = 0) out vec4 outFragColor;

layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint countRainDrops;
  vec2 viewPortSize;
  vec2 padding;
  vec4 occlusionOBBCenter; 
  vec4 occlusionOBBHalfSize;
  vec4 occlusionOBBOrientation;
} pushConstants;

#include "quaternion.glsl"

// A point is occluded if it is inside the OBB defined by the occlusionOBBCenter, occlusionOBBHalfSize, and occlusionOBBOrientation.
// For to check if a point is inside a building or other occluder, where rain streaks should not be rendered. 
bool isOccluded(vec3 position){
  if(pushConstants.occlusionOBBHalfSize.w > 0.5){ 
    vec3 p = transformVectorByQuaternion(position.xyz - pushConstants.occlusionOBBCenter.xyz, pushConstants.occlusionOBBOrientation);
    return all(lessThanEqual(abs(p), pushConstants.occlusionOBBHalfSize.xyz));
  }else{
    return false; // OBB is not defined, so no occlusion
  }
}

// Returns a factor for how much the rain streak should be occluded based on its position relative to the OBB. When inside the OBB, the
// factor is 0.0 (invisible), and when outside the OBB, the factor is 1.0 (fully visible). The factor is smoothstep-ed to avoid hard edges.
float visibilityFactor(vec3 position){
  if(pushConstants.occlusionOBBHalfSize.w > 0.5){ 
    vec3 p = transformVectorByQuaternion(position.xyz - pushConstants.occlusionOBBCenter.xyz, pushConstants.occlusionOBBOrientation);
    vec3 q = abs(p) - pushConstants.occlusionOBBHalfSize.xyz;
    float d = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
    return smoothstep(0.0, pushConstants.occlusionOBBCenter.w, d);  
  }else{
    return 1.0; // OBB is not defined, so no occlusion
  }
}

void main(){
  
  vec4 outputColor = vec4(0.0);
  
  vec2 p = inPosition, a = inPosition0, b = inPosition1;

#if 1
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

  float alpha = (1.0 - clamp(d / fwidth(d), 0.0, 1.0)) * visibilityFactor(inPosition3D);

  if((outZ < outZMinMax.x) || (outZ > outZMinMax.y)){
    alpha = 0.0; 
  }

  outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

  outFragColor = outputColor;

}
