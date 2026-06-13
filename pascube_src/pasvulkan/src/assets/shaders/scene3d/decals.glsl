#ifndef DECALS_GLSL
#define DECALS_GLSL

#ifdef LIGHTS

const uint DECAL_FLAG_MODE_MASK = (1u << 4) - 1;
const uint DECAL_FLAG_PASS_MESH = 1u << 4;
const uint DECAL_FLAG_PASS_PLANET = 1u << 5;
const uint DECAL_FLAG_PASS_GRASS = 1u << 6;
const uint DECAL_FLAG_DEBUG_DECAL = 1u << 30;
const uint DECAL_FLAG_DEBUG_CULL = 1u << 31;

#if defined(MESH_PASS) || defined(MESH_FRAGMENT_SHADER)
const uint DECAL_FLAG_PASS = DECAL_FLAG_PASS_MESH;
#elif defined(PLANET_PASS) || defined(PLANET_RENDERPASS_FRAGMENT_SHADER)
const uint DECAL_FLAG_PASS = DECAL_FLAG_PASS_PLANET;
#elif defined(GRASS_PASS) || defined(PLANET_GRASS_FRAGMENT_SHADER)
const uint DECAL_FLAG_PASS = DECAL_FLAG_PASS_GRASS;
#else
// Just match all in this case when no specific pass is defined
const uint DECAL_FLAG_PASS = DECAL_FLAG_PASS_MESH | DECAL_FLAG_PASS_PLANET | DECAL_FLAG_PASS_GRASS;
#endif

#include "blendnormals.glsl"

// Overlay blend mode
vec3 decalOverlayBlend(vec3 base, vec3 blend) {
  return mix(2.0 * base * blend, 1.0 - (2.0 * ((1.0 - base) * (1.0 - blend))), step(0.5, base));
}

// Apply decals to material properties - Full PBR workflow
void applyDecals(
  inout vec4 baseColor,           // RGBA - albedo + alpha
  inout float metallic,           // Metallic value
  inout float perceptualRoughness,// Roughness value
  inout float occlusion,          // Ambient occlusion
  inout vec3 F0Dielectric,        // Base reflectance for dielectrics
  inout vec3 F90Dielectric,       // Grazing angle reflectance
  inout float specularWeight,     // Specular intensity
  inout vec3 decalNormal,           // Output: accumulated decal normal in tangent space
  inout float decalNormalBlend,     // Output: blend factor for decal normal (0 = no decal normals)
  in vec3 worldPosition,
  in vec3 worldNormal,
  in vec3 viewSpacePosition,
  in vec3 baseIORF0Dielectric    // Base IOR-derived F0 for neutral specular calculation
) {
  
#if defined(LIGHTCLUSTERS)
  // ===========================================================================
  // CLUSTER-BASED DECAL LOOKUP (EXACT SAME pattern as lighting.glsl)
  // ===========================================================================
  
  // Decal cluster grid (reuses same cluster calculation as lights)
  uvec3 clusterXYZ = uvec3(uvec2(uvec2(gl_FragCoord.xy) / uFrustumClusterGridGlobals.tileSizeZNearZFar.xy), 
                           uint(clamp(fma(log2(-viewSpacePosition.z), uFrustumClusterGridGlobals.scaleBiasMax.x, uFrustumClusterGridGlobals.scaleBiasMax.y), 0.0, uFrustumClusterGridGlobals.scaleBiasMax.z)));
  uint clusterIndex = clamp((((clusterXYZ.z * uFrustumClusterGridGlobals.clusterSize.y) + clusterXYZ.y) * uFrustumClusterGridGlobals.clusterSize.x) + clusterXYZ.x, 0u, uFrustumClusterGridGlobals.countLightsViewIndexSizeOffsetedViewIndex.z) +
                      (uint(gl_ViewIndex + uFrustumClusterGridGlobals.countLightsViewIndexSizeOffsetedViewIndex.w) * uFrustumClusterGridGlobals.countLightsViewIndexSizeOffsetedViewIndex.z);
  uvec2 clusterDecalData = frustumClusterGridData[clusterIndex].zw; // z = offset, w = count (and ignore light data for now)
  for(uint clusterDecalIndex = clusterDecalData.x, clusterCountDecals = clusterDecalData.y; clusterCountDecals > 0u; clusterDecalIndex++, clusterCountDecals--){
    {
      {
        Decal decal = decals[frustumClusterGridIndexList[clusterDecalIndex]];
#else
  // ===========================================================================
  // BVH/SKIP-TREE DECAL LOOKUP (EXACT SAME pattern as lighting.glsl)
  // ===========================================================================
  
  // Decal BVH
  uint decalTreeNodeIndex = 0;
  uint decalTreeNodeCount = decalTreeNodes[0].aabbMinSkipCount.w;
  while (decalTreeNodeIndex < decalTreeNodeCount) {
    DecalTreeNode decalTreeNode = decalTreeNodes[decalTreeNodeIndex];
    vec3 aabbMin = vec3(uintBitsToFloat(uvec3(decalTreeNode.aabbMinSkipCount.xyz)));
    vec3 aabbMax = vec3(uintBitsToFloat(uvec3(decalTreeNode.aabbMaxUserData.xyz)));
    if (all(greaterThanEqual(worldPosition, aabbMin)) && all(lessThanEqual(worldPosition, aabbMax))) {
      if (decalTreeNode.aabbMaxUserData.w != 0xffffffffu) {
        Decal decal = decals[decalTreeNode.aabbMaxUserData.w];
#endif
        
        // Get decal flags for this rendering pass
        const uint decalFlags = decal.decalUpFlags.w;

        // Check if decal applies to this rendering pass
        if ((decalFlags & DECAL_FLAG_PASS) != 0u) {          

          // Construct world to decal matrix from three vec4 and transpose for correct multiplication with world position.
          // Also allows us to keep decal data as vec4 arrays which are more compatible with buffer references.
//        mat4 worldToDecalMatrix = transpose(mat4(decal.matrix0, decal.matrix1, decal.matrix2, vec4(0.0, 0.0, 0.0, 1.0)));
          mat4 worldToDecalMatrix = mat4(
            decal.matrix0.x, decal.matrix1.x, decal.matrix2.x, 0.0,
            decal.matrix0.y, decal.matrix1.y, decal.matrix2.y, 0.0,
            decal.matrix0.z, decal.matrix1.z, decal.matrix2.z, 0.0,
            decal.matrix0.w, decal.matrix1.w, decal.matrix2.w, 1.0
          );
                    
          // Project world position into decal OBB space
          vec3 decalSpacePos = (worldToDecalMatrix * vec4(worldPosition, 1.0)).xyz;
          
          // Check if fragment is inside decal box (OBB bounds: -0.5 to 0.5)
          if(all(greaterThan(decalSpacePos, vec3(-0.5))) && all(lessThan(decalSpacePos, vec3(0.5)))) {
            
            // Calculate UVs [0,1]
            vec2 decalUV = fma(decalSpacePos.xz + vec2(0.5), decal.uvScaleOffset.xy, decal.uvScaleOffset.zw);
            
            // Edge fade (soft edges at decal boundaries)
            vec2 edgeDist = min(decalUV, vec2(1.0) - decalUV) * 2.0;
            float edgeFade = smoothstep(0.0, uintBitsToFloat(decal.blendParams.z), min(edgeDist.x, edgeDist.y));
            
            // Angle fade (fade based on surface orientation vs decal up)
            float angleFade = clamp(dot(normalize(worldNormal), normalize(uintBitsToFloat(decal.decalUpFlags.xyz))), 0.0, 1.0);
            angleFade = pow(angleFade, uintBitsToFloat(decal.blendParams.y));
            
            // Sample decal textures from unified u2DTextures array
            vec4 decalAlbedo = (decal.textureIndices.x >= 0) ? texture(u2DTextures[nonuniformEXT((decal.textureIndices.x & 0x3fff) << 1) | 1], decalUV) : vec4(1.0); // sRGB
            vec3 decalNormalTangentSpace = (decal.textureIndices.y >= 0) ? (texture(u2DTextures[nonuniformEXT((decal.textureIndices.y & 0x3fff) << 1)], decalUV).xyz * 2.0 - 1.0) : vec3(0.0, 0.0, 1.0); // linear
            vec3 decalORM = (decal.textureIndices.z >= 0) ? texture(u2DTextures[nonuniformEXT((decal.textureIndices.z & 0x3fff) << 1)], decalUV).xyz : vec3(1.0); // linear
            vec4 decalSpecular = (decal.textureIndices.w >= 0) ? texture(u2DTextures[nonuniformEXT((decal.textureIndices.w & 0x3fff) << 1)], decalUV) : vec4(1.0, 1.0, 1.0, 1.0); // linear
            vec3 decalEmissive = (decal.textureIndices2.x >= 0) ? texture(u2DTextures[nonuniformEXT((decal.textureIndices2.x & 0x3fff) << 1) | 1], decalUV).xyz : vec3(0.0); // sRGB
            
            // Extract ORM components
            float decalOcclusion = decalORM.x;
            float decalRoughness = decalORM.y;
            float decalMetallic = decalORM.z;
            
            // Extract specular components
            vec3 decalSpecularColorFactor = decalSpecular.xyz;
            float decalSpecularWeight = decalSpecular.w;
            
            // Calculate decal's Fresnel properties
            vec3 decalF0Dielectric = min(baseIORF0Dielectric * decalSpecularColorFactor, vec3(1.0));
            vec3 decalF90Dielectric = vec3(decalSpecularWeight);
            
            // Combined blend factor
            float blend = decalAlbedo.w * uintBitsToFloat(decal.blendParams.x) * angleFade * edgeFade;
            
            // Apply blend mode
            uint blendMode = decalFlags & DECAL_FLAG_MODE_MASK;
            float pbrBlendFactor = uintBitsToFloat(decal.blendParams.w);
            switch(blendMode) {
              case 0u: {  // Alpha blend (standard)
                baseColor.xyz = mix(baseColor.xyz, decalAlbedo.xyz, blend);
                metallic = mix(metallic, decalMetallic, blend * pbrBlendFactor);
                perceptualRoughness = mix(perceptualRoughness, decalRoughness, blend * pbrBlendFactor);
                occlusion = mix(occlusion, decalOcclusion, blend);
                F0Dielectric = mix(F0Dielectric, decalF0Dielectric, blend);
                F90Dielectric = mix(F90Dielectric, decalF90Dielectric, blend);
                specularWeight = mix(specularWeight, decalSpecularWeight, blend);
                break;
              }
              case 1u: {  // Multiply (dirt/grime/darkening)
                baseColor.xyz *= mix(vec3(1.0), decalAlbedo.xyz, blend);
                metallic = mix(metallic, decalMetallic, blend * pbrBlendFactor);
                perceptualRoughness = mix(perceptualRoughness, decalRoughness, blend * pbrBlendFactor);
                occlusion = mix(occlusion, decalOcclusion, blend);
                // Don't modify specular for multiply mode
                break;
              }
              case 2u: {  // Overlay (painted markings)
                baseColor.xyz = mix(baseColor.xyz, decalOverlayBlend(baseColor.xyz, decalAlbedo.xyz), blend);
                metallic = mix(metallic, decalMetallic, blend * pbrBlendFactor);
                perceptualRoughness = mix(perceptualRoughness, decalRoughness, blend * pbrBlendFactor);
                occlusion = mix(occlusion, decalOcclusion, blend);
                F0Dielectric = mix(F0Dielectric, decalF0Dielectric, blend * pbrBlendFactor);
                F90Dielectric = mix(F90Dielectric, decalF90Dielectric, blend * pbrBlendFactor);
                specularWeight = mix(specularWeight, decalSpecularWeight, blend * pbrBlendFactor);
                break;
              }
              case 3u: {  // Additive (glowing effects)
                baseColor.xyz += decalAlbedo.xyz * blend;
                // Don't modify material properties for additive
                break;
              }
              case 4u: { // Just PBR
                metallic = mix(metallic, decalMetallic, blend * pbrBlendFactor);
                perceptualRoughness = mix(perceptualRoughness, decalRoughness, blend * pbrBlendFactor);
                occlusion = mix(occlusion, decalOcclusion, blend);
                F0Dielectric = mix(F0Dielectric, decalF0Dielectric, blend * pbrBlendFactor);
                F90Dielectric = mix(F90Dielectric, decalF90Dielectric, blend * pbrBlendFactor);
                specularWeight = mix(specularWeight, decalSpecularWeight, blend * pbrBlendFactor);
                break;
              }   
              case 5u: { // Just normal map
                break;
              } 
              default: {
                // Alpha blend as fallback
                baseColor.xyz = mix(baseColor.xyz, decalAlbedo.xyz, blend);
                metallic = mix(metallic, decalMetallic, blend * pbrBlendFactor);
                perceptualRoughness = mix(perceptualRoughness, decalRoughness, blend * pbrBlendFactor);
                occlusion = mix(occlusion, decalOcclusion, blend);
                F0Dielectric = mix(F0Dielectric, decalF0Dielectric, blend * pbrBlendFactor);
                F90Dielectric = mix(F90Dielectric, decalF90Dielectric, blend * pbrBlendFactor);
                specularWeight = mix(specularWeight, decalSpecularWeight, blend * pbrBlendFactor);
                break;
              }
            }
            
            // Accumulate decal normal contribution
            decalNormal = blendNormals(decalNormal, decalNormalTangentSpace, blend);
            decalNormalBlend = 1.0 - ((1.0 - decalNormalBlend) * (1.0 - blend));

            if((decalFlags & DECAL_FLAG_DEBUG_DECAL) != 0u) {
              baseColor.x = 1.0; // DEBUG: visualize decal coverage
            }

          }

          if((decalFlags & DECAL_FLAG_DEBUG_CULL) != 0u) {
            baseColor.y = 0.0; // DEBUG: visualize decal coverage
          }

#if defined(LIGHTCLUSTERS)
        }
      }
    }
  }
#else
      }
      decalTreeNodeIndex++;
    } else {
      decalTreeNodeIndex += max(1u, decalTreeNode.aabbMinSkipCount.w);
    }
  }
#endif
}

// Simplified decal application for unlit materials
// Only applies albedo, no material properties or normals
void applyDecalsUnlit(
  inout vec3 color,               // RGB color
  in vec3 worldPosition,
  in vec3 worldNormal,
  in vec3 viewSpacePosition
) {
  
#if defined(LIGHTCLUSTERS)
  // Decal cluster grid
  uvec3 clusterXYZ = uvec3(uvec2(uvec2(gl_FragCoord.xy) / uFrustumClusterGridGlobals.tileSizeZNearZFar.xy), 
                           uint(clamp(fma(log2(-viewSpacePosition.z), uFrustumClusterGridGlobals.scaleBiasMax.x, uFrustumClusterGridGlobals.scaleBiasMax.y), 0.0, uFrustumClusterGridGlobals.scaleBiasMax.z)));
  uint clusterIndex = clamp((((clusterXYZ.z * uFrustumClusterGridGlobals.clusterSize.y) + clusterXYZ.y) * uFrustumClusterGridGlobals.clusterSize.x) + clusterXYZ.x, 0u, uFrustumClusterGridGlobals.countLightsViewIndexSizeOffsetedViewIndex.z) +
                      (uint(gl_ViewIndex + uFrustumClusterGridGlobals.countLightsViewIndexSizeOffsetedViewIndex.w) * uFrustumClusterGridGlobals.countLightsViewIndexSizeOffsetedViewIndex.z);
  uvec2 clusterDecalData = frustumClusterGridData[clusterIndex].zw;
  for(uint clusterDecalIndex = clusterDecalData.x, clusterCountDecals = clusterDecalData.y; clusterCountDecals > 0u; clusterDecalIndex++, clusterCountDecals--){
    {
      {
        Decal decal = decals[frustumClusterGridIndexList[clusterDecalIndex]];
#else
  // Decal BVH
  uint decalTreeNodeIndex = 0;
  uint decalTreeNodeCount = decalTreeNodes[0].aabbMinSkipCount.w;
  while (decalTreeNodeIndex < decalTreeNodeCount) {
    DecalTreeNode decalTreeNode = decalTreeNodes[decalTreeNodeIndex];
    vec3 aabbMin = vec3(uintBitsToFloat(uvec3(decalTreeNode.aabbMinSkipCount.xyz)));
    vec3 aabbMax = vec3(uintBitsToFloat(uvec3(decalTreeNode.aabbMaxUserData.xyz)));
    if (all(greaterThanEqual(worldPosition, aabbMin)) && all(lessThanEqual(worldPosition, aabbMax))) {
      if (decalTreeNode.aabbMaxUserData.w != 0xffffffffu) {
        Decal decal = decals[decalTreeNode.aabbMaxUserData.w];
#endif
    
        // Get decal flags for this rendering pass
        const uint decalFlags = decal.decalUpFlags.w;

        // Check if decal applies to this rendering pass
        if ((decalFlags & DECAL_FLAG_PASS) != 0u) {          

          // Construct world to decal matrix from three vec4 and transpose for correct multiplication with world position.
          // Also allows us to keep decal data as vec4 arrays which are more compatible with buffer references.
//        mat4 worldToDecalMatrix = transpose(mat4(decal.matrix0, decal.matrix1, decal.matrix2, vec4(0.0, 0.0, 0.0, 1.0)));
          mat4 worldToDecalMatrix = mat4(
            decal.matrix0.x, decal.matrix1.x, decal.matrix2.x, 0.0,
            decal.matrix0.y, decal.matrix1.y, decal.matrix2.y, 0.0,
            decal.matrix0.z, decal.matrix1.z, decal.matrix2.z, 0.0,
            decal.matrix0.w, decal.matrix1.w, decal.matrix2.w, 1.0
          );

          // Project world position into decal OBB space
          vec3 decalSpacePos = (worldToDecalMatrix * vec4(worldPosition, 1.0)).xyz;
          
          // Check if fragment is inside decal box (OBB bounds: -0.5 to 0.5)
          if(all(greaterThan(decalSpacePos, vec3(-0.5))) && all(lessThan(decalSpacePos, vec3(0.5)))) {
            
            // Calculate UVs [0,1]
            vec2 decalUV = fma(decalSpacePos.xz + vec2(0.5), decal.uvScaleOffset.xy, decal.uvScaleOffset.zw);
            
            // Edge fade (soft edges at decal boundaries)
            vec2 edgeDist = min(decalUV, vec2(1.0) - decalUV) * 2.0;
            float edgeFade = smoothstep(0.0, uintBitsToFloat(decal.blendParams.z), min(edgeDist.x, edgeDist.y));
            
            // Angle fade (fade based on surface orientation vs decal up)
            float angleFade = clamp(dot(normalize(worldNormal), normalize(uintBitsToFloat(decal.decalUpFlags.xyz))), 0.0, 1.0);
            angleFade = pow(angleFade, uintBitsToFloat(decal.blendParams.y));
            
            // Sample only albedo texture for unlit (sRGB)
            vec4 decalAlbedo = (decal.textureIndices.x >= 0) ? texture(u2DTextures[nonuniformEXT((decal.textureIndices.x & 0x3fff) << 1) | 1], decalUV) : vec4(1.0);
            
            // Combined blend factor
            float blend = decalAlbedo.w * uintBitsToFloat(decal.blendParams.x) * angleFade * edgeFade;
            
            // Apply blend mode (only color, no material properties)
            uint blendMode = decalFlags & DECAL_FLAG_MODE_MASK;
            switch(blendMode) {
              case 0u: {  // Alpha blend
                color = mix(color, decalAlbedo.xyz, blend);
                break;
              }
              case 1u: {  // Multiply
                color *= mix(vec3(1.0), decalAlbedo.xyz, blend);
                break;
              }
              case 2u: {  // Overlay
                color = mix(color, decalOverlayBlend(color, decalAlbedo.xyz), blend);
                break;
              }
              case 3u: {  // Additive
                color += decalAlbedo.xyz * blend;
                break;
              }
              case 4u: { // Just PBR
                break;
              }
              case 5u: { // Just normal map
                break;
              }
              default: {
                color = mix(color, decalAlbedo.xyz, blend);
                break;
              }
            }

            if((decalFlags & DECAL_FLAG_DEBUG_DECAL) != 0u) {
              color.x = 1.0; // DEBUG: visualize decal coverage
            }

          }

          if((decalFlags & DECAL_FLAG_DEBUG_CULL) != 0u) {
            color.y = 0.0; // DEBUG: visualize decal coverage
          }
        
        }

#if defined(LIGHTCLUSTERS)        
      }
    }
  }
#else      
      }
      decalTreeNodeIndex++;
    } else {
      decalTreeNodeIndex += max(1u, decalTreeNode.aabbMinSkipCount.w);
    }
  }
#endif
}

#endif // LIGHTS

#endif // DECALS_GLSL
