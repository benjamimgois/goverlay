#version 450 core

#pragma shader_stage(vertex)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable

#include "bufferreference_definitions.glsl"

layout(location = 0) in vec3 inVector;
layout(location = 1) in vec2 inOctahedralEncodedNormal;

#if defined(RAYTRACING)

layout(location = 0) out vec3 outWorldSpacePosition;

layout(location = 1) flat out vec3 outCameraPosition;

layout(location = 2) out OutBlock {
  vec3 position;
  vec3 sphereNormal;
  vec3 normal;
  vec3 triplanarNormal;
  vec3 triplanarPosition;
//vec3 worldSpacePosition;
  vec3 viewSpacePosition;
//vec3 cameraRelativePosition;
  vec2 jitter;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
} outBlock;

#else

layout(location = 0) out OutBlock {
  vec3 position;
  vec3 sphereNormal;
  vec3 normal;
  vec3 triplanarNormal;
  vec3 triplanarPosition;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
  vec2 jitter;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
} outBlock;
#endif

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256];
} uView;

// Global descriptor set

#define PLANETS
#include "globaldescriptorset.glsl"
#undef PLANETS

#include "planet_renderpass.glsl"

layout(set = 2, binding = 0) uniform sampler2D uTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map

#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix;
mat4 projectionMatrix = uView.views[viewIndex].projectionMatrix;
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix;

void main(){          

  vec3 sphereNormal = normalize(inVector);

  mat4 viewProjectionMatrix = projectionMatrix * viewMatrix;

#if 1
  // The actual standard approach
  vec3 cameraPosition = inverseViewMatrix[3].xyz;
#else
  // This approach assumes that the view matrix has no scaling or skewing, but only rotation and translation.
  vec3 cameraPosition = (-viewMatrix[3].xyz) * mat3(viewMatrix);
#endif   

  vec3 position = (planetData.modelMatrix * vec4(inVector, 1.0)).xyz;

  vec3 triplanarPosition = (planetData.triplanarMatrix * vec4(inVector, 1.0)).xyz;
 
  vec3 worldSpacePosition = position;

  vec3 normal = octSignedDecode(inOctahedralEncodedNormal);

  if((planetData.flagsResolutions.x & (1u << 1u)) != 0){

    layerMaterialSetup(sphereNormal);

    multiplanarSetup(position, vec3(1e-6), vec3(1e-6), normal);

    float displacement = 1.0 - clamp(getLayeredMultiplanarHeight(), 0.0, 1.0);

    position -= normal * displacement * 0.25;

  }

  vec4 viewSpacePosition = viewMatrix * vec4(position, 1.0);
  viewSpacePosition.xyz /= viewSpacePosition.w;

  outBlock.position = position;         
  outBlock.sphereNormal = sphereNormal;
  outBlock.normal = normalize((planetData.normalMatrix * vec4(normal, 0.0)).xyz);
  outBlock.triplanarNormal = normalize((planetData.triplanarNormalMatrix * vec4(normal, 0.0)).xyz);
  outBlock.triplanarPosition = triplanarPosition;
#if !defined(RAYTRACING)
  outBlock.worldSpacePosition = worldSpacePosition;
#endif
  outBlock.viewSpacePosition = viewSpacePosition.xyz;  
#if !defined(RAYTRACING)
  outBlock.cameraRelativePosition = worldSpacePosition - cameraPosition;
#endif
  outBlock.jitter = pushConstants.jitter;
#ifdef VELOCITY
  outBlock.currentClipSpace = (projectionMatrix * viewMatrix) * vec4(position, 1.0);
  outBlock.previousClipSpace = (uView.views[viewIndex + pushConstants.countAllViews].projectionMatrix * uView.views[viewIndex + pushConstants.countAllViews].viewMatrix) * vec4(position, 1.0);
#endif

#if defined(RAYTRACING)
  outWorldSpacePosition = worldSpacePosition;
  outCameraPosition = cameraPosition;
#endif

  gl_Position = viewProjectionMatrix * vec4(position, 1.0);

}