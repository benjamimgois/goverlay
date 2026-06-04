#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(set = 0, binding = 0) uniform sampler2DArray uTextureCurrent;
layout(set = 0, binding = 1) uniform sampler2DArray uTextureVelocity;
layout(set = 0, binding = 2) uniform sampler2DArray uTexturePrevious;

// SMAA T2x reprojection, but with additional TAA-style rejecting and disocclusion handling for better anti-ghosting and temporal stability, at least in theory.   

#define ColorSpaceRGB 0
#define ColorSpaceYCoCg 1
#define ColorSpace ColorSpaceYCoCg 

#include "bidirectional_tonemapping.glsl"

#include "antialiasing_smaa.glsl"

// Tone mapping
vec4 Tonemap(vec4 color){
  return ApplyToneMapping(color);
  //return vec4(color.xyz / (Luminance(color) + 1.0), color.w);
}

// Inverse tone mapping
vec4 Untonemap(vec4 color){
  return ApplyInverseToneMapping(color); 
  //return vec4(color.xyz / max(1.0 - Luminance(color), 1e-4), color.w);
}

#if ColorSpace == ColorSpaceYCoCg

// RGB to YCoCg conversion
vec4 RGBToYCoCg(in vec4 c){
//return vec4(vec3(c.yy + ((c.x + c.z) * vec2(0.5, -0.5)), c.x - c.z).xzy * 0.5, 1.0);
  return vec4(mat3(0.25, 0.5, -0.25, 0.5, 0, 0.5, 0.25, -0.5, -0.25) * c.xyz, c.w);
}

// YCoCg to RGB conversion
vec4 YCoCgToRGB(in vec4 c){
//return vec4((c.xxx + vec3(c.yz, -c.y)) - vec2(c.z, 0.0).xyx, c.w);
  return vec4(mat3(1.0, 1.0, 1.0, 1.0, 0.0, -1.0, -1.0, 1.0, -1.0) * c.xyz, c.w);
}

#define ConvertFromRGB RGBToYCoCg
#define ConvertToRGB YCoCgToRGB

#else

#define ConvertFromRGB
#define ConvertToRGB

#endif

float Luminance(vec4 color){
  return dot(color.xyz, vec3(0.2125, 0.7154, 0.0721));
}

// Clip a point to an axis-aligned bounding box
vec4 ClipAABB(vec4 q, vec4 p, vec3 aabbMin, vec3 aabbMax){	
#if 0  
  vec3 p_clip = (aabbMin + aabbMax) * 0.5;
	vec3 e_clip = fma(aabbMax - aabbMin, vec3(0.5), vec3(1e-7));
	vec4 v_clip = q - vec4(p_clip, p.w);
	vec3 a_unit = abs(v_clip.xyz / e_clip);
	float maxUnit = max(a_unit.x, max(a_unit.y, a_unit.z));
	return (maxUnit > 1.0) ? vec4(vec4(p_clip, p.w) + (v_clip / maxUnit)) : q;
#else
  const float FLT_MIN = uintBitsToFloat(0x00800000u); // 1.17549435e-38
//const float FLT_MAX = uintBitsToFloat(0x7f7fffffu); // 3.40282347e+38
  vec4 r = q - p;
  vec3 rmax = aabbMax - p.xyz, rmin = aabbMin - p.xyz;
  if(r.x > (rmax.x + FLT_MIN)){
    r *= rmax.x / r.x;
  }
  if(r.y > (rmax.y + FLT_MIN)){
    r *= rmax.y / r.y;
  }
  if(r.z > (rmax.z + FLT_MIN)){
    r *= rmax.z / r.z;
  }
  if(r.x < (rmin.x - FLT_MIN)){
    r *= rmin.x / r.x;
  }
  if(r.y < (rmin.y - FLT_MIN)){
    r *= rmin.y / r.y;
  }
  if(r.z < (rmin.z - FLT_MIN)){
    r *= rmin.z / r.z;
  }
  return p + r;
#endif
}

void main(){
  
  vec3 uvw = vec3(inTexCoord, float(gl_ViewIndex));

  vec4 current = ConvertFromRGB(Tonemap(textureLod(uTextureCurrent, uvw, 0.0)));
  
  vec2 velocity = textureLod(uTextureVelocity, uvw, 0.0).xy;
  
  vec4 previous = ConvertFromRGB(Tonemap(textureLod(uTexturePrevious, vec3(inTexCoord - velocity, float(gl_ViewIndex)), 0.0)));

  float delta = ((current.a * current.a) - (previous.a * previous.a)) * (1.0 / 5.0);
  float weight = 1.0 - (clamp(1.0 - (sqrt(delta) * SMAA_REPROJECTION_WEIGHT_SCALE), 0.0, 1.0) * 0.5);

  // Get the current color samples    
  vec4 currentSamples[9] = vec4[9](    
    ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2(-1, -1)))), // a 0
    ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2( 0, -1)))), // b 1
    ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2( 1, -1)))), // c 2
    ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2(-1,  0)))), // d 3
    current, // ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2( 0,  0)))), // e 4
    ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2( 1,  0)))), // f 5
    ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2(-1,  1)))), // g 6
    ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2( 0,  1)))), // h 7
    ConvertFromRGB(Tonemap(textureLodOffset(uTextureCurrent, uvw, 0, ivec2( 1,  1))))  // i 8
  );

#if 1
  // Soft minimum and maximum ("Hybrid Reconstruction Antialiasing")
  //        1         0 1 2
  // (min 3 4 5 + min 3 4 5) * 0.5
  //        7         6 7 8        
  vec4 minimumColor = min(min(min(min(currentSamples[1], currentSamples[3]), currentSamples[4]), currentSamples[5]), currentSamples[7]),
       maximumColor = max(max(max(max(currentSamples[1], currentSamples[3]), currentSamples[4]), currentSamples[5]), currentSamples[7]);
  minimumColor = (minimumColor + min(min(min(min(minimumColor, currentSamples[0]), currentSamples[2]), currentSamples[6]), currentSamples[8])) * 0.5;
  maximumColor = (maximumColor + max(max(max(max(maximumColor, currentSamples[0]), currentSamples[2]), currentSamples[6]), currentSamples[8])) * 0.5;
#else
  // Simple minimum and maximum
  vec4 minimumColor = min(min(min(min(min(min(min(min(currentSamples[0], currentSamples[1]), currentSamples[2]), currentSamples[3]), currentSamples[4]), currentSamples[5]), currentSamples[6]), currentSamples[7]), currentSamples[8]),
       maximumColor = max(max(max(max(max(max(max(max(currentSamples[0], currentSamples[1]), currentSamples[2]), currentSamples[3]), currentSamples[4]), currentSamples[5]), currentSamples[6]), currentSamples[7]), currentSamples[8]);
#endif

  // Average color
  vec4 averageColor = (currentSamples[0] + currentSamples[1] + currentSamples[2] + currentSamples[3] + currentSamples[4] + currentSamples[5] + currentSamples[6] + currentSamples[7] + currentSamples[8]) * (1.0 / 9.0);
  
  {
    // Variance clipping ("An Excursion in Temporal Supersampling")
    vec4 m0 = currentSamples[0],
          m1 = currentSamples[0] * currentSamples[0];   
    for(int i = 1; i < 9; i++) {
      vec4 currentSample = currentSamples[i]; 
      m0 += currentSample;
      m1 += currentSample * currentSample;
    }
    m0 *= 1.0 / 9.0;
    m1 *= 1.0 / 9.0;
    vec4 sigma = sqrt(m1 - (m0 * m0)) * 1.0;//pushConstants.varianceClipGamma;
    minimumColor = max(minimumColor, m0 - sigma);
    maximumColor = min(maximumColor, m0 + sigma);
  }            

#if ColorSpace == ColorSpaceYCoCg 
  // Shrink chroma extents for luminance-chroma-based color spaces like YCoCg, YCbCr, YUV, etc.
  vec2 chromaExtent = vec2(maximumColor.x - minimumColor.x) * 0.125;
  vec2 chromaCenter = current.yz;
  minimumColor.yz = chromaCenter - chromaExtent;
  maximumColor.yz = chromaCenter + chromaExtent;
  averageColor.yz = chromaCenter;
#endif      

  previous = ClipAABB(previous, clamp(averageColor, minimumColor, maximumColor), minimumColor.xyz, maximumColor.xyz);

// Luminance disocclusion with different feedback coefficients for opaque and translucent surfaces
#if ColorSpace == ColorSpaceYCoCg
  float currentLuminance = current.x;
  float historyLuminance = previous.x;    
#else
  float currentLuminance = Luminance(current);
  float historyLuminance = Luminance(previous);
#endif      
  float unbiasedWeight = 1.0 - (abs(currentLuminance - historyLuminance) / max(currentLuminance, max(historyLuminance, 0.2)));
  float unbiasedWeightSquaredClamped = clamp(unbiasedWeight * unbiasedWeight, 0.0, 1.0);
  float luminanceDisocclusionBasedBlendFactor = mix(0.88, 0.97, unbiasedWeightSquaredClamped);

  weight *= luminanceDisocclusionBasedBlendFactor;     

  outFragColor = Untonemap(ConvertToRGB(mix(previous, current, weight)));

}
