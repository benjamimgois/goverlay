#version 450 core

#pragma shader_stage(tesseval)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable
#extension GL_GOOGLE_include_directive : enable

#include "bufferreference_definitions.glsl"

#ifdef TRIANGLES
layout(triangles, fractional_even_spacing, ccw) in;
#else
layout(quads, fractional_even_spacing, ccw) in; 
#endif

layout(location = 0) in InBlock {
  vec3 position;
  vec3 normal;
} inBlocks[];

layout(location = 0) out OutBlock {
  vec3 position;
  vec3 sphereNormal;
  vec3 normal;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
  vec2 jitter;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
} outBlock;

in gl_PerVertex {
	vec4 gl_Position;
	float gl_PointSize;
	float gl_ClipDistance[];
} gl_in[];

out gl_PerVertex {
	vec4 gl_Position;
	float gl_PointSize;
	float gl_ClipDistance[];
};

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

// Global descriptor set

#define PLANETS
#include "globaldescriptorset.glsl"
#undef PLANETS

// Global planet descriptor set

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256];
} uView;

// Per planet descriptor set

layout(set = 2, binding = 0) uniform sampler2D uTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map

#include "planet_renderpass.glsl"

#include "octahedral.glsl"
#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix;
mat4 projectionMatrix = uView.views[viewIndex].projectionMatrix;
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix;

void main(){	  

  mat4 viewProjectionMatrix = projectionMatrix * viewMatrix;

#if 1
  // The actual standard approach
  vec3 cameraPosition = inverseViewMatrix[3].xyz;
#else
  // This approach assumes that the view matrix has no scaling or skewing, but only rotation and translation.
  vec3 cameraPosition = (-viewMatrix[3].xyz) * mat3(viewMatrix);
#endif

#ifdef TRIANGLES
 
  // Barycentric coordinates

  //vec3 position = (inBlocks[0].position * gl_TessCoord.x) + (inBlocks[1].position * gl_TessCoord.y) + (inBlocks[2].position * gl_TessCoord.z);

  vec3 sphereNormal = normalize((inBlocks[0].normal * gl_TessCoord.x) + (inBlocks[1].normal * gl_TessCoord.y) + (inBlocks[2].normal * gl_TessCoord.z));

#else

  // Bilinear interpolation

  /*
  vec3 position = mix(mix(inBlocks[0].position, inBlocks[1].position, gl_TessCoord.x),
                      mix(inBlocks[2].position, inBlocks[3].position, gl_TessCoord.x), 
                      gl_TessCoord.y);*/
  
  vec3 sphereNormal = normalize(mix(mix(inBlocks[0].normal, inBlocks[1].normal, gl_TessCoord.x), 
                                    mix(inBlocks[3].normal, inBlocks[2].normal, gl_TessCoord.x),
                               gl_TessCoord.y));
#endif
 
  //position += sphereNormal * textureCatmullRomPlanetOctahedralMap(uTextures[0], sphereNormal).x * pushConstants.heightMapScale;
 
  vec3 position = (planetData.modelMatrix * vec4(sphereNormal * (planetData.bottomRadiusTopRadiusHeightMapScale.x + (textureCatmullRomPlanetOctahedralMap(uTextures[0], sphereNormal).x * planetData.bottomRadiusTopRadiusHeightMapScale.z)), 1.0)).xyz;

  vec3 worldSpacePosition = position;

  vec3 normal = sphereNormal;

  if((planetData.flagsResolutions.x & (1u << 1u)) != 0){

    normal = normalize(fma(textureCatmullRomPlanetOctahedralMap(uTextures[1], sphereNormal).xyz, vec3(2.0), vec3(-1.0)));

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
  outBlock.worldSpacePosition = worldSpacePosition;
  outBlock.viewSpacePosition = viewSpacePosition.xyz;  
  outBlock.cameraRelativePosition = worldSpacePosition - cameraPosition;
  outBlock.jitter = pushConstants.jitter;
#ifdef VELOCITY
  outBlock.currentClipSpace = (projectionMatrix * viewMatrix) * vec4(position, 1.0);
  outBlock.previousClipSpace = (uView.views[viewIndex + pushConstants.countAllViews].projectionMatrix * uView.views[viewIndex + pushConstants.countAllViews].viewMatrix) * vec4(position, 1.0);
#endif

	gl_Position = viewProjectionMatrix * vec4(position, 1.0);
  
}
