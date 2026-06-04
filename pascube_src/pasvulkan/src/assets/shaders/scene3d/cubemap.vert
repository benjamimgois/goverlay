#version 450 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
//#extension GL_AMD_vertex_shader_layer : enable
#extension GL_ARB_shader_viewport_layer_array : enable

//layout(location = 0) in vec3 inPosition;

layout(location = 0) out vec2 outTexCoord;
layout(location = 1) flat out int outFaceIndex;

void main(){
  // For 18 vertices (6x attribute-less-rendered "full-screen" triangles)
  int vertexID = int(gl_VertexIndex),
      vertexIndex = vertexID % 3,
      faceIndex = vertexID / 3;
  outTexCoord = vec2((vertexIndex >> 1) * 2.0, (vertexIndex & 1) * 2.0);
  outFaceIndex = faceIndex;
  gl_Position = vec4(((vertexIndex >> 1) * 4.0) - 1.0, ((vertexIndex & 1) * 4.0) - 1.0, 0.0, 1.0);
  gl_Layer = faceIndex;
}
