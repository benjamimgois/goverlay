#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_viewport_layer_array : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec2 oOutput;

layout(set = 0, binding = 0) uniform sampler2DArray uTexture;

layout(push_constant) uniform PushConstants { 
  vec4 direction;
} pushConstants;
/* clang-format on */

void main() {
  int viewIndex = int(gl_ViewIndex);
  ivec2 origin = ivec2(gl_FragCoord.xy);
  ivec2 ts = ivec2(textureSize(uTexture, 0).xy) - ivec2(1);
  int nSamples = 8;
  float SIGMA = (float(nSamples) + 1.0) * 0.5;
  float sig2 = SIGMA * SIGMA;
  const float TWO_PI = 6.2831853071795;
  const float E = 2.7182818284590;

  // set up incremental counter:
  vec3 gaussInc;
  gaussInc.x = 1.0 / (sqrt(TWO_PI) * SIGMA);
  gaussInc.y = exp(-(0.5 / sig2));
  gaussInc.z = gaussInc.y * gaussInc.y;

  // accumulate results:
  float sum = gaussInc.x;
  vec2 center = texelFetch(uTexture, ivec3(origin, viewIndex), 0).xy;
  float result;
  if (isinf(center.y)) {
    result = center.x;
    sum = 1.0;
  } else {
    result = center.x * sum;
    for (int i = 1; i < nSamples; ++i) {
      gaussInc.xy *= gaussInc.yz;
      ivec2 offset = i * ivec2(pushConstants.direction) * 2;
      for (int j = -1; j <= 1; j += 2) {
        vec2 t = texelFetch(uTexture, ivec3(clamp(origin + (offset * int(j)), ivec2(0), ts), viewIndex), 0).xy;
        if (!isinf(center.y)) {
          float weight = gaussInc.x * (1.0 / (1.0 + (abs(center.y - t.y) * 100.0)));
          result += t.x * weight;
          sum += weight;
        }
      }
    }
  }
  oOutput = vec2(result / sum, center.y);
}
