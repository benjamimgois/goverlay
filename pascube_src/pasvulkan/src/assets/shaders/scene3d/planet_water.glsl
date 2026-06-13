#ifndef PLANET_WATER_GLSL
#define PLANET_WATER_GLSL

#include "octahedral.glsl"

#include "octahedralmap.glsl"

#if 1
// This solveQuadraticRoots function offers a significant improvement over the old solveQuadraticRoots
// function in terms of numerical stability and accuracy. In computing, especially for floating-point
// numbers, the representation and precision of real numbers are limited, which can lead to issues
// like loss of significance and catastrophic cancellation. This problem is particularly acute when
// dealing with values that are very close in magnitude but have opposite signs.
// The old solveQuadraticRoots function uses a direct approach to calculate the roots of the quadratic
// equation, which suffers from these numerical stability issues. Specifically, when 'b' and the
// square root of the discriminant ('d') in the quadratic formula have values close to each other
// but opposite in sign, it can lead to significant errors due to rounding and cancellation.
// This solveQuadraticRoots function addresses this by using an alternative formulation:
// q = -0.5 * (b + sign(b) * sqrt(b^2 - 4ac))
// t0 = q / a
// t1 = c / q
// This approach ensures that the terms added to compute 'q' always have the same sign, thus avoiding
// the catastrophic cancellation that can occur in the OldSolveQuadraticRoots function. By doing so,
// this solveQuadraticRoots provides more reliable and accurate results, particularly in edge cases 
// where precision is crucial.
bool solveQuadraticRoots(float a, float b, float c, out vec2 t){
  float discriminant = (b * b) - ((a * c) * 4.0);
  if(discriminant < 0.0){
    t = vec2(0.0);
    return false;
  }else{
    if(discriminant == 0.0){
      t = vec2(((-0.5 * b) / a));
    }else{
      float q = (b + (sqrt(discriminant) * (b > 0.0 ? 1.0 : -1.0))) * (-0.5);
      t = vec2(q / a, c / q);
      if(t.x > t.y){
        t = t.yx;
      }
    }  
    return true;
  }
}
#else
bool solveQuadraticRoots(float a, float b, float c, out vec2 t){
  float discriminant = (b * b) - ((a * c) * 4.0);
  if(discriminant < 0.0){
    t = vec2(0.0);
    return false;
  }else{
    float a2 = a * 2.0;
    if(abs(a2) < 1e-7){
      t = vec2(0.0);
      return false;
    }else{
      float inverseDenominator = 1.0 / a2;
      if(abs(discriminant) < 1e-7){
        t = vec2((-b) * inverseDenominator);
      }else{
        t = fma(vec2(sqrt(discriminant)), vec2(-1.0, 1.0), vec2(-b)) * inverseDenominator;
        if(t.x > t.y){
          t = t.yx;
        }
      }
      return true;
    }
  }
}
#endif

bool intersectRaySphere(vec4 sphere, vec3 rayOrigin, vec3 rayDirection, out float time){
  vec3 sphereCenterToRayOrigin = rayOrigin - sphere.xyz;
  vec2 t;
  bool result = solveQuadraticRoots(dot(rayDirection, rayDirection), 
                                    dot(rayDirection, sphereCenterToRayOrigin) * 2.0, 
                                    dot(sphereCenterToRayOrigin, sphereCenterToRayOrigin) - (sphere.w * sphere.w), 
                                    t);
  if(result){
    if(t.x > t.y){
      t = t.yx;
    }
    if(t.x < 0.0){
      t.x = t.y;
      if(t.x < 0.0){
        result = false;
      }
    }    
    time = t.x;
  }
  return result;
}

bool intersectRaySphere(vec4 sphere, vec3 rayOrigin, vec3 rayDirection, out vec2 times){
  vec3 sphereCenterToRayOrigin = rayOrigin - sphere.xyz;
  vec2 t;
  bool result = solveQuadraticRoots(dot(rayDirection, rayDirection), 
                                    dot(rayDirection, sphereCenterToRayOrigin) * 2.0, 
                                    dot(sphereCenterToRayOrigin, sphereCenterToRayOrigin) - (sphere.w * sphere.w), 
                                    t);
  if(result){
    if(t.x > t.y){
      t = t.yx;
    }
    if(t.x < 0.0){
      t.x = t.y;
      if(t.x < 0.0){
        result = false;
      }
    }    
    times = t;
  }
  return result;
}

float getWaves(vec2 position, int iterations){
  vec2 frequencyTimeMultiplier = vec2(1.0, 2.0);
  float weight = 1.0;
  vec2 result = vec2(0.0);
  float time = pushConstants.time; 
  float r = 0.0; 
  for(int i = 0; i < iterations; i++){
    vec2 p = sin(vec2(r) + vec2(0.0, 1.5707963267948966));
    vec2 sinCosX = sin((vec2(dot(p, position) * frequencyTimeMultiplier.x) + (time * frequencyTimeMultiplier.y)) + vec2(0.0, 1.5707963267948966));
    vec2 res = exp(sinCosX.x - 1.0) * vec2(1.0, -sinCosX.y);
    position += p * res.y * weight * 0.38;
    result += vec2(res.x, 1.0) * weight;
    weight = mix(weight, 0.0, 0.2);
    frequencyTimeMultiplier *= vec2(1.18, 1.07);
    r += 1232.399963;
  }
  return result.x / result.y;
}

float getWaterRippleHeight(vec2 uv){
  // Samples the current water ripple ping-pong image (red channel = ripple height
  // in world-space units). Returns 0.0 when the ripple subsystem is disabled
  // (waterRippleMapResolution == 0) so callers can unconditionally add this value.
  // Only available when planet_data.glsl is included by the caller; otherwise the
  // ripple contribution is silently zero (e.g. in prepass shaders that do not bind
  // the planet data SSBO).
#ifdef PLANET_DATA_GLSL
  if(planetData.waterRippleMapResolution == 0u){
    return 0.0;
  }
  uint rippleTextureIndex = PLANET_TEXTURE_WATERRIPPLEMAP_PING + (planetData.waterRippleReadIndex & 1u);
  return texture(uPlanetTextures[rippleTextureIndex], uv).x;
#else
  return 0.0;
#endif
}

float getWaterRippleHeight(vec3 n){
#ifdef PLANET_DATA_GLSL
  if(planetData.waterRippleMapResolution == 0u){
    return 0.0;
  }
  uint rippleTextureIndex = PLANET_TEXTURE_WATERRIPPLEMAP_PING + (planetData.waterRippleReadIndex & 1u);
  vec2 uv = octPlanetUnsignedEncode(n) + (vec2(0.5) / vec2(textureSize(uPlanetTextures[rippleTextureIndex], 0).xy));
  return texture(uPlanetTextures[rippleTextureIndex], uv).x;
#else
  return 0.0;
#endif
}

// PCG-style 2D integer hash — returns a pseudo-random uint for a grid cell.
uint rainDropCellHash(int cx, int cy){
  uint h = uint((cx * 1664525) + (cy * 22695477) + 12345678);
  h ^= (h >> 16u);
  h *= 0x45d9f3bu;
  h ^= (h >> 16u);
  return h;
}

// Procedural rain splash ring-wave height contribution (Voronoi, UV-space).
// Returns 0 when rain is disabled (amplitude = 0 or no precipitation).
// Parameters packed in planetData.waterRainSplashParams as 8×float16:
//   .xy → cellSize, amplitude, ringFreq, envSharp
//   .zw → crownSharp, crownAmp, lifetime, waveSpeed
float getWaterRainSplashHeight(vec2 uv, float time){
#ifdef PLANET_DATA_GLSL
  const float oneOver65535 = 1.0 / 65535.0;

  // Early-out: skip all work if splash is disabled (amplitude = 0).
  vec2 cellAmp = unpackHalf2x16(planetData.waterRainSplashParams.x); // cellSize, amplitude
  float cellSize = cellAmp.x;
  float amplitude = cellAmp.y;
  if(abs(amplitude) <= 1e-6){
    return 0.0;
  }

  // Per-pixel weather wetness from precipitation × atmosphere maps (already 0..1).
  float precipitation = clamp(texture(uPlanetTextures[PLANET_TEXTURE_PRECIPITATIONMAP], uv).x, 0.0, 1.0);
  float atmosphere    = clamp(texture(uPlanetTextures[PLANET_TEXTURE_ATMOSPHEREMAP],    uv).x, 0.0, 1.0);
  float wetness = precipitation * atmosphere;
  if(wetness <= 0.0){
    return 0.0;
  }
  // Global spawn-density multiplier (0..1) from the rain splash JSON setting.
  float spawnGate = wetness * pushConstants.splashDensity;

  // Unpack remaining tuning parameters.
  vec2 freqSharp  = unpackHalf2x16(planetData.waterRainSplashParams.y); // ringFreq, envSharp
  vec2 crownParam = unpackHalf2x16(planetData.waterRainSplashParams.z); // crownSharp, crownAmp
  vec2 timeParam  = unpackHalf2x16(planetData.waterRainSplashParams.w); // lifetime, waveSpeed
  float ringFreq   = freqSharp.x;
  float envSharp   = freqSharp.y;
  float crownSharp = crownParam.x;
  float crownAmp   = crownParam.y;
  float lifetime   = max(timeParam.x, 1e-3);
  float waveSpeed  = timeParam.y;

  // Decompose UV into Voronoi cell coordinates.
  vec2 cellUV   = uv / cellSize;
  vec2 cellBase = floor(cellUV);
  vec2 cellFrac = fract(cellUV);

  float h = 0.0;

  // Accumulate contributions from the 3×3 neighbourhood of cells.
  for(int dy = -1; dy <= 1; dy++){
    for(int dx = -1; dx <= 1; dx++){

      // Hash 1: drop position within cell (jitter, 0..1 range).
      uint h1 = rainDropCellHash(int(cellBase.x) + dx, int(cellBase.y) + dy);
      vec2 dropPos = vec2(float(h1 & 0xffffu), float((h1 >> 16u) & 0xffffu)) * oneOver65535;

      // Hash 2: phase offset so drops don't all spawn simultaneously.
      uint h2 = h1 ^ 0xdeadbeafu;
      h2 ^= (h2 >> 13u); 
      h2 *= 0xb5297a4du; 
      h2 ^= (h2 >> 13u);
      float birthPhase = float(h2 & 0xffffu) * oneOver65535; // 0..1

      // Hash 3: spawn gate — skip this cell if its density roll exceeds the rain level.
      uint h3 = h2 ^ 0xc0ffee00u;
      h3 ^= (h3 >> 15u); 
      h3 *= 0x1b873593u; 
      h3 ^= (h3 >> 15u);
      if((float(h3 & 0xffffu) * oneOver65535) > spawnGate){
        continue;
      }

      // Age in [0, 1] cycling every lifetime seconds.
      float t0  = birthPhase * lifetime;
      float age  = fract((time - t0) / lifetime);
      float front = age * waveSpeed; // wavefront radius in UV-space

      // Distance from current pixel to drop centre.
      vec2 delta = (cellFrac - vec2(float(dx), float(dy))) - dropPos;
      float r    = length(delta);
      float dist = r - front; // signed: negative inside ring, positive outside

      // Concentric ring wave: sinusoid × Gaussian envelope × fade-in/out.
      float env  = exp(-(dist * envSharp) * (dist * envSharp));
      float fade = (1.0 - age) * smoothstep(0.0, 0.1, age);
      h += sin(dist * ringFreq) * env * fade;

      // Initial crown plume: radial Gaussian that decays in the first ~8 % of lifetime.
      h += exp(-r * crownSharp) * crownAmp * (1.0 - smoothstep(0.0, 0.08, age));
    }
  }

  return h * amplitude * wetness * pushConstants.rainIntensity;
#else
  return 0.0;
#endif
}

float getWaterRainSplashHeight(vec3 n, float time){
#ifdef PLANET_DATA_GLSL
  vec2 uv = octPlanetUnsignedEncode(n) + (vec2(0.5) / vec2(textureSize(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], 0).xy));
  return getWaterRainSplashHeight(uv, time);
#else
  return 0.0; 
#endif
}

// Finite-difference slope of the rain splash height field in UV space.
// Returns vec2(dH/dU, dH/dV) using a fine step (cellSize/16) to capture the
// high-frequency ring-wave detail that the coarse 1/4096 normal stencil misses.
vec2 getWaterRainSplashSlope(vec2 uv, float time){
#ifdef PLANET_DATA_GLSL
  vec2 cellAmp = unpackHalf2x16(planetData.waterRainSplashParams.x);
  if(abs(cellAmp.y) <= 1e-6){
    return vec2(0.0);
  }
  float eps = max(cellAmp.x * (1.0 / 16.0), 1e-5);
  float hu0 = getWaterRainSplashHeight(wrapOctahedralCoordinates(uv - vec2(eps, 0.0)), time);
  float hu1 = getWaterRainSplashHeight(wrapOctahedralCoordinates(uv + vec2(eps, 0.0)), time);
  float hv0 = getWaterRainSplashHeight(wrapOctahedralCoordinates(uv - vec2(0.0, eps)), time);
  float hv1 = getWaterRainSplashHeight(wrapOctahedralCoordinates(uv + vec2(0.0, eps)), time);
  return vec2(hu1 - hu0, hv1 - hv0) * (0.5 / eps);
#else
  return vec2(0.0);
#endif
}

float getWaterHeightData(vec2 uv){
  float h = textureBicubicPlanetOctahedralMap(uPlanetTextures[PLANET_TEXTURE_WATERMAP], uv).x; // But for the water map, we use bicubic interpolation to get a smoother water surface
#ifdef PLANET_DATA_GLSL
  vec2 splashDepthThresh = unpackHalf2x16(planetData.waterRainSplashParams2.y); // depthThresholdLow, depthThresholdHigh
  float splashFade = smoothstep(splashDepthThresh.x, max(splashDepthThresh.y, splashDepthThresh.x + 1e-6), h);
#else
  float splashFade = smoothstep(1e-4, 1e-3, h); // Fallback: fade out ripple/splash contribution on shallow water based on fixed depth thresholds when planet data is not available (e.g. in prepass shaders that don't bind the planet data SSBO)
#endif
  return h + ((splashFade > 1e-5) ? ((getWaterRippleHeight(uv) + (getWaterRainSplashHeight(uv, pushConstants.time) * splashFade))) : 0.0); // Additive GPU ripple + rain splash contribution, faded out on shallow water via JSON depth thresholds
}

float getWaterHeightData(vec3 n){
  return getWaterHeightData(octPlanetUnsignedEncode(n) + (vec2(0.5) / vec2(textureSize(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], 0).xy)));    
}

vec2 getSphereHeightData(vec2 uv){
  return vec2(
    mix( 
      planetBottomRadius,
      planetTopRadius,
      texturePlanetOctahedralMap(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], uv).x  // Linear interpolation of the heightmap for to match the vertex-based rendering
    ),         
    getWaterHeightData(uv) // But for the water map, we use bicubic interpolation to get a smoother water surface, and it already adds the ripple contribution
  );
}

vec2 getSphereHeightData(vec3 n){
  vec2 uv = octPlanetUnsignedEncode(n) + (vec2(0.5) / vec2(textureSize(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], 0).xy));
  return vec2(
    mix( 
      planetBottomRadius,
      planetTopRadius,
      texturePlanetOctahedralMap(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], uv).x  // Linear interpolation of the heightmap for to match the vertex-based rendering
    ),         
    getWaterHeightData(uv)
  );
}

float getSphereHeight(vec3 n, int i){
  return mix( 
           planetBottomRadius,
           planetTopRadius,
           texturePlanetOctahedralMap(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], n).x  // Linear interpolation of the heightmap for to match the vertex-based rendering
         ) +
         getWaterHeightData(n);
}

float getSphereHeight(vec2 uv){
  return mix( 
           planetBottomRadius,
           planetTopRadius,
           texturePlanetOctahedralMap(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], uv).x  // Linear interpolation of the heightmap for to match the vertex-based rendering
         ) +
         getWaterHeightData(uv);
}

float getSphereHeight(vec3 n){
  return getSphereHeight(n, 12);
}

float getSphereHeightEx(vec2 uv){
  float h = getWaterHeightData(uv); // Bicubic water height + additive GPU ripple contribution
  return (h > 1e-7) 
          ? (mix( 
              planetBottomRadius,
              planetTopRadius,
              texturePlanetOctahedralMap(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], uv).x  // Linear interpolation of the heightmap for to match the vertex-based rendering
             ) +
             h)
          : -1.0; 
}

float mapHeight(vec3 p, float h){
  return length(planetCenter - p) - clamp(h, max(0.0, planetBottomRadius - 0.01), planetTopRadius);
}

float mapEx(vec3 p, int i){
  return length(planetCenter - p) - clamp(getSphereHeight(normalize(p - planetCenter), i), max(0.0, planetBottomRadius - 0.01), planetTopRadius);
}

float map(vec3 p){
  return mapEx(p, 12);
}

vec3 mapNormal(vec3 p){
  vec2 e = vec2(1e-2, 0.0); // 0.01 meters for now for the epsilon for the normal calculation
  const int i = 37;
  return normalize(
    vec3(
      mapEx(p + e.xyy, i) - mapEx(p - e.xyy, i),
      mapEx(p + e.yxy, i) - mapEx(p - e.yxy, i),
      mapEx(p + e.yyx, i) - mapEx(p - e.yyx, i)
    )  
  );
}

const int MAX_MARCHING_STEPS = 256;

const float PRECISION = 1e-2;

float INFINITY = uintBitsToFloat(0x7f800000u); 

int countSteps = 0;

// Accelerated ray marching based on https://www.researchgate.net/publication/329152815_Accelerating_Sphere_Tracing
bool acceleratedRayMarching(vec3 rayOrigin, vec3 rayDirection, float startTime, float maxTime, float w, float q, out float hitTime){
  float previousR = 0.0; 
  float currentR = 0.0;
  float nextR = INFINITY;
  float stepDistance = 0.0;
  float time = startTime;
#if 0
  vec2 closest = vec2(INFINITY, 0.0);    
#endif
  float raySign = (map(rayOrigin) < 0.0) ? -1.0 : 1.0;  
  for(int i = 0; (i < MAX_MARCHING_STEPS) && (nextR >= PRECISION) && (time < maxTime); i++){
    float currentSignedDistance = map(fma(rayDirection, vec3(time + stepDistance), rayOrigin)) * raySign;
#if 0
    if(closest.x > abs(currentSignedDistance)){
      closest = vec2(abs(currentSignedDistance), time);
    }
#endif
    nextR = currentSignedDistance;
    if(stepDistance > (currentR + nextR)){
      stepDistance = currentR;
      currentSignedDistance = map(fma(rayDirection, vec3(time + stepDistance), rayOrigin)) * raySign;
      nextR = currentSignedDistance;
    }
    time += stepDistance;
    previousR = currentR;
    currentR = nextR * q;
    stepDistance = currentR + ((w * currentR) * (((stepDistance - previousR) + currentR) / ((stepDistance + previousR) - currentR)));
    countSteps++;
  }    
  bool hit = false;
  if((time <= maxTime) && (nextR < PRECISION)){
    hit = true;
    hitTime = min(time, maxTime);    
#if 0
  }else if((closest.x < 1e-2) && (closest.y <= maxTime)){
    hit = true;
    hitTime = closest.y;
#endif
  }
  return hit;
}

bool standardRayMarching(vec3 rayOrigin, vec3 rayDirection, float startTime, float maxTime, out float hitTime){

  bool hit = false;
  
  float t = startTime;

  float timeStep = max(1.0, maxTime) / (float(MAX_MARCHING_STEPS) * 0.125); 
  
  float closest = INFINITY;
  float closestT = 0.0;

  float secondClosest = INFINITY;
  float secondClosestT = 0.0;
  float previousDT = 0.0;

  float raySign = (map(rayOrigin) < 0.0) ? -1.0 : 1.0;  

  for(int i = 0; (i < MAX_MARCHING_STEPS) && (t < maxTime); i++){

    vec3 rayPosition = fma(rayDirection, vec3(t), rayOrigin);

    float dt = map(rayPosition) * raySign;
    if(dt < closest){
      closest = dt;
      closestT = t;
    }
    
    if((secondClosest > dt) && (previousDT < dt)){
        secondClosest = dt;
        secondClosestT = t;
    }      

    if(dt < PRECISION){
      hit = true;
      hitTime = t;
      break;
    }    

    t += (clamp(abs(dt) * 0.1, 1e-6, timeStep) * ((dt < 0.0) ? -1.0 : 1.0));
    
    previousDT = dt;

    countSteps++;
    
  }       
  
#if 0
  if((!hit) && (closest < 1e-2)){
    hit = true;
    hitTime = closestT;
  }
#endif

  return hit;

} 

vec3 getRaySphereIntersections(vec4 sphere, vec3 rayOrigin, vec3 rayDirection){
#if 1 
  vec3 sphereCenterToRayOrigin = rayOrigin - sphere.xyz;
  vec2 t;
  bool result = solveQuadraticRoots(dot(rayDirection, rayDirection), 
                                    dot(rayDirection, sphereCenterToRayOrigin) * 2.0, 
                                    dot(sphereCenterToRayOrigin, sphereCenterToRayOrigin) - (sphere.w * sphere.w), 
                                    t);
  return result ? vec3(t, 10) : vec3(0.0);
#else
  vec3 p = rayOrigin - sphere.xyz;
  float b = 2.0 * dot(p, rayDirection);
  float discriminant = (b * b) - (4.0 * (dot(p, p) - (sphere.w * sphere.w)));
  return (discriminant >= 0.0) : vec3((vec2(-b) + (vec2(sqrt(discriminant)) * vec2(-1.0, 1.0))) * 0.5, 1.0) : vec3(0.0);
#endif
}

bool planetRayMarching(vec3 rayOrigin, vec3 rayDirection, float maxTime, out float hitTime){

  vec3 outer = getRaySphereIntersections(vec4(planetCenter, planetTopRadius), rayOrigin, rayDirection);

  if((outer.z > 0.0) && (outer.y >= 0.0)){

    vec3 inner = getRaySphereIntersections(vec4(planetCenter, planetBottomRadius), rayOrigin, rayDirection);

    float start = max(0.0, outer.x);
    float end = outer.y;

    if (inner.z > 0.0){
      if((inner.x < 0.0) && (inner.y > 0.0)){
        return false;
      } else if(inner.x > 0.0){
        end = inner.x;
      }
    }

    vec3 startPoint = rayOrigin + (rayDirection * start) - planetCenter;
    vec3 offset = rayDirection * (end - start);

    const int maxSteps = 1024;

    const float rayMarchStride = 1e-3;

    float stride = rayMarchStride * (planetTopRadius * 2.0) / (end - start);

    for(int t = 0; t < maxSteps; t++){
    
      if((float(t) * stride) > 1.0){
        break;
      }

      vec3 point = startPoint + (offset * float(t) * stride);

      float radius = length(point);
      vec3 unit = point / radius;
            
      float rayHeight = (radius - planetBottomRadius) / (planetTopRadius - planetBottomRadius);

      float height = clamp((getSphereHeight(unit) - planetBottomRadius) / (planetTopRadius - planetBottomRadius), 0.0, 1.0);

      if(height >= rayHeight){
 
        if(float(t) < 0.5){          
          return (hitTime = start) < maxTime;
        }

        float lower = float(t - 1) * stride;
        float upper = float(t) * stride;
        float midpoint = (lower + upper) * 0.5;

        for(int i = 0; i < 8; i++){

          point = startPoint + (offset * midpoint);
          unit = point / (radius = length(point));
          rayHeight = (radius - planetBottomRadius) / (planetTopRadius - planetBottomRadius);
          height = clamp((getSphereHeight(unit) - planetBottomRadius) / (planetTopRadius - planetBottomRadius), 0.0, 1.0); 

          if(height >= rayHeight){
            upper = midpoint;
          } else {
            lower = midpoint;
          }

          midpoint = (lower + upper) * 0.5;

        }

        return (hitTime = (start + (midpoint * (end - start)))) <= maxTime;

      }

    }

   if((inner.z > 0.0) && (inner.y >= 0.0)){
      return (hitTime = end) <= maxTime;
    }

  }

  return false;

}

// Compute Gerstner-style swell displacement height using global wind direction in sphere space.
// Spatial variation comes from dot(windDir, spherePos); scale in rad is freq * sphereRadius.
// windDir: planet-local swell direction (need not be pre-normalised);
// freq: wave number in rad/m; speed: animation speed (rad/s); steepness: wave-shape factor.
// Returns unnormalized height sum; caller multiplies by waveAmplitude.
float computeGerstnerDisplacement(vec3 spherePos, vec3 windDir, float freq, float speed, float steepness, float time){
  float wdLen = length(windDir);
  if(wdLen < 1e-3){ return 0.0; }
  vec3 wd = windDir / wdLen;
  vec3 sn = normalize(spherePos);
  vec3 wdBraw = cross(sn, wd);
  float wdBLen = length(wdBraw);
  if(wdBLen < 1e-3){ return 0.0; } // windDir collinear with sphere normal — no tangential variation
  vec3 wdB = wdBraw / wdBLen;
  float t = time * speed;
  float h  = sin(freq       * dot(wd,                               spherePos) - t);
  h +=       sin(freq * 0.7 * dot((0.866025 * wd) + (0.5     * wdB), spherePos) - t * 1.1) * 0.5;
  h +=       sin(freq * 1.3 * dot((0.707107 * wd) - (0.707107 * wdB), spherePos) - t * 0.8) * 0.35;
  h +=       sin(freq * 2.1 * dot((0.5      * wd) + (0.866025 * wdB), spherePos) - t * 1.3) * 0.2;
  return h * steepness;
}

// Compute UV-wave displacement height at a given oct-UV coordinate.
// Uses the same 4 wave trains as accumulateUVWaveNormal for normal/displacement consistency.
// Returns unnormalized height sum; caller multiplies by displacement amplitude.
// freq: uvWaveFrequency, speed: uvWaveSpeed, scale: uvWaveScale
float computeWaveDisplacement(vec2 uv, float time, float freq, float speed, float scale){
  vec2 scaledUV = wrapOctahedralCoordinates(uv * scale);
  float t = time * speed;
  float h  = sin(freq        * dot(vec2(1.0, 0.0),            scaledUV) - t);
  h +=       sin(freq * 0.73 * dot(vec2(0.0, 1.0),            scaledUV) - t * 1.1) * 0.6;
  h +=       sin(freq * 1.4  * dot(vec2(0.707107,  0.707107), scaledUV) - t * 0.8) * 0.35;
  h +=       sin(freq * 2.1  * dot(vec2(0.707107, -0.707107), scaledUV) - t * 1.3) * 0.2;
  return h;
}

#endif // PLANET_WATER_GLSL