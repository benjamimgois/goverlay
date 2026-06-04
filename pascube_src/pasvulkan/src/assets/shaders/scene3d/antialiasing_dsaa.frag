#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(set = 0, binding = 0) uniform sampler2DArray uTexture;

#include "antialiasing_srgb.glsl"

// This rather simple DSAA method calculates the gradient of luminance values and uses it to determine the direction 
// and magnitude of anti-aliasing adjustments. It samples neighboring texels and averages the results to smooth out 
// edges.

void main() {
#if 1
  
  // Linear color space  

  // Inverse Scale Calculation: 
  //   Calculates the inverse scale of the fragment coordinates based on the texture size.
  //   The w vector is a scaled version of this inverse scale, used for offsetting texture coordinates.
  vec2 fragCoordInvScale = vec2(1.0) / vec2(textureSize(uTexture, 0).xy),  //
       w = fragCoordInvScale * 1.75;

  // Lumiinance Weights and Direction Vectors:
  //   The f vector contains luminance weights for converting RGB to grayscale. 
  //   The d vector defines direction offsets for sampling neighboring texels.
  vec4 f = vec4(0.2126, 0.7152, 0.0722, 0.0),
       d = vec3(-1.0, 0.0, 1.0).xyzy;

  // Temporary Tone Mapping and Texture Sampling:
  //   Samples the texture at four neighboring coordinates, applies tone mapping, and converts the results to grayscale 
  //   using the luminance weights.
  vec4 t = vec4(dot(ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord + (d.yx * w), float(gl_ViewIndex)), 0.0)), f),  //
                dot(ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord + (d.xy * w), float(gl_ViewIndex)), 0.0)), f),  //
                dot(ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord + (d.zy * w), float(gl_ViewIndex)), 0.0)), f),  //
                dot(ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord + (d.yz * w), float(gl_ViewIndex)), 0.0)), f));

  // Gradient Calculation:
  //   Calculates the gradient of the luminance values. The n vector represents the gradient of the luminance values,
  //   and nl is its length. This gradient is used to determine the direction and magnitude of the anti-aliasing correction.             
  vec2 n = vec2(-(t.x - t.w), t.z - t.y);
  float nl = length(n);

  // Conditional Anti-Aliasing Adjustment:
  //  If the gradient is above a certain threshold, the texture is sampled at additional neighboring coordinates,
  //  and the results are combined to produce the final color output. If the gradient length nl exceeds a threshold (0.0625),
  //  it adjusts the n vector and averages multiple texture samples around the current fragment coordinate to smooth out 
  //  the aliasing.
  vec4 outColor = ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0));
  if (nl >= 0.0625) {
    n *= fragCoordInvScale / nl;                                                                       //
    outColor = (outColor +                                                                             //
                ((ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord + (n * 0.5), float(gl_ViewIndex)), 0.0)) * 0.9) +  //
                 (ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord - (n * 0.5), float(gl_ViewIndex)), 0.0)) * 0.9) +  //
                 (ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord + n, float(gl_ViewIndex)), 0.0)) * 0.75) +         //
                 (ApplyToneMapping(textureLod(uTexture, vec3(inTexCoord - n, float(gl_ViewIndex)), 0.0)) * 0.75))          //
                ) /
               4.3;  //
  }
  
  // Final Color Output with inverse Tone Mapping:
  //   The final color, after anti-aliasing adjustments, is passed through an inverse tone mapping function and assigned to 
  //   outFragColor.
  outFragColor = ApplyInverseToneMapping(outColor);

#else
  // Gamma corrected color space
  vec2 fragCoordInvScale = vec2(1.0) / vec2(textureSize(uTexture, 0).xy),  //
       w = fragCoordInvScale * 1.75;
  vec4 f = vec4(0.299, 0.587, 0.114, 0.0),                                                           // vec4(0.2126, 0.7152, 0.0722, 0.0),
      d = vec3(-1.0, 0.0, 1.0).xyzy,                                                                 //
      t = vec4(dot(SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord + (d.yx * w), float(gl_ViewIndex)), 0.0), f),  //
               dot(SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord + (d.xy * w), float(gl_ViewIndex)), 0.0), f),  //
               dot(SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord + (d.zy * w), float(gl_ViewIndex)), 0.0), f),  //
               dot(SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord + (d.yz * w), float(gl_ViewIndex)), 0.0), f));
  vec2 n = vec2(-(t.x - t.w), t.z - t.y);
  float nl = length(n);
  vec4 outColor = SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0);
  if (nl >= 0.0625) {
    n *= fragCoordInvScale / nl;                                                                       //
    outColor = (outColor +                                                                             //
                ((SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord + (n * 0.5), float(gl_ViewIndex)), 0.0) * 0.9) +  //
                 (SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord - (n * 0.5), float(gl_ViewIndex)), 0.0) * 0.9) +  //
                 (SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord + n, float(gl_ViewIndex)), 0.0) * 0.75) +         //
                 (SRGBGammaCorrectedTexture(uTexture, vec3(inTexCoord - n, float(gl_ViewIndex)), 0.0) * 0.75))          //
                ) /
               4.3;  //
  }
  outFragColor = SRGBout(outColor);
//outFragColor = vec4(mix(pow((outColor.xyz + vec3(5.5e-2)) / vec3(1.055), vec3(2.4)), outColor.xyz / vec3(12.92), lessThan(outColor.xyz, vec3(4.045e-2))), outColor.w);
#endif
}
