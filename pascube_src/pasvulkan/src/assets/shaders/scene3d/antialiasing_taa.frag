#version 450 core

#define ColorSpaceRGB 0
#define ColorSpaceYCoCg 1

#define ColorSpace ColorSpaceYCoCg 

#define UseSimple 0

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_control_flow_attributes : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(set = 0, binding = 0) uniform sampler2DArray uCurrentColorTexture;
layout(set = 0, binding = 1) uniform sampler2DArray uCurrentDepthTexture;
layout(set = 0, binding = 2) uniform sampler2DArray uCurrentVelocityTexture;
layout(set = 0, binding = 3) uniform sampler2DArray uHistoryColorTexture;
layout(set = 0, binding = 4) uniform sampler2DArray uHistoryDepthTexture;
layout(set = 0, binding = 5) uniform sampler2DArray uHistoryVelocityTexture;

const uint FLAG_FIRST_FRAME_DISOCCLUSION = 1u << 0u; // First frame disocclusion
const uint FLAG_TRANSLUCENT_DISOCCLUSION = 1u << 1u; // Translucent disocclusion
const uint FLAG_VELOCITY_DISOCCLUSION = 1u << 2u; // Velocity disocclusion
const uint FLAG_DEPTH_DISOCCLUSION = 1u << 3u; // Depth disocclusion
const uint FLAG_INCLUDE_BACKGROUND = 1u << 4u; // Include background in the temporal antialiasing.
const uint FLAG_VARIANCE_CLIPPING = 1u << 5u; // Variance clipping
const uint FLAG_CHROMA_SHRINKING = 1u << 6u; // Chroma shrinking 
const uint FLAG_CLIPPING = 1u << 7u; // Clipping
const uint FLAG_LUMINANCE_WEIGHTING = 1u << 8u; // Luminance weighting
const uint FLAG_USE_FALLBACK_FXAA = 1u << 9u; // Use fallback FXAA for disoccluded or otherwise rejected areas.
const uint FLAG_DISABLE_TEMPORAL_ANTIALIASING = 1u << 10u; // For debugging purposes and for showing the raw jittered input without any temporal antialiasing when FLAG_USE_FALLBACK_FXAA is even not set.

layout(push_constant, std140) uniform PushConstants {
  
  uint baseViewIndex;
  uint countViews;
  uint flags;
  float varianceClipGamma;
  
  float backgroundFeedbackMin;
  float backgroundFeedbackMax;
  float translucentFeedbackMin;
  float translucentFeedbackMax;

  float opaqueFeedbackMin; 
  float opaqueFeedbackMax; 
  float ZMul;
  float ZAdd;

  float disocclusionDebugFactor;
  float velocityDisocclusionThreshold;
  float depthDisocclusionThreshold;
  float sharpingFactor;

  vec2 jitterUV;

} pushConstants;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256]; // 65536 / (64 * 4) = 256
} uView;

mat4 inverseProjectionMatrix = uView.views[pushConstants.baseViewIndex + uint(gl_ViewIndex)].inverseProjectionMatrix;

// Linearize depth
float LinearizeDepth(float depth, vec2 uv){
#if 0
  vec2 v = (inverseProjectionMatrix * vec4(vec3(fma(uv, vec2(2.0), vec2(-1.0)), depth), 1.0)).zw;
#else
  vec2 v = fma(inverseProjectionMatrix[2].zw, vec2(depth), inverseProjectionMatrix[3].zw);
#endif
  return -(v.x / v.y);
}

// Get the luminance of a RGB color
float Luminance(vec4 color){
  return dot(color.xyz, vec3(0.2125, 0.7154, 0.0721));
}

#include "bidirectional_tonemapping.glsl"

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

// Catmull-Rom texture sampling with 9-tap filtering by exploiting the bilinear filtering of the texture hardware.
vec4 textureCatmullRom(const in sampler2DArray tex, const in vec3 uvw, const in float lod){
  vec2 texSize = textureSize(tex, int(lod)).xy,
       uv = uvw.xy,
       samplePos = uv * texSize,
       p11 = floor(samplePos - vec2(0.5)) + vec2(0.5),
       t = samplePos - p11, 
       tt = t * t, 
       ttt = tt * t,
       w0 = (tt - (ttt * 0.5)) - (0.5 * t),
       w1 = ((ttt * 1.5) - (tt * 2.5)) + vec2(1.0),
       w2 = ((tt * 2.0) - (ttt * 1.5)) + (t * 0.5),
       w3 = (ttt * 0.5) - (tt * 0.5),
       w4 = w1 + w2,
       p00 = (p11 - vec2(1.0)) / texSize,
       p33 = (p11 + vec2(2.0)) / texSize,
       p12 = (p11 + (w2 / w4)) / texSize;
  return (((textureLod(tex, vec3(vec2(p00.x, p00.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p00.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x, p00.y), uvw.z), float(lod)) * w3.x)) * w0.y) +
         (((textureLod(tex, vec3(vec2(p00.x, p12.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p12.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x, p12.y), uvw.z), float(lod)) * w3.x)) * w4.y) +
         (((textureLod(tex, vec3(vec2(p00.x, p33.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p33.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x, p33.y), uvw.z), float(lod)) * w3.x)) * w3.y);
}

// Sacht-Nehab3 texture sampling with 9-tap filtering by exploiting the bilinear filtering of the texture hardware.
vec4 textureSachtNehab3(const in sampler2DArray tex, const in vec3 uvw, const in float lod){
 vec2 texSize = textureSize(tex, int(lod)).xy,
       uv = uvw.xy,
       samplePos = uv * texSize,
       p11 = floor(samplePos - vec2(0.5)) + vec2(0.5),
       t = samplePos - p11, 
       tt = t * t, 
       ttt = tt * t,
       w0 = (((0.218848 - (0.497801 * t)) + (0.370818 * tt)) - (0.0899247 * ttt)),
       w1 = (((0.562591 + (0.0446542 * t)) - (0.700012 * tt)) + (0.309387 * ttt)),
       w2 = (((0.216621 + (0.427208 * t)) + (0.228149 * tt)) - (0.309387 * ttt)),
       w3 = (((0.00194006 + (0.0259387 * t)) + (0.101044 * tt)) + (0.0899247 * ttt)),
       w4 = w1 + w2,
       p00 = (p11 - vec2(1.0)) / texSize,
       p33 = (p11 + vec2(2.0)) / texSize,
       p12 = (p11 + (w2 / w4)) / texSize;
  return (((textureLod(tex, vec3(vec2(p00.x, p00.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p00.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x, p00.y), uvw.z), float(lod)) * w3.x)) * w0.y) +
         (((textureLod(tex, vec3(vec2(p00.x, p12.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p12.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x, p12.y), uvw.z), float(lod)) * w3.x)) * w4.y) +
         (((textureLod(tex, vec3(vec2(p00.x, p33.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p33.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x, p33.y), uvw.z), float(lod)) * w3.x)) * w3.y);
}

// Fallback FXAA for disoccluded areas
vec4 FallbackFXAA(const in vec2 invTexSize){
  const vec2 fragCoordInvScale = invTexSize;
  vec4 p = vec4(inTexCoord, vec2(inTexCoord - (fragCoordInvScale * (0.5 + (1.0 / 4.0)))));
  const float FXAA_SPAN_MAX = 8.0,
              FXAA_REDUCE_MUL = 1.0 / 8.0,
              FXAA_REDUCE_MIN = 1.0 / 128.0;
  vec3 rgbNW = ApplyToneMapping(textureLod(uCurrentColorTexture, vec3(p.zw, float(gl_ViewIndex)), 0.0).xyz),
       rgbNE = ApplyToneMapping(textureLodOffset(uCurrentColorTexture, vec3(p.zw, float(gl_ViewIndex)), 0.0, ivec2(1, 0)).xyz),
       rgbSW = ApplyToneMapping(textureLodOffset(uCurrentColorTexture, vec3(p.zw, float(gl_ViewIndex)), 0.0, ivec2(0, 1)).xyz),
       rgbSE = ApplyToneMapping(textureLodOffset(uCurrentColorTexture, vec3(p.zw, float(gl_ViewIndex)), 0.0, ivec2(1, 1)).xyz),
       rgbM = ApplyToneMapping(textureLod(uCurrentColorTexture, vec3(p.xy, float(gl_ViewIndex)), 0.0).xyz),
       luma = vec3(0.2126, 0.7152, 0.0722);
  float lumaNW = dot(rgbNW, luma),
        lumaNE = dot(rgbNE, luma),
        lumaSW = dot(rgbSW, luma),
        lumaSE = dot(rgbSE, luma),
        lumaM = dot(rgbM, luma),
        lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE))), 
        lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
  vec2 dir = vec2(-((lumaNW + lumaNE) - (lumaSW + lumaSE)), ((lumaNW + lumaSW) - (lumaNE + lumaSE)));
  float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN), 
  rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
  dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)) * fragCoordInvScale;
  vec4 rgbA = (1.0 / 2.0) * (ApplyToneMapping(textureLod(uCurrentColorTexture, vec3(p.xy + (dir * ((1.0 / 3.0) - 0.5)), float(gl_ViewIndex)), 0.0).xyzw) + ApplyToneMapping(textureLod(uCurrentColorTexture, vec3(p.xy + (dir * ((2.0 / 3.0) - 0.5)), float(gl_ViewIndex)), 0.0).xyzw)),
       rgbB = (rgbA * (1.0 / 2.0)) + ((1.0 / 4.0) * (ApplyToneMapping(textureLod(uCurrentColorTexture, vec3(p.xy + (dir * ((0.0 / 3.0) - 0.5)), float(gl_ViewIndex)), 0.0).xyzw) + ApplyToneMapping(textureLod(uCurrentColorTexture, vec3(p.xy + (dir * ((3.0 / 3.0) - 0.5)), float(gl_ViewIndex)), 0.0).xyzw)));
  float lumaB = dot(rgbB.xyz, luma);
  return clamp(ApplyInverseToneMapping(((lumaB < lumaMin) || (lumaB > lumaMax)) ? rgbA : rgbB), vec4(0.0), vec4(65504.0));
}

// Check for disocclusions and return true if disoccluded, otherwise false.
bool IsDisoccluded(const in vec3 uvw, const in vec3 historyUVW, const in vec4 current, const in vec2 invTexSize, const in vec2 depthTransform){

  // First frame disocclusion or disable temporal antialiasing
  if((pushConstants.flags & (FLAG_FIRST_FRAME_DISOCCLUSION | FLAG_DISABLE_TEMPORAL_ANTIALIASING)) != 0u){
    return true;
  }

  // Screen disocclusion
  if(any(lessThan(historyUVW.xy, vec2(0.0))) || any(greaterThan(historyUVW.xy, vec2(1.0)))){
    return true;
  }

  // Optional translucency disocclusion, for optionally to force of different handling of translucent surfaces without temporal antialiasing,
  // since these have no valid motion vector data.
  if(((pushConstants.flags & FLAG_TRANSLUCENT_DISOCCLUSION) != 0u) && (current.w < 1e-7)){
    return true;
  }

  // Optional velocity disocclusion for further reducing ghosting artifacts.
  if((pushConstants.flags & FLAG_VELOCITY_DISOCCLUSION) != 0u){
    const vec2 historyVelocity = textureLod(uHistoryVelocityTexture, historyUVW, 0.0).xy;
    if(length(textureLod(uCurrentVelocityTexture, uvw, 0.0).xy - historyVelocity) > pushConstants.velocityDisocclusionThreshold){
      return true;
    }
  } 

  // Optional depth disocclusion for further reducing ghosting artifacts.
  if((pushConstants.flags & FLAG_DEPTH_DISOCCLUSION) != 0u){

    // Get the current and history depth samples as raw values
    float currentDepth = textureLod(uCurrentDepthTexture, uvw, 0.0).x;
    float historyDepth = textureLod(uHistoryDepthTexture, historyUVW, 0.0).x;

    // Check if we're not in the far plane for avoiding other unwanted artifacts than ghosting and so on.
    if(all(greaterThan(vec2(fma(vec2(currentDepth, historyDepth), depthTransform.xx, depthTransform.yy)), vec2(1e-7)))){

      // Linearize the current and history depth samples
      float currentLinearDepth = LinearizeDepth(currentDepth, uvw.xy);
      float historyLinearDepth = LinearizeDepth(historyDepth, historyUVW.xy);

      // Check if the current and history depth samples are candidates for disocclusion
      if(abs(currentLinearDepth - historyLinearDepth) > pushConstants.depthDisocclusionThreshold){
        return true;
      }

    }

  }

  // Otherwise we're not disoccluded
  return false;

}

void main() {
    
  vec2 texSize = vec2(textureSize(uCurrentColorTexture, 0).xy);
  vec2 invTexSize = vec2(1.0) / texSize;
  
  vec4 color = vec4(0.0);
  
  vec3 uvw = vec3(inTexCoord, float(gl_ViewIndex));

#if 0
  vec4 current = textureLod(uCurrentColorTexture, uvw - vec3(pushConstants.jitterUV, 0.0), 0.0); // With unjittering
#else
  vec4 current = textureLod(uCurrentColorTexture, uvw, 0.0); // Without unjittering
#endif

  vec2 depthTransform = vec2(pushConstants.ZMul, pushConstants.ZAdd);

  // Find the closest depth sample and its attached information 
  vec4 velocityUVWZ;
  {
    vec3 depthSamples[9] = vec3[9](
      vec3(-1.0, -1.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2(-1.0, -1.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y)),
      vec3( 0.0, -1.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2( 0.0, -1.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y)),
      vec3( 1.0, -1.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2( 1.0, -1.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y)),
      vec3(-1.0,  0.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2(-1.0,  0.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y)),
      vec3( 0.0,  0.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2( 0.0,  0.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y)),
      vec3( 1.0,  0.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2( 1.0,  0.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y)),
      vec3(-1.0,  1.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2(-1.0,  1.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y)),
      vec3( 0.0,  1.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2( 0.0,  1.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y)),
      vec3( 1.0,  1.0, fma(textureLod(uCurrentDepthTexture, uvw + vec3(vec2(vec2( 1.0,  1.0) * invTexSize), 0), 0.0).x, depthTransform.x, depthTransform.y))
    );
    vec3 bestDepth = depthSamples[0];
    if(bestDepth.z < depthSamples[1].z){ bestDepth = depthSamples[1]; }
    if(bestDepth.z < depthSamples[2].z){ bestDepth = depthSamples[2]; }
    if(bestDepth.z < depthSamples[3].z){ bestDepth = depthSamples[3]; }
    if(bestDepth.z < depthSamples[4].z){ bestDepth = depthSamples[4]; }
    if(bestDepth.z < depthSamples[5].z){ bestDepth = depthSamples[5]; }
    if(bestDepth.z < depthSamples[6].z){ bestDepth = depthSamples[6]; }
    if(bestDepth.z < depthSamples[7].z){ bestDepth = depthSamples[7]; }
    if(bestDepth.z < depthSamples[8].z){ bestDepth = depthSamples[8]; }
    velocityUVWZ = vec4(fma(bestDepth.xy, invTexSize, uvw.xy), uvw.z, bestDepth.z);
  }

  // Check for far plane, but avoid translucent surfaces which does writes also no depth data like the background
  bool isBackground = ((velocityUVWZ.w < 1e-7) && (current.w > 0.5));

  // Check if we're in the far plane and the background should be included in the temporal antialiasing or not
  if(((pushConstants.flags & FLAG_INCLUDE_BACKGROUND) == 0u) && isBackground){ 
    
    // We're in the far plane, so no temporal antialiasing or similar, so that background und similiar things are always sharp.

    color = current;

  }else{

    // Otherwise do our job.
   
    // Get the current velocity 
    vec2 currentVelocity = textureLod(uCurrentVelocityTexture, velocityUVWZ.xyz, 0.0).xy;  

    // Offset the history UVW by the current velocity
    vec3 historyUVW = uvw - vec3(currentVelocity, 0.0);

    // Get the current color samples    
    vec4 currentSamples[9] = vec4[9](    
      ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2(-1, -1)))), // a 0
      ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2( 0, -1)))), // b 1
      ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2( 1, -1)))), // c 2
      ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2(-1,  0)))), // d 3
      current = ConvertFromRGB(Tonemap(current)), // ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2( 0,  0)))), // e 4
      ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2( 1,  0)))), // f 5
      ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2(-1,  1)))), // g 6
      ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2( 0,  1)))), // h 7
      ConvertFromRGB(Tonemap(textureLodOffset(uCurrentColorTexture, uvw, 0, ivec2( 1,  1))))  // i 8
    );

    // Convert the current color to YCoCg color space and apply tonemapping
    // current = ConvertFromRGB(Tonemap(current));

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
    
    if((pushConstants.flags & FLAG_VARIANCE_CLIPPING) != 0u){
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
      vec4 sigma = sqrt(m1 - (m0 * m0)) * pushConstants.varianceClipGamma;
      minimumColor = max(minimumColor, m0 - sigma);
      maximumColor = min(maximumColor, m0 + sigma);
    }            

#if ColorSpace == ColorSpaceYCoCg 
    // Shrink chroma extents for luminance-chroma-based color spaces like YCoCg, YCbCr, YUV, etc.
    if((pushConstants.flags & FLAG_CHROMA_SHRINKING) != 0u){  
       // TODO: Fix this for very bright colors (=> butterfly artifacts later at bloom) 
      vec2 chromaExtent = vec2(maximumColor.x - minimumColor.x) * 0.125;
      vec2 chromaCenter = current.yz;
      minimumColor.yz = chromaCenter - chromaExtent;
      maximumColor.yz = chromaCenter + chromaExtent;
      averageColor.yz = chromaCenter;
    }  
#endif      
    
    float blendWeight;

    vec4 historySample;

    // Check for disocclusion / rejection
    if(IsDisoccluded(uvw, historyUVW, current, invTexSize, depthTransform.xy)){

      // Disoccluded / rejected

      // Mark as rejected because of disocclusion (weight = 0.0)
      blendWeight = 0.0; 

      // No valid history sample in this case
      historySample = vec4(0.0); 

    }else{  

      // Not disoccluded / rejected

      // Initial weight for blending (weight = 1.0), which will be modified later if needed
      blendWeight = 1.0; 

      // Get the history color sample, convert it to YCoCg color space and apply tonemapping   
      historySample = ConvertFromRGB(Tonemap(textureCatmullRom(uHistoryColorTexture, historyUVW, 0.0)));
            
      // Clip the history color sample to the current minimum and maximum color values
      if((pushConstants.flags & FLAG_CLIPPING) != 0u){
        historySample = ClipAABB(historySample, clamp(averageColor, minimumColor, maximumColor), minimumColor.xyz, maximumColor.xyz);
      } 

      // Luminance weighting with different feedback coefficients for opaque and translucent surfaces
      if((pushConstants.flags & FLAG_LUMINANCE_WEIGHTING) != 0u){
  #if ColorSpace == ColorSpaceYCoCg
        float currentLuminance = current.x;
        float historyLuminance = historySample.x;    
  #else
        float currentLuminance = Luminance(current);
        float historyLuminance = Luminance(historySample);
  #endif      
        float unbiasedWeight = 1.0 - (abs(currentLuminance - historyLuminance) / max(currentLuminance, max(historyLuminance, 0.2)));
        float unbiasedWeightSquaredClamped = clamp(unbiasedWeight * unbiasedWeight, 0.0, 1.0);
        float luminanceDisocclusionBasedBlendFactor = isBackground
          ? mix(pushConstants.backgroundFeedbackMin, pushConstants.backgroundFeedbackMax, unbiasedWeightSquaredClamped) // Background
          : mix(
              mix(pushConstants.translucentFeedbackMin, pushConstants.translucentFeedbackMax, unbiasedWeightSquaredClamped), // Translucent
              mix(pushConstants.opaqueFeedbackMin, pushConstants.opaqueFeedbackMin, unbiasedWeightSquaredClamped), // Opaque
              clamp(current.w, 0.0, 1.0) // In the alpha channel of the current color sample the translucency/opacity factor is stored, 0.0 = full translucent, 1.0 = full opaque
            );

        blendWeight *= luminanceDisocclusionBasedBlendFactor;     

      }  

    }

    // Optionally apply sharping when enabled
    if(pushConstants.sharpingFactor > 1e-7){
      current += (vec4(1.0) - exp(-(current - clamp(averageColor, minimumColor, maximumColor)))) * pushConstants.sharpingFactor; 
    }

    // Check for valid history sample for blending (valid = not rejected, for example by disocclusion) 
    if(blendWeight > 1e-7){

      // When valid, blend the current and history color samples based on the blend weight
      color = clamp(Untonemap(ConvertToRGB(mix(current, historySample, blendWeight))), vec4(0.0), vec4(65504.0));   

    }else{      
      
      // When not valid, use the current color sample or use fallback FXAA when enabled.
      
      if((pushConstants.flags & FLAG_USE_FALLBACK_FXAA) != 0u){
        // Use fallback FXAA for to have still a more or less initial antialiased result in rejected areas
        // But attentation, FXAA don't use the sharpened color calculated above, so it isn't post-sharped then. 
        color = FallbackFXAA(invTexSize);
      }else{
        // Use the current color sample without blending directly 
        color = clamp(Untonemap(ConvertToRGB(current)), vec4(0.0), vec4(65504.0));   
      }

      color = mix(color, vec4(1.0, 0.0, 0.0, 1.0), pushConstants.disocclusionDebugFactor);
      
    }

  }
 
  outFragColor = color;

}