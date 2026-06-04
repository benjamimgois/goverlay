#ifndef IBL_GLSL
#define IBL_GLSL

const float PI = 3.1415926535897932384626433832795;
const float INV_PI = 1.0 / PI;

#include "cubemap.glsl"

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

/*struct MicrofacetDistributionSample {
  float pdf;
  float cosTheta;
  float sinTheta;
  float phi;
};*/

#ifdef COMPUTESHADER
shared vec4 ImportanceSamples[1024]; // 16KiB
#endif

float D_GGX(const in float NdotH, const in float roughness) {
  float a = NdotH * roughness;
  float k = roughness / ((1.0 - (NdotH * NdotH)) + (a * a));
  return (k * k) * INV_PI;
}

// GGX microfacet distribution
// https://www.cs.cornell.edu/~srm/publications/EGSR07-btdf.html
// This implementation is based on https://bruop.github.io/ibl/,
//  https://www.tobias-franke.eu/log/2014/03/30/notes_on_importance_sampling.html
// and https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch20.html
/*MicrofacetDistributionSample GGX(const in vec2 xi, const in float roughness) {
  MicrofacetDistributionSample ggx;
  float alpha = roughness * roughness;
  ggx.cosTheta = clamp(sqrt((1.0 - xi.y) / (1.0 + (((alpha * alpha) - 1.0) * xi.y))), 0.0, 1.0);
  ggx.sinTheta = sqrt(1.0 - (ggx.cosTheta * ggx.cosTheta));
  ggx.phi = 2.0 * PI * xi.x;
  ggx.pdf = D_GGX(ggx.cosTheta, alpha) * 0.25;
  return ggx;
}*/

vec4 GGX(const in vec2 xi, const in float roughness) {
  vec4 ggx;
  float alpha = roughness * roughness;
  ggx.x = clamp(sqrt((1.0 - xi.y) / (1.0 + (((alpha * alpha) - 1.0) * xi.y))), 0.0, 1.0);
  ggx.y = sqrt(1.0 - (ggx.x * ggx.x));
  ggx.z = 2.0 * PI * xi.x;
  ggx.w = D_GGX(ggx.x, alpha) * 0.25;
  return ggx;
}

// Ashikhmin 2007, "Distribution-based BRDFs"
float D_Ashikhmin(const in float NdotH, const in float roughness) {
  float alpha = roughness * roughness;
  float a2 = alpha * alpha;
  float cos2h = NdotH * NdotH;
  float sin2h = 1.0 - cos2h;
  float sin4h = sin2h * sin2h;
  float cot2 = -cos2h / (a2 * sin2h);
  return (1.0 / (PI * ((4.0 * a2) + 1.0) * sin4h)) * ((4.0 * exp(cot2)) + sin4h);
}

float D_Charlie(float sheenRoughness, const in float NdotH) {
  sheenRoughness = max(sheenRoughness, 0.000001);  // clamp (0,1)
  float invR = 1.0 / sheenRoughness;
  float cos2h = NdotH * NdotH;
  float sin2h = 1.0 - cos2h;
  return (2.0 + invR) * pow(sin2h, invR * 0.5) / (2.0 * PI);
}

/*MicrofacetDistributionSample Charlie(const in vec2 xi, const in float roughness) {
  MicrofacetDistributionSample charlie;
  float alpha = roughness * roughness;
  charlie.sinTheta = pow(xi.y, alpha / ((2.0 * alpha) + 1.0));
  charlie.cosTheta = sqrt(1.0 - (charlie.sinTheta * charlie.sinTheta));
  charlie.phi = 2.0 * PI * xi.x;
  charlie.pdf = D_Charlie(alpha, charlie.cosTheta) * 0.25;
  return charlie;
}*/

vec4 Charlie(const in vec2 xi, const in float roughness) {
  vec4 charlie;
  float alpha = roughness * roughness;
  charlie.y = pow(xi.y, alpha / ((2.0 * alpha) + 1.0));
  charlie.x = sqrt(1.0 - (charlie.y * charlie.y));
  charlie.z = 2.0 * PI * xi.x;
  charlie.w = D_Charlie(alpha, charlie.x) * 0.25;
  return charlie;
}

/*MicrofacetDistributionSample Lambertian(const in vec2 xi, const in float roughness) {
  MicrofacetDistributionSample lambertian;
  lambertian.cosTheta = sqrt(1.0 - xi.y);
  lambertian.sinTheta = sqrt(xi.y);  // equivalent to `sqrt(1.0 - cosTheta*cosTheta)`;
  lambertian.phi = 2.0 * PI * xi.x;
  lambertian.pdf = lambertian.cosTheta * INV_PI;
  return lambertian;
}*/

vec4 Lambertian(const in vec2 xi, const in float roughness) {
  vec4 lambertian;
  lambertian.x = sqrt(1.0 - xi.y);
  lambertian.y = sqrt(xi.y);  // equivalent to `sqrt(1.0 - cosTheta*cosTheta)`;
  lambertian.z = 2.0 * PI * xi.x;
  lambertian.w = lambertian.x * INV_PI;
  return lambertian;
}

vec4 getImportanceSampleLambertian(const in int sampleIndex, const in int sampleCount, const in mat3 tbn, const in float roughness) {
  vec4 importanceSample = Lambertian(Hammersley(sampleIndex, sampleCount), roughness);
  return vec4(tbn *                                                                                                                    //
              normalize(vec3(vec2(cos(importanceSample.z), sin(importanceSample.z)) * importanceSample.y, importanceSample.x)),  //
              importanceSample.w                                                                                                                     //
  );
}

vec4 getImportanceSampleGGX(const in int sampleIndex, const in int sampleCount, const in mat3 tbn, const in float roughness) {
  vec4 importanceSample = GGX(Hammersley(sampleIndex, sampleCount), roughness);
  return vec4(tbn *                                                                                                                    //
              normalize(vec3(vec2(cos(importanceSample.z), sin(importanceSample.z)) * importanceSample.y, importanceSample.x)),  //
              importanceSample.w                                                                                                                     //
  );
}

vec4 getImportanceSampleCharlie(const in int sampleIndex, const in int sampleCount, const in mat3 tbn, const in float roughness) {
  vec4 importanceSample = Charlie(Hammersley(sampleIndex, sampleCount), roughness);
  return vec4(tbn *                                                                                                                    //
              normalize(vec3(vec2(cos(importanceSample.z), sin(importanceSample.z)) * importanceSample.y, importanceSample.x)),  //
              importanceSample.w                                                                                                                     //
  );
}

float computeLod(const in float pdf, const in int width, const in int sampleCount) {
  return 0.5 * log2((6.0 * (float(width) * float(width))) / (float(sampleCount) * pdf));  //
}

vec4 filterLambertian(const in samplerCube cubeMap, const in vec3 N, const in int sampleCount, const in float roughness) {
  vec4 result = vec4(0.0);
  float lodBias = 0.0;
  int width = int(textureSize(cubeMap, 0).x); 
  mat3 tbn = generateTBN(N);
  for (int i = 0; i < sampleCount; i++) {
#ifdef COMPUTESHADER
    vec4 importanceSample = ImportanceSamples[i];
    importanceSample = vec4(tbn * importanceSample.xyz, importanceSample.w);
#else
    vec4 importanceSample = getImportanceSampleLambertian(i, sampleCount, tbn, roughness);
#endif
    vec3 H = vec3(importanceSample.xyz);
    result += textureLod(cubeMap, H, computeLod(importanceSample.w, width, sampleCount) + lodBias);
  }
  return result / float(sampleCount);
}

vec4 filterGGX(const in samplerCube cubeMap, const in vec3 N, const in int sampleCount, const in float roughness) {
  vec4 result = vec4(0.0);
  float weight = 0.0;
  float lodBias = 0.0;
  int width = int(textureSize(cubeMap, 0).x); 
  mat3 tbn = generateTBN(N);
  for (int i = 0; i < sampleCount; i++) {
#ifdef COMPUTESHADER
    vec4 importanceSample = ImportanceSamples[i];
    importanceSample = vec4(tbn * importanceSample.xyz, importanceSample.w);
#else
    vec4 importanceSample = getImportanceSampleGGX(i, sampleCount, tbn, roughness);
#endif
    vec3 H = vec3(importanceSample.xyz);
    float lod = computeLod(importanceSample.w, width, sampleCount) + lodBias;
    vec3 V = N;
    vec3 L = normalize(reflect(-V, H));
    float NdotL = dot(N, L);
    if (NdotL > 0.0) {
      result += textureLod(cubeMap, L, (roughness < 1e-7) ? lodBias : lod) * NdotL;
      weight += NdotL;
    }
  }
  return result / ((abs(weight) > 1e-7) ? weight : 1.0);
}

vec4 filterCharlie(const in samplerCube cubeMap, const in vec3 N, const in int sampleCount, const in float roughness) {
  vec4 result = vec4(0.0);
  float weight = 0.0;
  float lodBias = 0.0;
  int width = int(textureSize(cubeMap, 0).x); 
  mat3 tbn = generateTBN(N);
  for (int i = 0; i < sampleCount; i++) {
#ifdef COMPUTESHADER
    vec4 importanceSample = ImportanceSamples[i];
    importanceSample = vec4(tbn * importanceSample.xyz, importanceSample.w);
#else
    vec4 importanceSample = getImportanceSampleCharlie(i, sampleCount, tbn, roughness);
#endif
    vec3 H = vec3(importanceSample.xyz);
    float lod = computeLod(importanceSample.w, width, sampleCount) + lodBias;
    vec3 V = N;
    vec3 L = normalize(reflect(-V, H));
    float NdotL = dot(N, L);
    if (NdotL > 0.0) {
      result += textureLod(cubeMap, L, (roughness < 1e-7) ? lodBias : lod) * NdotL;
      weight += NdotL;
    }
  }
  return result / ((abs(weight) > 1e-7) ? weight : 1.0);
}

float V_SmithGGXCorrelated(const in float NoV, const in float NoL, const in float roughness) {
  float a2 = pow(roughness, 4.0);
  return 0.5 / ((NoL * sqrt(((NoV * NoV) * (1.0 - a2)) + a2)) + (NoV * sqrt(((NoL * NoL) * (1.0 - a2)) + a2)));
}

// https://github.com/google/filament/blob/master/shaders/src/brdf.fs#L136
float V_Ashikhmin(const in float NdotL, const in float NdotV) {
  return clamp(1.0 / (4.0 * ((NdotL + NdotV) - (NdotL * NdotV))), 0.0, 1.0);  //
}

vec2 LUTGGX(const in float NdotV, const in float roughness, const in int sampleCount) {
  vec3 V = vec3(sqrt(1.0 - (NdotV * NdotV)), 0.0, NdotV);
  vec3 N = vec3(0.0, 0.0, 1.0);
  vec2 r = vec2(0.0);
  mat3 tbn = generateTBN(N);
  for (int i = 0; i < sampleCount; i++) {
    vec3 H = getImportanceSampleGGX(i, sampleCount, tbn, roughness).xyz;
    vec3 L = normalize(reflect(-V, H));
    float NdotL = clamp(L.z, 0.0, 1.0);
    float NdotH = clamp(H.z, 0.0, 1.0);
    float VdotH = clamp(dot(V, H), 0.0, 1.0);
    if (NdotL > 0.0) {
      float Fc = pow(1.0 - VdotH, 5.0);
      r += vec2(1.0 - Fc, Fc) * ((V_SmithGGXCorrelated(NdotV, NdotL, roughness) * VdotH * NdotL) / NdotH);
    }
  }
  return vec2(r) * (4.0 / float(sampleCount));
}

float LUTCharlie(const in float NdotV, const in float roughness, const in int sampleCount) {
  vec3 V = vec3(sqrt(1.0 - (NdotV * NdotV)), 0.0, NdotV);
  vec3 N = vec3(0.0, 0.0, 1.0);
  float r = 0.0;
  mat3 tbn = generateTBN(N);
  for (int i = 0; i < sampleCount; i++) {
    vec3 H = getImportanceSampleCharlie(i, sampleCount, tbn, roughness).xyz;
    vec3 L = normalize(reflect(-V, H));
    float NdotL = clamp(L.z, 0.0, 1.0);
    float NdotH = clamp(H.z, 0.0, 1.0);
    float VdotH = clamp(dot(V, H), 0.0, 1.0);
    if (NdotL > 0.0) {
      r += V_Ashikhmin(NdotL, NdotV) * D_Charlie(roughness, NdotH) * NdotL * VdotH;
    }
  }
  return (r * 4.0 * 2.0 * PI) / float(sampleCount);
}

#endif