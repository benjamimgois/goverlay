#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(push_constant) uniform PushConstants {
  float bokehChromaticAberration;
  int debug;
} pushConstants;

layout(set = 0, binding = 0) uniform sampler2DArray uTextureInputs[2];

void main(){

  vec2 inputTextureSize = textureSize(uTextureInputs[0], 0).xy; 

  vec2 inverseInputTextureSize = vec2(1.0) / inputTextureSize; 

  vec3 uvw = vec3(inTexCoord.xy, gl_ViewIndex); 
  
  vec4 colorA = textureLod(uTextureInputs[0], uvw, 0.0);
  //vec4 colorB = fma(textureLod(uTextureInputs[1], uvw, 0.0), vec2(1.0, 2.0).xxxy, vec2(0.0, -1.0).xxxy);

  colorA.xyz = clamp(colorA.xyz, vec3(0.0), vec3(65504.0));

  float CoC = colorA.w;

  float fringe = pushConstants.bokehChromaticAberration; 

  vec2 chromaticAberrationFringeOffset = (clamp(abs(colorA.w * inputTextureSize.y), 0.0, 1.0) * fringe) * inverseInputTextureSize.xy;

  vec3 color = vec3(textureLod(uTextureInputs[1], uvw + vec3(vec2(0.0, 1.0) * chromaticAberrationFringeOffset, 0.0), 0.0).x, 
                    textureLod(uTextureInputs[1], uvw + vec3(vec2(-0.866, -0.5) * chromaticAberrationFringeOffset, 0.0), 0.0).y, 
                    textureLod(uTextureInputs[1], uvw + vec3(vec2(0.866, -0.5) * chromaticAberrationFringeOffset, 0.0), 0.0).z); 
  color.xyz = clamp(color.xyz, vec3(0.0), vec3(65504.0));

  color = mix(colorA.xyz, color, smoothstep(1.0 * inverseInputTextureSize.y, 2.0 * inverseInputTextureSize.y, abs(CoC))); 

  if(pushConstants.debug != 0){
   color = mix(color, mix(mix(vec3(0.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0), smoothstep(0.5 * inverseInputTextureSize.y, 1.0 * inverseInputTextureSize.y, CoC)), vec3(0.0, 0.0, 1.0), smoothstep(0.5 * inverseInputTextureSize.y, 1.0 * inverseInputTextureSize.y, -CoC)), 0.125);
  }
  
  outFragColor = vec4(clamp(color.xyz, vec3(-65504.0), vec3(65504.0)), 1.0);                                                                                     

}
