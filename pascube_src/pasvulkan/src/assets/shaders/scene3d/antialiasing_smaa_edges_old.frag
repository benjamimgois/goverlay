#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 inTexCoord;
layout(location = 1) in vec4 inOffset0;
layout(location = 2) in vec4 inOffset1;
layout(location = 3) in vec4 inOffset2;

layout(location = 0) out vec2 outFragOutput;

layout(set = 0, binding = 0) uniform sampler2DArray uColorTexture;

#include "antialiasing_smaa.glsl"

#include "antialiasing_srgb.glsl"

#if SMAA_PREDICATION
layout(set = 0, binding = 1) uniform sampler2DArray uPredicationTexture;
#endif

void main() {
  vec2 threshold = vec2(SMAA_THRESHOLD);
#if SMAA_PREDICATION
  {
    vec3 neighbours = textureGather(uPredicationTexture, vec3(fma(vec2(1.0) / vec2(textureSize(uPredicationTexture, 0).xy), vec2(-0.5), inTexCoord), float(gl_ViewIndex)), 0).yxz;
    vec2 delta = abs(neighbours.xx - neighbours.yz);
    vec2 edges = step(SMAA_PREDICATION_THRESHOLD, delta);
    threshold = SMAA_PREDICATION_SCALE * SMAA_THRESHOLD * fma(edges, vec2(-SMAA_PREDICATION_STRENGTH), vec2(1.0));
  }
#endif
#if defined(LUMA)
  const vec3 weights = vec3(0.2126, 0.7152, 0.0722);
  float L = dot(ApplyToneMapping(textureLod(uColorTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0.0).xyz), weights);
  vec4 delta;
  vec2 Llt = vec2(dot(ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset0.xy, float(gl_ViewIndex)), 0.0).xyz), weights), 
                  dot(ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset0.zw, float(gl_ViewIndex)), 0.0).xyz), weights));
  delta.xy = abs(vec2(L) - Llt);
  vec2 edges = step(threshold, delta.xy);
  if (dot(edges, vec2(1.0, 1.0)) == 0.0) {
    discard;
  } else {
    vec2 Lrb = vec2(dot(ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset1.xy, float(gl_ViewIndex)), 0.0).xyz), weights), 
                    dot(ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset1.zw, float(gl_ViewIndex)), 0.0).xyz), weights));
    delta.zw = abs(vec2(L) - Lrb);
    vec2 maxDelta = max(delta.xy, delta.zw);
    vec2 Llltt = vec2(dot(ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset2.xy, float(gl_ViewIndex)), 0.0).xyz), weights), 
                      dot(ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset2.zw, float(gl_ViewIndex)), 0.0).xyz), weights));
    delta.zw = abs(Llt - Llltt);
    maxDelta = max(maxDelta.xy, delta.zw);
    edges.xy *= step(max(maxDelta.x, maxDelta.y), SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR * delta.xy);
    outFragOutput = edges;
  }
#else
  vec4 delta;
  vec3 c = ApplyToneMapping(textureLod(uColorTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0.0).xyz);
  vec3 t = abs(c - ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset0.xy, float(gl_ViewIndex)), 0.0).xyz));
  delta.x = max(max(t.r, t.g), t.b);
  t = abs(c - ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset0.zw, float(gl_ViewIndex)), 0.0).xyz));
  delta.y = max(max(t.r, t.g), t.b);
  vec2 edges = step(threshold, delta.xy);
  if (dot(edges, vec2(1.0, 1.0)) == 0.0) {
    discard;
  } else {
    t = abs(c - ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset1.xy, float(gl_ViewIndex)), 0.0).xyz));
    delta.z = max(max(t.r, t.g), t.b);
    t = abs(c - ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset1.zw, float(gl_ViewIndex)), 0.0).xyz));
    delta.w = max(max(t.r, t.g), t.b);
    vec2 maxDelta = max(delta.xy, delta.zw);
    t = abs(c - ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset2.xy, float(gl_ViewIndex)), 0.0).xyz));
    delta.z = max(max(t.r, t.g), t.b);
    t = abs(c - ApplyToneMapping(textureLod(uColorTexture, vec3(inOffset2.zw, float(gl_ViewIndex)), 0.0).xyz));
    delta.w = max(max(t.r, t.g), t.b);
    maxDelta = max(maxDelta.xy, delta.zw);
    edges.xy *= step(max(maxDelta.x, maxDelta.y), SMAA_LOCAL_CONTRAST_ADAPTATION_FACTOR * delta.xy);
    outFragOutput = edges;
  }
#endif
}
