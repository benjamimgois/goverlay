#ifndef VERTEX_GLSL
#define VERTEX_GLSL

// Octahedron direction vector encoding
vec2 vertexOctEncode(vec3 vector) {
  vector = normalize(vector); // just for to make sure that it is normalized
  vec2 result = vector.xy / (abs(vector.x) + abs(vector.y) + abs(vector.z));
  return (vector.z < 0.0) ? ((1.0 - abs(result.yx)) * fma(step(vec2(0.0), result.xy), vec2(2.0), vec2(-1.0))) : result;
}

// Octahedron direction vector decoding
vec3 vertexOctDecode(vec2 oct) {
  vec3 v = vec3(oct.xy, 1.0 - (abs(oct.x) + abs(oct.y)));
  return normalize((v.z < 0.0) ? vec3((1.0 - abs(v.yx)) * fma(step(vec2(0.0), v.xy), vec2(2.0), vec2(-1.0)), v.z) : v);
}

#endif // VERTEX_GLSL