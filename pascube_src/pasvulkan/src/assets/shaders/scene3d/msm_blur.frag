#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_viewport_layer_array : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;
layout(location = 1) flat in int inFaceIndex;

layout(location = 0) out vec4 oOutput;

layout(set = 0, binding = 0) uniform sampler2DArray uTexture;

layout(push_constant) uniform PushConstants { 
  vec4 direction;
} pushConstants;
/* clang-format on */

vec4 GaussianBlur(const in sampler2DArray pTexSource, const in vec2 pCenterUV, const in float pLayer, const in float pLOD, const in vec2 pPixelOffset){
#if 1
  return ((textureLod(pTexSource, vec3(pCenterUV + (pPixelOffset * 0.5949592424752924), pLayer), pLOD) +
           textureLod(pTexSource, vec3(pCenterUV - (pPixelOffset * 0.5949592424752924), pLayer), pLOD)) * 0.3870341767000849)+
         ((textureLod(pTexSource, vec3(pCenterUV + (pPixelOffset * 2.176069137573487), pLayer), pLOD) +
           textureLod(pTexSource, vec3(pCenterUV - (pPixelOffset * 2.176069137573487), pLayer), pLOD)) * 0.11071876711891004);
#else
  return ((textureLod(pTexSource, vec3(pCenterUV + (pPixelOffset * 0.6591712451751888), pLayer), pLOD) +
           textureLod(pTexSource, vec3(pCenterUV - (pPixelOffset * 0.6591712451751888), pLayer), pLOD)) * 0.15176565679402804)+
         ((textureLod(pTexSource, vec3(pCenterUV + (pPixelOffset * 2.4581680281192115), pLayer), pLOD) +
           textureLod(pTexSource, vec3(pCenterUV - (pPixelOffset * 2.4581680281192115), pLayer), pLOD)) * 0.16695645822541735)+
         ((textureLod(pTexSource, vec3(pCenterUV + (pPixelOffset * 4.425094078679077), pLayer), pLOD) +
           textureLod(pTexSource, vec3(pCenterUV - (pPixelOffset * 4.425094078679077), pLayer), pLOD)) * 0.10520961571427603)+
         ((textureLod(pTexSource, vec3(pCenterUV + (pPixelOffset * 6.39267736227941), pLayer), pLOD) +
           textureLod(pTexSource, vec3(pCenterUV - (pPixelOffset * 6.39267736227941), pLayer), pLOD)) * 0.05091823661517932)+
         ((textureLod(pTexSource, vec3(pCenterUV + (pPixelOffset * 8.361179642955081), pLayer), pLOD) +
           textureLod(pTexSource, vec3(pCenterUV - (pPixelOffset * 8.361179642955081), pLayer), pLOD)) * 0.01892391240315673)+
         ((textureLod(pTexSource, vec3(pCenterUV + (pPixelOffset * 10.330832149360727), pLayer), pLOD) +
           textureLod(pTexSource, vec3(pCenterUV - (pPixelOffset * 10.330832149360727), pLayer), pLOD)) * 0.005400173381332095);
#endif
}

void main(){
  oOutput = GaussianBlur(uTexture, inTexCoord, float(inFaceIndex), 0.0, vec2(vec2(1.0) / vec2(textureSize(uTexture, 0).xy)) * pushConstants.direction.xy);
}
