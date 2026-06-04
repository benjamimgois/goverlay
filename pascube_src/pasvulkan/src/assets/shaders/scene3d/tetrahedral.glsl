#ifndef TETRAHEDRAL_GLSL
#define TETRAHEDRAL_GLSL

// Tetrahedral sphere projection mapping wraps at the horizontal axis and mirrors at the vertical axis.
vec2 tetrahedralWrap(vec2 uv){
  return vec2(
    fract(uv.x),
    fma(abs(fract(uv.y * 0.5) - 0.5), -2.0, 1.0)     
  );
}

#if 1
// Converts a 2D UV coordinate to a 3D unit vector on a tetrahedral sphere.
vec3 tetrahedralDecode(vec2 uv){
 	return normalize(
    vec3(
      fma((uv.x < 0.5) ? uv.x : (1.0 - uv.x), 4.0, -1.0),
      fma(vec2(uv.y, abs(1.0 - abs(1.0 - fma(uv.x, 2.0, -uv.y)))), vec2(2.0), vec2(-1.0))
    )
  );
}

// Converts a 3D unit vector on a tetrahedral sphere to a 2D UV coordinate.
vec2 tetrahedralEncode(vec3 uvw){
  const vec2 v = vec2(-0.5, 0.5);
  vec4 d = vec4(dot(uvw, v.yyy), dot(uvw, v.xxy), dot(uvw, v.yxx), dot(uvw, v.xyx)) / (dot(uvw.xyz, uvw.xyz) * 0.5);  
  uvw /= max(d.x, max(d.y, max(d.z, d.w)));
  return vec2(
    ((all(greaterThan(uvw.xy + uvw.yz, vec2(0.0))) && ((-uvw.z) - uvw.x < 0.0)) || (((uvw.x + uvw.y) < 0.0) && all(greaterThan(uvw.zz - uvw.yx, vec2(0.0))))) ? fma(uvw.x, -0.25, 0.75) : fma(uvw.x, 0.25, 0.25),
    fma(uvw.y, 0.5, 0.5)
  );
}

#else

// Other "wrong" implementation, just for future reference for a starting point for a different approach. 

vec3 tetrahedralDecode(vec2 uv) {
  float x = (uv.x < 0.5) ? fma(uv.x, 4.0, -1.0) : fma(uv.x - 0.5, -4.0, 1.0);
  vec2 yz = fma(uv, 2.0, -1.0);
  float t = 1.0 - (abs(yz.x) + abs(yz.y));
  return vec3(x, yz.x, (x < 0.0) ? -t : t);
}

vec2 tetrahedralEncode(vec3 uvw) {
  vec3 absUVW = abs(uvw);
  float maxComponent = max(absUVW.x, max(absUVW.y, absUVW.z));
  uvw /= maxComponent;
  
  float x = (uvw.x >= 0.0) ? fma(uvw.x, 0.25, 0.5) : fma(uvw.x, -0.25, 0.25);
  vec2 yz = fma(uvw.yz, vec2(0.5), vec2(0.5));
  return vec2(x, (uvw.x >= 0.0) ? yz.x : yz.y);
}
#endif

#endif