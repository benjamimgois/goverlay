#ifndef ADJUGATE_GLSL
#define ADJUGATE_GLSL

mat3 adjugate(const in mat3 m){
  return mat3(cross(m[1], m[2]), cross(m[2], m[0]), cross(m[0], m[1]));
}

mat3 adjugate(const in mat4 m){
  return mat3(cross(m[1].xyz, m[2].xyz), cross(m[2].xyz, m[0].xyz), cross(m[0].xyz, m[1].xyz));
}

#endif