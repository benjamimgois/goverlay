#version 460 core

// Based on:
//
// GPU Pro 7: Real-Time Volumetric Cloudscapes - A. Schneider
//     Follow up presentation: http://advances.realtimerendering.com/s2017/Nubis%20-%20Authoring%20Realtime%20Volumetric%20Cloudscapes%20with%20the%20Decima%20Engine%20-%20Final%20.pdf
// R. Hogfeldt, "Convincing Cloud Rendering An Implementation of Real-Time Dynamic Volumetric Clouds in Frostbite"
// F. Bauer, "Creating the Atmospheric World of Red Dead Redemption 2: A Complete and Integrated Solution" in Advances in Real-Time Rendering in Games, Siggraph 2019.
// 
// Multi scattering approximation: http://magnuswrenninge.com/wp-content/uploads/2010/03/Wrenninge-OzTheGreatAndVolumetric.pdf
// Participating media and volumetric integration: https://media.contentapi.ea.com/content/dam/eacom/frostbite/files/s2016-pbs-frostbite-sky-clouds-new.pdf
//     Small example: https://www.shadertoy.com/view/XlBSRz

//#define SHADOWMAP

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_multiview : enable
#extension GL_EXT_samplerless_texture_functions : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable
#ifdef RAYTRACING
  #extension GL_EXT_buffer_reference : enable
  #define USE_BUFFER_REFERENCE
  #define USE_MATERIAL_BUFFER_REFERENCE
#endif

#ifdef COMPUTE_SHADER
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
#endif

#include "bufferreference_definitions.glsl"

/* clang-format off */

//layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

/* clang-format on */

#undef SHADOWS

#define MULTISCATAPPROX_ENABLED
#ifdef SHADOWS
 #define SHADOWS_ENABLED
 #define NOTEXCOORDS
#else
 #undef SHADOWS_ENABLED
#endif

#define FLAGS_USE_FAST_SKY 1u
#define FLAGS_USE_FAST_AERIAL_PERSPECTIVE 2u
#define FLAGS_USE_BLUE_NOISE 4u
#define FLAGS_SHADOWS 8u
#define PUSH_CONSTANT_FLAG_REVERSE_DEPTH 65536u

// Push constants
layout(push_constant, std140) uniform PushConstants {
  int baseViewIndex;
  int countViews;
  int frameIndex;
  uint flags;
  int countSamples;
} pushConstants;

#include "globaldescriptorset.glsl"

#include "math.glsl"

#ifdef SHADOWS
#define SPECIAL_SHADOWS

#if defined(RAYTRACING)
  #include "raytracing.glsl"
#endif

#ifdef SHADOWMAP

#else
#if 1 //!defined(RAYTRACING)
#define NUM_SHADOW_CASCADES 4
const uint SHADOWMAP_MODE_NONE = 1;
const uint SHADOWMAP_MODE_PCF = 2;
const uint SHADOWMAP_MODE_DPCF = 3;
const uint SHADOWMAP_MODE_PCSS = 4;
const uint SHADOWMAP_MODE_MSM = 5;

#define inFrameIndex pushConstants.frameIndex

layout(set = 3, binding = 0, std140) uniform uboCascadedShadowMaps {
  mat4 shadowMapMatrices[NUM_SHADOW_CASCADES];
  vec4 shadowMapSplitDepthsScales[NUM_SHADOW_CASCADES];
  vec4 constantBiasNormalBiasSlopeBiasClamp[NUM_SHADOW_CASCADES];
  uvec4 metaData; // x = type
} uCascadedShadowMaps;

layout(set = 3, binding = 1) uniform sampler2DArray uCascadedShadowMapTexture;

#ifdef PCFPCSS

// Yay! Binding Aliasing! :-)
layout(set = 3, binding = 1) uniform sampler2DArrayShadow uCascadedShadowMapTextureShadow;

#endif // PCFPCSS
#endif // !RAYTRACING 

vec3 inWorldSpacePosition, workNormal;

#include "shadows.glsl"

#endif // SHADOWMAP

#endif // SHADOWS

#include "atmosphere_common.glsl"

#ifndef COMPUTE_SHADER
layout(location = 0) in vec2 inTexCoord;
#endif

#ifdef SHADOWMAP

#ifndef COMPUTE_SHADER
layout(location = 0) out vec4 outMSMCoefficients;
#endif

#else

layout(location = 0) out vec4 outInscattering; // w = monochromatic transmittance as alpha
layout(location = 1) out vec4 outTransmittance; // w = monochromatic transmittance as alpha
layout(location = 2) out float outDepth; // linear depth with infinite for far plane (requires 32-bit floating point target buffer)

#endif

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256]; // 65536 / (64 * 4) = 256
} uView;

#ifndef SHADOWMAP

#ifdef MSAA

#ifdef MULTIVIEW
layout(set = 2, binding = 0) uniform texture2DMSArray uDepthTexture;
#else
layout(set = 2, binding = 0) uniform texture2DMS uDepthTexture;
#endif

#else

#ifdef MULTIVIEW
layout(set = 2, binding = 0) uniform texture2DArray uDepthTexture; 
#else
layout(set = 2, binding = 0) uniform texture2D uDepthTexture;
#endif

#endif // MSAA

#endif // !SHADOWMAP

layout(set = 2, binding = 1, std140) uniform AtmosphereParametersBuffer {
  AtmosphereParameters atmosphereParameters;
} uAtmosphereParameters;

layout(set = 2, binding = 2) uniform sampler2D uTextureBlueNoise;

layout(set = 2, binding = 3) uniform sampler2D uTextureSkyLuminance;

layout(set = 2, binding = 4) uniform sampler2D uTextureTransmittanceLUT;

layout(set = 2, binding = 5) uniform sampler3D uTextureShapeNoise;

layout(set = 2, binding = 6) uniform sampler3D uTextureDetailNoise;

layout(set = 2, binding = 7) uniform sampler3D uTextureCurlNoise;

layout(set = 2, binding = 8) uniform samplerCube uTextureSkyLuminanceLUT;

layout(set = 2, binding = 9) uniform samplerCube uTextureWeatherMap;

layout(set = 2, binding = 10) uniform samplerCube uTexturePercipitationMap;

layout(set = 2, binding = 11) uniform samplerCube uTextureAtmosphereMap;

layout(set = 2, binding = 12, std430) buffer AtmosphereMapMinMaxBuffer {
  float minValue;
  float maxValue;
} uAtmosphereMapMinMax;

#ifdef COMPUTE_SHADER
layout(set = 2, binding = 13, rgba16) uniform image2D uDestinationTexture;
#endif

#ifdef SHADOWMAP
#include "msm_16bit.glsl" 
#endif

#include "quaternion.glsl"

//////////////////////////////////////////////////////////////////////////////////

bool usePrecipitationMap = ((uAtmosphereParameters.atmosphereParameters.flags & FLAGS_USE_PRECIPITATION_MAP) != 0u);

// Check if the atmosphere map should be used, if it is enabled in the flags and if the min and max values are not both 1.0,
// which would indicate that the atmosphere can be considered fully existing everywhere (no atmosphere map lookups needed =>
// faster and more performance).
bool useAtmosphereMap = ((uAtmosphereParameters.atmosphereParameters.flags & FLAGS_USE_ATMOSPHERE_MAP) != 0u) && 
                        (((abs(1.0 - uAtmosphereMapMinMax.minValue) > 1e-4) || (abs(1.0 - uAtmosphereMapMinMax.maxValue) > 1e-4)));

//////////////////////////////////////////////////////////////////////////////////

float bayer2(vec2 a){ 
  a = floor(a);
  return fract(dot(a, vec2(0.5, a.y * 0.75)));
}

float bayer4(vec2 a){
   return fma(bayer2(a * 0.5), 0.25, bayer2(a));
} 

float bayer8(vec2 a){
   return fma(bayer4(a * 0.5), 0.25, bayer4(a));
} 

float bayer16(vec2 a){
   return fma(bayer8(a * 0.5), 0.25, bayer8(a));
} 

float bayer32(vec2 a){
   return fma(bayer16(a * 0.5), 0.25, bayer16(a));
} 

float bayer64(vec2 a){
   return fma(bayer32(a * 0.5), 0.25, bayer32(a));
} 
                  
float bayer128(vec2 a){
   return fma(bayer64(a * 0.5), 0.25, bayer64(a));
} 
 
float bayer256(vec2 a){
   return fma(bayer128(a * 0.5), 0.25, bayer128(a));
} 

vec2 intersectSphere(vec3 rayOrigin, vec3 rayDirection, vec4 sphere){
  vec3 v = rayOrigin - sphere.xyz;
  float b = dot(v, rayDirection),
        c = dot(v, v) - (sphere.w * sphere.w),
        d = (b * b) - c;
  return (d < 0.0) 
             ? vec2(-1.0)                                // No intersection
             : ((vec2(-1.0, 1.0) * sqrt(d)) - vec2(b));  // Intersection
}        

vec2 rayIntersectSphere(vec3 rayOrigin, vec3 rayDirection, vec4 sphere){
  vec3 sphereCenterToRayOrigin = rayOrigin - sphere.xyz;
  float a = dot(rayDirection, rayDirection),
        b = dot(rayDirection, sphereCenterToRayOrigin) * 2.0,
        c = dot(sphereCenterToRayOrigin, sphereCenterToRayOrigin) - (sphere.w * sphere.w); 
  float discriminant = (b * b) - ((a * c) * 4.0);
  if(discriminant < 0.0){
    return vec2(-1.0);
  }else if(discriminant == 0.0){
    return vec2((-0.5 * b) / a);
  }else{
    float q = (b + (sqrt(discriminant) * ((b > 0.0) ? 1.0 : -1.0))) * (-0.5);
    return vec2(q / a, c / q);
  }  
}                      

float getHeightFractionForPoint(const in vec3 position){
  float height = length(position);  
  if((height >= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight) && (height <= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.EndHeight)){
    return clamp((height - uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight) / (uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.EndHeight - uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight), 0.0, 1.0);
  }else if((height >= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.StartHeight) && (height <= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight)){
    return clamp((height - uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.StartHeight) / (uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight - uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.StartHeight), 0.0, 1.0);
  }else{  
    return 0.0;
  }
}

float getWeatherDensity(vec4 weatherData){
  return mix(1.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.WetnessDensityFactor, weatherData.z);
}

float getWeatherLuminance(vec4 weatherData){
  return mix(1.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.WetnessLuminanceFactor, weatherData.z);
}

float getDensityHeightGradientForPoint(const in vec3 position, const in float heightFraction, const in vec4 weatherData){
  const vec3 weatherTypeMask = vec3(1.0 - clamp(weatherData.y * 2.0, 0.0, 1.0), 1.0 - (abs(weatherData.y - 0.5) * 2.0), clamp(weatherData.y - 0.5, 0.0, 1.0) * 2.0);
  const vec4 heightGradient = uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.heightGradients * weatherTypeMask;
  return smoothstep(heightGradient.x, heightGradient.y, heightFraction) * smoothstep(heightGradient.w, heightGradient.z, heightFraction);
}
                             
vec3 scaleLayerLowCloudPosition(vec3 position){
  return position * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.PositionScale;
}                                        

vec3 scaleLayerHighCloudPosition(vec3 position){
  return position * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.PositionScale;
}

#include "rotation.glsl"

vec4 getWeatherData(const in vec3 position, const in mat3 rotationMatrices[2], const float mipMapLevel){
  // Percipitation map: -1.0 = no clouds, 0.0 = dry clouds, 1.0 = wet clouds
  const float percipitation = usePrecipitationMap ? clamp(textureLod(uTexturePercipitationMap, normalize(position), 0.0).x, -1.0, 1.0) : 0.0;
  const float wetness = clamp(percipitation, 0.0, 1.0);
  const float factor = clamp(percipitation + 1.0, 0.0, 1.0); // -1.0 .. 0.0 => 0.0 .. 1.0
  return clamp(
    fma(
      vec4(
        textureLod(uTextureWeatherMap, normalize(rotationMatrices[0] * position), mipMapLevel).xyz,
        textureLod(uTextureWeatherMap, normalize(rotationMatrices[1] * position), mipMapLevel).w
      ),
      mix(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.dryCoverageTypeWetnessTopFactors, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.wetCoverageTypeWetnessTopFactors, wetness), 
      mix(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.dryCoverageTypeWetnessTopOffsets, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.wetCoverageTypeWetnessTopOffsets, wetness)
    ) * vec2(factor, 1.0).xyyx,
    vec4(0.0),
    vec4(1.0)
  );
}                                     

//////////////////////////////////////////////////////////////////////////
            
float getLayerHighCloudNoiseHash(ivec3 p){
  vec3 p3 = fract(vec3(p) * 0.1031);
  p3 += dot(p3, p3.zyx + vec3(31.32));
  return fract((p3.x + p3.y) * p3.z);
}

float getLayerHighCloudNoise(vec3 p){
  ivec3 i = ivec3(floor(p));
  vec3 f = fract(p);  
  f *= f * (3.0 - (2.0 * f));  
  ivec2 e = ivec2(0, 1);	
  return mix(mix(mix(getLayerHighCloudNoiseHash(i + e.xxx), getLayerHighCloudNoiseHash(i + e.yxx), f.x),
                 mix(getLayerHighCloudNoiseHash(i + e.xyx), getLayerHighCloudNoiseHash(i + e.yyx), f.x), f.y),
             mix(mix(getLayerHighCloudNoiseHash(i + e.xxy), getLayerHighCloudNoiseHash(i + e.yxy), f.x),
                 mix(getLayerHighCloudNoiseHash(i + e.xyy), getLayerHighCloudNoiseHash(i + e.yyy), f.x), f.y), f.z);
}

float layerHighCloudRotationTime = uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.Speed;
mat3 layerHighCloudRotationBase = rotationMatrix(normalize(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.RotationBase.xyz), uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.RotationBase.w * layerHighCloudRotationTime);
mat3 layerHighCloudRotationOctave1 = rotationMatrix(normalize(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.RotationOctave1.xyz), uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.RotationOctave1.w * layerHighCloudRotationTime);
mat3 layerHighCloudRotationOctave2 = rotationMatrix(normalize(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.RotationOctave2.xyz), uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.RotationOctave2.w * layerHighCloudRotationTime);
mat3 layerHighCloudRotationOctave3 = rotationMatrix(normalize(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.RotationOctave3.xyz), uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.RotationOctave3.w * layerHighCloudRotationTime);

float getLayerHighClouds(const in vec3 p, const in VolumetricCloudLayerHigh cloudLayerParameters, const in vec4 weatherData){
  float h = length(p);
  if((weatherData.w > 1e-4) && (cloudLayerParameters.Density > 1e-4) && (h >= cloudLayerParameters.StartHeight) && (h <= cloudLayerParameters.EndHeight)){
    vec3 cloudCoord = layerHighCloudRotationBase * (p * cloudLayerParameters.PositionScale);
    float noise = getLayerHighCloudNoise(cloudCoord * cloudLayerParameters.OctaveScales.x) * cloudLayerParameters.OctaveFactors.x;
 	  noise += getLayerHighCloudNoise((layerHighCloudRotationOctave1 * cloudCoord) * cloudLayerParameters.OctaveScales.y) * cloudLayerParameters.OctaveFactors.y;
    noise += getLayerHighCloudNoise((layerHighCloudRotationOctave2 * cloudCoord) * cloudLayerParameters.OctaveScales.z) * cloudLayerParameters.OctaveFactors.z;
    noise += getLayerHighCloudNoise((layerHighCloudRotationOctave3 * cloudCoord) * cloudLayerParameters.OctaveScales.w) * cloudLayerParameters.OctaveFactors.w;
    float horizonHeightPercent = clamp((h - cloudLayerParameters.StartHeight) / (cloudLayerParameters.EndHeight - cloudLayerParameters.StartHeight), 0.0, 1.0);
    return smoothstep(cloudLayerParameters.CoverMin, cloudLayerParameters.CoverMax, noise) *
           (smoothstep(0.0, cloudLayerParameters.FadeMin, horizonHeightPercent) *
            smoothstep(1.0, 1.0 - cloudLayerParameters.FadeMax, horizonHeightPercent)) *
           cloudLayerParameters.Density *
           weatherData.w;
  }else{
    return 0.0;    
  }            
}
                                                       
//////////////////////////////////////////////////////////////////////////

mat3 layerLowWindRotation, layerLowCurlRotation;

float getLowResCloudDensity(vec3 position, const in mat3 rotationMatrices[2], const in mat3 windRotation, const in vec4 weatherData, const float mipMapLevel){
            
  float height = length(position);

  if((weatherData.x > 1e-4) && (height >= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight) && (height <= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.EndHeight)){

    // Layer low clouds

    // Evaluate atmosphere map, with AtmosphereMapTexture cube map with atmosphere visiblity values
    const float atmosphereFactor = useAtmosphereMap 
                                    ? textureLod(uTextureAtmosphereMap, normalize(position), 0.0).x // 0.0 = no atmosphere, 1.0 = full atmosphere    
                                    : 1.0; // No atmosphere map, so return full atmosphere
    if(atmosphereFactor < 1e-4){
      return 0.0; // No atmosphere, so no clouds
    }                                

    position = rotationMatrices[0] * position;
                       
    float heightFraction = clamp((height - uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight) / (uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.EndHeight - uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight), 0.0, 1.0);
                       
    // Read the low-frequency Perlin-Worley and Worley noises
    vec4 lowFrequencyNoises = textureLod(uTextureShapeNoise, scaleLayerLowCloudPosition(windRotation * position) * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.ShapeNoiseScale, mipMapLevel);
                                                                                                                      
    // Build an FBM out of the low frequency Worley noises that can be used to add detail to the low-frequency Perlin-Worley noise
    float lowFrequencyFBM = dot(lowFrequencyNoises.yzw, vec3(0.625, 0.25, 0.125));
  
    // Define the base cloud shape by dilating it with the low-frequency FBM made of Worley noise
    float baseCloud = remap(lowFrequencyNoises.x, -(1.0 - lowFrequencyFBM), 1.0, 0.0, 1.0);
    
    // Get the density-height gradient using the density height function
    float densityHeightGradient = getDensityHeightGradientForPoint(position, heightFraction, weatherData);
    
    // Apply the height funct ion to the base cloud shape .
    baseCloud *= densityHeightGradient;
    
    // Cloud coverage is stored in weather data's red channel .
    float cloudCoverage = weatherData.x;
    
    // Use remap to apply the cloud coverage attribute .
    float baseCloudWithCoverage = remap(baseCloud, 1.0 - cloudCoverage, 1.0, 0.0, 1.0);
  
    // Multiply the result by the cloud coverage attribute so that smaller clouds are lighter and more aesthetically pleasing
    baseCloudWithCoverage *= cloudCoverage;

    // Apply the atmosphere factor to the base cloud with coverage
    baseCloudWithCoverage *= atmosphereFactor;

    // Apply the wetness factor to the base cloud with coverage
    //baseCloudWithCoverage *= getWeatherDensity(weatherData);
    
    return clamp(baseCloudWithCoverage, 0.0, 1.0);
    
  }else if((weatherData.w > 1e-4) && (height >= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.StartHeight) && (height <= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight)){

    // Layer high clouds

    // Evaluate atmosphere map, with AtmosphereMapTexture cube map with atmosphere visiblity values
    const float atmosphereFactor = useAtmosphereMap 
                                    ? textureLod(uTextureAtmosphereMap, normalize(position), 0.0).x // 0.0 = no atmosphere, 1.0 = full atmosphere    
                                    : 1.0; // No atmosphere map, so return full atmosphere
    if(atmosphereFactor < 1e-4){
      return 0.0; // No atmosphere, so no clouds
    }                                

    position = rotationMatrices[1] * position;
    
    return getLayerHighClouds(position, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh, weatherData) * atmosphereFactor;
    
  }else{
  
    return 0.0;
    
  } 
  
  
}     

float getHighResCloudDensity(vec3 position, const in mat3 rotationMatrices[2], const in mat3 windRotation, const in vec3 curlOffset, const in vec4 weatherData, const float lowResDensity, const float mipMapLevel){
                           
  float height = length(position);
  
  if((weatherData.x > 1e-4) && (height >= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight) && (height <= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.EndHeight)){

    // Layer low clouds
  
    position = rotationMatrices[0] * position;

    float heightFraction = clamp((height - uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight) / (uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.EndHeight - uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight), 0.0, 1.0);

    // Sample high-frequency noises
    vec3 highFrequencyNoises = textureLod(
      uTextureDetailNoise,
      scaleLayerLowCloudPosition(
        (windRotation * position) +
        (curlOffset.xyz * (1.0 - heightFraction) * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.CurlScale)
      ) * 
      uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.DetailNoiseScale,
      mipMapLevel
    ).xyz;

    // Build high frequency Worley noise FBM
    float highFrequencyFBM = dot(highFrequencyNoises, vec3(0.625, 0.25, 0.125));
  
    // Transition from wispy shapes to billowy shapes over height 
    float highFrequencyNoiseModifer = mix(highFrequencyFBM, 
                                          1.0 - highFrequencyFBM, 
                                          clamp(heightFraction * 10.0, 0.0, 1.0));
    
    // Erode the base cloud shape with the distorted high-frequency Worley noises
    return clamp(remap(lowResDensity, highFrequencyNoiseModifer * 0.2, 1.0, 0.0, 1.0), 0.0, 1.0);
    
  }else{

    // For other cloud layers, return just the low resolution density, as high resolution density is not needed or already included in the low resolution density

    return clamp(lowResDensity, 0.0, 1.0);
  
  }

}

/*float scaleDensity(float density){
  return density;
}*/

float powderTerm(float density, float cosAngle){
	return mix(1.0, clamp(1.0 - exp(-(density * 2.0)), 0.0, 1.0), clamp(fma(cosAngle, -0.5, 0.5), 0.0, 1.0));
}                                 
  
float powderTerm(float density){
  return clamp(1.0 - exp(-(density * 2.0)), 0.0, 1.0);
}                                 
 
float beerTerm(float density){
  return exp(-density);
}

float beerLaw(float density){
	return max(exp(-density), exp(-density * 0.5) * 0.7);
}

float henyeyGreensteinPhase(float cosAngle, float g){
  float g2 = g * g;
  return ((1.0 - g2) / pow((1.0 + g2) - (2.0 * g * cosAngle), 3.0 / 2.0)) / (4.0 * PI);
}

float getSunPhase(vec3 rayDirection, vec3 sunDirection, float g) {
  float g2 = g * g;
  return (1.0 - g2) / (pow((1.0 + g2) - ((2.0 * g) * dot(rayDirection, sunDirection)), 3.0 / 2.0) * (4.0 * PI));
}

const vec3 randomVectors[8] = vec3[](
	vec3( 0.38051305,  0.92453449, -0.02111345),
	vec3(-0.50625799, -0.03590792, -0.86163418),
	vec3(-0.32509218, -0.94557439,  0.01428793),
	vec3( 0.09026238, -0.27376545,  0.95755165),
	vec3( 0.28128598,  0.42443639, -0.86065785),
	vec3(-0.16852403,  0.14748697,  0.97460106),
	vec3(-0.86065785,  0.28128598,  0.42443639),
	vec3( 0.73454242, -0.17479357,  0.27376545)
);

float sampleShadow(const in vec3 rayOrigin,
                   const in vec3 rayDirection,
                   const in float rayLength,
                   const in bool highResCloudDensity,
                   const float mipMapLevel,
                   const in mat3 rotationMatrices[2]){
                   
  vec2 tTopSolutions = intersectSphere(rayOrigin, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight).xxxy);
  if(tTopSolutions.y >= 0.0){
    
    vec2 tMinMax = tTopSolutions;             

    vec2 tGroundSolutions = intersectSphere(rayOrigin, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.BottomRadius).xxxy);
    if(tGroundSolutions.x >= 0.0){
      return 0.0; // Planet blocks all sun light
    }

    vec2 tBottomSolutions = intersectSphere(rayOrigin, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight).xxxy);

    if((tBottomSolutions.x < 0.0) && (tBottomSolutions.y >= 0.0)){
      // Below clouds
      tMinMax.x = min(tMinMax.x, tBottomSolutions.y);
    }
    
    tMinMax = clamp(tMinMax, vec2(0.0), vec2(rayLength));
 
    if(tMinMax.x < tMinMax.y){
                   
      const int numSteps = 7; 
      float r = 1.0, timeStep = rayLength / float(numSteps), time = timeStep * 0.5;         
      for(int i = 0; i < numSteps; i++){
        vec3 position = rayOrigin + (rayDirection * time);
        if(length(position) > uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight){
          break;
        }else{
          vec4 weatherData = getWeatherData(position, rotationMatrices, mipMapLevel + 1.0);
          float density = getLowResCloudDensity(position, rotationMatrices, layerLowWindRotation, weatherData, mipMapLevel + 1.0);            
          if(highResCloudDensity){
            // If are ray march is hasn't absorbed too much light yet, we use the high res cloud data to calculate the self occlusion of the cloud 
            density = getHighResCloudDensity(position, rotationMatrices, layerLowWindRotation, vec3(0.0), weatherData, density, mipMapLevel + 1.0);
          }
          r *= exp(-(density * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.ShadowDensity * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.DensityScale * timeStep));
          time += timeStep;  
        }
      }
      
      return r;
      
    }
    
   }
   
   return 1.0;
   
}

float sampleCloudDensityAlongCone(const in vec3 rayOrigin,
                                  const in vec3 rayDirection,
                                  const in float rayLength,
                                  const in float rayLengthFarMultipler,
                                  const in bool highResCloudDensity,
                                  const float mipMapLevel,
                                  const in mat3 rotationMatrices[2]){
  const int numSteps = 7;
  float coneSpreadMultipler = length(rayDirection) * (rayLength / float(numSteps + 1)),
        densityAlongCone = 0.0;
  vec3 position = rayOrigin;
  for(int stepIndex = 0; stepIndex <= numSteps; stepIndex++){
    position = (stepIndex == numSteps) 
                 ? (rayOrigin + (rayDirection * (rayLength * rayLengthFarMultipler)))
                 : (position + (rayDirection + (coneSpreadMultipler * randomVectors[stepIndex] * float(stepIndex))));
    if(length(position) <= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight){
      vec4 weatherData = getWeatherData(position, rotationMatrices, mipMapLevel + 1.0);                    
      float density = getLowResCloudDensity(position, rotationMatrices, layerLowWindRotation, weatherData, mipMapLevel + 1.0); 
      if(highResCloudDensity){
        // If are ray march is hasn't absorbed too much light yet, 
        // we use the high res cloud data to calculate the self occlusion of the cloud 
        vec3 curlOffsetVector = decodeCURL(textureLod(uTextureCurlNoise, scaleLayerLowCloudPosition(layerLowWindRotation * (rotationMatrices[0] * position)), mipMapLevel + 1.0).xyz) * (1.0 * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.Scale);
        density = getHighResCloudDensity(position, rotationMatrices, layerLowWindRotation, curlOffsetVector, weatherData, density, mipMapLevel + 1.0); 
      }
      if(length(position) < uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.StartHeight){
        density *= getWeatherDensity(weatherData);  
      }
      densityAlongCone += density * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LightingDensity * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.DensityScale;
    }
  }                 
  return densityAlongCone;
} 

float projectionVectorScale;
vec3 sideVector, upVector;

bool traceVolumetricClouds(vec3 rayOrigin, 
                           vec3 rayDirection, 
#ifndef SHADOWMAP
                           float rayLength, 
#endif                           
                           ivec2 threadPosition,
#ifndef SHADOWMAP
                           out vec3 inscattering,
                           out vec3 transmittance,
#endif 
                           out float depth){

#ifdef SHADOWMAP

  vec3 transmittance = vec3(1.0);

#else

  inscattering = vec3(0.0);
  
  transmittance = vec3(1.0);

#endif

  vec3 toSunDirection = normalize(getSunDirection(uAtmosphereParameters.atmosphereParameters));
  
#ifndef SHADOWMAP

  float cosAngle = dot(rayDirection, toSunDirection);

  float forwardScatteringPhase = henyeyGreensteinPhase(cosAngle, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.ForwardScatteringG);
  float backwardScatteringPhase = henyeyGreensteinPhase(cosAngle, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.BackwardScatteringG);

#endif

  vec3 scattering = uAtmosphereParameters.atmosphereParameters.VolumetricClouds.Scattering.xyz;
  vec3 absorption = uAtmosphereParameters.atmosphereParameters.VolumetricClouds.Absorption.xyz;
  vec3 extinction = absorption + scattering;

#ifndef SHADOWMAP

  vec3 sunColor = uAtmosphereParameters.atmosphereParameters.SolarIlluminance.xyz;

#endif

  vec2 weightedDepth = vec2(0.0);
 
  vec2 tTopSolutions = intersectSphere(rayOrigin, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight).xxxy);
  if(tTopSolutions.y >= 0.0){

    float distanceToPlanetCenter = length(rayOrigin);
    
#ifndef SHADOWMAP
    // If the ray is outside the atmosphere, the ray length is set to infinity, so that the ray march code path handles the ray as if 
    // it is in outer space without occluders, for to avoid artefacts at calculating the ray march steps in outer space when 
    // for example asteroids are present.
    if((!isinf(rayLength)) && ((rayLength - distanceToPlanetCenter) > uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight)){
      rayLength = uintBitsToFloat(0x7f800000u); // INF      
    }
#endif

    vec3 viewNormal = normalize(rayOrigin);
    
    vec2 tMinMax = tTopSolutions;             

    vec2 tBottomSolutions = intersectSphere(rayOrigin, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight).xxxy);

    vec2 tGroundSolutions = intersectSphere(rayOrigin, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.BottomRadius).xxxy);

    if((tBottomSolutions.x < 0.0) && (tBottomSolutions.y >= 0.0)){
      // Below clouds
#ifndef SHADOWMAP
      if(rayLength < tBottomSolutions.y){
        return false;
      }
#endif
      tMinMax.x = max(tMinMax.x, tBottomSolutions.y);
    }else if(tBottomSolutions.x >= 0.0){
      // Inside or above clouds
      if(tGroundSolutions.x >= 0.0){
        tMinMax.y = min(tMinMax.y, tBottomSolutions.x);
      }           
    }

    if(tGroundSolutions.x >= 0.0){
      // Above ground
      tMinMax.y = min(tMinMax.y, tGroundSolutions.x);
    }else if(tGroundSolutions.y >= 0.0){ 
      // Below ground
      if(dot(rayDirection, viewNormal) < 0.0){
        tMinMax = vec2(1.0, 0.0);//min(tMinMax.y, tGroundSolutions.y);
      }
    }
    
#ifdef SHADOWMAP    
    tMinMax = max(tMinMax, vec2(0.0));
#else
    tMinMax = clamp(tMinMax, vec2(0.0), vec2(rayLength));
#endif
    
    if(tMinMax.x < tMinMax.y){

      float mipMapLevel = 0.0;

#ifdef SHADOWMAP    
      int countSteps = clamp(int(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.RayMinSteps), 8, 2048);
#else
      int countSteps = clamp(
        int(
          (
           (isinf(rayLength) && (all(greaterThanEqual(tTopSolutions, vec2(0.0))) || all(greaterThanEqual(tBottomSolutions, vec2(0.0)))) && all(lessThan(tGroundSolutions, vec2(0.0))))
          )
            ? mix(
                float(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.OuterSpaceRayMinSteps),
                float(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.OuterSpaceRayMaxSteps), 
                clamp(max(abs(dot(rayDirection, sideVector)), abs(dot(rayDirection, upVector)) * projectionVectorScale), 0.0, 1.0)
              )
            : mix(
                float(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.RayMinSteps), 
                float(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.RayMaxSteps), 
                clamp(max(abs(dot(rayDirection, sideVector)), abs(dot(rayDirection, upVector)) * projectionVectorScale), 0.0, 1.0)
              )
        ), 
        8, 
        2048
      );
#endif
        
      float density = 0.0;      
      float cloudTestDensity = 0.0;
      float previousSampledDensity = 0.0;
      int zeroDensitySampleCounter = 0;

      const float directScatteringIntensity = uAtmosphereParameters.atmosphereParameters.VolumetricClouds.DirectScatteringIntensity;
      const float indirectScatteringIntensity = uAtmosphereParameters.atmosphereParameters.VolumetricClouds.IndirectScatteringIntensity;
      const float ambientLightIntensity = uAtmosphereParameters.atmosphereParameters.VolumetricClouds.AmbientLightIntensity;

      // 0.61803398875 is the golden ratio conjugate for better distribution of the samples over time, since temporal aliasing is less noticeable than
      // spatial aliasing 
#if 1
      float offset = fract(texelFetch(uTextureBlueNoise, ivec2(threadPosition) & ivec2(1023), 0).x + (float(pushConstants.frameIndex) * 0.61803398875)); 
#else
      float offset = fract(bayer256(ivec2(threadPosition) & ivec2(1023)) + (float(pushConstants.frameIndex) * 0.61803398875)); 
#endif
    
      float rayPartLength = tMinMax.y - tMinMax.x,
            timeStep = rayPartLength / float(countSteps),
            time = fma(offset, timeStep, tMinMax.x);
                
      //float sunPhase = getSunPhase(rayDirection, sunDirection, -cloudsForwardScatteringG);

      const mat3 rotationMatrices[2] = mat3[2](
        quaternionToMatrix(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.Orientation),
        quaternionToMatrix(uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.Orientation)
      );
      
      for(int stepIndex = 0; (stepIndex < countSteps) && (time < tMinMax.y); stepIndex++){
    
        vec3 position = fma(rayDirection, vec3(time), rayOrigin);

/*      float height = length(position);

        if(height < uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight){

          // In cloud-free area, so we can skip the empty space and go directly to the beginning of the low cloud layer

          vec2 tSolutions = intersectSphere(position, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.StartHeight).xxxy);

          if((tSolutions.x < 0.0) && (tSolutions.y >= 0.0)){ 

            if((time += tSolutions.y) >= tMinMax.y){
              break;
            }

            position = fma(rayDirection, vec3(fma(offset, timeStep, time)), rayOrigin);

            zeroDensitySampleCounter = 0;                        

          }          

        }else if(height > uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight){

          // Above the clouds, so we can skip the empty space and go directly to the beginning of the high cloud layer

          vec2 tSolutions = intersectSphere(position, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.EndHeight).xxxy);

          if((tSolutions.x >= 0.0) && (tSolutions.y >= 0.0)){ 

            if((time += tSolutions.x) >= tMinMax.y){
              break;
            }

            position = fma(rayDirection, vec3(fma(offset, timeStep, time)), rayOrigin);

            zeroDensitySampleCounter = 0;                        

          }else{
            // We are above the clouds, so we can abort here, since we are not interested in the empty space above the clouds
            break;
          }          

        }else if((height > uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.EndHeight) &&
                 (height < uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.StartHeight)){

          // Above the low clouds and below the high clouds, so we can skip the empty space and go directly to the beginning 
          // of the high cloud layer or the end of the low cloud layer, whichever the case may be, depending on the ray direction 
          // situation

          // First try to intersect the beginning of high cloud layer (the first case to be tested, since the view is more likely to be from 
          // below the clouds at the most of the time)   

          vec2 tSolutions = intersectSphere(position, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.StartHeight).xxxy);

          if((tSolutions.x >= 0.0) && (tSolutions.y >= 0.0)){
            
            if((time += tSolutions.x) >= tMinMax.y){
              break;
            }

            position = fma(rayDirection, vec3(fma(offset, timeStep, time)), rayOrigin);

            zeroDensitySampleCounter = 0;                        

          }else{

            // Otherwise try to intersect the end of low cloud layer, when the previous intersection test failed

            vec2 tSolutions = intersectSphere(position, rayDirection, vec2(0.0, uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.EndHeight).xxxy); 

            if((tSolutions.x >= 0.0) && (tSolutions.y >= 0.0)){
            
              if((time += tSolutions.x) >= tMinMax.y){
                break;
              }
              
              position = fma(rayDirection, vec3(fma(offset, timeStep, time)), rayOrigin);

              zeroDensitySampleCounter = 0;                        

            }

          }

        }*/

        vec4 weatherData = getWeatherData(position, rotationMatrices, mipMapLevel);
        
        float density;
        if(max(weatherData.x, weatherData.w) > 1e-4){
          density = getLowResCloudDensity(position, rotationMatrices, layerLowWindRotation, weatherData, mipMapLevel);
        }else{
          density = 0.0;
        }
        
        if(density > 1e-4){
        
          if(zeroDensitySampleCounter > 0){
            // Go one step back so that we don't miss the cloud edge as much as possible, since we did double-sized steps in the previous iterations
            zeroDensitySampleCounter = 0;                        
            weatherData = getWeatherData(position = fma(rayDirection, vec3(time -= timeStep), rayOrigin), rotationMatrices, mipMapLevel);
            if(max(weatherData.x, weatherData.w) > 1e-4){
              density = getLowResCloudDensity(position, rotationMatrices, layerLowWindRotation, weatherData, mipMapLevel);
            }else{
              // If we still have no density, we can skip this step and continue with the next hopefully real one
              time += timeStep;          
              continue;
            }
          }            
        
          vec3 curlOffsetVector = decodeCURL(
            textureLod(
              uTextureCurlNoise,
              scaleLayerLowCloudPosition((layerLowWindRotation * (rotationMatrices[0] * position)) * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.AdvanceCurlScale),
              mipMapLevel).xyz
          ) * 
            (1.0 * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.Scale) * 
            uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerLow.AdvanceCurlAmplitude *
            1.0;
                                                          
          density = getHighResCloudDensity(position, rotationMatrices, layerLowWindRotation, curlOffsetVector, weatherData, density, mipMapLevel);  

          const bool isLowClouds = (length(position) < uAtmosphereParameters.atmosphereParameters.VolumetricClouds.LayerHigh.StartHeight);
          if(isLowClouds){
            density *= getWeatherDensity(weatherData);  
          }

          density *= uAtmosphereParameters.atmosphereParameters.VolumetricClouds.ViewDensity * uAtmosphereParameters.atmosphereParameters.VolumetricClouds.DensityScale;
          
          if(density > 1e-4){
          
#ifdef SHADOWMAP

            float extinctionCoefficient = max(1e-10, density);

            transmittance *= exp(-extinctionCoefficient * timeStep * extinction);     

            weightedDepth += vec2(length(position - rayOrigin), 1.0) * density; //min(transmittance.x, min(transmittance.y, transmittance.z)); 

#else

            float heightFraction = getHeightFractionForPoint(position);

            float scatteringCoefficient = density;
            float extinctionCoefficient = max(1e-10, density);

            float sunLightTerm = max(0.0, dot(normalize(position), toSunDirection));
            
            float densityAlongCone = sampleCloudDensityAlongCone(
              position, 
              toSunDirection, 
              uAtmosphereParameters.atmosphereParameters.VolumetricClouds.DensityAlongConeLength,
              uAtmosphereParameters.atmosphereParameters.VolumetricClouds.DensityAlongConeLengthFarMultiplier, 
              any(greaterThan(transmittance, vec3(0.3))), 
              mipMapLevel,
              rotationMatrices
            );  
//          float shadowTowardsLight = sampleShadow(position, toSunDirection, any(greaterThan(transmittance, vec3(0.3))), mipMapLevel);  
  
            float lightEnergy = beerTerm(densityAlongCone * timeStep) * 
                                powderTerm(density * timeStep, cosAngle) *             
                                sunLightTerm *
#if 0
                                fma(max(forwardScatteringPhase, backwardScatteringPhase), 0.07, 0.8) *
#else                                
                                fma(mix(forwardScatteringPhase, backwardScatteringPhase, 0.5), 1.0, 0.0) *
#endif                                                                
                                2.0;
                                
            vec3 directScatting = vec3(lightEnergy) * sunColor * directScatteringIntensity;
            
            // Fake multiple scattering 
            vec3 indirectScattering = clamp(pow(3.0 * scatteringCoefficient, 0.5), 0.7, 1.0) *
                                      (textureLod(uTextureSkyLuminanceLUT, normalize(position), 0.0).xyz * ambientLightIntensity) * 
                                      beerTerm(density) *
                                      //sunLightTerm *
                                      indirectScatteringIntensity *
                                      vec3(1.0);
            
            vec3 sampledScattering = (directScatting + indirectScattering) * scatteringCoefficient;

            if(isLowClouds){
              // Apply wetness weather luminance to the low clouds, not to the high clouds
              sampledScattering *= getWeatherLuminance(weatherData);
            }                        
                                       
            weightedDepth += vec2(length(position - rayOrigin), 1.0) * density; //min(transmittance.x, min(transmittance.y, transmittance.z)); 
                                                             
#if 1
            // See slide 28 at http://www.frostbite.com/2015/08/physically-based-unified-volumetric-rendering-in-frostbite/
            vec3 sampledExtinction = max(vec3(1e-10), density * extinction);
            vec3 sampledTransmittance = exp(-sampledExtinction * timeStep);
            vec3 integratedSampledScattering = (sampledScattering - (sampledScattering * sampledTransmittance)) / sampledExtinction;
            inscattering += transmittance * integratedSampledScattering;
            transmittance *= sampledTransmittance;     
#else        
            inscattering += transmittance * sampledScattering * ((1.0 - exp(-(extinctionCoefficient * timeStep))) / extinctionCoefficient);
            transmittance *= exp(-extinctionCoefficient * timeStep * extinction);     
#endif      
              
#if 0
            inscattering += sampleScattering * 
                            scatteringCoefficient *
                            ((1.0 - exp(-(extinctionCoefficient * timeStep))) / extinctionCoefficient) *
                            transmittance * 
                            1.0;       
            transmittance *= exp(-extinctionCoefficient * timeStep);
#endif
            
#endif

            if(all(lessThan(transmittance, vec3(1e-4)))){
              break;
            }
                   
          }
         
          zeroDensitySampleCounter = 0;

          time += timeStep;          
         
        }else{

          zeroDensitySampleCounter++;
          
          time += timeStep * 2.0;  
         
        }                                                          
        
        
      }  
      
    }
    
  }
  
  depth = (weightedDepth.y > 0.0) ? (weightedDepth.x / weightedDepth.y) : uintBitsToFloat(0x7f800000u); 

  return weightedDepth.y > 0.0;

}

void main(){

  layerLowWindRotation = layerLowCurlRotation = mat3(1.0);

#ifdef COMPUTE_SHADER
  int viewIndex = pushConstants.baseViewIndex;
#else
  int viewIndex = pushConstants.baseViewIndex + int(gl_ViewIndex);
#endif
  View view = uView.views[viewIndex];

/*vec2 pixPos = vec2(gl_FragCoord.xy) + vec2(0.5);
  vec2 uv = pixPos / pushConstants.resolution;*/

#ifdef COMPUTE_SHADER
  ivec2 xy = ivec2(gl_GlobalInvocationID.xy);
  ivec2 texSize = ivec2(imageSize(uDestinationTexture).xy);
  if(any(lessThanEqual(xy, ivec2(0))) || any(greaterThanEqual(xy, texSize))){
    return;
  }

  vec2 uv = (vec2(xy) + vec2(0.5)) / vec2(texSize);
#else
  vec2 uv = inTexCoord; 
#endif

  vec3 worldPos, worldDir;
  GetCameraPositionDirection(worldPos, worldDir, view.viewMatrix, view.projectionMatrix, view.inverseViewMatrix, view.inverseProjectionMatrix, uv);
  
  worldPos = (uAtmosphereParameters.atmosphereParameters.inverseTransform * vec4(worldPos, 1.0)).xyz;
  worldDir = normalize((uAtmosphereParameters.atmosphereParameters.inverseTransform * vec4(worldDir, 0.0)).xyz);

  projectionVectorScale = length(vec2(length(view.projectionMatrix[0].xyz), length(view.projectionMatrix[1].xyz)));

  sideVector = normalize(view.inverseViewMatrix[0].xyz); 

  upVector = normalize(view.inverseViewMatrix[1].xyz); 

#ifndef SHADOWMAP
#ifdef MSAA
  // At MSAA we must find the farthest depth value, since clouds are rendered without MSAA but applied to the opaque pass content with MSAA,
  // so we must find the farthest depth value to avoid or at least minimize artifacts at the merging stage.
  float depthBufferValue;
  if((pushConstants.flags & PUSH_CONSTANT_FLAG_REVERSE_DEPTH) != 0u){
    depthBufferValue = uintBitsToFloat(0x7f800000u); // +inf as marker for the farthest depth value, so the minimum value is always less than this
    for(int sampleIndex = 0; sampleIndex < pushConstants.countSamples; sampleIndex++){
#ifdef MULTIVIEW
      float depthValue = texelFetch(uDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), sampleIndex).x;
#else
      float depthValue = texelFetch(uDepthTexture, ivec2(gl_FragCoord.xy), sampleIndex).x;
#endif
/*    if((depthValue > 0.0) && (depthValue < depthBufferValue)){
        depthBufferValue = depthValue;
      }*/
      depthBufferValue = min(depthBufferValue, depthValue);
    }
    if(isinf(depthBufferValue)){
      // Replace +inf with 0.0 with the real farthest depth value 
      depthBufferValue = 0.0;
    }
  }else{
    depthBufferValue = uintBitsToFloat(0xff800000u); // -inf as marker for the farthest depth value, so the maximum value is always greater than this
    for(int sampleIndex = 0; sampleIndex < pushConstants.countSamples; sampleIndex++){
#ifdef MULTIVIEW
      float depthValue = texelFetch(uDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), sampleIndex).x;
#else
      float depthValue = texelFetch(uDepthTexture, ivec2(gl_FragCoord.xy), sampleIndex).x;
#endif
/*    if((depthValue < 1.0) && (depthValue > depthBufferValue)){
        depthBufferValue = depthValue;
      }*/
      depthBufferValue = max(depthBufferValue, depthValue);
    }
    if(isinf(depthBufferValue)){
      // Replace -inf with 1.0 with the real farthest depth value
      depthBufferValue = 1.0;
    }
  }
#else
  // Without MSAA we can just use the depth value directly. Easy peasy. :-)
#ifdef MULTIVIEW
  float depthBufferValue = texelFetch(uDepthTexture, ivec3(ivec2(gl_FragCoord.xy), int(gl_ViewIndex)), 0).x;
#else
  float depthBufferValue = texelFetch(uDepthTexture, ivec2(gl_FragCoord.xy), 0).x;
#endif
#endif

#endif

  vec3 sunDirection = normalize(getSunDirection(uAtmosphereParameters.atmosphereParameters));

#ifdef SHADOWS
  lightDirection = -sunDirection;
#endif

#ifndef SHADOWMAP
  bool depthIsZFar = depthBufferValue == GetZFarDepthValue(view.projectionMatrix);

  if(depthIsZFar){
    depthBufferValue = uintBitsToFloat(0x7f800000u); // +inf
  }else{
    vec4 t = view.inverseProjectionMatrix * vec4(fma(uv, vec2(2.0), vec2(-1.0)), depthBufferValue, 1.0);
    depthBufferValue = -(t.z / t.w);
  }
#endif

#ifdef SHADOWMAP
  
  float depth;
 if(traceVolumetricClouds(worldPos, 
                          worldDir, 
#ifdef COMPUTE_SHADER
                          ivec2(gl_GlobalInvocationID.xy),
#else
                          ivec2(gl_FragCoord), 
#endif
                          depth)){
    vec4 clipSpace = view.projectionMatrix * view.viewMatrix * vec4(fma(worldDir, vec3(depth), worldPos), 1.0);
    depth = clamp(clipSpace.z / clipSpace.w, 0.0, 1.0); // 0.0 .. 1.0 range 
  }else{
    depth = 1.0;
  }
#ifdef COMPUTE_SHADER
  imageStore(uDestinationTexture, ivec2(gl_GlobalInvocationID.xy), encodeMSM16BitCoefficients(depth));
#else  
  outMSMCoefficients = encodeMSM16BitCoefficients(depth);
#endif  

#else

  vec3 inscattering, transmittance;
  float depth;
  if(uAtmosphereParameters.atmosphereParameters.AbsorptionExtinction.w > 0.0){
    if(!traceVolumetricClouds(worldPos, worldDir, depthBufferValue, ivec2(gl_FragCoord), inscattering, transmittance, depth)){
      discard;
    }
  }else{
    discard;
  }

  float alpha = 1.0 - clamp(dot(transmittance, vec3(1.0 / 3.0)), 0.0, 1.0);
  outInscattering = vec4(clamp(inscattering, vec3(0.0), vec3(65504.0)), alpha); // clamp to 16-bit floating point range
  outTransmittance = vec4(clamp(transmittance, vec3(0.0), vec3(1.0)), alpha); // clamp to normalized range
  outDepth = depth;

#endif

}