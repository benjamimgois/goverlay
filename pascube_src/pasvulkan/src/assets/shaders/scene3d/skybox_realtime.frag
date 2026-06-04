#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec3 inPosition;

layout(location = 0) out vec4 outFragColor;

layout (push_constant) uniform PushConstants {
  vec3 lightDirection;
} pushConstants;

const float HALF_PI = 1.57079632679;
const float PI = 3.1415926535897932384626433832795;
const float TWO_PI = 6.28318530718;

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
  vec3 inscattering = ((exp(-(sunLightRayDistance * brm)) * //
                        ((br * (1.0 + (cosTheta * cosTheta))) + //
                         (bm * pow(1.0 + gm * (gm - (2.0 * cosTheta)), -1.5))) * (1.0 - extinction)) * //
                       vec3(1.0)) + //
                      (sunDiskParameters.z * //
                       extinction * //
                       sunLightColor * //
                       pow(clamp((cosTheta * sunDiskParameters.x) + sunDiskParameters.y, 0.0, 1.0), sunDiskParameters.w)); //
  return vec4(inscattering * atmosphereBrightness, 1.0);
}

void main(){
   vec4 color = atmosphereGet(vec3(0.0), normalize(inPosition));
   outFragColor = vec4(clamp(color.xyz, vec3(-65504.0), vec3(65504.0)), color.w);
}