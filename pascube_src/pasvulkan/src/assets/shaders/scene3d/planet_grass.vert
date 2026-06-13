#version 450 core

// This vertex shader is used for grass rendering, in conjunction with compute-based tasks and mesh shader emulation, in scenarios 
// where mesh shaders are unsuitable:
// - Hardware lacks support for mesh shaders.
// - Vulkan implementation doesn't support multi-view rendering with mesh shaders (e.g. Intel).
// - Ray tracing requires all vertex data upfront, contrary to the streaming nature of mesh shaders.

#pragma shader_stage(vertex)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable

#include "bufferreference_definitions.glsl"

//#define COMPACT_VERTEX_DATA

/*
layout(location = 0) in uvec4 inPositionXYZNormalXYZTexCoordU;
layout(location = 1) in uvec4 inTangentSignTexCoordVBladeIndexBladeID;
*/

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec4 inNormalXYZTexCoordU;
layout(location = 2) in vec4 inTangentSign;
layout(location = 3) in float inTexCoordV;
#if defined(VELOCITY)
// In this case, blade index and blade ID are not used, so we can repurpose these attributes to store 
// packed velocity vectors, since blade index and ID are not yet used by the following shader stages.
// But this can be changed later if needed. But for now, it saves bandwidth and memory.
layout(location = 4) in uint inPackedVelocityXY;
layout(location = 5) in uint inPackedVelocityZUnused;
#else
// layout(location = 4) in uint inBladeIndex;
// layout(location = 5) in uint inBladeID;
#endif

#if defined(RAYTRACING)

layout(location = 0) out vec3 outWorldSpacePosition;

layout(location = 1) out OutBlock {
  vec3 position;
  vec3 normal;
  vec4 tangentSign;
  vec2 texCoord;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
  flat uint meshletID; 
} outBlock;

#else

layout(location = 0) out OutBlock {
  vec3 position;
  vec3 normal;
  vec4 tangentSign;
  vec2 texCoord;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
  flat uint meshletID; 
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

#include "adjugate.glsl"

#include "planet_grass.glsl"

#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 

#include "quaternion.glsl" 

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix;
mat4 projectionMatrix = uView.views[viewIndex].projectionMatrix;
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix;

void main(){          

  // Calculate the model matrix from the position/scale and orientation/quaternion push constant values
  mat4 modelMatrix = mat4(quaternionToMatrix(pushConstants.modelMatrixOrientation));
  modelMatrix[3].xyz = pushConstants.modelMatrixPositionScale.xyz;
  modelMatrix[0].xyz *= pushConstants.modelMatrixPositionScale.w;
  modelMatrix[1].xyz *= pushConstants.modelMatrixPositionScale.w;
  modelMatrix[2].xyz *= pushConstants.modelMatrixPositionScale.w; 

  mat4 viewProjectionMatrix = projectionMatrix * viewMatrix;

#if 1
  // The actual standard approach
  vec3 cameraPosition = inverseViewMatrix[3].xyz;
#else
  // This approach assumes that the view matrix has no scaling or skewing, but only rotation and translation.
  vec3 cameraPosition = (-viewMatrix[3].xyz) * mat3(viewMatrix);
#endif   

  vec3 position = (modelMatrix * vec4(inPosition, 1.0)).xyz;
//vec3 position = (modelMatrix * vec4(uintBitsToFloat(inPositionXYZNormalXYZTexCoordU.xyz), 1.0)).xyz;

#if defined(VELOCITY)
  vec3 previousPosition = position + vec3(unpackSnorm2x16(inPackedVelocityXY), unpackSnorm2x16(inPackedVelocityZUnused).x);
#endif

  vec3 worldSpacePosition = position;

  // Decode the normal and texture U coordinate from a single 32-bit unsigned integer.
/*uvec4 encodedNormalTexCoordU = (uvec4(inNormalXYZTexCoordU) >> uvec4(0u, 10u, 20u, 30u)) & uvec2(0x3ffu, 0x3u).xxxy;
  vec3 normal = normalize(max(vec3((-(encodedNormalTexCoordU.xyz & ivec3(0x200u))) | (encodedNormalTexCoordU.xyz & ivec3(0x1ffu))) / vec3(ivec3(0x1ffu)), vec3(-1.0)));*/
  vec3 normal = normalize(inNormalXYZTexCoordU.xyz);

  // Decode the tangent and texture V coordinate from a single 32-bit unsigned integer.
/*uvec4 encodedTangentSign = (uvec4(inTangentSign.x) >> uvec4(0u, 10u, 20u, 30u)) & uvec2(0x3ffu, 0x3u).xxxy;
  vec4 tangentSign = vec4(normalize(max(vec3((-(encodedTangentSign.xyz & ivec3(0x200u))) | (encodedTangentSign.xyz & ivec3(0x1ffu))) / vec3(ivec3(0x1ffu)), vec3(-1.0))), ((encodedTangentSign.w & 1u) != 0) ? -1.0 : 1.0);*/
  vec4 tangentSign = vec4(normalize(inTangentSign.xyz), (abs(inTangentSign.w) > 1e-3) ? -1.0 : 1.0);  
  
  vec2 texCoordUV = vec2((abs(inNormalXYZTexCoordU.w) > 1e-3) ? 1.0 : 0.0, inTexCoordV);
    
  vec4 viewSpacePosition = viewMatrix * vec4(position, 1.0);
  viewSpacePosition.xyz /= viewSpacePosition.w;

  outBlock.position = position;         
  outBlock.normal = normalize(adjugate(modelMatrix) * normal);
  outBlock.tangentSign = tangentSign;
  outBlock.texCoord = texCoordUV;
  outBlock.worldSpacePosition = worldSpacePosition;
  outBlock.viewSpacePosition = viewSpacePosition.xyz;  
  outBlock.cameraRelativePosition = worldSpacePosition - cameraPosition;
#ifdef VELOCITY
  outBlock.currentClipSpace = viewProjectionMatrix * vec4(position, 1.0);
  outBlock.previousClipSpace = (uView.views[viewIndex + pushConstants.countAllViews].projectionMatrix * uView.views[viewIndex + pushConstants.countAllViews].viewMatrix) * vec4(previousPosition, 1.0);
#endif
  outBlock.meshletID = 0u; // No meshlet ID in the vertex shader path, since meshlets are not used here, but we still keep this field in the output for consistency with the mesh shader path, where meshlet ID is available and can be used for debugging or other purposes.

#if defined(RAYTRACING)
  outWorldSpacePosition = worldSpacePosition;
#endif

  gl_Position = viewProjectionMatrix * vec4(position, 1.0);

}