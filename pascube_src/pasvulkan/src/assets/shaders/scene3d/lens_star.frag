#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

float noise(vec2 p){
  vec2 f = fract(p);
  f = (f * f) * (3.0 - (2.0 * f));    
	float n = dot(floor(p), vec2(1.0, 157.0));
  vec4 a = fract(sin(vec4(n + 0.0, n + 1.0, n + 157.0, n + 158.0)) * 43758.5453123);
  return mix(mix(a.x, a.y, f.x), mix(a.z, a.w, f.x), f.y);
} 

float fbm(vec2 p){
  const mat2 m = mat2(0.80, -0.60, 0.60, 0.80);
  float f = 0.0;
  f += 0.5000 * noise(p); p = m * p * 2.02;
  f += 0.2500 * noise(p); p = m * p * 2.03;
  f += 0.1250 * noise(p); p = m * p* 2.01;
  f += 0.0625 * noise(p);
  return f / 0.9375;
} 

vec4 getLensStar(vec2 p){
  // just be creative to create your own procedural lens star textures :)
  vec2 pp = (p - vec2(0.5)) * 2.0;
  float a = atan(pp.y, pp.x);
  vec4 cp = vec4(sin(a * 1.0), length(pp), sin(a * 13.0), sin(a * 53.0));
  float d = sin(clamp(pow(length(vec2(0.5) - p) * 2.0, 5.0), 0.0, 1.0) * 3.14159);
  vec3 c = vec3(d) * vec3(fbm(cp.xy * 16.0) * fbm(cp.zw * 9.0) * max(max(max(max(0.5, sin(a * 1.0)), sin(a * 3.0) * 0.8), sin(a * 7.0) * 0.8), sin(a * 9.0) * 0.6));
  c *= vec3(mix(1.0, (sin(length(pp.xy) * 256.0) * 0.5) + 0.5, sin((clamp((length(pp.xy) - 0.875) / 0.1, 0.0, 1.0) + 0.0) * 2.0 * 3.14159) * 0.5) + 0.5) * 0.3275;
  return vec4(vec3(c * 4.0), d);	
}

void main(){
  outFragColor = getLensStar(inTexCoord.xy);
}
