#version 450

#pragma shader_stage(fragment)

layout(constant_id = 0) const int SSAO_KERNEL_SIZE = 64;

layout(constant_id = 1) const float SSAO_KERNEL_RADIUS = 0.5;

layout(constant_id = 2) const int COUNT_VIEWS = 2;

layout(location = 0) in vec4 inColor;

layout(location = 0) out vec4 outColor;

layout(binding = 0, set = 0) uniform inUniformBuffer {
  mat4 modelViewProjectionMatrix[COUNT_VIEWS];
  vec4 testVector;
} uboGlobals;

layout(push_constant) uniform PushConstants {
  layout(offset = 0) mat4 transformMatrix;
  layout(offset = 64) mat4 fillMatrix;
} pushConstants;

layout(binding = 1, set = 0) buffer inShaderStorageBuffer {
  vec4 testVectors[2][2];
  mat4 bones[];
} ssboGlobals;

void main(){
  outColor = inColor + vec4(ivec4(SSAO_KERNEL_SIZE));
}

 
