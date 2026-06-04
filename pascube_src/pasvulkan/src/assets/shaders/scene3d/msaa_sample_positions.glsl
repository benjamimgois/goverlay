#ifndef MSAA_SAMPLE_POSITIONS_GLSL
#define MSAA_SAMPLE_POSITIONS_GLSL

// The current Vulkan/SPIR-V spec does not provide a way to retrieve non-standard sample positions. If the pipeline is 
// configured for standard default positions, we can return the positions for rasterizationSamples up to 16. However, for 
// rasterizationSamples of 32 and 64, there are no standard positions defined.

// The following sample positions are based on the following source:
// - https://registry.khronos.org/vulkan/specs/1.3-extensions/html/vkspec.html#primsrast-multisampling

// Locations are defined relative to an origin in the upper left corner of the fragment. These are valid when
// the standardSampleLocations member of VkPhysicalDeviceLimits is VK_TRUE, and no custom sample locations with
// VK_EXT_sample_locations are provided, if supported at all. But that is the case for the majority of the hardware 
// anyway, so consider it just as given for simplicity.

const vec2 msaa1SamplePositions[1] = vec2[1](
  vec2(0.5, 0.5)
);

const vec2 msaa2SamplePositions[2] = vec2[2](
  vec2(0.75, 0.75),
  vec2(0.25, 0.25)
);

const vec2 msaa4SamplePositions[4] = vec2[4](
  vec2(0.375, 0.125),
  vec2(0.875, 0.375),
  vec2(0.125, 0.625),
  vec2(0.625, 0.875)
);  

const vec2 msaa8SamplePositions[8] = vec2[8](
  vec2(0.5625, 0.3125),
  vec2(0.4375, 0.6875),
  vec2(0.8125, 0.5625),
  vec2(0.3125, 0.1875),
  vec2(0.1875, 0.8125),
  vec2(0.0625, 0.4375),
  vec2(0.6875, 0.9375),
  vec2(0.9375, 0.0625)
);  

const vec2 msaa16SamplePositions[16] = vec2[16](
  vec2(0.5625, 0.5625),
  vec2(0.4375, 0.3125),
  vec2(0.3125, 0.6250),
  vec2(0.7500, 0.4375),
  vec2(0.1875, 0.3750),
  vec2(0.6250, 0.8125),
  vec2(0.8125, 0.6875),
  vec2(0.6875, 0.1875),
  vec2(0.3750, 0.8750),
  vec2(0.5000, 0.0625),
  vec2(0.2500, 0.1250),
  vec2(0.1250, 0.750),
  vec2(0.0000, 0.5000),
  vec2(0.9375, 0.2500),
  vec2(0.8750, 0.9375),
  vec2(0.0625, 0.0000)
);

vec2 getMSAASamplePosition(const in int countSamples, const in int sampleIndex){
  switch(countSamples){
    case 1:{
      return msaa1SamplePositions[0]; // Only one sample position, no need to mess with sampleIndex
    }
    case 2:{
      return msaa2SamplePositions[sampleIndex & 1];
    }
    case 4:{
      return msaa4SamplePositions[sampleIndex & 3];
    }
    case 8:{
      return msaa8SamplePositions[sampleIndex & 7];
    }
    case 16:{
      return msaa16SamplePositions[sampleIndex & 15];
    }
    default:{
      // No standard positions defined for 32 and 64 and other sample counts, therefore we return a default position which is the center of the pixel.
      return vec2(0.5);
    }
  }
}

#endif // MSAA_SAMPLE_POSITIONS_GLSL