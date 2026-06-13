#ifndef PLANET_BRUSHES_GLSL
#define PLANET_BRUSHES_GLSL

// Common brush sampling functions for planet terrain modification shaders
// Note: Requires uBrushTextureArray to be declared in the parent shader as:
// layout(set = 0, binding = 1) uniform sampler2DArray uBrushTextureArray[];
// This is an array-of-arrays: an unbounded array of sampler2DArray textures,
// where each array element contains multiple texture layers for different brush indices.

// Sample a brush at the given position with rotation
// Parameters:
//   p: Current surface position (normalized)
//   n: Brush center normal (normalized)
//   radius: Brush radius
//   innerRadius: Inner radius for smooth falloff (negative value) / smooth level (0.0 .. 1.0)
//   brushIndex: Brush texture index (0 = circle, 1-255 = texture, 256+ = none)
//   brushRotation: Rotation angle in radians
// Returns: Brush intensity value [0.0, 1.0]
float sampleBrush(vec3 p, vec3 n, float radius, float innerRadius, uint brushIndex, float brushRotation){

  float d;

  if(brushIndex == 0u){

    // Just a circle brush
   
    d = smoothstep(
      0.0,
      -innerRadius,
      length(p - n) - radius
    );

  }else if(brushIndex <= 255u){

    // Brush texture

    vec3 t = n.yzx - n.zxy, 
         b = normalize(cross(n, t = normalize(t - dot(t, n)))),
         o = p - n;
    if(brushRotation != 0.0){
      const vec2 rotationSinCos = sin(vec2(brushRotation) + vec2(0.0, 1.57079632679));
      const vec3 ot = t, ob = b;
      t = (ot * rotationSinCos.y) - (ob * rotationSinCos.x);
      b = (ot * rotationSinCos.x) + (ob * rotationSinCos.y);
    }
    vec2 uv = vec2(dot(o, t), dot(o, b)) / radius;
    d = smoothstep(1.0, 1.0 - (1.0 / length(textureSize(uBrushTextureArray[0], 0).xy)), max(abs(uv.x), abs(uv.y)));

    d *= smoothstep(-1e-4, 1e-4, dot(p, n)); // When we are on the back side of the planet, we need to clear the brush, but smoothly.

    if(d > 0.0){
      // Smooth level interpolation between the 16 brush textures
      float smoothLevel = clamp(innerRadius * 15.0, 0.0, 15.0); // Scale from [0.0, 1.0] to [0.0, 15.0]
      float smoothLevelFract = fract(smoothLevel);
      uint smoothLevelInt = uint(smoothLevel);
      uint smoothLevelIntNext = min(smoothLevelInt + 1u, 15u);
      
      vec2 uvCoords = fma(uv, vec2(0.5), vec2(0.5));
      
      // Sample both levels
      float value0 = textureLod(uBrushTextureArray[smoothLevelInt], vec3(uvCoords, float(brushIndex)), 0.0).x;
      float value1 = textureLod(uBrushTextureArray[smoothLevelIntNext], vec3(uvCoords, float(brushIndex)), 0.0).x;
      
      // Interpolate between levels
      d *= mix(value0, value1, smoothLevelFract);
    } 

  }else{

    // No brush

    d = 0.0;

  }

  return d;
}

#endif // PLANET_BRUSHES_GLSL
