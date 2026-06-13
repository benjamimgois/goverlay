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

