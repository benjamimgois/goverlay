#ifndef MESH_PUSHCONSTANTS_GLSL
#define MESH_PUSHCONSTANTS_GLSL

layout (push_constant) uniform PushConstants {
  
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint frameIndex;
  
  vec4 jitter;
  
  uvec4 timeSecondsTimeFractionalSecondWidthHeight; // x = timeSeconds (uint), y = timeFractionalSecond (float), z = width, w = height
  
  uint raytracingFlags;
  uint drawFlags; // bit 0 = meshlet debug colors, bit 3 = meshlet culling enabled, bit 4 = reversed Z
  uint textureDepthIndex;
  uint meshDrawCommandsBDALow; // Low 32 bits of mesh draw commands buffer BDA (mesh shader path)
  uint meshDrawCommandsBDAHigh; // High 32 bits of mesh draw commands buffer BDA (mesh shader path)
  
} pushConstants;

#endif