#if 0 // Old variants kept for A/B testing

// ============================================================================
// Variant 1: Simple area light sampling without adaptive early-out
// ============================================================================
#if 0
                    const int countSamples = 8;
                    
                    vec3 lightNormal = pointToLightDirection;
                    vec3 lightTangent = normalize(cross(lightNormal, getPerpendicularVector(lightNormal)));
                    vec3 lightBitangent = cross(lightNormal, lightTangent);
                    
                    float shadow = 0.0;
                    bool isDirectional = (lightType == 1u) || (lightType == 4u);
                    
                    if(isDirectional){
                      const float sunAngularRadius = 0.00465;
                      
                      for(int i = 0; i < countSamples; i++){
                        vec2 diskSample = shadowDiscRotationMatrix * BlueNoise2DDisc[(i + int(shadowDiscRandomValues.y)) & BlueNoise2DDiscMask];
                        float u1 = diskSample.x * 0.5 + 0.5;
                        float u2 = diskSample.y * 0.5 + 0.5;
                        
                        float cosMax = cos(sunAngularRadius);
                        float cosTheta = mix(1.0, cosMax, u1);
                        float sinTheta = sqrt(max(0.0, 1.0 - cosTheta * cosTheta));
                        float phi = 6.28318530718 * u2;
                        
                        vec3 sampleDirection = normalize(lightNormal * cosTheta + (lightTangent * cos(phi) + lightBitangent * sin(phi)) * sinTheta);
                        shadow += getRaytracedHardShadow(rayOrigin, rayNormal, sampleDirection, rayOffset, effectiveRayDistance);
                      }
                    }else{
                      float lightPhysicalRadius = light.positionRadius.w * 0.02;
                      float distanceToLight = length(pointToLightVector);
                      float shadowMaxDistance = min(distanceToLight, effectiveRayDistance);
                      
                      for(int i = 0; i < countSamples; i++){
                        vec2 diskSample = shadowDiscRotationMatrix * BlueNoise2DDisc[(i + int(shadowDiscRandomValues.y)) & BlueNoise2DDiscMask];
                        vec3 lightSamplePoint = light.positionRadius.xyz + (lightTangent * diskSample.x + lightBitangent * diskSample.y) * lightPhysicalRadius;
                        
                        vec3 toSample = lightSamplePoint - rayOrigin;
                        float sampleDistance = length(toSample);
                        vec3 sampleDirection = toSample / sampleDistance;
                        
                        float rayMaxDist = min(sampleDistance, shadowMaxDistance);
                        shadow += getRaytracedHardShadow(rayOrigin, rayNormal, sampleDirection, rayOffset, rayMaxDist);
                      }
                    }
                    lightAttenuation *= shadow / float(countSamples);
#endif

// ============================================================================
// Variant 2: PCSS-style blocker search (original implementation)
// ============================================================================
#if 0
                    // PCSS-style contact-hardening soft shadows with blocker search
                    // Phase 1: Blocker search - find average blocker distance
                    const int blockerSearchSamples = 8;
                    const int shadowSamples = 8;
                    
                    // Compute light angular radius based on light type
                    float lightAngularRadius;
                    switch(lightType){
                      case 1u:  // Directional
                      case 4u:  // Primary directional (sun)
                        lightAngularRadius = 0.00465; // Sun angular radius in radians (~0.267 degrees)
                        break;
                      case 2u:  // Point
                      case 3u:  // Spot
                      case 5u:  // View directional
                      default:{
                        // For local lights, estimate angular size from light's physical radius and distance
                        // Use a fraction of the influence radius as the physical emitter size
                        float lightPhysicalRadius = light.positionRadius.w * 0.02; // 2% of influence radius as emitter size
                        float distanceToLight = length(pointToLightVector);
                        lightAngularRadius = clamp(lightPhysicalRadius / max(distanceToLight, 0.001), 0.002, 0.15);
                        break;
                      }
                    }
                    
                    vec3 lightNormal = pointToLightDirection;
                    vec3 lightTangent = normalize(cross(lightNormal, getPerpendicularVector(lightNormal)));
                    vec3 lightBitangent = cross(lightNormal, lightTangent);
                    
                    // Blocker search with wide initial search radius
                    float blockerDistanceSum = 0.0;
                    float blockerCount = 0.0;
                    const float searchRadius = 0.02; // Initial wide search radius
                    
                    for(int i = 0; i < blockerSearchSamples; i++){
                      vec2 sampleXY = (shadowDiscRotationMatrix * BlueNoise2DDisc[(i + int(shadowDiscRandomValues.y)) & BlueNoise2DDiscMask]) * searchRadius;
                      vec3 sampleDirection = normalize(lightNormal + (sampleXY.x * lightTangent) + (sampleXY.y * lightBitangent));
                      
                      // Trace ray and get distance to blocker
                      rayQueryEXT blockerQuery;
                      rayQueryInitializeEXT(blockerQuery, uRaytracingTopLevelAccelerationStructure, 0u, CULLMASK_SHADOWS, 
                                            raytracingOffsetRay(rayOrigin, rayNormal, sampleDirection), rayOffset, sampleDirection, effectiveRayDistance);
                      
                      float queryResult;
                      rayProceedEXTAlphaHandlingBasedLoop(blockerQuery, false, queryResult);
                      
                      if(rayQueryGetIntersectionTypeEXT(blockerQuery, true) != gl_RayQueryCommittedIntersectionNoneEXT){
                        float hitDistance = rayQueryGetIntersectionTEXT(blockerQuery, true);
                        blockerDistanceSum += hitDistance;
                        blockerCount += 1.0;
                      }
                      rayQueryTerminateEXT(blockerQuery);
                    }
                    
                    float shadow = 1.0;
                    if(blockerCount > 0.0){
                      // Phase 2: Compute penumbra width based on blocker distance
                      float avgBlockerDistance = blockerDistanceSum / blockerCount;
                      // Penumbra width grows with distance from blocker (contact hardening)
                      // penumbraWidth = lightSize * (receiverDistance - blockerDistance) / blockerDistance
                      float receiverDistance = effectiveRayDistance; // Approximate receiver as far plane
                      float penumbraRatio = clamp((receiverDistance - avgBlockerDistance) / max(avgBlockerDistance, 0.001), 0.0, 1.0);
                      float penumbraRadius = lightAngularRadius * penumbraRatio;
                      // Clamp penumbra radius to reasonable range
                      penumbraRadius = clamp(penumbraRadius, 0.001, 0.05);
                      
                      // Phase 3: Shadow sampling with adaptive penumbra width
                      shadow = 0.0;
                      for(int i = 0; i < shadowSamples; i++){
                        vec2 sampleXY = (shadowDiscRotationMatrix * BlueNoise2DDisc[(i + int(shadowDiscRandomValues.z)) & BlueNoise2DDiscMask]) * penumbraRadius;
                        vec3 sampleDirection = normalize(lightNormal + (sampleXY.x * lightTangent) + (sampleXY.y * lightBitangent));
                        shadow += getRaytracedHardShadow(rayOrigin, rayNormal, sampleDirection, rayOffset, effectiveRayDistance);
                      }
                      shadow /= float(shadowSamples);
                    }
                    lightAttenuation *= shadow;
#endif

#endif // Old variants


                    // Soft shadow
                    const int countSamples = 8;
                    vec3 lightNormal = pointToLightDirection;
                    vec3 lightTangent = normalize(cross(lightNormal, getPerpendicularVector(lightNormal)));
                    vec3 lightBitangent = cross(lightNormal, lightTangent);
                    float shadow = 0.0;
                    for(int i = 0; i < countSamples; i++){
                      vec2 sampleXY = (shadowDiscRotationMatrix * BlueNoise2DDisc[(i + int(shadowDiscRandomValues.y)) & BlueNoise2DDiscMask]) * 1e-2;
                      vec3 sampleDirection = normalize(lightNormal + (sampleXY.x * lightTangent) + (sampleXY.y * lightBitangent));
                      shadow += getRaytracedHardShadow(rayOrigin, rayNormal, sampleDirection, rayOffset, effectiveRayDistance);
                    }
                    lightAttenuation *= shadow / float(countSamples);
