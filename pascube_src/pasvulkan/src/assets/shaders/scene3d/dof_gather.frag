#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

#ifdef PASS1
layout(location = 0) out vec4 outFragColor0;
layout(location = 1) out vec4 outFragColor1;
#else
layout(location = 0) out vec4 outFragColor;
#endif

layout(push_constant) uniform PushConstants {
  int countSamples;
} pushConstants;

#ifdef PASS1
layout(set = 0, binding = 0) uniform sampler2DArray uTextureInput;
#else
layout(set = 0, binding = 0) uniform sampler2DArray uTextureInputs[2];
#endif

float doGatherAndApply(const in sampler2DArray inputTexture,
                       const in vec3 uvw, 
                       const in float LOD,
                       const in float baseCoC, 
                       const in float stepDistance, 
                       const in vec2 inputTextureSize, 
                       inout vec4 color){
  
  vec4 sampleColor = textureLod(inputTexture, uvw, LOD);
  sampleColor.xyz = clamp(sampleColor.xyz, vec3(0.0), vec3(65504.0));

  // CoC < 0.0 means the pixel is in front of the focal plane.
  bool blurNear = sampleColor.w < 0.0;
  float absoluteCoC = abs(sampleColor.w);

  float sampleFraction = 0.0;
  
  // Check if the CoC of the sampled pixel is big enough to scatter here, and
  // the sampled pixel is in front of the focal plane or
  // this pixel is behind the focal plane and the sampled pixel isn't too far behind it.
  if((absoluteCoC > stepDistance) && (blurNear || ((baseCoC > 0.0) && (absoluteCoC < (baseCoC * 2.0))))){
    // Sort out the CoC of the blurred image, by taking to biggest CoC to maintain the
    // hexagon shape in the second pass.
    // Near-blurred pixels should continue to blur over far pixels. Far pixels don't blur
    // over near pixels so that case can be ignored.
    if(blurNear){
      if(color.w < 0.0){
        // This pixel is already near-blurred, so see if the sampled CoC is any bigger.
        color.w = min(color.w, sampleColor.w);
      }else{
        // This pixel is behind the focal plane, so only continue with the near-blur if
        // that is stronger. Going to get artifacts either way on depth edges with different
        // colored pixels.
        if((-sampleColor.w) > color.w){
          color.w = sampleColor.w;
        }
      }
    }
    // Now accumulate the color. Allow partial sampling at the pixel boundary for smoothness.
    sampleFraction = clamp((absoluteCoC - stepDistance) * inputTextureSize.y, 0.0, 1.0);
    color.xyz += sampleColor.xyz * sampleFraction;
  }
  
  return sampleFraction;
}

const int LOD = 0;

void main(){
#ifdef PASS1
  vec2 inputTextureSize = textureSize(uTextureInput, LOD).xy; 

  vec2 inverseInputTextureSize = vec2(1.0) / inputTextureSize; 

  vec3 uvw = vec3(inTexCoord.xy, gl_ViewIndex); 
  
  // Start by sampling at the center of the blur.
  vec4 baseColor = textureLod(uTextureInput, uvw, float(LOD));
  baseColor.xyz = clamp(baseColor.xyz, vec3(0.0), vec3(65504.0));

  // Final color and CoC size will be accumulated in the output.
  vec4 outputA = vec4(vec3(0.0), baseColor.w);
  vec4 outputB = outputA;

  // Sample over the full extent to fake our pseudo-scatter. Keep count of how much of each sample was added.
  float sampleCountA = 0.0;  
  float sampleCountB = 0.0;
  
  // Diagonal blur step, corrected for aspect ratio. 
  float stepX = 0.866 * (inverseInputTextureSize.x / inverseInputTextureSize.y);

  for(int i = 0, j = pushConstants.countSamples; i < j; i++){
    float stepDistance = (float(i) + 0.5) * inverseInputTextureSize.y;
    sampleCountA += doGatherAndApply(uTextureInput, uvw + (vec3(0.0, 1.0, 0.0) * stepDistance), float(LOD), baseColor.w, stepDistance, inputTextureSize, outputA);  // Vertical blur.
    sampleCountB += doGatherAndApply(uTextureInput, uvw + (vec3(stepX, -0.5, 0.0) * stepDistance), float(LOD), baseColor.w, stepDistance, inputTextureSize, outputB); // Diagonal blur.
  }
   
  // Normalise if any colour was added.
  outputA.xyz = (sampleCountA > 0.0) ? (outputA.xyz / sampleCountA) : baseColor.xyz;
  outputB.xyz = (sampleCountB > 0.0) ? (outputB.xyz / sampleCountB) : baseColor.xyz;

  // The second render target contains both of these added together. Don't divide
  // by two here, as it'll be combined again and divided by three in the next pass.
  outputB.xyz += outputA.xyz;

  // For the combined term, set the CoC to the blurriest of the two inputs.
  if(abs(outputA.w) > abs(outputB.w)){
    outputB.w = outputA.w;
  }
  
  outFragColor0 = vec4(outputA.xyz, clamp(outputA.w, -1.0, 1.0));
  outFragColor1 = vec4(outputB.xyz, clamp(outputB.w, -1.0, 1.0));
#else
  vec2 inputTextureSize = textureSize(uTextureInputs[0], LOD).xy; 

  vec2 inverseInputTextureSize = vec2(1.0) / inputTextureSize; 

  vec3 uvw = vec3(inTexCoord.xy, gl_ViewIndex); 

  // Use the combined output as the base for the second pass.
  vec4 baseColor = textureLod(uTextureInputs[1], uvw, float(LOD));
  baseColor.xyz = clamp(baseColor.xyz, vec3(0.0), vec3(65504.0));

  // Two sets of colour to accumulate this time.
  vec4 outputA = vec4(vec3(0.0), baseColor.w);
  vec4 outputB = outputA;
  
  float sampleCountA = 0.0;
  float sampleCountB = 0.0;
  
  // Diagonal passes in different directions for each input texture.
  float stepX = 0.866 * (inverseInputTextureSize.x / inverseInputTextureSize.y);
  
  vec2 stepA = vec2(stepX, -0.5);
  vec2 stepB = vec2(-stepX, -0.5);
  
  for(int i = 0, j = pushConstants.countSamples; i < j; i++){
    float stepDistance = (float(i) + 0.5) * inverseInputTextureSize.y;
    sampleCountA += doGatherAndApply(uTextureInputs[0], uvw + vec3(stepA * stepDistance, 0.0), 0.0, baseColor.w, stepDistance, inputTextureSize, outputA);
    sampleCountB += doGatherAndApply(uTextureInputs[1], uvw + vec3(stepB * stepDistance, 0.0), 0.0, baseColor.w, stepDistance, inputTextureSize, outputB);
  }
  
  // Normalise if any colour was added. outputA is from sampling the single texture,
  // so use half the base colour (which is from the combined texture).
  outputA.xyz = (sampleCountA > 0.0) ? (outputA.xyz / sampleCountA) : (baseColor.xyz * 0.5);
  outputB.xyz = (sampleCountB > 0.0) ? (outputB.xyz / sampleCountB) : baseColor.xyz;
  
  // Combine and divide by three (outputB is double brightness). Use a max for the blurriness, no accumulation done here.
  outFragColor = vec4(vec3((outputA.xyz + outputB.xyz) / 3.0), clamp((abs(outputA.w) < abs(outputB.w)) ? outputB.w : outputA.w, -1.0, 1.0));                     
#endif
}
