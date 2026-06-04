#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragOutput;

layout(push_constant) uniform PushConstants {
  float maxCoC;
} pushConstants;

layout(set = 0, binding = 0) uniform sampler2DArray uTextureInputs[2];

void main(){
  vec2 inputTextureSize = textureSize(uTextureInputs[0], 0).xy;
  vec2 inverseInputTextureSize = vec2(1.0) / inputTextureSize; 
  vec3 uvw = vec3(inTexCoord.xy, gl_ViewIndex); 
  vec4 inFocus = textureLod(uTextureInputs[0], uvw, 0.0);
  inFocus.xyz = clamp(inFocus.xyz, vec3(0.0), vec3(65504.0));
  float CoC = clamp(inFocus.w, -pushConstants.maxCoC, pushConstants.maxCoC);
  float farFieldAlpha = smoothstep(inverseInputTextureSize.y * 2.0, inverseInputTextureSize.y * 4.0, CoC);
  vec4 blurredDepthOfField = textureLod(uTextureInputs[1], uvw, 0);
  blurredDepthOfField.xyz = clamp(blurredDepthOfField.xyz, vec3(0.0), vec3(65504.0));
  float alpha = max(max(blurredDepthOfField.x, blurredDepthOfField.y), blurredDepthOfField.z);
#if 0
  vec4 color = mix(mix(inFocus, blurredDepthOfField, farFieldAlpha), blurredDepthOfField, blurredDepthOfField.w);
#else
  vec4 color = mix(inFocus, vec4(blurredDepthOfField.xyz, alpha), (farFieldAlpha + blurredDepthOfField.w) - (farFieldAlpha * blurredDepthOfField.w));
#endif
  outFragOutput = vec4(color.xyz, inFocus.w);
}
