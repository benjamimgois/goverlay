#ifndef MESHLET_GLSL
#define MESHLET_GLSL

#define MESHLET_DEBUG_COLOR_VARIANT_NONE 0
#define MESHLET_DEBUG_COLOR_VARIANT_FORMULA_1 1
#define MESHLET_DEBUG_COLOR_VARIANT_FORMULA_2 2
#define MESHLET_DEBUG_COLOR_VARIANT_FORMULA_3 3
#define MESHLET_DEBUG_COLOR_VARIANT_FORMULA_4 4
#define MESHLET_DEBUG_COLOR_VARIANT_FORMULA_5 5
#define MESHLET_DEBUG_COLOR_VARIANT_FORMULA_6 6
#define MESHLET_DEBUG_COLOR_VARIANT_FORMULA_7 7
#define MESHLET_DEBUG_COLOR_VARIANT_PREDEFINED 8

#define MESHLET_DEBUG_COLOR_VARIANT MESHLET_DEBUG_COLOR_VARIANT_FORMULA_7

#if MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_PREDEFINED
#if 0
const vec3 MeshletDebugColors[16] = vec3[16](
    vec3(0.90, 0.20, 0.20), // red
    vec3(0.20, 0.90, 0.20), // green
    vec3(0.20, 0.45, 0.95), // blue
    vec3(0.95, 0.85, 0.20), // yellow
    vec3(0.95, 0.20, 0.95), // magenta
    vec3(0.20, 0.90, 0.90), // cyan
    vec3(0.95, 0.55, 0.20), // orange
    vec3(0.55, 0.95, 0.20), // lime
    vec3(0.55, 0.20, 0.95), // violet
    vec3(0.95, 0.20, 0.55), // pink
    vec3(0.20, 0.55, 0.95), // sky
    vec3(0.20, 0.95, 0.55), // mint
    vec3(0.95, 0.70, 0.35), // amber
    vec3(0.35, 0.95, 0.70), // aqua-green
    vec3(0.70, 0.35, 0.95), // purple
    vec3(0.95, 0.35, 0.70)  // rose
);
#else
const vec3 MeshletDebugColors[16] = vec3[16](
    vec3(1.00, 0.00, 0.00), // red
    vec3(0.00, 1.00, 0.00), // green
    vec3(0.00, 0.00, 1.00), // blue
    vec3(1.00, 1.00, 0.00), // yellow
    vec3(1.00, 0.00, 1.00), // magenta
    vec3(0.00, 1.00, 1.00), // cyan
    vec3(1.00, 0.50, 0.25), // orange
    vec3(0.50, 1.00, 0.25), // lime
    vec3(0.50, 0.25, 1.00), // violet
    vec3(1.00, 0.25, 0.50), // pink
    vec3(0.25, 0.50, 1.00), // sky
    vec3(0.25, 1.00, 0.50), // mint
    vec3(1.00, 0.75, 0.25), // amber
    vec3(0.25, 1.00, 0.75), // aqua-green
    vec3(0.75, 0.25, 1.00), // purple
    vec3(1.00, 0.25, 0.75)  // rose
);
#endif
#endif

vec3 meshletDebugColor(uint id){
#if MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_PREDEFINED
  // Simple predefined palette based on the low 4 bits of the ID, giving 16 distinct colors. This is useful for visually 
  // distinguishing meshlets, but can result in adjacent meshlets having similar colors if their IDs are close together. 
  // The formulas below can provide more varied colors at the cost of some predictability and potential clustering of 
  // similar colors. 
  return MeshletDebugColors[id & 0xfu];
#else
  const vec3 oneDiv255 = vec3(1.0 / 255.0);
#if MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_FORMULA_1
  // Simple hash-based approach with quantization to get a limited palette of distinct colors. Not based on any particular known
  // hash function, just some bit manipulations and prime multiplications to mix the bits of the ID.
  const uvec3 primeMultipliers = uvec3(2654435761u, 2246822519u, 3266489917u);
  const uvec3 values = id * primeMultipliers;
  const uvec3 masked = (values >> uvec3(24u)) & uvec3(0xffu);
  const uvec3 quantized = (masked & uvec3(0x30u)) >> uvec3(4u); // Quantize to 4 levels per channel (0, 48, 96, 144 - 2 bits)
  vec3 color = vec3(quantized) * 0.25; // Scale to [0,1] range
#elif MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_FORMULA_2
  // Another simple hash-based approach with different bit manipulations and prime multiplications to get a different palette of colors.
  vec3 color = vec3(uvec3((uvec3((id * 747796405u) + 2891336453u) >> uvec3(0u, 8u, 16u)) & uvec3(0xffu))) * oneDiv255;
#elif MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_FORMULA_3
  // A more complex hash-based approach that uses a small integer hash function with good bit mixing properties to generate more varied colors.  
  vec3 color = vec3(uvec3((uvec3(id) * uvec3(16807u, 48271u, 40692u)) & uvec3(0xffu))) * oneDiv255;
#elif MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_FORMULA_4
  // A different hash-based approach
  id = (id ^ (id >> 16u)) * 0x7feb352du;
  id = (id ^ (id >> 15u)) * 0x846ca68bu;
  vec3 color = vec3(uvec3((uvec3(id ^ (id >> 16u)) >> uvec3(0u, 8u, 16u)) & uvec3(255u))) * oneDiv255;
#elif MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_FORMULA_5
  // A more computationally expensive hash-based approach that uses a small integer hash function with good bit mixing properties 
  //followed by a post-mixing step to generate more varied colors with less correlation between similar IDs.
  uvec4 v = uvec4(id) * uvec4(0x9e3779b9u, 0x7f4a7c15u, 0xf39cc060u, 0x106689d3u);
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 16u) | (v.w >> 16u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 12u) | (v.y >> 20u); 
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 8u) | (v.w >> 24u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 7u) | (v.y >> 25u); 
  v -= (v << 6u);
  v ^= (v >> 17u);
  v -= (v << 9u);
  v ^= (v << 4u);
  v -= (v << 3u);
  v ^= (v << 10u);
  v ^= (v >> 15u);  
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 16u) | (v.w >> 16u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 12u) | (v.y >> 20u); 
  v.x += v.y; v.w ^= v.x; v.w = (v.w << 8u) | (v.w >> 24u);
  v.z += v.w; v.y ^= v.z; v.y = (v.y << 7u) | (v.y >> 25u); 
  vec3 color = vec3(uintBitsToFloat(uvec3((v.xyz >> 9u) & uvec3(0x007fffffu)) | uvec3(0x3f800000u))) - vec3(1.0);
#elif MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_FORMULA_6
  // Another more computationally expensive hash-based approach that uses a different small integer hash function with good
  // bit mixing properties
  id -= (id << 6u);
  id ^= (id >> 17u);
  id -= (id << 9u);
  id ^= (id << 4u);
  id -= (id << 3u);
  id ^= (id << 10u);
  id ^= (id >> 15u);
  vec3 color = vec3(uvec3((uvec3(id) >> uvec3(0u, 8u, 16u)) & uvec3(255u))) * oneDiv255;
#elif MESHLET_DEBUG_COLOR_VARIANT == MESHLET_DEBUG_COLOR_VARIANT_FORMULA_7
  // Yet another hash-based approach 
  id = (id ^ (id >> 17u)) * 0xed5ad4bbu;
  id = (id ^ (id >> 11u)) * 0xac4c1b51u;
  id = (id ^ (id >> 15u)) * 0x31848babu;
  vec3 color = vec3(uvec3((uvec3(id ^ (id >> 14u)) >> uvec3(0u, 8u, 16u)) & uvec3(255u))) * oneDiv255;
#else
  // Fallback to a default color if no valid variant is selected
  vec3 color = vec3(1.0); // white for none or unknown variants
#endif
  
  // Clamp to [0,1] range just in case, to avoid issues with invalid colors in debug visualization
  color = clamp(color, vec3(0.0), vec3(1.0));

  // Optionally scale and bias to avoid very dark colors that are hard to see on dark backgrounds
  if(dot(color, vec3(0.2126, 0.7152, 0.0722)) < 0.125){
    color = mix(vec3(0.125), vec3(1.0), color); // Scale and bias to avoid very dark colors
  }

  // Final output 
  return color;

#endif  
}

#endif