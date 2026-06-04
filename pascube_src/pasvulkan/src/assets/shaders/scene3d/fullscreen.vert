#version 450 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

//layout(location = 0) in vec3 inPosition;

layout(location = 0) out vec2 outTexCoord;

void main(){
#undef OLD
#ifdef OLD
  outTexCoord = vec2((gl_VertexIndex >> 1) * 2.0, (gl_VertexIndex & 1) * 2.0);
  gl_Position = vec4(((gl_VertexIndex >> 1) * 4.0) - 1.0, ((gl_VertexIndex & 1) * 4.0) - 1.0, 0.0, 1.0);
#else
  ivec2 uv = ivec2(ivec2(int(gl_VertexIndex)) << ivec2(0, 1)) & ivec2(2); // ivec2 uv = ivec2(gl_VertexIndex & 2, (gl_VertexIndex << 1) & 2);
  outTexCoord = vec2(uv);
  gl_Position = vec4(vec2(ivec2((uv << ivec2(1)) - ivec2(1))), 0.0, 1.0);
#endif
}
