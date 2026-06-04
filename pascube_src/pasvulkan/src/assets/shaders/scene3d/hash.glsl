#ifndef HASH_GLSL
#define HASH_GLSL

uvec4 hash44ChaCha20(uvec4 p){
  
  uvec4 v = uvec4(p);
    
#if 1
  // Pre-inter-mixing of all components with all components with a single ChaCha20 cipher round primitive iteration
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 16u) | (v.w >> 16u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 12u) | (v.y >> 20u); 
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 8u) | (v.w >> 24u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 7u) | (v.y >> 25u); 
#endif
    
#if 1
  // Full avalanche integer (re-)hashing with as far as possible equal bit distribution probability
  // => http://burtleburtle.net/bob/hash/integer.html  
  v -= (v << 6u);
  v ^= (v >> 17u);
  v -= (v << 9u);
  v ^= (v << 4u);
  v -= (v << 3u);
  v ^= (v << 10u);
  v ^= (v >> 15u);
#endif
    
#if 1
  // Post-inter-mixing of all components with all components with a single ChaCha20 cipher round primitive iteration
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 16u) | (v.w >> 16u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 12u) | (v.y >> 20u); 
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 8u) | (v.w >> 24u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 7u) | (v.y >> 25u); 
#endif
    
  return v;
    
}      

vec4 hash44ChaCha20(vec4 p){
  
  uvec4 v = uvec4(floatBitsToInt(p));
    
#if 1
  // Pre-inter-mixing of all components with all components with a single ChaCha20 cipher round primitive iteration
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 16u) | (v.w >> 16u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 12u) | (v.y >> 20u); 
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 8u) | (v.w >> 24u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 7u) | (v.y >> 25u); 
#endif
    
#if 1
  // Full avalanche integer (re-)hashing with as far as possible equal bit distribution probability
  // => http://burtleburtle.net/bob/hash/integer.html  
  v -= (v << 6u);
  v ^= (v >> 17u);
  v -= (v << 9u);
  v ^= (v << 4u);
  v -= (v << 3u);
  v ^= (v << 10u);
  v ^= (v >> 15u);
#endif
    
#if 1
  // Post-inter-mixing of all components with all components with a single ChaCha20 cipher round primitive iteration
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 16u) | (v.w >> 16u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 12u) | (v.y >> 20u); 
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 8u) | (v.w >> 24u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 7u) | (v.y >> 25u); 
#endif
    
  return vec4(intBitsToFloat(ivec4(uvec4(((v >> 9u) & uvec4(0x007fffffu)) | uvec4(0x3f800000u))))) - vec4(1.0);
    
}      

#endif
