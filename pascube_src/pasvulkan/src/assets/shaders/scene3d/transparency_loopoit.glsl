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
#ifdef REVERSEDZ
     (oitCurrentDepth >= oitDepth) &&  
#else
     (oitCurrentDepth <= oitDepth) &&  
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

#ifndef DEPTHONLY    
      outFragColor = vec4(0.0);
#endif

    #elif defined(LOOPOIT_PASS2)

      if(!additiveBlending){
        finalColor.xyz *= finalColor.w;
      }

      finalColor.xyz = clamp(finalColor.xyz, vec3(-65504.0), vec3(65504.0));

      if(
         imageLoad(uOITImgZBuffer, oitBufferBaseIndex + (oitCountLayers - 1)).x
#ifdef REVERSEDZ
         >
#else 
         <
#endif
         oitCurrentDepth
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
             oitDepth
#ifdef REVERSEDZ
             > 
#else
             <
#endif
            oitCurrentDepth
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

