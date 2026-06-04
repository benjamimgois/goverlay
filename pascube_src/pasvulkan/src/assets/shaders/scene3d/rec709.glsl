#ifndef REC709_GLSL
#define REC709_GLSL

vec3 linearSRGBToREC709(vec3 c){
  return mix(fma(pow(c, vec3(0.45)), vec3(1.0993), vec3(-0.0993)), c * vec3(4.5), lessThan(c, vec3(0.0181)));
}

vec3 rec709ToLinearSRGB(vec3 c){
  return mix(pow((c + vec3(0.0993)) / vec3(1.0993), vec3(1.0 / 0.45)), c / vec3(4.5), lessThan(c, vec3(0.08145)));
}

#endif