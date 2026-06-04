#ifndef COLOR_GRADING_GLSL
#define COLOR_GRADING_GLSL

#include "colortemperature.glsl"
#include "rec2020.glsl"

// Order of operations:
// - Exposure (outside color grading function)
// - Post-correction-exposure
// - Night adaptation
// - White balance
// - Hue
// - Channel mixer
// - Shadows/mid-tones/highlights
// - Slope/offset/power (ASC CDL / SOP)
// - Lift/gamma/gain/offset (LGGO)
// - Contrast
// - Vibrance
// - Saturation
// - Curves
// - Tone mapping (outside color grading function)

struct ColorGradingSettings {

  // Exposure, night adaptation, white balance temperature, white balance tint
  vec4 exposureNightAdaptationWhiteBalanceTemperatureTint; // x: exposure, y: night adaptation, z: white balance temperature, w: white balance tint
  
  // Channel mixer
  vec4 channelMixerRed; // x: red, y: green, z: blue, w: unused
  vec4 channelMixerGreen; // x: red, y: green, z: blue, w unused
  vec4 channelMixerBlue; // x: red, y: green, z: blue, w: unused

  // Shadows/mid-tones/highlights 
  vec4 shadows;
  vec4 midtones;
  vec4 highlights;
  vec4 tonalRanges;

  // ASC CDL (slope/offset/power)
  vec4 asccdlSlope; // x: red, y: green, z: blue, w: all channel value
  vec4 asccdlOffset; // x: red, y: green, z: blue, w: all channel value
  vec4 asccdlPower; // x: red, y: green, z: blue, w: all channel value

  vec4 offset; // x: red, y: green, z: blue, w: all channel value

  // Contrast, vibrance, saturation, hue
  vec4 contrastVibranceSaturationHue; // x: contrast, y: vibrance, z: saturation, w: hue

  // Curves
  vec4 curvesGamma; // x: red, y: green, z: blue, w: all channel value
  vec4 curvesMidPoint; // x: red, y: green, z: blue, w: all channel value
  vec4 curvesScale; // x: red, y: green, z: blue, w: all channel value
  
};

const ColorGradingSettings defaultColorGradingSettings = ColorGradingSettings(
  vec4(0.0, 0.0, 0.0, 0.0),    // exposureNightAdaptationWhiteBalanceTemperatureTint
  vec4(1.0, 0.0, 0.0, 0.0),    // channelMixerRed
  vec4(0.0, 1.0, 0.0, 0.0),    // channelMixerGreen
  vec4(0.0, 0.0, 1.0, 0.0),    // channelMixerBlue
  vec4(1.0, 1.0, 1.0, 1.0),    // shadows
  vec4(1.0, 1.0, 1.0, 1.0),    // midtones
  vec4(1.0, 1.0, 1.0, 1.0),    // highlights
  vec4(0.0, 0.333, 0.55, 1.0), // tonalRanges, defaults from DaVinci Resolve 
  vec4(1.0, 1.0, 1.0, 1.0),    // asccdlSlope
  vec4(0.0, 0.0, 0.0, 0.0),    // asccdlOffset
  vec4(1.0, 1.0, 1.0, 1.0),    // asccdlPower
  vec4(0.0, 0.0, 0.0, 0.0),    // offset
  vec4(1.0, 1.0, 1.0, 0.0),    // contrastVibranceSaturationHue
  vec4(1.0, 1.0, 1.0, 1.0),    // curvesGamma
  vec4(1.0, 1.0, 1.0, 1.0),    // curvesMidPoint
  vec4(1.0, 1.0, 1.0, 1.0)     // curvesScale
);

vec3 applyColorGrading(vec3 color, const in ColorGradingSettings colorGradingSettings){

  // Exposure
  color = max(vec3(0.0), color * exp(colorGradingSettings.exposureNightAdaptationWhiteBalanceTemperatureTint.x * 0.6931471805599453));

  // Night adaptation
  if(colorGradingSettings.exposureNightAdaptationWhiteBalanceTemperatureTint.y != 0.0){
#if 1
    // Implementation with precomputed values
    const mat3x4 LMSR = mat3x4(vec4(7.696847, 2.431137, 0.289117, 0.466386), vec4(18.424824, 18.697937, 1.401833, 15.564362), vec4(2.068096, 3.012463, 13.792292, 10.059963));
    const mat3 LMS_to_RGB = mat3(vec3(0.18838383, -0.024254944, -0.0014836978), vec3(-0.18656954, 0.07839355, -0.004056921), vec3(0.01250249, -0.013485514, 0.073612854));
    const mat3 opponent_to_LMS = mat3(-0.5, 0.5, 0.0, 0.0, 0.0, 1.0, 0.5, 0.5, 1.0);
    const mat3 weightedRodResponse = mat3(vec3(-1.043769, 0.5244833, 8.741389), vec3(2.484736, 0.5244229, 8.74038), vec3(0.0, 0.8403885, 0.0));
    vec4 q = LMSR * (color * 380.0);
    vec3 g = inversesqrt(vec3(1.0) + max(vec3(0.0), vec3(0.517883, 0.840936, 0.205428) * (q.rgb + (vec3(0.2, 0.2, 0.3) * q.w))));
    vec3 deltaOpponent = weightedRodResponse * g * q.w * colorGradingSettings.exposureNightAdaptationWhiteBalanceTemperatureTint.y;
    vec3 qHat = q.rgb + (opponent_to_LMS * deltaOpponent);
    color = (LMS_to_RGB * qHat) * 0.002631578947368421;       
#else
    // Reference 
    const vec3 L = vec3(7.696847, 18.424824, 2.068096), M = vec3(2.431137, 18.697937, 3.012463),
               S = vec3(0.289117, 1.401833, 13.792292), R = vec3(0.466386, 15.564362, 10.059963);
    const mat3 LMS_to_RGB = inverse(transpose(mat3(L, M, S)));
    const vec3 m = vec3(0.63721, 0.39242, 1.6064), k = vec3(0.2, 0.2, 0.3);
    const mat3 opponent_to_LMS = mat3(-0.5, 0.5, 0.0, 0.0, 0.0, 1.0, 0.5, 0.5, 1.0);
    const float K_ = 45.0, S_ = 10.0, k3 = 0.6, rw = 0.139, p = 0.6189;
    const mat3 weightedRodResponse = (K_ / S_) * 
                                     mat3(-(k3 + rw), p * k3,  p * S_,
                                     1.0 + (k3 * rw), (1.0 - p) * k3, (1.0 - p) * S_,
                                     0.0, 1.0, 0.0) *
                                     mat3(k.x, 0.0, 0.0, 0.0, k.y, 0.0, 0.0, 0.0, k.z) *
                                     inverse(mat3(m.x, 0.0, 0.0, 0.0, m.y, 0.0, 0.0, 0.0, m.z));
    const float logExposure = 380.0;
    color *= logExposure;
    vec4 q = vec4(dot(color, L), dot(color, M), dot(color, S), dot(color, R));
    vec3 g = inversesqrt(vec3(1.0) + max(vec3(0.0), (vec3(0.33) / m) * (q.rgb + (k * q.w))));
    vec3 deltaOpponent = weightedRodResponse * g * q.w * colorGradingSettings.exposureNightAdaptationWhiteBalanceTemperatureTint.y;
    vec3 qHat = q.rgb + (opponent_to_LMS * deltaOpponent);
    color = (LMS_to_RGB * qHat) / logExposure;
#endif    
  }

  // From linear sRGB to linear Rec. 2020 color space
  color = LinearSRGBToLinearRec2020Matrix * color;

  // White balance in linear Rec. 2020 color space
  if(any(notEqual(colorGradingSettings.exposureNightAdaptationWhiteBalanceTemperatureTint.zw, vec2(0.0)))){
    float k = colorGradingSettings.exposureNightAdaptationWhiteBalanceTemperatureTint.z,
          t = colorGradingSettings.exposureNightAdaptationWhiteBalanceTemperatureTint.w,
          x = 0.31271 - (k * ((k < 0.0) ? 0.0214 : 0.066)),
          y = fma(t, 0.066, ((2.87 * x) - (3.0 * x * x)) - 0.27509507);
    vec3 XYZ = (vec3(x, 1.0, (1.0 - (x + y))) * vec2(1.0 / max(y, 1e-5), 1.0).xyx),
         LMS = mat3(0.401288, -0.250268, -0.002079, 0.650173, 1.204414, 0.048952, -0.051461, 0.045854, 0.953127) * XYZ, // XYZ to CIECAT16 matrix 
         v = vec3(0.975533, 1.016483, 1.084837) / LMS; // D65 white point
    color = ((mat3(3.8733532291777, 0.2507926606282, 0.014079235027999992, // LMS CAT16 to Rec. 2020 matrix
                   -2.3033185515869, 0.8670924192667999, -0.0944384071338, 
                   -0.3471639522502, -0.0968435083328, 0.9927970866124) * 
              mat3(vec3(v.x, 0.0, 0.0), vec3(0.0, v.y, 0.0), vec3(0.0, 0.0, v.z))) * 
             mat3(0.21905756192659998, -0.06438950088709999, -0.0092312583396, // Rec. 2020 to LMS CAT16 matrix
                  0.5965740909872, 0.9903051386899, 0.08574124775780001, 
                  0.1347940470862, 0.0740843621972, 1.0123903105818)) * color;
  } 

  // Hue
  if(colorGradingSettings.contrastVibranceSaturationHue.w != 0.0){
    vec3 hueRotationValues = vec3(0.57735, sin(vec2(radians(colorGradingSettings.contrastVibranceSaturationHue.w)) + vec2(0.0, 1.57079632679)));
    color = mix(hueRotationValues.xxx * dot(hueRotationValues.xxx, color), color, hueRotationValues.z) + (cross(hueRotationValues.xxx, color) * hueRotationValues.y);
  }

  // Channel mixer
  color = vec3(
    dot(color, colorGradingSettings.channelMixerRed.xyz),
    dot(color, colorGradingSettings.channelMixerGreen.xyz),
    dot(color, colorGradingSettings.channelMixerBlue.xyz)
  );

  // Shadows/mid-tones/highlights
  {
    float y = dot(color, LinearRec2020LuminanceWeights),
          s = 1.0 - smoothstep(colorGradingSettings.tonalRanges.x, colorGradingSettings.tonalRanges.y, y),
          h = smoothstep(colorGradingSettings.tonalRanges.z, colorGradingSettings.tonalRanges.w, y),
          m = 1.0 - (s + h);
    color = (color * s * (colorGradingSettings.shadows.xyz * colorGradingSettings.shadows.w)) + 
            (color * m * (colorGradingSettings.midtones.xyz * colorGradingSettings.midtones.w)) +
            (color * h * (colorGradingSettings.highlights.xyz * colorGradingSettings.highlights.w));
  }

  { 
    // Stuff which behaves better in log space

    // Linear to Log Space
    color = fma(log(fma(color, vec3(5.555556), vec3(0.047996))) * 0.43429448190325176, vec3(0.244161), vec3(0.386036));

    // ASC CDL
    color = fma(color, max(vec3(0.0), colorGradingSettings.asccdlSlope.xyz * colorGradingSettings.asccdlSlope.w), colorGradingSettings.asccdlOffset.xyz + colorGradingSettings.asccdlOffset.www);
    color = mix(pow(color, max(vec3(0.0), colorGradingSettings.asccdlPower.xyz * colorGradingSettings.asccdlPower.www)), color, vec3(lessThanEqual(color, vec3(0.0))));

    // Here just as reference "Lift, gamma, gain" but ASC CDL is standardized, LGG is not, where every software has its own implementation and 
    // different formula, which are incompatible with each other, which is not good for interoperability.
    // color = max(vec3(0.0), (((color - vec3(1.0)) * (colorGradingSettings.lggoLift.xyz * colorGradingSettings.lggoLift.www)) + vec3(1.0)) * (colorGradingSettings.lggoGain.xyz * colorGradingSettings.lggoGain.w));
    // color = pow(color, max(vec3(0.0), vec3(1.0) / colorGradingSettings.lggoGamma.xyz));

    // Offset (outside ASC CDL, since it is not part of the ASC CDL standard, but DaVinci Resolve has it in its Lift/Gamma/Gain/Offset, so 
    // it is here, since it doesn't hurt to have it here, when the default values are zero. LGG is otherwise more or less mappable to SOP.)
    // The conversion from "Lift/Gain/Gamma" to "Slope/Offset/Power" can be peformed by following equations:
    //
    //   slope = lift * gain;
    //   offset = (1.0 - lift) * gain;
    //   power = (gamma == 0.0) ? 3.402823466e+38 : (1.0 / gamma);
    //
    // When the "Lift/Gain/Gamma" variant from Blender and DarkTable is used. Both are using the same formula, although their LGG=>SOP
    // conversion is wrong, where slope and offset are swapped at their implementation, which is not correct in direct comparison to
    // the output from between ((((color - 1.0) * lift) + 1.0) * gain) ^ (1.0 / gamma) from Blender and DarkTable and their SOP
    // implementation after the conversion from LGG to SOP. The correct conversion is the one above. 
    color += colorGradingSettings.offset.xyz + colorGradingSettings.offset.www;

    // Contrast
    color = mix(vec3(0.4135884), color, colorGradingSettings.contrastVibranceSaturationHue.x);

    // Log Space to Linear
    color = max(vec3(0.0), fma(exp(2.302585092994046 * fma(color, vec3(4.095658192749866), vec3(-1.5810715060963874))), vec3(0.17999998560000113), vec3(-0.008639279308857654)));

  }

  // Vibrance
  {
    vec2 s = vec2((colorGradingSettings.contrastVibranceSaturationHue.y - 1.0) / (1.0 + exp(-3.0 * (color.x - max(color.y, color.z)))) + 1.0, 0.0);
    vec3 l = LinearRec2020LuminanceWeights * (1.0 - s.x);
    color = vec3(dot(color, l + s.xyy), dot(color, l + s.yxy), dot(color, l + s.yyx));
  }

  // Saturation
  color = max(vec3(0.0), mix(vec3(dot(color, LinearRec2020LuminanceWeights)), color, colorGradingSettings.contrastVibranceSaturationHue.z));
  
  // Curves - "Practical HDR and Wide Color Techniques in Gran Turismo SPORT", Uchimura 2018
  {
    vec3 midPoint = colorGradingSettings.curvesMidPoint.xyz * colorGradingSettings.curvesMidPoint.w,
         scale = colorGradingSettings.curvesScale.xyz * colorGradingSettings.curvesScale.w,
         gamma = colorGradingSettings.curvesGamma.xyz * colorGradingSettings.curvesGamma.w;  
    color = mix(fma(color - midPoint, scale, midPoint), 
                pow(color, gamma) * (vec3(1.0) / pow(midPoint, gamma - vec3(1.0))), 
                vec3(lessThanEqual(color, midPoint)));
  }

  // Back from linear Rec. 2020 color space to linear sRGB, for the following tone mapping pass outside of this function 
  color = LinearRec2020ToLinearSRGBMatrix * max(vec3(0.0), color);

  return color;

}

#endif 