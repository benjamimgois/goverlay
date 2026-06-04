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
  uint flags;
} inBlocks[];

layout(location = 0) out OutBlock {
  vec3 localPosition;
  vec3 position;
  vec3 sphereNormal;
  vec3 normal;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
  vec2 jitter;
  float mapValue;
  float waterOverSurface;
  float underWater;
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

layout(set = 2, binding = 0) uniform sampler2D uPlanetTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map
layout(set = 2, binding = 0) uniform sampler2DArray uPlanetArrayTextures[];  // 0 = height map, 1 = normal map, 2 = tangent bitangent map

#define PLANET_WATER
#include "planet_renderpass.glsl"

#include "planet_textures.glsl"

#include "octahedral.glsl"
#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix;
mat4 projectionMatrix = uView.views[viewIndex].projectionMatrix;
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix;

vec3 planetCenter = vec3(0.0);
float planetBottomRadius = planetData.bottomRadiusTopRadiusHeightMapScale.x;
float planetTopRadius = planetData.bottomRadiusTopRadiusHeightMapScale.y;

mat4 planetModelMatrix = planetData.modelMatrix;
mat4 planetInverseModelMatrix = inverse(planetModelMatrix);

#include "planet_water.glsl"

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
 
  vec2 sphereHeightData = getSphereHeightData(sphereNormal);

  float sphereHeight = dot(sphereHeightData, vec2(1.0));

  vec3 localPosition = sphereNormal * ((sphereHeight > 1e-6) ? clamp(sphereHeight, planetData.bottomRadiusTopRadiusHeightMapScale.x * 0.5, planetData.bottomRadiusTopRadiusHeightMapScale.y) : 1e-6);

  vec3 position = (planetData.modelMatrix * vec4(localPosition, 1.0)).xyz;

  vec3 worldSpacePosition = position;

  vec3 normal = sphereNormal;

  vec4 viewSpacePosition = viewMatrix * vec4(position, 1.0);
  viewSpacePosition.xyz /= viewSpacePosition.w;

  outBlock.localPosition = localPosition;
  outBlock.position = position;
  outBlock.sphereNormal = sphereNormal;      
  outBlock.normal = normalize((planetData.normalMatrix * vec4(normal, 0.0)).xyz);
  outBlock.worldSpacePosition = worldSpacePosition;
  outBlock.viewSpacePosition = viewSpacePosition.xyz;  
  outBlock.cameraRelativePosition = worldSpacePosition - cameraPosition;
  outBlock.jitter = pushConstants.jitter;
  outBlock.mapValue = mapHeight(localPosition, sphereHeight);
  outBlock.waterOverSurface = (sphereHeightData.y > 1e-6) ? 1.0 : 0.0;
  outBlock.underWater = ((inBlocks[0].flags & (1u << 0u)) != 0u) ? 1.0 : 0.0;

	gl_Position = viewProjectionMatrix * vec4(position, 1.0);
  
}
