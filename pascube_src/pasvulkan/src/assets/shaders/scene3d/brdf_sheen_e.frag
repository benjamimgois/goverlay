#version 450 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

const int numSamples = 4096;

const float PI = 3.14159265359;

vec2 Hammersley(const in int index, const in int numSamples){
#if 1
  uint reversedIndex = bitfieldReverse(uint(index)); 
#else
  uint reversedIndex = uint(index); 
  reversedIndex = (reversedIndex << 16) | (reversedIndex >> 16);
  reversedIndex = ((reversedIndex & 0x00ff00fful) << 8) | ((reversedIndex & 0xff00ff00ul) >> 8);
  reversedIndex = ((reversedIndex & 0x0f0f0f0ful) << 4) | ((reversedIndex & 0xf0f0f0f0ul) >> 4);
  reversedIndex = ((reversedIndex & 0x33333333ul) << 2) | ((reversedIndex & 0xccccccccul) >> 2);
  reversedIndex = ((reversedIndex & 0x55555555ul) << 1) | ((reversedIndex & 0xaaaaaaaaul) >> 1);
#endif
  return vec2(fract(float(index) / numSamples), float(reversedIndex) * 2.3283064365386963e-10);
}    

vec3 hemisphereUniformSample(vec2 u){
  float phi = 2.0 * PI * u.x;
  float cosTheta = 1.0 - u.y;
  float sinTheta = sqrt(1.0 - (cosTheta * cosTheta));
  return vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
}

float VisibilityAshikhmin(float NoV, float NoL, float a) {
  // Neubelt and Pettineo 2013, "Crafting a Next-gen Material Pipeline for The Order: 1886"
  return 1.0 / (4.0 * ((NoL + NoV) - (NoL * NoV)));
}

float DistributionCharlie(float NoH, float linearRoughness) {
  // Estevez and Kulla 2017, "Production Friendly Microfacet Sheen BRDF"
  float a = linearRoughness;
  float invAlpha = 1.0 / a;
  float cos2h = NoH * NoH;
  float sin2h = 1.0 - cos2h;
  return ((2.0 + invAlpha) * pow(sin2h, invAlpha * 0.5)) / (2.0 * PI);
}

// https://dassaultsystemes-technology.github.io/EnterprisePBRShadingModel/spec-2021x.md.html#components/sheen
// https://www.shadertoy.com/view/wl3SWs
float L(float x, float r) {
  r = 1.0 - clamp(r, 0.0, 1.0);
  r = 1.0 - (r * r);
  float a = mix( 25.3245,  21.5473, r);
  float b = mix( 3.32435,  3.82987, r);
  float c = mix( 0.16801,  0.19823, r);
  float d = mix(-1.27393, -1.97760, r);
  float e = mix(-4.85967, -4.32054, r);
  return ((a / (1.0 + (b * pow(x, c)))) + (d * x)) + e;
}

// https://dassaultsystemes-technology.github.io/EnterprisePBRShadingModel/spec-2021x.md.html#components/sheen
// https://www.shadertoy.com/view/wl3SWs
float VisibilityCharlie(float NdotV, float NdotL, float sheenRoughness){
  float r = sheenRoughness;
  float visV = NdotV < 0.5 ? exp(L(NdotV, r)) : exp(2.0 * L(0.5, r) - L(1.0 - NdotV, r));
  float visL = NdotL < 0.5 ? exp(L(NdotL, r)) : exp(2.0 * L(0.5, r) - L(1.0 - NdotL, r));
  return 1.0 / ((1.0 + (visV + visL)) * (4.0 * (NdotV * NdotL)));
}

float DFV_Charlie_Uniform(float NdotV, float linearRoughness, int numSamples) {
  float r = 0.0;
  vec3 V = vec3(sqrt(1.0 - (NdotV * NdotV)), 0.0, NdotV);
  for (int i = 0; i < numSamples; i++) {
    vec2 u = Hammersley(i, numSamples);
    vec3 H = hemisphereUniformSample(u);
    vec3 L = ((2.0 * dot(V, H)) * H) - V;
    float VdotH = clamp(dot(V, H), 0.0, 1.0);
    float NdotL = clamp(L.z, 0.0, 1.0);
    float NdotH = clamp(H.z, 0.0, 1.0);
    if (NdotL > 0.0) {
#if 0
      float v = VisibilityCharlie(NdotV, NdotL, linearRoughness);
#else
      float v = VisibilityAshikhmin(NdotV, NdotL, linearRoughness);
#endif
      float d = DistributionCharlie(NdotH, linearRoughness);
      r += v * d * NdotL * VdotH; // VdotH comes from the Jacobian, 1/(4*VdotH)
    }
  }
  // uniform sampling, the PDF is 1/2pi, 4 comes from the Jacobian
  return r * (((4.0 * 2.0) * PI) / float(numSamples));
}

float computeDirectionalAlbedoSheenLuT(float NdotV, float roughness)
{
	float alpha = max(roughness, 0.07);
	alpha = alpha * alpha;
	float c = 1.0 - NdotV;
	float c3 = c * c * c;
	return (0.65584461 * c3) + (1.0 / (4.16526551 + exp(-7.97291361 * sqrt(alpha) + 6.33516894)));
}

float analyticDirectionalAlbedoSheenLuT(float NdotV, float roughness)
{
    vec2 r = vec2(13.67300, 1.0) +
             vec2(-68.78018, 61.57746) * NdotV +
             vec2(799.08825, 442.78211) * roughness +
             vec2(-905.00061, 2597.49308) * NdotV * roughness +
             vec2(60.28956, 121.81241) * (NdotV * NdotV) +
             vec2(1086.96473, 3045.55075) * (roughness * roughness);
    return r.x / r.y;
}

void main(){
  float nDotV = inTexCoord.x;
  float roughness = inTexCoord.y;
  float linearRoughness = roughness * roughness;
#ifdef FAST
  outFragColor = vec4(analyticDirectionalAlbedoSheenLuT(nDotV, linearRoughness), 0.0, 0.0, 1.0);
#else
  outFragColor = vec4(DFV_Charlie_Uniform(nDotV, linearRoughness, numSamples), 0.0, 0.0, 1.0);
#endif
}
