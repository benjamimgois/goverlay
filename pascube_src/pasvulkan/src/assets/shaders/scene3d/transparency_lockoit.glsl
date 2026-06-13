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
  uint oitDepth = floatBitsToUint(subpassLoad(uOITImgDepth, gl_SampleID).r); 
 #else
  uint oitDepth = floatBitsToUint(subpassLoad(uOITImgDepth).r); 
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
  #ifdef REVERSEDZ
            uint oitMaxDepth = 0xffffffffu;
  #else
            uint oitMaxDepth = 0;
  #endif
            for(int oitIndex = 0; oitIndex < oitCountLayers; oitIndex++){
              uint oitTestDepth = imageLoad(uOITImgABuffer, oitABufferBaseIndex + (oitIndex * oitViewSize)).z;
              if(
  #ifdef REVERSEDZ
                  (oitTestDepth < oitMaxDepth)
  #else
                  (oitTestDepth > oitMaxDepth)
  #endif
                ){
                oitMaxDepth = oitTestDepth;
                oitFurthest = oitIndex;
              }
            }

            if(
  #ifdef REVERSEDZ
              (oitMaxDepth < oitStoreValue.z)
  #else
              (oitMaxDepth > oitStoreValue.z)
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

  outFragColor = finalColor;

