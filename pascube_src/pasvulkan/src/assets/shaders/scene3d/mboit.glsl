#ifndef MBOIT_GLSL
#define MBOIT_GLSL

float MBOIT_WarpDepth(float depth, float lnDepthMin, float lnDepthMax) {         //
  return fma((log(depth) - lnDepthMin) / (lnDepthMax - lnDepthMin), 2.0, -1.0);  //
}

void MBOIT4_GenerateMoments(float depth, float transmittance, out float b_0, out vec4 b) {
  float                                      //
      absorbance = -log(transmittance),      //
      depth_pow2 = depth * depth,            //
      depth_pow4 = depth_pow2 * depth_pow2;  //
  b_0 = absorbance;
  b = vec4(                    //
          depth,               //
          depth_pow2,          //
          depth_pow2 * depth,  //
          depth_pow4) *        //
      absorbance;
}

float MBOIT4_ComputeTransmittanceAtDepthFrom4PowerMoments(  //
    float b_0,                                              //
    vec4 b,                                                 //
    float depth,                                            //
    float bias,                                             //
    float overestimation,                                   //
    vec4 bias_vector                                        //
) {
  // Bias input data to avoid artifacts
  b = mix(b, bias_vector, bias);
  vec3 z;
  z[0] = depth;

  // Compute a Cholesky factorization of the Hankel matrix B storing only non-
  // trivial entries or related products
  float L21D11 = fma(-b[0], b[1], b[2]);
  float D11 = fma(-b[0], b[0], b[1]);
  float InvD11 = 1.0 / D11;
  float L21 = L21D11 * InvD11;
  float SquaredDepthVariance = fma(-b[1], b[1], b[3]);
  float D22 = fma(-L21D11, L21, SquaredDepthVariance);

  // Obtain a scaled inverse image of bz=(1,z[0],z[0]*z[0])^T
  vec3 c = vec3(1.0, z[0], z[0] * z[0]);
  // Forward substitution to solve L*c1=bz
  c[1] -= b.x;
  c[2] -= b.y + L21 * c[1];
  // Scaling to solve D*c2=c1
  c[1] *= InvD11;
  c[2] /= D22;
  // Backward substitution to solve L^T*c3=c2
  c[1] -= L21 * c[2];
  c[0] -= dot(c.yz, b.xy);
  // Solve the quadratic equation c[0]+c[1]*z+c[2]*z^2 to obtain solutions
  // z[1] and z[2]
  float InvC2 = 1.0 / c[2];
  float p = c[1] * InvC2;
  float q = c[0] * InvC2;
  float D = (p * p * 0.25) - q;
  float r = sqrt(D);
  z[1] = -p * 0.5 - r;
  z[2] = -p * 0.5 + r;
  // Compute the absorbance by summing the appropriate weights
  vec3 polynomial;
  vec3 weight_factor = vec3(overestimation, (z[1] < z[0]) ? 1.0 : 0.0, (z[2] < z[0]) ? 1.0 : 0.0);
  float f0 = weight_factor[0];
  float f1 = weight_factor[1];
  float f2 = weight_factor[2];
  float f01 = (f1 - f0) / (z[1] - z[0]);
  float f12 = (f2 - f1) / (z[2] - z[1]);
  float f012 = (f12 - f01) / (z[2] - z[0]);
  polynomial[0] = f012;
  polynomial[1] = polynomial[0];
  polynomial[0] = f01 - polynomial[0] * z[1];
  polynomial[2] = polynomial[1];
  polynomial[1] = polynomial[0] - polynomial[1] * z[0];
  polynomial[0] = f0 - polynomial[0] * z[0];
  float absorbance = polynomial[0] + dot(b.xy, polynomial.yz);
  ;
  // Turn the normalized absorbance into transmittance
  return clamp(exp(-b_0 * absorbance), 0.0, 1.0);
}

void MBOIT4_ResolveMoments(            //
    float depth,                       //
    float b0,                          //
    vec4 b_1234,                       //
    out float transmittance_at_depth,  //
    out float total_transmittance      //
) {
  transmittance_at_depth = 1.0;
  total_transmittance = 1.0;

  if (b0 < 0.00100050033) {  //
    discard;                 //
  }
  total_transmittance = exp(-b0);

  b_1234 /= b0;

  transmittance_at_depth = MBOIT4_ComputeTransmittanceAtDepthFrom4PowerMoments  //
      (                                                                         //
          b0,                                                                   //
          b_1234,                                                               //
          depth,                                                                //
          0.0035,                                                               // moment_bias
          0.1,                                                                  // overestimation
          vec4(0.0, 0.375, 0.0, 0.375)                                          // bias_vector
      );
}

void MBOIT6_GenerateMoments(float depth, float transmittance, out float b0, out vec4 b1234, out vec4 b56) {
  float  //
      absorbance = -log(transmittance),
      depth_pow2 = depth * depth,            //
      depth_pow4 = depth_pow2 * depth_pow2,  //
      depth_pow6 = depth_pow4 * depth_pow2;
  b0 = absorbance;
  b1234 = vec4(depth, depth_pow2, depth_pow2 * depth, depth_pow4) * absorbance;
  b56 = vec4(depth_pow4 * depth, depth_pow6, 0.0, 0.0) * absorbance;
}

float MBOIT6_Saturate(float x) {               //
  return clamp(isinf(x) ? 1.0 : x, 0.0, 1.0);  //
}

float MBOIT6_ArcTan2(in float y, in float x) {                           //
  return mix(/*PI / 2.0*/1.57079632679 - atan(x, y), atan(y, x), bool(abs(x) > abs(y)));  //
}

/*! Code taken from the blog "Moments in Graphics" by Christoph Peters.
    http://momentsingraphics.de/?p=105
    This function computes the three real roots of a cubic polynomial
    Coefficient[0]+Coefficient[1]*x+Coefficient[2]*x^2+Coefficient[3]*x^3.*/
vec3 MBOIT6_SolveCubic(vec4 Coefficient) {
  // Normalize the polynomial
  Coefficient.xyz /= Coefficient.w;
  // Divide middle coefficients by three
  Coefficient.yz /= 3.0f;
  // Compute the Hessian and the discrimant
  vec3 Delta = vec3(fma(-Coefficient.z, Coefficient.z, Coefficient.y),  //
                    fma(-Coefficient.y, Coefficient.z, Coefficient.x),  //
                    dot(vec2(Coefficient.z, -Coefficient.y),            //
                        Coefficient.xy));
  float Discriminant = dot(vec2(4.0f * Delta.x, -Delta.y), Delta.zy);
  // Compute coefficients of the depressed cubic
  // (third is zero, fourth is one)
  vec2 Depressed = vec2(fma(-2.0f * Coefficient.z, Delta.x, Delta.y), Delta.x);
  // Take the cubic root of a normalized complex number
  float Theta = MBOIT6_ArcTan2(sqrt(Discriminant), -Depressed.x) / 3.0f;
  vec2 CubicRoot = vec2(cos(Theta), sin(Theta));
  // Compute the three roots, scale appropriately and
  // revert the depression transform
  vec3 Root = vec3(CubicRoot.x,                                      //
                   dot(vec2(-0.5f, -0.5f * sqrt(3.0f)), CubicRoot),  //
                   dot(vec2(-0.5f, 0.5f * sqrt(3.0f)), CubicRoot));
  Root = fma(vec3(2.0f * sqrt(-Depressed.y)), Root, vec3(-Coefficient.z));
  return Root;
}

float MBOIT6_ComputeTransmittanceAtDepthFrom6PowerMoments(float b_0, vec3 b_even, vec3 b_odd, float depth, float bias, float overestimation, float bias_vector[6]) {
  float b[6] = {b_odd.x, b_even.x, b_odd.y, b_even.y, b_odd.z, b_even.z};
  // Bias input data to avoid artifacts
  //[unroll]
  for (int i = 0; i != 6; ++i) {
    b[i] = mix(b[i], bias_vector[i], bias);
  }

  vec4 z;
  z[0] = depth;

  // Compute a Cholesky factorization of the Hankel matrix B storing only non-
  // trivial entries or related products
  float InvD11 = 1.0f / fma(-b[0], b[0], b[1]);
  float L21D11 = fma(-b[0], b[1], b[2]);
  float L21 = L21D11 * InvD11;
  float D22 = fma(-L21D11, L21, fma(-b[1], b[1], b[3]));
  float L31D11 = fma(-b[0], b[2], b[3]);
  float L31 = L31D11 * InvD11;
  float InvD22 = 1.0f / D22;
  float L32D22 = fma(-L21D11, L31, fma(-b[1], b[2], b[4]));
  float L32 = L32D22 * InvD22;
  float D33 = fma(-b[2], b[2], b[5]) - dot(vec2(L31D11, L32D22), vec2(L31, L32));
  float InvD33 = 1.0f / D33;

  // Construct the polynomial whose roots have to be points of support of the
  // canonical distribution: bz=(1,z[0],z[0]*z[0],z[0]*z[0]*z[0])^T
  vec4 c;
  c[0] = 1.0f;
  c[1] = z[0];
  c[2] = c[1] * z[0];
  c[3] = c[2] * z[0];
  // Forward substitution to solve L*c1=bz
  c[1] -= b[0];
  c[2] -= fma(L21, c[1], b[1]);
  c[3] -= b[2] + dot(vec2(L31, L32), c.yz);
  // Scaling to solve D*c2=c1
  c.yzw *= vec3(InvD11, InvD22, InvD33);
  // Backward substitution to solve L^T*c3=c2
  c[2] -= L32 * c[3];
  c[1] -= dot(vec2(L21, L31), c.zw);
  c[0] -= dot(vec3(b[0], b[1], b[2]), c.yzw);

  // Solve the cubic equation
  z.yzw = MBOIT6_SolveCubic(c);

  // Compute the absorbance by summing the appropriate weights
  vec4 weigth_factor;
  weigth_factor[0] = overestimation;
  // weigth_factor.yzw = (z.yzw > z.xxx) ? vec3 (0.0f, 0.0f, 0.0f) : vec3 (1.0f, 1.0f, 1.0f);
  // weigth_factor = vec4(overestimation, (z[1] < z[0])?1.0f:0.0f, (z[2] < z[0])?1.0f:0.0f, (z[3] < z[0])?1.0f:0.0f);
  weigth_factor.yzw = mix(vec3(1.0f, 1.0f, 1.0f), vec3(0.0f, 0.0f, 0.0f), ivec3(greaterThan(z.yzw, z.xxx)));
  // Construct an interpolation polynomial
  float f0 = weigth_factor[0];
  float f1 = weigth_factor[1];
  float f2 = weigth_factor[2];
  float f3 = weigth_factor[3];
  float f01 = (f1 - f0) / (z[1] - z[0]);
  float f12 = (f2 - f1) / (z[2] - z[1]);
  float f23 = (f3 - f2) / (z[3] - z[2]);
  float f012 = (f12 - f01) / (z[2] - z[0]);
  float f123 = (f23 - f12) / (z[3] - z[1]);
  float f0123 = (f123 - f012) / (z[3] - z[0]);
  vec4 polynomial;
  // f012+f0123 *(z-z2)
  polynomial[0] = fma(-f0123, z[2], f012);
  polynomial[1] = f0123;
  // *(z-z1) +f01
  polynomial[2] = polynomial[1];
  polynomial[1] = fma(polynomial[1], -z[1], polynomial[0]);
  polynomial[0] = fma(polynomial[0], -z[1], f01);
  // *(z-z0) +f0
  polynomial[3] = polynomial[2];
  polynomial[2] = fma(polynomial[2], -z[0], polynomial[1]);
  polynomial[1] = fma(polynomial[1], -z[0], polynomial[0]);
  polynomial[0] = fma(polynomial[0], -z[0], f0);
  float absorbance = dot(polynomial, vec4(1.0, b[0], b[1], b[2]));
  // Turn the normalized absorbance into transmittance
  return MBOIT6_Saturate(exp(-b_0 * absorbance));
}

void MBOIT6_ResolveMoments(out float transmittance_at_depth, out float total_transmittance, float depth, float moment_bias, float overestimation, float b0, vec4 b_1234, vec4 b_56) {
  transmittance_at_depth = 1.0;
  total_transmittance = 1.0;

  if (b0 < 0.00100050033)  // Completely transparent
  {
    discard;
  }

  total_transmittance = exp(-b0);

  vec3                                                 //
      b_even = vec3(b_1234.y, b_1234.w, b_56.y) / b0,  //
      b_odd = vec3(b_1234.x, b_1234.z, b_56.x) / b0;

  const float bias_vector[6] = {
      //
      0.0,    //
      0.48,   //
      0.0,    //
      0.451,  //
      0.0,    //
      0.45    //
  };

  transmittance_at_depth = MBOIT6_ComputeTransmittanceAtDepthFrom6PowerMoments(  //
      b0,                                                                        //
      b_even,                                                                    //
      b_odd,                                                                     //
      depth,                                                                     //
      moment_bias,                                                               //
      overestimation,                                                            //
      bias_vector                                                                //
  );
}

#endif