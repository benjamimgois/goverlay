#ifndef ENV_STARLIGHT_GLSL
#define ENV_STARLIGHT_GLSL

vec3 starlightHash33(uvec3 q){
  q *= uvec3(1597334673u, 3812015801u, 2798796415u);
  q ^= ((q.yzx + uvec3(1013904223u, 826366247u, 3014898611u)) * uvec3(1597334673u, 3812015801u, 2798796415u));
  q ^= ((q.zxy + uvec3(1013904223u, 826366247u, 3014898611u)) * uvec3(1597334673u, 3812015801u, 2798796415u));
  q = (q.x ^ q.y ^ q.z) * uvec3(1597334673u, 3812015801u, 2798796415u);
  return vec3(vec3(uintBitsToFloat(uvec3(uvec3(((q >> 9u) & uvec3(0x007fffffu)) | uvec3(0x3f800000u))))) - vec3(1.0));
}

vec3 starlightHash33(ivec3 p){
  uvec3 q = uvec3(p) * uvec3(1597334673u, 3812015801u, 2798796415u);
  q ^= ((q.yzx + uvec3(1013904223u, 826366247u, 3014898611u)) * uvec3(1597334673u, 3812015801u, 2798796415u));
  q ^= ((q.zxy + uvec3(1013904223u, 826366247u, 3014898611u)) * uvec3(1597334673u, 3812015801u, 2798796415u));
  q = (q.x ^ q.y ^ q.z) * uvec3(1597334673u, 3812015801u, 2798796415u);
  return vec3(vec3(uintBitsToFloat(uvec3(uvec3(((q >> 9u) & uvec3(0x007fffffu)) | uvec3(0x3f800000u))))) - vec3(1.0));
}

vec3 starlightHash33(vec3 p){
  uvec3 q = uvec3(ivec3(p)) * uvec3(1597334673u, 3812015801u, 2798796415u);
  q ^= ((q.yzx + uvec3(1013904223u, 826366247u, 3014898611u)) * uvec3(1597334673u, 3812015801u, 2798796415u));
  q ^= ((q.zxy + uvec3(1013904223u, 826366247u, 3014898611u)) * uvec3(1597334673u, 3812015801u, 2798796415u));
  q = (q.x ^ q.y ^ q.z) * uvec3(1597334673u, 3812015801u, 2798796415u);
  return vec3(vec3(uintBitsToFloat(uvec3(uvec3(((q >> 9u) & uvec3(0x007fffffu)) | uvec3(0x3f800000u))))) - vec3(1.0));
}


vec3 starlightNoise(in vec3 p){
  ivec3 i = ivec3(floor(p));  
  p -= vec3(i);
  vec3 w = (p * p) * (3.0 - (2.0 * p));
  ivec2 o = ivec2(0, 1);
  return mix(mix(mix(starlightHash33(i + o.xxx), starlightHash33(i + o.yxx), w.x),
                 mix(starlightHash33(i + o.xyx), starlightHash33(i + o.yyx), w.x), w.y),
             mix(mix(starlightHash33(i + o.xxy), starlightHash33(i + o.yxy), w.x),
                 mix(starlightHash33(i + o.xyy), starlightHash33(i + o.yyy), w.x), w.y), w.z);                     
}

vec2 starlightVoronoi(in vec3 x){
  x += vec3(1.0); 
  vec3 n = floor(x);
  vec3 f = x - n;
  vec4 m = vec4(uintBitsToFloat(0x7f800000u));
  for(int k = -1; k <= 1; k++){
    for(int j = -1; j <= 1; j++){
      for(int i = -1; i <= 1; i++){
        vec3 g = vec3(ivec3(i, j, k));  
        vec3 o = starlightHash33(n + g);
        vec3 r = (g - f) + o;
	      float d = dot(r, r);
        m = (d < m.w) ? vec4(o, d) : m;
      }  
    }
  }
  return vec2(sqrt(m.w), dot(m.xyz, vec3(1.0)));
}

float noise(vec3 p){
  vec3 f = fract(p);
  f = (f * f) * (3.0 - (2.0 * f));
  float n = dot(floor(p), vec3(1.0, 57.0, 113.0));
  vec4 a = fract(sin(vec4(n + 0.0, n + 1.0, n + 57.0, n + 58.0)) * 43758.5453123);
  vec4 b = fract(sin(vec4(n + 113.0, n + 114.0, n + 170.0, n + 171.0)) * 43758.5453123);
  return mix(mix(mix(a.x, a.y, f.x), mix(a.z, a.w, f.x), f.y), mix(mix(b.x, b.y, f.x), mix(b.z, b.w, f.x), f.y), f.z);
}                             

float fbm(vec3 p, const int steps) {
	float f = 0.0, m = 0.5, mm = 0.0, s = 0.0;
  for(int i = 0; i < steps; i++) {        
	  f += noise(p) * m;
	  s += m;
	  p *= mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64) * (2.0 + mm);
		m *= 0.5;
		mm += 0.0059;
	}
	return f / s;	 
}
        
float spaceHash(vec3 p){
  return fract(sin(dot(p, vec3(12.9898, 78.233, 151.7182))) * 43758.5453123);
}

vec3 space(vec3 rayOrigin, vec3 rayDirection){
  vec4 c = vec4(vec3(0.0), 0.015625);
  for(float t = 0.1; t < 1.6; t += 0.25){
    vec3 p = abs(vec3(1.7) - mod((vec3(0.1, 0.2, 1.0)) + (rayDirection * (t * 0.5)), vec3(3.4))), a = vec3(0.0);
    for(int i = 0; i < 16; i++){
      a.xy = vec2(a.x + abs((a.z = length(p = (abs(p) / dot(p, p)) - vec3(0.5))) - a.y), a.z);
    }       
    c = vec4(c.xyz + (((pow(vec3(t), vec3(t / 6.4, 1.0 + (t / 6.4), 2.0 + (t / 6.4)).zyx) * pow(a.x, 3.0) * 0.002) + vec3(1.0)) * c.w), c.w * 0.785);
  }
  c.xyz = clamp(pow(c.xyz, vec3(1.0)) * (1.0 / 128.0), vec3(0.0), vec3(2.0));
  c.xyz += pow(vec3((max(vec3(0.0), (fbm(rayDirection.yxz * vec3(7.0, 13.0, 1.0), 4) - 0.5) * vec3(1.0, 2.0, 3.0)) * (1.0 / (1.0 - 0.5)))), vec3(1.0)) * (1.0 / 512.0);
  //c.xyz += (vec3(pow(max(0.0, pow(spaceHash(floor(rayDirection * float(resolution.y)) / float(resolution.y)), 16.0) - 0.7) * (1.0 / (1.0 - 0.7)), 8.0)) * 1.0);
	return c.xyz; //pow(c.xyz, vec3(1.0));// * smoothstep(15e+3, 21e+3, length(rayOrigin) - Re);
}                                                       

vec3 starfield(vec3 rayDirection, float pixelScale){
  const vec3 lumianceAndColorOfTotalStarLight = 1.0825e-6 * vec3(0.9714, 1.0123, 1.0341);
  const float fractionOfIntegratedStarLight = 0.7169, 
	            power = -0.7684, 
              powerSum = 31.8768;	// = sum( i^-0.7684, i=1..9072 )
  vec3 absoluteRayDirection = abs(rayDirection);
  vec4 params = (absoluteRayDirection.x < absoluteRayDirection.y) 
                  ? ((absoluteRayDirection.y < absoluteRayDirection.z)
                      ?	vec4(rayDirection.xyz, 0.0) 
                      : vec4(rayDirection.zxy, 2.0))
                  : ((absoluteRayDirection.z < absoluteRayDirection.x)
                      ? vec4(rayDirection.yzx, 4.0) 
                      :	vec4(rayDirection.xyz, 0.0));
  float n = min(8344508.0, 2.0 / pixelScale),
        scale = ((2.0 * (n + 2.0)) / powerSum) * pow( length( params.xyz ), -n );
  vec3 cell = vec3(floor(asin(params.xy) * 5.09393754), params.w + sign( params.z )),
       color = vec3(0.0);//vec3(cell.xy / 7. + .5, cell.z / 5. );
  int k = 1 + int(mod(239. * dot(cell, vec3(1.0, 8.0, 64.0)), 384.0));
  uint rnd = uint(13 * k);
  for(int i = 0, numSamples = 27; i < numSamples; i++){		
  	vec2 phi = sin((cell.xy + vec2(rnd *= 3934873077u, rnd *= 3934873077u) / 4294967296.0) / 5.09393754);
    vec3 direction = vec3(phi, sign(params.z) * sqrt(1.0 - dot(phi, phi)));
    color += scale * pow(float(k + (384 * i)), power) * pow(dot(direction, params.xyz), n);
  }
  return mix(color, vec3(1.0), fractionOfIntegratedStarLight) *
         lumianceAndColorOfTotalStarLight;
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

  const float w = 64.0;  
  vec3 d = normalize(direction) * w;
  vec2 v = starlightVoronoi(d);
#ifdef COMPUTE_DERIVATIVES
  vec2 vdxy = vec2(starlightVoronoi(normalize(directionX) * w).x, starlightVoronoi(normalize(directionY) * w).x) - v.xx;
#else  
  vec2 vdxy = vec2(dFdxFine(v.x), dFdyFine(v.x));
#endif
  float f = max(1.0 / w, length(vdxy)) * 2.0;

  return vec3(
    clamp(
      (space(vec3(0.0), direction) * 0.1) +
      starfield(direction, f * 0.5) +
      vec3(smoothstep(0.0, 1.0, starlightNoise(d + vec3(3.0, 5.0, 7.0)).z) * smoothstep(f, 0.0, v.x) * 0.1) +
      vec3(0.0), 
      vec3(0.0), 
      vec3(65504.0)
    )
  );    

} 

#endif