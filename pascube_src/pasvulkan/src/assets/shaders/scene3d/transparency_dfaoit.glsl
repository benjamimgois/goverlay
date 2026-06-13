  int oitMultiViewIndex = int(gl_ViewIndex);
  ivec3 oitCoord = ivec3(ivec2(gl_FragCoord.xy), oitMultiViewIndex);
#ifdef WATER_FRAGMENT_SHADER
  uint oitStoreMask = 0xffffffffu; // All bits set, since it is a full-screen post-processing effect
#else
  uint oitStoreMask = uint(gl_SampleMaskIn[0]);
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
#ifdef REVERSEDZ
     (oitCurrentDepth >= oitDepth) &&
#else
     (oitCurrentDepth <= oitDepth) &&
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

  outFragColor = vec4(0.0);

