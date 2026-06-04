#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragOutput;

layout(set = 0, binding = 0) uniform sampler2DArray uTextureInput;

void main(){
  vec4 offsets = vec3(0.5, -0.5, 0.0).xxyz / textureSize(uTextureInput, 0).xyxy; 
  vec3 uvw = vec3(inTexCoord.xy, gl_ViewIndex); 
  outFragOutput = clamp(
                   textureLod(uTextureInput, uvw - vec3(offsets.xy, 0.0), 0.0) + //
                   textureLod(uTextureInput, uvw - vec3(offsets.zy, 0.0), 0.0) + //
                   textureLod(uTextureInput, uvw + vec3(offsets.zy, 0.0), 0.0) + //
                   textureLod(uTextureInput, uvw + vec3(offsets.xy, 0.0), 0.0), //
                   vec2(0.0, -65536.0).xxxy, //
                   vec2(65504.0, 65536.0).xxxy) * 0.25;
}
