#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (constant_id = 0) const bool SeparateNearFarProcessing = true;

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragOutput;

layout(push_constant) uniform PushConstants {
  float maxCoC;
  float fFactor;
  float ngon;
  float downSampleFactor;
  int blurKernelSize;
} pushConstants;

layout(set = 0, binding = 0) uniform sampler2DArray uTextureInput;

layout(set = 0, binding = 1, std430) readonly buffer BokehShapeTaps {
  int countBokehShapeTaps; 
  vec2 bokehShapeTaps[];
};

const float PI = 3.14159265359;   

void main(){
  
  vec2 inputTextureSize = textureSize(uTextureInput, 0).xy; 
 
  vec2 inverseInputTextureSize = vec2(1.0) / inputTextureSize; 

  float aspectRatio = inputTextureSize.y / inputTextureSize.x;
 
  vec3 uvw = vec3(inTexCoord.xy, gl_ViewIndex); 

  vec4 centerSample = textureLod(uTextureInput, uvw, 0);

  centerSample.xyz = clamp(centerSample.xyz, vec3(0.0), vec3(65504.0));

  if(SeparateNearFarProcessing){

    float marginEx = inverseInputTextureSize.y;// * pushConstants.downSampleFactor;

    float margin = marginEx * 2.0;

    vec4 farSum = vec4(0.0);
    vec4 nearSum = vec4(0.0);

    int countSamples = countBokehShapeTaps;
        
    for(int sampleIndex = 0; sampleIndex < countSamples; sampleIndex++){            

      vec2 offset = bokehShapeTaps[sampleIndex] * pushConstants.maxCoC;
      
      float offsetDistance = max(1e-7, length(offset));
      
      offset.x *= aspectRatio;

      vec4 sampleTexel = textureLod(uTextureInput, uvw + vec3(offset, 0.0), 0.0);

      sampleTexel.xyz = clamp(sampleTexel.xyz, vec3(0.0), vec3(65504.0));
          
      farSum += vec4(sampleTexel.xyz, 1.0) * clamp(((max(0.0, min(centerSample.w, sampleTexel.w)) - offsetDistance) + margin) / margin, 0.0, 1.0);

      nearSum += vec4(sampleTexel.xyz, 1.0) * clamp((((-sampleTexel.w) - offsetDistance) + margin) / margin, 0.0, 1.0) * smoothstep(marginEx * 0.5, marginEx, -sampleTexel.w);

    }

    farSum.xyz /= ((farSum.w < 1e-7) ? 1.0 : farSum.w);
    nearSum.xyz /= ((nearSum.w < 1e-7) ? 1.0 : nearSum.w);

  //farSum.w = smoothstep(inverseInputTextureSize.y, inverseInputTextureSize.y * 2.0, centerSample.w);
  //nearSum.w *= PI / float(countSamples);

    float alpha = clamp(nearSum.w * (PI / float(countSamples)), 0.0, 1.0);

    outFragOutput = vec4(mix(farSum.xyz, nearSum.xyz, alpha), alpha);

  }else{

    vec4 color = vec4(centerSample.xyz, 1.0);
  
    float halfMargin = 0.5 * inverseInputTextureSize.y;

    int countSamples = countBokehShapeTaps;
        
    float nearSum = 0.0;

    for(int sampleIndex = 0; sampleIndex < countSamples; sampleIndex++){            

      vec2 offset = bokehShapeTaps[sampleIndex] * pushConstants.maxCoC;
      
      float offsetDistance = max(1e-7, length(offset));
      
      offset.x *= aspectRatio;

      vec4 sampleTexel = textureLod(uTextureInput, uvw + vec3(offset, 0.0), 0.0);
          
      sampleTexel.xyz = clamp(sampleTexel.xyz, vec3(0.0), vec3(65504.0));

      float weight = smoothstep(offsetDistance - halfMargin, 
                                offsetDistance + halfMargin,
                                (centerSample.w < sampleTexel.w) ? clamp(abs(sampleTexel.w), 0.0, abs(centerSample.w) * 2.0) : abs(sampleTexel.w)
                              ) * 1.0; //int(abs(sign(sampleSize) - sign(centerSample.w)) < 2);

      color += vec4(mix(color.xyz / color.w, sampleTexel.xyz, weight), 1.0);         
      
      nearSum += float(sampleTexel.w < 0.0) * weight;

    }

    outFragOutput = vec4(color.xyz / color.w, clamp(nearSum * (PI / float(countSamples)), 0.0, 1.0));

  }

}
