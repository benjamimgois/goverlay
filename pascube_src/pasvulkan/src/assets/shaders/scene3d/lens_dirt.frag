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

vec4 getLensDirt(vec2 p){
  // just be creative to create your own procedural lens dirt textures :)
  p.xy += vec2(fbm(p.yx * 3.0), fbm(p.yx * 6.0)) * 0.0625;
  vec3 o = vec3(mix(0.125, 0.25, max(max(smoothstep(0.4, 0.0, length(p - vec2(0.25))),
                                         smoothstep(0.4, 0.0, length(p - vec2(0.75)))),
                                         smoothstep(0.8, 0.0, length(p - vec2(0.875, 0.25))))));
  o += vec3(max(fbm(p * 1.0) - 0.5, 0.0)) * 0.5;
  o += vec3(max(fbm(p * 2.0) - 0.5, 0.0)) * 0.5;
  o += vec3(max(fbm(p * 4.0) - 0.5, 0.0)) * 0.25;
  o += vec3(max(fbm(p * 8.0) - 0.75, 0.0)) * 1.0;
  o += vec3(max(fbm(p * 16.0) - 0.75, 0.0)) * 0.75;
  o += vec3(max(fbm(p * 64.0) - 0.75, 0.0)) * 0.5;
  return vec4(clamp(o, vec3(0.0), vec3(1.0)), 1.0);	
}

void main(){
  outFragColor = getLensDirt(inTexCoord.xy);
}
