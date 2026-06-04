#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 inTexCoord;
layout(location = 1) in vec4 inOffset;

layout(location = 0) out vec4 outFragColor;

layout(set = 0, binding = 0) uniform sampler2DArray uColorTexture;
layout(set = 0, binding = 1) uniform sampler2DArray uBlendTexture;

#if SMAA_REPROJECTION
layout(set = 0, binding = 2) uniform sampler2DArray uVelocityTexture;
#endif

layout(push_constant) uniform PushConstants {
  vec4 metrics;  //
} pushConstants;

#include "antialiasing_smaa.glsl"

#include "antialiasing_srgb.glsl"

vec4 SMAA_RT_METRICS = pushConstants.metrics;

void SMAAMovc(bvec2 cond, inout vec2 variable, vec2 value) {
  if (cond.x) variable.x = value.x;
  if (cond.y) variable.y = value.y;
}

void SMAAMovc(bvec4 cond, inout vec4 variable, vec4 value) {
  SMAAMovc(cond.xy, variable.xy, value.xy);
  SMAAMovc(cond.zw, variable.zw, value.zw);
}

void main() {
  vec4 outColor;

  // Fetch the blending weights for current pixel:
  vec4 a;
  a.x = textureLod(uBlendTexture, vec3(inOffset.xy, float(gl_ViewIndex)), 0).w;   // Right
  a.y = textureLod(uBlendTexture, vec3(inOffset.zw, float(gl_ViewIndex)), 0).y;   // Top
  a.wz = textureLod(uBlendTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0).xz;  // Bottom / Left

  // Is there any blending weight with a value greater than 0.0?
  if (dot(a, vec4(1.0, 1.0, 1.0, 1.0)) <= 1e-5) {
    outColor = textureLod(uColorTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0.0);  // LinearSampler
#if SMAA_REPROJECTION
    outColor.w = sqrt(5.0 * length(textureLod(uVelocityTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0.0).xy)); 
#endif
  } else {
    bool h = max(a.x, a.z) > max(a.y, a.w);  // max(horizontal) > max(vertical)

    // Calculate the blending offsets:
    vec4 blendingOffset = vec4(0.0, a.y, 0.0, a.w);
    vec2 blendingWeight = a.yw;
    SMAAMovc(bvec4(h, h, h, h), blendingOffset, vec4(a.x, 0.0, a.z, 0.0));
    SMAAMovc(bvec2(h, h), blendingWeight, a.xz);
    blendingWeight /= dot(blendingWeight, vec2(1.0));

    // Calculate the texture coordinates:
    vec4 blendingCoord = fma(blendingOffset, vec4(SMAA_RT_METRICS.xy, -SMAA_RT_METRICS.xy), inTexCoord.xyxy);

    // We exploit bilinear filtering to mix current pixel with the chosen
    // neighbor:
    outColor = ApplyInverseToneMapping((blendingWeight.x * ApplyToneMapping(textureLod(uColorTexture, vec3(blendingCoord.xy, float(gl_ViewIndex)), 0.0))) +  // LinearSampler
                                       (blendingWeight.y * ApplyToneMapping(textureLod(uColorTexture, vec3(blendingCoord.zw, float(gl_ViewIndex)), 0.0))));   // LinearSampler
#if SMAA_REPROJECTION
    outColor.w = sqrt(5.0 * length((textureLod(uVelocityTexture, vec3(blendingCoord.xy, float(gl_ViewIndex)), 0.0).xy * blendingWeight.x) + 
                                   (textureLod(uVelocityTexture, vec3(blendingCoord.zw, float(gl_ViewIndex)), 0.0).xy * blendingWeight.y)));
#endif
  }
  outFragColor = outColor;
  //outFragColor = vec4(mix(pow((outColor.xyz + vec3(5.5e-2)) / vec3(1.055), vec3(2.4)), outColor.xyz / vec3(12.92), lessThan(outColor.xyz, vec3(4.045e-2))), outColor.w);
}
