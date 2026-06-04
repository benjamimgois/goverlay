#ifndef HLG_GLSL
#define HLG_GLSL

// HLG constants as per Rec. ITU-R BT.2100-2 Table 5
const float HLG_a = 0.17883277;
const float HLG_b = 0.28466892; // 1 - 4 * HLG_a
const float HLG_c = 0.559910714626312255859375; // 0.5 - HLG_a * ln(4 * HLG_a)

// Precomputed constants
const float HLG_a_inv = 5.591816309728916;
const float HLG_inv3 = 0.3333333333333333;
const float HLG_inv12 = 0.08333333333333333;

vec3 oetfHLG(vec3 c){
  return mix(fma(log(fma(c, vec3(12.0), vec3(-HLG_b))), vec3(HLG_a), vec3(HLG_c)), sqrt(c * vec3(3.0)), lessThanEqual(c, vec3(1.0 / 12.0)));
}

vec3 eotfHLG(vec3 c){
  return mix((vec3(HLG_b) + exp((c - vec3(HLG_c)) * vec3(HLG_a_inv))) * vec3(HLG_inv12), (c * c) * vec3(HLG_inv3), lessThanEqual(c, vec3(0.5)));
}

#endif