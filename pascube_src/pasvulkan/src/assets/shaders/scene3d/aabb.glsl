#ifndef AABB_GLSL
#define AABB_GLSL

void aabbTransform(inout vec3 aabbMin, inout vec3 aabbMax, mat4 m){
  if((abs(m[0][3]) + abs(m[1][3]) + abs(m[2][3]) + (abs(m[3][3]) - 1.0)) < 1e-6){
    // Fast path for affine transformations
    vec3 center = (m * vec4((aabbMin + aabbMax) * 0.5, 1.0)).xyz;
    vec3 temp = (aabbMax - aabbMin) * 0.5;
    vec3 extents = vec3(
      (abs(m[0][0]) * temp.x) + (abs(m[1][0]) * temp.y) + (abs(m[2][0]) * temp.z),
      (abs(m[0][1]) * temp.x) + (abs(m[1][1]) * temp.y) + (abs(m[2][1]) * temp.z),
      (abs(m[0][2]) * temp.x) + (abs(m[1][2]) * temp.y) + (abs(m[2][2]) * temp.z)
    );
    aabbMin = center - extents;
    aabbMax = center + extents;
  }else{
    // Slow path for non-affine transformations
    vec2 minMaxX = vec2(aabbMin.x, aabbMax.x), minMaxY = vec2(aabbMin.y, aabbMax.y), minMaxZ = vec2(aabbMin.z, aabbMax.z);
    vec4 newAABBMin = m * vec4(aabbMin, 1.0);
    newAABBMin /= newAABBMin.w;
    vec4 newAABBMax = newAABBMin;
    [[unroll]] for(int cornerIndex = 1; cornerIndex < 8; cornerIndex++){
      vec4 corner = m * vec4(minMaxX[cornerIndex & 1u], minMaxY[(cornerIndex >> 1u) & 1u], minMaxZ[(cornerIndex >> 2u) & 1u], 1.0);
      corner.xyz /= corner.w;
      newAABBMin.xyz = min(newAABBMin.xyz, corner.xyz);
      newAABBMax.xyz = max(newAABBMax.xyz, corner.xyz);
    }
    aabbMin = newAABBMin.xyz;
    aabbMax = newAABBMax.xyz;
  }
}

#endif // AABB_GLSL