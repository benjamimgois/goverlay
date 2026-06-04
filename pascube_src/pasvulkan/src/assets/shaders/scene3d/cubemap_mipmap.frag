#version 450 core

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 inTexCoord;
layout(location = 1) flat in int inFaceIndex;

layout(location = 0) out vec4 outFragColor;

layout (push_constant) uniform PushConstants {
  int mipMapLevel;
  int maxMipMapLevel;
} pushConstants;

layout (set = 0, binding = 0) uniform samplerCube uTexture;

vec3 getCubeMapDirection(in vec2 uv,
                         in int faceIndex){                        
  vec3 zDir = vec3(ivec3((faceIndex <= 1) ? 1 : 0,
                         (faceIndex & 2) >> 1,
                         (faceIndex & 4) >> 2)) *
             (((faceIndex & 1) == 1) ? -1.0 : 1.0),
       yDir = (faceIndex == 2)
                ? vec3(0.0, 0.0, 1.0)
                : ((faceIndex == 3)
                     ? vec3(0.0, 0.0, -1.0)
                     : vec3(0.0, -1.0, 0.0)),
       xDir = cross(zDir, yDir);
  return normalize((mix(-1.0, 1.0, uv.x) * xDir) +
                   (mix(-1.0, 1.0, uv.y) * yDir) +
                   zDir);
}

void main(){
  vec2 texCoord = inTexCoord + (vec2(0.5) / vec2(textureSize(uTexture, 0).xy));//max(0, mipMapLevel)).xy));
  vec3 direction = getCubeMapDirection(texCoord, inFaceIndex);
  outFragColor = textureLod(uTexture, direction, 0.0);  
}