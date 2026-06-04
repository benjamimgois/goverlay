#version 450 core

layout (location = 0) out vec2 outTexCoord;

void main(void){
  outTexCoord = vec2(ivec2(ivec2(ivec2(int(gl_VertexIndex)) << ivec2(1, 0)) & ivec2(2)));
  gl_Position = vec4(fma(outTexCoord, vec2(2.0), vec2(-1.0)), 0.0f, 1.0f);
}