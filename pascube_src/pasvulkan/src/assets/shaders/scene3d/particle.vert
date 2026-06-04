#version 450 core

//#define SHADERDEBUG

#ifndef VOXELIZATION
#extension GL_EXT_multiview : enable
#endif
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#if defined(SHADERDEBUG) && !defined(VELOCITY)
#extension GL_EXT_debug_printf : enable
#endif

layout(location = 0) in vec3 inPosition;
layout(location = 1) in float inRotation;
layout(location = 2) in vec2 inQuadCoord;
layout(location = 3) in uint inTextureID;
layout(location = 4) in vec2 inSize;
layout(location = 5) in vec4 inColor;
layout(location = 6) in float inTime;

#ifdef VOXELIZATION
layout(location = 0) out vec3 outWorldSpacePosition;
#else
layout(location = 0) out vec3 outViewSpacePosition;
#endif
layout(location = 1) out vec3 outTexCoord;
layout(location = 2) out vec4 outColor;
layout(location = 3) flat out uint outTextureID;

/* clang-format off */
/*
#ifdef VOXELIZATION

// Should be the same as in the geometry shader, since the minimum "maximum-size" of push constants is 128 bytes
layout (push_constant) uniform PushConstants {
  uint viewIndex; // for the main primary view (in VR mode just simply the left eye, which will use as the primary view for the lighting for the voxelization then) 
} pushConstants;

#else
*/
layout (push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint frameIndex;
  vec4 jitter;
} pushConstants;

//#endif

// Global descriptor set

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256]; // 65536 / (64 * 4) = 256
} uView;

out gl_PerVertex {
	vec4 gl_Position;
	float gl_PointSize;
};

/* clang-format on */

void main() {
#ifdef VOXELIZATION
  uint viewIndex = pushConstants.viewBaseIndex;
#else 
  uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
#endif
  View view = uView.views[viewIndex];
  vec3 worldSpaceRight = view.inverseViewMatrix[0].xyz;
  vec3 worldSpaceUp = view.inverseViewMatrix[1].xyz;
  vec2 coord = fma(inQuadCoord, vec2(1.0), vec2(-0.5)) * inSize;
  vec2 sinCos = sin(vec2(inRotation) + vec2(0.0, 1.57079632679));
/*coord = vec2((coord.x * sinCos.y) + (coord.y * sinCos.x), (coord.y * sinCos.y) - (coord.x * sinCos.x));
  vec3 position = inPosition + ((worldSpaceRight * coord.x) + (worldSpaceUp * coord.y));*/
  vec3 position = inPosition + ((worldSpaceRight * ((coord.x * sinCos.y) + (coord.y * sinCos.x))) + (worldSpaceUp * ((coord.y * sinCos.y) - (coord.x * sinCos.x))));
#ifdef VOXELIZATION
  outWorldSpacePosition = position;
#else
  vec4 viewSpacePosition = view.viewMatrix * vec4(position, 1.0);
  viewSpacePosition /= viewSpacePosition.w;
  outViewSpacePosition = viewSpacePosition.xyz;
#endif
  outTexCoord = vec3(inQuadCoord, inTime);
  outColor = inColor;
  outTextureID = inTextureID;
#ifdef VOXELIZATION
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0); // Overrided by geometry shader anyway
#else
  gl_Position = (view.projectionMatrix * view.viewMatrix) * vec4(position, 1.0);
#endif
  gl_PointSize = 1.0;
}
