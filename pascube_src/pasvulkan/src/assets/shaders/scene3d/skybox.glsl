#ifndef SKYBOX_GLSL
#define SKYBOX_GLSL

layout(push_constant) uniform PushConstants {

  mat4 orientation;
  
  vec4 lightDirection;

  uint viewBaseIndex;  //
  uint countViews;     //
  float skyBoxBrightnessFactor; //
  uint widthHeight;    // low 16 bits: width, high 16 bits: height

  uint mode;           // 0: cube map, 1: realtime starlight

} pushConstants;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 0, binding = 0, std140) uniform uboViews {
   View views[256];
} uView;

#endif