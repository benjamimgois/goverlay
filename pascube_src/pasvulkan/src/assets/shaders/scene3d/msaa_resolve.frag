#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_GOOGLE_include_directive : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outColor;

layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInputMS uSubPassInputMSAA;

layout (set = 0, binding = 1, std430) buffer HistogramLuminanceBuffer {
  float histogramLuminance;
  float luminanceFactor; 
} histogramLuminanceBuffer;

layout(push_constant) uniform PushConstants { 
  int countSamples; 
} pushConstants;

/* clang-format on */

#include "bidirectional_tonemapping.glsl"
#include "premultiplied_alpha.glsl"

// This fragment shader resolves MSAA in a tonemapping compliant way using the luminance factor from the previous frame and
// a universal tone mapping operator, which is also reversible.

// The luminance factor from the histogram from the previous frame is used, because the new value for the current frame is 
// not yet available, as it will be calculated after this fragment shader. Therefore it has a one frame delay, but it should
// not be noticeable in practice and be good enough for most use cases.

void main() {
  vec4 color = vec4(0.0);
  int samples = pushConstants.countSamples;
  float luminanceFactor = histogramLuminanceBuffer.luminanceFactor; 
  for (int i = 0; i < samples; i++) {
    color += ApplyToneMapping(subpassLoad(uSubPassInputMSAA, i) * luminanceFactor);
  }
  color = ApplyInverseToneMapping(color / float(samples)) / luminanceFactor;   
  outColor = vec4(clamp(color.xyz, vec3(-65504.0), vec3(65504.0)), color.w);
}