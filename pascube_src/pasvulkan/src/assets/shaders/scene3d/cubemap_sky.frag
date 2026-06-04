#version 450 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_viewport_layer_array : enable

layout(location = 0) in vec2 inTexCoord;
layout(location = 1) flat in int inFaceIndex;

layout(location = 0) out vec4 outFragColor;

layout (push_constant) uniform PushConstants {
  vec3 lightDirection;
} pushConstants;

const float HALF_PI = 1.57079632679;
const float PI = 3.1415926535897932384626433832795;
const float TWO_PI = 6.28318530718;

#ifdef FAST
vec4 atmosphereGet(vec3 rayOrigin, vec3 rayDirection){
  vec3 sunDirection = pushConstants.lightDirection;
  vec3 sunLightColor = vec3(1.70, 1.15, 0.70);
  const float atmosphereHaze = 0.03;
  const float atmosphereHazeFadeScale = 1.0;
  const float atmosphereDensity = 0.25;
  const float atmosphereBrightness = 1.0;
  const float atmospherePlanetSize = 1.0;
  const float atmosphereHeight = 1.0;
  const float atmosphereClarity = 10.0;
  const float atmosphereSunDiskSize = 1.0;
  const float atmosphereSunDiskPower = 16.0;
  const float atmosphereSunDiskBrightness = 4.0;
  const float earthRadius = 6.371e6;
  const float earthAtmosphereHeight = 0.1e6;
  const float planetRadius = earthRadius * atmospherePlanetSize;
  const float planetAtmosphereRadius = planetRadius + (earthAtmosphereHeight * atmosphereHeight);
  const vec3 atmosphereRadius = vec3(planetRadius, planetAtmosphereRadius * planetAtmosphereRadius, (planetAtmosphereRadius * planetAtmosphereRadius) - (planetRadius * planetRadius));
  const float gm = mix(0.75, 0.9, atmosphereHaze);
  const vec3 lambda = vec3(680e-9, 550e-9, 450e-9);
  const vec3 brt = vec3(1.86e-31 / atmosphereDensity) / pow(lambda, vec3(4.0));
  const vec3 bmt = pow(vec3(2.0 * PI) / lambda, vec3(2.0)) * vec3(0.689235, 0.6745098, 0.662745) * atmosphereHazeFadeScale * (1.36e-19 * max(atmosphereHaze, 1e-3));
  const vec3 brmt = (brt / vec3(1.0 + atmosphereClarity)) + bmt;
  const vec3 br = (brt / brmt) * (3.0 / (16.0 * PI));
  const vec3 bm = (bmt / brmt) * (((1.0 - gm) * (1.0 - gm)) / (4.0 * PI));
  const vec3 brm = brmt / 0.693147180559945309417;
  const float sunDiskParameterY1 = -(1.0 - (0.0075 * atmosphereSunDiskSize));
  const float sunDiskParameterX = 1.0 / (1.0 + sunDiskParameterY1);
  const vec4 sunDiskParameters = vec4(sunDiskParameterX, sunDiskParameterX * sunDiskParameterY1, atmosphereSunDiskBrightness, atmosphereSunDiskPower);
  float cosTheta = dot(rayDirection, -sunDirection);
  float a = atmosphereRadius.x * max(rayDirection.y, min(-sunDirection.y, 0.0));
  float rayDistance = sqrt((a * a) + atmosphereRadius.z) - a;
  vec3 extinction = exp(-(rayDistance * brm));
  vec3 position = rayDirection * (rayDistance * max(0.15 - (0.75 * sunDirection.y), 0.0));
  position.y = max(position.y, 0.0) + atmosphereRadius.x;
  a = dot(position, -sunDirection);
  float sunLightRayDistance = sqrt(((a * a) + atmosphereRadius.y) - dot(position, position)) - a;
  vec3 inscattering = ((exp(-(sunLightRayDistance * brm)) *
                        ((br * (1.0 + (cosTheta * cosTheta))) +
                         (bm * pow(1.0 + gm * (gm - (2.0 * cosTheta)), -1.5))) * (1.0 - extinction)) *
                       vec3(1.0)) + 
                      (sunDiskParameters.z *
                       extinction *
                       sunLightColor *
                       pow(clamp((cosTheta * sunDiskParameters.x) + sunDiskParameters.y, 0.0, 1.0), sunDiskParameters.w));
  return vec4(inscattering * atmosphereBrightness, 1.0);
}
#else
const float luxScale = 1e-4;
const float planetScale = 1e0;
const float planetInverseScale = 1.0 / planetScale;
const float cameraScale = 1e-0 * planetScale;
const float cameraInverseScale = 1.0 / cameraScale;
const float planetDensityScale = 1.0 * planetInverseScale;
const float planetGroundRadius = 6360.0 * planetScale;
const float planetAtmosphereRadius = 6460.0 * planetScale;
const float cameraHeightOverGround = 1e-3 * planetScale;
const float planetWeatherMapScale = 16.0 / planetAtmosphereRadius;
const float planetAtmosphereHeight = planetAtmosphereRadius - planetGroundRadius;
const float heightScaleRayleigh = 8.0 * planetScale;
const float heightScaleMie = 1.2 * planetScale;
const float heightScaleOzone = 8.0 * planetScale;
const float heightScaleAbsorption = 8.0 * planetScale;
const float planetToSunDistance = 149597870.61 * planetScale;
const float sunRadius = 696342.0 * planetScale;
const float sunIntensity = 100000.0 * luxScale;
const vec3 scatteringCoefficientRayleigh = vec3(5.8e-3, 1.35e-2, 3.31e-2) * planetInverseScale;
const vec3 scatteringCoefficientMie = vec3(21e-3, 21e-3, 21e-3) * planetInverseScale;
const vec3 scatteringCoefficientOzone = vec3(3.486, 8.298, 0.356) * planetInverseScale;
const vec3 scatteringCoefficientAbsorption = vec3(3.486e-3, 8.298e-3, 0.356e-3) * planetInverseScale;
const float skyTurbidity = 0.2;
const float skyMieCoefficientG = 0.98;

vec2 intersectSphere(vec3 rayOrigin, vec3 rayDirection, vec4 sphere){
  vec3 v = rayOrigin - sphere.xyz;
  float b = dot(v, rayDirection),
        c = dot(v, v) - (sphere.w * sphere.w),
        d = (b * b) - c;
  return (d < 0.0)
             ? vec2(-1.0)
             : ((vec2(-1.0, 1.0) * sqrt(d)) - vec2(b));
}

void getAtmosphereParticleDensity(const in vec4 planetGroundSphere,
                                  const in float inverseHeightScaleRayleigh,
                                  const in float inverseHeightScaleMie,
                                  const in vec3 position,
                                  inout float rayleigh,
                                  inout float mie){
  float height = length(position - planetGroundSphere.xyz) - planetGroundSphere.w;
  rayleigh = exp(-(height * inverseHeightScaleRayleigh));
  mie = exp(-(height * inverseHeightScaleMie));
}

void getAtmosphere(vec3 rayOrigin,
                   vec3 rayDirection,
                   const in float startOffset,
                   const in float maxDistance,
                   const in vec3 lightDirection,
                   const in float lightIntensity,
                   const float turbidity,
                   const float meanCosine,
                   const in int countSteps,
                   const in int countSubSteps,
                   out vec3 inscattering,
                   out vec3 extinction){
  float atmosphereHeight = planetAtmosphereRadius - planetGroundRadius;
  vec4 planetGroundSphere = vec4(0.0, -(planetGroundRadius + cameraHeightOverGround), 0.0, planetGroundRadius);
  vec4 planetAtmosphereSphere = vec4(0.0, -(planetGroundRadius + cameraHeightOverGround), 0.0, planetAtmosphereRadius);
  vec2 planetAtmosphereIntersection = intersectSphere(rayOrigin, rayDirection, planetAtmosphereSphere);
  if(planetAtmosphereIntersection.y >= 0.0){
    vec2 planetGroundIntersection = intersectSphere(rayOrigin, rayDirection, planetGroundSphere);
    if(!((planetGroundIntersection.x < 0.0) && (planetGroundIntersection.y >= 0.0))){
      float inverseHeightScaleRayleigh = 1.0 / heightScaleRayleigh,
            inverseHeightScaleMie = 1.0 / heightScaleMie;
      vec2 nearFar = vec2(max(0.0, ((planetGroundIntersection.x < 0.0) && (planetGroundIntersection.y >= 0.0))
                                     ? max(planetGroundIntersection.y, planetAtmosphereIntersection.x)
                                     : planetAtmosphereIntersection.x),
                          (planetGroundIntersection.x >= 0.0)
                           ? min(planetGroundIntersection.x, planetAtmosphereIntersection.y)
                           : planetAtmosphereIntersection.y);
      float fullRayLength = min(maxDistance, nearFar.y - nearFar.x);
      rayOrigin += nearFar.x * rayDirection;
      float timeStep = 1.0 / float(countSteps),
            time = startOffset * timeStep,
            densityScale = fullRayLength / countSteps;
      vec3 inscatteringRayleigh = vec3(0.0);
      vec3 inscatteringMie = vec3(0.0);
      float totalParticleDensityRayleigh = 0.0;
      float totalParticleDensityMie = 0.0;
      for (int stepIndex = 0; stepIndex < countSteps; stepIndex++, time += timeStep){
        float offset = time * fullRayLength;
        vec3 position = rayOrigin + (rayDirection * offset);
        float particleDensityRayleigh, particleDensityMie;
        getAtmosphereParticleDensity(planetGroundSphere,
                                     inverseHeightScaleRayleigh,
                                     inverseHeightScaleMie,
                                     position,
                                     particleDensityRayleigh,
                                     particleDensityMie);
        particleDensityRayleigh *= densityScale;
        particleDensityMie *= densityScale;
        totalParticleDensityRayleigh += particleDensityRayleigh;
        totalParticleDensityMie += particleDensityMie;
        if(densityScale > 0.0){
          vec2 outAtmosphereIntersection = intersectSphere(position, lightDirection, planetAtmosphereSphere);
          float subRayLength = outAtmosphereIntersection.y;
          if(subRayLength > 0.0){
            float dls = subRayLength / float(countSubSteps),
                  subTotalParticleDensityRayleigh = 0.0,
                  subTotalParticleDensityMie = 0.0;
            float subTimeStep = 1.0 / float(countSubSteps),
                  subTime = 0.0,
                  subDensityScale = subRayLength / float(countSubSteps);
            for(int subStepIndex = 0; subStepIndex < countSubSteps; subStepIndex++, subTime += subTimeStep){
              float subParticleDensityRayleigh, subParticleDensityMie;
              vec3 subPosition = position + (lightDirection * subTime * subRayLength);
              getAtmosphereParticleDensity(planetGroundSphere,
                                           inverseHeightScaleRayleigh,
                                           inverseHeightScaleMie,
                                           subPosition,
                                           subParticleDensityRayleigh,
                                           subParticleDensityMie);
              subTotalParticleDensityRayleigh += subParticleDensityRayleigh * subDensityScale;
              subTotalParticleDensityMie += subParticleDensityMie * subDensityScale;
            }
            vec3 totalOpticalDepthRayleigh = scatteringCoefficientRayleigh * (totalParticleDensityRayleigh + subTotalParticleDensityRayleigh);
            vec3 totalOpticalDepthMie = scatteringCoefficientMie * (totalParticleDensityMie + subTotalParticleDensityMie);
            vec3 totalExtinction = exp(-(totalOpticalDepthRayleigh +
                                         totalOpticalDepthMie));
            vec3 differentialInscatteringAmountRayleigh = particleDensityRayleigh * scatteringCoefficientRayleigh * totalExtinction;
            vec3 differentialInscatteringAmountMie = particleDensityMie * scatteringCoefficientMie * totalExtinction;
            float visibility = 1.0;
            inscatteringRayleigh += differentialInscatteringAmountRayleigh * visibility;
            inscatteringMie += differentialInscatteringAmountMie * visibility;
          }  
        }
      }
      float cosTheta = dot(rayDirection, lightDirection),
            onePlusCosThetaMulCosTheta = 1.0 + (cosTheta * cosTheta),
            meanCosineSquared = meanCosine * meanCosine,
            phaseRayleigh = (3.0 / (16.0 * PI)) * onePlusCosThetaMulCosTheta,
            phaseMie = ((3.0 / (8.0 * PI)) * (1.0 - meanCosineSquared) * onePlusCosThetaMulCosTheta) /
                       ((2.0 + meanCosineSquared) * pow((1.0 + meanCosineSquared) - (2.0 * meanCosine * cosTheta), 1.5));
      inscattering = max(vec3(0.0),
                         ((inscatteringRayleigh * phaseRayleigh) +
                          (inscatteringMie * phaseMie * turbidity)) *
                         lightIntensity);
      extinction = max(vec3(0.0),
                       exp(-((totalParticleDensityRayleigh * scatteringCoefficientRayleigh) +
                             (totalParticleDensityMie * scatteringCoefficientMie))));
    }else{
      inscattering = vec3(0.0);
      extinction = vec3(1.0);
    }
  }else{
    inscattering = vec3(0.0);
    extinction = vec3(1.0);
  }
}
#endif

vec3 getCubeMapDirection(in vec2 uv,
                         in int faceIndex){
  vec3 zDir = vec3(ivec3((faceIndex <= 1) ? 1 : 0,
                         (faceIndex & 2) >> 1,
                         (faceIndex & 4) >> 2)) *
             (((faceIndex & 1) == 1) ? -1.0 : 1.0),
       yDir = (faceIndex == 2)
                ? vec3(0.0, 0.0, 1.0)
                : ((faceIndex == 3)
                     ? vec3(0.0, 0.0, -1.0)
                     : vec3(0.0, -1.0, 0.0)),
       xDir = cross(zDir, yDir);
  return normalize((mix(-1.0, 1.0, uv.x) * xDir) +
                   (mix(-1.0, 1.0, uv.y) * yDir) +
                   zDir);
}

void main(){
  vec3 direction = getCubeMapDirection(inTexCoord, inFaceIndex);
#ifdef FAST
  outFragColor = atmosphereGet(vec3(0.0), direction);
#else
  vec3 tempInscattering, tempTransmittance;
  getAtmosphere(vec3(0.0, 0.0, 0.0),
                vec3(direction.x, max(0.0, direction.y), direction.z),
                0.0,
                1e+32,
                -normalize(pushConstants.lightDirection),
                sunIntensity,
                skyTurbidity,
                skyMieCoefficientG,
                256,
                32,
                tempInscattering,
                tempTransmittance);
  outFragColor = vec4(tempInscattering, 1.0);
#endif
}
