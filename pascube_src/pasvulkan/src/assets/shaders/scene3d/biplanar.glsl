#ifndef BIPLANAR_GLSL
#define BIPLANAR_GLSL

// Biplanar texture mapping, based on https://www.shadertoy.com/view/ws3Bzf 
vec4 biplanar(sampler2D source, in vec3 position, in vec3 normal, in float k){
  vec3 dpdx = dFdx(position), dpdy = dFdy(position);
  normal = abs(normal);
  ivec3 majorAxis = ((normal.x > normal.y) && (normal.x > normal.z)) ? ivec3(0, 1, 2) : ((normal.y > normal.z) ? ivec3(1, 2, 0) : ivec3(2, 0, 1));
  ivec3 minorAxis = ((normal.x < normal.y) && (normal.x < normal.z)) ? ivec3(0, 1, 2) : ((normal.y < normal.z) ? ivec3(1, 2, 0) : ivec3(2, 0, 1));
  ivec3 medianAxis = (ivec3(3) - minorAxis) - majorAxis;
  vec4 x = textureGrad(source, vec2(position[majorAxis.y], position[majorAxis.z]), vec2(dpdx[majorAxis.y], dpdx[majorAxis.z]), vec2(dpdy[majorAxis.y], dpdy[majorAxis.z]));
  vec4 y = textureGrad(source, vec2(position[medianAxis.y], position[medianAxis.z]), vec2(dpdx[medianAxis.y], dpdx[medianAxis.z]), vec2(dpdy[medianAxis.y], dpdy[medianAxis.z]));
  vec2 w = pow(clamp((vec2(normal[majorAxis.x], normal[medianAxis.x]) - vec2(0.5773)) / vec2(1.0 - 0.5773), vec2(0.0), vec2(1.0)), vec2(k * 0.125));
  return ((x * w.x) + (y * w.y)) / (w.x + w.y);
}

#endif // BIPLANAR_GLSL