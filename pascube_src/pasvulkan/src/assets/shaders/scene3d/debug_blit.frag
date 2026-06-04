#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable // <= needed here for uTextureOtherDebugData random index access

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInput uSubpassInput; 

layout(set = 0, binding = 1) uniform sampler2DArray uTextureDebugData; // cascaded shadow map slices

layout(set = 0, binding = 2) uniform sampler2D uTextureOtherDebugData[];

layout(push_constant) uniform PushConstants {
  int countExtraTextures;
} pushConstants;

void main(){
  vec4 c = subpassLoad(uSubpassInput);
  int slices = textureSize(uTextureDebugData, 0).z;
  float sliceWidthSum = 0.1 * float(slices + pushConstants.countExtraTextures); // cascaded shadow map slices + extra textures
  if(all(lessThanEqual(inTexCoord, vec2(sliceWidthSum, 0.1)))){
    vec2 texCoord = inTexCoord * vec2(float(slices + pushConstants.countExtraTextures) / sliceWidthSum, 1.0 / 0.1);
    int index = int(texCoord.x);
    texCoord.x -= float(index);
    if(index < slices){
      c = texture(uTextureDebugData, vec3(texCoord, index), 0.0);
    }else{
      index -= slices;
      if(index < pushConstants.countExtraTextures){
        c = texture(uTextureOtherDebugData[index], texCoord, 0.0);
      }
    } 
  }  
  outFragColor = c;
}
