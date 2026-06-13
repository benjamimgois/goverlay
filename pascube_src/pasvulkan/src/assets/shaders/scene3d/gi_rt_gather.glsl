#ifndef GI_RT_GATHER_GLSL
#define GI_RT_GATHER_GLSL

// =====================================================================================================================
//  Shared ray-traced "probe gather" layer for the ray-traced global illumination techniques (DDGI and surfel GI).
//
//  This include encapsulates the common operation that both DDGI probes and surfels need: shoot a ray into the scene,
//  find the closest hit, and compute the outgoing radiance towards the ray origin at that hit point. The radiance
//  accounts for:
//    - emissive meshes               (the hit material's emissive term)
//    - all analytic light sources    (traversal of the light BVH, identical light model as the rasterization path)
//    - ray-traced shadows            (a shadow ray per contributing light against the same TLAS)
//    - the sky / environment on miss (provided by the includer via the GI_GATHER_SKY macro)
//    - previous-frame indirect light (one-bounce feedback term, passed in by the caller for "infinite" bounces)
//
//  Prerequisites (the includer must set these up *before* including this file):
//    #define RAYTRACING
//    #define LIGHTS
//    #define USE_MATERIAL_BUFFER_REFERENCE
//    #define USE_BUFFER_REFERENCE
//    #include "globaldescriptorset.glsl"   // -> TLAS (binding 8), uRaytracingData (9), uMaterials (5), lights[] (1),
//                                          //    lightTreeNodes[] (2), u2DTextures (10)
//    #include "raytracing.glsl"            // -> ray query helpers, raytracingTextureFetch, raytracingOffsetRay, ...
//
//  Optional configuration defines (sensible defaults below):
//    GI_GATHER_TRACE_SHADOWS   1   - trace a shadow ray per light (set 0 to inject lights unshadowed, much cheaper)
//    GI_GATHER_SHADOW_TMAX     1e8 - maximum directional-light shadow ray length in meters
//    GI_GATHER_SKY(dir)        ->  vec3 expression returning the sky/environment radiance for a missed ray direction
//                                  (defaults to black; the trace passes override it to sample the sky)
//    GI_GATHER_DEFAULT_PLANET_ALBEDO  vec3(0.25) - albedo used for planet hits (planet materials are not unpacked here)
// =====================================================================================================================

#ifdef RAYTRACING

#ifndef GI_GATHER_TRACE_SHADOWS
  #define GI_GATHER_TRACE_SHADOWS 1
#endif

#ifndef GI_GATHER_SHADOW_TMAX
  #define GI_GATHER_SHADOW_TMAX 1e8
#endif

#ifndef GI_GATHER_SKY
  #define GI_GATHER_SKY(dir) vec3(0.0)
#endif

#ifndef GI_GATHER_DEFAULT_PLANET_ALBEDO
  #define GI_GATHER_DEFAULT_PLANET_ALBEDO vec3(0.25)
#endif

#ifndef GI_GATHER_OneOverPI
  #define GI_GATHER_OneOverPI 0.3183098861837907
#endif

// Result of a single gather ray: the surface that was hit (if any) together with everything needed to shade it.
struct GIGatherSurface {
  vec3 position;     // world space hit position (meters)
  vec3 normal;       // shading normal at the hit, oriented against the ray
  vec3 albedo;       // diffuse albedo (base color), linear
  vec3 emission;     // emissive radiance, linear (the FULL emissive term; the GI-only limitation is applied in giGatherShadeHit)
  float emissiveGIFactor; // per-material multiplier for the emissive term's GI contribution (1.0 = unchanged)
  float emissiveGIMax;    // per-material upper clamp for the emissive term's GI contribution (+Inf = unbounded)
  float hitDistance; // distance from ray origin to hit; negative when the ray missed
  bool hit;          // true when the ray hit geometry, false on a sky/environment miss
  bool backface;     // true when the ray hit the back side of the surface (shading normal pointed along the ray before
                     // it was flipped) — i.e. the ray origin is behind/inside this surface. Used by the DDGI trace to
                     // treat such hits as occluders (shortened distance) and absorptive (black), preventing leaks.
  bool doubleSided;  // true when the hit material is double-sided (face culling == None). A "backface" of a double-sided
                     // surface (foliage, thin sheets) is a legitimate surface, not geometry the probe is embedded in.
};

// ---------------------------------------------------------------------------------------------------------------------
//  Closest-hit query with material extraction.
//
//  Mirrors tracePrimaryBasicGeometryRay() from raytracing.glsl for the geometry part, but additionally unpacks the hit
//  material so we can shade it (base color + emissive). It runs the alpha-handling proceed loop so cut-out / blended
//  geometry behaves the same as in the rasterization path.
// ---------------------------------------------------------------------------------------------------------------------

// Planet surface albedo for the ray-traced gather.
//
// All planet geometry/material data comes through the PlanetData buffer reference (BDA) and the global bindless texture
// array (u2DTextures). The material LAYER WEIGHTS, however, live in the per-planet blend map (a 2-layer octahedral 2D
// array) and grass map - which are not in the global texture array. When GI_GATHER_PLANET_TEXTURES is enabled, those
// maps are provided bindlessly via a dedicated descriptor set, indexed by the planet object index (== the same index
// used to fetch PlanetData), and we reproduce the planet render pass' material blend (up to 8 weighted layers + default
// ground + grass). Without that define we fall back to the default ground material (materials[15]) only.
#ifdef GI_GATHER_PLANET_TEXTURES
  #ifndef GI_GATHER_PLANET_TEXTURES_SET
    #define GI_GATHER_PLANET_TEXTURES_SET 2
  #endif
  layout(set = GI_GATHER_PLANET_TEXTURES_SET, binding = 0) uniform sampler2DArray uGIPlanetBlendMaps[]; // per planet, 2 layers = 8 material layer weights
  layout(set = GI_GATHER_PLANET_TEXTURES_SET, binding = 1) uniform sampler2D uGIPlanetGrassMaps[];      // per planet, grass coverage
#endif

// Triplanar albedo of a single planet material: three axis-projected taps from the global bindless texture array at
// LOD 0, weighted by the (already normalized) triplanar blend weights.
vec3 giPlanetMaterialAlbedo(const in PlanetMaterial material, const in vec3 triplanarPosition, const in vec3 weights){
  float scale = abs(GetPlanetMaterialScale(material)); // a negative scale selects the raster anti-tiling path; magnitude is what matters for the LOD0 sample
  uint albedoTextureIndex = (GetPlanetMaterialAlbedoTextureIndex(material) << 1u) | 1u; // | 1 selects the sRGB texture view variant
  vec3 p = triplanarPosition * scale;
  return (textureLod(u2DTextures[nonuniformEXT(albedoTextureIndex)], p.yz, 0.0).xyz * weights.x) +
         (textureLod(u2DTextures[nonuniformEXT(albedoTextureIndex)], p.zx, 0.0).xyz * weights.y) +
         (textureLod(u2DTextures[nonuniformEXT(albedoTextureIndex)], p.xy, 0.0).xyz * weights.z);
}

vec3 giPlanetAlbedo(const in PlanetData planetData, const in uint planetIndex, const in vec3 objectPosition, const in vec3 objectNormal){
  vec3 triplanarPosition = (planetData.triplanarMatrix * vec4(objectPosition, 1.0)).xyz;
  vec3 triplanarNormal = normalize((planetData.triplanarNormalMatrix * vec4(objectNormal, 0.0)).xyz);
  vec3 weights = pow(abs(triplanarNormal), vec3(6.0));
  weights /= max((weights.x + weights.y) + weights.z, 1e-6);

#ifdef GI_GATHER_PLANET_TEXTURES

  // Octahedral sphere normal = the object-space (sphere) position direction, exactly as the planet shaders address the maps.
  vec3 sphereNormal = normalize(objectPosition);
  mat2x4 layerWeights = mat2x4(
    texturePlanetOctahedralMapArray(uGIPlanetBlendMaps[nonuniformEXT(planetIndex)], sphereNormal, 0),
    texturePlanetOctahedralMapArray(uGIPlanetBlendMaps[nonuniformEXT(planetIndex)], sphereNormal, 1)
  );
  float grass = clamp(texturePlanetOctahedralMap(uGIPlanetGrassMaps[nonuniformEXT(planetIndex)], sphereNormal).x, 0.0, 1.0);

  // Mirror the planet render pass blend: up to 8 weighted material layers, then the default ground material fills the
  // remaining weight, then the grass material is overlaid. (Albedo only - GI does not need normal/roughness/occlusion.)
  vec3 albedo = vec3(0.0);
  float weightSum = 0.0;
  for(int top = 0; top < 2; top++){
    vec4 w4 = layerWeights[top];
    for(int bot = 0; bot < 4; bot++){
      float weight = w4[bot];
      if(weight > 0.0){
        albedo += giPlanetMaterialAlbedo(planetData.materials[(top << 2) | bot], triplanarPosition, weights) * weight;
        weightSum += weight;
      }
    }
  }
  float defaultWeight = clamp(1.0 - weightSum, 0.0, 1.0);
  if(defaultWeight > 0.0){
    albedo += giPlanetMaterialAlbedo(planetData.materials[15], triplanarPosition, weights) * defaultWeight;
    weightSum += defaultWeight;
  }
  if(grass > 0.0){
    if(weightSum > 0.0){
      albedo *= 1.0 / max(1e-7, weightSum);
      weightSum = 1.0;
    }
    float f = pow(1.0 - grass, 16.0);
    albedo *= f;
    weightSum *= f;
    albedo += giPlanetMaterialAlbedo(planetData.materials[14], triplanarPosition, weights) * grass;
    weightSum += grass;
  }
  return (weightSum > 0.0) ? (albedo / weightSum) : vec3(0.0);

#else

  // No per-planet maps available: just the default ground material.
  return giPlanetMaterialAlbedo(planetData.materials[15], triplanarPosition, weights);

#endif
}

GIGatherSurface giGatherClosestHit(const in vec3 origin, const in vec3 direction, const in float tMin, const in float tMax, const in uint cullMask){

  GIGatherSurface s;
  s.position = origin + (direction * tMax);
  s.normal = -direction;
  s.albedo = vec3(0.0);
  s.emission = vec3(0.0);
  s.emissiveGIFactor = 1.0;                       // default: emissive contributes to GI unchanged
  s.emissiveGIMax = uintBitsToFloat(0x7f800000u); // default: +Inf -> unbounded (no clamp)
  s.hitDistance = -1.0;
  s.hit = false;
  s.backface = false;
  s.doubleSided = false;

  rayQueryEXT rayQuery;
  rayQueryInitializeEXT(rayQuery, uRaytracingTopLevelAccelerationStructure, 0u, cullMask, origin, tMin, direction, tMax);

  float temporaryAlpha;
  rayProceedEXTAlphaHandlingBasedLoop(rayQuery, true, temporaryAlpha);

  if(rayQueryGetIntersectionTypeEXT(rayQuery, true) != gl_RayQueryCommittedIntersectionTriangleEXT){
    rayQueryTerminateEXT(rayQuery);
    return s; // miss
  }

  s.hit = true;
  s.hitDistance = rayQueryGetIntersectionTEXT(rayQuery, true);

  int geometryID = rayQueryGetIntersectionGeometryIndexEXT(rayQuery, true);

  int geometryInstanceOffset = rayQueryGetIntersectionInstanceCustomIndexEXT(rayQuery, true);
  if((geometryInstanceOffset & 0x00800000) != 0){
    const int instanceID = rayQueryGetIntersectionInstanceIdEXT(rayQuery, true);
    geometryInstanceOffset = int(uRaytracingData.geometryInstanceOffsets.geometryInstanceOffsets[instanceID]);
  }

  RaytracingGeometryItem geometryItem = uRaytracingData.geometryItems.geometryItems[geometryInstanceOffset + geometryID];

  int primitiveID = rayQueryGetIntersectionPrimitiveIndexEXT(rayQuery, true);

  vec3 barycentrics = vec3(0.0, rayQueryGetIntersectionBarycentricsEXT(rayQuery, true));
  barycentrics.x = 1.0 - (barycentrics.y + barycentrics.z);

  uint indexOffset = geometryItem.indexOffset + (uint(primitiveID) * 3u);

  switch(geometryItem.objectType){

    case 0u:{ // Mesh

      uvec3 indices = uvec3(
        uRaytracingData.meshIndices.meshIndices[indexOffset + 0u],
        uRaytracingData.meshIndices.meshIndices[indexOffset + 1u],
        uRaytracingData.meshIndices.meshIndices[indexOffset + 2u]
      );

      uvec4 vertexPositionNormalXYArray[3] = uvec4[3](
        uRaytracingData.meshDynamicVertices.meshDynamicVertices[indices.x].positionNormalXY,
        uRaytracingData.meshDynamicVertices.meshDynamicVertices[indices.y].positionNormalXY,
        uRaytracingData.meshDynamicVertices.meshDynamicVertices[indices.z].positionNormalXY
      );

      vec3 vertexPositionArray[3] = vec3[3](
        uintBitsToFloat(vertexPositionNormalXYArray[0].xyz),
        uintBitsToFloat(vertexPositionNormalXYArray[1].xyz),
        uintBitsToFloat(vertexPositionNormalXYArray[2].xyz)
      );

      vec3 vertexNormalArray[3] = vec3[3](
        normalize(vec3(unpackSnorm2x16(vertexPositionNormalXYArray[0].w), unpackSnorm2x16(uRaytracingData.meshDynamicVertices.meshDynamicVertices[indices.x].normalZSignTangentXYZModelScaleXYZ.x).x)),
        normalize(vec3(unpackSnorm2x16(vertexPositionNormalXYArray[1].w), unpackSnorm2x16(uRaytracingData.meshDynamicVertices.meshDynamicVertices[indices.y].normalZSignTangentXYZModelScaleXYZ.x).x)),
        normalize(vec3(unpackSnorm2x16(vertexPositionNormalXYArray[2].w), unpackSnorm2x16(uRaytracingData.meshDynamicVertices.meshDynamicVertices[indices.z].normalZSignTangentXYZModelScaleXYZ.x).x))
      );

      s.position = (barycentrics.x * vertexPositionArray[0]) + (barycentrics.y * vertexPositionArray[1]) + (barycentrics.z * vertexPositionArray[2]);
      s.normal = normalize((barycentrics.x * vertexNormalArray[0]) + (barycentrics.y * vertexNormalArray[1]) + (barycentrics.z * vertexNormalArray[2]));
      s.backface = dot(s.normal, direction) > 0.0; // ray hit the back side -> origin is behind this surface
      if(s.backface){
        s.normal = -s.normal;
      }

      vec4 vertexTexCoordsArray[3] = vec4[3](
        uRaytracingData.meshStaticVertices.meshStaticVertices[indices.x].texCoords,
        uRaytracingData.meshStaticVertices.meshStaticVertices[indices.y].texCoords,
        uRaytracingData.meshStaticVertices.meshStaticVertices[indices.z].texCoords
      );

      vec4 vertexColorArray[3] = vec4[3](
        vec4(unpackHalf2x16(uRaytracingData.meshStaticVertices.meshStaticVertices[indices.x].color0MaterialID.x), unpackHalf2x16(uRaytracingData.meshStaticVertices.meshStaticVertices[indices.x].color0MaterialID.y)),
        vec4(unpackHalf2x16(uRaytracingData.meshStaticVertices.meshStaticVertices[indices.y].color0MaterialID.x), unpackHalf2x16(uRaytracingData.meshStaticVertices.meshStaticVertices[indices.y].color0MaterialID.y)),
        vec4(unpackHalf2x16(uRaytracingData.meshStaticVertices.meshStaticVertices[indices.z].color0MaterialID.x), unpackHalf2x16(uRaytracingData.meshStaticVertices.meshStaticVertices[indices.z].color0MaterialID.y))
      );

      vec4 vertexTexCoords = (barycentrics.x * vertexTexCoordsArray[0]) + (barycentrics.y * vertexTexCoordsArray[1]) + (barycentrics.z * vertexTexCoordsArray[2]);
      vec4 vertexColor = (barycentrics.x * vertexColorArray[0]) + (barycentrics.y * vertexColorArray[1]) + (barycentrics.z * vertexColorArray[2]);
      vec2 texCoords[2] = vec2[2]( vertexTexCoords.xy, vertexTexCoords.zw );

      Material material = uMaterials.materials[geometryItem.materialIndex];

      // Double-sided when the material's face-culling mode is None (flags bits 4..5 == 0; see TpvScene3D.EncodeModeFlags).
      s.doubleSided = (((material.alphaCutOffFlagsTex0Tex1.y >> 4u) & 3u) == 0u);

      // glTF double-sided semantics: a back-facing hit on a double-sided material is shaded as a FRONT face with the normal
      // flipped toward the ray (the flip already happened above). So it is not a "behind/inside geometry" backface — clear the
      // flag, and the whole downstream GI path (radiance gather, ray-data distance encode, relocation/classification backface
      // count, irradiance blend) then treats it exactly like any front-face hit. Single-sided backfaces keep backface == true.
      if(s.doubleSided){
        s.backface = false;
      }

      // Base color (texture index 0, sRGB) modulated by the base color factor and vertex color.
      s.albedo = raytracingTextureFetch(material, 0, vec4(1.0), true, texCoords).xyz * material.baseColorFactor.xyz * vertexColor.xyz;

      // Emissive (texture index 4, sRGB) modulated by the emissive factor (xyz) and strength (w) and vertex color.
      s.emission = raytracingTextureFetch(material, 4, vec4(1.0), true, texCoords).xyz * material.emissiveFactor.xyz * material.emissiveFactor.w * vertexColor.xyz;

      // Per-material GI emissive limitation (PASVULKAN_materials_emissive_gi): two fp16 packed into the .w of the
      // dispersion/shadow-mask uvec4 (the formerly-"Unused" slot). x = factor, y = max. Applied GI-only in giGatherShadeHit.
      vec2 emissiveGI = unpackHalf2x16(material.dispersionShadowCastMaskShadowReceiveMaskUnused.w);
      s.emissiveGIFactor = emissiveGI.x;
      s.emissiveGIMax = emissiveGI.y;

      break;

    }

    case 2u:{ // Planet. Geometry and the default-ground material albedo are unpacked from the planet data buffer reference (BDA).

      mat4x3 objectToWorld = rayQueryGetIntersectionObjectToWorldEXT(rayQuery, true);

      ReferencedPlanetDataArray referencedPlanetDataArray = uRaytracingData.referencedPlanetDataArray;
      PlanetData planetData = referencedPlanetDataArray.planetData[geometryItem.objectIndex];
      RaytracingPlanetVertices raytracingPlanetVertices = RaytracingPlanetVertices(uvec2(planetData.verticesIndices.xy));
      RaytracingPlanetIndices raytracingPlanetIndices = RaytracingPlanetIndices(uvec2(planetData.verticesIndices.zw));

      uvec3 indices = uvec3(
        raytracingPlanetIndices.planetIndices[indexOffset + 0u],
        raytracingPlanetIndices.planetIndices[indexOffset + 1u],
        raytracingPlanetIndices.planetIndices[indexOffset + 2u]
      );

      // Object (sphere) space positions/normals - kept in object space because the triplanar material projection is
      // defined in that space (planetData.triplanarMatrix), just like the planet vertex shader does it.
      vec3 objectPositionArray[3] = vec3[3](
        uintBitsToFloat(raytracingPlanetVertices.planetVertices[indices.x].xyz),
        uintBitsToFloat(raytracingPlanetVertices.planetVertices[indices.y].xyz),
        uintBitsToFloat(raytracingPlanetVertices.planetVertices[indices.z].xyz)
      );

      vec3 objectNormalArray[3] = vec3[3](
        octSignedDecode(unpackSnorm2x16(raytracingPlanetVertices.planetVertices[indices.x].w)),
        octSignedDecode(unpackSnorm2x16(raytracingPlanetVertices.planetVertices[indices.y].w)),
        octSignedDecode(unpackSnorm2x16(raytracingPlanetVertices.planetVertices[indices.z].w))
      );

      vec3 objectPosition = (barycentrics.x * objectPositionArray[0]) + (barycentrics.y * objectPositionArray[1]) + (barycentrics.z * objectPositionArray[2]);
      vec3 objectNormal = normalize((barycentrics.x * objectNormalArray[0]) + (barycentrics.y * objectNormalArray[1]) + (barycentrics.z * objectNormalArray[2]));

      s.position = objectToWorld * vec4(objectPosition, 1.0);
      s.normal = normalize(objectToWorld * vec4(objectNormal, 0.0));
      s.backface = dot(s.normal, direction) > 0.0; // ray hit the back side -> origin is behind this surface
      if(s.backface){
        s.normal = -s.normal;
      }

      s.albedo = giPlanetAlbedo(planetData, geometryItem.objectIndex, objectPosition, objectNormal);
      s.emission = vec3(0.0);

      break;

    }

    default:{ // Particles and anything else: treat as a faintly lit facing surface so it does not punch a hole in the GI.
      s.position = origin + (direction * s.hitDistance);
      s.normal = -direction;
      s.albedo = vec3(0.0);
      s.emission = vec3(0.0);
      break;
    }

  }

  rayQueryTerminateEXT(rayQuery);

  return s;
}

// ---------------------------------------------------------------------------------------------------------------------
//  Lambertian contribution of a single light at a gather hit, with an optional ray-traced shadow. This mirrors the
//  light model used by the voxel cone tracing radiance transfer (voxelEvaluateLight) so the indirect light matches the
//  direct lighting, but resolves visibility with an actual shadow ray instead of a shadow map.
// ---------------------------------------------------------------------------------------------------------------------
vec3 giGatherEvaluateLight(const in Light light, const in vec3 worldPosition, const in vec3 normal){
  uint lightType = light.metaData.x & 0x0000000fu;
  vec3 pointToLightVector;
  vec3 pointToLightDirection;
  float shadowTMax;
  if((lightType == 1u) || (lightType == 4u)){ // Directional / primary directional (sun)
    pointToLightDirection = normalize(-light.directionRange.xyz);
    pointToLightVector = pointToLightDirection * float(GI_GATHER_SHADOW_TMAX);
    shadowTMax = float(GI_GATHER_SHADOW_TMAX);
  }else{ // Point, spot, view directional
    pointToLightVector = light.positionRadius.xyz - worldPosition;
    pointToLightDirection = normalize(pointToLightVector);
    shadowTMax = length(pointToLightVector);
  }

  float NdotL = clamp(dot(normal, pointToLightDirection), 0.0, 1.0);
  if(NdotL <= 0.0){
    return vec3(0.0);
  }

  float attenuation = 1.0;
  if(lightType == 3u){ // Spot cone angular attenuation
    float angularAttenuation = clamp(fma(dot(normalize(light.directionRange.xyz), -pointToLightDirection), uintBitsToFloat(light.metaData.z), uintBitsToFloat(light.metaData.w)), 0.0, 1.0);
    attenuation *= angularAttenuation * angularAttenuation;
  }
  if((lightType == 2u) || (lightType == 3u) || (lightType == 5u)){ // Distance attenuation for positional lights
    if(light.directionRange.w >= 0.0){
      float currentDistance = length(pointToLightVector);
      if(currentDistance > 0.0){
        attenuation *= 1.0 / (currentDistance * currentDistance);
        if(light.directionRange.w > 0.0){
          float distanceByRange = currentDistance / light.directionRange.w;
          distanceByRange *= distanceByRange;
          attenuation *= clamp(1.0 - (distanceByRange * distanceByRange), 0.0, 1.0);
        }
      }
    }
  }
  if(attenuation <= 0.0){
    return vec3(0.0);
  }

  float shadow = 1.0;
#if GI_GATHER_TRACE_SHADOWS
  shadow = getRaytracedFastHardShadow(worldPosition, normal, pointToLightDirection, uintBitsToFloat(0x00000001u), shadowTMax);
#endif

  return (light.colorIntensity.xyz * light.colorIntensity.w) * (NdotL * attenuation * shadow);
}

// Accumulate direct lighting at a gather hit by traversing the light BVH (same traversal as voxelEvaluateLighting).
vec3 giGatherEvaluateLighting(const in vec3 worldPosition, const in vec3 normal){
  vec3 result = vec3(0.0);
  uint lightTreeNodeCount = lightTreeNodes[0].aabbMinSkipCount.w;
  uint lightTreeNodeIndex = 0u;
  while(lightTreeNodeIndex < lightTreeNodeCount){
    LightTreeNode lightTreeNode = lightTreeNodes[lightTreeNodeIndex];
    vec3 aabbMin = uintBitsToFloat(lightTreeNode.aabbMinSkipCount.xyz);
    vec3 aabbMax = uintBitsToFloat(lightTreeNode.aabbMaxUserData.xyz);
    if(all(greaterThanEqual(worldPosition, aabbMin)) && all(lessThanEqual(worldPosition, aabbMax))){
      if(lightTreeNode.aabbMaxUserData.w != 0xffffffffu){
        result += giGatherEvaluateLight(lights[lightTreeNode.aabbMaxUserData.w], worldPosition, normal);
      }
      lightTreeNodeIndex++;
    }else{
      lightTreeNodeIndex += max(1u, lightTreeNode.aabbMinSkipCount.w);
    }
  }
  return result;
}

// ---------------------------------------------------------------------------------------------------------------------
//  Outgoing radiance towards the ray origin at a gather hit.
//    Lo = emission + (albedo / PI) * (directLight + previousFrameIndirect)
//  previousFrameIndirect is the irradiance that the caller sampled from the *previous* frame's GI data structure at the
//  hit point (probe field for DDGI, hash grid for surfels). Passing it in here gives multi-bounce ("infinite bounce")
//  lighting almost for free; pass vec3(0.0) to disable it.
// ---------------------------------------------------------------------------------------------------------------------

// Global GI-emissive master regulators: a renderer-wide scale (multiplies the per-material factor) and an absolute cap
// (min'd with the per-material max). Each GI producer supplies them from its own source (DDGI: ddgiData; surfels: push
// constants) by #defining these before including this file; they default to a no-op (scale 1.0, +Inf cap).
#ifndef GI_GATHER_EMISSIVE_SCALE
#define GI_GATHER_EMISSIVE_SCALE 1.0
#endif
#ifndef GI_GATHER_EMISSIVE_MAX
#define GI_GATHER_EMISSIVE_MAX uintBitsToFloat(0x7f800000u)
#endif

vec3 giGatherShadeHit(const in GIGatherSurface surface, const in vec3 previousFrameIndirect){
  vec3 directLight = giGatherEvaluateLighting(surface.position, surface.normal);
  // GI-only emissive limitation: scale the full emissive term by (per-material factor * global scale), then clamp to
  // min(per-material max, global cap). With the defaults (1.0 / +Inf) this reduces exactly to the unmodified emission.
  vec3 limitedEmission = min(surface.emission * (surface.emissiveGIFactor * float(GI_GATHER_EMISSIVE_SCALE)),
                             vec3(min(surface.emissiveGIMax, float(GI_GATHER_EMISSIVE_MAX))));
  return limitedEmission + (surface.albedo * float(GI_GATHER_OneOverPI) * (directLight + previousFrameIndirect));
}

// Convenience: trace one gather ray and return its radiance, sampling the sky on a miss. previousFrameIndirect is only
// applied at geometry hits.
vec3 giGatherTraceRadiance(const in vec3 origin, const in vec3 direction, const in float tMin, const in float tMax, const in uint cullMask, const in vec3 previousFrameIndirect, out float hitDistance){
  GIGatherSurface surface = giGatherClosestHit(origin, direction, tMin, tMax, cullMask);
  hitDistance = surface.hitDistance;
  if(!surface.hit){
    return GI_GATHER_SKY(direction);
  }
  return giGatherShadeHit(surface, previousFrameIndirect);
}

// ---------------------------------------------------------------------------------------------------------------------
//  Swappable closest-hit trace backend. The trace producers (DDGI / surfel) call giTraceClosestHit() instead of a fixed
//  implementation, so the ray-vs-scene query can be swapped at compile time. The default is the hardware ray-query
//  backend (giGatherClosestHit, above); a future SDF backend would #define GI_TRACE_BACKEND = GI_TRACE_BACKEND_SDF and
//  provide its own giTraceClosestHit returning a GIGatherSurface. (A ray-generation/closest-hit RT-pipeline producer is a
//  different shader stage and lives in its own pass; it produces the same ray-data and needs no backend macro here.)
// ---------------------------------------------------------------------------------------------------------------------
#define GI_TRACE_BACKEND_RAYQUERY 0
#define GI_TRACE_BACKEND_SDF      1
#ifndef GI_TRACE_BACKEND
  #define GI_TRACE_BACKEND GI_TRACE_BACKEND_RAYQUERY
#endif
#if GI_TRACE_BACKEND == GI_TRACE_BACKEND_RAYQUERY
GIGatherSurface giTraceClosestHit(const in vec3 origin, const in vec3 direction, const in float tMin, const in float tMax, const in uint cullMask){
  return giGatherClosestHit(origin, direction, tMin, tMax, cullMask);
}
#endif

#endif // RAYTRACING

#endif // GI_RT_GATHER_GLSL
