#ifndef PLANET_GRASS_GLSL
#define PLANET_GRASS_GLSL

layout(push_constant) uniform PushConstants {

  mat4 modelMatrix; 

  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint maximalCountBladesPerPatch;
  
  float maximumDistance;
  float grassHeight;
  float grassThickness;
  float time;

  uint tileMapResolution;
  uint tileResolution;  
  uint lod;
  int frameIndex; 

  uint timeSeconds; // The current time in seconds
  float timeFractionalSecond; // The current time in fractional seconds
  uint unused0; // Padding to ensure 16-byte alignment
  uint unused1; // Padding to ensure 16-byte alignment

#if defined(MESH_SHADER_EMULATION)
  uint maximalCountTaskIndices;
  uint maximalCountVertices;
  uint maximalCountIndices;
  uint invocationVariants;
#else  
  vec2 jitter;
  uint invocationVariants;
#endif

} pushConstants;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endif
