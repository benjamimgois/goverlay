#ifndef PBR_GLSL
#define PBR_GLSL

#ifdef UseEnvMap

#define DUALENVMAP

#ifdef UseEnvMapGGX
float envMapMaxLevelGGX = max(0.0, textureQueryLevels(uImageBasedLightingEnvMaps[0]) - 1.0);
#else
float envMapMaxLevelGGX; 
#endif

#ifdef UseEnvMapCharlie
float envMapMaxLevelCharlie = max(0.0, textureQueryLevels(uImageBasedLightingEnvMaps[1]) - 1.0);
#else 
float envMapMaxLevelCharlie;
#endif

#ifdef DUALENVMAP

#ifdef UseEnvMapGGX
float envMapMaxLevelGGX2 = max(0.0, textureQueryLevels(uImageBasedLightingEnvMaps[3]) - 1.0);
#else
float envMapMaxLevelGGX2;
#endif

#ifdef UseEnvMapCharlie
float envMapMaxLevelCharlie2 = max(0.0, textureQueryLevels(uImageBasedLightingEnvMaps[4]) - 1.0);
#else
float envMapMaxLevelCharlie2;
#endif

const bool enableDualEnvMap = true;

#endif

#else

// Just dummy definitions, so that the shader compiles without errors.
float envMapMaxLevelGGX, envMapMaxLevelCharlie;

#endif

#include "math.glsl"

float ambientOcclusion = 1.0;
float diffuseOcclusion = 1.0; 
float specularOcclusion = 1.0;

vec3 iridescenceFresnelDielectric = vec3(0.0);
vec3 iridescenceFresnelMetallic = vec3(0.0);
float iridescenceFactor = 0.0;
float iridescenceIor = 1.3;
float iridescenceThickness = 400.0;

#ifdef ENABLE_ANISOTROPIC
bool anisotropyActive;
vec3 anisotropyDirection;
vec3 anisotropyT;
vec3 anisotropyB;
float anisotropyStrength;
float alphaRoughnessAnisotropyT;
float alphaRoughnessAnisotropyB;
float anisotropyTdotV;
float anisotropyBdotV;
float anisotropyTdotL;
float anisotropyBdotL;
float anisotropyTdotH;
float anisotropyBdotH;
#endif

vec3 colorOutput = vec3(0.0);

vec3 clearcoatFresnel = vec3(0.0);

float rcpSinFromCos(const in float cosAngle){
  return inversesqrt(max(0.0, 1.0 - (cosAngle * cosAngle)));
}

// Based on https://x.com/BenSimsTech/status/1933128209786347709 
vec3 getViewClampedNormal(vec3 normal, const in vec3 viewDirection, out float NdotV){
  NdotV = dot(normal, viewDirection);
  if(NdotV < 0.0){
    normal = (normal - (viewDirection * NdotV)) * rcpSinFromCos(NdotV); 
    NdotV = 0.0;
  }
  return normal;
}

float applyIorToRoughness(float roughness, float ior) {
  // Scale roughness with IOR so that an IOR of 1.0 results in no microfacet refraction and 
  // an IOR of 1.5 results in the default amount of microfacet refraction.
  return roughness * clamp(fma(ior, 2.0, -2.0), 0.0, 1.0);
}

vec3 rgbMix(vec3 base, vec3 layer, vec3 rgbAlpha){
  return ((1.0 - max(max(rgbAlpha.x, rgbAlpha.y), rgbAlpha.z)) * base) + (rgbAlpha * layer);
}

vec3 approximateAnalyticBRDF(vec3 specularColor, float NoV, float roughness) {
  const vec4 c0 = vec4(-1.0, -0.0275, -0.572, 0.022);
  const vec4 c1 = vec4(1.0, 0.0425, 1.04, -0.04);
  vec4 r = fma(c0, vec4(roughness), c1);
  vec2 AB = fma(vec2(-1.04, 1.04), vec2((min(r.x * r.x, exp2(-9.28 * NoV)) * r.x) + r.y), r.zw);
  return fma(specularColor, AB.xxx, AB.yyy);
}

vec3 F_Schlick(vec3 f0, vec3 f90, float VdotH) {
  return mix(f0, f90, pow(clamp(1.0 - VdotH, 0.0, 1.0), 5.0));  //
}

float F_Schlick(float f0, float f90, float VdotH) {
  float x = clamp(1.0 - VdotH, 0.0, 1.0);
  float x2 = x * x;
  return mix(f0, f90, x * x2 * x2);  
}

float F_Schlick(float f0, float VdotH) {
  return F_Schlick(f0, 1.0, VdotH); //
}

vec3 F_Schlick(vec3 f0, float VdotH) {
  return F_Schlick(f0, vec3(1.0), VdotH); //
}

vec3 Schlick_to_F0(vec3 f, vec3 f90, float VdotH) {
  float x = clamp(1.0 - VdotH, 0.0, 1.0);
  float x2 = x * x;
  float x5 = clamp(x * x2 * x2, 0.0, 0.9999);

  return (f - (f90 * x5)) / (1.0 - x5);
}

float Schlick_to_F0(float f, float f90, float VdotH) {
  float x = clamp(1.0 - VdotH, 0.0, 1.0);
  float x2 = x * x;
  float x5 = clamp(x * x2 * x2, 0.0, 0.9999);

  return (f - (f90 * x5)) / (1.0 - x5);
}

vec3 Schlick_to_F0(vec3 f, float VdotH) { 
  return Schlick_to_F0(f, vec3(1.0), VdotH); //
}

float Schlick_to_F0(float f, float VdotH) { 
  return Schlick_to_F0(f, 1.0, VdotH); //
}

float V_GGX(float NdotL, float NdotV, float alphaRoughness) {
#ifdef ENABLE_ANISOTROPIC
  float GGX;
  if (anisotropyActive) {
    GGX = (NdotL * length(vec3(alphaRoughnessAnisotropyT * anisotropyTdotV, alphaRoughnessAnisotropyB * anisotropyBdotV, NdotV))) + //
          (NdotV * length(vec3(alphaRoughnessAnisotropyT * anisotropyTdotL, alphaRoughnessAnisotropyB * anisotropyBdotL, NdotL)));
  }else{
    float alphaRoughnessSq = alphaRoughness * alphaRoughness;
    GGX = (NdotL * sqrt(((NdotV * NdotV) * (1.0 - alphaRoughnessSq)) + alphaRoughnessSq)) +  //
          (NdotV * sqrt(((NdotL * NdotL) * (1.0 - alphaRoughnessSq)) + alphaRoughnessSq));
  }
  return (GGX > 0.0) ? clamp(0.5 / GGX, 0.0, 1.0) : 0.0;
#else
  float alphaRoughnessSq = alphaRoughness * alphaRoughness;
  float GGX = (NdotL * sqrt(((NdotV * NdotV) * (1.0 - alphaRoughnessSq)) + alphaRoughnessSq)) +  //
              (NdotV * sqrt(((NdotL * NdotL) * (1.0 - alphaRoughnessSq)) + alphaRoughnessSq));
  return (GGX > 0.0) ? (0.5 / GGX) : 0.0;
#endif  
}

float D_GGX(float NdotH, float alphaRoughness) {
#ifdef ENABLE_ANISOTROPIC
  if (anisotropyActive) {
    float a2 = alphaRoughnessAnisotropyT * alphaRoughnessAnisotropyB;
    vec3 f = vec3(alphaRoughnessAnisotropyB * anisotropyTdotH, alphaRoughnessAnisotropyT * anisotropyBdotH, a2 * NdotH);
    return (a2 * pow2(a2 / dot(f, f))) / PI;  
  }else{
    float alphaRoughnessSq = alphaRoughness * alphaRoughness;
    float f = ((NdotH * NdotH) * (alphaRoughnessSq - 1.0)) + 1.0;
    return alphaRoughnessSq / (PI * (f * f));
  }
#else
  float alphaRoughnessSq = alphaRoughness * alphaRoughness;
  float f = ((NdotH * NdotH) * (alphaRoughnessSq - 1.0)) + 1.0;
  return alphaRoughnessSq / (PI * (f * f));
#endif
}

float lambdaSheenNumericHelper(float x, float alphaG) {
  float oneMinusAlphaSq = (1.0 - alphaG) * (1.0 - alphaG);
  return ((mix(21.5473, 25.3245, oneMinusAlphaSq) /          //
           (1.0 + (mix(3.82987, 3.32435, oneMinusAlphaSq) *  //
                   pow(x, mix(0.19823, 0.16801, oneMinusAlphaSq))))) +
          (mix(-1.97760, -1.27393, oneMinusAlphaSq) * x)) +  //
         mix(-4.32054, -4.85967, oneMinusAlphaSq);
}

float lambdaSheen(float cosTheta, float alphaG) {
  return (abs(cosTheta) < 0.5) ?  //
             exp(lambdaSheenNumericHelper(cosTheta, alphaG))
                               :  //
             exp((2.0 * lambdaSheenNumericHelper(0.5, alphaG)) - lambdaSheenNumericHelper(1.0 - cosTheta, alphaG));
}

float V_Sheen(float NdotL, float NdotV, float sheenRoughness) {
  sheenRoughness = max(sheenRoughness, 0.000001);
  float alphaG = sheenRoughness * sheenRoughness;
  return clamp(1.0 / (((1.0 + lambdaSheen(NdotV, alphaG)) + lambdaSheen(NdotL, alphaG)) * (4.0 * NdotV * NdotL)), 0.0, 1.0);
}

float D_Charlie(float sheenRoughness, float NdotH) {
  sheenRoughness = max(sheenRoughness, 0.000001);
  float invR = 1.0 / (sheenRoughness * sheenRoughness);
  return ((2.0 + invR) * pow(1.0 - (NdotH * NdotH), invR * 0.5)) / (2.0 * PI);
}

// https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#acknowledgments AppendixB
vec3 BRDF_lambertian(vec3 diffuseColor) {
  // see https://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
  return diffuseColor * OneOverPI; 
}

// https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#acknowledgments AppendixB
vec3 BRDF_specularGGX(float alphaRoughness, float NdotL, float NdotV, float NdotH) {
  return vec3(V_GGX(NdotL, NdotV, alphaRoughness) * D_GGX(NdotH, alphaRoughness));  //
}

vec3 BRDF_specularSheen(vec3 sheenColor, float sheenRoughness, float NdotL, float NdotV, float NdotH) {
  return sheenColor * D_Charlie(sheenRoughness, NdotH) * V_Sheen(NdotL, NdotV, sheenRoughness);  //
}

float getSpecularOcclusion(const in float NdotV, const in float ao, const in float roughness){
  return clamp((pow(NdotV + ao, /*roughness * roughness*/exp2((-16.0 * roughness) - 1.0)) - 1.0) + ao, 0.0, 1.0); 
} 

float albedoSheenScalingLUT(const in float NdotV, const in float sheenRoughnessFactor) {
  return textureLod(uImageBasedLightingBRDFTextures[2], vec2(NdotV, sheenRoughnessFactor), 0.0).x;  //
}

/////////////////////////////

// Compute attenuated light as it travels through a volume.
vec3 applyVolumeAttenuation(vec3 radiance, float transmissionDistance, vec3 attenuationColor, float attenuationDistance) {
  if (isinf(attenuationDistance) || (attenuationDistance == 0.0)) {
    // Attenuation distance is infinity (which we indicate by zero), i.e. the transmitted color is not attenuated at all.
    return radiance;
  } else {
    // Compute light attenuation using Beer's law.
#if 0    
    vec3 attenuationCoefficient = -log(attenuationColor) / attenuationDistance;
    vec3 transmittance = exp(-attenuationCoefficient * transmissionDistance);  // Beer's law
#else
    vec3 transmittance = pow(attenuationColor, vec3(transmissionDistance / attenuationDistance));  // Beer's law
#endif
    return transmittance * radiance;
  }
}

vec3 getVolumeTransmissionRay(vec3 n, vec3 v, float thickness, float ior) {
  return normalize(refract(-v, normalize(n), 1.0 / ior)) * thickness * inModelScale;
}

/////////////////////////////

void doSingleLight(const in vec3 lightColor, 
                   const in vec3 lightLit, 
                   const in vec3 lightDirection, // Direction from surface point to light
                   const in vec3 normal, 
                   const in vec3 baseColor,
                   const in vec3 F0Dielectric,
                   const in vec3 F90, 
                   const in vec3 F90Dielectric,
                   const in vec3 viewDirection, 
                   const in float refractiveAngle, 
                   const in float materialTransparency,
                   const in float alphaRoughness, 
                   const in float metallic, 
                   const in vec3 sheenColor, 
                   const in float sheenRoughness,
                   const in vec3 clearcoatNormal, 
                   const in vec3 clearcoatFresnel,
                   const in float clearcoatFactor,
                   const float clearcoatRoughness, 
                   const in float specularWeight,
                   const vec3 transmittedLight,
                   const in float transmissionFactor){

  vec3 halfwayVector = normalize(viewDirection + lightDirection); // Direction of the vector between lightDirection and viewDirection, called halfway vector

  float NDotL = clamp(dot(normal, lightDirection), 0.0, 1.0);
  float NDotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
  float NDotH = clamp(dot(normal, halfwayVector), 0.0, 1.0);
  float LDotH = clamp(dot(lightDirection, halfwayVector), 0.0, 1.0);
  float VDotH = clamp(dot(viewDirection, halfwayVector), 0.0, 1.0);

  vec3 dielectricFresnel = F_Schlick(F0Dielectric * specularWeight, F90Dielectric, abs(VDotH));
  vec3 metalFresnel = F_Schlick(baseColor.xyz, vec3(1.0), abs(VDotH));
  
  vec3 lightIntensity = vec3(lightColor * lightLit);

  vec3 lightDiffuse = lightIntensity * NDotL * BRDF_lambertian(baseColor.xyz);

  vec3 lightSpecularDielectric = vec3(0.0);
  vec3 lightSpecularMetal = vec3(0.0);
  vec3 lightDielectricBRDF = vec3(0.0);
  vec3 lightMetalBRDF = vec3(0.0);
  vec3 lightClearcoatBRDF = vec3(0.0);
  vec3 lightSheen = vec3(0.0);
  float lightAlbedoSheenScaling = 1.0; 

#if defined(CAN_HAVE_EXTENDED_PBR_MATERIAL)

  // Diffuse transmission  
  if ((flags & (1u << 16u)) != 0u) {
    lightDiffuse *= 1.0 - diffuseTransmissionFactor; 
    if(dot(normal, lightDirection) < 0.0){
      float lightNDotL = clamp(dot(normal, -lightDirection), 0.0, 1.0);
      vec3 lightDiffuseBTDF = lightIntensity * lightNDotL * BRDF_lambertian(diffuseTransmissionColorFactor.xyz);
      vec3 lightMirror = normalize(lightDirection + (2.0 * dot(-lightDirection, normal) * normal));
      float diffuseVDotH = clamp(dot(viewDirection, lightMirror), 0.0, 1.0);
      dielectricFresnel = F_Schlick(F0Dielectric * specularWeight, F90Dielectric, abs(diffuseVDotH));
      // Volume attenuation
      if ((flags & (1u << 12u)) != 0u) {
        lightDiffuseBTDF = applyVolumeAttenuation(
          lightDiffuseBTDF, 
          diffuseTransmissionThickness, 
          volumeAttenuationColor, 
          volumeAttenuationDistance
        );
      }
      lightDiffuse += lightDiffuseBTDF * diffuseTransmissionFactor;
    }
  }

#ifdef TRANSMISSION
  // Transmission
  if ((flags & (1u << 11u)) != 0u) {
    lightDiffuse = mix(lightDiffuse, transmittedLight, transmissionFactor);
  }
#endif
#endif

  if((NDotL > 0.0) || (NDotV > 0.0)) // <= TODO: Check if this check is right, if it produces no missing light output
  {

#ifdef ENABLE_ANISOTROPIC
    anisotropyTdotL = dot(anisotropyT, lightDirection);
    anisotropyBdotL = dot(anisotropyB, lightDirection);
    anisotropyTdotH = dot(anisotropyT, halfwayVector);
    anisotropyBdotH = dot(anisotropyB, halfwayVector);
#endif

    lightSpecularMetal = lightIntensity * NDotL * BRDF_specularGGX(alphaRoughness, NDotL, NDotV, NDotH);
    lightSpecularDielectric = lightSpecularMetal;

    lightMetalBRDF = metalFresnel * lightSpecularMetal;
    lightDielectricBRDF = mix(lightDiffuse, lightSpecularDielectric, dielectricFresnel);

#if defined(CAN_HAVE_EXTENDED_PBR_MATERIAL)

    if ((flags & (1u << 10u)) != 0u) {
      lightMetalBRDF = mix(lightMetalBRDF, lightSpecularMetal * iridescenceFresnelMetallic, iridescenceFactor);
      lightDielectricBRDF = mix(lightDielectricBRDF, rgbMix(lightDiffuse, lightSpecularDielectric, iridescenceFresnelDielectric), iridescenceFactor);
    }

    if ((flags & (1u << 7u)) != 0u) {
      float sheenColorMax = max(max(sheenColor.x, sheenColor.y), sheenColor.z);
      lightAlbedoSheenScaling = min(1.0 - (sheenColorMax * albedoSheenScalingLUT(NDotV, sheenRoughness)), //
                                    1.0 - (sheenColorMax * albedoSheenScalingLUT(NDotL, sheenRoughness)));
      lightSheen = lightIntensity * NDotL * BRDF_specularSheen(sheenColor, sheenRoughness, NDotL, NDotV, NDotH);
    }

    if ((flags & (1u << 8u)) != 0u) { 
      float NDotL = clamp(dot(clearcoatNormal, lightDirection), 0.0, 1.0);
      float NDotV = clamp(dot(clearcoatNormal, viewDirection), 0.0, 1.0);
      float NDotH = clamp(dot(clearcoatNormal, halfwayVector), 0.0, 1.0);
      lightClearcoatBRDF = lightIntensity * NDotL * BRDF_specularGGX(clearcoatRoughness * clearcoatRoughness, NDotL, NDotV, NDotH);
    }

#endif

  }

  // Compute the final color
  vec3 lightResultColor = mix(lightDielectricBRDF, lightMetalBRDF, metallic);
#if defined(CAN_HAVE_EXTENDED_PBR_MATERIAL)
  lightResultColor = fma(lightResultColor, vec3(lightAlbedoSheenScaling), lightSheen);
  lightResultColor = mix(lightResultColor, lightClearcoatBRDF, clearcoatFactor * clearcoatFresnel);
#endif
  colorOutput += lightResultColor;

}

vec4 getEnvMap(sampler2D texEnvMap, vec3 rayDirection, float texLOD) {
  rayDirection = normalize(rayDirection);
  return textureLod(texEnvMap, (vec2((atan(rayDirection.z, rayDirection.x) / PI2) + 0.5, acos(rayDirection.y) / 3.1415926535897932384626433832795)), texLOD);
}

vec3 getIBLDiffuse(const in vec3 normal) {
#ifdef UseEnvMap
  vec3 irradiance = textureLod(uImageBasedLightingEnvMaps[2], normal.xyz, 0.0).xyz;
#ifdef DUALENVMAP
  if(enableDualEnvMap){
    vec4 envB = textureLod(uImageBasedLightingEnvMaps[5], normal.xyz, 0.0);
    irradiance = mix(irradiance, envB.xyz, envB.w); 
  }
#endif
  return irradiance;
#else
  return vec3(0.0);
#endif
}

vec3 getIBLGGXFresnel(vec3 normal, vec3 viewDirection, float roughness, vec3 F0, float specularWeight){
  float NdotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
#ifdef ENABLE_ANISOTROPIC
  if(anisotropyActive){
  //float tangentRoughness = mix(roughness, 1.0, anisotropyStrength * anisotropyStrength);  
    normal = normalize(mix(cross(cross(anisotropyDirection, viewDirection), anisotropyDirection), normal, pow4(1.0 - (anisotropyStrength * (1.0 - roughness)))));
  }
#endif
  vec2 brdfSamplePoint = clamp(vec2(NdotV, roughness), vec2(0.0, 0.0), vec2(1.0, 1.0));
  vec2 f_ab = texture(uImageBasedLightingBRDFTextures[0], brdfSamplePoint).xy;
  vec3 Fr = max(vec3(1.0 - roughness), F0) - F0;
  vec3 k_S = F0 + (Fr * pow(1.0 - NdotV, 5.0));
  vec3 FssEss = (specularWeight * k_S * f_ab.x) + f_ab.y;

  // Multiple scattering, from Fdez-Aguera
  float Ems = (1.0 - (f_ab.x + f_ab.y));
  vec3 F_avg = specularWeight * (F0 + (1.0 - F0) / 21.0);
  vec3 FmsEms = Ems * FssEss * F_avg / (1.0 - F_avg * Ems);

  return FssEss + FmsEms;
}

vec3 getIBLRadianceGGX(vec3 normal, vec3 viewDirection, float roughness){
  float NdotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
#ifdef ENABLE_ANISOTROPIC
  if(anisotropyActive){
  //float tangentRoughness = mix(roughness, 1.0, anisotropyStrength * anisotropyStrength);  
    normal = normalize(mix(cross(cross(anisotropyDirection, viewDirection), anisotropyDirection), normal, pow4(1.0 - (anisotropyStrength * (1.0 - roughness)))));
  }
#endif
  vec3 reflectionVector = normalize(reflect(-viewDirection, normal));
  vec3 specularSample = textureLod(uImageBasedLightingEnvMaps[0], reflectionVector, roughnessToMipMapLevel(roughness, envMapMaxLevelGGX)).xyz;
#ifdef DUALENVMAP
  if(enableDualEnvMap){
    vec4 envB = textureLod(uImageBasedLightingEnvMaps[3], reflectionVector, roughnessToMipMapLevel(roughness, envMapMaxLevelGGX2));
    specularSample = mix(specularSample, envB.xyz, envB.w); 
  } 
#endif
  vec3 specularLight = specularSample.xyz;
  return specularLight;
}

/*vec3 getIBLRadianceGGX(in vec3 normal, const in float roughness, const in vec3 F0, const in float specularWeight, const in vec3 viewDirection, const in float litIntensity, const in vec3 imageLightBasedLightDirection) {
#ifdef UseEnvMap
  float NdotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
#ifdef ENABLE_ANISOTROPIC
  if(anisotropyActive){
  //float tangentRoughness = mix(roughness, 1.0, anisotropyStrength * anisotropyStrength);  
    normal = normalize(mix(cross(cross(anisotropyDirection, viewDirection), anisotropyDirection), normal, pow4(1.0 - (anisotropyStrength * (1.0 - roughness)))));
  }
#endif
  vec3 reflectionVector = normalize(reflect(-viewDirection, normal));
  float ao = 1.0,                                                                                                   //
      lightIntensity = mix(1.0, litIntensity, max(0.0, dot(reflectionVector, -imageLightBasedLightDirection) * (1.0 - (roughness * roughness)))),  //
      specularOcclusion = getSpecularOcclusion(NdotV, ao * lightIntensity, roughness);
  vec2 brdf = textureLod(uImageBasedLightingBRDFTextures[0], clamp(vec2(NdotV, roughness), vec2(0.0), vec2(1.0)), 0.0).xy;
  vec3 irradiance = textureLod(uImageBasedLightingEnvMaps[0], reflectionVector, roughnessToMipMapLevel(roughness, envMapMaxLevelGGX)).xyz;
#ifdef DUALENVMAP
  if(enableDualEnvMap){
    vec4 envB = textureLod(uImageBasedLightingEnvMaps[3], reflectionVector, roughnessToMipMapLevel(roughness, envMapMaxLevelGGX2));
    irradiance = mix(irradiance, envB.xyz, envB.w); 
  } 
#endif
  return (irradiance *                                                                   //
          fma(mix(F0 + ((max(vec3(1.0 - roughness), F0) - F0) * pow(1.0 - NdotV, 5.0)),  //
                  iridescenceFresnel,                                                    //
                  iridescenceFactor),                                                    //
              brdf.xxx,                                                                  //
              brdf.yyy * clamp(max(max(F0.x, F0.y), F0.z) * 50.0, 0.0, 1.0)) *           //
          specularWeight *                                                               //
          specularOcclusion *                                                            //
          1.0);
#else
  return vec3(0.0); 
#endif
}*/

vec3 getIBLRadianceCharlie(vec3 normal, vec3 viewDirection, float sheenRoughness, vec3 sheenColor) {
#ifdef UseEnvMap
  float NdotV = clamp(dot(normal.xyz, viewDirection), 0.0, 1.0);
  vec3 reflectionVector = normalize(reflect(-viewDirection, normal));
  vec3 irradiance = textureLod(uImageBasedLightingEnvMaps[1], reflectionVector, roughnessToMipMapLevel(sheenRoughness, envMapMaxLevelCharlie)).xyz;
#ifdef DUALENVMAP
  if(enableDualEnvMap){
    vec4 envB = textureLod(uImageBasedLightingEnvMaps[4], reflectionVector, roughnessToMipMapLevel(sheenRoughness, envMapMaxLevelCharlie2));
    irradiance = mix(irradiance, envB.xyz, envB.w); 
  }
#endif
  return irradiance * //
         sheenColor * //
         textureLod(uImageBasedLightingBRDFTextures[1], clamp(vec2(NdotV, sheenRoughness), vec2(0.0), vec2(1.0)), 0.0).x;
#else
  return vec3(0.0);
#endif
}

vec3 getPunctualRadianceTransmission(vec3 normal, vec3 view, vec3 pointToLight, float alphaRoughness, vec3 baseColor, float ior) {
  float transmissionRougness = applyIorToRoughness(alphaRoughness, ior);

  vec3 n = normalize(normal);  // Outward direction of surface point
  vec3 v = normalize(view);    // Direction from surface point to view
  vec3 l = normalize(pointToLight);
  vec3 l_mirror = normalize(l + (2.0 * n * dot(-l, n)));  // Mirror light reflection vector on surface
  vec3 h = normalize(l_mirror + v);                       // Halfway vector between transmission light vector and v

  float D = D_GGX(clamp(dot(n, h), 0.0, 1.0), transmissionRougness);
  float Vis = V_GGX(clamp(dot(n, l_mirror), 0.0, 1.0), clamp(dot(n, v), 0.0, 1.0), transmissionRougness);

  // Transmission BTDF
  return baseColor * D * Vis;
}

/////////////////////////////

// XYZ to sRGB color space
const mat3 XYZ_TO_REC709 = mat3(3.2404542, -0.9692660, 0.0556434, -1.5371385, 1.8760108, -0.2040259, -0.4985314, 0.0415560, 1.0572252);

// Assume air interface for top
// Note: We don't handle the case fresnel0 == 1
vec3 Fresnel0ToIor(vec3 fresnel0) {
  vec3 sqrtF0 = sqrt(fresnel0);
  return (vec3(1.0) + sqrtF0) / (vec3(1.0) - sqrtF0);
}

// Conversion FO/IOR
vec3 IorToFresnel0(vec3 transmittedIor, float incidentIor) { 
  return sq((transmittedIor - vec3(incidentIor)) / (transmittedIor + vec3(incidentIor))); //
}

// ior is a value between 1.0 and 3.0. 1.0 is air interface
float IorToFresnel0(float transmittedIor, float incidentIor) { 
  return sq((transmittedIor - incidentIor) / (transmittedIor + incidentIor)); //
}

// Fresnel equations for dielectric/dielectric interfaces.
// Ref: https://belcour.github.io/blog/research/2017/05/01/brdf-thin-film.html
// Evaluation XYZ sensitivity curves in Fourier space
vec3 evalSensitivity(float OPD, vec3 shift) {
  float phase = 2.0 * PI * OPD * 1.0e-9;
  vec3 val = vec3(5.4856e-13, 4.4201e-13, 5.2481e-13);
  vec3 pos = vec3(1.6810e+06, 1.7953e+06, 2.2084e+06);
  vec3 var = vec3(4.3278e+09, 9.3046e+09, 6.6121e+09);

  vec3 xyz = val * sqrt(2.0 * PI * var) * cos(pos * phase + shift) * exp(-sq(phase) * var);
  xyz.x += 9.7470e-14 * sqrt(2.0 * PI * 4.5282e+09) * cos(2.2399e+06 * phase + shift[0]) * exp(-4.5282e+09 * sq(phase));
  xyz /= 1.0685e-7;

  vec3 srgb = XYZ_TO_REC709 * xyz;
  return srgb;
}

vec3 evalIridescence(float outsideIOR, float eta2, float cosTheta1, float thinFilmThickness, vec3 baseF0) {
  vec3 I;

  // Force iridescenceIor -> outsideIOR when thinFilmThickness -> 0.0
  float iridescenceIor = mix(outsideIOR, eta2, smoothstep(0.0, 0.03, thinFilmThickness));
  // Evaluate the cosTheta on the base layer (Snell law)
  float sinTheta2Sq = sq(outsideIOR / iridescenceIor) * (1.0 - sq(cosTheta1));

  // Handle TIR:
  float cosTheta2Sq = 1.0 - sinTheta2Sq;
  if (cosTheta2Sq < 0.0) {
    return vec3(1.0);
  }

  float cosTheta2 = sqrt(cosTheta2Sq);

  // First interface
  float R0 = IorToFresnel0(iridescenceIor, outsideIOR);
  float R12 = F_Schlick(R0, cosTheta1);
  float R21 = R12;
  float T121 = 1.0 - R12;
  float phi12 = 0.0;
  if (iridescenceIor < outsideIOR) phi12 = PI;
  float phi21 = PI - phi12;

  // Second interface
  vec3 baseIOR = Fresnel0ToIor(clamp(baseF0, 0.0, 0.9999));  // guard against 1.0
  vec3 R1 = IorToFresnel0(baseIOR, iridescenceIor);
  vec3 R23 = F_Schlick(R1, cosTheta2);
  vec3 phi23 = vec3(0.0);
  if (baseIOR[0] < iridescenceIor) phi23[0] = PI;
  if (baseIOR[1] < iridescenceIor) phi23[1] = PI;
  if (baseIOR[2] < iridescenceIor) phi23[2] = PI;

  // Phase shift
  float OPD = 2.0 * iridescenceIor * thinFilmThickness * cosTheta2;
  vec3 phi = vec3(phi21) + phi23;

  // Compound terms
  vec3 R123 = clamp(R12 * R23, 1e-5, 0.9999);
  vec3 r123 = sqrt(R123);
  vec3 Rs = sq(T121) * R23 / (vec3(1.0) - R123);

  // Reflectance term for m = 0 (DC term amplitude)
  vec3 C0 = R12 + Rs;
  I = C0;

  // Reflectance term for m > 0 (pairs of diracs)
  vec3 Cm = Rs - T121;
  for (int m = 1; m <= 2; ++m) {
    Cm *= r123;
    vec3 Sm = 2.0 * evalSensitivity(float(m) * OPD, float(m) * phi);
    I += Cm * Sm;
  }

  // Since out of gamut colors might be produced, negative color values are clamped to 0.
  return max(I, vec3(0.0));
}

////////////////////////////
 
#if defined(TRANSMISSION) || defined(SCREEN_SPACE_REFLECTIONS)

vec4 cubic(float v) {
  vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
  n *= n * n;
  vec3 t = vec3(n.x, fma(n.xy, vec2(-4.0), n.yz)) + vec2(0.0, 6.0 * n.x).xxy;
  return vec4(t, ((6.0 - t.x) - t.y) - t.z) * (1.0 / 6.0);
}

vec4 textureBicubicEx(const in sampler2DArray tex, vec3 uvw, int lod) {
  vec2 textureResolution = textureSize(tex, lod).xy,  //
      uv = fma(uvw.xy, textureResolution, vec2(-0.5)),            //
      fuv = fract(uv);
  uv -= fuv;
  vec4 xcubic = cubic(fuv.x),                                                             //
      ycubic = cubic(fuv.y),                                                              //
      c = uv.xxyy + vec2(-0.5, 1.5).xyxy,                                                 //
      s = vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw),                             //
      o = (c + (vec4(xcubic.yw, ycubic.yw) / s)) * (vec2(1.0) / textureResolution).xxyy;  //
  s.xy = s.xz / (s.xz + s.yw);
  return mix(mix(textureLod(tex, vec3(o.yw, uvw.z), float(lod)), textureLod(tex, vec3(o.xw, uvw.t), float(lod)), s.x),  //
             mix(textureLod(tex, vec3(o.yz, uvw.z), float(lod)), textureLod(tex, vec3(o.xz, uvw.z), float(lod)), s.x), s.y);
}

vec4 textureBicubic(const in sampler2DArray tex, vec3 uvw, float lod, int maxLod) {
  int ilod = int(floor(lod));
  lod -= float(ilod); 
  return (lod < float(maxLod)) ? mix(textureBicubicEx(tex, uvw, ilod), textureBicubicEx(tex, uvw, ilod + 1), lod) : textureBicubicEx(tex, uvw, maxLod);
}

vec4 betterTextureEx(const in sampler2DArray tex, vec3 uvw, int lod) {
  vec2 textureResolution = textureSize(uPassTextures[1], lod).xy;
  vec2 uv = fma(uvw.xy, textureResolution, vec2(0.5));
  vec2 fuv = fract(uv);
  return textureLod(tex, vec3((floor(uv) + ((fuv * fuv) * fma(fuv, vec2(-2.0), vec2(3.0))) - vec2(0.5)) / textureResolution, uvw.z), float(lod));
}

vec4 betterTexture(const in sampler2DArray tex, vec3 uvw, float lod, int maxLod) {
  int ilod = int(floor(lod));
  lod -= float(ilod); 
  return (lod < float(maxLod)) ? mix(betterTextureEx(tex, uvw, ilod), betterTextureEx(tex, uvw, ilod + 1), lod) : betterTextureEx(tex, uvw, maxLod);
}

#endif // defined(TRANSMISSION) || defined(SCREEN_SPACE_REFLECTIONS)

////////////////////////////

#ifdef TRANSMISSION

vec3 getTransmissionSample(vec2 fragCoord, float roughness, float ior) {
  int maxLod = int(textureQueryLevels(uPassTextures[1]));
  float framebufferLod = float(maxLod) * applyIorToRoughness(roughness, ior);
#if 1
  vec3 transmittedLight = (framebufferLod < 1e-4) ? //
                           betterTexture(uPassTextures[1], vec3(fragCoord.xy, inViewIndex), framebufferLod, maxLod).xyz :  //                           
                           textureBicubic(uPassTextures[1], vec3(fragCoord.xy, inViewIndex), framebufferLod, maxLod).xyz; //
#else
  vec3 transmittedLight = texture(uPassTextures[1], vec3(fragCoord.xy, inViewIndex), framebufferLod).xyz;
#endif
  return transmittedLight;
}

vec3 getIBLVolumeRefraction(vec3 n, vec3 v, float perceptualRoughness, vec3 baseColor, vec3 position, float ior, float thickness, vec3 attenuationColor, float attenuationDistance, float dispersion) {
  
  vec3 attenuatedColor;

  // Sample framebuffer to get pixel the refracted ray hits.
  if(abs(dispersion) > 1e-7){
    
    float realIOR = 1.0 / ior;
    
    float iorDispersionSpread = 0.04 * dispersion * (realIOR - 1.0);
    
    vec3 iorValues = vec3(1.0 / (realIOR - iorDispersionSpread), ior, 1.0 / (realIOR + iorDispersionSpread));
    
    for(int i = 0; i < 3; i++){
      vec3 transmissionRay = getVolumeTransmissionRay(n, v, thickness, iorValues[i]);
      vec3 refractedRayExit = position + transmissionRay;

      // Project refracted vector on the framebuffer, while mapping to normalized device coordinates.
      vec4 ndcPos = uView.views[inViewIndex].projectionMatrix * uView.views[inViewIndex].viewMatrix * vec4(refractedRayExit, 1.0);
      vec2 refractionCoords = fma(ndcPos.xy / ndcPos.w, vec2(0.5), vec2(0.5));

      vec3 transmittedLight = getTransmissionSample(refractionCoords, perceptualRoughness, iorValues[i]);

      attenuatedColor[i] = applyVolumeAttenuation(transmittedLight, length(transmissionRay), attenuationColor, attenuationDistance)[i];    

    }

  }else{

    vec3 transmissionRay = getVolumeTransmissionRay(n, v, thickness, ior);
    vec3 refractedRayExit = position + transmissionRay;

    // Project refracted vector on the framebuffer, while mapping to normalized device coordinates.
    vec4 ndcPos = uView.views[inViewIndex].projectionMatrix * uView.views[inViewIndex].viewMatrix * vec4(refractedRayExit, 1.0);
    vec2 refractionCoords = fma(ndcPos.xy / ndcPos.w, vec2(0.5), vec2(0.5));

    vec3 transmittedLight = getTransmissionSample(refractionCoords, perceptualRoughness, ior);

    attenuatedColor = applyVolumeAttenuation(transmittedLight, length(transmissionRay), attenuationColor, attenuationDistance);  
      
  }
  
  return attenuatedColor * baseColor;
}
#endif // TRANSMISSION

#ifdef SCREEN_SPACE_REFLECTIONS

float ssrRayAAABBIntersection(const in vec2 rayOrigin, const in vec2 rayDirection, const in vec2 aabbMin, const in vec2 aabbMax){
  vec2 boundary = mix(aabbMin, aabbMax, greaterThan(rayDirection, vec2(0.0)));
  vec2 times = (boundary - rayOrigin) / rayDirection;
  return min(times.x, times.y);
}

vec3 ssrEnhance(const in vec3 rayOrigin, const in vec3 rayDirection, const in int mipLevel, const in ivec2 texSize){
  const vec2 mipSize = vec2(texSize >> mipLevel);
  const vec2 position = rayOrigin.xy * mipSize;
  return fma(
    rayDirection, 
    vec3(ssrRayAAABBIntersection(rayOrigin.xy, rayDirection.xy, floor(position) / mipSize, ceil(position) / mipSize) + (0.1 / mipSize.x)), 
    rayOrigin
  );
}

#if 1
// Don't work also yet
bool castScreenSpaceRay(vec3 worldSpaceRayOrigin,
                        vec3 worldSpaceRayDirection,
                        out vec2 hitUV){

  vec3 rayOrigin = (viewMatrix * vec4(worldSpaceRayOrigin, 1.0)).xyz;

  vec3 rayDirection = normalize((viewMatrix * vec4(worldSpaceRayDirection, 0.0)).xyz);

  vec3 viewDirection = normalize(rayDirection);

  float cameraContribution = smoothstep(0.5, 0.25, dot(-viewDirection, rayDirection));  
  if(cameraContribution < 1e-6){
    return false;
  } 

  const bool reversedZ = false;//projectionMatrix[2][3] < -1e-7;

  const float maxDistance = 100.0;
  const int countIterations = 128;

  const ivec2 texSize = ivec2(textureSize(uPassTextures[2], 0).xy);
  
  const int countLODLevels = int(textureQueryLevels(uPassTextures[2]));

  vec3 p0 = rayOrigin;
  vec3 p1 = fma(rayDirection, vec3(maxDistance), rayOrigin);

  vec4 t = projectionMatrix * vec4(p0, 1.0);
  vec3 start = t.xyz / t.w; 
  start.xy = fma(start.xy, vec2(0.5), vec2(0.5));

  t = projectionMatrix * vec4(p1, 1.0);
  vec3 end = t.xyz / t.w; 
  end.xy = fma(end.xy, vec2(0.5), vec2(0.5));

  vec3 origin = start;
  vec3 direction = normalize(end - start);

  int mipLevel = 0;
  for(int iteration = 0; (iteration < countIterations) && (mipLevel >= 0); iteration++){

    //origin = ssrEnhance(origin, direction, mipLevel, texSize);

	  ivec2 mipSize = texSize >> mipLevel;

    vec2 mipCellIndex = origin.xy * vec2(mipSize);

    vec2 boundaryUV = vec2(
      (direction.x > 0.0) ? ceil(mipCellIndex.x) / float(mipSize.x) : floor(mipCellIndex.x) / float(mipSize.x),
      (direction.y > 0.0) ? ceil(mipCellIndex.y) / float(mipSize.y) : floor(mipCellIndex.y) / float(mipSize.y)
    );

    vec2 t = (boundaryUV - origin.xy) / direction.xy;

    origin += ((abs(t.x) < abs(t.y)) ? (t.x + (0.1 / mipSize.x)) : (t.y + (0.1 / mipSize.y))) * direction;

    if(all(greaterThanEqual(origin, vec3(0.0))) && all(lessThanEqual(origin, vec3(1.0)))){

      float depth = textureLod(uPassTextures[2], vec3(origin.xy, inViewIndex), float(mipLevel)).x;

      if(origin.z < depth){
        mipLevel = min(mipLevel + 1, countLODLevels - 1);
      }else{
        origin -= direction * ((origin.z - depth) / direction.z);
        mipLevel--;
      }
      
    }else{
      break;
    }

  }

  hitUV = origin.xy;

  return all(greaterThanEqual(hitUV, vec2(0.0))) && all(lessThanEqual(hitUV, vec2(1.0)));

}
#else
// Don't work yet
bool castScreenSpaceRay(vec3 worldSpaceRayOrigin,
                        vec3 worldSpaceRayDirection,
                        out vec2 hitUV){

  const int countHiZRayIterations = 128;
  const int countLODLevels = int(textureQueryLevels(uPassTextures[2]));
  const float stepEpsilon = 1e-4;
  const float zeroEpsilon = 1e-5;
  const float zeroDirectionEpsilon = 1e-3;
  const float maxDistance = 100.0;
  const float zThickness = 0.02;

  const ivec2 lod0Size = ivec2(textureSize(uPassTextures[2], 0).xy);
  const vec2 invLOD0Size = vec2(1.0) / vec2(lod0Size);

  vec3 rayOrigin = (viewMatrix * vec4(worldSpaceRayOrigin, 1.0)).xyz;

  vec3 rayDirection = normalize((viewMatrix * vec4(worldSpaceRayDirection, 0.0)).xyz);

  vec2 nearPlaneTemporary = (inverseProjectionMatrix * vec4(0.0, 0.0, (projectionMatrix[2][3] < -1e-7) ? 1.0 : 0.0, 1.0)).zw;
  float nearPlane = nearPlaneTemporary.x / nearPlaneTemporary.y;

  // Limit the ray length to the near plane distance, when needed.
  float rayLength = ((rayOrigin.z + (rayDirection.z * maxDistance)) < nearPlane)
                      ? (nearPlane - rayOrigin.z) / rayDirection.z
                      : maxDistance;

  vec3 rayEnd = fma(rayDirection, vec3(rayLength), rayOrigin);

  vec4 pHS0 = projectionMatrix * vec4(rayOrigin, 1.0);
  pHS0 /= pHS0.w;
  vec3 pSS0 = vec3(fma(pHS0.xy / pHS0.w, vec2(0.5), vec2(0.5)), pHS0.z);

  vec4 pHS1 = projectionMatrix * vec4(rayEnd, 1.0);
  pHS1 /= pHS1.w;
  vec3 pSS1 = vec3(fma(pHS1.xy / pHS1.w, vec2(0.5), vec2(0.5)), pHS1.z);

  vec3 vSS = pSS1 - pSS0;

  vec3 stepSign = mix(vec3(1.0), vec3(-1.0), lessThan(vSS, vec3(0.0)));

  vec2 stepOffset = stepSign.xy * (stepEpsilon * invLOD0Size);

  vec3 vSSAbs = abs(vSS);
  vSS = mix(vSS, stepSign * zeroDirectionEpsilon, lessThan(vSSAbs, vec3(zeroEpsilon)));
 
  vec2 stepVector = clamp(stepSign.xy, vec2(0.0), vec2(1.0));
 
  vec3 vSSInv = vec3(1.0) / vSS;

  float pSS0InvZ = 1.0 / pSS0.z;
  float pSS1InvZ = 1.0 / pSS1.z;

  float interpolationPoint = pSS0InvZ;
  float interpolationVector = pSS1InvZ - pSS0InvZ;

  float calcT0 = -pSS0InvZ;
  float calcT1 = 1.0f / (pSS1InvZ - pSS0InvZ);
 
  const vec2 timeStartPixelXY = ((((floor(pSS0.xy * vec2(lod0Size)) + stepVector) / vec2(lod0Size)) + stepOffset) - pSS0.xy) * vSSInv.xy;
  float time = min(timeStartPixelXY.x, timeStartPixelXY.y);
  vec2 timeSceneZMinMax = vec2(1.0, 0.0);
  int mipLevel = countLODLevels - 1;
 
  for(int iteration = 0; (mipLevel >= 0) && (iteration < countHiZRayIterations) && (time <= 1.0); iteration++){
    const vec2 maxRayPointXY = fma(vSS.xy, vec2(time), pSS0.xy);
    const vec2 levelSize = floor(vec2(lod0Size) / min(vec2(exp2(mipLevel)), vec2(lod0Size)));
    const vec2 pixel = floor(maxRayPointXY * levelSize);
    const vec2 timePixelXY = ((((pixel + stepVector) / levelSize) + stepOffset) - pSS0.xy) * vSSInv.xy;
    const float timePixelEdge = min(timePixelXY.x, timePixelXY.y);
    vec2 uv = (pixel + vec2(0.5)) * invLOD0Size;   
    vec2 rawDepths = textureLod(uPassTextures[2], vec3(uv, inViewIndex), float(mipLevel)).xy;
    uv = fma(uv, vec2(2.0), vec2(-1.0));
    vec4 depths = vec4((inverseProjectionMatrix * vec4(uv, rawDepths.x, 1.0)).zw, (inverseProjectionMatrix * vec4(uv, rawDepths.y, 1.0)).zw);
    vec2 sceneZMinMax = vec2(depths.xz / depths.yw) + vec2(0.0, zThickness);
    if(sceneZMinMax.y == 0.0){
      sceneZMinMax.xy = vec2(16777216.0, 0.0);
    }
    timeSceneZMinMax = ((vec2(1.0) / sceneZMinMax) + calcT0) * calcT1;
    if((timeSceneZMinMax.x <= timePixelEdge) && (time <= timeSceneZMinMax.y)){
      mipLevel--;
      time = max(time, timeSceneZMinMax.x);
    }else{
      time = timePixelEdge;
      mipLevel = min(mipLevel + 1, countLODLevels - 1);
    }
  }

  vec3 hit = vec3(fma(vSS.xy, vec2(time), pSS0.xy), 1.0 / fma(interpolationVector, time, interpolationPoint));

  hitUV = hit.xy;
  
  return (mipLevel == -1) && (time >= timeSceneZMinMax.x) && (time <= timeSceneZMinMax.y);

}
#endif

vec3 getReflectionSample(vec2 fragCoord, float roughness) {
  int maxLod = int(textureQueryLevels(uPassTextures[1]));
  float framebufferLod = float(maxLod) * applyIorToRoughness(roughness, 1.0);
#if 1
  vec3 reflectedLight = (framebufferLod < 1e-4) ? //
                        betterTexture(uPassTextures[1], vec3(fragCoord.xy, inViewIndex), framebufferLod, maxLod).xyz :  //                           
                        textureBicubic(uPassTextures[1], vec3(fragCoord.xy, inViewIndex), framebufferLod, maxLod).xyz; //
#else
  vec3 reflectedLight = texture(uPassTextures[1], vec3(fragCoord.xy, inViewIndex), framebufferLod).xyz;
#endif
  return reflectedLight;
}

vec4 getScreenSpaceReflection(vec3 worldSpacePosition,
                              vec3 worldSpaceNormal, 
                              vec3 worldSpaceViewDirection,
                              float roughness,
                              vec4 fallbackColor){

  // Compute the reflection vector in world space.
  vec3 worldSpaceReflectionVector = normalize(reflect(worldSpaceViewDirection, worldSpaceNormal.xyz)); 

#if 0

  vec2 hitUV;
  if(castScreenSpaceRay(worldSpacePosition, worldSpaceReflectionVector, hitUV)){
    return vec4(getReflectionSample(hitUV, roughness), 1.0);
  }

#else

  const float rayStep = 0.2;
  const int countLinearSearchIterations = 128;
  const int countBinarySearchIterations = 16;
  const float distanceBias = 0.05;
  const bool isBinarySearchEnabled = true;  
  const bool isAdaptiveStepEnabled = false;  
  const bool isExponentialStepEnabled = true;

  float viewIndex = float(gl_ViewIndex);

  // Compute the ray origin and direction in view space.
  vec3 rayOrigin = (viewMatrix * vec4(worldSpacePosition, 1.0)).xyz;

  vec3 rayDirection = (viewMatrix * vec4(worldSpaceReflectionVector, 0.0)).xyz;

  // First, perform a linear search to find the first intersection point. 

  float depthDifference;

  vec3 stepVector = rayDirection * rayStep;  

  vec3 rayPosition = rayOrigin + stepVector;

  for(int iteration = 0; iteration < countLinearSearchIterations; iteration++){

    vec4 screenSpaceRayPosition = projectionMatrix * vec4(rayPosition, 1.0);
    screenSpaceRayPosition.xy = fma(screenSpaceRayPosition.xy / screenSpaceRayPosition.w, vec2(0.5), vec2(0.5));

    float viewSpaceRawDepth = textureLod(uPassTextures[2], vec3(screenSpaceRayPosition.xy, viewIndex), 0.0).x;

    vec4 viewSpaceProbePosition = inverseProjectionMatrix * vec4(fma(screenSpaceRayPosition.xy, vec2(2.0), vec2(-1.0)), viewSpaceRawDepth, 1.0);
    depthDifference = (viewSpaceProbePosition.z / viewSpaceProbePosition.w) - rayPosition.z;

    if((all(greaterThanEqual(screenSpaceRayPosition.xy, vec2(0.0))) && all(lessThanEqual(screenSpaceRayPosition.xy, vec2(1.0)))) &&
       ((depthDifference >= 0.0) && (depthDifference < distanceBias))){
      return vec4(getReflectionSample(screenSpaceRayPosition.xy, roughness), 1.0);
    } 

    if(isBinarySearchEnabled && (depthDifference > 0.0)){
      // Switch to binary search for further refinement.
      break;
    }

    if(isAdaptiveStepEnabled){
      float directionSign = sign(depthDifference);
      rayPosition += (stepVector *= (1.0 - rayStep * max(directionSign, 0.0))) * (-directionSign);
    }else {
      rayPosition += stepVector;
    }

    if(isExponentialStepEnabled){
      stepVector *= 1.05;
    }

  }

  // If the linear search failed, perform a binary search to find the intersection point, when enabled.

  if(isBinarySearchEnabled){

    for(int iteration = 0; iteration < countBinarySearchIterations; iteration++){
	
      rayPosition -= ((stepVector *= 0.5) * sign(depthDifference));

      vec4 screenSpaceRayPosition = projectionMatrix * vec4(rayPosition, 1.0);
      screenSpaceRayPosition.xy = fma(screenSpaceRayPosition.xy / screenSpaceRayPosition.w, vec2(0.5), vec2(0.5));
			
      float viewSpaceRawDepth = textureLod(uPassTextures[2], vec3(screenSpaceRayPosition.xy, viewIndex), 0.0).x;

      vec4 viewSpaceProbePosition = inverseProjectionMatrix * vec4(fma(screenSpaceRayPosition.xy, vec2(2.0), vec2(-1.0)), viewSpaceRawDepth, 1.0);
      depthDifference = (viewSpaceProbePosition.z / viewSpaceProbePosition.w) - rayPosition.z;

      if((all(greaterThanEqual(screenSpaceRayPosition.xy, vec2(0.0))) && all(lessThanEqual(screenSpaceRayPosition.xy, vec2(1.0)))) &&
         ((depthDifference >= 0.0) && (depthDifference < distanceBias))){
        return vec4(getReflectionSample(screenSpaceRayPosition.xy, roughness), 1.0);
      }

    }

  }

#endif

  // No reflection found, so fall back to the environment map (in the GGX variant, since it is also used for IBL specular lighting).
  if(fallbackColor.w >= 0.99999){
    return vec4(fallbackColor.xyz, 0.0);
  }else{

#ifdef UseEnvMap
    vec3 env = textureLod(uImageBasedLightingEnvMaps[0], worldSpaceReflectionVector, roughnessToMipMapLevel(roughness, envMapMaxLevelGGX)).xyz;
#ifdef DUALENVMAP
    if(enableDualEnvMap){
      vec4 envB = textureLod(uImageBasedLightingEnvMaps[3], worldSpaceReflectionVector, roughnessToMipMapLevel(roughness, envMapMaxLevelGGX2));
      env = mix(env, envB.xyz, envB.w);
    }
#endif
 
    return vec4(mix(env.xyz, fallbackColor.xyz, fallbackColor.w), 0.0);

  }

#else

  return vec4(fallbackColor.xyz, 0.0);

#endif

}

#endif // SCREEN_SPACE_REFLECTIONS

#endif // PBR_GLSL