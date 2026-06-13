#ifndef PLANET_DATA_GLSL
#define PLANET_DATA_GLSL

#if 0
struct PlanetMaterial {
  uint albedo;
  uint normalHeight;
  uint occlusionRoughnessMetallic;
  float scale;
}; 
#define GetRaytracingPlanetMaterialAlbedoTextureIndex(m) (m).albedo
#define GetRaytracingPlanetMaterialNormalHeightTextureIndex(m) (m).normalHeight
#define GetRaytracingPlanetMaterialOcclusionRoughnessMetallicTextureIndex(m) (m).occlusionRoughnessMetallic
#define GetRaytracingPlanetMaterialScale(m) (m).scale
#else
#define PlanetMaterial uvec4  // x = albedo, y = normalHeight, z = occlusionRoughnessMetallic, w = scale (float)
#define GetPlanetMaterialAlbedoTextureIndex(m) (m).x
#define GetPlanetMaterialNormalHeightTextureIndex(m) (m).y
#define GetPlanetMaterialOcclusionRoughnessMetallicTextureIndex(m) (m).z
#define GetPlanetMaterialScale(m) (uintBitsToFloat((m).w))
#endif

#if defined(USE_PLANET_BUFFER_REFERENCE)
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer PlanetData 
#else
layout(set = 2, binding = 1, std430) readonly buffer PlanetData 
#endif
{

  mat4 modelMatrix;

  mat4 triplanarMatrix;

  mat4 normalMatrix; // normalMatrix = mat4(adjugate(modelMatrix))) for to save computation in the shader, and mat4 instead of mat3 for alignment/padding rules of std430

  mat4 triplanarNormalMatrix;

  vec4 bottomRadiusTopRadiusHeightMapScale; // x = bottomRadius, y = topRadius, z = heightMapScale, w = unused

  uvec4 flagsResolutions; // x = flags, y = resolution (2x 16-bit: tile map resolution, tile resolution), z = WaterMapResolution

  uvec4 verticesIndices; // xy = vertices device address, zw = indices device address

  vec4 selected; // xyz = octahedral map coordinates, w = radius   

  uvec4 selectedColorBrushIndexBrushRotation; // xy = selected color (16-bit half float vec4), z = brush index, w = brush rotation

  vec4 minMaxHeightFactor; // x = min height, y = min factor, z = max height, w = max factor

  float selectedInnerRadius;
  float heightFactorExponent;
  uint waterRippleMapResolution; // The resolution of the water ripple ping-pong image
  uint waterRippleReadIndex; // 0 or 1, selects which of PLANET_TEXTURE_WATERRIPPLEMAP_PING/PONG is the current read target
  
  uvec4 waterAbsorptionDeepColor; // xy = 4x16-bit half float vec4 (xyz = Beer-Lambert absorption 1/m, w = legacy-fade amount 0..1), zw = 4x16-bit half float vec4 (xyz = deep water scattering color linear, w = unused)

  uvec4 waterBaseColorIORs; // xy = 4x16-bit half float vec4 (xyz = water base color linear, w = unused), zw = 4x16-bit half float vec4 (x = waterIOR, y = airIOR, zw = unused)

  uvec4 waterShoreFoam; // xy = 4x16-bit half float vec4 (xyz = foam color linear, w = foam depth start meters), zw = 4x16-bit half float vec4 (x = foam depth end meters, y = pattern scale, z = scroll speed, w = foam intensity 0..1)

  uvec4 waterShoreFoamExtra; // x = half2(breakupLow, breakupHigh), yzw = unused

  uvec4 waterWaveParams; // xy = half4(windDirX, windDirY, windDirZ, waveAmplitude), zw = half4(waveFrequency, waveSteepness, waveSpeed, whitecapFactor)

  uvec4 waterUVWaveParams; // xy = half4(uvWaveAmplitude, uvWaveFrequency, uvWaveSpeed, uvWaveSteepness), zw = half4(uvWaveFactor, waveWindFactor, uvWaveScale, unused)

  uvec4 waterDisplaceParams; // xy = half4(waveDisplaceAmplitude, displaceHeightLowThreshold, displaceHeightHighThreshold, displaceHeightFactor), zw = padding

  uvec4 waterCausticParams; // xy = half4(causticIntensity, causticScale, causticFadeDepth, causticSpeed), zw = half4(causticDepthThresholdLow, causticDepthThresholdHigh, unused, unused)

  uvec4 waterCausticParams2; // xy = half4(tintR, tintG, tintB, unused), zw = padding

  uvec4 waterWhitecapParams; // xy = half4(colorR, colorG, colorB, patternScale), zw = half4(slopeThreshLow, slopeThreshHigh, breakupLow, breakupHigh)

  uvec4 waterWhitecapParams2; // x = half2(whitecapFactor, unused), yzw = unused

  uvec4 waterRainSplashParams; // xy = half4(cellSize, amplitude, ringFreq, envSharp), zw = half4(crownSharp, crownAmp, lifetime, waveSpeed)
  uvec4 waterRainSplashParams2; // xy = half4(normalStrength, depthThresholdLow, depthThresholdHigh, unused), zw = unused/padding

  PlanetMaterial materials[16];

}
#if defined(USE_PLANET_BUFFER_REFERENCE)
;
#else
planetData;
#endif

#endif