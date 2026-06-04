#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_viewport_layer_array : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;
layout(location = 1) flat in int inFaceIndex;

layout(location = 0) out vec4 oOutput;

#ifdef MSAA
layout(set = 0, binding = 0) uniform sampler2DMSArray uTexture;

layout(push_constant) uniform PushConstants { 
  int countSamples; 
} pushConstants;
#else
layout(set = 0, binding = 0) uniform sampler2DArray uTexture;
#endif

/* clang-format on */

void main() {
  ivec3 position = ivec3(ivec2(gl_FragCoord.xy), int(inFaceIndex));
#ifdef MSAA
  vec4 sum = vec4(0.0);
  int samples = pushConstants.countSamples;
  for (int i = 0; i < samples; i++) {
    float                                         //
        d = texelFetch(uTexture, position, i).x,  //
        d2 = d * d;
    sum += vec4(d, d2, d2 * d, d2 * d2);
  }
  oOutput = ((sum / float(samples)) *                                           //
             mat4(-2.07224649, 32.23703778, -68.571074599, 39.3703274134,       //
                  13.7948857237, -59.4683975703, 82.0359750338, -35.364903257,  //
                  0.105877704, -1.9077466311, 9.3496555107, -6.6543490743,      //
                  9.7924062118, -33.7652110555, 47.9456096605, -23.9728048165)) +
            vec2(0.035955884801, 0.0).xyyy;  //
#else
  float                                                                              //
      d = texelFetch(uTexture, position, 0).x,                                          //
      d2 = d * d;                                                                    //
  oOutput = (vec4(d, d2, d2 * d, d2 * d2) *                                           //
             mat4(-2.07224649, 32.23703778, -68.571074599, 39.3703274134,       //
                  13.7948857237, -59.4683975703, 82.0359750338, -35.364903257,  //
                  0.105877704, -1.9077466311, 9.3496555107, -6.6543490743,      //
                  9.7924062118, -33.7652110555, 47.9456096605, -23.9728048165)) +
            vec2(0.035955884801, 0.0).xyyy;  //
#endif
}
