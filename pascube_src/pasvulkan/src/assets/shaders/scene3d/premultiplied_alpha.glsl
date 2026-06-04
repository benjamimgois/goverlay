#ifndef PREMULTIPLIED_ALPHA_GLSL
#define PREMULTIPLIED_ALPHA_GLSL

vec4 PremultiplyAlpha(vec4 color){
  return vec4(color.xyz, 1.0) * color.w; 
}

vec4 UnpremultiplyAlpha(vec4 color){
  return vec4((color.w > 0.0) ? (color.xyz / max(color.w, 1e-5)) : vec3(0.0), color.w); 
}

#endif