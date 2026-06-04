
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

  float depth = fma((log(clamp(-inViewSpacePosition.z, uWBOIT.wboitZNearZFar.x, uWBOIT.wboitZNearZFar.y)) - uWBOIT.wboitZNearZFar.z) / (uWBOIT.wboitZNearZFar.w - uWBOIT.wboitZNearZFar.z), 2.0, -1.0); 
  float transmittance = clamp(1.0 - alpha, 1e-4, 1.0);
  if(!additiveBlending){
    finalColor.xyz *= finalColor.w;
  }
  finalColor.xyz = clamp(finalColor.xyz, vec3(-65504.0), vec3(65504.0));
  float weight = min(1.0, fma(max(max(finalColor.x, finalColor.y), max(finalColor.z, finalColor.w)), 40.0, 0.01)) * clamp(depth, 1e-2, 3e3); //clamp(0.03 / (1e-5 + pow(abs(inViewSpacePosition.z) / 200.0, 4.0)), 1e-2, 3e3);
  outFragWBOITAccumulation = clamp(finalColor * weight, vec4(-65504.0), vec4(65504.0));
  outFragWBOITRevealage = vec4(finalColor.w);

#elif defined(MBOIT)

  float depth = MBOIT_WarpDepth(clamp(-inViewSpacePosition.z, uMBOIT.mboitZNearZFar.x, uMBOIT.mboitZNearZFar.y), uMBOIT.mboitZNearZFar.z, uMBOIT.mboitZNearZFar.w);
  float transmittance = clamp(1.0 - alpha, 1e-4, 1.0);
#ifdef MBOITPASS1
  {
    float b0;
    vec4 b1234;
    vec4 b56;
    MBOIT6_GenerateMoments(depth, transmittance, b0, b1234, b56);
    outFragMBOITMoments0 = vec4(b0, b1234.xyz);
    outFragMBOITMoments1 = vec4(b1234.w, b56.xy, 0.0);
  }
#elif defined(MBOITPASS2)
  {
#ifdef MSAA
    vec4 mboitMoments0 = subpassLoad(uMBOITMoments0, gl_SampleID); 
    vec4 mboitMoments1 = subpassLoad(uMBOITMoments1, gl_SampleID); 
#else    
    vec4 mboitMoments0 = subpassLoad(uMBOITMoments0); 
    vec4 mboitMoments1 = subpassLoad(uMBOITMoments1); 
#endif
    float b0 = mboitMoments0.x;
    vec4 b1234 = vec4(mboitMoments0.yzw, mboitMoments1.x);
    vec4 b56 = vec3(mboitMoments1.yz, 0.0).xyzz;
    float transmittance_at_depth = 1.0;
    float total_transmittance = 1.0;
    MBOIT6_ResolveMoments(transmittance_at_depth,  //
                          total_transmittance,     //
                          depth,                   //
                          5e-5,                    // moment_bias
                          0.04,                    // overestimation
                          b0,                      //
                          b1234,                   //
                          b56);
    if(isinf(transmittance_at_depth) || isnan(transmittance_at_depth)){
      transmittance_at_depth = 1.0;
    }
    vec4 fragColor = additiveBlending ? 
                     (vec4(finalColor.xyz, finalColor.w) * transmittance_at_depth) :         // Additive blending
                     (vec4(finalColor.xyz, 1.0) * (finalColor.w * transmittance_at_depth));  // Premultiplied alpha blending
    outFragColor = vec4(clamp(fragColor.xyz, vec3(-65504.0), vec3(65504.0)), fragColor.w);
  } 
#endif

#elif defined(DFAOIT)

  int oitMultiViewIndex = int(gl_ViewIndex);
  ivec3 oitCoord = ivec3(ivec2(gl_FragCoord.xy), oitMultiViewIndex);
#ifdef WATER_FRAGMENT_SHADER
  uint oitStoreMask = 0xffffffffu; // All bits set, since it is a full-screen post-processing effect
#else
  uint oitStoreMask = uint(gl_SampleMaskIn[0]);
#endif

#ifdef INTERLOCK
  beginInvocationInterlock();
#endif

  // Workaround for missing VK_EXT_post_depth_coverage support on AMD GPUs older than RDNA,
  // namely, an extra OIT renderpass with an fragment-shader-based depth check on the depth
  // buffer values from the previous forward rendering pass, which should fix problems with
  // transparent and opaque objects in MSAA, even without VK_EXT_post_depth_coverage support,
  // at least I hope it so:
 #ifdef OVERRIDED_DEPTH
  uint oitCurrentDepth = floatBitsToUint(OVERRIDED_DEPTH);
 #else
  uint oitCurrentDepth = floatBitsToUint(gl_FragCoord.z);
 #endif
 #ifdef MSAA
  uint oitDepth = floatBitsToUint(subpassLoad(uOITImgDepth, gl_SampleID).x);
 #else
  uint oitDepth = floatBitsToUint(subpassLoad(uOITImgDepth).x);
 #endif
  if(
#ifdef USE_SPECIALIZATION_CONSTANTS
     ((UseReversedZ && (oitCurrentDepth >= oitDepth)) ||
      ((!UseReversedZ) && (oitCurrentDepth <= oitDepth))) &&
#else
#ifdef REVERSEDZ
     (oitCurrentDepth >= oitDepth) &&
#else
     (oitCurrentDepth <= oitDepth) &&
#endif
#endif
     (min(alpha, finalColor.w) > 0.0)
    ){

     if(!additiveBlending){
       finalColor.xyz *= finalColor.w;
     }

     finalColor.xyz = clamp(finalColor.xyz, vec3(-65504.0), vec3(65504.0));

#ifdef SPINLOCK
    for(bool oitDone = gl_HelperInvocation || (oitStoreMask == 0); !oitDone; ){
      if(imageAtomicExchange(uOITImgSpinLock, oitCoord, 1u) == 0u){
      //if(imageAtomicCompSwap(uOITImgSpinLock, oitCoord, 0u, 1u) == 0u){
#endif

#ifdef MSAA
        #define SAMPLE_ID , int(gl_SampleID)
#else
        #define SAMPLE_ID
#endif

        // Average color
        imageStore(uOITImgAverage, oitCoord SAMPLE_ID , vec4(imageLoad(uOITImgAverage, oitCoord SAMPLE_ID ) + finalColor));
        
        // Accumulated color
        imageStore(uOITImgAccumulation, oitCoord SAMPLE_ID , vec4((imageLoad(uOITImgAccumulation, oitCoord SAMPLE_ID ) + vec4(finalColor.xyz, 0.0)) * vec2(1.0, 1.0 - finalColor.w).xxxy));

        // Load the first and second fragments
        vec4 fragments[2];
        fragments[0] = imageLoad(uOITImgBucket, ivec3(oitCoord.xy, (oitCoord.z << 1) | 0) SAMPLE_ID );
        fragments[1] = imageLoad(uOITImgBucket, ivec3(oitCoord.xy, (oitCoord.z << 1) | 1) SAMPLE_ID );

        uvec4 fragmentCounterFragmentDepthsSampleMask = (imageLoad(uOITImgFragmentCouterFragmentDepthsSampleMask, oitCoord SAMPLE_ID ) + uvec2(1u, 0u).xyyy) | uvec2(0, oitStoreMask).xxxy;
        uvec2 depths = uvec2(fragmentCounterFragmentDepthsSampleMask.yz); 

        uint depth = oitCurrentDepth;

        if
#ifdef REVERSEDZ
          (depth >= depths.x)
#else
          (depth <= depths.x)
#endif
        {
          vec4 tempColor = finalColor;
          uint tempDepth = depth;
          finalColor = fragments[0];
          depth = depths.x;
          imageStore(uOITImgBucket, ivec3(oitCoord.xy, (oitCoord.z << 1) | 0) SAMPLE_ID , fragments[0] = tempColor);
          fragmentCounterFragmentDepthsSampleMask.y = depths.x = tempDepth;
        }

        if
#ifdef REVERSEDZ
          (depth >= depths.y)
#else
          (depth <= depths.y)
#endif
        {
          vec4 tempColor = finalColor;
          uint tempDepth = depth;
          finalColor = fragments[1];
          depth = depths.y;          
          imageStore(uOITImgBucket, ivec3(oitCoord.xy, (oitCoord.z << 1) | 1) SAMPLE_ID , fragments[1] = tempColor);
          fragmentCounterFragmentDepthsSampleMask.z = depths.y = tempDepth;
        }

        imageStore(uOITImgFragmentCouterFragmentDepthsSampleMask, oitCoord SAMPLE_ID , fragmentCounterFragmentDepthsSampleMask);

        #undef SAMPLE_ID

#ifdef SPINLOCK
        memoryBarrier();
        imageAtomicExchange(uOITImgSpinLock, oitCoord, 0u);
        oitDone = true;
      }
    }
#endif

  }

#ifdef INTERLOCK
  endInvocationInterlock();
#endif

  outFragColor = vec4(0.0);

#elif defined(LOCKOIT)

  int oitMultiViewIndex = int(gl_ViewIndex);
  ivec3 oitCoord = ivec3(ivec2(gl_FragCoord.xy), oitMultiViewIndex);
#ifdef WATER_FRAGMENT_SHADER
  uint oitStoreMask = 0xffffffffu; // All bits set, since it is a full-screen post-processing effect
#else
  uint oitStoreMask = uint(gl_SampleMaskIn[0]);
#endif

#ifdef INTERLOCK
  beginInvocationInterlock();
#endif

  // Workaround for missing VK_EXT_post_depth_coverage support on AMD GPUs older than RDNA,
  // namely, an extra OIT renderpass with an fragment-shader-based depth check on the depth 
  // buffer values from the previous forward rendering pass, which should fix problems with 
  // transparent and opaque objects in MSAA, even without VK_EXT_post_depth_coverage support,
  // at least I hope it so:
 #ifdef OVERRIDED_DEPTH
  uint oitCurrentDepth = floatBitsToUint(OVERRIDED_DEPTH);
 #else
  uint oitCurrentDepth = floatBitsToUint(gl_FragCoord.z);
 #endif
 #ifdef MSAA 
  uint oitDepth = floatBitsToUint(subpassLoad(uOITImgDepth, gl_SampleID).r); 
 #else
  uint oitDepth = floatBitsToUint(subpassLoad(uOITImgDepth).r); 
 #endif 
  if(
#ifdef USE_SPECIALIZATION_CONSTANTS
     ((UseReversedZ && (oitCurrentDepth >= oitDepth)) ||
      ((!UseReversedZ) && (oitCurrentDepth <= oitDepth))) &&
#else
#ifdef REVERSEDZ
     (oitCurrentDepth >= oitDepth) &&  
#else
     (oitCurrentDepth <= oitDepth) &&  
#endif
#endif
     (min(alpha, finalColor.w) > 0.0)
    ){

    if(!additiveBlending){
      finalColor.xyz *= finalColor.w;
    }

    finalColor.xyz = clamp(finalColor.xyz, vec3(-65504.0), vec3(65504.0));

#ifndef IGNORELOCKOIT
    const int oitViewSize = int(uOIT.oitViewPort.z);
    const int oitCountLayers = int(uOIT.oitViewPort.w & 0xffffu);
    const int oitMultiViewSize = oitViewSize * oitCountLayers;
    const int oitABufferBaseIndex = ((oitCoord.y * int(uOIT.oitViewPort.x)) + oitCoord.x) + (oitMultiViewSize * oitMultiViewIndex);

    uvec4 oitStoreValue = uvec4(packHalf2x16(finalColor.xy), packHalf2x16(finalColor.zw), oitCurrentDepth, oitStoreMask);

#ifdef SPINLOCK
    for(bool oitDone = gl_HelperInvocation || (oitStoreMask == 0); !oitDone; ){
      if(imageAtomicExchange(uOITImgSpinLock, oitCoord, 1u) == 0u){
      //if(imageAtomicCompSwap(uOITImgSpinLock, oitCoord, 0u, 1u) == 0u){
#endif
       const uint oitAuxCounter = imageLoad(uOITImgAux, oitCoord).x;
#if defined(MSAA)
        bool mustInsert = true;
        for(int oitIndex = 0; oitIndex < oitAuxCounter; oitIndex++){
          uvec4 oitFragment = imageLoad(uOITImgABuffer, oitABufferBaseIndex + (oitIndex * oitViewSize));
          if((oitFragment.w != 0u) && (oitFragment.z == oitStoreValue.z)){
            mustInsert = false;
            oitFragment.w |= oitStoreMask;
            imageStore(uOITImgABuffer, oitABufferBaseIndex + (oitIndex * oitViewSize), oitFragment);
            break;
          }
        }
        if(mustInsert)
#endif
        {
          imageStore(uOITImgAux, oitCoord, uvec4(oitAuxCounter + 1, 0, 0, 0));
          if(oitAuxCounter < oitCountLayers){
            imageStore(uOITImgABuffer, oitABufferBaseIndex + (int(oitAuxCounter) * oitViewSize), oitStoreValue);
            finalColor = vec4(0.0);
          }else{
            int oitFurthest = 0;
#ifdef USE_SPECIALIZATION_CONSTANTS
            uint oitMaxDepth = UseReversedZ ? 0xffffffffu : 0u;
#else
  #ifdef REVERSEDZ
            uint oitMaxDepth = 0xffffffffu;
  #else
            uint oitMaxDepth = 0;
  #endif
#endif
            for(int oitIndex = 0; oitIndex < oitCountLayers; oitIndex++){
              uint oitTestDepth = imageLoad(uOITImgABuffer, oitABufferBaseIndex + (oitIndex * oitViewSize)).z;
              if(
#ifdef USE_SPECIALIZATION_CONSTANTS
                  (UseReversedZ && (oitTestDepth < oitMaxDepth)) ||
                  ((!UseReversedZ) && (oitTestDepth > oitMaxDepth))
#else
  #ifdef REVERSEDZ
                  (oitTestDepth < oitMaxDepth)
  #else
                  (oitTestDepth > oitMaxDepth)
  #endif
#endif
                ){
                oitMaxDepth = oitTestDepth;
                oitFurthest = oitIndex;
              }
            }

            if(
#ifdef USE_SPECIALIZATION_CONSTANTS
               (UseReversedZ && (oitMaxDepth < oitStoreValue.z)) ||
               ((!UseReversedZ) && (oitMaxDepth > oitStoreValue.z))
#else
  #ifdef REVERSEDZ
              (oitMaxDepth < oitStoreValue.z)
  #else
              (oitMaxDepth > oitStoreValue.z)
  #endif
#endif
              ){
              int oitIndex = oitABufferBaseIndex + (oitFurthest * oitViewSize);
              uvec4 oitOldValue = imageLoad(uOITImgABuffer, oitIndex);
              finalColor = vec4(vec2(unpackHalf2x16(oitOldValue.x)), vec2(unpackHalf2x16(oitOldValue.y)));
              imageStore(uOITImgABuffer, oitIndex, oitStoreValue);
            }
          }
        }
#ifdef SPINLOCK
        memoryBarrier();
        imageAtomicExchange(uOITImgSpinLock, oitCoord, 0u);        
        oitDone = true;
      }
    }
#endif
#endif
  } else {
    finalColor = vec4(0.0);
  }

#ifdef INTERLOCK
  endInvocationInterlock();
#endif

  outFragColor = finalColor;

#elif defined(LOOPOIT)

  int oitMultiViewIndex = int(gl_ViewIndex);
  ivec3 oitCoord = ivec3(ivec2(gl_FragCoord.xy), oitMultiViewIndex);
#ifdef MSAA
#ifdef WATER_FRAGMENT_SHADER
  uint oitStoreMask = 0xffffffffu; // All bits set, since it is a full-screen post-processing effect
#else
  uint oitStoreMask = uint(gl_SampleMaskIn[0]);
#endif
#else
  uint oitStoreMask = 0x00000001u;
#endif  

  // Workaround for missing VK_EXT_post_depth_coverage support on AMD GPUs older than RDNA,
  // namely, an extra OIT renderpass with an fragment-shader-based depth check on the depth 
  // buffer values from the previous forward rendering pass, which should fix problems with 
  // transparent and opaque objects in MSAA, even without VK_EXT_post_depth_coverage support,
  // at least I hope it so:
 #ifdef OVERRIDED_DEPTH
  uint oitCurrentDepth = floatBitsToUint(OVERRIDED_DEPTH);
 #else
  uint oitCurrentDepth = floatBitsToUint(gl_FragCoord.z);
 #endif
 #ifdef MSAA 
  uint oitDepth = floatBitsToUint(subpassLoad(uOITImgDepth, gl_SampleID).r); 
 #else
  uint oitDepth = floatBitsToUint(subpassLoad(uOITImgDepth).r); 
 #endif 
 if(
#ifdef USE_SPECIALIZATION_CONSTANTS
     ((UseReversedZ && ((oitCurrentDepth >= oitDepth))) ||
      ((!UseReversedZ) && ((oitCurrentDepth <= oitDepth)))) &&
#else
#ifdef REVERSEDZ
     (oitCurrentDepth >= oitDepth) &&  
#else
     (oitCurrentDepth <= oitDepth) &&  
#endif
#endif
#if defined(LOOPOIT_PASS1)
     (alpha > 0.0)
#elif defined(LOOPOIT_PASS2)
     (min(alpha, finalColor.w) > 0.0)
#else
     true    
#endif
    ){

    const int oitViewSize = int(uOIT.oitViewPort.z);
    const int oitCountLayers = int(uOIT.oitViewPort.w & 0xffffu);
    const int oitMultiViewSize = oitViewSize * oitCountLayers;
    const int oitBufferBaseIndex = (((oitCoord.y * int(uOIT.oitViewPort.x)) + oitCoord.x) * oitCountLayers) + (oitMultiViewSize * oitMultiViewIndex);

    #if defined(LOOPOIT_PASS1)

#ifdef USE_SPECIALIZATION_CONSTANTS
      if(UseReversedZ){
        for(int oitLayerIndex = 0; oitLayerIndex < oitCountLayers; oitLayerIndex++){
          uint oitDepth = imageAtomicMax(uOITImgZBuffer, oitBufferBaseIndex + oitLayerIndex, oitCurrentDepth);
          if((oitDepth == 0x00000000u) || (oitDepth == oitCurrentDepth)){
            break;
          }
          oitCurrentDepth = min(oitCurrentDepth, oitDepth);
        }
      }else{
        for(int oitLayerIndex = 0; oitLayerIndex < oitCountLayers; oitLayerIndex++){
          uint oitDepth = imageAtomicMin(uOITImgZBuffer, oitBufferBaseIndex + oitLayerIndex, oitCurrentDepth);
          if((oitDepth == 0xFFFFFFFFu) || (oitDepth == oitCurrentDepth)){
            break;
          }
          oitCurrentDepth = max(oitCurrentDepth, oitDepth);
        }
      }
#else
      for(int oitLayerIndex = 0; oitLayerIndex < oitCountLayers; oitLayerIndex++){
#ifdef REVERSEDZ
        uint oitDepth = imageAtomicMax(uOITImgZBuffer, oitBufferBaseIndex + oitLayerIndex, oitCurrentDepth);
        if((oitDepth == 0x00000000u) || (oitDepth == oitCurrentDepth)){
          break;
        }
        oitCurrentDepth = min(oitCurrentDepth, oitDepth);
#else
        uint oitDepth = imageAtomicMin(uOITImgZBuffer, oitBufferBaseIndex + oitLayerIndex, oitCurrentDepth);
        if((oitDepth == 0xFFFFFFFFu) || (oitDepth == oitCurrentDepth)){
          break;
        }
        oitCurrentDepth = max(oitCurrentDepth, oitDepth);
#endif
      }
#endif

#ifndef DEPTHONLY    
      outFragColor = vec4(0.0);
#endif

    #elif defined(LOOPOIT_PASS2)

      if(!additiveBlending){
        finalColor.xyz *= finalColor.w;
      }

      finalColor.xyz = clamp(finalColor.xyz, vec3(-65504.0), vec3(65504.0));

#ifdef USE_SPECIALIZATION_CONSTANTS
      float oitTempDepth = imageLoad(uOITImgZBuffer, oitBufferBaseIndex + (oitCountLayers - 1)).x;
#endif      
      if(
#ifdef USE_SPECIALIZATION_CONSTANTS
         ((UseReversedZ && (oitTempDepth > oitCurrentDepth)) ||
          ((!UseReversedZ) && (oitTempDepth < oitCurrentDepth)))
#else          
         imageLoad(uOITImgZBuffer, oitBufferBaseIndex + (oitCountLayers - 1)).x
#ifdef REVERSEDZ
         >
#else 
         <
#endif
         oitCurrentDepth
#endif
        ){
#ifndef DEPTHONLY    
        outFragColor = finalColor;
#endif
      }else{
        int oitStart = 0;
        int oitEnd = oitCountLayers - 1;
        while(oitStart < oitEnd){
          int oitMid = (oitStart + oitEnd) >> 1;
          uint oitDepth = imageLoad(uOITImgZBuffer, oitBufferBaseIndex + oitMid).x;
          if(
#ifdef USE_SPECIALIZATION_CONSTANTS
             ((UseReversedZ && (oitDepth > oitCurrentDepth)) ||
              ((!UseReversedZ) && (oitDepth < oitCurrentDepth)))
#else
             oitDepth
#ifdef REVERSEDZ
             > 
#else
             <
#endif
            oitCurrentDepth
#endif
            ){
            oitStart = oitMid + 1; 
          }else{
            oitEnd = oitMid; 
          }
        }    

#ifdef MSAA
        imageAtomicOr(uOITImgSBuffer, oitBufferBaseIndex + oitStart, oitStoreMask);
#endif

        imageStore(uOITImgABuffer,
                   oitBufferBaseIndex + oitStart, 
                   uvec3(packHalf2x16(finalColor.xy), packHalf2x16(finalColor.zw), 0u).xyzz
                  );

#ifndef DEPTHONLY    
        outFragColor = vec4(0.0);
#endif

      }  

    #endif
  }else{
#ifndef DEPTHONLY    
    outFragColor = vec4(0.0);
#endif
  }

#elif defined(BLEND)

  outFragColor = vec4(clamp(finalColor.xyz * (additiveBlending ? 1.0 : finalColor.w), vec3(-65504.0), vec3(65504.0)), finalColor.w);

#endif

#endif