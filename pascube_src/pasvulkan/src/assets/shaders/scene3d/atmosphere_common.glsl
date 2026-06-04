#ifndef ATMOSPHERE_COMMON_GLSL
#define ATMOSPHERE_COMMON_GLSL

#extension GL_GOOGLE_include_directive : enable

// Based on: https://github.com/sebh/UnrealEngineSkyAtmosphere

#undef ILLUMINANCE_IS_ONE
#define USE_CornetteShanks
#define MULTI_SCATTERING_POWER_SERIE 1

#define MultiScatteringLUTRes 32

#define AP_SLICE_COUNT_INT 32
#define AP_SLICE_COUNT 32.0
#define AP_KM_PER_SLICE 4.0

#define FLAGS_USE_FAST_SKY 1u
#define FLAGS_USE_FAST_AERIAL_PERSPECTIVE 2u
#define FLAGS_USE_BLUE_NOISE 4u
#define FLAGS_SHADOWS 8u
#define PUSH_CONSTANT_FLAG_REVERSE_DEPTH 65536u

#include "math.glsl"

#include "octahedral.glsl"

#include "octahedralmap.glsl"

float SampleSegmentT = 0.3;

struct CloudPhaseParameters {
  float G;
  float G2;
  float Offset;
  float Blend;
};

struct CloudParameters {
  
  vec4 ShapeNoiseWeights;
  
  vec4 DetailNoiseWeights;
  
  vec4 /*CloudPhaseParameters*/PhaseParameters; // x = G, y = G2, z = Offset, w = Blend 
  
  float DetailNoiseMultiplier;
  float StartHeight;
  float EndHeight;
  float CloudScale;
  
  float DetailScale;
  float DensityOffset;
  float DensityMultiplier;
  float Padding0; 
  
  float LightAbsTowardsSun;
  float LightAbsThroughCloud;
  float DarknessThreshold;
  float Padding1; 

  uint Flags;
  uint CountSamples;
  uint CountSamplesToSun;
  uint Padding2; 

};

struct VolumetricCloudLayerLow {
   
  vec4 Orientation; 

  float StartHeight;
  float EndHeight;
  float PositionScale;
  float ShapeNoiseScale;
  
  float DetailNoiseScale;
  float CurlScale;
  float AdvanceCurlScale;
  float AdvanceCurlAmplitude;
    
  mat3x4 heightGradients;
  mat3x4 anvilDeformations; // unused for now  

};

struct VolumetricCloudLayerHigh {

  vec4 Orientation; 
  
  float StartHeight;
  float EndHeight;
  float PositionScale;
  float Density;

  float CoverMin;
  float CoverMax;
  float FadeMin;
  float FadeMax;

  float Speed;
  float Padding0;
  float Padding1;
  float Padding2;             

  vec4 RotationBase;

  vec4 RotationOctave1;

  vec4 RotationOctave2;

  vec4 RotationOctave3;

  vec4 OctaveScales;

  vec4 OctaveFactors;
  
};

struct VolumetricCloudParameters {

  vec4 dryCoverageTypeWetnessTopFactors; // x = Coverage, y = Type, z = Wetness, w = Top
  vec4 dryCoverageTypeWetnessTopOffsets; // x = Coverage, y = Type, z = Wetness, w = Top

  vec4 wetCoverageTypeWetnessTopFactors; // x = Coverage, y = Type, z = Wetness, w = Top
  vec4 wetCoverageTypeWetnessTopOffsets; // x = Coverage, y = Type, z = Wetness, w = Top

  vec4 Scattering; 
  vec4 Absorption;

  float LightingDensity;
  float ShadowDensity;
  float ViewDensity;
  float DensityScale;

  float Scale;
  float ForwardScatteringG;
  float BackwardScatteringG;
  float ShadowRayLength;

  float DensityAlongConeLength;
  float DensityAlongConeLengthFarMultiplier;
  uint RayMinSteps;
  uint RayMaxSteps;

  uint OuterSpaceRayMinSteps;
  uint OuterSpaceRayMaxSteps;
  float DirectScatteringIntensity;
  float IndirectScatteringIntensity;

  float AmbientLightIntensity;
  float WetnessDensityFactor;
  float WetnessLuminanceFactor;
  float Padding;
  
  VolumetricCloudLayerLow LayerLow;
  VolumetricCloudLayerHigh LayerHigh;

};

// Atmosphere culling for avoiding rendering the atmosphere scattering inside scene objects, when the GPU is too slow for real atmospheric shadowing either by
// using shadow mapping or by using raytracing. 
// This structure data must set dynamically based on the scene object that it should cull the atmosphere scattering inside.
struct AtmosphereCullingParameters {
  uvec4 innerOuterFadeDistancesCountFacesMode; // x = inner fade distance, y = outer fade distance, z = count faces, w = mode (0 = Disabled, 1 = Sphere, 2 = AABB, 3 = Convex Hull)
  mat4 inversedTransform; // Inversed transform matrix 
  vec4 boundingSphere; // xyz = center, w = radius 
  vec4 facePlanes[32]; // maximal 32 faces, but for AABB [0] is the center and [1] is the extent, for Sphere [0] is the center (xyz) with radius (w)
};

struct AtmosphereParameters {

  mat4 transform;
 
  mat4 inverseTransform;
 
  mat4 originTransform;

  mat4 inverseOriginTransform;

  vec4 RayleighScattering; // w = Mu_S_min
 
  vec4 MieScattering; // w = sun direction X
 
  vec4 MieExtinction; // w = sun direction Y
 
  vec4 MieAbsorption; // w = sun direction Z
  
  vec4 AbsorptionExtinction; // w = fade factor
 
  vec4 GroundAlbedo; // w = intensity
 
  vec4 SolarIlluminance; // w = intensity
 
  float BottomRadius;
  float TopRadius;
  float RayleighDensityExpScale;
  float MieDensityExpScale;
 
  float MiePhaseG;
  float AbsorptionDensity0LayerWidth;
  float AbsorptionDensity0ConstantTerm;
  float AbsorptionDensity0LinearTerm;
 
  float AbsorptionDensity1ConstantTerm;
  float AbsorptionDensity1LinearTerm;
  int RaymarchingMinSteps;
  int RaymarchingMaxSteps;

  float maxShadowDistance;
  uint flags;
  float RainAtmosphereCubeMapLuminanceFactor; // Factor to multiply the rain atmosphere luminance by, this is used to adjust the rain atmosphere luminance based on the scene lighting for indirect lighting
  float unused2;

  AtmosphereCullingParameters CullingParameters;

  VolumetricCloudParameters VolumetricClouds;

};

const uint FLAGS_USE_PRECIPITATION_MAP = 1u << 0u;
const uint FLAGS_USE_ATMOSPHERE_MAP = 1u << 1u; 

float getAtmosphereCullingSDF(const in AtmosphereCullingParameters CullingParameters, vec3 p){
  if(CullingParameters.innerOuterFadeDistancesCountFacesMode.w == 0u){
    // Disabled
    return 1e20;
  }else{
    p = (CullingParameters.inversedTransform * vec4(p, 1.0)).xyz; // Transform the point to the local space 
    float signedDistance = length(p - CullingParameters.boundingSphere.xyz) - CullingParameters.boundingSphere.w;
    if(signedDistance > 0.0){
      return 1e20; // Outside the bounding sphere, early out 
    }
    switch(CullingParameters.innerOuterFadeDistancesCountFacesMode.w & 0xfu){
      case 1u:{
        // Sphere culling
        signedDistance = length(p - CullingParameters.facePlanes[0].xyz) - CullingParameters.facePlanes[0].w;
        break;
      }
      case 2u:{
        // AABB culling
        signedDistance = length(max(vec3(0.0), abs(p - CullingParameters.facePlanes[0].xyz) - CullingParameters.facePlanes[1].xyz));
        break;
      }
      case 3u:{
        // Convex Hull culling
        signedDistance = uintBitsToFloat(0xff800000u); // -inf
        for(uint faceIndex = 0u, countFaces = min(CullingParameters.innerOuterFadeDistancesCountFacesMode.z, 32u); faceIndex < countFaces; faceIndex++){
          const vec4 facePlane = CullingParameters.facePlanes[faceIndex];
          signedDistance = max(signedDistance, dot(p, facePlane.xyz) + facePlane.w);
        }
        break;
      }
      default:{
        // Should not happen
        return 1e20;
      }
    }
    return signedDistance;
  }
}

float getAtmosphereCullingFactor(const in AtmosphereCullingParameters CullingParameters, vec3 p, vec3 c){
  if(CullingParameters.innerOuterFadeDistancesCountFacesMode.w == 0u){
    // Disabled
    return 1.0;
  }else{
    const vec2 innerOuterFadeDistances = uintBitsToFloat(CullingParameters.innerOuterFadeDistancesCountFacesMode.xy);
    if((CullingParameters.innerOuterFadeDistancesCountFacesMode.w & 0x10u) != 0u){
      p = c; // Use the camera position instead of the point
    }
    p = (CullingParameters.inversedTransform * vec4(p, 1.0)).xyz; // Transform the point to the local space 
    float signedDistance = length(p - CullingParameters.boundingSphere.xyz) - CullingParameters.boundingSphere.w;
    if(signedDistance > 0.0){
      return 1.0; // Outside the bounding sphere, early out 
    }
    switch(CullingParameters.innerOuterFadeDistancesCountFacesMode.w & 0xfu){
      case 1u:{
        // Sphere culling
        signedDistance = length(p - CullingParameters.facePlanes[0].xyz) - CullingParameters.facePlanes[0].w;
        break;
      }
      case 2u:{
        // AABB culling
        signedDistance = length(max(vec3(0.0), abs(p - CullingParameters.facePlanes[0].xyz) - CullingParameters.facePlanes[1].xyz));
        break;
      }
      case 3u:{
        // Convex Hull culling
        signedDistance = uintBitsToFloat(0xff800000u); // -inf
        for(uint faceIndex = 0u, countFaces = min(CullingParameters.innerOuterFadeDistancesCountFacesMode.z, 32u); faceIndex < countFaces; faceIndex++){
          const vec4 facePlane = CullingParameters.facePlanes[faceIndex];
          signedDistance = max(signedDistance, dot(p, facePlane.xyz) + facePlane.w);
          if(signedDistance >= innerOuterFadeDistances.y){
            // If it is already greater than the outer fade distance, then break the loop early
            break;
          }
        }
        break;
      }
      default:{
        // Should not happen
        return 1.0;
      }
    }
    return clamp((signedDistance - innerOuterFadeDistances.x) / max(1e-6, innerOuterFadeDistances.y - innerOuterFadeDistances.x), 0.0, 1.0);
  }
}

vec3 getSunDirection(const in AtmosphereParameters atmosphereParameters){
  vec3 sunDirection = vec3(atmosphereParameters.MieScattering.w, atmosphereParameters.MieExtinction.w, atmosphereParameters.MieAbsorption.w); 
  sunDirection = normalize(atmosphereParameters.originTransform * vec4(sunDirection, 0.0)).xyz; // Transform the sun direction to the world space
  return sunDirection;
}

struct SingleScatteringResult {
  vec3 L;						// Scattered light (luminance)
  vec3 OpticalDepth;			// Optical depth (1/m)
  vec3 Transmittance;			// Transmittance in [0,1] (unitless)
  vec3 MultiScatAs1;
  vec3 NewMultiScatStep0Out;
  vec3 NewMultiScatStep1Out;
};

//vec2 RayMarchMinMaxSPP = vec2(4.0, 14.0);

#define PLANET_RADIUS_OFFSET 0.01

struct Ray{
  vec3 o;
  vec3 d;
};

Ray createRay(in vec3 p, in vec3 d){
  Ray r;
  r.o = p;
  r.d = d;
  return r;
}

float safeSqrt(float x){
  return sqrt(max(0.0, x));
}

void seedSampleSeedT(const in sampler2D bluenoise, const in ivec2 p, const in int frame){
  SampleSegmentT = fract(texelFetch(bluenoise, ivec2(p) & ivec2(1023), 0).x + (float(frame) * GoldenRatioConjugate));
}

float fromUnitToSubUvs(float u, float resolution){ return (u + (0.5 / resolution)) * (resolution / (resolution + 1.0)); }
float fromSubUvsToUnit(float u, float resolution){ return (u - (0.5 / resolution)) * (resolution / (resolution - 1.0)); }

void UvToLutTransmittanceParams(AtmosphereParameters Atmosphere, out float viewHeight, out float viewZenithCosAngle, in vec2 uv){
  //uv = vec2(fromSubUvsToUnit(uv.x, TRANSMITTANCE_TEXTURE_WIDTH), fromSubUvsToUnit(uv.y, TRANSMITTANCE_TEXTURE_HEIGHT)); // No real impact so off
  float x_mu = uv.x;
  float x_r = uv.y;

  float H = safeSqrt((Atmosphere.TopRadius * Atmosphere.TopRadius) - (Atmosphere.BottomRadius * Atmosphere.BottomRadius));
  float rho = H * x_r;
  float localViewHeight = (rho * rho) + (Atmosphere.BottomRadius * Atmosphere.BottomRadius);
  localViewHeight = safeSqrt(localViewHeight);
  viewHeight = localViewHeight;

  float d_min = Atmosphere.TopRadius - localViewHeight;
  float d_max = rho + H;
  float d = d_min + (x_mu * (d_max - d_min));
  float localViewZenithCosAngle = (d == 0.0) ? 1.0 : (((H * H) - (rho * rho)) - (d * d)) / (2.0 * localViewHeight * d);
  localViewZenithCosAngle = clamp(localViewZenithCosAngle, -1.0, 1.0);
  viewZenithCosAngle = localViewZenithCosAngle;
}

#define NONLINEARSKYVIEWLUT 1
void UvToSkyViewLutParams(AtmosphereParameters Atmosphere, out float viewZenithCosAngle, out float lightViewCosAngle, in float viewHeight, in vec2 uv){
  // Constrain uvs to valid sub texel range (avoid zenith derivative issue making LUT usage visible)
  uv = vec2(fromSubUvsToUnit(uv.x, 256.0), fromSubUvsToUnit(uv.y, 128.0));

  float Vhorizon = sqrt((viewHeight * viewHeight) - (Atmosphere.BottomRadius * Atmosphere.BottomRadius));
  float CosBeta = Vhorizon / viewHeight;				// GroundToHorizonCos
  float Beta = acos(CosBeta);
  float ZenithHorizonAngle = PI - Beta;

  if(uv.y < 0.5){
    float coord = 2.0 * uv.y;
    coord = 1.0 - coord;
#if NONLINEARSKYVIEWLUT
    coord *= coord;
#endif
    coord = 1.0 - coord;
    viewZenithCosAngle = cos(ZenithHorizonAngle * coord);
  }else{
    float coord = fma(uv.y, 2.0, -1.0);
#if NONLINEARSKYVIEWLUT
    coord *= coord;
#endif
    viewZenithCosAngle = cos(ZenithHorizonAngle + Beta * coord);
  }

  float coord = uv.x;
  coord *= coord;
  lightViewCosAngle = -fma(coord, 2.0, -1.0);
}

void SkyViewLutParamsToUv(AtmosphereParameters Atmosphere, in bool IntersectGround, in float viewZenithCosAngle, in float lightViewCosAngle, in float viewHeight, out vec2 uv){
  float Vhorizon = sqrt((viewHeight * viewHeight) - (Atmosphere.BottomRadius * Atmosphere.BottomRadius));
  float CosBeta = Vhorizon / viewHeight;				// GroundToHorizonCos
  float Beta = acos(CosBeta);
  float ZenithHorizonAngle = PI - Beta;

  if(!IntersectGround){
    float coord = acos(viewZenithCosAngle) / ZenithHorizonAngle;
    coord = 1.0 - coord;
#if NONLINEARSKYVIEWLUT
    coord = sqrt(coord);
#endif
    coord = 1.0 - coord;
    uv.y = coord * 0.5;
  }else{
    float coord = (acos(viewZenithCosAngle) - ZenithHorizonAngle) / Beta;
#if NONLINEARSKYVIEWLUT
    coord = sqrt(coord);
#endif
    uv.y = fma(coord, 0.5, 0.5);
  }

  {
    float coord = fma(lightViewCosAngle, -0.5, 0.5);
    coord = sqrt(coord);
    uv.x = coord;
  }

  // Constrain uvs to valid sub texel range (avoid zenith derivative issue making LUT usage visible)
  uv = vec2(fromUnitToSubUvs(uv.x, 256.0), fromUnitToSubUvs(uv.y, 128.0));
}

vec2 raySphereIntersect(vec3 r0, vec3 rd, vec3 s0, float sR){
#if 1
  vec3 sphereCenterToRayOrigin = r0 - s0;
  float a = dot(rd, rd),
        b = dot(rd, sphereCenterToRayOrigin) * 2.0,
        c = dot(sphereCenterToRayOrigin, sphereCenterToRayOrigin) - (sR * sR); 
  float discriminant = (b * b) - ((a * c) * 4.0);
  if(discriminant < 0.0){
    return vec2(-1.0);
  }else if(discriminant == 0.0){
    return vec2((-0.5 * b) / a);
  }else{
    float q = (b + (sqrt(discriminant) * ((b > 0.0) ? 1.0 : -1.0))) * (-0.5);
    return vec2(q / a, c / q);
  }  
#else
  float a = dot(rd, rd);
  vec3 s0_r0 = r0 - s0;
  float b = 2.0 * dot(rd, s0_r0);
  float c = dot(s0_r0, s0_r0) - (sR * sR);
  float delta = (b * b) - (4.0 * a * c);
  if((delta < 0.0) || (a == 0.0)){
    return vec2(-1.0);
  }else{
    return (vec2(-b) + (vec2(sqrt(delta)) * vec2(-1.0, 1.0))) / vec2(2.0 * a);
  }
#endif
}

float raySphereIntersectNearest(vec3 r0, vec3 rd, vec3 s0, float sR){
#if 1
  vec3 sphereCenterToRayOrigin = r0 - s0;
  float a = dot(rd, rd),
        b = dot(rd, sphereCenterToRayOrigin) * 2.0,
        c = dot(sphereCenterToRayOrigin, sphereCenterToRayOrigin) - (sR * sR); 
  float discriminant = (b * b) - ((a * c) * 4.0);
  if(discriminant < 0.0){
    return -1.0;
  }else if(discriminant == 0.0){
    return (-0.5 * b) / a;
  }else{
    float q = (b + (sqrt(discriminant) * ((b > 0.0) ? 1.0 : -1.0))) * (-0.5);
    vec2 t = vec2(q / a, c / q);
    if(all(lessThan(t, vec2(0.0)))){
      return -1.0;
    }else if(t.x < 0.0){
      return max(0.0, t.y);
    }else if(t.y < 0.0){
      return max(0.0, t.x);
    }else{
      return max(0.0, min(t.x, t.y));
    }		
  }  
#else
  float a = dot(rd, rd);
  vec3 s0_r0 = r0 - s0;
  float b = 2.0 * dot(rd, s0_r0);
  float c = dot(s0_r0, s0_r0) - (sR * sR);
  float delta = (b * b) - (4.0 * a * c);
  if((delta < 0.0) || (a == 0.0)){
    return -1.0;
  }else{
    vec2 sol01 = (vec2(-b) + (vec2(sqrt(delta)) * vec2(-1.0, 1.0))) / vec2(2.0 * a);
    if(all(lessThan(sol01, vec2(0.0)))){
      return -1.0;
    }else if(sol01.x < 0.0){
      return max(0.0, sol01.y);
    }else if(sol01.y < 0.0){
      return max(0.0, sol01.x);
    }else{
      return max(0.0, min(sol01.x, sol01.y));
    }		
  }
#endif
}

void LutTransmittanceParamsToUv(const in AtmosphereParameters Atmosphere, in float viewHeight, in float viewZenithCosAngle, out vec2 uv){
  
  float H = sqrt(max(0.0, Atmosphere.TopRadius * Atmosphere.TopRadius - Atmosphere.BottomRadius * Atmosphere.BottomRadius));
  float rho = sqrt(max(0.0, viewHeight * viewHeight - Atmosphere.BottomRadius * Atmosphere.BottomRadius));

  float discriminant = viewHeight * viewHeight * (viewZenithCosAngle * viewZenithCosAngle - 1.0) + Atmosphere.TopRadius * Atmosphere.TopRadius;
  float d = max(0.0, (-viewHeight * viewZenithCosAngle + sqrt(discriminant))); // Distance to atmosphere boundary

  float d_min = Atmosphere.TopRadius - viewHeight;
  float d_max = rho + H;
  float x_mu = (d - d_min) / (d_max - d_min);
  float x_r = rho / H;

  uv = vec2(x_mu, x_r);
  //uv = vec2(fromUnitToSubUvs(uv.x, TRANSMITTANCE_TEXTURE_WIDTH), fromUnitToSubUvs(uv.y, TRANSMITTANCE_TEXTURE_HEIGHT)); // No real impact so off
}

float RayleighPhase(float cosTheta){
  float factor = 3.0 / (16.0 * PI);
  return factor * (1.0 + (cosTheta * cosTheta));
}

float CornetteShanksMiePhaseFunction(float g, float cosTheta){
  float k = ((3.0 / (8.0 * PI)) * (1.0 - (g * g))) / (2.0 + (g * g));
  return (k * (1.0 + (cosTheta * cosTheta))) / pow((1.0 + (g * g)) - (2.0 * g * -cosTheta), 1.5);
}

float hgPhase(float g, float cosTheta){
#ifdef USE_CornetteShanks
  return CornetteShanksMiePhaseFunction(g, cosTheta);
#else
  // Reference implementation (i.e. not schlick approximation). 
  // See http://www.pbr-book.org/3ed-2018/Volume_Scattering/Phase_Functions.html
  float numer = 1.0 - (g * g);
  float denom = 1.0 + (g * g) + (2.0 * g * cosTheta);
  return numer / (4.0 * PI * denom * sqrt(denom));
#endif
}

float DualLobPhase(float g0, float g1, float w, float cosTheta){
  return mix(hgPhase(g0, cosTheta), hgPhase(g1, cosTheta), w);
}

float getAlbedo(float scattering, float extinction){
  return scattering / max(0.001, extinction);
}

vec3 getAlbedo(vec3 scattering, vec3 extinction){
  return scattering / max(vec3(0.001), extinction);
}

struct MediumSampleRGB {
  vec3 scattering;
  vec3 absorption;
  vec3 extinction;

  vec3 scatteringMie;
  vec3 absorptionMie;
  vec3 extinctionMie;

  vec3 scatteringRay;
  vec3 absorptionRay;
  vec3 extinctionRay;

  vec3 scatteringOzo;
  vec3 absorptionOzo;
  vec3 extinctionOzo;

  vec3 albedo;
};

MediumSampleRGB sampleMediumRGB(in vec3 WorldPos, in AtmosphereParameters Atmosphere){

  const float viewHeight = max(1e-4, length(WorldPos) - Atmosphere.BottomRadius);

  const float densityMie = exp(Atmosphere.MieDensityExpScale * viewHeight);
  const float densityRay = exp(Atmosphere.RayleighDensityExpScale * viewHeight);
  const float densityOzo = clamp(viewHeight < Atmosphere.AbsorptionDensity0LayerWidth ?
    fma(Atmosphere.AbsorptionDensity0LinearTerm, viewHeight, Atmosphere.AbsorptionDensity0ConstantTerm) :
    fma(Atmosphere.AbsorptionDensity1LinearTerm, viewHeight, Atmosphere.AbsorptionDensity1ConstantTerm), 
    0.0, 1.0);

  MediumSampleRGB s;

  s.scatteringMie = densityMie * Atmosphere.MieScattering.xyz;
  s.absorptionMie = densityMie * Atmosphere.MieAbsorption.xyz;
  s.extinctionMie = densityMie * Atmosphere.MieExtinction.xyz;

  s.scatteringRay = densityRay * Atmosphere.RayleighScattering.xyz;
  s.absorptionRay = vec3(0.0);
  s.extinctionRay = s.scatteringRay + s.absorptionRay;

  s.scatteringOzo = vec3(0.0);
  s.absorptionOzo = densityOzo * Atmosphere.AbsorptionExtinction.xyz;
  s.extinctionOzo = s.scatteringOzo + s.absorptionOzo;

  s.scattering = s.scatteringMie + s.scatteringRay + s.scatteringOzo;
  s.absorption = s.absorptionMie + s.absorptionRay + s.absorptionOzo;
  s.extinction = s.extinctionMie + s.extinctionRay + s.extinctionOzo;
  s.albedo = getAlbedo(s.scattering, s.extinction);

  return s;
}

vec3 GetMultipleScattering(const in sampler2D MultiScatTexture, AtmosphereParameters Atmosphere, vec3 scattering, vec3 extinction, vec3 worldPos, float viewZenithCosAngle){
  vec2 uv = clamp(vec2(fma(viewZenithCosAngle, 0.5, 0.5), (length(worldPos) - Atmosphere.BottomRadius) / (Atmosphere.TopRadius - Atmosphere.BottomRadius)), vec2(0.0), vec2(1.0));
  uv = vec2(fromUnitToSubUvs(uv.x, MultiScatteringLUTRes), fromUnitToSubUvs(uv.y, MultiScatteringLUTRes));
  vec3 multiScatteredLuminance = textureLod(MultiScatTexture, uv, 0).xyz;
  return multiScatteredLuminance;
}

#ifdef SHADOWS_ENABLED
float getShadow(in AtmosphereParameters Atmosphere, vec3 p){
  if((pushConstants.flags & FLAGS_SHADOWS) != 0u){
    p = (Atmosphere.transform * vec4(p, 1.0)).xyz;
    inWorldSpacePosition = p;
    workNormal = normalize(p);
    return getFastCascadedShadow((Atmosphere.maxShadowDistance > 0.0) ? Atmosphere.maxShadowDistance : 1e7, Atmosphere.inverseOriginTransform);
  }else{
    return 1.0;
  }
}
#endif

vec3 IntegrateOpticalDepth(in vec3 WorldPos,
                           in vec3 WorldDir, 
                           const in AtmosphereParameters Atmosphere,
                           in bool ground, 
                           in float SampleCountIni, 
                           in float tMaxMax, 
                           in bool VariableSampleCount){
  
  if(tMaxMax < 0.0){
    tMaxMax = 9000000.0;
  } 

  // Compute next intersection with atmosphere or ground 
  // TODO:gs another empirical finding. This removes a white pixel stripe in the Transmittance LUT.
  vec3 earthO = vec3(0.0, 0.0, -0.001);
  float tMax = 0.0;
#if 0	
  float tBottom = raySphereIntersectNearest(WorldPos, WorldDir, earthO, Atmosphere.BottomRadius);
  float tTop = raySphereIntersectNearest(WorldPos, WorldDir, earthO, Atmosphere.TopRadius);
  if(tBottom < 0.0){
    if (tTop < 0.0){
      tMax = 0.0; // No intersection with earth nor atmosphere: stop right away  
      return vec3(0.0);
    }else{
      tMax = tTop;
    }
  }else{
    if(tTop > 0.0){
      tMax = min(tTop, tBottom);
    }
  }  
#else
  vec2 SolT = raySphereIntersect(WorldPos, WorldDir, earthO, Atmosphere.TopRadius);
  if(all(lessThan(SolT, vec2(0.0)))){
    tMax = 0.0; // No intersection with earth nor atmosphere: stop right away  
    return vec3(0.0);
  }
  float tBottom = 0.0;
  vec2 SolB = raySphereIntersect(WorldPos, WorldDir, earthO, Atmosphere.BottomRadius);
  if(all(lessThan(SolB, vec2(0.0)))){
    tMax = max(SolT.x, SolT.y);
  }else{
    tMax = tBottom = max(0.0, all(greaterThanEqual(SolB, vec2(0.0))) ? min(SolB.x, SolB.y) : max(SolB.x, SolB.y));	
  }
#endif
  
  tMax = min(tMax, tMaxMax);

  // Sample count 
  float SampleCount = SampleCountIni;
  float SampleCountFloor = SampleCountIni;
  float tMaxFloor = tMax;
  if(VariableSampleCount){
//  SampleCount = mix(RayMarchMinMaxSPP.x, RayMarchMinMaxSPP.y, clamp(tMax * 0.01, 0.0, 1.0));
    SampleCount = clamp(mix(float(Atmosphere.RaymarchingMinSteps), float(Atmosphere.RaymarchingMaxSteps), clamp(tMax * 0.01, 0.0, 1.0)), 0.0, 256.0);
    SampleCountFloor = floor(SampleCount);
    tMaxFloor = tMax * SampleCountFloor / SampleCount;	// rescale tMax to map to the last entire step segment.
  }
  float dt = tMax / SampleCount;

#ifdef ILLUMINANCE_IS_ONE
  // When building the scattering factor, we assume light illuminance is 1 to compute a transfert function relative to identity illuminance of 1.
  // This make the scattering factor independent of the light. It is now only linked to the atmosphere properties.
  vec3 globalL = vec3(1.0);
#else
  vec3 globalL = Atmosphere.SolarIlluminance.xyz * Atmosphere.SolarIlluminance.w; // w = intensity
#endif

  // Ray march the atmosphere to integrate optical depth
  vec3 L = vec3(0.0);
  vec3 throughput = vec3(1.0);
  vec3 OpticalDepth = vec3(0.0);
  float t = 0.0;
  float tPrev = 0.0;
  for (float s = 0.0; s < SampleCount; s += 1.0){
    if (VariableSampleCount){
      // More expenssive but artefact free
      float t0 = (s) / SampleCountFloor;
      float t1 = (s + 1.0) / SampleCountFloor;
      // Non linear distribution of sample within the range.
      t0 = t0 * t0;
      t1 = t1 * t1;
      // Make t0 and t1 world space distances.
      t0 = tMaxFloor * t0;
      if(t1 > 1.0){
        t1 = tMax;
      //t1 = tMaxFloor;	// this reveal depth slices
      }else{
        t1 = tMaxFloor * t1;
      }
      //t = t0 + (t1 - t0) * (whangHashNoise(pixPos.x, pixPos.y, gFrameId * 1920 * 1080)); // With dithering required to hide some sampling artefact relying on TAA later? This may even allow volumetric shadow?
      t = t0 + ((t1 - t0) * SampleSegmentT);
      dt = t1 - t0;
    }else{
      //t = tMax * (s + SampleSegmentT) / SampleCount;
      // Exact difference, important for accuracy of multiple scattering
      float NewT = tMax * (s + SampleSegmentT) / SampleCount;
      dt = NewT - t;
      t = NewT;
    }
    vec3 P = WorldPos + t * WorldDir;

    MediumSampleRGB medium = sampleMediumRGB(P, Atmosphere);
    const vec3 SampleOpticalDepth = medium.extinction * dt;
    OpticalDepth += SampleOpticalDepth;

    tPrev = t;

  }

  return OpticalDepth;
  
}

SingleScatteringResult IntegrateScatteredLuminance(const in sampler2D TransmittanceLutTexture,
#ifdef MULTISCATAPPROX_ENABLED
                                                   const in sampler2D MultiScatTexture, 
#endif
#ifdef ATMOSPHEREMAP_ENABLED
                                                   const in samplerCube AtmosphereMapTexture,
#endif
                                                   in vec2 uv, 
                                                   in vec3 WorldPos, 
                                                   in vec3 WorldDir, 
                                                   in vec3 SunDir, 
                                                   const in AtmosphereParameters Atmosphere,
                                                   in bool ground, 
                                                   in float SampleCountIni, 
                                                   in float DepthBufferValue, 
                                                   in bool VariableSampleCount,
                                                   in bool MieRayPhase, 
                                                   in mat4 SkyInvViewProjMat,
                                                   float tMaxMax,
                                                   in bool reversedZ){
  if(tMaxMax < 0.0){
    tMaxMax = 9000000.0;
  } 

  SingleScatteringResult result = SingleScatteringResult( vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0) );

  // Compute next intersection with atmosphere or ground 
  vec3 earthO = vec3(0.0, 0.0, -0.001);
  float tMax = 0.0;
#if 0	
  float tBottom = raySphereIntersectNearest(WorldPos, WorldDir, earthO, Atmosphere.BottomRadius);
  float tTop = raySphereIntersectNearest(WorldPos, WorldDir, earthO, Atmosphere.TopRadius);
  if(tBottom < 0.0){
    if (tTop < 0.0){
      tMax = 0.0; // No intersection with earth nor atmosphere: stop right away  
      return result;
    }else{
      tMax = tTop;
    }
  }else{
    if(tTop > 0.0){
      tMax = min(tTop, tBottom);
    }
  }  
#else
  vec2 SolT = raySphereIntersect(WorldPos, WorldDir, earthO, Atmosphere.TopRadius);
  if(all(lessThan(SolT, vec2(0.0)))){
    tMax = 0.0; // No intersection with earth nor atmosphere: stop right away  
    return result;
  }
  float tBottom = 0.0;
  vec2 SolB = raySphereIntersect(WorldPos, WorldDir, earthO, Atmosphere.BottomRadius);
  if(all(lessThan(SolB, vec2(0.0)))){
    tMax = max(SolT.x, SolT.y);
  }else{
    tMax = tBottom = max(0.0, all(greaterThanEqual(SolB, vec2(0.0))) ? min(SolB.x, SolB.y) : max(SolB.x, SolB.y));	
  }
#endif

  if(DepthBufferValue >= 0.0){

    vec3 ClipSpace = vec3(fma(uv, vec2(2.0), vec2(-1.0)), DepthBufferValue);

    if((reversedZ && (ClipSpace.z > 0.0)) || (!reversedZ && (ClipSpace.z < 1.0))){

      vec4 DepthBufferWorldPos = SkyInvViewProjMat * vec4(ClipSpace, 1.0);
      DepthBufferWorldPos /= DepthBufferWorldPos.w;

      // Check if the result is valid, because for example in a case of a reverse infinite far Z plane, the depth value can be infinite,
      // where we just ignore this case then, since it is infinite far away anyway. 
      if(!(any(isinf(DepthBufferWorldPos)) || any(isnan(DepthBufferWorldPos)))){

        DepthBufferWorldPos.xyz = (Atmosphere.inverseTransform * vec4(DepthBufferWorldPos.xyz, 1.0)).xyz;

        float tDepth = length(DepthBufferWorldPos.xyz - WorldPos); // apply earth offset to go back to origin as top of earth mode. 
        if(!(isinf(tDepth) || isnan(tDepth))){
          tMax = min(tMax, tDepth);
        }

      }

    }
    /*
    if (VariableSampleCount && ((reversedZ && (ClipSpace.z == 0.0)) || (!reversedZ && (ClipSpace.z == 1.0))){
      return result;
    }*/
  }
  tMax = min(tMax, tMaxMax);

  // Sample count 
  float SampleCount = SampleCountIni;
  float SampleCountFloor = SampleCountIni;
  float tMaxFloor = tMax;
  if(VariableSampleCount){
//  SampleCount = mix(RayMarchMinMaxSPP.x, RayMarchMinMaxSPP.y, clamp(tMax * 0.01, 0.0, 1.0));
    SampleCount = clamp(mix(float(Atmosphere.RaymarchingMinSteps), float(Atmosphere.RaymarchingMaxSteps), clamp(tMax * 0.01, 0.0, 1.0)), 0.0, 256.0);
    SampleCountFloor = floor(SampleCount);
    tMaxFloor = tMax * SampleCountFloor / SampleCount;	// rescale tMax to map to the last entire step segment.
  }
  float dt = tMax / SampleCount;

  // Phase functions
  const float uniformPhase = 1.0 / (4.0 * PI);
  const vec3 wi = SunDir;
  const vec3 wo = WorldDir;
  float cosTheta = dot(wi, wo);
  float MiePhaseValue = hgPhase(Atmosphere.MiePhaseG, -cosTheta);	// mnegate cosTheta because due to WorldDir being a "in" direction. 
  float RayleighPhaseValue = RayleighPhase(cosTheta);

#ifdef ILLUMINANCE_IS_ONE
  // When building the scattering factor, we assume light illuminance is 1 to compute a transfert function relative to identity illuminance of 1.
  // This make the scattering factor independent of the light. It is now only linked to the atmosphere properties.
  vec3 globalL = vec3(1.0);
#else
  vec3 globalL = Atmosphere.SolarIlluminance.xyz * Atmosphere.SolarIlluminance.w; // w = intensity
#endif

  // Ray march the atmosphere to integrate optical depth
  vec3 L = vec3(0.0);
  vec3 throughput = vec3(1.0);
  vec3 OpticalDepth = vec3(0.0);
  float t = 0.0;
  float tPrev = 0.0;
  for (float s = 0.0; s < SampleCount; s += 1.0){
    if (VariableSampleCount){
      // More expenssive but artefact free
      float t0 = (s) / SampleCountFloor;
      float t1 = (s + 1.0) / SampleCountFloor;
      // Non linear distribution of sample within the range.
      t0 = t0 * t0;
      t1 = t1 * t1;
      // Make t0 and t1 world space distances.
      t0 = tMaxFloor * t0;
      if(t1 > 1.0){
        t1 = tMax;
      //t1 = tMaxFloor;	// this reveal depth slices
      }else{
        t1 = tMaxFloor * t1;
      }
      //t = t0 + (t1 - t0) * (whangHashNoise(pixPos.x, pixPos.y, gFrameId * 1920 * 1080)); // With dithering required to hide some sampling artefact relying on TAA later? This may even allow volumetric shadow?
      t = t0 + ((t1 - t0) * SampleSegmentT);
      dt = t1 - t0;
    }else{
      //t = tMax * (s + SampleSegmentT) / SampleCount;
      // Exact difference, important for accuracy of multiple scattering
      float NewT = tMax * (s + SampleSegmentT) / SampleCount;
      dt = NewT - t;
      t = NewT;
    }
    vec3 P = WorldPos + (t * WorldDir);

#ifdef ATMOSPHEREMAP_ENABLED
    // Evaluate atmosphere map, with AtmosphereMapTexture cube map with atmosphere visiblity values
    const float atmosphereFactor = ((Atmosphere.flags & FLAGS_USE_ATMOSPHERE_MAP) != 0u) 
                                     ? textureLod(AtmosphereMapTexture, normalize(P), 0.0).x // 0.0 = no atmosphere, 1.0 = full atmosphere    
                                     : 1.0; // No atmosphere map, so use 1.0 as factor
#endif

    MediumSampleRGB medium = sampleMediumRGB(P, Atmosphere);
    const vec3 SampleOpticalDepth = medium.extinction * 
#ifdef ATMOSPHEREMAP_ENABLED
                                    atmosphereFactor *
#endif
                                    dt;
    const vec3 SampleTransmittance = exp(-SampleOpticalDepth);
    OpticalDepth += SampleOpticalDepth;

    float pHeight = length(P);
    const vec3 UpVector = P / pHeight;
    float SunZenithCosAngle = dot(SunDir, UpVector);
    vec2 uv;
    LutTransmittanceParamsToUv(Atmosphere, pHeight, SunZenithCosAngle, uv);
    vec3 TransmittanceToSun = textureLod(TransmittanceLutTexture, vec2(uv), 0.0).xyz;

    vec3 PhaseTimesScattering;
    if(MieRayPhase){
      PhaseTimesScattering = medium.scatteringMie * MiePhaseValue + medium.scatteringRay * RayleighPhaseValue;
    }else{
      PhaseTimesScattering = medium.scattering * uniformPhase;
    }

    // Earth shadow 
    float tEarth = raySphereIntersectNearest(P, SunDir, earthO + (PLANET_RADIUS_OFFSET * UpVector), Atmosphere.BottomRadius);
    float earthShadow = (tEarth >= 0.0) ? 0.0 : 1.0;

    // Dual scattering for multi scattering 

    vec3 multiScatteredLuminance = vec3(0.0);
#ifdef MULTISCATAPPROX_ENABLED
    multiScatteredLuminance = GetMultipleScattering(MultiScatTexture, Atmosphere, medium.scattering, medium.extinction, P, SunZenithCosAngle);
#endif

    float shadow = 1.0;
#ifdef SHADOWS_ENABLED
    // First evaluate opaque shadow
    shadow = getShadow(Atmosphere, P);
#endif

    vec3 S = globalL * ((earthShadow * shadow * TransmittanceToSun * PhaseTimesScattering) + (multiScatteredLuminance * medium.scattering));

    // When using the power serie to accumulate all sattering order, serie r must be <1 for a serie to converge.
    // Under extreme coefficient, MultiScatAs1 can grow larger and thus result in broken visuals.
    // The way to fix that is to use a proper analytical integration as proposed in slide 28 of http://www.frostbite.com/2015/08/physically-based-unified-volumetric-rendering-in-frostbite/
    // However, it is possible to disable as it can also work using simple power serie sum unroll up to 5th order. The rest of the orders has a really low contribution.
#define MULTI_SCATTERING_POWER_SERIE 1

#if MULTI_SCATTERING_POWER_SERIE==0
    // 1 is the integration of luminance over the 4pi of a sphere, and assuming an isotropic phase function of 1.0/(4*PI)
    result.MultiScatAs1 += throughput * medium.scattering * 1.0 * dt;
#else
    vec3 MS = medium.scattering * 1.0;
    vec3 MSint = (MS - (MS * SampleTransmittance)) / medium.extinction;
    result.MultiScatAs1 += throughput * MSint;
#endif

    // Evaluate input to multi scattering 
    {
      vec3 newMS;

      newMS = earthShadow * TransmittanceToSun * medium.scattering * uniformPhase * 1;
      result.NewMultiScatStep0Out += throughput * (newMS - newMS * SampleTransmittance) / medium.extinction;
      //	result.NewMultiScatStep0Out += SampleTransmittance * throughput * newMS * dt;

      newMS = medium.scattering * uniformPhase * multiScatteredLuminance;
      result.NewMultiScatStep1Out += throughput * (newMS - newMS * SampleTransmittance) / medium.extinction;
      //	result.NewMultiScatStep1Out += SampleTransmittance * throughput * newMS * dt;
    }

#if 0
    L += throughput * S * dt;
    throughput *= SampleTransmittance;
#else
    // See slide 28 at http://www.frostbite.com/2015/08/physically-based-unified-volumetric-rendering-in-frostbite/ 
    vec3 Sint = (S - S * SampleTransmittance) / medium.extinction;	// integrate along the current step segment 
    L += throughput * Sint;														// accumulate and also take into account the transmittance from previous steps
    throughput *= SampleTransmittance;
#endif

    tPrev = t;

  }

  if(ground && (tMax == tBottom) && (tBottom > 0.0)){

    // Account for bounced light off the earth
    vec3 P = WorldPos + (tBottom * WorldDir);
    float pHeight = length(P);

    const vec3 UpVector = P / pHeight;
    float SunZenithCosAngle = dot(SunDir, UpVector);
    vec2 uv;
    LutTransmittanceParamsToUv(Atmosphere, pHeight, SunZenithCosAngle, uv);
    vec3 TransmittanceToSun = textureLod(TransmittanceLutTexture, vec2(uv), 0.0).xyz;

    const float NdotL = clamp(dot(normalize(UpVector), normalize(SunDir)), 0.0, 1.0);
    L += globalL * TransmittanceToSun * throughput * NdotL * Atmosphere.GroundAlbedo.xyz / PI;

  }

  result.L = L * Atmosphere.GroundAlbedo.w; // w = intensity
  result.OpticalDepth = OpticalDepth;
  result.Transmittance = throughput;
  return result;

}

bool MoveToTopAtmosphere(inout vec3 WorldPos, in vec3 WorldDir, in float AtmosphereTopRadius){
  float viewHeight = length(WorldPos);
  if(viewHeight > AtmosphereTopRadius){
    float tTop = raySphereIntersectNearest(WorldPos, WorldDir, vec3(0.0), AtmosphereTopRadius);
    if(tTop >= 0.0){
      vec3 UpVector = WorldPos / viewHeight;
      vec3 UpOffset = UpVector * -PLANET_RADIUS_OFFSET;
      WorldPos = WorldPos + (WorldDir * tTop) + UpOffset;
    }else{
      // Ray is not intersecting the atmosphere
      return false;
    }
  }
  return true; // ok to start tracing
}


float AerialPerspectiveDepthToSlice(float depth){
  return depth * (1.0 / AP_KM_PER_SLICE);
}

float AerialPerspectiveSliceToDepth(float slice){
  return slice * AP_KM_PER_SLICE;
}

vec3 GetAtmosphereTransmittance(const in AtmosphereParameters Atmosphere, 
                                const in sampler2D TransmittanceLutTexture,
                                vec3 WorldPosition, 
                                vec3 WorldDirection){
  if(any(greaterThan(raySphereIntersect(WorldPosition, WorldDirection, vec3(0.0), Atmosphere.BottomRadius), vec2(0.0)))){
    return vec3(0.0);
  }else{
    float pHeight = length(WorldPosition);
    const vec3 UpVector = WorldPosition / pHeight;
    float SunZenithCosAngle = dot(WorldDirection, UpVector);
    vec2 uv;
    LutTransmittanceParamsToUv(Atmosphere, pHeight, SunZenithCosAngle, uv);
    return textureLod(TransmittanceLutTexture, vec2(uv), 0.0).xyz;
  }
}

vec4 GetSunLuminance(vec3 WorldPos, vec3 WorldDir, vec3 sunDirection, float PlanetRadius){
  if (dot(WorldDir, sunDirection) > cos(0.5*0.505*3.14159 / 180.0)){
    float t = raySphereIntersectNearest(WorldPos, WorldDir, vec3(0.0), PlanetRadius);
    if(t < 0.0){ // no intersection
      const vec3 SunLuminance = vec3(1000000.0); // arbitrary. But fine, not use when comparing the models
      return vec4(SunLuminance, 1.0);
    }
  }
  return vec4(0.0);
}

// Code by me (Benjamin Rosseaux):

bool ProjectionMatrixIsReversedZ(const in mat4 projectionMatrix){
  return projectionMatrix[2][3] < -1e-7;
}

bool ProjectionMatrixIsInfiniteFarPlane(const in mat4 projectionMatrix){
  return ProjectionMatrixIsReversedZ(projectionMatrix) && ((abs(projectionMatrix[2][2]) < 1e-7) && (abs(projectionMatrix[3][2]) > 1e-7));
}

float GetZFarDepthValue(const in mat4 projectionMatrix){
  return ProjectionMatrixIsReversedZ(projectionMatrix) ? 0.0 : 1.0;
}

void GetCameraPositionDirection(out vec3 origin, 
                                out vec3 direction,
                                const in mat4 viewMatrix,
                                const in mat4 projectionMatrix,
                                const in mat4 inverseViewMatrix,
                                const in mat4 inverseProjectionMatrix,
                                const in vec2 uv){ 

#ifdef SHADOWMAP

  // For shadow map rendering, we need to compute the origin and direction of the primary ray in the more safe way, for just to be sure.

  bool reversedZ = ProjectionMatrixIsReversedZ(projectionMatrix);

  mat4 inverseViewProjectionMatrix = inverseViewMatrix * inverseProjectionMatrix;

  vec4 nearPlane = inverseViewProjectionMatrix * vec4(fma(uv, vec2(2.0), vec2(-1.0)), reversedZ ? 1.0 : 0.0, 1.0);
  nearPlane /= nearPlane.w;

  vec4 farPlane = inverseViewProjectionMatrix * vec4(fma(uv, vec2(2.0), vec2(-1.0)), reversedZ ? 0.0 : 1.0, 1.0);
  farPlane /= farPlane.w;

  origin = nearPlane.xyz;
  direction = normalize(farPlane.xyz - nearPlane.xyz);

#else

  // For the main rendering, we can use a faster way to compute the origin and direction of the primary ray.

  bool reversedZ = ProjectionMatrixIsReversedZ(projectionMatrix);

  vec4 nearPlane = vec4(fma(uv, vec2(2.0), vec2(-1.0)), reversedZ ? 1.0 : 0.0, 1.0);

  vec4 cameraDirection = vec4((inverseProjectionMatrix * nearPlane).xyz, 0.0); 

#if 0    
  
  // Works also for orthographic projection (and for all projection types)
  
  vec4 primaryRayOrigin = inverseViewProjectionMatrix * nearPlane;
  primaryRayOrigin /= primaryRayOrigin.w;

  origin = primaryRayOrigin.xyz;

#else

  // Works only for perspective projection, not for orthographic projection, but is faster

  origin = inverseViewMatrix[3].xyz;

#endif

  direction = normalize((inverseViewMatrix * cameraDirection).xyz);

#endif

}

#endif