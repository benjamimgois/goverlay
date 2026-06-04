#ifndef RAYTRACING_GLSL
#define RAYTRACING_GLSL

#ifdef RAYTRACING

#extension GL_EXT_ray_tracing : enable
#extension GL_EXT_ray_query : enable
#extension GL_EXT_ray_flags_primitive_culling : enable
#extension GL_EXT_buffer_reference_uvec2 : enable

// All routines in this files consider meters as units for distances and positions, keep this in mind when reading the code

#define CULLMASK_SHADOWS 0x01    // All objects that should cast shadows should have this cull mask set
#define CULLMASK_CAMERAVIEW 0x02 // All objects that should be visible in the camera view should have this cull mask set, so for example the player in first person view should not have this cull mask set, but still CULLMASK_REFLECTION for reflections and so on
#define CULLMASK_REFLECTION 0x04 // All objects that should be visible in reflections should have this cull mask set
#define CULLMASK_OCCLUSION 0x08  // All objects that should be considered for ambient occlusion as occluders should have this cull mask set
#define CULLMASK_ALL 0xff        // Just everything

#include "octahedralmap.glsl"

#include "instancedataeffect.glsl"

void raytracingCorrectSmoothNormal(inout vec3 smoothNormal, const in vec3 geometricNormal, const in vec3 worldSpacePosition, const in vec3 objectRayOrigin){
  vec3 direction = worldSpacePosition - objectRayOrigin;
  vec3 reflected = reflect(direction, smoothNormal);
  float reflectedDotSmoothNormal = dot(reflected, smoothNormal);
  if(reflectedDotSmoothNormal < 0.0){
    smoothNormal = normalize(normalize(fma(geometricNormal, vec3(-reflectedDotSmoothNormal), reflected)) - normalize(direction));
  }
}

vec3 raytracingOffsetRay(const in vec3 position, const in vec3 normal, const in vec3 direction){
#ifdef MSAA_RAYOFFSET_WORKAROUND
  // With MSAA, there is a issue at the edges of geometry, where the offset seems to need to be increased with the distance to the camera
  // This is a workaround for this issue, but it might not be the best solution, so it might need some further tweaking and therefore it.
  // TODO: Investigate this further and maybe find a better solution.
  const float positionCameraDistance = length(position - inCameraPosition); 
  const float factor = (gl_SampleID != 0) ? (clamp(log2(positionCameraDistance / 8.0), 0.0, 1.0) * smoothstep(50.0, 100.0, positionCameraDistance)) : 0.0;
  #define fixRayOffset(a,b) (a * mix(1.0, b, factor))
#else  
  #define fixRayOffset(a,b) (a)
#endif  
#if 0
  // A simple offset to avoid self-intersections by moving the ray's starting point slightly along the normal direction
  return fma(normal, vec3(fixRayOffset(1e-3, 10.0)), position);
#elif 0
  // A simple offset to avoid self-intersections by moving the ray's starting point slightly along the normal direction and the ray direction
  return fma(mix(normal, direction, abs(dot(normal, direction))), vec3(fixRayOffset(1e-3, 10.0)), position);
#elif 1
  /*
  ** 
  ** To effectively minimize self-intersection errors in ray tracing, it's crucial to properly scale the offset applied to the ray's starting point.
  ** This adjustment depends on the angle between the surface normal and the ray direction. Specifically, the scale of the offset perpendicular to 
  ** the surface should vary with the sine of the angle between the normal and the ray direction. Likewise, the scale of the offset along the ray's 
  ** path should be proportional to the tangent of this angle. These adjustments ensure that the offset is appropriately scaled to reduce 
  ** self-intersections without unnecessarily distorting the geometry.
  ** 
  ** 
  **                                               ^  N                                                                                              ^  N
  **                                              /|\                                                                                               /|\
  **                                               |                                                 D                                               |
  **                                               |                                                                                                 |
  **                                               |                                          ......                                                 |                                               D
  **                                               |         ...--.                             ....                                      .-         |                                       .......
  **                                               |     ....     ::                          :::- .                                      . ::       |                                         .::..
  **                                               |  ....         .-                      ::.     .                                      .  .-      |                                      .:::-  .
  **                                               |...              -.                 ::.                                               .    -.    |                                   .::       .
  **                                             ..|                  ::             :::                                                  .     ::   |                                .::.
  **                                           ... |                    -         :::                                                     .      .-  |                             .::.
  **                                         ..    |                     -.    :::                                                        .        - |                           ::.
  **                                      ...      |                      ::::.                                                           .         :|                       .::.
  **                                    -.         |                     ::.-                                                             :.         ==     α             .::
  **                                     ::        |       α          ::.    ::                                                            .:        |===              .::.
  **                                      .-       | ===           :::        .:                                                             -       |   ==         .::.
  **                                        -.     |    ===     :::            .-                                                             ::     |    .===    ::.
  **                                         ::    |       ==:::                 :.                                                            .-    |     . .=::.
  **                                          .:   |      .::                     .:                                                             -.  |     :..:
  **                                            -. |   .::                          -                                                             :. |   ::. .-
  **                                             ::-:::                              ::                                                            .-=:::      -.
  **       :::::::::::::::::::::::::::::::::::::::-*-:::::::::::::::::::::::::::::::----:::::.              .::::::::::::::::::::-:::----------------+=---------=-------:::::::::::::::::::::::
  **                                                -:                            ...                                                                 :-        .
  **                                                 .:                        ...                                                                     .-       .
  **                                                  .-                    ...                                                                          :.     .
  **                                                    -.              ....                                                                              ::    .
  **                                                     ::         .....                                                                                  .-   .
  **                                                       -      ...                                                                                        -. .
  **                                                        :. ...                                                                                            ::
  **                                                         ..
  ** 
  **                                                Slope Basis                                                                                    Normal Bias
  */
  const float slopeBiasOffset = fixRayOffset(1e-4, 10.0), normalBiasScale = fixRayOffset(5e-3, 32.0), slopeBiasScale = fixRayOffset(5e-3, 32.0), maxOffset = 0.0;
  float cosAlpha = clamp(dot(normal, direction), 0.0, 1.0);
  float offsetScaleN = sqrt(1.0 - (cosAlpha * cosAlpha));  // sin(acos(D·N))
  float offsetScaleD = offsetScaleN / max(5e-4, cosAlpha); // tan(acos(D·N))
  vec2 offsets = fma(vec2(offsetScaleN, min(2.0, offsetScaleD)), vec2(normalBiasScale, slopeBiasScale), vec2(0.0, slopeBiasOffset));
  if(maxOffset > 1e-6){
    offsets.xy = clamp(offsets.xy, vec2(-maxOffset), vec2(maxOffset));
  }
  return position + (normal * offsets.x) + (direction * offsets.y);
#else
  // Based on: A Fast and Robust Method for Avoiding Self-Intersection - Carsten Wächter & Nikolaus Binder - 26 February 2019
  // Implementation as optimized GLSL code by Benjamin Rosseaux - 2024
  // But it seems still to have some issues with a bit far away geometry, so it might need some further tweaking and therefore it 
  // is not used here for now
  const float origin = 1.0 / 16.0, floatScale = 3.0 / 65536.0, intScale = fixRayOffset(3.0 * 256.0, 32.0), directionScale = 0.0;
  return mix(
    intBitsToFloat(floatBitsToInt(position) + (ivec3(normal * mix(vec3(intScale), vec3(-intScale), vec3(lessThanEqual(position, vec3(0.0))))))), 
    fma(normal, vec3(floatScale), position), 
    vec3(lessThan(abs(position), vec3(origin)))
  ) + (direction * directionScale); // and for additional safety a small offset in the direction of the ray
#endif
#undef fixRayOffset
}

vec4 raytracingTextureFetch(const in Material material, const in int textureIndex, const in vec4 defaultValue, const bool sRGB, const in vec2 texCoords[2]){
  int textureID = material.textures[textureIndex];
  if(textureID >= 0){
    int texCoordIndex = int((textureID >> 16) & 0xf); 
    mat3x2 m = material.textureTransforms[textureIndex];
    return textureLod(u2DTextures[nonuniformEXT(((textureID & 0x3fff) << 1) | (int(sRGB) & 1))], (m * vec3(texCoords[texCoordIndex], 1.0)).xy, 0);
  }else{
    return defaultValue;
  } 
}

// This function handles the rayProceedEXT loop with alpha handling based on the material properties
void rayProceedEXTAlphaHandlingBasedLoop(in rayQueryEXT rayQuery, const in bool closest, out float resultAlpha/*, const in float maxDistance*/){

  resultAlpha = 1.0;

  bool done = false;
  while((!done) && rayQueryProceedEXT(rayQuery)){

/*  if((maxDistance > 0.0) && (rayQueryGetIntersectionTEXT(rayQuery, false) > maxDistance)){
      // Continue with the next intersection, since the current intersection is too far away
      continue;
    }*/

    uint intersectionType = rayQueryGetIntersectionTypeEXT(rayQuery, false);
    
    switch(intersectionType){
    
      case gl_RayQueryCandidateIntersectionTriangleEXT:{
    
        bool opaqueHit = (rayQueryGetRayFlagsEXT(rayQuery) & gl_RayFlagsOpaqueEXT) != 0;
    
        if(opaqueHit){

          // Shortcut for opaque triangles, no need to check material alpha cut-off or alpha blending here
    
          rayQueryConfirmIntersectionEXT(rayQuery);
          resultAlpha = 0.0;
          if(!closest){
            done = true;
          }

        }else{

          // With possible transparent triangles we need to check the material alpha cut-off and alpha blending
          
          int geometryID = rayQueryGetIntersectionGeometryIndexEXT(rayQuery, false);
          
          int geometryInstanceOffset = rayQueryGetIntersectionInstanceCustomIndexEXT(rayQuery, false);
          int additionalInstanceDataID = 0; // 0 = no additional instance data

          // The custom index is only 24 bits long. We reserve the highest (24th) bit as a flag:
          // - If the 24th bit is set, the actual geometry instance offset is not stored directly here but in an external buffer,
          //   indexed by the BLAS instance ID. In this case, the lower 23 bits represent an additional instance data index
          //   (used for per-instance shader effects or other custom instance data).
          // - If the 24th bit is not set, the custom index directly provides the geometry instance offset, which saves memory bandwidth at shader execution time.
          //
          // This mechanism allows us to support a full integer range for geometry offsets in very large scenes,
          // while also optionally associating extra instance-specific data.
          if((geometryInstanceOffset & 0x00800000) != 0){
            additionalInstanceDataID = geometryInstanceOffset & 0x007fffff; 
            const int instanceID = rayQueryGetIntersectionInstanceIdEXT(rayQuery, false);
            geometryInstanceOffset = int(uRaytracingData.geometryInstanceOffsets.geometryInstanceOffsets[instanceID]);     
          }

          RaytracingGeometryItem geometryItem = uRaytracingData.geometryItems.geometryItems[geometryInstanceOffset + geometryID];

          switch(geometryItem.objectType){

            case 0u:{

              // Mesh object type
    
              Material material = uMaterials.materials[geometryItem.materialIndex]; // <= buffer reference, so practically a pointer inside the shader here

              // Check if alpha cut-off or alpha blending is used and if the material is forced opaque for this intersection, if yes, then we can skip the alpha handling
              if(((material.alphaCutOffFlagsTex0Tex1.y & ((1u << 4u) | (1u << 5u))) != 0u) && // Check if alpha cut-off or alpha blending is used 
                 ((material.alphaCutOffFlagsTex0Tex1.y & (1u << 28u)) == 0u)){                // Check if the material is not forced opaque for this intersection

                int primitiveID = rayQueryGetIntersectionPrimitiveIndexEXT(rayQuery, false);

                vec3 barycentrics = vec3(0.0, rayQueryGetIntersectionBarycentricsEXT(rayQuery, false));

                barycentrics.x = 1.0 - (barycentrics.y + barycentrics.z); // Calculate the missing barycentric coordinate
    
                uint indexOffset = geometryItem.indexOffset + (primitiveID * 3u);
                
                uvec3 indices = uvec3(
                  uRaytracingData.meshIndices.meshIndices[indexOffset + 0u],
                  uRaytracingData.meshIndices.meshIndices[indexOffset + 1u],
                  uRaytracingData.meshIndices.meshIndices[indexOffset + 2u]
                );

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

                if((material.alphaCutOffFlagsTex0Tex1.y & (1u << 4u)) != 0u){
                  // Mask / Alpha Test
                  float alpha = raytracingTextureFetch(material, 0, vec4(1.0), true, texCoords).w * material.baseColorFactor.w * vertexColor.w;
                  if(additionalInstanceDataID > 0){
                    // Apply instance effect
                    vec4 dummyColor = vec4(1.0);
                    if(!applyInstanceDataEffect(uint(additionalInstanceDataID), dummyColor, texCoords[0], uvec2(0u), true)){
                      alpha = 0.0;
                    }
                  }
                  if(alpha >= uintBitsToFloat(material.alphaCutOffFlagsTex0Tex1.x)){
                    rayQueryConfirmIntersectionEXT(rayQuery);
                    resultAlpha = 0.0;
                    if(!closest){
                      done = true;
                    }
                  }              
                }else if((material.alphaCutOffFlagsTex0Tex1.y & (1u << 5u)) != 0u){
                  // Blend / Alpha Blend
                  float alpha = raytracingTextureFetch(material, 0, vec4(1.0), true, texCoords).w * material.baseColorFactor.w * vertexColor.w;
                  if(additionalInstanceDataID > 0){
                    // Apply instance effect
                    vec4 dummyColor = vec4(1.0);
                    if(!applyInstanceDataEffect(uint(additionalInstanceDataID), dummyColor, texCoords[0], uvec2(0u), true)){
                      alpha = 0.0;
                    }
                  }
                  resultAlpha *= (1.0 - clamp(alpha, 0.0, 1.0));
                }else{
                  // Opaque, but should not happen here, since we have already checked above for opaque hits
                  rayQueryConfirmIntersectionEXT(rayQuery);
                  resultAlpha = 0.0;
                  if(!closest){
                    done = true;
                  }
                }

              }else{
                  
                // Opaque
                rayQueryConfirmIntersectionEXT(rayQuery);
                resultAlpha = 0.0;
                if(!closest){
                  done = true;
                }

              } 

              break;

            }

            case 1u:{
              
              // Particle object type, ignore for now, but TODO
              break;

            } 

            case 2u:{
              
              // Planet object type, consider as opaque for all cases for now, since the ground should be always opaque on the planets
 
              rayQueryConfirmIntersectionEXT(rayQuery);
              resultAlpha = 0.0;
              if(!closest){
                done = true;
              }

              break;

            }

            default:{
              break;
            }

          } 

        }

        break;
      }

      case gl_RayQueryCandidateIntersectionAABBEXT:{
        // Ignore for now
        //rayQueryGenerateIntersectionEXT(rayQuery, 0.0);
        break;
      }

      default:{
        break;
      }

    } 

  }

}

bool tracePrimaryBasicGeometryRay(vec3 position, 
                                  vec3 direction, 
                                  float minDistance, 
                                  float maxDistance, 
                                  uint cullMask, 
                                  out vec3 hitPosition, 
                                  out vec3 hitFlatNormal, 
                                  out vec3 hitNormal){

  const uint flags = 0u | 
                     //gl_RayFlagsCullFrontFacingTrianglesEXT |
                     //gl_RayFlagsTerminateOnFirstHitEXT | 
                     //gl_RayFlagsOpaqueEXT |
                     //gl_RayFlagsSkipClosestHitShaderEXT |
                     0u;

  rayQueryEXT rayQuery;

  rayQueryInitializeEXT(rayQuery, uRaytracingTopLevelAccelerationStructure, flags, cullMask, position, minDistance, direction, maxDistance);

  float temporaryAlpha;
  rayProceedEXTAlphaHandlingBasedLoop(rayQuery, true, temporaryAlpha/*, maxDistance*/);

  bool result = rayQueryGetIntersectionTypeEXT(rayQuery, true) != gl_RayQueryCommittedIntersectionNoneEXT;

/*// Check if the intersection is too far away, if maxDistance is set, if yes, then we have no intersection
  if(result && (maxDistance > 0.0) && (rayQueryGetIntersectionTEXT(rayQuery, true) > maxDistance)){
    result = false;
  }*/

  if(result){

    uint intersectionType = rayQueryGetIntersectionTypeEXT(rayQuery, false);
    
    switch(intersectionType){
    
      case gl_RayQueryCandidateIntersectionTriangleEXT:{

        int geometryID = rayQueryGetIntersectionGeometryIndexEXT(rayQuery, true);
        
        int geometryInstanceOffset = rayQueryGetIntersectionInstanceCustomIndexEXT(rayQuery, true);
        int additionalInstanceDataID = 0; // 0 = no additional instance data

        // The custom index is only 24 bits long. We reserve the highest (24th) bit as a flag:
        // - If the 24th bit is set, the actual geometry instance offset is not stored directly here but in an external buffer,
        //   indexed by the BLAS instance ID. In this case, the lower 23 bits represent an additional instance data index
        //   (used for per-instance shader effects or other custom instance data).
        // - If the 24th bit is not set, the custom index directly provides the geometry instance offset, which saves memory bandwidth at shader execution time.
        //
        // This mechanism allows us to support a full integer range for geometry offsets in very large scenes,
        // while also optionally associating extra instance-specific data.
        if((geometryInstanceOffset & 0x00800000) != 0){
          additionalInstanceDataID = geometryInstanceOffset & 0x007fffff; 
          const int instanceID = rayQueryGetIntersectionInstanceIdEXT(rayQuery, true);
          geometryInstanceOffset = int(uRaytracingData.geometryInstanceOffsets.geometryInstanceOffsets[instanceID]);     
        }
        
        RaytracingGeometryItem geometryItem = uRaytracingData.geometryItems.geometryItems[geometryInstanceOffset + geometryID];

        switch(geometryItem.objectType){

          case 0u:{

            // Mesh object type

            // mat4x3 objectToWorld = rayQueryGetIntersectionObjectToWorldEXT(rayQuery, true); // don't need this here, since meshDynamicVertices already contains the world space positions 

            int primitiveID = rayQueryGetIntersectionPrimitiveIndexEXT(rayQuery, true);

            vec3 barycentrics = vec3(0.0, rayQueryGetIntersectionBarycentricsEXT(rayQuery, true));

            barycentrics.x = 1.0 - (barycentrics.y + barycentrics.z); // Calculate the missing barycentric coordinate

            uint indexOffset = geometryItem.indexOffset + (primitiveID * 3u);
              
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

            hitPosition = (barycentrics.x * vertexPositionArray[0]) + (barycentrics.y * vertexPositionArray[1]) + (barycentrics.z * vertexPositionArray[2]);

            hitNormal = normalize((barycentrics.x * vertexNormalArray[0]) + (barycentrics.y * vertexNormalArray[1]) + (barycentrics.z * vertexNormalArray[2]));
            
            hitFlatNormal = normalize(cross(vertexPositionArray[1] - vertexPositionArray[0], vertexPositionArray[2] - vertexPositionArray[0]));
            if(dot(hitFlatNormal, direction) > 0.0){
              hitFlatNormal = -hitFlatNormal;
              hitNormal = -hitNormal;
            }

            break;

          }

          case 1u:{
            
            // Particle object type, ignore for now, but TODO
            hitPosition = position + (direction * rayQueryGetIntersectionTEXT(rayQuery, true));
            hitNormal = -direction;
            hitFlatNormal = -direction;
            break;

          }

          case 2u:{
            
            // Planet object type

            mat4x3 objectToWorld = rayQueryGetIntersectionObjectToWorldEXT(rayQuery, true); 

            ReferencedPlanetDataArray referencedPlanetDataArray = uRaytracingData.referencedPlanetDataArray;            
            
            PlanetData planetData = referencedPlanetDataArray.planetData[geometryItem.objectIndex];

            RaytracingPlanetVertices raytracingPlanetVertices = RaytracingPlanetVertices(uvec2(planetData.verticesIndices.xy)); 
            
            RaytracingPlanetIndices raytracingPlanetIndices = RaytracingPlanetIndices(uvec2(planetData.verticesIndices.zw)); 

            int primitiveID = rayQueryGetIntersectionPrimitiveIndexEXT(rayQuery, true);

            vec3 barycentrics = vec3(0.0, rayQueryGetIntersectionBarycentricsEXT(rayQuery, true));

            barycentrics.x = 1.0 - (barycentrics.y + barycentrics.z); // Calculate the missing barycentric coordinate

            uint indexOffset = geometryItem.indexOffset + (primitiveID * 3u);
              
            uvec3 indices = uvec3(
              raytracingPlanetIndices.planetIndices[indexOffset + 0u],
              raytracingPlanetIndices.planetIndices[indexOffset + 1u],
              raytracingPlanetIndices.planetIndices[indexOffset + 2u]
            );

            vec3 vertexPositionArray[3] = vec3[3](
              objectToWorld * vec4(uintBitsToFloat(raytracingPlanetVertices.planetVertices[indices.x].xyz), 1.0),
              objectToWorld * vec4(uintBitsToFloat(raytracingPlanetVertices.planetVertices[indices.y].xyz), 1.0),
              objectToWorld * vec4(uintBitsToFloat(raytracingPlanetVertices.planetVertices[indices.z].xyz), 1.0)
            );

            vec3 vertexNormalArray[3] = vec3[3](
              normalize(objectToWorld * vec4(octSignedDecode(unpackSnorm2x16(raytracingPlanetVertices.planetVertices[indices.x].w)), 0.0)),
              normalize(objectToWorld * vec4(octSignedDecode(unpackSnorm2x16(raytracingPlanetVertices.planetVertices[indices.y].w)), 0.0)),
              normalize(objectToWorld * vec4(octSignedDecode(unpackSnorm2x16(raytracingPlanetVertices.planetVertices[indices.z].w)), 0.0))
            );

            hitPosition = (barycentrics.x * vertexPositionArray[0]) + (barycentrics.y * vertexPositionArray[1]) + (barycentrics.z * vertexPositionArray[2]);

            hitNormal = normalize((barycentrics.x * vertexNormalArray[0]) + (barycentrics.y * vertexNormalArray[1]) + (barycentrics.z * vertexNormalArray[2]));
            
            hitFlatNormal = normalize(cross(vertexPositionArray[1] - vertexPositionArray[0], vertexPositionArray[2] - vertexPositionArray[0]));
            if(dot(hitFlatNormal, direction) > 0.0){
              hitFlatNormal = -hitFlatNormal;
              hitNormal = -hitNormal;
            }


            break;

          }

          default:{
            hitPosition = position + (direction * rayQueryGetIntersectionTEXT(rayQuery, true));
            hitNormal = -direction;
            hitFlatNormal = -direction;
            break;
          }

        } 

        break;

      }

      case gl_RayQueryCandidateIntersectionAABBEXT:{
        // Ignore for now
        hitPosition = position + (direction * rayQueryGetIntersectionTEXT(rayQuery, true));
        hitNormal = -direction;
        hitFlatNormal = -direction;
        break;
      }

      default:{
        hitPosition = position + (direction * rayQueryGetIntersectionTEXT(rayQuery, true));
        hitNormal = -direction;
        hitFlatNormal = -direction;
        break;
      }

    }

  }

  rayQueryTerminateEXT(rayQuery);

  return result;
}                 

// Fast hard shadow raytracing just for opaque triangles, without alpha cut-off and alpha blending testing, and not with the support for
// custom intersection shaders of custom shapes, and so on. So this is really for the most simple and fast hard shadow raytracing.
float getRaytracedFastHardShadow(vec3 position, vec3 normal, vec3 direction, float minDistance, float maxDistance){
  const uint flags = gl_RayFlagsTerminateOnFirstHitEXT | gl_RayFlagsCullNoOpaqueEXT | gl_RayFlagsSkipAABBEXT;
  rayQueryEXT rayQuery;
  rayQueryInitializeEXT(rayQuery, uRaytracingTopLevelAccelerationStructure, flags, CULLMASK_SHADOWS, raytracingOffsetRay(position, normal, direction), minDistance, direction, maxDistance);
  rayQueryProceedEXT(rayQuery); // No loop needed here, since we are only interested in the first hit (terminate on first hit flag is set above)
  float result = (rayQueryGetIntersectionTypeEXT(rayQuery, true) == gl_RayQueryCommittedIntersectionTriangleEXT) ? 0.0 : 1.0; 
  rayQueryTerminateEXT(rayQuery);
  return result;
}                 

float getRaytracedFastOcclusion(vec3 position, vec3 normal, vec3 direction, float minDistance, float maxDistance, bool offsetRay, bool useDistanceBasedCutOff){
  const uint flags = gl_RayFlagsCullNoOpaqueEXT | gl_RayFlagsSkipAABBEXT;
  rayQueryEXT rayQuery;
  rayQueryInitializeEXT(rayQuery, uRaytracingTopLevelAccelerationStructure, flags, CULLMASK_OCCLUSION, offsetRay ? raytracingOffsetRay(position, normal, direction) : position, minDistance, direction, maxDistance);
  while(rayQueryProceedEXT(rayQuery)){}; // Loop until the ray is terminated, so we get the closest hit, which we are interested in for occulsion
  float result = (rayQueryGetIntersectionTypeEXT(rayQuery, true) == gl_RayQueryCommittedIntersectionTriangleEXT) 
                   ? (useDistanceBasedCutOff 
                        ? (1.0 - clamp(rayQueryGetIntersectionTEXT(rayQuery, true) / maxDistance, 0.0, 1.0))
                        : 1.0) 
                   : 0.0; 
  rayQueryTerminateEXT(rayQuery);
  return result;
}                 

// Full hard shadow raytracing with alpha cut-off and alpha blending support and so on
float getRaytracedHardShadow(vec3 position, vec3 normal, vec3 direction, float minDistance, float maxDistance){

  const uint flags = 0u | 
                     //gl_RayFlagsCullFrontFacingTrianglesEXT |
                     //gl_RayFlagsTerminateOnFirstHitEXT | 
                     //gl_RayFlagsOpaqueEXT |
                     //gl_RayFlagsSkipClosestHitShaderEXT |
                     0u;

  rayQueryEXT rayQuery;
  rayQueryInitializeEXT(rayQuery, uRaytracingTopLevelAccelerationStructure, flags, CULLMASK_SHADOWS, raytracingOffsetRay(position, normal, direction), minDistance, direction, maxDistance);

  float result;

  rayProceedEXTAlphaHandlingBasedLoop(rayQuery, false, result/*, maxDistance*/);

  if(rayQueryGetIntersectionTypeEXT(rayQuery, true) != gl_RayQueryCommittedIntersectionNoneEXT){
/*  // If we have an intersection, then we have a shadow, so we return 0.0, but we need to check if the intersection is too far away, if maxDistance is set
    if((maxDistance > 0.0) && (rayQueryGetIntersectionTEXT(rayQuery, true) > maxDistance)){
      // Do nothing 
    }else{ 
      result = 0.0;
    }*/
    result = 0.0;
  } 
    
  // Terminate the ray query 
  rayQueryTerminateEXT(rayQuery);

  // Return the result
  return result;

}

#endif // RAYTRACING

#endif // RAYTRACING_GLSL