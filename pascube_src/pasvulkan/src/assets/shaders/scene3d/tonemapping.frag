#version 450 core

//#define SHADERDEBUG

#extension GL_EXT_multiview : enable
#extension GL_GOOGLE_include_directive : enable

#if defined(SHADERDEBUG)
#extension GL_EXT_debug_printf : enable
#endif

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outColor;

layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInput uSubpassInput;

layout(push_constant) uniform PushConstants {
  int mode;
} pushConstants;

#include "rec2020.glsl"
#include "colorgrading.glsl"

layout(set = 0, binding = 1) uniform ColorGradingSettingsBuffer {
  ColorGradingSettings colorGradingSettings;
} colorGradingSettingsBuffer;

#define MODE_NONE 0 // No tonemapping (just color grading, if enabled, and HDR negative value to zero clamping)
#define MODE_LINEAR 1
#define MODE_REINHARD 2
#define MODE_HEJL 3
#define MODE_HEJL2015 4
#define MODE_ACESFILM 5
#define MODE_ACESFILM2 6
#define MODE_UNCHARTED2 7
#define MODE_UCHIMURA 8
#define MODE_LOTTES 9
#define MODE_AMD 10
#define MODE_AGX_REC709 11
#define MODE_AGX_REC709_GOLDEN 12
#define MODE_AGX_REC709_PUNCHY 13
#define MODE_AGX_REC2020 14
#define MODE_AGX_REC2020_GOLDEN 15
#define MODE_AGX_REC2020_PUNCHY 16
#define MODE_KHRONOS_PBR_NEUTRAL 17

vec3 linear(const in vec3 color) { 
  return color; 
}

vec3 reinhard(in vec3 color) {
  color *= 1.5;
  return color / (vec3(1.0) + color);
}

vec3 hejl(const in vec3 color) {
  vec3 x = max(vec3(0.0), color - vec3(0.004));
  return pow((x * ((6.2 * x) + vec3(0.5))) / max(x * ((6.2 * x) + vec3(1.7)) + vec3(0.06), vec3(1e-8)), vec3(2.2));
}

vec3 hejl2015(vec3 c, float w) {
  vec4 h = vec4(c, w), a = (1.425 * h) + vec4(0.05), f = (((h * a) + vec4(0.004)) / ((h * (a + vec4(0.55)) + vec4(0.0491)))) - vec4(0.0821);
  return f.xyz / f.w;
}

vec3 ACESFilm(const in vec3 x) {
  const float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
  return clamp((x * ((a * x) + vec3(b))) / (x * ((c * x) + vec3(d)) + vec3(e)), vec3(0.0), vec3(1.0));
}

vec3 ACESFilm2(const in vec3 x) {
  const float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
  return pow(clamp((x * ((a * x) + vec3(b))) / (x * ((c * x) + vec3(d)) + vec3(e)), vec3(0.0), vec3(1.0)), vec3(2.2));
}

vec3 uncharted2(in vec3 color) {
  float A = 0.15;
  float B = 0.50;
  float C = 0.10;
  float D = 0.20;
  float E = 0.02;
  float F = 0.30;
  float W = 11.2;
  float IW = 1.0 / (((W * ((A * W) + (C * B)) + (D * E)) / (W * ((A * W) + B) + (D * F))) - (E / F));
  color *= 5.0;
  return (((color * ((A * color) + vec3(C * B)) + vec3(D * E)) / (color * ((A * color) + vec3(B)) + vec3(D * F))) - vec3(E / F)) * IW;
}

vec3 uchimura(in vec3 x, in float P, in float a, in float m, in float l, in float c, in float b) {
  float l0 = ((P - m) * l) / a;
  float L0 = m - m / a;
  float L1 = m + (1.0 - m) / a;
  float S0 = m + l0;
  float S1 = m + a * l0;
  float C2 = (a * P) / (P - S1);
  float CP = -C2 / P;

  vec3 w0 = vec3(1.0 - smoothstep(0.0, m, x));
  vec3 w2 = vec3(step(m + l0, x));
  vec3 w1 = vec3(1.0 - w0 - w2);

  vec3 T = vec3(m * pow(x / m, vec3(c)) + b);
  vec3 S = vec3(P - (P - S1) * exp(CP * (x - S0)));
  vec3 L = vec3(m + a * (x - m));

  return T * w0 + L * w1 + S * w2;
}

vec3 uchimura(in vec3 x) {
  const float P = 1.0;   // max display brightness
  const float a = 1.0;   // contrast
  const float m = 0.22;  // linear section start
  const float l = 0.4;   // linear section length
  const float c = 1.33;  // black

  return uchimura(x, P, a, m, l, c, 0.0);
}

vec3 lottes(in vec3 x) {
  const vec3 a = vec3(1.6);
  const vec3 d = vec3(0.977);
  const vec3 hdrMax = vec3(8.0);
  const vec3 midIn = vec3(0.18);
  const vec3 midOut = vec3(0.267);

  const vec3 b = (-pow(midIn, a) + pow(hdrMax, a) * midOut) / ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
  const vec3 c = (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) / ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);

  return pow(x, a) / (pow(x, a * d) * b + c);
}

// Source: https://github.com/GPUOpen-LibrariesAndSDKs/Cauldron/blob/master/src/VK/shaders/tonemappers.glsl

float ColToneB(float hdrMax, float contrast, float shoulder, float midIn, float midOut) {  //
  return -((-pow(midIn, contrast) + (midOut * (pow(hdrMax, contrast * shoulder) * pow(midIn, contrast) - pow(hdrMax, contrast) * pow(midIn, contrast * shoulder) * midOut)) / (pow(hdrMax, contrast * shoulder) * midOut - pow(midIn, contrast * shoulder) * midOut)) / (pow(midIn, contrast * shoulder) * midOut));
}

// General tonemapping operator, build 'c' term.
float ColToneC(float hdrMax, float contrast, float shoulder, float midIn, float midOut) {  //
  return (pow(hdrMax, contrast * shoulder) * pow(midIn, contrast) - pow(hdrMax, contrast) * pow(midIn, contrast * shoulder) * midOut) / (pow(hdrMax, contrast * shoulder) * midOut - pow(midIn, contrast * shoulder) * midOut);
}

// General tonemapping operator, p := {contrast,shoulder,b,c}.
float ColTone(float x, vec4 p) {
  float z = pow(x, p.r);
  return z / (pow(z, p.g) * p.b + p.a);
}

vec3 AMDTonemapper(vec3 color) {
  const float hdrMax = 16.0;   // How much HDR range before clipping. HDR modes likely need this pushed up to say 25.0.
  const float contrast = 2.0;  // Use as a baseline to tune the amount of contrast the tonemapper has.
  const float shoulder = 1.0;  // Likely donÆt need to mess with this factor, unless matching existing tonemapper is not working well..
  const float midIn = 0.18;    // most games will have a {0.0 to 1.0} range for LDR so midIn should be 0.18.
  const float midOut = 0.18;   // Use for LDR. For HDR10 10:10:10:2 use maybe 0.18/25.0 to start. For scRGB, I forget what a good starting point is, need to re-calculate.

  float b = ColToneB(hdrMax, contrast, shoulder, midIn, midOut);
  float c = ColToneC(hdrMax, contrast, shoulder, midIn, midOut);

#define EPS 1e-6f
  float peak = max(color.r, max(color.g, color.b));
  peak = max(EPS, peak);

  vec3 ratio = color / peak;
  peak = ColTone(peak, vec4(contrast, shoulder, b, c));
  // then process ratio

  // probably want send these pre-computed (so send over saturation/crossSaturation as a constant)
  float crosstalk = 4.0;                    // controls amount of channel crosstalk
  float saturation = contrast;              // full tonal range saturation control
  float crossSaturation = contrast * 16.0;  // crosstalk saturation

  float white = 1.0;

  // wrap crosstalk in transform
  ratio = pow(abs(ratio), vec3(saturation / crossSaturation));
  ratio = mix(ratio, vec3(white), vec3(pow(peak, crosstalk)));
  ratio = pow(abs(ratio), vec3(crossSaturation));

  // then apply ratio to peak
  color = peak * ratio;
  return color;
}

//////////////////////////////////////////////////////////////////////////
// AgX Rec.2020 + Rec. 709 EOTF and OETF                                //
//////////////////////////////////////////////////////////////////////////

vec3 AgXDefaultContrastApproximation(vec3 x) {
  // Sigmoid curve approximation
#if 1
  // 7th Order Polynomial Approximation. Squared mean error: 1.85907662e-06
  vec3 x2 = x * x, x4 = x2 * x2, x6 = x4 * x2;
  return (-17.86 * x6 * x) + (78.01 * x6) + (-126.7 * x4 * x) + (92.06 * x4) + (-28.72 * x2 * x) + (4.361 * x2) + (-0.1718 * x) + vec3(0.002857);
#else
  // 6th Order Polynomial Approximation. Squared mean error: 3.6705141e-06
  vec3 x2 = x * x, x4 = x2 * x2;
  return (15.5 * x4 * x2) + (-40.14 * x4 * x) + (31.96 * x4) - (6.868 * x2 * x) + (0.4298 * x2) + (0.1191 * x) - vec3(0.00232);
#endif
}

// These matrices taken from Wrensch's minimal implementation of AgX, which works with Rec.709 / sRGB primaries.
// https://iolite-engine.com/blog_posts/minimal_agx_implementation
const mat3 AgXRec709InsetMatrix = mat3(
  0.842479062253094, 0.0423282422610123, 0.0423756549057051,
  0.0784335999999992, 0.878468636469772, 0.0784336,
  0.0792237451477643, 0.0791661274605434, 0.879142973793104
);

const mat3 AgXRec709OutsetMatrix = mat3(
  1.19687900512017, -0.0528968517574562, -0.0529716355144438,
  -0.0980208811401368, 1.15190312990417, -0.0980434501171241,
  -0.0990297440797205, -0.0989611768448433, 1.15107367264116
);

// These matrices taken from Blender's implementation of AgX, which works with Rec.2020 primaries.
// https://github.com/EaryChow/AgX_LUT_Gen/blob/main/AgXBaseRec2020.py
const mat3 AgXRec2020InsetMatrix = mat3(
  vec3(0.856627153315983, 0.137318972929847, 0.11189821299995),
  vec3(0.0951212405381588, 0.761241990602591, 0.0767994186031903),
  vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859)
);

const mat3 AgXRec2020OutsetMatrix = mat3(
  vec3(1.1271005818144368, -0.1413297634984383, -0.14132976349843826),
  vec3(-0.11060664309660323, 1.157823702216272, -0.11060664309660294),
  vec3(-0.016493938717834573, -0.016493938717834257, 1.2519364065950405)
);

// AgXRec2020InsetMatrixFromLinearSRGB = AgXRec2020InsetMatrix * LinearSRGBToLinearRec2020Matrix
const mat3 AgXRec2020InsetMatrixFromLinearSRGB = mat3(
  0.54490465, 0.1404396, 0.088826895,
  0.37377995, 0.7541106, 0.17887735,
  0.0813857, 0.10543349, 0.7322502
);

vec3 AgXCore(vec3 color) {
  // LOG2_MIN = -10.0, LOG2_MAX = +6.5, MIDDLE_GRAY = 0.18
  const float AgXMinEV = -12.473931188332413; // log2(pow(2, LOG2_MIN) * MIDDLE_GRAY)
  const float AgXMaxEV = 4.026068811667588;   // log2(pow(2, LOG2_MAX) * MIDDLE_GRAY)
  return AgXDefaultContrastApproximation(clamp((log2(max(vec3(1e-10), color)) - vec3(AgXMinEV)) / vec3(AgXMaxEV - AgXMinEV), 0.0, 1.0));
}

vec3 AgXRec709(vec3 color) {
  return AgXCore(AgXRec709InsetMatrix * max(vec3(0.0), color));
}

vec3 AgXRec709EOTF(vec3 color) {
  return max(vec3(0.0), pow(max(vec3(0.0), AgXRec709OutsetMatrix * color), vec3(2.2)));
}

vec3 AgXRec2020(vec3 color) {
  return AgXCore(AgXRec2020InsetMatrixFromLinearSRGB * max(vec3(0.0), color));
}

vec3 AgXRec2020EOTF(vec3 color) {
  return max(vec3(0.0), LinearRec2020ToLinearSRGBMatrix * pow(max(vec3(0.0), AgXRec2020OutsetMatrix * color), vec3(2.2)));
}

vec3 agxGolden(vec3 color) {
  const vec3 lw = vec3(0.2126, 0.7152, 0.0722);
  float luma = dot(color, lw);
  vec3 offset = vec3(0.0), slope = vec3(1.0, 0.9, 0.5), power = vec3(0.8);
  float sat = 0.8;
  return fma(pow(fma(color, slope, offset), power) - vec3(luma), vec3(sat), vec3(luma));
}

vec3 agxPunchy(vec3 color) {
  const vec3 lw = vec3(0.2126, 0.7152, 0.0722);
  float luma = dot(color, lw);
  vec3 offset = vec3(0.0), slope = vec3(1.0), power = vec3(1.35);
  float sat = 1.4;
  return fma(pow(fma(color, slope, offset), power) - vec3(luma), vec3(sat), vec3(luma));
}

vec3 khronosPBRNeutral(vec3 color){

  const float startCompression = 0.8 - 0.04;
  const float desaturation = 0.15;

  color = max(vec3(0.0), color); // Non-negative values only
  
  float x = min(color.r, min(color.g, color.b));
  float offset = (x < 0.08) ? (x - (6.25 * (x * x))) : 0.04;
  color -= offset;

  float peak = max(color.r, max(color.g, color.b));
  if(peak < startCompression){
    return color;
  }

  const float d = 1.0 - startCompression;
  float newPeak = 1.0 - ((d * d) / ((peak + d) - startCompression));
  color *= newPeak / peak;

  float g = 1.0 - (1.0 / ((desaturation * (peak - newPeak)) + 1.0));
  return mix(color, newPeak * vec3(1.0, 1.0, 1.0), g);
}

vec3 doToneMapping(vec3 color){
  switch(pushConstants.mode){
    case MODE_LINEAR:{
      color = clamp(linear(color.xyz), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_REINHARD:{
      color = clamp(reinhard(color.xyz), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_HEJL:{
      color = clamp(hejl(color.xyz), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_HEJL2015:{
      color = clamp(hejl2015(color.xyz, 4.0), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_ACESFILM:{
      color = clamp(ACESFilm(color.xyz), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_ACESFILM2:{
      float m = max(max(color.x, color.y), color.z);
    //color = clamp(pow(ACESFilm2(vec3(color)) * (m / color.xyz), vec3(1.0 / 2.2)), vec3(0.0), vec3(1.0));
      color = clamp(pow(ACESFilm2(vec3(m)) * (color.xyz / m), vec3(1.0 / 2.2)), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_UNCHARTED2:{
      color = clamp(uncharted2(color.xyz), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_UCHIMURA:{
      color = clamp(uchimura(color.xyz), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_LOTTES:{
      color = clamp(lottes(color.xyz), vec3(0.0), vec3(1.0));  
      break;
    }
    case MODE_AMD:{
      color = clamp(AMDTonemapper(color.xyz), vec3(0.0), vec3(1.0));
      break;
    }
    case MODE_AGX_REC709:{
      color = clamp(AgXRec709EOTF(AgXRec709(color.xyz)), vec3(0.0), vec3(1.0));  
      break;
    }
    case MODE_AGX_REC709_GOLDEN:{
      color = clamp(AgXRec709EOTF(agxGolden(AgXRec709(color.xyz))), vec3(0.0), vec3(1.0));  
      break;
    }
    case MODE_AGX_REC709_PUNCHY:{
      color = clamp(AgXRec709EOTF(agxPunchy(AgXRec709(color.xyz))), vec3(0.0), vec3(1.0));  
      break;
    }
    case MODE_AGX_REC2020:{
      color = clamp(AgXRec2020EOTF(AgXRec2020(color.xyz)), vec3(0.0), vec3(1.0));  
      break;
    }
    case MODE_AGX_REC2020_GOLDEN:{
      color = clamp(AgXRec2020EOTF(agxGolden(AgXRec2020(color.xyz))), vec3(0.0), vec3(1.0));  
      break;
    }
    case MODE_AGX_REC2020_PUNCHY:{
      color = clamp(AgXRec2020EOTF(agxPunchy(AgXRec2020(color.xyz))), vec3(0.0), vec3(1.0));  
      break;
    }
    case MODE_KHRONOS_PBR_NEUTRAL:{
      color = clamp(khronosPBRNeutral(color.xyz), vec3(0.0), vec3(1.0));
      break;
    }
    default:{
      color = max(color.xyz, vec3(0.0)); // Clamp negative values to 0.0, but not higher values than 1.0, for HDR 
      break;
    }
  }
  return color;
}

void main() {
#if 1
  vec4 c = subpassLoad(uSubpassInput);
  outColor = vec4(max(vec3(0.0), doToneMapping(max(vec3(0.0), applyColorGrading(c.xyz, colorGradingSettingsBuffer.colorGradingSettings)))), c.w);
#else
  outColor = vec4(1.0);
#endif
}