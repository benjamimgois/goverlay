#version 450

#pragma shader_stage(tesc)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable

layout(vertices = 1) out;

layout(location = 0) patch in InBlock {
  vec4 v1;
  vec4 v2;
  vec3 bladeDirection;
  vec3 bladeUp;
} inBlock[];

layout(location = 0) patch out OutBlock {
  vec4 v1;
  vec4 v2;
  vec3 bladeDirection;
  vec3 bladeUp;
} outBlock;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256];
} uView;

#define PLANETS
#include "globaldescriptorset.glsl"
#undef PLANETS

#include "planet_grass.glsl"

#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix;
mat4 projectionMatrix = uView.views[viewIndex].projectionMatrix;
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix;

mat4 viewProjectionMatrix = projectionMatrix * viewMatrix;

vec3 cameraPosition = inverseViewMatrix[3].xyz;

void main() {
  
  outBlock.v1 = inBlock[0].v1;
  outBlock.v2 = inBlock[0].v2;
  outBlock.bladeDirection = inBlock[0].bladeDirection;
  outBlock.bladeUp = inBlock[0].bladeUp;

  const float d = distance(gl_in[0].gl_Position.xyz, cameraPosition);
	const float minTessLevel = 1.0;
	const float maxTessLevel = 64.0;
	const float maxDistance = 1.0;
	const float minDistance = 100.0;
	const float level = fma(1.0 - clamp((d - minDistance) / (maxDistance - minDistance), 0.0, 1.0), maxTessLevel - minTessLevel, minTessLevel);

	gl_TessLevelInner[0] = 1.0;
	gl_TessLevelInner[1] = level;
	gl_TessLevelOuter[0] = level;
	gl_TessLevelOuter[1] = 1.0;
	gl_TessLevelOuter[2] = level;
	gl_TessLevelOuter[3] = 1.0;
  
}