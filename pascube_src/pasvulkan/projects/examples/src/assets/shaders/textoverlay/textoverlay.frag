#version 450 core

// The PasVulkan example project uses frame buffers and textures, which contains values in linear color space and not
// in the sRGB color space, for correct linear space blending, so keep it in mind, while you are reading this code.

layout (location = 0) in vec3 inUV;
layout (location = 1) in vec4 inBackgroundColor;
layout (location = 2) in vec4 inForegroundColor;

layout (binding = 0) uniform UBO {
	float uThreshold;
} ubo;

layout (binding = 1) uniform sampler2DArray uSamplerFont;

layout (location = 0) out vec4 outFragColor;

// Define our own linearstep function for to map distance coverage, when we have sRGB output. 
// Smoothstep's nonlinear response is actually doing some fake-gamma, so it ends up over-correcting when the output is already gamma-correct.
#define TEMPLATE_LINEARSTEP(DATATYPE) \
  DATATYPE linearstep(DATATYPE edge0, DATATYPE edge1, DATATYPE value){ \
    return clamp((value - edge0) / (edge1 - edge0), DATATYPE(0.0), DATATYPE(1.0)); \
  }
TEMPLATE_LINEARSTEP(float)  
TEMPLATE_LINEARSTEP(vec4)  

// SDF with 5 point tap tent filter-based supersampling

const float SQRT_0_DOT_5 = sqrt(0.5),
            HALF_BY_SQRT_TWO = 0.5 / sqrt(2.0),
            ONE_BY_THREE = 1.0 / 3.0;

#ifndef BLENDMODE
#define BLENDMODE 1
#endif

#if BLENDMODE == 1
vec4 convertLinearRGBToSRGB(in vec4 pLinearRGB){
  return vec4(mix((1.055 * pow(pLinearRGB.rgb, vec3(1.0 / 2.4))) - vec3(0.055), 
                  pLinearRGB.rgb * 12.92,
                  lessThan(pLinearRGB.rgb, vec3(0.0031308))),
              pLinearRGB.a);
}

vec4 convertSRGBToLinearRGB(in vec4 pSRGB){
  return vec4(mix(pow((pSRGB.rgb + vec3(0.055)) * (1.0 / 1.055), vec3(2.4)), 
                  pSRGB.rgb * (1.0 / 12.92),
                  lessThan(pSRGB.rgb, vec3(0.04045))),
              pSRGB.a);
}
#endif

vec4 blend(const in vec4 pFrom, const in vec4 pTo, const in float pFactor){
#if BLENDMODE == 1
  // gamma-incorrect blending for fonts, because the most fonts are (sadly) designed for gamma-incorrect antialiasing
  // blending in sRGB space 
  return convertSRGBToLinearRGB(mix(convertLinearRGBToSRGB(pFrom), 
                                    convertLinearRGBToSRGB(pTo), 
                                    pFactor));
#elif BLENDMODE == 2
  // gamma-incorrect blending for fonts, because the most fonts are (sadly) designed for gamma-incorrect antialiasing
  // blending with gamma = 1.42
  const float y = 1.42; // the value is from Photoshop, which seems to use 1.42 as default gamma value for text antialiasing 
  const vec3 f = vec3(1.0 / y, y, 1.0); 
  return pow(mix(pow(pFrom, f.xxxz), pow(pTo, f.xxxz), pFactor), f.yyyz);
#elif BLENDMODE == 3
  // gamma-incorrect blending for fonts, because the most fonts are (sadly) designed for gamma-incorrect antialiasing
  // blending with gamma = 2.0
  vec4 t = mix(vec4(sqrt(pFrom.rgb), pFrom.a), vec4(sqrt(pTo.rgb), pTo.a), pFactor);
  return vec4(t.rgb * t.rgb, t.a);
#elif BLENDMODE == 4
  // gamma-incorrect blending for fonts, because the most fonts are (sadly) designed for gamma-incorrect antialiasing
  // blending with gamma = 2.2
  const float y = 2.2; 
  const vec3 f = vec3(1.0 / y, y, 1.0); 
  return pow(mix(pow(pFrom, f.xxxz), pow(pTo, f.xxxz), pFactor), f.yyyz);
#else // BLENDMODE == 0                  
  // gamma-correct blending
  // blending in linear space (gamma = 1.0) 
  return mix(pFrom, pTo, pFactor);
#endif
}
  
void main(void){
  float center = textureLod(uSamplerFont, inUV, 0.0).r;
#ifdef SIMPLE_SIGNED_DISTANCE_FIELD_WIDTH_CALCULATION
  vec2 width = vec2(0.5) + (vec2(-SQRT_0_DOT_5, SQRT_0_DOT_5) * length(vec2(dFdx(center), dFdy(center))));
#else
  // Based on: https://www.essentialmath.com/blog/?p=151 but with Adreno issue compensation, which likes to drop tiles on division by zero
  const float NORMALIZATION_THICKNESS_SCALE = SQRT_0_DOT_5 * (0.5 / 4.0); 
  vec2 centerGradient = vec2(dFdx(center), dFdy(center));
  float centerGradientSquaredLength = dot(centerGradient, centerGradient);
  if(centerGradientSquaredLength < 1e-4){
    centerGradient = vec2(SQRT_0_DOT_5); 
  }else{
    centerGradient *= inversesqrt(centerGradientSquaredLength); 
  }
  vec2 Juv = inUV.xy * textureSize(uSamplerFont, 0).xy,       
       Jdx = dFdx(Juv), 
       Jdy = dFdy(Juv),
       jacobianGradient = vec2((centerGradient.x * Jdx.x) + (centerGradient.y * Jdy.x), 
                               (centerGradient.x * Jdx.y) + (centerGradient.y * Jdy.y));
  vec2 width = vec2(0.5) + (vec2(-1.0, 1.0) * min(length(jacobianGradient) * NORMALIZATION_THICKNESS_SCALE, 0.5));
#endif
  vec4 buv = inUV.xyxy + (vec2((dFdx(inUV.xy) + dFdy(inUV.xy)) * HALF_BY_SQRT_TWO).xyxy * vec2(-1.0, 1.0).xxyy);
  outFragColor = blend(inBackgroundColor, 
                       inForegroundColor,
                       clamp((linearstep(width.x, width.y, center) + 
                             dot(linearstep(width.xxxx, 
                                            width.yyyy, 
                                            vec4(textureLod(uSamplerFont, vec3(buv.xy, inUV.z), 0.0).r,
                                                 textureLod(uSamplerFont, vec3(buv.zw, inUV.z), 0.0).r,
                                                 textureLod(uSamplerFont, vec3(buv.xw, inUV.z), 0.0).r,
                                                 textureLod(uSamplerFont, vec3(buv.zy, inUV.z), 0.0).r)), vec4(0.5))) * ONE_BY_THREE, 0.0, 1.0));
}
