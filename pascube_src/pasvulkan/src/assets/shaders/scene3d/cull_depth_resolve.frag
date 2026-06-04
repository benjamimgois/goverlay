#version 450 core

// This fragment shader resolves a MSAA depth texture into a R32 "color" texture.

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_viewport_layer_array : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;
layout(location = 1) flat in int inFaceIndex;

layout(location = 0) out float oOutput;

layout(set = 0, binding = 0) uniform sampler2DMSArray uTexture;

layout(push_constant) uniform PushConstants { 
  int countSamples; 
} pushConstants;

/* clang-format on */

#ifdef REVERSEDZ
  #define reduceOp min
#else
  #define reduceOp max
#endif

void main() {
  ivec3 position = ivec3(ivec2(gl_FragCoord.xy), int(inFaceIndex));  
  float result = texelFetch(uTexture, position, 0).x;
  for(int sampleIndex = 1, samples = pushConstants.countSamples; sampleIndex < samples; sampleIndex++){
    result = reduceOp(result, texelFetch(uTexture, position, sampleIndex).x);
  }
  oOutput = result;
}
