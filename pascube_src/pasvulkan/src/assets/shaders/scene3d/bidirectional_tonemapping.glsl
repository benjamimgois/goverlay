#ifndef BIDIRECTIONAL_TONEMAPPING_GLSL
#define BIDIRECTIONAL_TONEMAPPING_GLSL

// Bidirectional temporal tonemapping for MSAA resolving, antialiasing, upsampling, downsampling, and so on, but not for the tonemapping of the final output.

// All these tone mapping operators are more or less reversible, but some are more costly or less precise than the others of them. For MSAA resolving, antialiasing,
// upsampling, downsampling, and so on, the AMD one is the most recommended to use for the inverse tone mapping, since it's the cheapest one in terms of calculations 
// for both directions and the most universal one of them, independent of the actually used tonemapping operator for the real output at the end. The only downside of
// the AMD one is that it's not the most good looking one in comparison to the others, when it is used for the real output at the end, but this doesn't matter here, 
// since it's only used together with its inverse function as a compensation against ugly results at post processing tasks like MSAA resolving, antialiasing, 
// upsampling, downsampling, and so on. Thus the choice of a even more complex tonemapping operator for the real output at the end doesn't affect these tasks.
// For more information see: https://gpuopen.com/learn/optimized-reversible-tonemapper-for-resolve/

#define BIDIRECTIONAL_TONEMAPPING_VARIANT_NONE 0 // No tonemapping operator is used. It is the fastest one, but it's not recommended to use it, since it doesn't compensate against ugly results at post processing tasks like antialiasing, upsampling, downsampling, and so on.
#define BIDIRECTIONAL_TONEMAPPING_VARIANT_ACES 1 // https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/ - A good tonemapping operator, but it's more costly than the others for the inverse tonemapping, since it has a square root in it.
#define BIDIRECTIONAL_TONEMAPPING_VARIANT_AMD 2 // https://gpuopen.com/learn/optimized-reversible-tonemapper-for-resolve/ - The most universal for all cases, independent of the actually used tonemapping operator for the real output at the end. It's also the cheapest one in terms of calculations for the inverse tonemapping.
#define BIDIRECTIONAL_TONEMAPPING_VARIANT_BRIAN_KARIS 3 // http://graphicrants.blogspot.com/2013/12/tone-mapping.html - Also a good universal tonemapping operator, but it costs a bit more instructions than the AMD one, but it's still cheaper than the others in terms of calculations for the inverse tonemapping, since it has no square root in it.
#define BIDIRECTIONAL_TONEMAPPING_VARIANT_JIM_HEJL_RICHARD_BURGESS_DAWSON 4 // http://filmicworlds.com/blog/filmic-tonemapping-operators/ - Also a good tonemapping operator, but it costs also more than the others in terms of calculations for the inverse tonemapping, since it has a square root in it.
#define BIDIRECTIONAL_TONEMAPPING_VARIANT_UNCHARTED2 5 // http://filmicworlds.com/blog/filmic-tonemapping-operators/ - Also a good tonemapping operator, but it costs also more than the others in terms of calculations for the inverse tonemapping, since it has a square root in it. 

// AMD has black-artefacts at too bright values at MSAA resolving, so it's not used here.

#define BIDIRECTIONAL_TONEMAPPING_VARIANT BIDIRECTIONAL_TONEMAPPING_VARIANT_BRIAN_KARIS 

vec3 ApplyToneMapping(vec3 color){
#if BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_ACES
  // ACESFilmic - https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
  // x = (y * ((2.51 * y) + 0.3)) / ((y * ((2.43 * y) + 0.59)) + 0.14) 
  // optimized to: x = ((2.51 * y^2) + (0.3 * y)) / ((2.43 * y^2) + (0.59 * y) + 0.14) = (2.51y^2+0.03y)/(2.43y^2+0.59y+0.14)
  return (color * ((2.51 * color) + vec3(0.03))) / ((color * ((2.43 * color) + vec3(0.59))) + vec3(0.14));
#elif BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_AMD
  // https://gpuopen.com/learn/optimized-reversible-tonemapper-for-resolve/ 
  return color / (max(max(color.x, color.y), color.z) + 1.0);
#elif BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_BRIAN_KARIS
  // http://graphicrants.blogspot.com/2013/12/tone-mapping.html
  return color / (abs(dot(color, vec3(0.2125, 0.7154, 0.0721))) + 1.0); // abs is used to avoid negative values, since the dot product can be negative for scRGB values (extended sRGB for HDR).
  //return color / (dot(color, vec3(0.2125, 0.7154, 0.0721)) + 1.0); // This is the original version, but it can produce wrong very bright white-point-artefacts results at negative values, since the dot product can be negative for scRGB values (extended sRGB for HDR).
#elif BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_JIM_HEJL_RICHARD_BURGESS_DAWSON
  // Jim Hejl and Richard Burgess-Dawson - http://filmicworlds.com/blog/filmic-tonemapping-operators/
  // (y * (6.2 * y + 0.5)) / (y * (6.2 * y + 1.7) + 0.06)
  color = max(vec3(0.0), color - vec3(0.004));
  return (color * (6.2 * color + vec3(0.5))) / (color * (6.2 * color + vec3(1.7)) + vec3(0.06));  
#elif BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_UNCHARTED2
  // John Hable - http://filmicworlds.com/blog/filmic-tonemapping-operators/
  float A = 0.15;
  float B = 0.50;
  float C = 0.10;
  float D = 0.20;
  float E = 0.02;
  float F = 0.30;
  float W = 11.2;
  // return ((color * ((A * color) + vec3(C * B)) + vec3(D * E)) / (color * ((A * color) + vec3(B)) + vec3(D * F))) - vec3(E / F);
  // Inversed because for more floating point precision for the inverse tonemapping, see the link at the inverse tonemapping function for more information.
  return vec3(1.0) - (((color * ((A * color) + vec3(C * B)) + vec3(D * E)) / (color * ((A * color) + vec3(B)) + vec3(D * F))) - vec3(E / F));
#else // BIDIRECTIONAL_TONEMAPPING_VARIANT_NONE
  return color; // No tonemapping operator is used. 
#endif
}

vec3 ApplyInverseToneMapping(vec3 color){
#if BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_ACES
  // ACESFilmic - https://www.wolframalpha.com/input?i=2.51y%5E2%2B.03y%3Dx%282.43y%5E2%2B.59y%2B.14%29+solve+for+y}
  // return (sqrt((-10127.0 * color * color) + (13702.0 * color) + vec3(9.0)) + (59.0 * color) - vec3(3.0)) / (cec3(502.0) - vec3(486.0 * color)); 
  // https://www.wolframalpha.com/input?i=%28y*%28%282.51*y%29%2B0.03%29%29%2F%28%28y*%28%282.43*y%29%2B0.59%29%29%2B0.14%29%3Dx+solve+for+y
  // return ((sqrt((-10127.0 * color * color) + (13702.0 * color) + vec3(9.0)) - (59.0 * color)) + vec3(3.0)) / (vec3(486.0 * color) - 502.0);
  // ((sqrt((-10127.0 * y^2) + (13702.0 * y) + 9.0) - (59.0 * y)) + 3.0) / ((486.0 * y) - 502.0)
  // return ((sqrt((-1.0127 * color * color) + (1.3702 * color) + vec3(0.0009)) - (0.0059 * color)) + vec3(0.0003)) / (vec3(0.0486 * color) - 0.0502);
  // ((sqrt((-1.0127 * y^2) + (1.3702 * y) + 0.0009) - (0.0059 * y)) + 0.0003) / ((0.0486 * y) - 0.0502)
  // return ((-sqrt((-10127.0 * color * color) + (13702.0 * color) + vec3(9.0)) - (59.0 * color)) + vec3(3.0)) / (vec3(486.0 * color) - 502.0);
  // return (((-0.59 * color) + vec3(0.03)) - sqrt((-1.0127 * (color * color)) + (1.3702 * color) + vec3(0.0009))) / (vec3(4.86 * color) - 5.02);  
  // return (((-59.0 * color) + vec3(3.0)) - sqrt((-10127.0 * color * color) + (13702.0 * color) + vec3(9.0))) / (vec3(486.0 * color) - vec3(502.0));
/*
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return (((-d * color) + vec3(b)) - sqrt(((-1.0127 * (color * color) + (1.3702 * color)) + vec3(0.0009))) / (2.0 * ((c * color) - vec3(a)));
*/  
  return (((-0.59 * color) + vec3(0.03)) - sqrt((-1.0127 * (color * color)) + (1.3702 * color) + vec3(0.0009))) / (vec3(4.86 * color) - 5.02);  
#elif BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_AMD
  // https://gpuopen.com/learn/optimized-reversible-tonemapper-for-resolve/ 
  return color / max(1.0 - max(max(color.x, color.y), color.z), 1e-5);
#elif BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_BRIAN_KARIS
  // http://graphicrants.blogspot.com/2013/12/tone-mapping.html
  return color / max(1.0 - abs(dot(color, vec3(0.2125, 0.7154, 0.0721))), 1e-5); // Even here, abs is used to avoid negative values, since the dot product can be negative for scRGB values (extended sRGB for HDR). 
  //return color / max(1.0 - dot(color, vec3(0.2125, 0.7154, 0.0721)), 1e-5);  // This is the original version, but it can produce wrong very bright white-point-artefacts results at negative values, since the dot product can be negative for scRGB values (extended sRGB for HDR).
#elif BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_JIM_HEJL_RICHARD_BURGESS_DAWSON
  // Jim Hejl and Richard Burgess-Dawson - https://www.wolframalpha.com/input?i=%28y+*+%286.2+*+y+%2B+0.5%29%29+%2F+%28y+*+%286.2+*+y+%2B+1.7%29+%2B+0.06%29+%3D+x+solve+for+y
  // y = (-0.137097 sqrt(701 x^2 - 106 x + 125) - 2.5282 x + 1.53279)/(sqrt(701 x^2 - 106 x + 125) - 26.8328) 
  // x = (-0.137097 sqrt(701 y^2 - 106 y + 125) - 2.5282 y + 1.53279)/(sqrt(701 y^2 - 106 y + 125) - 26.8328) and sqrt(701 y^2 - 106 y + 125)!=26.8328 and y!=1
  // x = (-0.137097 sqrt(701 y^2 - 106 y + 125) + 2.5282 y - 1.53279)/(sqrt(701 y^2 - 106 y + 125) + 26.8328) and sqrt(701 y^2 - 106 y + 125) + 26.8328!=0 and y!=1 
  vec3 t = sqrt(((701.0 * color * color) - (106.0 * color)) + 125.0); 
  return ((((-0.137097 * t) - (2.5282 * color)) + 1.53279) / (t - 26.8328)) + vec3(0.004);
#elif BIDIRECTIONAL_TONEMAPPING_VARIANT == BIDIRECTIONAL_TONEMAPPING_VARIANT_UNCHARTED2
  // http://theagentd.blogspot.com/2013/01/hdr-inverse-tone-mapping-msaa-resolve.html
  float A = 0.15;
  float B = 0.50;
  float C = 0.10;
  float D = 0.20;
  float E = 0.02;
  float F = 0.30;
  float W = 11.2;
  //return ((color + vec3(E / F)) * (color + vec3(E / F)) - vec3(D * E)) / ((vec3(W) * (color + vec3(E / F)) - vec3(D * F)) * (color + vec3(E / F)) - vec3(D * E));
  //return (sqrt((4*color-4*color*color)*A*D*F*F*F+(-4*color*A*D*E+B*B*C*C-2*color*B*B*C+color*color*B*B)*F*F+(2*color*B*B-2*B*B*C)*E*F+B*B*E*E)+(B*C-color*B)*F-B*E)/((2*color-2)*A*F+2*A*E);
  // return (sqrt((4*color-4*color*color)*A*D*F*F*F+((4*color-4)*A*D*E+B*B*C*C+(2*color-2)*B*B*C+(color*color-2*color+1)*B*B)*F*F+((2-2*color)*B*B-2*B*B*C)*E*F+B*B*E*E)+((1-color)*B-B*C)*F+B*E)/(2*color*A*F-2*A*E);
  return ((sqrt((((4.0 * color) - (4.0 * color * color)) * A * D * F * F * F) + (((((4.0 * color) - vec3(4.0)) * A * D * E) + vec3(B * B * C * C)) + (((2.0 * color) - vec3(2.0)) * (B * B * C))) + (((color * color) - (2.0 * color)) + vec3(1.0)) * (B * B)) * (F * F)) + (((((vec3(2.0) - (2.0 * color)) * B * B) - vec3(2.0 * B * B * C)) * (E * F)) + vec3(B * B * E * E)) + ((((vec3(1.0) - color) * B) - vec3(B * C)) * F) + vec3(B * E)) / (((2.0 * color) * A * F) - vec3(2.0 * A * E));
#else // BIDIRECTIONAL_TONEMAPPING_VARIANT_NONE
  return color; // No inverse tonemapping operator is used.
#endif
}

vec4 ApplyToneMapping(vec4 color){
  return vec4(vec3(ApplyToneMapping(color.xyz)), color.w);
}

vec4 ApplyInverseToneMapping(vec4 color){
  return vec4(vec3(ApplyInverseToneMapping(color.xyz)), color.w);
}

#endif
