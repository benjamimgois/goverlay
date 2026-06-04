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
  uint reserved1;
  uint reserved2;
  
  PlanetMaterial materials[16];

}
#if defined(USE_PLANET_BUFFER_REFERENCE)
;
#else
planetData;
#endif

#endif