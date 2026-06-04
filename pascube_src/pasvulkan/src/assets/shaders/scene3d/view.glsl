#ifndef VIEW_GLSL
#define VIEW_GLSL

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;  
}; // (64*4) = 56 bytes 

// 65536 / 256 = 256 views per uniform buffer (64kb limit)

#endif