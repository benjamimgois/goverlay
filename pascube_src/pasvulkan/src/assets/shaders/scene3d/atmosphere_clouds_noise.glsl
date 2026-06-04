#ifndef ATMOSPHERE_CLOUDS_NOISE_GLSL
#define ATMOSPHERE_CLOUDS_NOISE_GLSL
 
vec3 interpolationC2(vec3 x){ 
  return ((x * x) * x) * (x * ((x * 6.0) - vec3(15.0)) + vec3(10.0)); 
}

vec4 interpolationC2(vec4 x){ 
  return ((x * x) * x) * (x * ((x * 6.0) - vec4(15.0)) + vec4(10.0)); 
}

void perlinHash(vec3 c, float s, const in bool t, out vec4 lh0, out vec4 lh1, out vec4 lh2, out vec4 hh0, out vec4 hh1, out vec4 hh2){
	const vec2 OFFSET = vec2(50.0, 161.0);
	const float DOMAIN = 69.0;
	const vec3 SOMELARGEFLOATS = vec3(635.298681, 682.357502, 668.926525);
	const vec3 ZINC = vec3(48.500388, 65.294118, 63.934599);
	c.xyz = c.xyz - floor(c.xyz * (1.0 / DOMAIN)) * DOMAIN;
	float d = DOMAIN - 1.5;
	vec3 c1 = step(c, vec3(d)) * (c + vec3(1.0));
	c1 = t ? mod(c1, vec3(s)) : c1;
	vec4 P = vec4(c.xy, c1.xy) + OFFSET.xyxy;
	P *= P;
	P = P.xzxz * P.yyww;
	vec3 lm = vec3(vec3(1.0) / (SOMELARGEFLOATS.xyz + (c.zzz * ZINC.xyz)));
	vec3 hm = vec3(vec3(1.0) / (SOMELARGEFLOATS.xyz + (c1.zzz * ZINC.xyz)));
	lh0 = fract(P * lm.xxxx);
	hh0 = fract(P * hm.xxxx);
	lh1 = fract(P * lm.yyyy);
	hh1 = fract(P * hm.yyyy);
	lh2 = fract(P * lm.zzzz);
	hh2 = fract(P * hm.zzzz);
} 

void perlinHash(vec4 c, float s, const in bool t, out vec4 lh0, out vec4 lh1, out vec4 lh2, out vec4 lh3, out vec4 hh0, out vec4 hh1, out vec4 hh2, out vec4 hh3){
	const vec2 OFFSET = vec2(50.0, 161.0);
	const float DOMAIN = 69.0;
	const vec4 SOMELARGEFLOATS = vec4(635.298681, 682.357502, 668.926525, 652.411521);
	const vec4 ZINC = vec4(48.500388, 65.294118, 63.934599, 57.141341);
	c.xyzw = c.xyzw - floor(c.xyzw * (1.0 / DOMAIN)) * DOMAIN;
	float d = DOMAIN - 1.5;
	vec4 c1 = step(c, vec4(d)) * (c + vec4(1.0));
	c1 = t ? mod(c1, vec4(s)) : c1;
	vec4 P = vec4(c.xy, c1.xy) + OFFSET.xyxy;
	P *= P;
	P = P.xzxz * P.yyww;
	vec4 lm = vec4(vec4(1.0) / (SOMELARGEFLOATS.xyzw + (c.zzzz * ZINC.xyzw)));
	vec4 hm = vec4(vec4(1.0) / (SOMELARGEFLOATS.xyzw + (c1.zzzz * ZINC.xyzw)));
	lh0 = fract(P * lm.xxxx);
	hh0 = fract(P * hm.xxxx);
	lh1 = fract(P * lm.yyyy);
	hh1 = fract(P * hm.yyyy);
	lh2 = fract(P * lm.zzzz);
	hh2 = fract(P * hm.zzzz);
	lh3 = fract(P * lm.wwww);
	hh3 = fract(P * hm.wwww);
} 

void perlinHash(vec4 gridcell,
                float s,
                bool t,  
                out vec4 z0w0_hash_0,		//  vec4 == ( x0y0, x1y0, x0y1, x1y1 )
                out vec4 z0w0_hash_1,
                out vec4 z0w0_hash_2,
                out vec4 z0w0_hash_3,
                out vec4 z1w0_hash_0,
                out vec4 z1w0_hash_1,
                out vec4 z1w0_hash_2,
                out vec4 z1w0_hash_3,
                out vec4 z0w1_hash_0,
                out vec4 z0w1_hash_1,
                out vec4 z0w1_hash_2,
                out vec4 z0w1_hash_3,
                out vec4 z1w1_hash_0,
                out vec4 z1w1_hash_1,
                out vec4 z1w1_hash_2,
                out vec4 z1w1_hash_3)
{
    const vec4 OFFSET = vec4( 16.841230, 18.774548, 16.873274, 13.664607 );
    const float DOMAIN = 69.0;
    const vec4 SOMELARGEFLOATS = vec4( 56974.746094, 47165.636719, 55049.667969, 49901.273438 );
    const vec4 SCALE = vec4( 0.102007, 0.114473, 0.139651, 0.084550 );

    gridcell = gridcell - floor(gridcell * ( 1.0 / DOMAIN )) * DOMAIN;
    vec4 gridcell_inc1 = step( gridcell, vec4( DOMAIN - 1.5 ) ) * ( gridcell + 1.0 );
    gridcell_inc1 = t ? mod(gridcell_inc1, vec4(s)) : gridcell_inc1; 

    //	calculate the noise
    gridcell = ( gridcell * SCALE ) + OFFSET;
    gridcell_inc1 = ( gridcell_inc1 * SCALE ) + OFFSET;
    gridcell *= gridcell;
    gridcell_inc1 *= gridcell_inc1;

    vec4 x0y0_x1y0_x0y1_x1y1 = vec4( gridcell.x, gridcell_inc1.x, gridcell.x, gridcell_inc1.x ) * vec4( gridcell.yy, gridcell_inc1.yy );
    vec4 z0w0_z1w0_z0w1_z1w1 = vec4( gridcell.z, gridcell_inc1.z, gridcell.z, gridcell_inc1.z ) * vec4( gridcell.ww, gridcell_inc1.ww );

    vec4 hashval = x0y0_x1y0_x0y1_x1y1 * z0w0_z1w0_z0w1_z1w1.xxxx;
    z0w0_hash_0 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.x ) );
    z0w0_hash_1 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.y ) );
    z0w0_hash_2 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.z ) );
    z0w0_hash_3 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.w ) );
    hashval = x0y0_x1y0_x0y1_x1y1 * z0w0_z1w0_z0w1_z1w1.yyyy;
    z1w0_hash_0 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.x ) );
    z1w0_hash_1 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.y ) );
    z1w0_hash_2 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.z ) );
    z1w0_hash_3 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.w ) );
    hashval = x0y0_x1y0_x0y1_x1y1 * z0w0_z1w0_z0w1_z1w1.zzzz;
    z0w1_hash_0 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.x ) );
    z0w1_hash_1 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.y ) );
    z0w1_hash_2 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.z ) );
    z0w1_hash_3 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.w ) );
    hashval = x0y0_x1y0_x0y1_x1y1 * z0w0_z1w0_z0w1_z1w1.wwww;
    z1w1_hash_0 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.x ) );
    z1w1_hash_1 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.y ) );
    z1w1_hash_2 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.z ) );
    z1w1_hash_3 = fract( hashval * ( 1.0 / SOMELARGEFLOATS.w ) );
}

float perlin(vec3 p, float s, const in bool t) {
  p *= s;
	vec3 pt = floor(p),
       pf = fract(p),
       pfm1 = pf - vec3(1.0);
	vec4 hx0, hy0, hz0, hx1, hy1, hz1;
	perlinHash(pt, s, t, hx0, hy0, hz0, hx1, hy1, hz1);
	vec4 gx0 = hx0 - vec4(0.49999), 
       gy0 = hy0 - vec4(0.49999), 
       gz0 = hz0 - vec4(0.49999), 
       gx1 = hx1 - vec4(0.49999), 
       gy1 = hy1 - vec4(0.49999), 
       gz1 = hz1 - vec4(0.49999),
       a = ((vec2(pf.x, pfm1.x).xyxy * gx0) + 
            (vec2(pf.y, pfm1.y).xxyy * gy0) + 
            (pf.zzzz * gz0)) / 
           sqrt((gx0 * gx0) + (gy0 * gy0) + (gz0 * gz0)),
       b = ((vec2(pf.x, pfm1.x).xyxy * gx1) + 
            (vec2(pf.y, pfm1.y).xxyy * gy1) + 
            (pfm1.zzzz * gz1)) /
            sqrt((gx1 * gx1) + (gy1 * gy1) + (gz1 * gz1));
	vec3 c = interpolationC2(pf);
	vec4 d = vec4(c.xy, vec2(vec2(1.0) - c.xy));
	return ((dot(mix(a ,b, c.z), d.zxzx * d.wwyy) * ((1.0 / sqrt(0.75)) * 1.5)) + 1.0) * 0.5;
}

float perlin(vec3 p){
	return perlin(p, 1.0, false);
}

float perlin(vec4 p, float s, const in bool t) {
#if 0
   vec4 P = p * s;
    // establish our grid cell and unit position
    vec4 Pi = floor(P);
    vec4 Pf = P - Pi;
    vec4 Pf_min1 = Pf - 1.0;

    //    calculate the hash.
    vec4 lowz_loww_hash_0, lowz_loww_hash_1, lowz_loww_hash_2, lowz_loww_hash_3;
    vec4 highz_loww_hash_0, highz_loww_hash_1, highz_loww_hash_2, highz_loww_hash_3;
    vec4 lowz_highw_hash_0, lowz_highw_hash_1, lowz_highw_hash_2, lowz_highw_hash_3;
    vec4 highz_highw_hash_0, highz_highw_hash_1, highz_highw_hash_2, highz_highw_hash_3;
    perlinHash(
        Pi,
        s,
        t,        
        lowz_loww_hash_0, lowz_loww_hash_1, lowz_loww_hash_2, lowz_loww_hash_3,
        highz_loww_hash_0, highz_loww_hash_1, highz_loww_hash_2, highz_loww_hash_3,
        lowz_highw_hash_0, lowz_highw_hash_1, lowz_highw_hash_2, lowz_highw_hash_3,
        highz_highw_hash_0, highz_highw_hash_1, highz_highw_hash_2, highz_highw_hash_3 );

    //	calculate the gradients
    lowz_loww_hash_0 -= 0.49999;
    lowz_loww_hash_1 -= 0.49999;
    lowz_loww_hash_2 -= 0.49999;
    lowz_loww_hash_3 -= 0.49999;
    highz_loww_hash_0 -= 0.49999;
    highz_loww_hash_1 -= 0.49999;
    highz_loww_hash_2 -= 0.49999;
    highz_loww_hash_3 -= 0.49999;
    lowz_highw_hash_0 -= 0.49999;
    lowz_highw_hash_1 -= 0.49999;
    lowz_highw_hash_2 -= 0.49999;
    lowz_highw_hash_3 -= 0.49999;
    highz_highw_hash_0 -= 0.49999;
    highz_highw_hash_1 -= 0.49999;
    highz_highw_hash_2 -= 0.49999;
    highz_highw_hash_3 -= 0.49999;

    vec4 grad_results_lowz_loww = inversesqrt( lowz_loww_hash_0 * lowz_loww_hash_0 + lowz_loww_hash_1 * lowz_loww_hash_1 + lowz_loww_hash_2 * lowz_loww_hash_2 + lowz_loww_hash_3 * lowz_loww_hash_3 );
    grad_results_lowz_loww *= ( vec2( Pf.x, Pf_min1.x ).xyxy * lowz_loww_hash_0 + vec2( Pf.y, Pf_min1.y ).xxyy * lowz_loww_hash_1 + Pf.zzzz * lowz_loww_hash_2 + Pf.wwww * lowz_loww_hash_3 );

    vec4 grad_results_highz_loww = inversesqrt( highz_loww_hash_0 * highz_loww_hash_0 + highz_loww_hash_1 * highz_loww_hash_1 + highz_loww_hash_2 * highz_loww_hash_2 + highz_loww_hash_3 * highz_loww_hash_3 );
    grad_results_highz_loww *= ( vec2( Pf.x, Pf_min1.x ).xyxy * highz_loww_hash_0 + vec2( Pf.y, Pf_min1.y ).xxyy * highz_loww_hash_1 + Pf_min1.zzzz * highz_loww_hash_2 + Pf.wwww * highz_loww_hash_3 );

    vec4 grad_results_lowz_highw = inversesqrt( lowz_highw_hash_0 * lowz_highw_hash_0 + lowz_highw_hash_1 * lowz_highw_hash_1 + lowz_highw_hash_2 * lowz_highw_hash_2 + lowz_highw_hash_3 * lowz_highw_hash_3 );
    grad_results_lowz_highw *= ( vec2( Pf.x, Pf_min1.x ).xyxy * lowz_highw_hash_0 + vec2( Pf.y, Pf_min1.y ).xxyy * lowz_highw_hash_1 + Pf.zzzz * lowz_highw_hash_2 + Pf_min1.wwww * lowz_highw_hash_3 );

    vec4 grad_results_highz_highw = inversesqrt( highz_highw_hash_0 * highz_highw_hash_0 + highz_highw_hash_1 * highz_highw_hash_1 + highz_highw_hash_2 * highz_highw_hash_2 + highz_highw_hash_3 * highz_highw_hash_3 );
    grad_results_highz_highw *= ( vec2( Pf.x, Pf_min1.x ).xyxy * highz_highw_hash_0 + vec2( Pf.y, Pf_min1.y ).xxyy * highz_highw_hash_1 + Pf_min1.zzzz * highz_highw_hash_2 + Pf_min1.wwww * highz_highw_hash_3 );

    // Classic Perlin Interpolation
    vec4 blend = interpolationC2( Pf );
    vec4 res0 = grad_results_lowz_loww + ( grad_results_lowz_highw - grad_results_lowz_loww ) * blend.wwww;
    vec4 res1 = grad_results_highz_loww + ( grad_results_highz_highw - grad_results_highz_loww ) * blend.wwww;
    res0 = res0 + ( res1 - res0 ) * blend.zzzz;
    blend.zw = vec2( 1.0 ) - blend.xy;
    return dot( res0, blend.zxzx * blend.wwyy);
#elif 1
  vec3 pa = p.xyz + vec3((floor(p.w) * 0.61803398875), 0.0, 0.0),pb = p.xyz + vec3((floor(p.w + 1.0) * 0.61803398875), 0.0, 0.0);
  float va = perlin(pa, s, t), vb = perlin(pb, s, t);
  return mix(va, vb, fract(p.w));
#else
  p *= s;
	vec4 pt = floor(p),
       pf = fract(p),
       pfm1 = pf - vec4(1.0);
	vec4 hx0, hy0, hz0, hw0, hx1, hy1, hz1, hw1;
	perlinHash(pt, s, t, hx0, hy0, hz0, hw0, hx1, hy1, hz1, hw1);
	vec4 gx0 = hx0 - vec4(0.49999), 
       gy0 = hy0 - vec4(0.49999), 
       gz0 = hz0 - vec4(0.49999), 
       gw0 = hw0 - vec4(0.49999), 
       gx1 = hx1 - vec4(0.49999), 
       gy1 = hy1 - vec4(0.49999), 
       gz1 = hz1 - vec4(0.49999), 
       gw1 = hw1 - vec4(0.49999),
       a = ((vec2(pf.x, pfm1.x).xyxy * gx0) + 
            (vec2(pf.y, pfm1.y).xxyy * gy0) + 
            (pf.zzzz * gz0)/*+ 
            (pf.wwww * gw0)*/) / 
           sqrt((gx0 * gx0) + (gy0 * gy0) + (gz0 * gz0) + (gw0 * gw0)),
       b = ((vec2(pf.x, pfm1.x).xyxy * gx1) + 
            (vec2(pf.y, pfm1.y).xxyy * gy1) + 
            (pfm1.zzzz * gz1)/*+ 
            (pfm1.wwww * gw1)*/) /
            sqrt((gx1 * gx1) + (gy1 * gy1) + (gz1 * gz1) + (gw1 * gw1));
	vec4 c = interpolationC2(pf);
	vec4 d = vec4(c.xy, vec2(vec2(1.0) - c.xy));
	return ((dot(mix(a, b, c.z), d.zxzx * d.wwyy) * ((1.0 / sqrt(0.75)) * 1.5)) + 1.0) * 0.5;
#endif  
}

float perlin(vec4 p){
	return perlin(p, 1.0, false);
}

vec3 voronoiHash(vec3 x, float s){
	x = mod(x, vec3(s));
	return fract(sin(vec3(dot(x, vec3(127.1, 311.7, 74.7)),
		                    dot(x, vec3(269.5, 183.3, 246.1)),
				                dot(x, vec3(113.5, 271.9, 124.6)))) * 43758.5453123);
}

vec4 voronoiHash(vec4 x, float s){
	x = mod(x, vec4(s));
	return fract(sin(vec4(dot(x, vec4(127.1, 311.7, 74.7, 172.1)),
		                    dot(x, vec4(269.5, 183.3, 246.1, 293.6)),
				                dot(x, vec4(113.5, 271.9, 124.6, 165.4)),
				                dot(x, vec4(304.8, 138.2, 212.2, 154.3)))) * 43758.5453123);
}

vec3 voronoi(in vec3 x, float s, float seed, bool inverted){
	x = fma(x, vec3(s), vec3(0.5));
	vec3 p = floor(x),
       f = fract(x);
	float id = 0.0;
	vec2 r = vec2(1.0);
	for(int k = -1; k <= 1; k++){
		for(int j = -1; j <= 1; j++) {
			for(int i = -1; i <= 1; i++) {
				vec3 b = vec3(ivec3(i, j, k)),
             t = (vec3(b) - f) + voronoiHash(p + b + (seed * 10.0), s);
				float d = dot(t, t);
				if(d < r.x){ 
					id = dot(p + b, vec3(1.0, 57.0, 113.0));
					r = vec2(d, r.x);			
				}else if(d < r.y){
					r.y = d;
				}
			}
		}
	}
	//r = sqrt(r);
	return vec3(inverted ? (vec2(1.0) - r) : r, abs(id));
}

vec3 voronoi(in vec4 x, float s, float seed, bool inverted){
	x = fma(x, vec4(s), vec4(0.5));
	vec4 p = floor(x),
       f = fract(x);
	float id = 0.0;
	vec2 r = vec2(1.0);
	for(int h = -1; h <= 1; h++){
	  for(int k = -1; k <= 1; k++){
		  for(int j = -1; j <= 1; j++) {
			  for(int i = -1; i <= 1; i++) {
				  vec4 b = vec4(ivec4(i, j, k, h)),
               t = (vec4(b) - f) + voronoiHash(p + b + (seed * 10.0), s);
				  float d = dot(t, t);
				  if(d < r.x){ 
					  id = dot(p + b, vec4(1.0, 57.0, 113.0, 227.0));
					  r = vec2(d, r.x);			
				  }else if(d < r.y){
					  r.y = d;
				  }
			  }
		  }
	  }
  }
	//r = sqrt(r);
	return vec3(inverted ? (vec2(1.0) - r) : r, abs(id));
}

float getWorley2Octaves(vec3 p, float s, float seed){
	return dot(clamp(vec2(voronoi(p, s * 1.0, seed, true).x, 
                        voronoi(p, s * 2.0, seed, false).x), 
                   vec2(0.0), 
                   vec2(1.0)), 
             vec2(1.0, -0.25));
}

float getWorley2Octaves(vec4 p, float s, float seed){
	return dot(clamp(vec2(voronoi(p, s * 1.0, seed, true).x, 
                        voronoi(p, s * 2.0, seed, false).x), 
                   vec2(0.0), 
                   vec2(1.0)), 
             vec2(1.0, -0.25));
}

float getWorley2Octaves(vec3 p, float s){
  return getWorley2Octaves(p, s, 0.0);
}

float getWorley2Octaves(vec4 p, float s){
  return getWorley2Octaves(p, s, 0.0);
}

float getWorley3Octaves(vec3 p, float s, float seed){
	return dot(clamp(vec3(voronoi(p, s * 1.0, seed, true).x, 
                        voronoi(p, s * 2.0, seed, false).x, 
                        voronoi(p, s * 4.0, seed, false).x), 
                   vec3(0.0), 
                   vec3(1.0)), 
             vec2(1.0, -0.3).xyy);
}

float getWorley3Octaves(vec4 p, float s, float seed){
	return dot(clamp(vec3(voronoi(p, s * 1.0, seed, true).x, 
                        voronoi(p, s * 2.0, seed, false).x, 
                        voronoi(p, s * 4.0, seed, false).x), 
                   vec3(0.0), 
                   vec3(1.0)), 
             vec2(1.0, -0.3).xyy);
}

float getWorley3Octaves(vec3 p, float s){
  return getWorley3Octaves(p, s, 0.0);
}

float getWorley3Octaves(vec4 p, float s){
  return getWorley3Octaves(p, s, 0.0);
}

float getPerlin3Octaves(vec3 p, float s, const in bool t){
  return (perlin(p, s * 1.0, true).x * 1.0) +
         (perlin(p, s * 2.0, true).x * 0.5) +
         (perlin(p, s * 4.0, true).x * 0.25);
}

float getPerlin3Octaves(vec4 p, float s, const in bool t){
  return (perlin(p, s * 1.0, true).x * 1.0) +
         (perlin(p, s * 2.0, true).x * 0.5) +
         (perlin(p, s * 4.0, true).x * 0.25);
}

float getPerlin5Octaves(vec3 p, const in bool t){
  return (perlin(p * 1.0, 1.0, t).x * 1.0) +
         (perlin(p * 2.02, 1.0, t).x * 0.5) +
         (perlin(p * 4.1006, 1.0, t).x * 0.25) +
         (perlin(p * 8.242206, 1.0, t).x * 0.125) +
         (perlin(p * 16.56683406, 1.0, t).x * 0.0625);
}

float getPerlin5Octaves(vec4 p, const in bool t){
  return (perlin(p * 1.0, 1.0, t).x * 1.0) +
         (perlin(p * 2.02, 1.0, t).x * 0.5) +
         (perlin(p * 4.1006, 1.0, t).x * 0.25) +
         (perlin(p * 8.242206, 1.0, t).x * 0.125) +
         (perlin(p * 16.56683406, 1.0, t).x * 0.0625);
}

float getPerlin5Octaves(vec3 p, float s, const in bool t){
  return (perlin(p, s * 1.0, true).x * 1.0) +
         (perlin(p, s * 2.0, true).x * 0.5) +
         (perlin(p, s * 4.0, true).x * 0.25) +
         (perlin(p, s * 8.0, true).x * 0.125) +
         (perlin(p, s * 16.0, true).x * 0.0625);
}

float getPerlin5Octaves(vec4 p, float s, const in bool t){
  return (perlin(p, s * 1.0, true).x * 1.0) +
         (perlin(p, s * 2.0, true).x * 0.5) +
         (perlin(p, s * 4.0, true).x * 0.25) +
         (perlin(p, s * 8.0, true).x * 0.125) +
         (perlin(p, s * 16.0, true).x * 0.0625);
}

float getPerlin7Octaves(vec3 p, float s, const in bool t){
	return (perlin(p, s * 1.0, t).x * 1.0) +
         (perlin(p, s * 2.0, t).x * 0.5) +
         (perlin(p, s * 4.0, t).x * 0.25) +
         (perlin(p, s * 8.0, t).x * 0.125) +
         (perlin(p, s * 16.0, t).x * 0.0625) +
         (perlin(p, s * 32.0, t).x * 0.03125) +
         (perlin(p, s * 64.0, t).x * 0.015625);
}

float getPerlin7Octaves(vec4 p, float s, const in bool t){
	return (perlin(p, s * 1.0, t).x * 1.0) +
         (perlin(p, s * 2.0, t).x * 0.5) +
         (perlin(p, s * 4.0, t).x * 0.25) +
         (perlin(p, s * 8.0, t).x * 0.125) +
         (perlin(p, s * 16.0, t).x * 0.0625) +
         (perlin(p, s * 32.0, t).x * 0.03125) +
         (perlin(p, s * 64.0, t).x * 0.015625);
}

vec3 curlNoise(vec3 p){
	vec4 e = vec4(0.0, -1.0, 1.0, 2.0) * 5e-2;
  vec3 t = vec3(getPerlin5Octaves(p + e.zxx, false) - getPerlin5Octaves(p + e.yxx, false),
                getPerlin5Octaves(p + e.xzx, false) - getPerlin5Octaves(p + e.xyx, false),
                getPerlin5Octaves(p + e.xxz, false) - getPerlin5Octaves(p + e.xxy, false));
	return (t.yzx - t.zxy) / e.w;
}

vec3 curlNoise(vec4 p){
	vec4 e = vec4(0.0, -1.0, 1.0, 2.0) * 5e-2;
  vec3 t = vec3(getPerlin5Octaves(p + e.zxxx, false) - getPerlin5Octaves(p + e.yxxx, false),
                getPerlin5Octaves(p + e.xzxx, false) - getPerlin5Octaves(p + e.xyxx, false),
                getPerlin5Octaves(p + e.xxzx, false) - getPerlin5Octaves(p + e.xxyx, false));
	return (t.yzx - t.zxy) / e.w;
}

float dilatePerlinWorley(float p, float w, float x) {
	float curve = 0.75;
	if(x < 0.5){
		x *= 2.0;
		return fma(w, x, p) * mix(1.0, 0.5, pow(x, curve));
	}else{
		x = (x - 0.5) * 2.0;
		return fma(p, 1.0 - x, w) * mix(0.5, 1.0, pow(x, 1.0 / curve));
	}
}

#endif