#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_viewport_layer_array : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out float oOutputZ;

layout(set = 0, binding = 0) uniform sampler2D uTextureDepth;

layout(push_constant) uniform PushConstants { 
  mat4 inverseViewProjectionMatrix; 
} pushConstants;

/* clang-format on */

float linearizeDepth(float depth) {
#if 0
  vec2 v = (pushConstants.inverseViewProjectionMatrix * vec4(vec3(fma(inTexCoord, vec2(2.0), vec2(-1.0)), depth), 1.0)).yw;
#else
  vec2 v = fma(pushConstants.inverseViewProjectionMatrix[2].yw, vec2(depth), pushConstants.inverseViewProjectionMatrix[3].yw);
#endif
  return v.x / v.y;
}

void main() {
  float depth = textureLod(uTextureDepth, inTexCoord, 0).x;
#if 0
  vec4 worldSpacePosition = pushConstants.inverseViewProjectionMatrix * vec4(fma(inTexCoord, vec2(2.0), vec2(-1.0), depth, 1.0);
  oOutputZ = worldSpacePosition.y / worldSpacePosition.w;
#else
  oOutputZ = linearizeDepth(depth);
#endif
}
