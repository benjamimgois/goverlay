#ifndef PBR_GLSL
#define PBR_GLSL

#include "math.glsl"

float cavity = 1.0;

float specularOcclusion = 1.0;

float ambientOcclusion = 1.0;

vec3 iridescenceFresnel = vec3(0.0);
vec3 iridescenceF0 = vec3(0.0);
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

vec3 diffuseOutput = vec3(0.0);
vec3 specularOutput = vec3(0.0);
vec3 sheenOutput = vec3(0.0);
vec3 clearcoatOutput = vec3(0.0);
vec3 clearcoatFresnel = vec3(0.0);
#if defined(TRANSMISSION)
vec3 transmissionOutput = vec3(0.0);
#endif

float albedoSheenScaling = 1.0;

float applyIorToRoughness(float roughness, float ior) {
  // Scale roughness with IOR so that an IOR of 1.0 results in no microfacet refraction and an IOR of 1.5 results in the default amount of microfacet refraction.
  return roughness * clamp(fma(ior, 2.0, -2.0), 0.0, 1.0);
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
  return F_Schlick(f0, 1.0, VdotH);
}

vec3 F_Schlick(vec3 f0, float VdotH) {
  return F_Schlick(f0, vec3(1.0), VdotH);
}

vec3 Schlick_to_F0(vec3 f, vec3 f90, float VdotH) {
  float x = clamp(1.0 - VdotH, 0.0, 1.0);
  float x2 = x * x;
  float x5 = clamp(x * x2 * x2, 0.0, 0.9999);

  return (f - f90 * x5) / (1.0 - x5);
}

float Schlick_to_F0(float f, float f90, float VdotH) {
  float x = clamp(1.0 - VdotH, 0.0, 1.0);
  float x2 = x * x;
  float x5 = clamp(x * x2 * x2, 0.0, 0.9999);

  return (f - f90 * x5) / (1.0 - x5);
}

vec3 Schlick_to_F0(vec3 f, float VdotH) { return Schlick_to_F0(f, vec3(1.0), VdotH); }

float Schlick_to_F0(float f, float VdotH) { return Schlick_to_F0(f, 1.0, VdotH); }

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

vec3 BRDF_lambertian(vec3 f0, vec3 f90, vec3 diffuseColor, float specularWeight, float VdotH) {
  return (1.0 - (specularWeight * mix(F_Schlick(f0, f90, VdotH), vec3(max(max(iridescenceF0.x, iridescenceF0.y), iridescenceF0.z)), iridescenceFactor))) * (diffuseColor * OneOverPI);  //
}

vec3 BRDF_specularGGX(vec3 f0, vec3 f90, float alphaRoughness, float specularWeight, float VdotH, float NdotL, float NdotV, float NdotH) {
  return specularWeight * mix(F_Schlick(f0, f90, VdotH), iridescenceFresnel, iridescenceFactor) * V_GGX(NdotL, NdotV, alphaRoughness) * D_GGX(NdotH, alphaRoughness);  //
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

void doSingleLight(const in vec3 lightColor, 
                   const in vec3 lightLit, 
                   const in vec3 lightDirection, 
                   const in vec3 normal, 
                   const in vec3 diffuseColor, 
                   const in vec3 F0, 
                   const in vec3 F90, 
                   const in vec3 viewDirection, 
                   const in float refractiveAngle, 
                   const in float materialTransparency,
                   const in float alphaRoughness, 
                   const in float materialCavity, 
                   const in vec3 sheenColor, 
                   const in float sheenRoughness,
                   const in vec3 clearcoatNormal, 
                   const in vec3 clearcoatF0,
                   const float clearcoatRoughness, 
                   const in float specularWeight){
  float nDotL = clamp(dot(normal, lightDirection), 0.0, 1.0);
  float nDotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
  if((nDotL > 0.0) || (nDotV > 0.0)){
    vec3 halfVector = normalize(viewDirection + lightDirection);
    float nDotH = clamp(dot(normal, halfVector), 0.0, 1.0);
    float vDotH = clamp(dot(viewDirection, halfVector), 0.0, 1.0);
    vec3 lit = vec3((materialCavity * nDotL * lightColor) * lightLit);
#ifdef ENABLE_ANISOTROPIC
    anisotropyTdotL = dot(anisotropyT, lightDirection);
    anisotropyBdotL = dot(anisotropyB, lightDirection);
    anisotropyTdotH = dot(anisotropyT, halfVector);
    anisotropyBdotH = dot(anisotropyB, halfVector);
#endif
    diffuseOutput += BRDF_lambertian(F0, F90, diffuseColor, specularWeight, vDotH) * lit;
    specularOutput += BRDF_specularGGX(F0, F90, alphaRoughness, specularWeight, vDotH, nDotL, nDotV, nDotH) * specularOcclusion * lit;
#if defined(CAN_HAVE_EXTENDED_PBR_MATERIAL)
    if ((flags & (1u << 7u)) != 0u) {
      float sheenColorMax = max(max(sheenColor.x, sheenColor.y), sheenColor.z);
      albedoSheenScaling = min(1.0 - (sheenColorMax * albedoSheenScalingLUT(nDotV, sheenRoughness)), //
                               1.0 - (sheenColorMax * albedoSheenScalingLUT(nDotL, sheenRoughness)));
      sheenOutput += BRDF_specularSheen(sheenColor, sheenRoughness, nDotL, nDotV, nDotH) * lit;
    }
    if ((flags & (1u << 8u)) != 0u) {
      float nDotL = clamp(dot(clearcoatNormal, lightDirection), 1e-5, 1.0);
      float nDotV = clamp(abs(dot(clearcoatNormal, viewDirection)) + 1e-5, 0.0, 1.0);
      float nDotH = clamp(dot(clearcoatNormal, halfVector), 0.0, 1.0);
      vec3 lit = vec3((materialCavity * nDotL * lightColor) * lightLit);
      clearcoatOutput += F_Schlick(clearcoatF0, vec3(1.0), vDotH) *  //
                        D_GGX(nDotH, clearcoatRoughness) *          //
                        V_GGX(nDotV, nDotL, clearcoatRoughness) * specularWeight * specularOcclusion * lit;
    }
#endif
  }
}

vec4 getEnvMap(sampler2D texEnvMap, vec3 rayDirection, float texLOD) {
  rayDirection = normalize(rayDirection);
  return textureLod(texEnvMap, (vec2((atan(rayDirection.z, rayDirection.x) / PI2) + 0.5, acos(rayDirection.y) / 3.1415926535897932384626433832795)), texLOD);
}

vec3 getIBLRadianceLambertian(const in vec3 normal, const in vec3 viewDirection, const in float roughness, const in vec3 diffuseColor, const in vec3 F0, const in float specularWeight) {
  float ao = cavity * ambientOcclusion;
  float NdotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
  vec2 brdfSamplePoint = clamp(vec2(NdotV, roughness), vec2(0.0), vec2(1.0));
  vec2 f_ab = textureLod(uImageBasedLightingBRDFTextures[0], brdfSamplePoint, 0.0).xy;
  vec3 irradiance = textureLod(uImageBasedLightingEnvMaps[2], normal.xyz, 0.0).xyz;
  vec3 mixedF0 = mix(F0, vec3(max(max(iridescenceF0.x, iridescenceF0.y), iridescenceF0.z)), iridescenceFactor);
  vec3 Fr = max(vec3(1.0 - roughness), mixedF0) - mixedF0;
  vec3 k_S = mixedF0 + (Fr * pow(1.0 - NdotV, 5.0));
  vec3 FssEss = (specularWeight * k_S * f_ab.x) + f_ab.y;
  float Ems = 1.0 - (f_ab.x + f_ab.y);
  vec3 F_avg = specularWeight * (mixedF0 + ((1.0 - mixedF0) / 21.0));
  vec3 FmsEms = (Ems * FssEss * F_avg) / (vec3(1.0) - (F_avg * Ems));
  vec3 k_D = (diffuseColor * ((1.0 - FssEss) + FmsEms) * ao);
  return (FmsEms + k_D) * irradiance;
}

vec3 getIBLRadianceGGX(in vec3 normal, const in float roughness, const in vec3 F0, const in float specularWeight, const in vec3 viewDirection, const in float litIntensity, const in vec3 imageLightBasedLightDirection) {
  float NdotV = clamp(dot(normal, viewDirection), 0.0, 1.0);
#ifdef ENABLE_ANISOTROPIC
  if(anisotropyActive){
  //float tangentRoughness = mix(roughness, 1.0, anisotropyStrength * anisotropyStrength);  
    normal = normalize(mix(cross(cross(anisotropyDirection, viewDirection), anisotropyDirection), normal, pow4(1.0 - (anisotropyStrength * (1.0 - roughness)))));
  }
#endif
  vec3 reflectionVector = normalize(reflect(-viewDirection, normal));
  float ao = cavity * ambientOcclusion,                                                                                                   //
      lit = mix(1.0, litIntensity, max(0.0, dot(reflectionVector, -imageLightBasedLightDirection) * (1.0 - (roughness * roughness)))),  //
      specularOcclusion = getSpecularOcclusion(NdotV, ao * lit, roughness);
  vec2 brdf = textureLod(uImageBasedLightingBRDFTextures[0], clamp(vec2(NdotV, roughness), vec2(0.0), vec2(1.0)), 0.0).xy;
  return (textureLod(uImageBasedLightingEnvMaps[0],  //
                     reflectionVector,               //
                     roughnessToMipMapLevel(roughness, envMapMaxLevelGGX))
              .xyz *                                                                     //
          fma(mix(F0 + ((max(vec3(1.0 - roughness), F0) - F0) * pow(1.0 - NdotV, 5.0)),  //
                  iridescenceFresnel,                                                    //
                  iridescenceFactor),                                                    //
              brdf.xxx,                                                                  //
              brdf.yyy * clamp(max(max(F0.x, F0.y), F0.z) * 50.0, 0.0, 1.0)) *           //
          specularWeight *                                                               //
          specularOcclusion *                                                            //
          1.0);
}

vec3 getIBLRadianceCharlie(vec3 normal, vec3 viewDirection, float sheenRoughness, vec3 sheenColor) {
  float ao = cavity * ambientOcclusion;
  float NdotV = clamp(dot(normal.xyz, viewDirection), 0.0, 1.0);
  vec3 reflectionVector = normalize(reflect(-viewDirection, normal));
  return texture(uImageBasedLightingEnvMaps[1],  //
                 reflectionVector,               //
                 roughnessToMipMapLevel(sheenRoughness, envMapMaxLevelCharlie))
             .xyz *    //
         sheenColor *  //
         textureLod(uImageBasedLightingBRDFTextures[1], clamp(vec2(NdotV, sheenRoughness), vec2(0.0), vec2(1.0)), 0.0).x *
         ao;
}

vec3 getPunctualRadianceTransmission(vec3 normal, vec3 view, vec3 pointToLight, float alphaRoughness, vec3 f0, vec3 f90, vec3 baseColor, float ior) {
  float transmissionRougness = applyIorToRoughness(alphaRoughness, ior);

  vec3 n = normalize(normal);  // Outward direction of surface point
  vec3 v = normalize(view);    // Direction from surface point to view
  vec3 l = normalize(pointToLight);
  vec3 l_mirror = normalize(l + (2.0 * n * dot(-l, n)));  // Mirror light reflection vector on surface
  vec3 h = normalize(l_mirror + v);                       // Halfway vector between transmission light vector and v

  float D = D_GGX(clamp(dot(n, h), 0.0, 1.0), transmissionRougness);
  vec3 F = F_Schlick(f0, f90, clamp(dot(v, h), 0.0, 1.0));
  float Vis = V_GGX(clamp(dot(n, l_mirror), 0.0, 1.0), clamp(dot(n, v), 0.0, 1.0), transmissionRougness);

  // Transmission BTDF
  return (1.0 - F) * baseColor * D * Vis;
}

/////////////////////////////

// Compute attenuated light as it travels through a volume.
vec3 applyVolumeAttenuation(vec3 radiance, float transmissionDistance, vec3 attenuationColor, float attenuationDistance) {
  if (isinf(attenuationDistance) || (attenuationDistance == 0.0)) {
    // Attenuation distance is +Ã¯ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ch we indicate by zero), i.e. the transmitted color is not attenuated at all.
    return radiance;
  } else {
    // Compute light attenuation using Beer's law.
    vec3 attenuationCoefficient = -log(attenuationColor) / attenuationDistance;
    vec3 transmittance = exp(-attenuationCoefficient * transmissionDistance);  // Beer's law
    return transmittance * radiance;
  }
}

vec3 getVolumeTransmissionRay(vec3 n, vec3 v, float thickness, float ior) {
  return normalize(refract(-v, normalize(n), 1.0 / ior)) * thickness * inModelScale;
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
vec3 IorToFresnel0(vec3 transmittedIor, float incidentIor) { return sq((transmittedIor - vec3(incidentIor)) / (transmittedIor + vec3(incidentIor))); }

// ior is a value between 1.0 and 3.0. 1.0 is air interface
float IorToFresnel0(float transmittedIor, float incidentIor) { return sq((transmittedIor - incidentIor) / (transmittedIor + incidentIor)); }

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

vec3 getIBLVolumeRefraction(vec3 n, vec3 v, float perceptualRoughness, vec3 baseColor, vec3 f0, vec3 f90, vec3 position, float ior, float thickness, vec3 attenuationColor, float attenuationDistance, float dispersion) {
  
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
  
  // Sample GGX LUT to get the specular component.
  float NdotV = clamp(dot(n, v), 0.0, 1.0);
  vec2 brdfSamplePoint = clamp(vec2(NdotV, perceptualRoughness), vec2(0.0, 0.0), vec2(1.0, 1.0));
  vec2 brdf = textureLod(uImageBasedLightingBRDFTextures[0], brdfSamplePoint, 0.0).xy;
  vec3 specularColor = (f0 * brdf.x) + (f90 * brdf.y);

  return (1.0 - specularColor) * attenuatedColor * baseColor;
}
#endif // TRANSMISSION

#ifdef SCREEN_SPACE_REFLECTIONS

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

  vec3 worldSpaceReflectionVector = normalize(reflect(worldSpaceViewDirection, worldSpaceNormal.xyz)); 

#if 0

  const int countIterations = 64;
  const float maxDistance = 64.0;
  const float strideZCutoff = 0.02;
  const float zThickness = 0.1;
  const float strideFactor = 1.0;
  const float jitter = 0.0;

  vec3 rayOrigin = (viewMatrix * vec4(worldSpacePosition, 1.0)).xyz;

  vec3 rayDirection = (viewMatrix * vec4(worldSpaceReflectionVector, 0.0)).xyz;

  float viewIndex = float(gl_ViewIndex);

  vec2 nearPlaneTemporary = (inverseProjectionMatrix * vec4(0.0, 0.0, (projectionMatrix[2][3] < -1e-7) ? 1.0 : 0.0, 1.0)).zw;
  float nearPlane = nearPlaneTemporary.x / nearPlaneTemporary.y;

  // Limit the ray length to the near plane distance, when needed.
  float rayLength = ((rayOrigin.z + (rayDirection.z * maxDistance)) < nearPlane)
                      ? (nearPlane - rayOrigin.z) / rayDirection.z
                      : maxDistance;

  vec3 rayEnd = rayOrigin + (rayDirection * rayLength);

  vec2 texSize = vec2(textureSize(uPassTextures[2], 0).xy);
  
  // Project into homogeneous clip space
  vec4 H0 = (projectionMatrix * vec4(rayOrigin, 1.0)) * vec3(texSize, 1.0).xyzz;
  vec4 H1 = (projectionMatrix * vec4(rayEnd, 1.0)) * vec3(texSize, 1.0).xyzz;
  
  // Compute the reciprocal of the w components
  float k0 = 1.0 / H0.w;
  float k1 = 1.0 / H1.w; 

  // The interpolated homogeneous version in texture-space
  vec3 Q0 = rayOrigin * k0;
  vec3 Q1 = rayEnd * k1;

  // The interpolated homogeneous version in screen-space
  vec2 P0 = H0.xy * k0;
  vec2 P1 = H1.xy * k1;

  // When the ray line is degenerated, ensure that the ray is at least one pixel long.
  P1 += (distance(P0, P1) < 1e-2) ? vec2(0.01) : vec2(0.0); 

  // Compute the difference between the two points
  vec2 delta = P1 - P0;

  // Determine the direction of the longest axis and swap the coordinates accordingly, so that x is always the longest axis. 
  bool swap = abs(delta.x) < abs(delta.y); 
  if(swap){
    P0 = P0.yx;
    P1 = P1.yx;
    delta = delta.yx;
  }

  // Compute the step direction and the inverse delta x
  float stepDirection = sign(delta.x);
  float inverseDeltaX = stepDirection / delta.x;

  // Compute the values of the derivatives  
  vec3 dQ = (Q1 - Q0) * inverseDeltaX;
  float dk = (k1 - k0) * inverseDeltaX;
  vec2 dP = vec2(stepDirection, delta.y * inverseDeltaX);

  float strideScale = 1.0 - min(1.0, rayOrigin.z * strideZCutoff);
  float stride = fma(strideFactor, strideScale, 1.0);
  dP *= stride;
  dQ *= stride;
  dk *= stride;

  P0 += dP * jitter;
  Q0 += dQ * jitter;
  k0 += dk * jitter;

  vec4 PQk = vec4(P0, Q0.z, k0);
  vec4 dPQk = vec4(dP, dQ.z, dk);
  vec3 Q = Q0;

  float end = P1.x * stepDirection;

  vec2 hitUV;

  int stepIndex = 0;
  float previousMaxZEstimate = rayOrigin.z;
  vec2 rayMinMaxZ = vec2(previousMaxZEstimate);
  float sceneMaxZ = rayMinMaxZ.y + 100.0;
  for(; 
    (stepIndex < countIterations) &&
    ((PQk.x * stepDirection) <= end) &&
    (abs(sceneMaxZ) < 1e-3);
    stepIndex++){ 

    float z = sceneMaxZ;
    z += zThickness + mix(0.0, 2.0, min(1.0, sceneMaxZ * strideZCutoff));
    if((rayMinMaxZ.y >= z) && ((rayMinMaxZ.x - zThickness) <= z)){
      break;
    }

    rayMinMaxZ = vec2(
      previousMaxZEstimate,
      fma(dPQk.z, 0.5, PQk.z) / fma(dPQk.w, 0.5, PQk.w)
    );
    previousMaxZEstimate = rayMinMaxZ.y;
    if(rayMinMaxZ.x > rayMinMaxZ.y){
      rayMinMaxZ = rayMinMaxZ.yx;
    }

    hitUV = ((swap ? PQk.yx : PQk.xy) + vec2(0.5)) / vec2(texSize);

    float viewSpaceRawDepth = textureLod(uPassTextures[2], vec3(hitUV, viewIndex), 0.0).x;

    vec4 viewSpaceProbePosition = inverseProjectionMatrix * vec4(fma(hitUV, vec2(2.0), vec2(-1.0)), viewSpaceRawDepth, 1.0);
    sceneMaxZ = viewSpaceProbePosition.z / viewSpaceProbePosition.w;

    PQk += dPQk;

  }
  
  Q.xy += dQ.xy * float(stepIndex);

  vec3 hitPoint = Q / PQk.w;

  float z = sceneMaxZ;
  z += zThickness + mix(0.0, 2.0, min(1.0, sceneMaxZ * strideZCutoff));
  if(((rayMinMaxZ.y >= z) && ((rayMinMaxZ.x - zThickness) <= z)) &&
     all(greaterThanEqual(hitUV, vec2(0.0))) && all(lessThanEqual(hitUV, vec2(1.0)))){
    return vec4(getReflectionSample(hitUV, roughness), 1.0);
  }

#else

  const float rayStep = 0.2;
  const int countLinearSearchIterations = 32;
  const int countBinarySearchIterations = 8;
  const float distanceBias = 0.05;
  const bool isBinarySearchEnabled = true;  
  const bool isAdaptiveStepEnabled = true;  
  const bool isExponentialStepEnabled = true;

  vec3 viewSpaceReflectionVector = (viewMatrix * vec4(worldSpaceReflectionVector, 0.0)).xyz;

  vec3 viewSpaceCurrentPosition = (viewMatrix * vec4(worldSpacePosition, 1.0)).xyz;

  float viewIndex = float(gl_ViewIndex);

  // First, perform a linear search to find the first intersection point. 

  float depthDifference;

  vec3 stepVector = viewSpaceReflectionVector * rayStep;  

  viewSpaceCurrentPosition += stepVector;

  for(int iteration = 0; iteration < countLinearSearchIterations; iteration++){

    vec4 screenSpaceCurrentPosition = projectionMatrix * vec4(viewSpaceCurrentPosition, 1.0);
    screenSpaceCurrentPosition.xy = fma(screenSpaceCurrentPosition.xy / screenSpaceCurrentPosition.w, vec2(0.5), vec2(0.5));

    float viewSpaceRawDepth = textureLod(uPassTextures[2], vec3(screenSpaceCurrentPosition.xy, viewIndex), 0.0).x;

    vec4 viewSpaceProbePosition = inverseProjectionMatrix * vec4(fma(screenSpaceCurrentPosition.xy, vec2(2.0), vec2(-1.0)), viewSpaceRawDepth, 1.0);
    depthDifference = (viewSpaceProbePosition.z / viewSpaceProbePosition.w) - viewSpaceCurrentPosition.z;

    if((all(greaterThanEqual(screenSpaceCurrentPosition.xy, vec2(0.0))) && all(lessThanEqual(screenSpaceCurrentPosition.xy, vec2(1.0)))) &&
       ((depthDifference >= 0.0) && (depthDifference < distanceBias))){
      return vec4(getReflectionSample(screenSpaceCurrentPosition.xy, roughness), 1.0);
    } 

    if(isBinarySearchEnabled && (depthDifference > 0.0)){
	    break;
	  }

		if(isAdaptiveStepEnabled){
	    float directionSign = sign(depthDifference);
	    viewSpaceCurrentPosition += (stepVector *= (1.0 - rayStep * max(directionSign, 0.0))) * (-directionSign);
	  }else {
	    viewSpaceCurrentPosition += stepVector;
	  }

	  if(isExponentialStepEnabled){
	    stepVector *= 1.05;
	  }

  }

  // If the linear search failed, perform a binary search to find the intersection point, when enabled.

  if(isBinarySearchEnabled){

    for(int iteration = 0; iteration < countBinarySearchIterations; iteration++){
	
      viewSpaceCurrentPosition -= ((stepVector *= 0.5) * sign(depthDifference));

      vec4 screenSpaceCurrentPosition = projectionMatrix * vec4(viewSpaceCurrentPosition, 1.0);
      screenSpaceCurrentPosition.xy = fma(screenSpaceCurrentPosition.xy / screenSpaceCurrentPosition.w, vec2(0.5), vec2(0.5));
			
      float viewSpaceRawDepth = textureLod(uPassTextures[2], vec3(screenSpaceCurrentPosition.xy, viewIndex), 0.0).x;

      vec4 viewSpaceProbePosition = inverseProjectionMatrix * vec4(fma(screenSpaceCurrentPosition.xy, vec2(2.0), vec2(-1.0)), viewSpaceRawDepth, 1.0);
      depthDifference = (viewSpaceProbePosition.z / viewSpaceProbePosition.w) - viewSpaceCurrentPosition.z;

      if((all(greaterThanEqual(screenSpaceCurrentPosition.xy, vec2(0.0))) && all(lessThanEqual(screenSpaceCurrentPosition.xy, vec2(1.0)))) &&
         ((depthDifference >= 0.0) && (depthDifference < distanceBias))){
        return vec4(getReflectionSample(screenSpaceCurrentPosition.xy, roughness), 1.0);
      }

    }

  }

#endif

  // No reflection found, so fall back to the environment map (in the GGX variant, since it is also used for IBL specular lighting).

  return vec4(
    (fallbackColor.w >= 0.99999) 
    ? fallbackColor.xyz
    : mix(
        textureLod(uImageBasedLightingEnvMaps[0], worldSpaceReflectionVector, roughnessToMipMapLevel(roughness, envMapMaxLevelGGX)).xyz,
        fallbackColor.xyz,
        fallbackColor.w
      ),
    0.0
  );

}

#endif // SCREEN_SPACE_REFLECTIONS

#endif // PBR_GLSL