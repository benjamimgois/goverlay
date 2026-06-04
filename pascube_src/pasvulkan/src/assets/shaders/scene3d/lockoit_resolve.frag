#version 450 core

#extension GL_EXT_multiview : enable
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

layout(set = 0, binding = 3, rgba32ui) uniform coherent uimageBuffer uOITImgABuffer;

layout(set = 0, binding = 4, r32ui) uniform coherent uimage2DArray uOITImgAux;

layout(set = 0, binding = 5, std140) uniform uboOIT {
  uvec4 oitViewPort;  //
} uOIT;

#ifdef MSAA
layout(set = 0, binding = 6, std430) buffer HistogramLuminanceBuffer {
  float histogramLuminance;
  float luminanceFactor; 
} histogramLuminanceBuffer;
#endif

/* clang-format on */

#if defined(MSAA)
#include "bidirectional_tonemapping.glsl"
#include "premultiplied_alpha.glsl"
#endif

void blend(inout vec4 target, const in vec4 source) {       
  target += (1.0 - target.a) * source;  // Source is already premultiplied
}

#define MAX_MSAA 16
#define MAX_OIT_LAYERS 16

void sort(inout uvec4 array[MAX_OIT_LAYERS], int count) {
#if MAX_OIT_LAYERS > 1
#if 1
  for (int i = (count - 2); i >= 0; --i) {
    for (int j = 0; j <= i; ++j) {
      if (
#ifdef REVERSEDZ
          (uintBitsToFloat(array[j].z) <= uintBitsToFloat(array[j + 1].z))
#else
          (uintBitsToFloat(array[j].z) >= uintBitsToFloat(array[j + 1].z))
#endif
      ) {
        uvec4 temp = array[j + 1];
        array[j + 1] = array[j];
        array[j] = temp;
      }
    }
  }
#else
  for (int i = 0, j = count - 1; i < j;) {
    if (
#ifdef REVERSEDZ
        (uintBitsToFloat(array[i].z) <= uintBitsToFloat(array[i + 1].z))
#else
        (uintBitsToFloat(array[i].z) >= uintBitsToFloat(array[i + 1].z))
#endif
    ) {
      uvec4 temp = array[i + 1];
      array[i + 1] = array[i];
      array[i] = temp;
      i += (i > 0) ? -1 : 1;
    } else {
      i++;
    }
  }
#endif
#endif  // #if OIT_LAYERS > 1
}

void main() {

  vec4 color = vec4(0.0);

#if 1
  uvec4 oitFragments[MAX_OIT_LAYERS];

  int oitMultiViewIndex = int(gl_ViewIndex);
  ivec3 oitCoord = ivec3(ivec2(gl_FragCoord.xy), oitMultiViewIndex);

  const int oitViewSize = int(uOIT.oitViewPort.z);
  const int oitCountLayers = int(uOIT.oitViewPort.w & 0xffffu);
  const int oitMultiViewSize = oitViewSize * oitCountLayers;
  const int oitABufferBaseIndex = ((oitCoord.y * int(uOIT.oitViewPort.x)) + oitCoord.x) + (oitMultiViewSize * oitMultiViewIndex);

  const int oitCountFragments = min(MAX_OIT_LAYERS, min(oitCountLayers, int(imageLoad(uOITImgAux, oitCoord).r)));

#ifdef MSAA
  const int oitMSAA = clamp(int(uOIT.oitViewPort.w >> 16), 1, MAX_MSAA);
#endif

  if (oitCountFragments > 0) {
    for (int oitFragmentIndex = 0; oitFragmentIndex < oitCountFragments; oitFragmentIndex++) {                             //
      oitFragments[oitFragmentIndex] = imageLoad(uOITImgABuffer, oitABufferBaseIndex + (oitFragmentIndex * oitViewSize));  //
    }

    sort(oitFragments, oitCountFragments);

#ifdef MSAA

#if 1
    vec4 oitMSAAColors[MAX_MSAA];
    for (int oitMSAASampleIndex = 0; oitMSAASampleIndex < oitMSAA; oitMSAASampleIndex++) {  //
      oitMSAAColors[oitMSAASampleIndex] = vec4(0.0);                                        //
    }
    for (int oitFragmentIndex = 0; oitFragmentIndex < oitCountFragments; oitFragmentIndex++) {          //
      if (oitFragments[oitFragmentIndex].w != 0) {                                                      //
        uvec4 fragment = oitFragments[oitFragmentIndex];                                                //
        vec4 fragmentColor = vec4(vec2(unpackHalf2x16(fragment.x)), vec2(unpackHalf2x16(fragment.y)));  //
#if 1
        uint oitMSAASampleMask = fragment.w;                                                            //  
        while(oitMSAASampleMask != 0){                                                                  //
          int oitMSAASampleIndex = findLSB(oitMSAASampleMask);                                          // 
          blend(oitMSAAColors[oitMSAASampleIndex], fragmentColor);                                      //
          oitMSAASampleMask &= (oitMSAASampleMask - 1u);                                                // 
        }                                                                                               //
#else
        for (int oitMSAASampleIndex = 0; oitMSAASampleIndex < oitMSAA; oitMSAASampleIndex++) {          //
          if ((fragment.w & (1u << oitMSAASampleIndex)) != 0) {                                         //
            blend(oitMSAAColors[oitMSAASampleIndex], fragmentColor);                                    //
          }
        }
#endif
      }
    }
    for (int oitMSAASampleIndex = 0; oitMSAASampleIndex < oitMSAA; oitMSAASampleIndex++) {                     //
      color += ApplyToneMapping(oitMSAAColors[oitMSAASampleIndex] * histogramLuminanceBuffer.luminanceFactor); //
    }
    color = ApplyInverseToneMapping(color / oitMSAA) / histogramLuminanceBuffer.luminanceFactor;
#else
    for (int oitMSAASampleIndex = 0; oitMSAASampleIndex < oitMSAA; oitMSAASampleIndex++) {
      vec4 sampleColor = vec4(0.0);
      for (int oitFragmentIndex = 0; oitFragmentIndex < oitCountFragments; oitFragmentIndex++) {          //
        if ((oitFragments[oitFragmentIndex].w & (1u << oitMSAASampleIndex)) != 0) {                       //
          uvec4 fragment = oitFragments[oitFragmentIndex];                                                //
          vec4 fragmentColor = vec4(vec2(unpackHalf2x16(fragment.x)), vec2(unpackHalf2x16(fragment.y)));  //
          blend(sampleColor, fragmentColor);                                                              //
        }
      }
      color += ApplyToneMapping(sampleColor * histogramLuminanceBuffer.luminanceFactor);
    }
    color = ApplyInverseToneMapping(color / oitMSAA) / histogramLuminanceBuffer.luminanceFactor;
#endif
#else
    for (int oitFragmentIndex = 0; oitFragmentIndex < oitCountFragments; oitFragmentIndex++) {        //
      uvec4 fragment = oitFragments[oitFragmentIndex];                                                //
      vec4 fragmentColor = vec4(vec2(unpackHalf2x16(fragment.x)), vec2(unpackHalf2x16(fragment.y)));  //
      blend(color, fragmentColor);                                                                    //
    }
#endif
  }

#endif

#ifdef MSAA
  {
    vec4 sampleColor = vec4(0.0);  
    for (int oitMSAASampleIndex = 0; oitMSAASampleIndex < oitMSAA; oitMSAASampleIndex++) {
      sampleColor += ApplyToneMapping(subpassLoad(uSubpassInputTransparent, oitMSAASampleIndex) * histogramLuminanceBuffer.luminanceFactor);
    }
    blend(color, ApplyInverseToneMapping(sampleColor / float(oitMSAA)) / histogramLuminanceBuffer.luminanceFactor);   
  }
#else
  blend(color, subpassLoad(uSubpassInputTransparent));
#endif

  vec4 waterColor;  
#if defined(MSAA) && !defined(NO_MSAA_WATER)
  {
    vec4 sampleColor = vec4(0.0);  
    for (int oitMSAASampleIndex = 0; oitMSAASampleIndex < oitMSAA; oitMSAASampleIndex++) {
      sampleColor += ApplyToneMapping(subpassLoad(uSubpassInputWater, oitMSAASampleIndex) * histogramLuminanceBuffer.luminanceFactor);
    }
    waterColor = ApplyInverseToneMapping(sampleColor / float(oitMSAA)) / histogramLuminanceBuffer.luminanceFactor;   
  }
#else
  waterColor = subpassLoad(uSubpassInputWater); // Already premultiplied alpha
#endif
  bool hasWaterTransparency = waterColor.w > 1e-4;
  blend(color, waterColor);

  vec4 temporary = subpassLoad(uSubpassInputOpaque);
  temporary.xyz *= temporary.w; // Premultiply alpha for opaque fragments
  blend(color, temporary);

  outColor = vec4(clamp(color.xyz, vec3(-65504.0), vec3(65504.0)), ((oitCountFragments == 0) && !hasWaterTransparency) ? 1.0 : 0.0);
  
}