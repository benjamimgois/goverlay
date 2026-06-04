#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(push_constant) uniform PushConstants {
  float factor;
  float bloomFactor;
  float lensflaresFactor;
  float bloomLensflaresFactor;
  
  int countGhosts;
  float lensStarRotationAngle;
  float aspectRatio;
  float inverseAspectRatio;
  
  float dispersal;
  float haloWidth;
  float distortion;
  
} pushConstants;

layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInput uSubpassScene;

layout(set = 0, binding = 1) uniform sampler2DArray uTextureBloom;

layout(set = 0, binding = 2) uniform sampler2D uTextureLensTextures[];

vec4 getLensColor(float x){
  return textureLod(uTextureLensTextures[0], vec2(clamp(x, 0.0, 1.0), 0.5), 0);
}

vec4 getLensDirt(vec2 p){
  return vec4(textureLod(uTextureLensTextures[1], p, 0).xxx, 1.0);
}

vec4 getLensStar(vec2 p){
  return vec4(textureLod(uTextureLensTextures[2], p, 0).xxx, 1.0);
}

vec4 textureLimited(const in vec2 texCoord){
	if(((texCoord.x < 0.0) || (texCoord.y < 0.0)) || ((texCoord.x > 1.0) || (texCoord.y > 1.0))){
	 	return vec4(0.0);
	}else{
	 	return textureLod(uTextureBloom, vec3(texCoord, gl_ViewIndex), 0.0);// * pow(1.0 - (length(texCoord.y - vec2(0.5)) * 2.0), 4.0);
	}
}

vec4 textureDistorted(const in vec2 texCoord, const in vec2 direction, const in vec3 distortion) {
  return clamp(
           vec4(textureLimited((texCoord + (direction * distortion.r))).r,
                textureLimited((texCoord + (direction * distortion.g))).g,
							  textureLimited((texCoord + (direction * distortion.b))).b,
                1.0),
           vec4(0.0),
           vec4(65504.0)
          );
}

vec4 getLensFlare(){
  vec2 aspectTexCoord = vec2(1.0) - (((inTexCoord - vec2(0.5)) * vec2(1.0, pushConstants.inverseAspectRatio)) + vec2(0.5)); 
  vec2 texCoord = vec2(1.0) - inTexCoord; 
  vec2 ghostVec = (vec2(0.5) - texCoord) * pushConstants.dispersal;
  vec2 ghostVecAspectNormalized = normalize(ghostVec * vec2(1.0, pushConstants.inverseAspectRatio)) * vec2(1.0, pushConstants.aspectRatio);
  vec2 haloVec = normalize(ghostVec) * pushConstants.haloWidth;
  vec2 haloVecAspectNormalized = ghostVecAspectNormalized * pushConstants.haloWidth;
  vec2 texelSize = vec2(1.0) / vec2(textureSize(uTextureBloom, 0).xy);
  vec3 distortion = vec3(-(texelSize.x * pushConstants.distortion), 0.0, texelSize.x * pushConstants.distortion);
  vec4 c = vec4(0.0);
  for (int i = 0, j = pushConstants.countGhosts; i < j; i++) {
    vec2 offset = texCoord + (ghostVec * float(i));
    c += textureDistorted(offset, ghostVecAspectNormalized, distortion) * clamp(pow(max(0.0, 1.0 - (length(vec2(0.5) - offset) / length(vec2(0.5)))), 10.0), 0.0, 16.0);
  }                       
  vec2 haloOffset = texCoord + haloVecAspectNormalized; 
  return (c * getLensColor((length(vec2(0.5) - aspectTexCoord) / length(vec2(0.5))))) + 
         (textureDistorted(haloOffset, ghostVecAspectNormalized, distortion) * clamp(pow(max(0.0, 1.0 - (length(vec2(0.5) - haloOffset) / length(vec2(0.5)))), 10.0), 0.0, 16.0));
} 


void main(){
  vec4 bloom = clamp(textureLod(uTextureBloom, vec3(inTexCoord, gl_ViewIndex), 0.0), vec4(0.0), vec4(65504.0));  
  vec4 lensflares = vec4(0.0);
  vec4 lensStar = vec4(0.0);
  vec2 texCoord = ((inTexCoord - vec2(0.5)) * vec2(pushConstants.aspectRatio, 1.0) * 0.5) + vec2(0.5);
  if(pushConstants.lensflaresFactor > 1e-7){
//  vec2 lensStarTexCoord = (mat2(cos(pushConstants.lensStarRotationAngle), -sin(pushConstants.lensStarRotationAngle), sin(pushConstants.lensStarRotationAngle), cos(pushConstants.lensStarRotationAngle)) * (texCoord - vec2(0.5))) + vec2(0.5);
    vec2 sinCos = sin(vec2(pushConstants.lensStarRotationAngle) + vec2(0.0, 1.5707963267948966));
    vec2 lensStarTexCoord = (mat2(sinCos.y, -sinCos.x, sinCos.x, sinCos.y) * (texCoord - vec2(0.5))) + vec2(0.5);
    lensflares = getLensFlare();
    lensStar = getLensStar(lensStarTexCoord);
  }
  vec4 lensDirt = getLensDirt(inTexCoord);
  outFragColor = mix(clamp(subpassLoad(uSubpassScene), vec4(-65504.0), vec4(65504.0)), 
                     (
                      ((bloom * lensDirt) * pushConstants.bloomFactor) + 
                      ((lensflares * (lensDirt + lensStar)) * pushConstants.lensflaresFactor)
                     ),
                     pushConstants.factor);
}
