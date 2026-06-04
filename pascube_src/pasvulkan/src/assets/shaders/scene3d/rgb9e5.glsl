#ifndef RGB9E5_GLSL
#define RGB9E5_GLSL

uint encodeRGB9E5(vec3 color){

#if 1

  // Fast and pretty exact version with bit magic on floats
 
  const float minValue = uintBitsToFloat(0x37800000u); // 1.00 x 2^-16
  const float maxValue = uintBitsToFloat(0x477f8000u); // 1.ff x 2^+15

  // Clamp the color to the representable range
  color = clamp(color, vec3(0.0), vec3(maxValue));

  // Find the largest component with clamping to the representable minimum value, so that the exponent is within the representable valid 5-bit range
  float maximumChannel = max(max(minValue, color.x), max(color.y, color.z));

  // Bias has to have the biggest exponent of the maximum channel plus 15 and nothing in the mantissa. When it will get added to the
  // three channels, it will shift the explicit one and the 8 most significant bits of the mantissa bits into the low 9 bits. The IEEE
  // 754 rules will take care of the rest, by rounding rather than truncating the value at addition. Channel values with smaller natural
  // exponents will be shifted further to the right => more bits will be discarded
  float bias = uintBitsToFloat((floatBitsToUint(maximumChannel) + 0x07804000u) & 0x7f800000u);

  // Cast the color floats to uint and shift the mantissas to the correct position
  uvec3 casted = (floatBitsToUint(color + bias) & uvec3(0x1ffu)) << uvec3(0u, 9u, 18u);

  // Combine the components
  return casted.x | casted.y | casted.z | uint((floatBitsToUint(bias) << 4u) + 0x10000000u);
  
#elif 0

  // Detailed version and without any floating point operations. It should be also more exact in terms of rounding and clamping, but maybe a bit slower

  // Clamp the color to the representable range
  color = clamp(color, vec3(0.0), vec3(65408.0));

  // Cast the color floats to uint
  const uvec3 castedColor = floatBitsToUint(color.xyz);

  // Extract the exponents
  uvec3 exponents = (castedColor & uvec3(0x7f800000u)) >> uvec3(23u);

  // Extract the mantissas and ORing the explicit 1 at the 9th bit
  uvec3 mantissas = (castedColor & uvec3(0x00ffffffu)) | uvec3(0x00800000u);

  // if the exponent is larger than what can be represented in 999e5, then clamp to the maximum exponanent and mantissa
  bvec3 overflowMask = greaterThan(exponents, uvec3(127u + 15u));
  exponents = mix(exponents, uvec3(127u + 15u), overflowMask);
  mantissas = mix(mantissas, uvec3(0x00ffffffu), overflowMask);

  // Find the largest exponent
  uint maximumExponent = max(max(exponents.x, exponents.y), exponents.z);
  
  // If the largest exponent is smaller than the representable minimum, then clamp to zero
  if(maximumExponent < (127u - 16u)){
    maximumExponent = 127u - 16u;
    mantissas = uvec3(0u);
  }

  // Rounding, adds half lsb before truncating the value
  mantissas += (uvec3(0x00004000u)) << (uvec3(maximumExponent) - exponents);

  // Shift the mantissas to the correct position, based on the difference between the max exponent and the component's exponent
  mantissas = mix(
    mantissas >> (uvec3(maximumExponent + 15u) - exponents),
    uvec3(0x0), 
    greaterThan(uvec3(maximumExponent) - exponents, uvec3(8u))
  ) & uvec3(0x1ffu);

  // Combine the components
  return (mantissas.x << 0u) | (mantissas.y << 9u) | (mantissas.z << 18u) | (uint(maximumExponent - (127u - 16u)) << 27u);
     
#else  
  
  // The more compact version with floating point operations

  // Clamp the color to the representable range
  color = clamp(color, vec3(0.0), vec3(65408.0));

  // Find the largest component
  float maximumChannel = max(max(color.x, color.y), color.z);

  // Get the shared exponent
  int sharedExponent = clamp(int((uint(floatBitsToUint(maximumChannel) & 0x7f800000u) >> 23u)) - (127 - 16), 0, 31);

  // Calculate the denominator
  float denominator = exp2(float(sharedExponent - 24));  

  // Calculate the maximum value
  int maximum = int(floor((maximumChannel / denominator) + 0.5));

  // If the maximum value is larger than 511, then double the denominator and increment the shared exponent
  if(maximum >= 512){
    denominator *= 2.0;
    sharedExponent++;
  }

  // Calculate the mantissas
  uvec3 t = (uvec3(floor((color / denominator) + vec3(0.5))) & uvec3(0x1ffu)) << uvec3(0u, 9u, 18u);

  // Combine the components
  return t.x | t.y | t.z | (uint(sharedExponent) << 27u);

#endif
}

vec3 decodeRGB9E5(uint color){
#if 1

  // Fast oneliner version
  return vec3(uvec3((uvec3(color) >> uvec3(0u, 9u, 18u)) & uvec3(0x1ffu))) * vec3(exp2(float(int(int(uint((color >> 27u) & 31u)) - 24))));

#elif 0

  // Detailed version and without any floating point operations

  // Extract the shared exponent with +1 compensation for the implicit 1
  const uint sharedExponent = ((color >> 27u) & 0x1fu) + (127u - 16u);

  // Extract the mantissas
  uvec3 mantissas = (uvec3(color) >> uvec3(0u, 9u, 18u)) & uvec3(0x1ffu);

  // Get the most significant bit of the mantissas and add 1 to the shift which is the amount of bits to shift the expanded mantissas for 32-bit floats
  const uvec3 shifts = uvec3(findMSB(mantissas & uvec3(0x1ffu))) + uvec3(1u); 

  // Expand the mantissas for 32-bit floats
  mantissas = (mantissas << (uvec3(9u) - shifts)) & uvec3(0xffu);
  mantissas = (mantissas << uvec3(15u)) | (mantissas << uvec3(7u)) | (mantissas >> uvec3(1u));

  // Construct the exponents
  const uvec3 exponents = (mix((uvec3(sharedExponent) + shifts) - uvec3(9u), uvec3(0u), equal(shifts, uvec3(0u))) & uvec3(0xffu)) << uvec3(23u);

  // Combine the components
  return uintBitsToFloat(exponents | mantissas);

#else
  
  // Also fast but a bit more readable version

  return vec3(
    float(bitfieldExtract(color, 0, 9)),
    float(bitfieldExtract(color, 9, 9)),
    float(bitfieldExtract(color, 18, 9))
  ) * exp2(float(int(bitfieldExtract(color, 27, 5)) - 24)); 

#endif
}

#endif