#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

// layout(location = 0) in vec3 inPosition;

layout(location = 0) out vec3 outPosition;

/* clang-format off */

#include "skybox.glsl"

/* clang-format on */

void main() {
  int vertexID = int(gl_VertexIndex), vertexIndex = vertexID % 3, faceIndex = vertexID / 3, stripVertexID = faceIndex + (((faceIndex & 1) == 0) ? (2 - vertexIndex) : vertexIndex), reversed = int(stripVertexID > 6), index = (reversed == 1) ? (13 - stripVertexID) : stripVertexID;
  outPosition = (vec3(ivec3(int((index < 3) || (index == 4)), reversed ^ int((index > 0) && (index < 4)), reversed ^ int((index < 2) || (index > 5)))) * 2.0) - vec3(1.0);
  View view = uView.views[pushConstants.viewBaseIndex + uint(gl_ViewIndex)];
  gl_Position = ((view.projectionMatrix *                                   //
                  mat4(vec4(view.viewMatrix[0].xyz, 0.0),                   //
                       vec4(view.viewMatrix[1].xyz, 0.0),                   //
                       vec4(view.viewMatrix[2].xyz, 0.0),                   //
                       vec4(vec3(0.0, 0.0, 0.0), view.viewMatrix[2].w))) *  //
                 vec4(outPosition, 1.0))
                    .xyww;
}