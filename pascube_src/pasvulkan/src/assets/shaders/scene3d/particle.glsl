#ifndef PARTICLE_GLSL
#define PARTICLE_GLSL

struct Particle {
  vec4 positionAge; // xyz = position, w = age
  vec4 velocityLifeTime; // xyz = velocity, w = life time
  vec4 gravityTime; // xyz = gravity, w = time
  uvec4 colorStartEnd; // xy = start color (half float RGBA), zw = end color (half float RGBA)
  vec4 sizeStartEnd; // xy = start size, zw = end size
  uvec4 rotationStartEndTextureIDFlags; // x = start rotation, z = end rotation, y = texture ID, w = flags
};

struct ParticleVertex {
  vec4 positionRotation; // xyz = position (32-bit float), w = rotation (32-bit float)
  uvec4 quadCoordTextureID; // x = quadCoord (half float XY), y = textureID (32-bit unsigned int), zw = size XY (32-bit floats)
  uvec4 colorUnused; // xy = color (half float RGBA), zw = unused 
  uvec4 unused; // unused
}; // 64 bytes per vertex

#endif