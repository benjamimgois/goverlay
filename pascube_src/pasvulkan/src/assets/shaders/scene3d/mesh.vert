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
#extension GL_GOOGLE_include_directive : enable

#ifdef RAYTRACING
#extension GL_EXT_fragment_shader_barycentric : enable // for calculating the geometry normal in the fragment shader without dFdx/dFdy in a more direct way, per pervertexEXT
#endif

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec4 inNormalSign;
layout(location = 2) in vec3 inTangent;
layout(location = 3) in vec3 inModelScale;
layout(location = 4) in vec2 inTexCoord0;
layout(location = 5) in vec2 inTexCoord1;
layout(location = 6) in vec4 inColor0;
layout(location = 7) in uint inMaterialID;
#ifdef VELOCITY
layout(location = 8) in vec3 inPreviousPosition;
layout(location = 9) in uint inGeneration;
layout(location = 10) in uint inPreviousGeneration;
#endif

layout(location = 0) out vec3 outWorldSpacePosition;
layout(location = 1) out vec3 outViewSpacePosition;
layout(location = 2) out vec3 outCameraRelativePosition;
layout(location = 3) out vec4 outTangentSign;
layout(location = 4) out vec3 outNormal;
layout(location = 5) out vec2 outTexCoord0;
layout(location = 6) out vec2 outTexCoord1;
layout(location = 7) out vec4 outColor0;
layout(location = 8) out vec3 outModelScale;
layout(location = 9) flat out uint outMaterialID;
layout(location = 10) flat out uint outInstanceDataIndex;
#ifndef VOXELIZATION
layout(location = 11) flat out int outViewIndex;
layout(location = 12) flat out uint outFrameIndex;
#ifdef VELOCITY
layout(location = 13) flat out vec4 outJitter;
layout(location = 14) out vec4 outPreviousClipSpace;
layout(location = 15) out vec4 outCurrentClipSpace;
#else
layout(location = 13) flat out vec2 outJitter;
#endif // VELOCITY
#endif // VOXELIZATION

/* clang-format off */

/*#ifdef VOXELIZATION

// Should be the same as in the geometry shader, since the minimum "maximum-size" of push constants is 128 bytes
layout (push_constant) uniform PushConstants {
  uint viewIndex; // for the main primary view (in VR mode just simply the left eye, which will use as the primary view for the lighting for the voxelization then) 
} pushConstants;

#else
*/

#include "mesh_pushconstants.glsl" 

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

layout(set = 0, binding = 0, std430) readonly buffer InstanceMatrices {
  mat4 instanceMatrices[]; // pair-wise: 0 = base, 1 = previous (for velocity)
};

layout(set = 0, binding = 5, std430) readonly buffer InstanceDataIndexBuffer {
  uint instanceDataIndices[];
};

out gl_PerVertex {
	vec4 gl_Position;
	float gl_PointSize;
};

/* clang-format on */

#include "adjugate.glsl"

const mat4 identityMatrix = mat4(1.0, 0.0, 0.0, 0.0,
                                 0.0, 1.0, 0.0, 0.0,
                                 0.0, 0.0, 1.0, 0.0,
                                 0.0, 0.0, 0.0, 1.0);

void main() {

#ifdef VOXELIZATION
  uint viewIndex = pushConstants.viewBaseIndex;
#else
  uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
#endif
 
  mat3 tangentSpace;
  {
    vec3 tangent = inTangent.xyz;
    vec3 normal = inNormalSign.xyz;
    tangentSpace = mat3(normalize(tangent), normalize(cross(normal, tangent)) * inNormalSign.w, normalize(normal));
  }

  View view = uView.views[viewIndex];

#if defined(SHADERDEBUG) && !(defined(VELOCITY) || defined(VOXELIZATION))
  if(gl_VertexIndex == 0){
    mat4 m = /*view.projectionMatrix * view.viewMatrix;*/ view.inverseProjectionMatrix;
    debugPrintfEXT("view-index %i matrix: %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f", 
                   viewIndex, 
                   m[0][0], 
                   m[0][1],
                   m[0][2],
                   m[0][3],
                   m[1][0], 
                   m[1][1],
                   m[1][2],
                   m[1][3],
                   m[2][0], 
                   m[2][1],
                   m[2][2],
                   m[2][3],
                   m[3][0], 
                   m[3][1],
                   m[3][2],
                   m[3][3]);
  }
#endif

#if 1
  // The actual standard approach
  vec3 cameraPosition = view.inverseViewMatrix[3].xyz;
#else
  // This approach assumes that the view matrix has no scaling or skewing, but only rotation and translation.
  vec3 cameraPosition = (-view.viewMatrix[3].xyz) * mat3(view.viewMatrix);
#endif

  vec3 modelScale = inModelScale; 

  vec4 clipSpacePosition;

#ifdef VELOCITY  
  vec4 previousClipSpacePosition;
#endif

  vec3 worldSpacePosition;

  vec4 viewSpacePosition;

  const uint instanceIndex = uint(gl_InstanceIndex);

  // gl_InstanceIndex is always 0 for non-instanced rendering, where we don't need to do this anyway then, and skip the transformations 
  // for to save some cycles and memory bandwidth, given the branch is always not taken in the current thread warp on the GPU.
  if(instanceIndex > 0u){  

    outInstanceDataIndex = instanceDataIndices[instanceIndex];

    // The base mesh data is assumed to be non-pretransformed by its origin. If it is pretransformed by its origin, it will be treated
    // as a delta transformation. It is because the mesh vertices are pretransformed by a compute shader, but this was originally only 
    // for non-instanced meshes. Therefore, the original to-be-instanced mesh data should be non-pretransformed by its origin.
    
    mat4 instanceMatrix = instanceMatrices[instanceIndex << 1u]; 

    modelScale *= vec3(length(instanceMatrix[0].xyz), length(instanceMatrix[1].xyz), length(instanceMatrix[2].xyz)); // needed for transmissive materials

    tangentSpace = adjugate(instanceMatrix) * tangentSpace;   

    clipSpacePosition = view.projectionMatrix * (viewSpacePosition = ((view.viewMatrix * instanceMatrix) * vec4(inPosition, 1.0)));
    viewSpacePosition.xyz /= viewSpacePosition.w;

    worldSpacePosition = (instanceMatrix * vec4(inPosition, 1.0)).xyz;

#ifdef VELOCITY  
    if(uint(inGeneration) != uint(inPreviousGeneration)){
      previousClipSpacePosition = clipSpacePosition;
    }else{  
      View previousView = uView.views[viewIndex + pushConstants.countAllViews];
      previousClipSpacePosition = previousView.projectionMatrix * ((previousView.viewMatrix * instanceMatrices[(instanceIndex << 1u) | 1u]) * vec4(inPreviousPosition, 1.0));
    }
#endif

  }else{

    // The instance effect index is always 0 for non-instanced rendering, since the instance effect data is only for instanced meshes. And
    // instance effect data #0 is the default instance effect data, which is the identity effect with no effect at all.
    outInstanceDataIndex = 0u;

    // Otherwise, the mesh data is assumed to be non-pretransformed by its origin, and the mesh vertices are pretransformed by a compute shader.

    worldSpacePosition = inPosition;

    clipSpacePosition = view.projectionMatrix * (viewSpacePosition = view.viewMatrix * vec4(inPosition, 1.0));
    viewSpacePosition.xyz /= viewSpacePosition.w;

#ifdef VELOCITY  
    if(uint(inGeneration) != uint(inPreviousGeneration)){
      previousClipSpacePosition = clipSpacePosition;
    }else{  
      View previousView = uView.views[viewIndex + pushConstants.countAllViews];
      previousClipSpacePosition = (previousView.projectionMatrix * previousView.viewMatrix) * vec4(inPreviousPosition, 1.0);
    }
#endif

  }

  outWorldSpacePosition = worldSpacePosition;
  outViewSpacePosition = viewSpacePosition.xyz;
  outCameraRelativePosition = worldSpacePosition - cameraPosition;
  outTangentSign = vec4(tangentSpace[0], inNormalSign.w);
  //outBitangent = tangentSpace[1];
  outNormal = tangentSpace[2];
  outTexCoord0 = inTexCoord0;
  outTexCoord1 = inTexCoord1;
  outColor0 = inColor0;
  outModelScale = modelScale;
  outMaterialID = inMaterialID;
#ifndef VOXELIZATION
  outViewIndex = int(viewIndex); 
  outFrameIndex = pushConstants.frameIndex;
#endif

#ifdef VOXELIZATION

  gl_Position = vec4(0.0, 0.0, 0.0, 1.0); // Overrided by geometry shader anyway

#else

#if defined(VELOCITY)

  outCurrentClipSpace = clipSpacePosition;

  outPreviousClipSpace = previousClipSpacePosition;
  
  outJitter = pushConstants.jitter;

#else
  
  outJitter = pushConstants.jitter.xy;

#endif

  gl_Position = clipSpacePosition;

#endif

  gl_PointSize = 1.0;
}
