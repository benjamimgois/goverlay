#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

// layout(location = 0) in vec3 inPosition;

layout(location = 0) out vec3 outRayOrigin;
layout(location = 1) out vec3 outRayDirection; // <= needs to be normalized in the fragment shader for spherical coordinates, since it is actually a cube here in the vertex shader   

/* clang-format off */

layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;  //
  uint countViews;     //
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

/* clang-format on */

void main() {
  int vertexID = int(gl_VertexIndex), vertexIndex = vertexID % 3, faceIndex = vertexID / 3, stripVertexID = faceIndex + (((faceIndex & 1) == 0) ? (2 - vertexIndex) : vertexIndex), reversed = int(stripVertexID > 6), index = (reversed == 1) ? (13 - stripVertexID) : stripVertexID;
  View view = uView.views[pushConstants.viewBaseIndex + uint(gl_ViewIndex)];
#if 1
  // The actual standard approach
  outRayOrigin = view.inverseViewMatrix[3].xyz;
#else
  // This approach assumes that the view matrix has no scaling or skewing, but only rotation and translation.
  outRayOrigin = (-view.viewMatrix[3].xyz) * mat3(view.viewMatrix);
#endif 
  outRayDirection = (vec3(ivec3(int((index < 3) || (index == 4)), reversed ^ int((index > 0) && (index < 4)), reversed ^ int((index < 2) || (index > 5)))) * 2.0) - vec3(1.0);
  gl_Position = ((view.projectionMatrix *                                   //
                  mat4(vec4(view.viewMatrix[0].xyz, 0.0),                   //
                       vec4(view.viewMatrix[1].xyz, 0.0),                   //
                       vec4(view.viewMatrix[2].xyz, 0.0),                   //
                       vec4(vec3(0.0, 0.0, 0.0), view.viewMatrix[2].w))) *  //
                 vec4(outRayDirection, 1.0))
                    .xyww;
}