#ifndef REC2084_GLSL
#define REC2084_GLSL

const float REC2084_M1 = 0.1593017578125; // (2610.0 / 4096.0) * 0.25;
const float REC2084_M2 = 78.84375; // (2523.0 / 4096.0) * 128.0;
const float REC2084_M1_INV = 6.277394636015326; // 1.0 / ((2610.0 / 4096.0) * 0.25));
const float REC2084_M2_INV = 0.05351170568561873; // 1.0 / ((2523.0 / 4096.0) * 128.0);
const float REC2084_C1 = 0.8359375; // 3424.0 / 4096.0;
const float REC2084_C2 = 18.8515625; // (2413.0 / 4096.0) * 32.0;
const float REC2084_C3 = 18.6875; // (2392.0 / 4096.0) * 32.0;

vec3 oetfREC2084(vec3 L){
  vec3 Lp = pow(L, vec3(REC2084_M1));
  return pow(fma(Lp, vec3(REC2084_C2), vec3(REC2084_C1)) / fma(Lp, vec3(REC2084_C3), vec3(1.0)), vec3(REC2084_M2));
}

vec3 eotfREC2084(vec3 N){
  vec3 Np = pow(N, vec3(REC2084_M2_INV));
  return pow(max(Np - vec3(REC2084_C1), vec3(0.0)) / fma(Np, vec3(-REC2084_C3), vec3(REC2084_C2)), vec3(REC2084_M1_INV));
}

#endif