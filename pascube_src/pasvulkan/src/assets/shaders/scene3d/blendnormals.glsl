#ifndef BLENDNORMALS_GLSL
#define BLENDNORMALS_GLSL

// Blend normals from multiple sources, typically used for terrain blending

vec3 blendNormals(vec3 n1, vec3 n2){
  // RNM normal blending
  n1 += vec3(0, 0, 1);
  n2 *= vec3(-1, -1, 1);
  return normalize(fma(n1, vec3(dot(n1, n2) / n1.z), -n2));
}

vec3 blendNormals(vec3 n1, vec3 n2, float t){
  if(t > 0.0){
    const vec3 blendedNormal = blendNormals(n1, n2);
    return (t < 1.0) ? normalize(mix(n1, blendedNormal, t)) : blendedNormal;
  }else{
    return n1;
  }
}

#endif // BLENDNORMALS_GLSL