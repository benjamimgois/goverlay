#ifndef MSM_16BIT_GLSL
#define MSM_16BIT_GLSL

vec4 encodeMSM16BitCoefficients(const in float z){
  const mat4 q = mat4(
    1.5, 0.0, 0.8660254037844386 /* sqrt(3.0) * 0.5 */, 0.0,
    0.0, 4.0, 0.0, 0.5,
    -2.0, 0.0, -0.38490017945975047 /* -sqrt(3.0) * 2.0 / 9.0 */, 0.0,
     0.0, -4.0, 0.0, 0.5
  );
  float z2 = z * z;
  return (q * vec4(z, z2, z2 * z, z2 * z2)) + vec4(0.5, 0.0, 0.5, 0.0);
}

vec4 decodeMSM16BitCoefficients(vec4 v){
  const mat4 q = mat4(
      -1.0 / 3.0, 0.0, -0.75, 0.0,
      0.0, 0.125, 0.0, -0.125,
      1.7320508075688772 /* sqrt(3.0) */, 0.0, 1.299038105676658 /* sqrt(3.0) * 0.75 */, 0.0,
      0.0, 1.0, 0.0, 1.0
  );
  return q * (v - vec4(0.5, 0.0, 0.5, 0.0));
}

#endif