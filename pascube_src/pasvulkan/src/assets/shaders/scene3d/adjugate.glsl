#ifndef ADJUGATE_GLSL
#define ADJUGATE_GLSL

mat3 adjugate(const in mat3 m){
  return mat3(cross(m[1], m[2]), cross(m[2], m[0]), cross(m[0], m[1]));
}

mat3 adjugate(const in mat4 m){
  return mat3(cross(m[1].xyz, m[2].xyz), cross(m[2].xyz, m[0].xyz), cross(m[0].xyz, m[1].xyz));
}

mat3 adjugate(const in mat3x4 m){
  return mat3(cross(m[1].xyz, m[2].xyz), cross(m[2].xyz, m[0].xyz), cross(m[0].xyz, m[1].xyz));
}

// Orientation-correct variant of adjugate() for transforming the shading tangent space / normals.
//
// adjugate(M) = cofactor(M) = det(M) * transpose(inverse(M)). It is the robust normal-transform matrix
// (defined even for singular/degenerate M, no inverse needed), but it carries the det(M) factor. For
// det(M) >= 0 that factor is a positive scale that normalize() removes, so it is irrelevant. For det(M) < 0
// (mirrored/reflected transforms, e.g. a glTF node with a negative scale on one axis) the factor is a sign
// that normalize() keeps, flipping the resulting normal inward. The renderer already flips the rasterizer
// winding (front face) for such instances, but the shading normal must be flipped consistently too.
//
// adjugateSignDet() re-applies sign(det(M)), yielding |det(M)| * transpose(inverse(M)) — i.e. the same
// orientation as Khronos' transpose(inverse(M)) normal matrix, while keeping the cheap/robust cofactor form
// and (for rotation/reflection) recovering the correct tangent transform M for the tangent column as well.
// det(M) == 0 (degenerate) falls back to the plain adjugate (no flip).
mat3 adjugateSignDet(const in mat3 m){
  vec3 c0 = cross(m[1], m[2]);
  mat3 a = mat3(c0, cross(m[2], m[0]), cross(m[0], m[1]));
  return (dot(m[0], c0) < 0.0) ? (-a) : a; // dot(m[0], c0) = det(M)
}

mat3 adjugateSignDet(const in mat4 m){
  vec3 c0 = cross(m[1].xyz, m[2].xyz);
  mat3 a = mat3(c0, cross(m[2].xyz, m[0].xyz), cross(m[0].xyz, m[1].xyz));
  return (dot(m[0].xyz, c0) < 0.0) ? (-a) : a;
}

mat3 adjugateSignDet(const in mat3x4 m){
  vec3 c0 = cross(m[1].xyz, m[2].xyz);
  mat3 a = mat3(c0, cross(m[2].xyz, m[0].xyz), cross(m[0].xyz, m[1].xyz));
  return (dot(m[0].xyz, c0) < 0.0) ? (-a) : a;
}

#endif