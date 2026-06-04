#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(set = 0, binding = 0) uniform sampler2DArray uTexture;

#include "bidirectional_tonemapping.glsl"

float posInfinity = uintBitsToFloat(0x7f800000u);
float negInfinity = uintBitsToFloat(0xff800000u);

#define DYNAMIC_SIZED_LANCZOS 0
#define DYNAMIC_SIZED_LANCZOS_RADIUS 5

#if DYNAMIC_SIZED_LANCZOS
const float PI = 3.1415926535897932384626433;
const float PI_SQ = 9.8696044010893586188344910;

float lanczosWeight(float x, float r) {
    return (abs(x) < 1e-6) ? 1.0 : (r * sin(PI * x) * sin(PI * (x / r) )) / (PI_SQ * (x * x));
}

float lanczosWeight(vec2 x, float r) {
    return lanczosWeight(x.x, r) * lanczosWeight(x.y, r);
}

vec4 lanczos(sampler2DArray tex, vec2 texCoord, int r) {
  vec2 texSize = vec2(textureSize(tex, 0).xy);
  texCoord -= vec2(0.5) / texSize;
  vec2 center = floor(texCoord * texSize) / texSize;
  vec4 total = vec4(0);    
  vec4 minValue = vec4(posInfinity); // infinity
  vec4 maxValue = vec4(negInfinity); // -infinity
  for (int x = -r; x <= r; x++) {
    for (int y = -r; y <= r; y++) {
      vec2 uv = (vec2(x,y) / texSize) + center;
      vec4 c = ApplyToneMapping(texelFetch(tex, ivec3(uv * texSize, float(gl_ViewIndex)), 0));
      minValue = min(minValue, c);
      maxValue = max(maxValue, c);
      total += c * 
               lanczosWeight(clamp((uv - texCoord) * texSize, vec2(-r), vec2(r)), float(r));
    }
  }  
  return ApplyInverseToneMapping(clamp(total, minValue, maxValue)); // Anti-ringing clamp
}
#endif

void main(){
#if DYNAMIC_SIZED_LANCZOS
  outFragColor = lanczos(uTexture, inTexCoord, DYNAMIC_SIZED_LANCZOS_RADIUS); //textureLod(uTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0.0);
#else  

  // Optimized lanczos shader with 4x4 kernel

  vec2 texSize = vec2(textureSize(uTexture, 0).xy);
  
  vec2 xy = inTexCoord;
  
  vec2 scaled = (xy * texSize) - vec2(0.5);
  
  xy = (floor(scaled) + vec2(0.5)) / texSize;
  
  vec2 uvratio = fract(scaled);
  
  vec4 coefsX = max(abs(3.141592653589 * vec4(1.0 + uvratio.x,uvratio.x, 1.0 - uvratio.x,2.0 - uvratio.x)), 1e-4);
  coefsX = 2.0*((sin(coefsX) * sin(coefsX * 0.5)) / (coefsX * coefsX));
  coefsX /= dot(coefsX, vec4(1.0));
  
  vec4 coefsY = max(abs(3.141592653589 * vec4(1.0 + uvratio.y, uvratio.y, 1.0 - uvratio.y, 2.0 - uvratio.y)), 1e-4);
  coefsY = 2.0 * ((sin(coefsY) * sin(coefsY*0.5)) / (coefsY * coefsY));
  coefsY /= dot(coefsY, vec4(1.0));

  mat4 colors0 = mat4(ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2(-1.0, -1.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 0.0, -1.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 1.0, -1.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),    
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 2.0, -1.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw));
  vec4 texel0 = colors0 * coefsX;
  vec4 minValue = min(min(min(colors0[0], colors0[1]), colors0[2]), colors0[3]);
  vec4 maxValue = max(max(max(colors0[0], colors0[1]), colors0[2]), colors0[3]);
  
  mat4 colors1 = mat4(ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2(-1.0,  0.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 0.0,  0.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 1.0,  0.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 2.0,  0.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw));
  vec4 texel1 = colors1 * coefsX;
  minValue = min(min(minValue, min(min(colors1[0], colors1[1]), colors1[2])), colors1[3]);
  maxValue = max(max(maxValue, max(max(colors1[0], colors1[1]), colors1[2])), colors1[3]);
  
  mat4 colors2 = mat4(ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2(-1.0,  1.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 0.0,  1.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 1.0,  1.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 2.0,  1.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw));
  vec4 texel2 = colors2 * coefsX;
  minValue = min(min(minValue, min(min(colors2[0], colors2[1]), colors2[2])), colors2[3]);
  maxValue = max(max(maxValue, max(max(colors2[0], colors2[1]), colors2[2])), colors2[3]);
  
  mat4 colors3 = mat4(ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2(-1.0,  2.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 0.0,  2.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 1.0,  2.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw),
                      ApplyToneMapping(textureLod(uTexture, vec3(xy + (vec2( 2.0,  2.0) / texSize), float(gl_ViewIndex)), 0.0).xyzw));
  vec4 texel3 = colors3 * coefsX;                
  minValue = min(min(minValue, min(min(colors3[0], colors3[1]), colors3[2])), colors3[3]);
  maxValue = max(max(maxValue, max(max(colors3[0], colors3[1]), colors3[2])), colors3[3]);                                           
  
  outFragColor = ApplyInverseToneMapping(clamp(mat4(texel0, texel1, texel2, texel3) * coefsY, minValue, maxValue)); // Anti-ringing clamp
#endif

}
