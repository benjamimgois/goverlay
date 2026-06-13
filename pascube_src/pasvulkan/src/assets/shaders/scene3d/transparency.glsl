
// Check for valid section define combination
#if (defined(TRANSPARENCY_DECLARATION) && defined(TRANSPARENCY_IMPLEMENTATION)) || \
    (defined(TRANSPARENCY_DECLARATION) && defined(TRANSPARENCY_GLOBALS)) || \
    (defined(TRANSPARENCY_GLOBALS) && defined(TRANSPARENCY_IMPLEMENTATION))
  #error "Only one of TRANSPARENCY_DECLARATION, TRANSPARENCY_GLOBALS and TRANSPARENCY_IMPLEMENTATION can be defined at once"
#endif

// -------------------------------------------------------------------------------------------------
// Declarations section
// -------------------------------------------------------------------------------------------------
#if defined(TRANSPARENCY_DECLARATION)

  #ifdef DEPTHONLY
    #if defined(MBOIT) && defined(MBOITPASS1)
      layout(location = 0) out vec4 outFragMBOITMoments0;
      layout(location = 1) out vec4 outFragMBOITMoments1;
    #endif
  #else
    #if defined(WBOIT)
      layout(location = 0) out vec4 outFragWBOITAccumulation;
      layout(location = 1) out vec4 outFragWBOITRevealage;
    #elif defined(MBOIT)
      #if defined(MBOITPASS1)
        layout(location = 0) out vec4 outFragMBOITMoments0;
        layout(location = 1) out vec4 outFragMBOITMoments1;
      #elif defined(MBOITPASS2)
        layout(location = 0) out vec4 outFragColor;
      #endif
    #else
      layout(location = 0) out vec4 outFragColor;
    #endif
  #endif

  #if defined(MESH_FRAGMENT_SHADER) || defined(PARTICLE_FRAGMENT_SHADER) || defined(WATER_FRAGMENT_SHADER)

    #if defined(BLEND)

      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInputMS uOITImgDepth;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInput uOITImgDepth;
      #endif

    #elif defined(WBOIT)

      layout(set = 1, binding = 9, std140) uniform uboWBOIT {
        vec4 wboitZNearZFar;
      } uWBOIT;
      
      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInputMS uOITImgDepth;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInput uOITImgDepth;
      #endif

    #elif defined(MBOIT)

      layout(set = 1, binding = 9, std140) uniform uboMBOIT {
        vec4 mboitZNearZFar;
      } uMBOIT;

      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInputMS uOITImgDepth;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInput uOITImgDepth;
      #endif

      #if defined(MBOITPASS1)
      #elif defined(MBOITPASS2)
        #ifdef MSAA
          layout(input_attachment_index = 0, set = 1, binding = 11) uniform subpassInputMS uMBOITMoments0;
          layout(input_attachment_index = 1, set = 1, binding = 12) uniform subpassInputMS uMBOITMoments1;
        #else
          layout(input_attachment_index = 0, set = 1, binding = 11) uniform subpassInput uMBOITMoments0;
          layout(input_attachment_index = 1, set = 1, binding = 12) uniform subpassInput uMBOITMoments1;
        #endif
      #endif

    #elif defined(LOCKOIT)

      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInputMS uOITImgDepth;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInput uOITImgDepth;
      #endif
      layout(set = 1, binding = 10, rgba32ui) uniform coherent uimageBuffer uOITImgABuffer;
      layout(set = 1, binding = 11, r32ui) uniform coherent uimage2DArray uOITImgAux;
      #ifdef SPINLOCK
        layout(set = 1, binding = 12, r32ui) uniform coherent uimage2DArray uOITImgSpinLock;
        layout(set = 1, binding = 13, std140) uniform uboOIT {
          ivec4 oitViewPort;
        } uOIT;
      #endif
      #ifdef INTERLOCK
        layout(set = 1, binding = 12, std140) uniform uboOIT {
          ivec4 oitViewPort;
        } uOIT;
      #endif

    #elif defined(DFAOIT)

      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInputMS uOITImgDepth;
        layout(set = 1, binding = 10, rgba32ui) uniform coherent uimage2DMSArray uOITImgFragmentCouterFragmentDepthsSampleMask;
        layout(set = 1, binding = 11, rgba16f) uniform coherent image2DMSArray uOITImgAccumulation;
        layout(set = 1, binding = 12, rgba16f) uniform coherent image2DMSArray uOITImgAverage;
        layout(set = 1, binding = 13, rgba16f) uniform coherent image2DMSArray uOITImgBucket;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInput uOITImgDepth;
        layout(set = 1, binding = 10, rgba32ui) uniform coherent uimage2DArray uOITImgFragmentCouterFragmentDepthsSampleMask;
        layout(set = 1, binding = 11, rgba16f) uniform coherent image2DArray uOITImgAccumulation;
        layout(set = 1, binding = 12, rgba16f) uniform coherent image2DArray uOITImgAverage;
        layout(set = 1, binding = 13, rgba16f) uniform coherent image2DArray uOITImgBucket;
      #endif
      #ifdef SPINLOCK
        layout(set = 1, binding = 14, r32ui) uniform coherent uimage2DArray uOITImgSpinLock;
        /*layout(set = 1, binding = 15, std140) uniform uboOIT {
          ivec4 oitViewPort;
        } uOIT;*/
      #endif
      #ifdef INTERLOCK
        /*layout(set = 1, binding = 15, std140) uniform uboOIT {
          ivec4 oitViewPort;
        } uOIT;*/
      #endif

    #elif defined(LOOPOIT)

      layout(set = 1, binding = 9, std140) uniform uboOIT {
        ivec4 oitViewPort;
      } uOIT;
      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInputMS uOITImgDepth;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInput uOITImgDepth;
      #endif
      #if defined(LOOPOIT_PASS1)
        layout(set = 1, binding = 11, r32ui) uniform coherent uimageBuffer uOITImgZBuffer;
      #else
        layout(set = 1, binding = 11, r32ui) uniform readonly uimageBuffer uOITImgZBuffer;
        layout(set = 1, binding = 12, rg32ui) uniform coherent uimageBuffer uOITImgABuffer;
        #ifdef MSAA    
          layout(set = 1, binding = 13, r32ui) uniform coherent uimageBuffer uOITImgSBuffer;
        #endif
      #endif 

    #endif

  /*#elif defined(PARTICLE_FRAGMENT)

    #if defined(WBOIT)

      layout(set = 1, binding = 9, std140) uniform uboWBOIT {
        vec4 wboitZNearZFar;
      } uWBOIT;

    #elif defined(MBOIT)

      layout(set = 1, binding = 9, std140) uniform uboMBOIT {
        vec4 mboitZNearZFar;
      } uMBOIT;

      #if defined(MBOITPASS1)
      #elif defined(MBOITPASS2)
        #ifdef MSAA
          layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInputMS uMBOITMoments0;
          layout(input_attachment_index = 1, set = 1, binding = 11) uniform subpassInputMS uMBOITMoments1;
        #else
          layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInput uMBOITMoments0;
          layout(input_attachment_index = 1, set = 1, binding = 11) uniform subpassInput uMBOITMoments1;
        #endif
      #endif

    #elif defined(LOCKOIT)

      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInputMS uOITImgDepth;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInput uOITImgDepth;
      #endif
      layout(set = 1, binding = 10, rgba32ui) uniform coherent uimageBuffer uOITImgABuffer;
      layout(set = 1, binding = 11, r32ui) uniform coherent uimage2DArray uOITImgAux;
      #ifdef SPINLOCK
        layout(set = 1, binding = 12, r32ui) uniform coherent uimage2DArray uOITImgSpinLock;
        layout(set = 1, binding = 13, std140) uniform uboOIT {
          ivec4 oitViewPort;
        } uOIT;
      #endif
      #ifdef INTERLOCK
        layout(set = 1, binding = 12, std140) uniform uboOIT {
          ivec4 oitViewPort;
        } uOIT;
      #endif

    #elif defined(DFAOIT)

      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInputMS uOITImgDepth;
        layout(set = 1, binding = 10, rgba32ui) uniform coherent uimage2DMSArray uOITImgFragmentCouterFragmentDepthsSampleMask;
        layout(set = 1, binding = 11, rgba16f) uniform coherent image2DMSArray uOITImgAccumulation;
        layout(set = 1, binding = 12, rgba16f) uniform coherent image2DMSArray uOITImgAverage;
        layout(set = 1, binding = 13, rgba16f) uniform coherent image2DMSArray uOITImgBucket;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInput uOITImgDepth;
        layout(set = 1, binding = 10, rgba32ui) uniform coherent uimage2DArray uOITImgFragmentCouterFragmentDepthsSampleMask;
        layout(set = 1, binding = 11, rgba16f) uniform coherent image2DArray uOITImgAccumulation;
        layout(set = 1, binding = 12, rgba16f) uniform coherent image2DArray uOITImgAverage;
        layout(set = 1, binding = 13, rgba16f) uniform coherent image2DArray uOITImgBucket;
      #endif
      #ifdef SPINLOCK
        layout(set = 1, binding = 14, r32ui) uniform coherent uimage2DArray uOITImgSpinLock;
        //layout(set = 1, binding = 15, std140) uniform uboOIT {
        //  ivec4 oitViewPort;
        //} uOIT;
      #endif
      #ifdef INTERLOCK
        //layout(set = 1, binding = 15, std140) uniform uboOIT {
        //  ivec4 oitViewPort;
        //} uOIT;
      #endif

    #elif defined(LOOPOIT)

      layout(set = 1, binding = 9, std140) uniform uboOIT {
        ivec4 oitViewPort;
      } uOIT;
      #ifdef MSAA
        layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInputMS uOITImgDepth;
      #else
        layout(input_attachment_index = 0, set = 1, binding = 10) uniform subpassInput uOITImgDepth;
      #endif
      #if defined(LOOPOIT_PASS1)
        layout(set = 1, binding = 11, r32ui) uniform coherent uimageBuffer uOITImgZBuffer;
      #else
        layout(set = 1, binding = 11, r32ui) uniform readonly uimageBuffer uOITImgZBuffer;
        layout(set = 1, binding = 12, rg32ui) uniform coherent uimageBuffer uOITImgABuffer;
        #ifdef MSAA    
          layout(set = 1, binding = 13, r32ui) uniform coherent uimageBuffer uOITImgSBuffer;
        #endif
      #endif 

    #endif
*/
  #else

    #error "No transparency method defined or wrong shader type"

  #endif

#endif

// -------------------------------------------------------------------------------------------------
// Global section
// -------------------------------------------------------------------------------------------------
#if defined(TRANSPARENCY_GLOBALS)
  #if defined(WBOIT)
  #elif defined(MBOIT)
    #include "mboit.glsl"
  #endif
#endif

// -------------------------------------------------------------------------------------------------
// Code section
// -------------------------------------------------------------------------------------------------
#if defined(TRANSPARENCY_IMPLEMENTATION)

#if defined(WBOIT)

  #include "transparency_wboit.glsl"

#elif defined(MBOIT)

  #include "transparency_mboit.glsl"

#elif defined(DFAOIT)

#ifdef INTERLOCK
  beginInvocationInterlock();
#endif
  if(reversedZ){
    #define REVERSEDZ
    #include "transparency_dfaoit.glsl"
  }else{
    #undef REVERSEDZ
    #include "transparency_dfaoit.glsl"
  }
#ifdef INTERLOCK
  endInvocationInterlock();
#endif

#elif defined(LOCKOIT)

#ifdef INTERLOCK
  beginInvocationInterlock();
#endif
  if(reversedZ){
    #define REVERSEDZ
    #include "transparency_lockoit.glsl"
  }else{
    #undef REVERSEDZ
    #include "transparency_lockoit.glsl"
  }
#ifdef INTERLOCK
  endInvocationInterlock();
#endif

#elif defined(LOOPOIT)

  if(reversedZ){
    #define REVERSEDZ
    #include "transparency_loopoit.glsl"
  }else{
    #undef REVERSEDZ
    #include "transparency_loopoit.glsl"
  }

#elif defined(BLEND)

  outFragColor = vec4(clamp(finalColor.xyz * (additiveBlending ? 1.0 : finalColor.w), vec3(-65504.0), vec3(65504.0)), finalColor.w);

#endif

#endif