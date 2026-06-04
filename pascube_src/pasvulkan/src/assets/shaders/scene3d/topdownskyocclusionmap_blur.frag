#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_ARB_shader_viewport_layer_array : enable

/* clang-format off */
layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out float oOutput;

layout(set = 0, binding = 0) uniform sampler2D uTexture;

layout(push_constant) uniform PushConstants { 
  vec4 direction;
} pushConstants;
/* clang-format on */

float GaussianBlur(const in sampler2D pTexSource, const in vec2 pCenterUV, const in float pLOD, const in vec2 pPixelOffset){
#if 0
  return ((textureLod(pTexSource, vec2(pCenterUV + (pPixelOffset * 0.5949592424752924)), pLOD).x +
           textureLod(pTexSource, vec2(pCenterUV - (pPixelOffset * 0.5949592424752924)), pLOD).x) * 0.3870341767000849)+
         ((textureLod(pTexSource, vec2(pCenterUV + (pPixelOffset * 2.176069137573487)), pLOD).x +
           textureLod(pTexSource, vec2(pCenterUV - (pPixelOffset * 2.176069137573487)), pLOD).x) * 0.11071876711891004);
#else
  return ((textureLod(pTexSource, vec2(pCenterUV + (pPixelOffset * 0.6591712451751888)), pLOD).x +
           textureLod(pTexSource, vec2(pCenterUV - (pPixelOffset * 0.6591712451751888)), pLOD).x) * 0.15176565679402804)+
         ((textureLod(pTexSource, vec2(pCenterUV + (pPixelOffset * 2.4581680281192115)), pLOD).x +
           textureLod(pTexSource, vec2(pCenterUV - (pPixelOffset * 2.4581680281192115)), pLOD).x) * 0.16695645822541735)+
         ((textureLod(pTexSource, vec2(pCenterUV + (pPixelOffset * 4.425094078679077)), pLOD).x +
           textureLod(pTexSource, vec2(pCenterUV - (pPixelOffset * 4.425094078679077)), pLOD).x) * 0.10520961571427603)+
         ((textureLod(pTexSource, vec2(pCenterUV + (pPixelOffset * 6.39267736227941)), pLOD).x +
           textureLod(pTexSource, vec2(pCenterUV - (pPixelOffset * 6.39267736227941)), pLOD).x) * 0.05091823661517932)+
         ((textureLod(pTexSource, vec2(pCenterUV + (pPixelOffset * 8.361179642955081)), pLOD).x +
           textureLod(pTexSource, vec2(pCenterUV - (pPixelOffset * 8.361179642955081)), pLOD).x) * 0.01892391240315673)+
         ((textureLod(pTexSource, vec2(pCenterUV + (pPixelOffset * 10.330832149360727)), pLOD).x +
           textureLod(pTexSource, vec2(pCenterUV - (pPixelOffset * 10.330832149360727)), pLOD).x) * 0.005400173381332095);
#endif
}

void main(){
  oOutput = GaussianBlur(uTexture, inTexCoord, 0.0, vec2(vec2(1.0) / vec2(textureSize(uTexture, 0).xy)) * pushConstants.direction.xy);
}
