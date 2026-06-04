#ifndef BAYER_GLSL
#define BAYER_GLSL

// Bayer dithering function for 2D positions, where n is the 2^n number of
// bayer matrix size in each dimension.
float bayerDither(uvec2 pos, const in uint n){

  // For a power-of-two n, bits = log2(n)
  const uint bits = uint(log2(float(n)));

  // Mask position
  pos &= uvec2((1u << bits) - 1u);

  // Interleave (pos.x XOR pos.y) and pos.x with morton code, and mask out any extra bits.
  uvec2 spread = uvec2(pos.x, pos.x ^ pos.y) & uvec2(0x0000ffffu);
  spread = (spread ^ (spread << uvec2(8u))) & uvec2(0x00ff00ffu);
  spread = (spread ^ (spread << uvec2(4u))) & uvec2(0x0f0f0f0fu);
  spread = (spread ^ (spread << uvec2(2u))) & uvec2(0x33333333u);
  spread = (spread ^ (spread << uvec2(1u))) & uvec2(0x55555555u);
  uint bitInterleaved = ((spread.x << 1u) ^ spread.y) & ((1u << (2u * bits)) - 1u);

  // Reverse the bits of the interleaved value, shift right to remove any extra bits,
  // and return the result as a float in the range [0, 1].  
  return float(uint(bitfieldReverse(bitInterleaved) >> (32u - (2u * bits)))) / float(n * n);

}

float bayer2(vec2 p){
  p = floor(p);
  return fract(dot(p, vec2(0.5, p.y * 0.75)));
}

float bayer4(vec2 p){
  return fma(bayer2(p * 0.5), 0.25, bayer2(p));
}

float bayer8(vec2 p){
  return fma(bayer4(p * 0.5), 0.25, bayer4(p));
}

float bayer16(vec2 p){
  return fma(bayer8(p * 0.25), 0.0625, bayer8(p));
}

float bayer32(vec2 p){
  return fma(bayer16(p * 0.25), 0.0625, bayer16(p));
}

float bayer64(vec2 p){
  return fma(bayer32(p * 0.125), 0.015625, bayer32(p));
}

float bayer128(vec2 p){
  return fma(bayer64(p * 0.125), 0.015625, bayer64(p));
}

float bayerDither2(vec2 p){
  return bayer2(p) - 0.375;
}

float bayerDither4(vec2 p){
  return bayer4(p) - 0.46875;
}

float bayerDither8(vec2 p){
  return bayer8(p) - 0.4921875;
}

float bayerDither16(vec2 p){
  return bayer16(p) - 0.49609375; // 0.498046875
}

float bayerDither32(vec2 p){
  return bayer32(p) - 0.49951171875;
}

float bayerDither64(vec2 p){
  return bayer64(p) - 0.4998779296875;
}

float bayerDither128(vec2 p){
  return bayer128(p) - 0.499969482421875;
}

#endif