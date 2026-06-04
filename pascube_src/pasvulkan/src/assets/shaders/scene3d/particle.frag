#version 450 core

#define PARTICLE_FRAGMENT_SHADER

#ifndef VOXELIZATION  
  #extension GL_EXT_multiview : enable
#endif
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable

#include "bufferreference_definitions.glsl"

#if defined(LOCKOIT) || defined(DFAOIT)
  #extension GL_ARB_post_depth_coverage : enable
  #ifdef INTERLOCK
    #extension GL_ARB_fragment_shader_interlock : enable
    #define beginInvocationInterlock beginInvocationInterlockARB
    #define endInvocationInterlock endInvocationInterlockARB
    #ifdef MSAA
      layout(early_fragment_tests, post_depth_coverage, sample_interlock_ordered) in;
    #else
      layout(early_fragment_tests, post_depth_coverage, pixel_interlock_ordered) in;
    #endif
  #else
    #if defined(ALPHATEST)
      layout(post_depth_coverage) in;
    #else
      layout(early_fragment_tests, post_depth_coverage) in;
    #endif
  #endif
#elif !defined(ALPHATEST)
  layout(early_fragment_tests) in;
#endif

#ifdef VOXELIZATION
  layout(location = 0) in vec3 inWorldSpacePosition;
#else
  layout(location = 0) in vec3 inViewSpacePosition;
#endif
layout(location = 1) in vec3 inTexCoord;
layout(location = 2) in vec4 inColor;
#ifdef VOXELIZATION
  layout(location = 3) in vec3 inNormal;
  layout(location = 4) flat in uint inTextureID;
  layout(location = 5) flat in vec3 inAABBMin;
  layout(location = 6) flat in vec3 inAABBMax;
  layout(location = 7) flat in uint inCascadeIndex; 
  layout(location = 8) in vec3 inVoxelPosition;
  layout(location = 9) flat in vec3 inVertex0;
  layout(location = 10) flat in vec3 inVertex1;
  layout(location = 11) flat in vec3 inVertex2;
#else
  layout(location = 3) flat in uint inTextureID;
#endif

// Specialization constants are sadly unusable due to dead slow shader stage compilation times with several minutes "per" pipeline, 
// when the validation layers and a debugger (GDB, LLDB, etc.) are active at the same time!
#undef USE_SPECIALIZATION_CONSTANTS
#ifdef USE_SPECIALIZATION_CONSTANTS
layout (constant_id = 0) const bool UseReversedZ = true;
#endif

// Global descriptor set

#include "globaldescriptorset.glsl"

// Pass descriptor set

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(std140, set = 1, binding = 0) uniform uboViews {
  View views[256];
} uView;

#ifdef VOXELIZATION
  layout(location = 0) out vec4 outFragColor;
  #include "voxelization_globals.glsl" 
#endif

#ifndef VOXELIZATION
  #define TRANSPARENCY_DECLARATION
  #include "transparency.glsl"
  #undef TRANSPARENCY_DECLARATION
#endif

/* clang-format on */

#if defined(VOXELIZATION)
  #include "rgb9e5.glsl"
#else
  #define TRANSPARENCY_GLOBALS
  #include "transparency.glsl"
  #undef TRANSPARENCY_GLOBALS
#endif

void main() {

#ifdef VOXELIZATION

#if 0
  bool additiveBlending = (inTextureID & 0x80000000u) != 0; // Reuse the MSB of the texture ID to indicate additive blending
  if(additiveBlending) {
    discard;
    return;
  } 
#endif 
  
  vec4 baseColor = (any(lessThan(inTexCoord.xy, vec2(0.0))) || any(greaterThan(inTexCoord.xy, vec2(1.0)))) ? vec4(0.0) : 
                   ((((inTextureID & 0x40000000u) != 0) ? 
                     texture(u3DTextures[nonuniformEXT(((inTextureID & 0x3fff) << 1) | (int(1/*sRGB*/) & 1))], inTexCoord.xyz) :
                     texture(u2DTextures[nonuniformEXT(((inTextureID & 0x3fff) << 1) | (int(1/*sRGB*/) & 1))], inTexCoord.xy )) * inColor);
  vec4 emissionColor = baseColor;
  float alpha = baseColor.w;

  uint flags = (1u << 6u); // Double-sided
  vec3 normal = inNormal;

  #include "voxelization_fragment.glsl" 

#else

  bool additiveBlending = (inTextureID & 0x80000000u) != 0; // Reuse the MSB of the texture ID to indicate additive blending

  bool is3DTexture = (inTextureID & 0x40000000u) != 0; // Reuse the MSB of the texture ID to indicate 3D texture

#ifdef DEPTHONLY
#if defined(ALPHATEST) || defined(LOOPOIT) || defined(LOCKOIT) || defined(WBOIT) || defined(MBOIT) || defined(DFAOIT)
  float alpha = (any(lessThan(inTexCoord.xy, vec2(0.0))) || any(greaterThan(inTexCoord.xy, vec2(1.0)))) ? 0.0 : 
                  ((((inTextureID & 0x40000000u) != 0) ? 
                    texture(u3DTextures[nonuniformEXT(((inTextureID & 0x3fff) << 1) | (int(1/*sRGB*/) & 1))], inTexCoord.xyz).w :
                    texture(u2DTextures[nonuniformEXT(((inTextureID & 0x3fff) << 1) | (int(1/*sRGB*/) & 1))], inTexCoord.xy ).w) * inColor.w);  
#endif
#else
 vec4 finalColor = (any(lessThan(inTexCoord.xy, vec2(0.0))) || any(greaterThan(inTexCoord.xy, vec2(1.0)))) ? vec4(0.0) : 
                    ((((inTextureID & 0x40000000u) != 0) ? 
                      texture(u3DTextures[nonuniformEXT(((inTextureID & 0x3fff) << 1) | (int(1/*sRGB*/) & 1))], inTexCoord.xyz) :
                      texture(u2DTextures[nonuniformEXT(((inTextureID & 0x3fff) << 1) | (int(1/*sRGB*/) & 1))], inTexCoord.xy )) * inColor);
  float alpha = finalColor.w; 
#if !(defined(WBOIT) || defined(MBOIT))
#ifndef BLEND 
  outFragColor = vec4(clamp(finalColor.xyz, vec3(-65504.0), vec3(65504.0)), finalColor.w);
#endif
#endif
#endif

#define TRANSPARENCY_IMPLEMENTATION
#include "transparency.glsl"
#undef TRANSPARENCY_IMPLEMENTATION

#endif

}

/*oid main() {
  outFragColor = vec4(vec3(mix(0.25, 1.0, max(0.0, dot(workNormal, vec3(0.0, 0.0, 1.0))))), 1.0);
//outFragColor = vec4(texture(uTexture, inTexCoord)) * vec4(vec3(mix(0.25, 1.0, max(0.0, dot(workNormal, vec3(0.0, 0.0, 1.0))))), 1.0);
}*/
