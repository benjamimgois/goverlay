#ifndef R11G11B10F_GLSL
#define R11G11B10F_GLSL

// GPUs converts the 32-bit float to 11-bit float with 5-bit exponent and 6-bit mantissa by truncating the least significant bits, which
// results in a loss of precision. Therefore, this following function prequantizes the 32-bit float to 11-bit float with 5-bit exponent by
// rounding the least significant bits before truncating them.
vec3 prequantizeR11G11B10F(const in vec3 color){
  return clamp(color + exp2(ceil(log2(color)) - (vec3(6.0 + 2.0, 6.0 + 2.0, 5.0 + 2.0))), vec3(0.0), vec3(65024.0));
}

#endif