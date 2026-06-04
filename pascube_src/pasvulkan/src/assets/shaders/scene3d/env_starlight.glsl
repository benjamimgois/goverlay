#ifndef ENV_STARLIGHT_GLSL
#define ENV_STARLIGHT_GLSL

uint starfieldFBMNoiseHash11(const in uint v){
  uint s = (v * 747796405u) + 2891336453u;
  uint w = ((s >> ((s >> 28u) + 4u)) ^ s) * 277803737u;
  return (w >> 22u) ^ w;
}

float starfieldFBMNoiseHash31(const in ivec3 i){
  uvec3 v = uvec3(i);
  return uintBitsToFloat(((starfieldFBMNoiseHash11(v.x + starfieldFBMNoiseHash11(v.y + starfieldFBMNoiseHash11(v.z))) >> 9u) & 0x007fffffu) | 0x3f800000u) - 1.0;
}
                       
float starfieldFBMNoise(in vec3 p){
  ivec3 i = ivec3(floor(p));  
  p -= vec3(i);
  vec3 w = (p * p) * (3.0 - (2.0 * p));
  ivec2 o = ivec2(0, 1);
  return mix(mix(mix(starfieldFBMNoiseHash31(i + o.xxx), starfieldFBMNoiseHash31(i + o.yxx), w.x),
                 mix(starfieldFBMNoiseHash31(i + o.xyx), starfieldFBMNoiseHash31(i + o.yyx), w.x), w.y),
             mix(mix(starfieldFBMNoiseHash31(i + o.xxy), starfieldFBMNoiseHash31(i + o.yxy), w.x),
                 mix(starfieldFBMNoiseHash31(i + o.xyy), starfieldFBMNoiseHash31(i + o.yyy), w.x), w.y), w.z);                     
}  

float starfieldFBM(vec3 p, const int steps) {
	float f = 0.0, m = 0.5, mm = 0.0, s = 0.0;
  for(int i = 0; i < steps; i++) {        
	  f += starfieldFBMNoise(p) * m;
	  s += m;
	  p *= mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64) * (2.0 + mm);
		m *= 0.5;
		mm += 0.0059;
	}
	return f / s;	 
}
        
vec3 starfield(vec3 rayDirection){
  vec4 c = vec4(vec3(0.0), 0.015625);
  for(float t = 0.1; t < 1.6; t += 0.25){
    vec3 p = abs(vec3(1.7) - mod((vec3(0.1, 0.2, 1.0)) + (rayDirection * (t * 0.5)), vec3(3.4))), a = vec3(0.0);
    for(int i = 0; i < 16; i++){
      a.xy = vec2(a.x + abs((a.z = length(p = (abs(p) / dot(p, p)) - vec3(0.5))) - a.y), a.z);
    }       
    c = vec4(c.xyz + (((pow(vec3(t), vec3(t / 6.4, 1.0 + (t / 6.4), 2.0 + (t / 6.4)).zyx) * pow(a.x, 3.0) * 0.002) + vec3(1.0)) * c.w), c.w * 0.785);
  }
  c.xyz = clamp(pow(c.xyz, vec3(1.0)) * (1.0 / 32.0), vec3(0.0), vec3(2.0));
  c.xyz += pow(vec3((max(vec3(0.0), (starfieldFBM(rayDirection.yxz * vec3(7.0, 13.0, 1.0), 4) - 0.5) * vec3(1.0, 2.0, 3.0)) * 2.0)), vec3(1.0)) * (1.0 / 128.0);
  vec3 absoluteRayDirection = abs(rayDirection);
  vec4 params = (absoluteRayDirection.x < absoluteRayDirection.y) 
                  ? ((absoluteRayDirection.y < absoluteRayDirection.z)
                      ?	vec4(rayDirection.xyz, 0.0) 
                      : vec4(rayDirection.zxy, 2.0))
                  : ((absoluteRayDirection.z < absoluteRayDirection.x)
                      ? vec4(rayDirection.yzx, 4.0) 
                      :	vec4(rayDirection.xyz, 0.0));
  vec2 uv = params.xy / (max(1e-5, abs(params.z)) * sign(params.z));
  vec4 positionBrightnessInverseSharpness = vec4((uv + vec2(2.0)) * 128.0, 1.0, -20.0);
  vec3 result = c.xyz;
  uint s = uint(params.w);
  for(uint i = 0u; i < 1u; i++){
    uvec4 v = uvec4(uvec2(positionBrightnessInverseSharpness.xy), s, i);
    v = (v * 1664525u) + 1013904223u;
    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;
    v = v ^ (v >> 16u);
    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;
    vec4 random = vec4(intBitsToFloat(ivec4(uvec4(((v >> 9u) & uvec4(0x007fffffu)) | uvec4(0x3f800000u))))) - vec4(1.0);
    float star = length(fma(random.xy - 0.5, vec2(-0.9), fract(positionBrightnessInverseSharpness.xy) - 0.5));
    float chroma = fma(random.z - 0.5, positionBrightnessInverseSharpness.z * 0.1, 0.5);
    result += vec3((1.0 - chroma) + pow(chroma, 5.0), 0.5, chroma) * 
              exp(positionBrightnessInverseSharpness.w * star) * 
              vec3(positionBrightnessInverseSharpness.z) * 
              pow(random.w, 16.0);
    positionBrightnessInverseSharpness *= vec3(0.25, 2.0, 1.75).xxyz;
  }
  return pow(result, vec3(1.0));
}
             
vec3 getStarlight(
#ifdef COMPUTE_DERIVATIVES
                  vec3 direction,
                  vec3 directionX, 
                  vec3 directionY
#else
                  vec3 direction                  
#endif
                 ){

  return clamp(starfield(direction), vec3(0.0), vec3(65504.0));    
  

} 

#endif