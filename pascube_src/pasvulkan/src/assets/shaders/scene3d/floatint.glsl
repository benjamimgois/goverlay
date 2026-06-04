#ifndef FLOATINT_GLSL
#define FLOATINT_GLSL

// Convert a float to a uint, preserving order.
uint mapFloat(float value){
  uint temporary = floatBitsToUint(value);
  return temporary ^ (uint(uint(-int(uint(temporary >> 31u)))) | 0x80000000u);
}

// Convert a uint to a float, preserving order.
float unmapFloat(uint value){
  return uintBitsToFloat(value ^ (((value >> 31u) - 1u) | 0x80000000u));
}

float makeAbsFloat(uint x){ // 0.0 .. 1.0
  return uintBitsToFloat(((x >> 9u) & 0x007fffffu) | 0x3f800000u) - 1.0;
}

vec2 makeAbsFloat(uvec2 x){ // 0.0 .. 1.0
  return uintBitsToFloat(((x >> uvec2(9u)) & uvec2(0x007fffffu)) | uvec2(0x3f800000u)) - uvec2(1.0);
}

vec3 makeAbsFloat(uvec3 x){ // 0.0 .. 1.0
  return uintBitsToFloat(((x >> uvec3(9u)) & uvec3(0x007fffffu)) | uvec3(0x3f800000u)) - vec3(1.0);
}

vec4 makeAbsFloat(uvec4 x){ // 0.0 .. 1.0
  return uintBitsToFloat(((x >> uvec4(9u)) & uvec4(0x007fffffu)) | uvec4(0x3f800000u)) - vec4(1.0);
}

float makeFloat(uint x){ // -1.0 .. +1.0
  return uintBitsToFloat(((x >> 9u) & 0x007fffffu) | 0x40000000u) - 3.0;
}

vec2 makeFloat(uvec2 x){ // -1.0 .. +1.0
  return uintBitsToFloat(((x >> uvec2(9u)) & uvec2(0x007fffffu)) | uvec2(0x40000000u)) - uvec2(3.0);
}

vec3 makeFloat(uvec3 x){ // -1.0 .. +1.0
  return uintBitsToFloat(((x >> uvec3(9u)) & uvec3(0x007fffffu)) | uvec3(0x40000000u)) - vec3(3.0);
}

vec4 makeFloat(uvec4 x){ // -1.0 .. +1.0
  return uintBitsToFloat(((x >> uvec4(9u)) & uvec4(0x007fffffu)) | uvec4(0x40000000u)) - vec4(3.0);
}

#endif 