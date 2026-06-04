#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outColor;

layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInput uSubpassInputOpaque;

#ifdef MSAA

#ifdef NO_MSAA_WATER
layout(input_attachment_index = 1, set = 0, binding = 1) uniform subpassInput uSubpassInputWater;
#else
layout(input_attachment_index = 1, set = 0, binding = 1) uniform subpassInputMS uSubpassInputWater;
#endif

layout(input_attachment_index = 2, set = 0, binding = 2) uniform subpassInputMS uSubpassInputTransparent;
#else

layout(input_attachment_index = 1, set = 0, binding = 1) uniform subpassInput uSubpassInputWater;

layout(input_attachment_index = 2, set = 0, binding = 2) uniform subpassInput uSubpassInputTransparent;

#endif

#if defined(MSAA)
layout(set = 0, binding = 3, std430) buffer HistogramLuminanceBuffer {
  float histogramLuminance;
  float luminanceFactor; 
} histogramLuminanceBuffer;
#endif

#ifdef MSAA
layout(push_constant) uniform PushConstants { 
  int countSamples; 
} pushConstants;
#endif

/* clang-format on */

#if defined(MSAA)
#include "bidirectional_tonemapping.glsl"
#include "premultiplied_alpha.glsl"
#endif

void blend(inout vec4 target, const in vec4 source) {                  //
  target += (1.0 - target.a) * vec4(source.xyz * source.a, source.a);  //
}

void main() {
  vec4 color = vec4(0.0);

#ifdef MSAA
  vec4 transparency = vec4(0.0);
  int countSamples = pushConstants.countSamples;
  for (int sampleIndex = 0; sampleIndex < countSamples; sampleIndex++) {
    transparency += ApplyToneMapping(subpassLoad(uSubpassInputTransparent, sampleIndex) * histogramLuminanceBuffer.luminanceFactor);
  }
  transparency = ApplyInverseToneMapping(transparency / float(countSamples)) / histogramLuminanceBuffer.luminanceFactor;
#else
  vec4 transparency = subpassLoad(uSubpassInputTransparent);
#endif
  bool hasTransparency = transparency.w > 1e-4;
  blend(color, transparency);

  vec4 waterColor;  
#if defined(MSAA) && !defined(NO_MSAA_WATER)
  {
    vec4 sampleColor = vec4(0.0);  
    for (int sampleIndex = 0; sampleIndex < countSamples; sampleIndex++) {
      sampleColor += ApplyToneMapping(subpassLoad(uSubpassInputWater, sampleIndex) * histogramLuminanceBuffer.luminanceFactor);
    }
    waterColor = ApplyInverseToneMapping(sampleColor / float(countSamples)) / histogramLuminanceBuffer.luminanceFactor;   
  }
#else
  waterColor = subpassLoad(uSubpassInputWater); // Already premultiplied alpha
#endif
  if(waterColor.w > 1e-4){
    hasTransparency = true;
  }
  blend(color, waterColor);

  blend(color, subpassLoad(uSubpassInputOpaque));

  outColor = vec4(clamp(color.xyz, vec3(-65504.0), vec3(65504.0)), hasTransparency ? 0.0 : 1.0);
}