  float depth = fma((log(clamp(-inViewSpacePosition.z, uWBOIT.wboitZNearZFar.x, uWBOIT.wboitZNearZFar.y)) - uWBOIT.wboitZNearZFar.z) / (uWBOIT.wboitZNearZFar.w - uWBOIT.wboitZNearZFar.z), 2.0, -1.0); 
  float transmittance = clamp(1.0 - alpha, 1e-4, 1.0);
  if(!additiveBlending){
    finalColor.xyz *= finalColor.w;
  }
  finalColor.xyz = clamp(finalColor.xyz, vec3(-65504.0), vec3(65504.0));
  float weight = min(1.0, fma(max(max(finalColor.x, finalColor.y), max(finalColor.z, finalColor.w)), 40.0, 0.01)) * clamp(depth, 1e-2, 3e3); //clamp(0.03 / (1e-5 + pow(abs(inViewSpacePosition.z) / 200.0, 4.0)), 1e-2, 3e3);
  outFragWBOITAccumulation = clamp(finalColor * weight, vec4(-65504.0), vec4(65504.0));
  outFragWBOITRevealage = vec4(finalColor.w);

