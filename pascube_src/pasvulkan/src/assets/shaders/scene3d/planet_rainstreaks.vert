#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec3 inPosition; // Position
layout(location = 1) in float inLineThickness; // Line thickness or point size  
layout(location = 2) in vec3 inPosition0; // Line start 
layout(location = 3) in float inZMin; // Z min value (optional for clipping) 
layout(location = 4) in vec3 inPosition1; // Line end
layout(location = 5) in float inZMax; // Z max value (optional for clipping) 
layout(location = 6) in vec4 inColor; // Color of the primitive

layout(location = 0) out vec4 outColor;
layout(location = 1) out vec2 outPosition;
layout(location = 2) out vec2 outPosition0;
layout(location = 3) out vec2 outPosition1;
layout(location = 4) out float outLineThickness;
layout(location = 5) out float outZ;
layout(location = 6) flat out vec2 outZMinMax;
layout(location = 7) out vec3 outPosition3D;

/* clang-format off */
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

// Global descriptor set

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 0, binding = 0, std140) uniform uboViews {
  View views[256]; // 65536 / (64 * 4) = 256
} uView;

out gl_PerVertex {
	vec4 gl_Position;
	float gl_PointSize;
};

/* clang-format on */

vec2 clipSpaceToScreenSpace(const vec2 clipSpace) {
  return fma(clipSpace, vec2(0.5), vec2(0.5)) * pushConstants.viewPortSize;
}

void main() {

  uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
  outColor = inColor;

  mat4 viewProjectionMatrix = uView.views[viewIndex].projectionMatrix * uView.views[viewIndex].viewMatrix;

  vec4 clipSpacePosition0 = viewProjectionMatrix * vec4(inPosition0, 1.0);
  vec4 clipSpacePosition1 = viewProjectionMatrix * vec4(inPosition1, 1.0);

  vec2 screenSpacePosition0 = outPosition0 = clipSpaceToScreenSpace(clipSpacePosition0.xy / clipSpacePosition0.w);
  vec2 screenSpacePosition1 = outPosition1 = clipSpaceToScreenSpace(clipSpacePosition1.xy / clipSpacePosition1.w);

  vec2 normal = screenSpacePosition1.xy - screenSpacePosition0.xy;
  if(length(normal) > 0.0){
    normal = normalize(normal);
  }

  vec2 tangent = vec2(-normal.y, normal.x);
  
  vec2 linePosition0 = screenSpacePosition0 + (((inPosition.x * tangent) + (inPosition.y * normal)) * inLineThickness);
  vec2 linePosition1 = screenSpacePosition1 + (((inPosition.x * tangent) + (inPosition.y * normal)) * inLineThickness);

  vec2 linePosition = outPosition = mix(linePosition0, linePosition1, inPosition.z);

  outZMinMax = vec2(inZMin, inZMax);

  vec4 viewSpacePosition = uView.views[viewIndex].viewMatrix * vec4(outPosition3D = mix(inPosition0, inPosition1, inPosition.z), 1.0);
  outZ = -(viewSpacePosition.z / viewSpacePosition.w); // Negative because the camera looks in the negative z direction
  
  outLineThickness = inLineThickness;

  vec4 clipSpacePosition = mix(clipSpacePosition0, clipSpacePosition1, inPosition.z);
  gl_Position = clipSpacePosition = vec4(fma(linePosition, vec2(2.0) / pushConstants.viewPortSize, vec2(-1.0)) * clipSpacePosition.w, clipSpacePosition.zw);
  
  gl_PointSize = 1.0; 

}