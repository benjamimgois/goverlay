#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (constant_id = 0) const bool PremultiplyWithCoC = true;

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragOutput;

layout(push_constant) uniform PushConstants {
  float maxCoC;
} pushConstants;

layout(set = 0, binding = 0) uniform sampler2DArray uTextureInput;

void main(){
  
  vec2 inputTextureSize = textureSize(uTextureInput, 0).xy; 

  vec2 inverseInputTextureSize = vec2(1.0) / inputTextureSize; 

  vec3 uvw = vec3(inTexCoord.xy, gl_ViewIndex); 

  vec4 redSamples = textureGather(uTextureInput, uvw, 0);
  vec4 greenSamples = textureGather(uTextureInput, uvw, 1);
  vec4 blueSamples = textureGather(uTextureInput, uvw, 2);
  vec4 CoCs = clamp(textureGather(uTextureInput, uvw, 3), vec4(-pushConstants.maxCoC), vec4(pushConstants.maxCoC));

  vec4 c0 = vec4(redSamples.x, greenSamples.x, blueSamples.x, 1.0);
  vec4 c1 = vec4(redSamples.y, greenSamples.y, blueSamples.y, 1.0);
  vec4 c2 = vec4(redSamples.z, greenSamples.z, blueSamples.z, 1.0);
  vec4 c3 = vec4(redSamples.w, greenSamples.w, blueSamples.w, 1.0);

  c0.xyz = clamp(c0.xyz, vec3(0.0), vec3(65504.0));
  c1.xyz = clamp(c1.xyz, vec3(0.0), vec3(65504.0));
  c2.xyz = clamp(c2.xyz, vec3(0.0), vec3(65504.0));
  c3.xyz = clamp(c3.xyz, vec3(0.0), vec3(65504.0));

  // Weights for bleeding and flickering reducation
  vec4 weights = vec4( //
    abs(CoCs.x) / ((max(max(c0.x, c0.y), c0.z) + 1.0) * pushConstants.maxCoC), //
    abs(CoCs.y) / ((max(max(c1.x, c1.y), c1.z) + 1.0) * pushConstants.maxCoC), //
    abs(CoCs.z) / ((max(max(c2.x, c2.y), c2.z) + 1.0) * pushConstants.maxCoC), //
    abs(CoCs.w) / ((max(max(c3.x, c3.y), c3.z) + 1.0) * pushConstants.maxCoC) //
  );

  vec3 average = (c0.xyz * weights.x) + (c1.xyz * weights.y) + (c2.xyz * weights.z) + (c3.xyz * weights.w);
  average /= max(dot(weights, vec4(1.0)), 1e-5);

  vec2 minMaxCoC = vec2( //
    min(min(min(CoCs.x, CoCs.y), CoCs.z), CoCs.w), //
    max(max(max(CoCs.x, CoCs.y), CoCs.z), CoCs.w) //
  );

  // Get the largest CoC
  float CoC = ((-minMaxCoC.x) > minMaxCoC.y) ? minMaxCoC.x : minMaxCoC.y;

  // Premultiply with CoC   
  if(PremultiplyWithCoC){
    average *= smoothstep(0.0, inverseInputTextureSize.y * 2.0, abs(CoC));
  }

  average.xyz = clamp(average.xyz, vec3(0.0), vec3(65504.0));

  outFragOutput = vec4(average, CoC);

}
