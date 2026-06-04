#ifndef MESH_RENDERING_PASS_DESCRIPTORSET_GLSL
#define MESH_RENDERING_PASS_DESCRIPTORSET_GLSL

#define NUM_SHADOW_CASCADES 4

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256];
} uView;

#if !(defined(DEPTHONLY) || defined(VOXELIZATION))

layout(set = 1, binding = 1) uniform sampler2D uImageBasedLightingBRDFTextures[];  // 0 = GGX, 1 = Charlie, 2 = Sheen E

layout(set = 1, binding = 2) uniform samplerCube uImageBasedLightingEnvMaps[];  // 0 = GGX(1), 1 = Charlie(1), 2 = Lambertian (1), 3 = GGX(2), 4 = Charlie(2), 5 = Lambertian(2)

#ifdef SHADOWS
const uint SHADOWMAP_MODE_NONE = 1;
const uint SHADOWMAP_MODE_PCF = 2;
const uint SHADOWMAP_MODE_DPCF = 3;
const uint SHADOWMAP_MODE_PCSS = 4;
const uint SHADOWMAP_MODE_MSM = 5;

layout(set = 1, binding = 3, std140) uniform uboCascadedShadowMaps {
  mat4 shadowMapMatrices[NUM_SHADOW_CASCADES];
  vec4 shadowMapSplitDepthsScales[NUM_SHADOW_CASCADES];
  vec4 constantBiasNormalBiasSlopeBiasClamp[NUM_SHADOW_CASCADES];
  uvec4 metaData; // x = type
} uCascadedShadowMaps;

layout(set = 1, binding = 4) uniform sampler2DArray uCascadedShadowMapTexture;

#ifdef PCFPCSS

// Yay! Binding Aliasing! :-)
layout(set = 1, binding = 4) uniform sampler2DArrayShadow uCascadedShadowMapTextureShadow;

#endif // PCFPCSS

#endif // SHADOWS

// 0 = SSAO, 1 = Opaque frame buffer, 2 = Opaque depth buffer, 3 = Clouds shadow map

layout(set = 1, binding = 5) uniform sampler2DArray uPassTextures[]; 

//layout(set = 1, binding = 5) uniform sampler2DMSArray uPassTexturesMS[];

#endif // !(defined(DEPTHONLY) || defined(VOXELIZATION))

#endif // MESH_RENDERING_PASS_DESCRIPTORSET_GLSL