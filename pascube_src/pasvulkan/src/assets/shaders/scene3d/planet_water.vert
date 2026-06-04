#version 450 core

#pragma shader_stage(vertex)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable

#include "bufferreference_definitions.glsl"

#ifdef UNDERWATER
layout(location = 0) out OutBlock {
  vec2 texCoord;
  float underWater;
} outBlock;
#else
layout(location = 0) out OutBlock {
  vec3 position;
  vec3 normal;
  vec3 planetCenterToCamera;
  uint flags;
} outBlock;
#endif

// Global descriptor set

#define PLANETS
#ifdef RAYTRACING
  #define USE_MATERIAL_BUFFER_REFERENCE // needed for raytracing
#endif
#include "globaldescriptorset.glsl"
#undef PLANETS

// Pass descriptor set

#include "mesh_rendering_pass_descriptorset.glsl"

// Per water render pass descriptor set

#if !defined(UNDERWATER)

layout(set = 3, binding = 0) readonly buffer VisibilityBuffer {
  uint bitmap[];
} visibilityBuffer;

layout(set = 3, binding = 1) readonly buffer WaterVisibilityBuffer {
  uint bitmap[];
} waterVisibilityBuffer;

#endif

#define PLANET_WATER
#include "planet_renderpass.glsl"

//#ifdef UNDERWATER
#include "planet_textures.glsl"
//#endif

//#ifndef UNDERWATER
#include "octahedral.glsl"
//#endif

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix; 
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix; 

//#ifdef UNDERWATER

layout(set = 2, binding = 0) uniform sampler2D uPlanetTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map
layout(set = 2, binding = 0) uniform sampler2DArray uPlanetArrayTextures[];  // 0 = height map, 1 = normal map, 2 = tangent bitangent map

vec3 planetCenter = vec3(0.0);
float planetBottomRadius = planetData.bottomRadiusTopRadiusHeightMapScale.x;
float planetTopRadius = planetData.bottomRadiusTopRadiusHeightMapScale.y;

mat4 planetModelMatrix = planetData.modelMatrix;
mat4 planetInverseModelMatrix = inverse(planetModelMatrix);

#include "planet_water.glsl"
//#endif

void main(){ 

  vec3 planetSpaceCameraPosition = (planetInverseModelMatrix * vec4(inverseViewMatrix[3].xyz, 1.0)).xyz;
  
  bool underWater = map(planetSpaceCameraPosition) <= 0.0;

#ifdef UNDERWATER

#undef OLD
#ifdef OLD
  outBlock.texCoord = vec2((gl_VertexIndex >> 1) * 2.0, (gl_VertexIndex & 1) * 2.0);
  outBlock.underWater = underWater ? 1.0 : 0.0;
  gl_Position = underWater ? vec4(((gl_VertexIndex >> 1) * 4.0) - 1.0, ((gl_VertexIndex & 1) * 4.0) - 1.0, 0.0, 1.0) : vec4(uintBitsToFloat(0x7fffffffu));
#else
  ivec2 uv = ivec2(ivec2(int(gl_VertexIndex)) << ivec2(0, 1)) & ivec2(2); // ivec2 uv = ivec2(gl_VertexIndex & 2, (gl_VertexIndex << 1) & 2);
  outBlock.texCoord = vec2(uv);
  outBlock.underWater = underWater ? 1.0 : 0.0;
  gl_Position = underWater ? vec4(vec2(ivec2((uv << ivec2(1)) - ivec2(1))), 0.0, 1.0) : vec4(uintBitsToFloat(0x7fffffffu));
#endif

#else
  uint countQuadPointsInOneDirection = pushConstants.countQuadPointsInOneDirection;
  uint countQuads = countQuadPointsInOneDirection * countQuadPointsInOneDirection;
  uint countTotalVertices = countQuads * 4u; // 4 vertices per quad

  vec3 sphereNormal;

  uint vertexIndex = uint(gl_VertexIndex);
  
  if(vertexIndex < countTotalVertices){ 

    // A quad is made of two triangles, where the first triangle is the lower left triangle and the second
    // triangle is the upper right triangle. So the vertex indices and the triangles of a quad are:
    //
    // 0,0 v0--v1 1,0
    //     |\   |
    //     | \t0|
    //     |t1\ |
    //     |   \|
    // 0,1 v3--v2 1,1
    //
    // The indices are encoded as bitwise values here, so that the vertex indices can be calculated by bitshifting. 

    uint quadIndex = vertexIndex >> 2u,
         quadVertexIndex = vertexIndex & 3u;

    quadVertexIndex = 3u - quadVertexIndex; 

    uint quadVertexUVIndex = (0xb4u >> (quadVertexIndex << 1u)) & 3u;     
    uvec2 quadVertexUV = uvec2(quadVertexUVIndex & 1u, quadVertexUVIndex >> 1u);    

    uvec2 quadXY;
    quadXY.y = quadIndex / countQuadPointsInOneDirection;
    quadXY.x = quadIndex - (quadXY.y * countQuadPointsInOneDirection); 

    sphereNormal = octPlanetUnsignedDecode(vec2(quadXY + quadVertexUV) / vec2(countQuadPointsInOneDirection));

  }else{

    sphereNormal = vec3(0.0);

  }  

  vec2 sphereHeightData = getSphereHeightData(sphereNormal);

  vec3 localPosition = sphereNormal * clamp(sphereHeightData.x + sphereHeightData.y, planetData.bottomRadiusTopRadiusHeightMapScale.x * 0.5, planetData.bottomRadiusTopRadiusHeightMapScale.y);
  
  bool visible, waterVisible;
  {
    vec2 planetUV = octPlanetUnsignedEncode(sphereNormal);
    ivec2 tileUV = ivec2(floor(planetUV * vec2(pushConstants.tileMapResolution))) & ivec2(pushConstants.tileMapResolution - 1);    
    uint tileIndex = (uint(tileUV.y) * pushConstants.tileMapResolution) + uint(tileUV.x);
    visible = (visibilityBuffer.bitmap[tileIndex >> 5u] & (1u << (tileIndex & 31u))) != 0u;
    waterVisible = (waterVisibilityBuffer.bitmap[tileIndex >> 5u] & (1u << (tileIndex & 31u))) != 0u;
  }

  outBlock.position = (planetData.modelMatrix * vec4(localPosition, 1.0)).xyz;
  outBlock.normal = sphereNormal;
  outBlock.planetCenterToCamera = inverseViewMatrix[3].xyz - (planetData.modelMatrix * vec2(0.0, 1.0).xxxy).xyz; 
  outBlock.flags = (underWater ? (1u << 0u) : 0u) |
                   (visible ? (1u << 1u) : 0u) |
                   (waterVisible ? (1u << 2u) : 0u) | 
                   ((sphereHeightData.y > 0.0) ? (1u << 3u) : 0u);
#endif

}
