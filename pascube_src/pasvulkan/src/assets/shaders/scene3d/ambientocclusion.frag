#version 460 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_viewport_layer_array : enable
#extension GL_GOOGLE_include_directive : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec2 oFragOcclusionDepth;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

#ifdef RAYTRACING
  #extension GL_EXT_buffer_reference : enable
  #extension GL_EXT_nonuniform_qualifier : enable
  #include "bufferreference_definitions.glsl"
  #include "globaldescriptorset.glsl"
  #define SET_INDEX 1
#else
  #define SET_INDEX 0  
#endif

layout(set = SET_INDEX, binding = 0, std140) uniform uboViews {
  View views[256]; // 65536 / (64 * 4) = 256
} uView;

#ifdef MULTIVIEW
layout(set = SET_INDEX, binding = 1) uniform sampler2DArray uTextureDepth;
#else
layout(set = SET_INDEX, binding = 1) uniform sampler2D uTextureDepth;
#endif

/*#ifdef MULTIVIEW
layout(set = SET_INDEX, binding = 2) uniform sampler2DArray uTextureLinearDepth;
#else
layout(set = SET_INDEX, binding = 2) uniform sampler2D uTextureLinearDepth;
#endif*/

layout (push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint frameIndex;
} pushConstants;

/* clang-format on */

float viewIndex = float(int(gl_ViewIndex));

#ifdef RAYTRACING
mat4 viewMatrix = uView.views[int(pushConstants.viewBaseIndex) + int(gl_ViewIndex)].viewMatrix;
mat4 inverseViewMatrix = uView.views[int(pushConstants.viewBaseIndex) + int(gl_ViewIndex)].inverseViewMatrix;
#endif

mat4 projectionMatrix = uView.views[int(pushConstants.viewBaseIndex) + int(gl_ViewIndex)].projectionMatrix;
mat4 inverseProjectionMatrix = uView.views[int(pushConstants.viewBaseIndex) + int(gl_ViewIndex)].inverseProjectionMatrix;

#ifdef RAYTRACING
mat4 viewProjectionMatrix = projectionMatrix * viewMatrix;
mat4 inverseViewProjectionMatrix = inverseViewMatrix * inverseProjectionMatrix;
#endif

float linearizeDepth(float z){
#if 0
  vec2 v = (inverseProjectionMatrix * vec4(vec3(fma(inTexCoord, vec2(2.0), vec2(-1.0)), z), 1.0)).zw;
#else
  vec2 v = fma(inverseProjectionMatrix[2].zw, vec2(z), inverseProjectionMatrix[3].zw);
#endif
  return v.x / v.y;
}

float delinearizeDepth(float z){
#if 0
  vec2 v = (projectionMatrix * vec4(vec3(fma(inTexCoord, vec2(2.0), vec2(-1.0)), z), 1.0)).zw;
#else
  vec2 v = fma(projectionMatrix[2].zw, vec2(z), inverseProjectionMatrix[3].zw);
#endif
  return v.x / v.y;
}

vec3 fetchPosition(vec2 texCoord) {
#ifdef MULTIVIEW
  vec4 position = inverseProjectionMatrix * vec4(vec3(fma(texCoord, vec2(2.0), vec2(-1.0)), textureLod(uTextureDepth, vec3(texCoord, viewIndex), 0).x), 1.0);
#else
  vec4 position = inverseProjectionMatrix * vec4(vec3(fma(texCoord, vec2(2.0), vec2(-1.0)), textureLod(uTextureDepth, texCoord, 0).x), 1.0);
#endif
  return position.xyz / position.w;
}

#ifdef RAYTRACING
vec3 fetchWorldPosition(vec2 texCoord) {
#ifdef MULTIVIEW
  vec4 position = inverseViewProjectionMatrix * vec4(vec3(fma(texCoord, vec2(2.0), vec2(-1.0)), textureLod(uTextureDepth, vec3(texCoord, viewIndex), 0).x), 1.0);
#else
  vec4 position = inverseViewProjectionMatrix * vec4(vec3(fma(texCoord, vec2(2.0), vec2(-1.0)), textureLod(uTextureDepth, texCoord, 0).x), 1.0);
#endif
  return position.xyz / position.w;
}

vec3 getWorldPosition(vec2 texCoord, float depth) {
  vec4 position = inverseViewProjectionMatrix * vec4(vec3(fma(texCoord, vec2(2.0), vec2(-1.0)), depth), 1.0);
  return position.xyz / position.w;
}
#endif

vec3 fetchPositionLod(vec2 texCoord, float lod) {
#ifdef MULTIVIEW
  vec4 position = inverseProjectionMatrix * vec4(vec3(fma(texCoord, vec2(2.0), vec2(-1.0)), textureLod(uTextureDepth, vec3(texCoord, viewIndex), lod).x), 1.0);
#else
  vec4 position = inverseProjectionMatrix * vec4(vec3(fma(texCoord, vec2(2.0), vec2(-1.0)), textureLod(uTextureDepth, texCoord, lod).x), 1.0);
#endif
  return position.xyz / position.w;
}

float hash12(vec2 p){
  vec3 p3  = fract(vec3(p.xyx) * vec3(0.1031, 0.11369, 0.13787));
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p){
  vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.11369, 0.13787));
  p3 += dot(p3, p3.yzx+19.19);
  return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

vec3 hash33(vec3 p) {
  vec3 p3 = fract(p.xyz * vec3(443.8975, 397.2973, 491.1871));
  p3 += dot(p3, p3.yxz + 19.19);
  return fract(vec3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

#include "adjugate.glsl"

#ifdef RAYTRACING
  #include "raytracing.glsl"
  #include "tangentspacebasis.glsl"
  #include "pcg.glsl"

vec2 Hammersley(const in int index, const in int numSamples) {
#if 1
  return vec2(fract(float(index) / float(numSamples)), float(bitfieldReverse(uint(index))) * 2.3283064365386963e-10);
#else
  uint reversedIndex = uint(index);
  reversedIndex = (reversedIndex << 16u) | (reversedIndex >> 16u);
  reversedIndex = ((reversedIndex & 0x00ff00ffu) << 8u) | ((reversedIndex & 0xff00ff00u) >> 8u);
  reversedIndex = ((reversedIndex & 0x0f0f0f0fu) << 4u) | ((reversedIndex & 0xf0f0f0f0u) >> 4u);
  reversedIndex = ((reversedIndex & 0x33333333u) << 2u) | ((reversedIndex & 0xccccccccu) >> 2u);
  reversedIndex = ((reversedIndex & 0x55555555u) << 1u) | ((reversedIndex & 0xaaaaaaaau) >> 1u);
  return vec2(fract(float(index) / float(numSamples)), float(reversedIndex) * 2.3283064365386963e-10);
#endif
}

mat3 generateTBN(const in vec3 normal) {
  vec3 bitangent = (1.0 - abs(dot(normal, vec3(0.0, 1.0, 0.0))) <= 1e-7) ? vec3(0.0, 0.0, (dot(normal, vec3(0.0, 1.0, 0.0)) > 0.0) ? 1.0 : -1.0) : vec3(0.0, 1.0, 0.0);
  vec3 tangent = normalize(cross(bitangent, normal));
  return mat3(tangent, cross(normal, tangent), normal);
}

vec3 sampleHemisphere(vec2 xi){
  return vec3(sin(vec2(xi.y * 6.283185307179586) + vec2(1.57079632679489661923, 0.0)) * sqrt(1.0 - (xi.x * xi.x)), xi.x);
}

#endif

#define SSAO 0
#define SPIRALAO 1
#define GTAO 2
#define METHOD SSAO

#if METHOD == SPIRALAO

// Spiral AO

const int SAMPLES = 16;
const float INTENSITY = 0.5;
const float SCALE = 2.5;
const float BIAS = 0.05;
const float AO_RADIUS = 2.0;
const float MAX_DISTANCE = 0.125;

float spiralAO(const in vec2 texCoord, const in vec3 viewPosition, const in vec3 viewNormal, float rotationAmount){
  vec4 samplePositionSpiral = vec4(
    hash12(texCoord * 100.0) * 6.283185307179586, // angle
    0.0,                                          // radius
    2.399963229728653,                            // delta angle, PI * (3.0 - sqrt(5.0)) (golden angle)  #
    rotationAmount / float(SAMPLES)               // delta radius
  );
  float occlusion = 0.0;
  for(int sampleIndex = 0; sampleIndex < SAMPLES; sampleIndex++){
    vec3 diff = fetchPosition(texCoord + sin(vec2(samplePositionSpiral.xx) + vec2(0.0, 1.57079632679489661923)) * samplePositionSpiral.y) - viewPosition;
    float l = length(diff);
    occlusion += max(0.0, dot(viewNormal, diff / l) - BIAS) * (1.0 / (1.0 + (l * SCALE))) * smoothstep(MAX_DISTANCE, MAX_DISTANCE * 0.5, l);
    samplePositionSpiral.xy += samplePositionSpiral.zw; 
  }
  return occlusion / float(SAMPLES);
}

void main(){

#ifdef MULTIVIEW
  vec3 texCoord = vec3(inTexCoord, float(gl_ViewIndex));
#else
  vec2 texCoord = inTexCoord;
#endif
  
  vec3 position = fetchPosition(texCoord.xy);
  
  float depth = position.z;
  
  float occlusion = 0.0;

  if (isinf(depth) || (abs(depth) < 1e-7)) {
    
    occlusion = 1.0;

  } else {

    vec3 viewNormal;
#if 1
    {
      vec2 texelSize = vec2(dFdx(texCoord.x), dFdy(texCoord.y));
#ifdef MULTIVIEW
      vec3 offsetH = vec3(texelSize.x, 0.0, 0.0);
      vec3 offsetV = vec3(0.0, texelSize.y, 0.0);
#else
      vec2 offsetH = vec2(texelSize.x, 0.0);
      vec2 offsetV = vec2(0.0, texelSize.y);
#endif
      vec3 pl = fetchPosition(texCoord.xy - (offsetH.xy * 1.0));
      vec3 pr = fetchPosition(texCoord.xy + (offsetH.xy * 1.0));
      vec3 pu = fetchPosition(texCoord.xy - (offsetV.xy * 1.0));
      vec3 pd = fetchPosition(texCoord.xy + (offsetV.xy * 1.0));
      vec4 H = vec4(                                                                   //
          pl.z,                                                                        //
          pr.z,                                                                        //
          linearizeDepth(textureLod(uTextureDepth, texCoord - (offsetH * 2.0), 0).x),  //
          linearizeDepth(textureLod(uTextureDepth, texCoord + (offsetH * 2.0), 0).x)   //
      );
      vec4 V = vec4(                                                                   //
          pu.z,                                                                        //
          pd.z,                                                                        //
          linearizeDepth(textureLod(uTextureDepth, texCoord - (offsetV * 2.0), 0).x),  //
          linearizeDepth(textureLod(uTextureDepth, texCoord + (offsetV * 2.0), 0).x)   //
      );
      vec4 hve = abs((vec4(H.xy * H.zw, V.xy * V.zw) / fma(vec4(H.zw, V.zw), vec4(2.0), -vec4(H.xy, V.xy))) - vec4(depth));
      viewNormal = -(cross((hve.x < hve.y) ? (position - pl) : (pr - position), (hve.z < hve.w) ? (position - pu) : (pd - position)));
      viewNormal = (length(viewNormal) < 1e-6) ? vec3(0.0, 0.0, -1.0) : normalize(viewNormal);
    }
#else
    viewNormal = -cross(dFdx(position), dFdy(position));
    viewNormal = (length(viewNormal) < 1e-6) ? vec3(0.0, 0.0, -1.0) : normalize(viewNormal);
#endif

    vec2 viewSize = textureSize(uTextureDepth, 0).xy;
    
    vec2 inverseViewSize = vec2(1.0) / viewSize;
    
    occlusion = clamp(1. - (spiralAO(inTexCoord, 
                                     position, 
                                     viewNormal, 
                                     (AO_RADIUS * projectionMatrix[1][1] * (0.25 * inverseViewSize.y)) / max(1e-6, abs(position.z))) * 
                               INTENSITY), 
                      0.0, 
                      1.0);

  }
  oFragOcclusionDepth = vec2(occlusion, depth);
}

#elif METHOD == GTAO

// GTAO

const float AO_RADIUS = 2.0;
const int NUM_STEPS = 8;
const int NUM_ROTATIONS = 4;
const int NUM_OFFSETS = 1;
const float LOD_BIAS = 0.5;

float Falloff(float dist2, float cosh){
  const float FALLOFF_START2	= 0.16;
  const float FALLOFF_END2 = 4.0;
  return 2.0 * clamp((dist2 - FALLOFF_START2) / (FALLOFF_END2 - FALLOFF_START2), 0.0, 1.0);
}

const vec2 SPATIAL_NOISE[4][4] = {
  { 
    vec2(0.0625* 0, 0.25*0), 
    vec2(0.0625* 4, 0.25*1), 
    vec2(0.0625* 8, 0.25*2), 
    vec2(0.0625*12, 0.25*3) 
  },
  { 
    vec2(0.0625* 5, 0.25*3), 
    vec2(0.0625* 9, 0.25*0), 
    vec2(0.0625*13, 0.25*1), 
    vec2(0.0625* 1, 0.25*2) 
  },
  {
     vec2(0.0625*10, 0.25*2), 
     vec2(0.0625*14, 0.25*3), 
     vec2(0.0625* 2, 0.25*0), 
     vec2(0.0625* 6, 0.25*1) 
  },
  { 
    vec2(0.0625*15, 0.25*1), 
    vec2(0.0625* 3, 0.25*2), 
    vec2(0.0625* 7, 0.25*3), 
    vec2(0.0625*11, 0.25*0) 
  }
};

const float TEMPORAL_NOISE[8] = float[8]( 0.0, 0.5, 0.25, 0.75, 0.125, 0.375, 0.625, 0.875 );

vec2 viewSize = textureSize(uTextureDepth, 0).xy;
vec2 inverseViewSize = vec2(1.0) / viewSize;

float getHorizonSample(vec3 viewPosition, vec3 viewDirection, float lod, vec2 sampleOffset, float closest){
  vec3 ws = fetchPositionLod((vec2(gl_FragCoord.xy) + sampleOffset) * inverseViewSize, lod) - viewPosition;
  float dist2 = dot(ws, ws);
  float cosH = dot(ws, viewDirection) * inversesqrt(dist2);
  float falloff = clamp(dist2 / (0.25 * AO_RADIUS * AO_RADIUS), 0.0, 1.0);
  float foCosH = mix(cosH, closest, falloff);
  return foCosH > closest ? foCosH : mix(foCosH, closest, 0.8);
}

void main(){

#ifdef MULTIVIEW
  vec3 texCoord = vec3(inTexCoord, viewIndex);
#else
  vec2 texCoord = inTexCoord;
#endif
  
  vec3 position = fetchPosition(texCoord.xy);
  
  float depth = position.z;
  
  float occlusion = 0.0;

  if (isinf(depth) || (abs(depth) < 1e-7)) {
    
    occlusion = 1.0;

  } else {

    vec3 viewNormal;
#if 1
    {
      vec2 texelSize = vec2(dFdx(texCoord.x), dFdy(texCoord.y));
#ifdef MULTIVIEW
      vec3 offsetH = vec3(texelSize.x, 0.0, 0.0);
      vec3 offsetV = vec3(0.0, texelSize.y, 0.0);
#else
      vec2 offsetH = vec2(texelSize.x, 0.0);
      vec2 offsetV = vec2(0.0, texelSize.y);
#endif
      vec3 pl = fetchPosition(texCoord.xy - (offsetH.xy * 1.0));
      vec3 pr = fetchPosition(texCoord.xy + (offsetH.xy * 1.0));
      vec3 pu = fetchPosition(texCoord.xy - (offsetV.xy * 1.0));
      vec3 pd = fetchPosition(texCoord.xy + (offsetV.xy * 1.0));
      vec4 H = vec4(                                                                   //
          pl.z,                                                                        //
          pr.z,                                                                        //
          linearizeDepth(textureLod(uTextureDepth, texCoord - (offsetH * 2.0), 0).x),  //
          linearizeDepth(textureLod(uTextureDepth, texCoord + (offsetH * 2.0), 0).x)   //
      );
      vec4 V = vec4(                                                                   //
          pu.z,                                                                        //
          pd.z,                                                                        //
          linearizeDepth(textureLod(uTextureDepth, texCoord - (offsetV * 2.0), 0).x),  //
          linearizeDepth(textureLod(uTextureDepth, texCoord + (offsetV * 2.0), 0).x)   //
      );
      vec4 hve = abs((vec4(H.xy * H.zw, V.xy * V.zw) / fma(vec4(H.zw, V.zw), vec4(2.0), -vec4(H.xy, V.xy))) - vec4(depth));
      viewNormal = -(cross((hve.x < hve.y) ? (position - pl) : (pr - position), (hve.z < hve.w) ? (position - pu) : (pd - position)));
      viewNormal = (length(viewNormal) < 1e-6) ? vec3(0.0, 0.0, -1.0) : normalize(viewNormal);
    }
#else
    viewNormal = -cross(dFdx(position), dFdy(position));
    viewNormal = (length(viewNormal) < 1e-6) ? vec3(0.0, 0.0, -1.0) : normalize(viewNormal);
#endif

    vec3 viewPosition = position;
    
    vec3 viewDirection = normalize(-viewPosition); 

    float pixelScale = projectionMatrix[1][1] * (0.25 * inverseViewSize.y);

    float radius = max((AO_RADIUS * pixelScale) / abs(viewPosition.z), NUM_STEPS * 1.415);
    float stepSize = radius / float(NUM_STEPS);

    float lod = min(floor(log2(stepSize / (4.0 * float(NUM_STEPS)))) + LOD_BIAS, floor(log2(min(viewSize.x, viewSize.y))) + 1.0);

    vec2 noises = SPATIAL_NOISE[uint(gl_FragCoord.y) & 3u][uint(gl_FragCoord.x) & 3u];

    float noiseRotation = noises.x / float(NUM_ROTATIONS);
    float noiseOffset = noises.y / float(NUM_OFFSETS);

    for(int rotationIndex = 0; rotationIndex < NUM_ROTATIONS; rotationIndex++){

      float rotation = (noiseRotation + TEMPORAL_NOISE[rotationIndex]) * 3.1415926535897932384626433832795;

      for(int offsetIndex = 0; offsetIndex < NUM_OFFSETS; offsetIndex++){

        float offset = (noiseOffset + TEMPORAL_NOISE[offsetIndex]) * stepSize;

        const float HALF_PI = 1.570796327;

        vec2 sampleDirection = sin(vec2(rotation) + vec2(HALF_PI, 0.0));

        vec2 horizons = vec2(-1.0, -1.0);
        float sampleDist = (1.0 + stepSize) - offset;

        for(int stepIndex = 0; stepIndex < NUM_STEPS; stepIndex++){
            const vec2 sampleOffset = sampleDirection * sampleDist;
            horizons.x = getHorizonSample(viewPosition, viewDirection, lod, sampleOffset, horizons.x);
            horizons.y = getHorizonSample(viewPosition, viewDirection, lod, -sampleOffset, horizons.y);
            sampleDist += stepSize;
        }

        horizons = acos(horizons);

        vec3 bitangent = normalize(cross(vec3(sampleDirection, 0.0), viewDirection));
        vec3 tangent = cross(viewDirection, bitangent);
        vec3 projectedNormal = viewNormal - (bitangent * dot(viewNormal, bitangent));

        float nnx       = length(projectedNormal);
        float invnnx    = 1.0 / (nnx + 1e-6);
        float cosxi     = dot(projectedNormal, tangent) * invnnx; // xi = gamma + HALF_PI
        float gamma     = acos(cosxi) - HALF_PI;
        float cosgamma  = dot(projectedNormal, viewDirection) * invnnx;
        float singamma2 = -2.0 * cosxi; // cos(x + HALF_PI) = -sin(x)

        horizons = vec2(gamma) + vec2(max(-horizons.x - gamma, -HALF_PI), min(horizons.y - gamma, HALF_PI));

        occlusion += nnx * 0.25 * (
          (horizons.x * singamma2 + cosgamma - cos(2.0 * horizons.x - gamma)) +
          (horizons.y * singamma2 + cosgamma - cos(2.0 * horizons.y - gamma))
        );
            
      }

    }
    
    occlusion /= float(NUM_ROTATIONS * NUM_OFFSETS);

  }
  oFragOcclusionDepth = vec2(occlusion, depth);
}

#else

// SSAO

vec3 signedOctDecode(vec3 normal) {
  vec2 outNormal;
  outNormal = vec2(normal.xx + vec2(-normal.y, normal.y - 1.0));
  return normalize(vec3(outNormal, fma(normal.z, 2.0, -1.0) * (1.0 - (abs(outNormal.x) + abs(outNormal.y)))));
}

#if 1
// Sample points generated using a Halton sequence, which is a low-discrepancy sequence, where low count of samples is already often
// enough to get good results in the most cases. The samples are generated in a hemisphere oriented along the z-axis. 
#define NUM_SAMPLES 16
#include "ambientocclusion_samples.glsl"
const float radius = 0.5;
const float bias = 1e-3; // should be enough to prevent self occlusion in the most cases
const float strength = 1.0; // full strength for now
const int stepKernelSamples = 1;
#else
const int countKernelSamples = 64;
const vec4 kernelSamples[64] = vec4[64](                                     //
    vec4(0.04977, -0.04471, 0.04996, 1.0), vec4(0.01457, 0.01653, 0.00224, 1.0),     //
    vec4(-0.04065, -0.01937, 0.03193, 1.0), vec4(0.01378, -0.09158, 0.04092, 1.0),   //
    vec4(0.05599, 0.05979, 0.05766, 1.0), vec4(0.09227, 0.04428, 0.01545, 1.0),      //
    vec4(-0.00204, -0.0544, 0.06674, 1.0), vec4(-0.00033, -0.00019, 0.00037, 1.0),   //
    vec4(0.05004, -0.04665, 0.02538, 1.0), vec4(0.03813, 0.0314, 0.03287, 1.0),      //
    vec4(-0.03188, 0.02046, 0.02251, 1.0), vec4(0.0557, -0.03697, 0.05449, 1.0),     //
    vec4(0.05737, -0.02254, 0.07554, 1.0), vec4(-0.01609, -0.00377, 0.05547, 1.0),   //
    vec4(-0.02503, -0.02483, 0.02495, 1.0), vec4(-0.03369, 0.02139, 0.0254, 1.0),    //
    vec4(-0.01753, 0.01439, 0.00535, 1.0), vec4(0.07336, 0.11205, 0.01101, 1.0),     //
    vec4(-0.04406, -0.09028, 0.08368, 1.0), vec4(-0.08328, -0.00168, 0.08499, 1.0),  //
    vec4(-0.01041, -0.03287, 0.01927, 1.0), vec4(0.00321, -0.00488, 0.00416, 1.0),   //
    vec4(-0.00738, -0.06583, 0.0674, 1.0), vec4(0.09414, -0.008, 0.14335, 1.0),      //
    vec4(0.07683, 0.12697, 0.107, 1.0), vec4(0.00039, 0.00045, 0.0003, 1.0),         //
    vec4(-0.10479, 0.06544, 0.10174, 1.0), vec4(-0.00445, -0.11964, 0.1619, 1.0),    //
    vec4(-0.07455, 0.03445, 0.22414, 1.0), vec4(-0.00276, 0.00308, 0.00292, 1.0),    //
    vec4(-0.10851, 0.14234, 0.16644, 1.0), vec4(0.04688, 0.10364, 0.05958, 1.0),     //
    vec4(0.13457, -0.02251, 0.13051, 1.0), vec4(-0.16449, -0.15564, 0.12454, 1.0),   //
    vec4(-0.18767, -0.20883, 0.05777, 1.0), vec4(-0.04372, 0.08693, 0.0748, 1.0),    //
    vec4(-0.00256, -0.002, 0.00407, 1.0), vec4(-0.0967, -0.18226, 0.29949, 1.0),     //
    vec4(-0.22577, 0.31606, 0.08916, 1.0), vec4(-0.02751, 0.28719, 0.31718, 1.0),    //
    vec4(0.20722, -0.27084, 0.11013, 1.0), vec4(0.0549, 0.10434, 0.32311, 1.0),      //
    vec4(-0.13086, 0.11929, 0.28022, 1.0), vec4(0.15404, -0.06537, 0.22984, 1.0),    //
    vec4(0.05294, -0.22787, 0.14848, 1.0), vec4(-0.18731, -0.04022, 0.01593, 1.0),   //
    vec4(0.14184, 0.04716, 0.13485, 1.0), vec4(-0.04427, 0.05562, 0.05586, 1.0),     //
    vec4(-0.02358, -0.08097, 0.21913, 1.0), vec4(-0.14215, 0.19807, 0.00519, 1.0),   //
    vec4(0.15865, 0.23046, 0.04372, 1.0), vec4(0.03004, 0.38183, 0.16383, 1.0),      //
    vec4(0.08301, -0.30966, 0.06741, 1.0), vec4(0.22695, -0.23535, 0.19367, 1.0),    //
    vec4(0.38129, 0.33204, 0.52949, 1.0), vec4(-0.55627, 0.29472, 0.3011, 1.0),      //
    vec4(0.42449, 0.00565, 0.11758, 1.0), vec4(0.3665, 0.00359, 0.0857, 1.0),        //
    vec4(0.32902, 0.0309, 0.1785, 1.0), vec4(-0.08294, 0.51285, 0.05656, 1.0),       //
    vec4(0.86736, -0.00273, 0.10014, 1.0), vec4(0.45574, -0.77201, 0.00384, 1.0),    //
    vec4(0.41729, -0.15485, 0.46251, 1.0), vec4(-0.44272, -0.67928, 0.1865, 1.0)     //
);
const float radius = 0.5;
const float bias = 1e-3;
const float strength = 1.0;
const int stepKernelSamples = 4;
#endif

const float divKernelSamples = 1.0 / float(countKernelSamples / stepKernelSamples); 

void main() {
#ifdef MULTIVIEW
  vec3 texCoord = vec3(inTexCoord, viewIndex);
#else
  vec2 texCoord = inTexCoord;
#endif
#ifdef RAYTRACING

  float depth, occlusion;

#if 1

  bool reversedZ = projectionMatrix[2][3] < -1e-7;
  
  //bool infiniteFarPlane = reversedZ && ((abs(projectionMatrix[2][2]) < 1e-7) && (abs(projectionMatrix[3][2]) > 1e-7));

  vec4 nearPlane = vec4(fma(texCoord.xy, vec2(2.0), vec2(-1.0)), reversedZ ? 1.0 : 0.0, 1.0);

  vec4 cameraDirection = vec4((inverseProjectionMatrix * nearPlane).xyz, 0.0); 
      
/*vec4 primaryRayOrigin = inverseViewProjectionMatrix * vec4(fma(texCoord.xy, vec2(2.0), vec2(-1.0)), reversedZ ? 1.0 : 0.0, 1.0);
  primaryRayOrigin /= primaryRayOrigin.w;*/

  vec3 primaryRayOrigin = inverseViewMatrix[3].xyz;

  vec3 primaryRayDirection = normalize((inverseViewMatrix * cameraDirection).xyz);

#else

  vec3 primaryRayOrigin = inverseViewMatrix[3].xyz;
  
  vec3 primaryRayTarget = fetchWorldPosition(texCoord.xy);

  vec3 primaryRayDirection = normalize(primaryRayTarget.xyz - primaryRayOrigin.xyz);

#endif
 
  vec3 rayOrigin, worldNormal, worldFlatNormal;
  
  if(tracePrimaryBasicGeometryRay(primaryRayOrigin.xyz, primaryRayDirection.xyz, 0.0, 1000000.0, CULLMASK_OCCLUSION, rayOrigin, worldFlatNormal, worldNormal)){
  
#if 1
    vec3 randomVector = normalize(hash33(vec3(gl_FragCoord.xy, float(uint(pushConstants.frameIndex & 0xfffu)))) - vec3(0.5));

    vec3 worldTangent = normalize(randomVector - (worldNormal * dot(randomVector, worldNormal)));
    vec3 worldBitangent = cross(worldNormal, worldTangent);

    mat3 worldTBN = mat3(worldTangent, worldBitangent, worldNormal);
#else
    mat3 worldTBN = getTangentSpaceFromNormal(worldFlatNormal); 
#endif
  
    for (int i = 0; i < countKernelSamples; i += stepKernelSamples) {
//    vec3 rayDirection = normalize(worldTBN * sampleHemisphere(Hammersley(i, countKernelSamples)));
      vec3 rayDirection = normalize(worldTBN * kernelSamples[i].xyz);
      occlusion += smoothstep(0.0, 0.25, getRaytracedFastOcclusion(rayOrigin.xyz, worldFlatNormal, rayDirection, 0.0, radius, true, true));
    }
  
    occlusion = clamp(1.0 - (strength * (occlusion * divKernelSamples)), 0.0, 1.0);

    depth = length(rayOrigin.xyz - primaryRayOrigin.xyz);
  
  }else{
    occlusion = 1.0;      
    depth = uintBitsToFloat(0x7f800000u); // inf 
  }

#else
  vec3 position = fetchPosition(texCoord.xy);
  float depth = position.z;
  float occlusion = 0.0;
  if (isinf(depth) || (abs(depth) < 1e-7)) {
    occlusion = 1.0;
  } else {
    vec3 viewNormal;
#if 1
    {
      vec2 texelSize = vec2(dFdx(texCoord.x), dFdy(texCoord.y));
#ifdef MULTIVIEW
      vec3 offsetH = vec3(texelSize.x, 0.0, 0.0);
      vec3 offsetV = vec3(0.0, texelSize.y, 0.0);
#else
      vec2 offsetH = vec2(texelSize.x, 0.0);
      vec2 offsetV = vec2(0.0, texelSize.y);
#endif
      vec3 pl = fetchPosition(texCoord.xy - (offsetH.xy * 1.0));
      vec3 pr = fetchPosition(texCoord.xy + (offsetH.xy * 1.0));
      vec3 pu = fetchPosition(texCoord.xy - (offsetV.xy * 1.0));
      vec3 pd = fetchPosition(texCoord.xy + (offsetV.xy * 1.0));
      vec4 H = vec4(                                                                   //
          pl.z,                                                                        //
          pr.z,                                                                        //
          linearizeDepth(textureLod(uTextureDepth, texCoord - (offsetH * 2.0), 0).x),  //
          linearizeDepth(textureLod(uTextureDepth, texCoord + (offsetH * 2.0), 0).x)   //
      );
      vec4 V = vec4(                                                                   //
          pu.z,                                                                        //
          pd.z,                                                                        //
          linearizeDepth(textureLod(uTextureDepth, texCoord - (offsetV * 2.0), 0).x),  //
          linearizeDepth(textureLod(uTextureDepth, texCoord + (offsetV * 2.0), 0).x)   //
      );
      vec4 hve = abs((vec4(H.xy * H.zw, V.xy * V.zw) / fma(vec4(H.zw, V.zw), vec4(2.0), -vec4(H.xy, V.xy))) - vec4(depth));
      viewNormal = -(cross((hve.x < hve.y) ? (position - pl) : (pr - position), (hve.z < hve.w) ? (position - pu) : (pd - position)));
      viewNormal = (length(viewNormal) < 1e-6) ? vec3(0.0, 0.0, -1.0) : normalize(viewNormal);
    }
#else
    viewNormal = -cross(dFdx(position), dFdy(position));
    viewNormal = (length(viewNormal) < 1e-6) ? vec3(0.0, 0.0, -1.0) : normalize(viewNormal);
#endif
    vec3 randomVector = normalize(hash33(vec3(gl_FragCoord.xy, float(uint(pushConstants.frameIndex & 0xfffu)))) - vec3(0.5));
    vec3 viewTangent = normalize(randomVector - (viewNormal * dot(randomVector, viewNormal)));
    vec3 viewBitangent = cross(viewNormal, viewTangent);
    mat3 viewTBN = mat3(viewTangent, viewBitangent, viewNormal);
#ifdef RAYTRACING
    mat3 worldTBN = adjugate(inverseViewMatrix) * viewTBN;
#if 1
    vec3 rayOrigin = fetchWorldPosition(texCoord.xy); 
#else   
    vec4 rayOrigin = inverseViewMatrix * vec4(position.xyz, 1.0);
    rayOrigin.xyz /= rayOrigin.w;
#endif    
    for (int i = 0; i < countKernelSamples; i += stepKernelSamples) {
      vec3 rayDirection = normalize(worldTBN * kernelSamples[i].xyz);
      occlusion += getRaytracedFastOcclusion(rayOrigin.xyz, worldTBN[2], rayDirection, 0.01, radius, false, true);
    }
#else
    for (int i = 0; i < countKernelSamples; i += stepKernelSamples) {
      vec4 p = projectionMatrix * vec4(position.xyz + ((viewTBN * kernelSamples[i].xyz) * kernelSamples[i].w * radius), 1.0);
      p.xyz /= p.w;
      p.xy = fma(p.xy, vec2(0.5), vec2(0.5));
#ifdef MULTIVIEW
      float sampleDepth = linearizeDepth(textureLod(uTextureDepth, vec3(p.xy, viewIndex), 0).x);
#else
      float sampleDepth = linearizeDepth(textureLod(uTextureDepth, p.xy, 0).x);
#endif
      occlusion += (sampleDepth >= (depth + bias)) ? smoothstep(0.0, 1.0, radius / abs(depth - sampleDepth)) : 0.0;
    }
#endif // RAYTRACING
    occlusion = clamp(1.0 - (strength * (occlusion * divKernelSamples)), 0.0, 1.0);
  }
#endif // RAYTRACING
  oFragOcclusionDepth = vec2(occlusion, depth);
}
#endif 