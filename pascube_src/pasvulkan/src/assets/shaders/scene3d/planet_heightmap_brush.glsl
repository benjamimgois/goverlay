#ifndef PLANET_HEIGHTMAP_BRUSH_GLSL
#define PLANET_HEIGHTMAP_BRUSH_GLSL

vec2 squareToCircle(vec2 p) {
  return p * sqrt(fma((p * p).yx, vec2(-0.5), vec2(1.0)));
}

vec2 circleToSquare(vec2 p) {
#if 0  
  const float TwoSqrt2 = 2.8284271247461903; // 2.0 * sqrt(2.0)
  return vec2(
    ((sqrt((((2.0 + (TwoSqrt2 * p.x)) + (p.x * p.x)) - (p.y * p.y)))) - (sqrt((((2.0 - (TwoSqrt2 * p.x)) + (p.x * p.x)) - (p.y * p.y))))) * 0.5,
    ((sqrt((((2.0 + (TwoSqrt2 * p.y)) + (p.y * p.y)) - (p.x * p.x)))) - (sqrt((((2.0 - (TwoSqrt2 * p.y)) + (p.y * p.y)) - (p.x * p.x))))) * 0.5
  );
#else
  vec2 uv2 = p * p;
  const float TwoSqrt2 = 2.8284271247461903; // 2.0 * sqrt(2.0)
  vec2 subterm = vec2((2.0 + uv2.x) - uv2.y, (2.0 - uv2.x) + uv2.y);
#if 1  
  vec2 term1 = fma(p, vec2(TwoSqrt2), subterm);
  vec2 term2 = fma(p, vec2(-TwoSqrt2), subterm);
  return vec2(sqrt(term1.x) - sqrt(term2.x), sqrt(term1.y) - sqrt(term2.y)) * 0.5;
#else  
  float termx1 = subterm.x + (p.x * TwoSqrt2);
  float termx2 = subterm.x - (p.x * TwoSqrt2);
  float termy1 = subterm.y + (p.y * TwoSqrt2);
  float termy2 = subterm.y - (p.y * TwoSqrt2);
  return vec2(sqrt(termx1) - sqrt(termx2), sqrt(termy1) - sqrt(termy2)) * 0.5;
#endif
#endif
}

float getBrushTexelValue(const in sampler2DArray tex, int index, float angle, float dist){
  vec2 circleUV = fma(vec2(sin(vec2(angle * 3.141592653589793) + vec2(0.0, 1.5707963267948966))), vec2(clamp(dist, 0.0, 1.0)), vec2(0.0));
  return texture(tex, vec3(circleToSquare(circleUV), float(index))).x;
}

#endif