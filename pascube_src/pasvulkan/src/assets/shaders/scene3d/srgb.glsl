#ifndef SRGB_GLSL
#define SRGB_GLSL

vec3 convertLinearRGBToSRGB(vec3 c) {
  return mix((pow(c, vec3(1.0 / 2.4)) * vec3(1.055)) - vec3(5.5e-2), c * vec3(12.92), lessThan(c, vec3(3.1308e-3)));  //
}

vec4 convertLinearRGBToSRGB(vec4 c) {
  return vec4(convertLinearRGBToSRGB(c.xyz), c.w);  //
}

vec3 convertSRGBToLinearRGB(vec3 c) {
  return mix(pow((c + vec3(5.5e-2)) / vec3(1.055), vec3(2.4)), c / vec3(12.92), lessThan(c, vec3(4.045e-2)));  //
}

vec4 convertSRGBToLinearRGB(vec4 c) {
  return vec4(convertSRGBToLinearRGB(c.xyz), c.w);  //
}

vec3 convertLinearRGBToSRGBFast(vec3 c) {
//return mix(12.92 * c, 1.13005 * sqrt(c - 0.00228) - 0.13448 * c + 0.005719, step(c, vec3(0.0031308)));
  return mix(fma(sqrt(c - vec3(0.00228)), vec3(1.13005), vec3(0.005719)) + (c * -0.13448), c * vec3(12.92), lessThan(c, vec3(3.1308e-3)));  //
}

vec4 convertLinearRGBToSRGBFast(vec4 c) {
  return vec4(convertLinearRGBToSRGBFast(c.xyz), c.w);  //
}

vec3 convertSRGBToLinearRGBFast(vec3 c) {
//return mix(c / 12.92, -7.43605 * c - 31.24297 * sqrt(-0.53792 * c + 1.279924) + 35.34864, step(c, vec3(0.04045)));
  return mix((c * -7.43605) + fma(sqrt(fma(c, vec3(-0.53792), vec3(1.279924))), vec3(-31.24297), vec3(35.34864)), c / vec3(12.92), lessThan(c, vec3(4.045e-2)));  //
}

vec4 convertSRGBToLinearRGBFast(vec4 c) {
  return vec4(convertSRGBToLinearRGB(c.xyz), c.w);  //
}

#endif
