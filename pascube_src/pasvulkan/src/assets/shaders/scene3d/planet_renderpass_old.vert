#version 450 core

#pragma shader_stage(vertex)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

#ifdef EXTERNAL_VERTICES
layout(location = 0) in vec3 inVector;
#endif

layout(location = 0) out OutBlock {
  vec3 position;
  vec3 normal;
  vec3 planetCenterToCamera;
} outBlock;

layout(push_constant) uniform PushConstants {
  
  mat4 modelMatrix;
  
  uint viewBaseIndex;
  uint countViews;
  uint countQuadPointsInOneDirection; 
  uint countAllViews;
  
  float bottomRadius;
  float topRadius;
  float resolutionX;  
  float resolutionY;  
  
  float heightMapScale;
  float tessellationFactor;
  vec2 jitter;

} pushConstants;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 0, binding = 0, std140) uniform uboViews {
  View views[256];
} uView;

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix; 

#ifndef EXTERNAL_VERTICES

const uvec2 offsets[4] = uvec2[](
  ivec2(0, 0),  
  ivec2(0, 1),  
  ivec2(1, 1),  
  ivec2(1, 0)
);  

#if defined(OCTAHEDRAL)

uint countQuadPointsInOneDirection = pushConstants.countQuadPointsInOneDirection;
uint countQuads = countQuadPointsInOneDirection * countQuadPointsInOneDirection;
#ifdef TRIANGLES
uint countTotalVertices = countQuads * 6u; // 2 triangles per quad, 3 vertices per triangle
#else
uint countTotalVertices = countQuads * 4u; // 4 vertices per quad
#endif

#elif defined(ICOSAHEDRAL)

uint countQuadPointsInOneDirection = pushConstants.countQuadPointsInOneDirection;
uint countFaceQuads = countQuadPointsInOneDirection * countQuadPointsInOneDirection;
#ifdef TRIANGLES
uint countTotalVertices = countFaceQuads * 3u * 20u; // 2 triangles per face, 20 faces
#else
  #error "Icosahedral spheres do support only triangles in this implementation."
#endif

#else

uint countQuadPointsInOneDirection = pushConstants.countQuadPointsInOneDirection;
uint countSideQuads = countQuadPointsInOneDirection * countQuadPointsInOneDirection;
#ifdef TRIANGLES
uint countTotalVertices = countSideQuads * (6u * 6u); // 2 triangles per quad, 3 vertices per triangle, 6 sides
#else
uint countTotalVertices = countSideQuads * (6u * 4u); // 4 vertices per quad, 6 sides
#endif

const mat3 sideMatrices[6] = mat3[6](
  mat3(vec3(0.0, 0.0, -1.0), vec3(0.0, -1.0, 0.0), vec3(-1.0, 0.0, 0.0)), // pos x
  mat3(vec3(0.0, 0.0, 1.0), vec3(0.0, -1.0, 0.0), vec3(1.0, 0.0, 0.0)),   // neg x
  mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, -1.0), vec3(0.0, 1.0, 0.0)),   // pos y
  mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(0.0, -1.0, 0.0)),   // neg y
  mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, -1.0, 0.0), vec3(0.0, 0.0, -1.0)),  // pos z
  mat3(vec3(-1.0, 0.0, 0.0), vec3(0.0, -1.0, 0.0), vec3(0.0, 0.0, 1.0))   // neg z
);  

const float HalfPI = 1.5707963267948966, // 1.570796326794896619231,
            PI = 3.141592653589793, // 3.141592653589793238463,
            PI2 = 6.283185307179586; // 6.283185307179586476925   

vec3 unitCubeToUnitSphere(const in vec3 unitCube){
  // http://mathproofs.blogspot.com/2005/07/mapping-cube-to-sphere.html
  vec3 unitCubeSquared = unitCube * unitCube, unitCubeSquaredDiv2 = unitCubeSquared * 0.5, unitCubeSquaredDiv3 = unitCubeSquared / 3.0;
  return normalize(unitCube * sqrt(((1.0 - unitCubeSquaredDiv2.yzx) - unitCubeSquaredDiv2.zxy) + (unitCubeSquared.yzx * unitCubeSquaredDiv3.zxy)));
}

vec3 unitSphereToUnitCubeCase(const in vec3 unitVector){
  // http://petrocket.blogspot.com/2010/04/sphere-to-cube-mapping.html
  vec2 a = (unitVector.xy * unitVector.xy) * 2.0, b = vec2(a.x - a.y, a.y - a.x);
  return sign(unitVector) * vec3(sqrt((b - sqrt(fma(a.x, -12.0, (b.y - 3.0) * (b.y - 3.0)))) + 3.0) * 0.70710676908493042, 1.0);
}

vec3 unitSphereToUnitCube(const in vec3 unitSphere){
  // http://petrocket.blogspot.com/2010/04/sphere-to-cube-mapping.html
  vec3 f = abs(unitSphere);
  return all(greaterThanEqual(f.yy, f.xz)) ? 
           unitSphereToUnitCubeCase(unitSphere.xzy).xzy : 
           ((f.x >= f.z) ? 
             unitSphereToUnitCubeCase(unitSphere.yzx).zxy : 
             unitSphereToUnitCubeCase(unitSphere));
}

vec3 getNormal(mat3 m, vec2 uv){
#if 0
  const float warpTheta = 0.868734829276; // radians
  const float tanWarpTheta = 1.1822866855467427; // tan(warpTheta);
  //uv = tan(uv * warpTheta)/ tanWarpTheta;
  uv = atan(uv * tanWarpTheta) / warpTheta;
#endif  
  vec3 unitCube = m * vec3((uv - vec2(0.5)) * 2.0, 1.0),
#if 1
       // Spherified cube
       normal = unitCubeToUnitSphere(unitCube);
#else
       // Normalized cube
       normal = normalize(unitCube);
#endif
  return normal; 
}
#endif

#endif

#if 0
const mat3 tangentTransformMatrix = mat3(vec3(0.0, 0.0, -1.0), vec3(0.0, -1.0, 0.0), vec3(1.0, 0.0, 0.0)),
           bitangentTransformMatrix = mat3(vec3(-1.0, 0.0, 0.0), vec3(0.0, 0.0, -1.0), vec3(0.0, 1.0, 0.0));
#endif

void main(){          
#ifdef EXTERNAL_VERTICES
  vec3 normal = normalize(inVector),
       position = (pushConstants.modelMatrix * vec4(normal * pushConstants.bottomRadius, 1.0)).xyz;
#if 0
  vec3 tangent = getNormal(normalMatrix * tangentTransformMatrix, uv),
       bitangent = getNormal(normalMatrix * bitangentTransformMatrix, uv);
  tangent = normalize(tangent - (dot(tangent, normal) * normal));
  bitangent = normalize(bitangent - (dot(bitangent, normal) * normal));
  tangent = cross(bitangent, normal);
  bitangent = cross(normal, tangent);
#endif
  outBlock.position = position;    
  outBlock.normal = normal;
  outBlock.planetCenterToCamera = inverseViewMatrix[3].xyz - (pushConstants.modelMatrix * vec2(0.0, 1.0).xxxy).xyz; 
#else       
  uint vertexIndex = uint(gl_VertexIndex);
  if(vertexIndex < countTotalVertices){   
#ifdef TRIANGLES
   uint triangleIndex = vertexIndex / 3u,
        triangleVertexIndex = vertexIndex - (triangleIndex * 3u),
        quadIndex = triangleIndex >> 1u,
        quadVertexIndex = uvec3[2]( uvec3(0u, 1u, 2u), uvec3(0u, 2u, 3u))[triangleIndex & 1u][triangleVertexIndex];
#else
    uint quadIndex = vertexIndex >> 2u,
         quadVertexIndex = vertexIndex & 3u;
#endif
#if defined(OCTAHEDRAL)
    uvec2 quadXY;
    quadXY.y = quadIndex / countQuadPointsInOneDirection;
    quadXY.x = quadIndex - (quadXY.y * countQuadPointsInOneDirection); 
    vec2 uv = fma(vec2(quadXY + offsets[3u - quadVertexIndex]) / vec2(countQuadPointsInOneDirection), vec2(2.0), vec2(-1.0));
    vec3 normal = vec3(uv.xy, 1.0 - (abs(uv.x) + abs(uv.y)));
    normal = normalize((normal.z < 0.0) ? vec3((1.0 - abs(normal.yx)) * vec2((normal.x >= 0.0) ? 1.0 : -1.0, (normal.y >= 0.0) ? 1.0 : -1.0), normal.z) : normal);
#elif defined(ICOSAHEDRAL)
    uint faceIndex = quadIndex / countFaceQuads,
         faceQuadIndex = quadIndex - (faceIndex * countFaceQuads);
    faceIndex %= 20u;
#else
    uint sideIndex = quadIndex / countSideQuads,
         sideQuadIndex = quadIndex - (sideIndex * countSideQuads);
    sideIndex %= 6u;
    uvec2 sideQuadXY;
    sideQuadXY.y = sideQuadIndex / countQuadPointsInOneDirection;
    sideQuadXY.x = sideQuadIndex - (sideQuadXY.y * countQuadPointsInOneDirection); 
    vec2 uv = vec2(sideQuadXY + offsets[3u - quadVertexIndex]) / vec2(countQuadPointsInOneDirection);
    mat3 normalMatrix = sideMatrices[sideIndex];       
    vec3 normal = getNormal(normalMatrix, uv);
#endif
    vec3 position = (pushConstants.modelMatrix * vec4(normal * pushConstants.bottomRadius, 1.0)).xyz;
#if 0
    vec3 tangent = getNormal(normalMatrix * tangentTransformMatrix, uv),
         bitangent = getNormal(normalMatrix * bitangentTransformMatrix, uv);
    tangent = normalize(tangent - (dot(tangent, normal) * normal));
    bitangent = normalize(bitangent - (dot(bitangent, normal) * normal));
    tangent = cross(bitangent, normal);
    bitangent = cross(normal, tangent);
#endif
    outBlock.position = position;    
    outBlock.normal = normal;
    outBlock.planetCenterToCamera = inverseViewMatrix[3].xyz - (pushConstants.modelMatrix * vec2(0.0, 1.0).xxxy).xyz; 
  }else{
    outBlock.position = outBlock.normal = vec3(0.0);
  }  
#endif
}


#elif defined(ICOSAHEDRAL)
  
    float GoldenRatio = 1.61803398874989485, // (1.0+sqrt(5.0))/2.0 (golden ratio)
          IcosahedronLength = 1.902113032590307, // sqrt(sqr(1)+sqr(GoldenRatio))
          IcosahedronNorm = 0.5257311121191336, // 1.0 / IcosahedronLength
          IcosahedronNormGoldenRatio = 0.85065080835204; // GoldenRatio / IcosahedronLength

    const vec3 faceVertices[12] = vec3[12](
      vec3(0.0, IcosahedronNorm, IcosahedronNormGoldenRatio),
      vec3(0.0, -IcosahedronNorm, IcosahedronNormGoldenRatio),
      vec3(IcosahedronNorm, IcosahedronNormGoldenRatio, 0.0),
      vec3(-IcosahedronNorm, IcosahedronNormGoldenRatio, 0.0),
      vec3(IcosahedronNormGoldenRatio, 0.0, IcosahedronNorm),
      vec3(-IcosahedronNormGoldenRatio, 0.0, IcosahedronNorm),
      vec3(0.0, -IcosahedronNorm, -IcosahedronNormGoldenRatio),
      vec3(0.0, IcosahedronNorm, -IcosahedronNormGoldenRatio),
      vec3(-IcosahedronNorm, -IcosahedronNormGoldenRatio, 0.0),
      vec3(IcosahedronNorm, -IcosahedronNormGoldenRatio, 0.0),
      vec3(-IcosahedronNormGoldenRatio, 0.0, -IcosahedronNorm),
      vec3(IcosahedronNormGoldenRatio, 0.0, -IcosahedronNorm)
    );

    const uvec3 faceIndices[20] = uvec3[20](
      uvec3(0u, 5u, 1u), uvec3(0u, 3u, 5u), uvec3(0u, 2u, 3u), uvec3(0u, 4u, 2u), uvec3(0u, 1u, 4u),
      uvec3(1u, 5u, 8u), uvec3(5u, 3u, 10u), uvec3(3u, 2u, 7u), uvec3(2u, 4u, 11u), uvec3(4u, 1u, 9u),
      uvec3(7u, 11u, 6u), uvec3(11u, 9u, 6u), uvec3(9u, 8u, 6u), uvec3(8u, 10u, 6u), uvec3(10u, 7u, 6u),
      uvec3(2u, 11u, 7u), uvec3(4u, 9u, 11u), uvec3(1u, 8u, 9u), uvec3(5u, 10u, 8u), uvec3(3u, 7u, 10u)
    );

    uint triangleIndex = vertexIndex / 3u,   
         triangleVertexIndex = vertexIndex - (triangleIndex * 3u);

    uvec3 faceVertexIndices = faceIndices[triangleIndex];
    
    vec3 faceVertex0 = faceVertices[faceVertexIndices.x],
         faceVertex1 = faceVertices[faceVertexIndices.y],
         faceVertex2 = faceVertices[faceVertexIndices.z];

    uvec2 quadXY;
    quadXY.y = quadIndex / countQuadPointsInOneDirection;
    quadXY.x = quadIndex - (quadXY.y * countQuadPointsInOneDirection); 

    vec2 uv = vec2(quadXY + quadVertexUV) / vec2(countQuadPointsInOneDirection);

    sphereNormal = normalize(mix(faceVertex0, mix(faceVertex1, faceVertex2, uv.x), uv.y));

#version 450 core

#pragma shader_stage(vertex)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

#ifdef EXTERNAL_VERTICES
  layout(location = 0) in vec3 inVector;
#endif

#ifdef DIRECT

// Without tessellation

layout(location = 0) out OutBlock {
  vec3 position;
  vec3 tangent;
  vec3 bitangent;
  vec3 normal;
  vec3 edge; 
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
  vec2 jitter;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
} outBlock;

#else

// With tessellation

layout(location = 0) out OutBlock {
  vec3 position;
  vec3 normal;
  vec3 planetCenterToCamera;
} outBlock;

#endif

layout(push_constant) uniform PushConstants {
  
  mat4 modelMatrix;
  
  uint viewBaseIndex;
  uint countViews;
  uint countQuadPointsInOneDirection; 
  uint countAllViews;
  
  float bottomRadius;
  float topRadius;
  float resolutionX;  
  float resolutionY;  
  
  float heightMapScale;
  float tessellationFactor;
  vec2 jitter;

} pushConstants;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 0, binding = 0, std140) uniform uboViews {
  View views[256];
} uView;

#ifdef DIRECT
layout(set = 1, binding = 0) uniform sampler2D uTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map

#include "octahedral.glsl"
#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix;
mat4 projectionMatrix = uView.views[viewIndex].projectionMatrix;
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix;
#else
uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix; 
#endif

#ifndef EXTERNAL_VERTICES

  #if defined(OCTAHEDRAL)

    uint countQuadPointsInOneDirection = pushConstants.countQuadPointsInOneDirection;
    uint countQuads = countQuadPointsInOneDirection * countQuadPointsInOneDirection;
    #ifdef TRIANGLES
      uint countTotalVertices = countQuads * 6u; // 2 triangles per quad, 3 vertices per triangle
    #else
      uint countTotalVertices = countQuads * 4u; // 4 vertices per quad
    #endif

  #else

    uint countQuadPointsInOneDirection = pushConstants.countQuadPointsInOneDirection;
    uint countSideQuads = countQuadPointsInOneDirection * countQuadPointsInOneDirection;
    #ifdef TRIANGLES
      uint countTotalVertices = countSideQuads * (6u * 6u); // 2 triangles per quad, 3 vertices per triangle, 6 sides
    #else
      uint countTotalVertices = countSideQuads * (6u * 4u); // 4 vertices per quad, 6 sides
    #endif

  #endif

#endif

void main(){          

  vec3 sphereNormal;

#ifdef EXTERNAL_VERTICES
  
  sphereNormal = normalize(inVector);

#else       
 
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
    // 1,0 v3--v2 1,1
    //
    // The indices are encoded as bitwise values here, so that the vertex indices can be calculated by bitshifting. 

#ifdef TRIANGLES

    // 0xe24 = 3,2,0,2,1,0 (two bit wise encoded triangle indices, reversed for bitshifting for 0,1,2, 0,2,3 output order)

    uint quadIndex = vertexIndex / 6u,   
         quadVertexIndex = (0xe24u >> ((vertexIndex - (quadIndex * 6u)) << 1u)) & 3u; 

#else

    uint quadIndex = vertexIndex >> 2u,
         quadVertexIndex = vertexIndex & 3u;

#endif

    // 0xb4 = 180 = 0b10110100 (bitwise encoded x y coordinates, where x is the first bit and y is the second bit in every two-bit pair)  
   
    uint quadVertexUVIndex = (0xb4u >> (quadVertexIndex << 1u)) & 3u; 
    uvec2 quadVertexUV = uvec2(quadVertexUVIndex & 1u, quadVertexUVIndex >> 1u);

#if defined(OCTAHEDRAL)

    uvec2 quadXY;
    quadXY.y = quadIndex / countQuadPointsInOneDirection;
    quadXY.x = quadIndex - (quadXY.y * countQuadPointsInOneDirection); 

    vec2 uv = fma(vec2(quadXY + quadVertexUV) / vec2(countQuadPointsInOneDirection), vec2(2.0), vec2(-1.0));

/*  ivec2 wrapUV = ivec2(bvec2(greaterThanEqual(uv, vec2(1.0))));
    
    uv = fma(fract(((wrapUV.x ^ wrapUV.y) != 0) ? vec2(1.0) - fract(uv) : fract(uv)), vec2(2.0), vec2(-1.0));*/

    sphereNormal = vec3(uv.xy, 1.0 - (abs(uv.x) + abs(uv.y)));
    sphereNormal = normalize((sphereNormal.z < 0.0) ? vec3((1.0 - abs(sphereNormal.yx)) * vec2((sphereNormal.x >= 0.0) ? 1.0 : -1.0, (sphereNormal.y >= 0.0) ? 1.0 : -1.0), sphereNormal.z) : sphereNormal);

#else

    const mat3 sideMatrices[6] = mat3[6](
      mat3(vec3(0.0, 0.0, -1.0), vec3(0.0, -1.0, 0.0), vec3(-1.0, 0.0, 0.0)), // pos x
      mat3(vec3(0.0, 0.0, 1.0), vec3(0.0, -1.0, 0.0), vec3(1.0, 0.0, 0.0)),   // neg x
      mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, -1.0), vec3(0.0, 1.0, 0.0)),   // pos y
      mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(0.0, -1.0, 0.0)),   // neg y
      mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, -1.0, 0.0), vec3(0.0, 0.0, -1.0)),  // pos z
      mat3(vec3(-1.0, 0.0, 0.0), vec3(0.0, -1.0, 0.0), vec3(0.0, 0.0, 1.0))   // neg z
    );  

    uint sideIndex = quadIndex / countSideQuads,
        sideQuadIndex = quadIndex - (sideIndex * countSideQuads);

    float sideQuadY = sideQuadIndex / countQuadPointsInOneDirection,
          sideQuadX = sideQuadIndex - (sideQuadY * countQuadPointsInOneDirection); 

    vec3 unitCube = sideMatrices[sideIndex % 6u] * 
                    vec3(
                      fma(
                        vec2(uvec2(sideQuadX, sideQuadY) + quadVertexUV) / vec2(countQuadPointsInOneDirection), 
                        vec2(2.0), 
                        vec2(-1.0)
                      ), 
                      1.0
                    );

    vec3 unitCubeSquared = unitCube * unitCube, 
                           unitCubeSquaredDiv2 = unitCubeSquared * 0.5, 
                           unitCubeSquaredDiv3 = unitCubeSquared / 3.0;

    sphereNormal = normalize(unitCube * sqrt(((1.0 - unitCubeSquaredDiv2.yzx) - unitCubeSquaredDiv2.zxy) + (unitCubeSquared.yzx * unitCubeSquaredDiv3.zxy)));

#endif
 
  }else{

    sphereNormal = vec3(0.0);

  }  

#endif

#ifdef DIRECT
 
  // Without tessellation, so directly output the vertex data to the fragment shader

  mat4 viewProjectionMatrix = projectionMatrix * viewMatrix;

#if 1
  // The actual standard approach
  vec3 cameraPosition = inverseViewMatrix[3].xyz;
#else
  // This approach assumes that the view matrix has no scaling or skewing, but only rotation and translation.
  vec3 cameraPosition = (-viewMatrix[3].xyz) * mat3(viewMatrix);
#endif   

  vec3 position = (pushConstants.modelMatrix * vec4(sphereNormal * (pushConstants.bottomRadius + (textureCatmullRomOctahedralMap(uTextures[0], sphereNormal).x * pushConstants.heightMapScale)), 1.0)).xyz;

  vec3 outputNormal = textureCatmullRomOctahedralMap(uTextures[1], sphereNormal).xyz;
  vec3 outputTangent = normalize(cross((abs(outputNormal.y) < 0.999999) ? vec3(0.0, 1.0, 0.0) : vec3(0.0, 0.0, 1.0), outputNormal));
  vec3 outputBitangent = normalize(cross(outputNormal, outputTangent));

  vec3 worldSpacePosition = position;

  vec4 viewSpacePosition = viewMatrix * vec4(position, 1.0);
  viewSpacePosition.xyz /= viewSpacePosition.w;

  outBlock.position = position;         
  outBlock.tangent = outputTangent;
  outBlock.bitangent = outputBitangent;
  outBlock.normal = outputNormal;
  outBlock.edge = vec3(1.0);
  outBlock.worldSpacePosition = worldSpacePosition;
  outBlock.viewSpacePosition = viewSpacePosition.xyz;  
  outBlock.cameraRelativePosition = worldSpacePosition - cameraPosition;
  outBlock.jitter = pushConstants.jitter;
#ifdef VELOCITY
  outBlock.currentClipSpace = (projectionMatrix * viewMatrix) * vec4(position, 1.0);
  outBlock.previousClipSpace = (uView.views[viewIndex + pushConstants.countAllViews].projectionMatrix * uView.views[viewIndex + pushConstants.countAllViews].viewMatrix) * vec4(position, 1.0);
#endif

	gl_Position = viewProjectionMatrix * vec4(position, 1.0);


#else

  // With tessellation

  vec3 position = (pushConstants.modelMatrix * vec4(sphereNormal * pushConstants.bottomRadius, 1.0)).xyz;
  outBlock.position = position;    
  outBlock.normal = sphereNormal;
  outBlock.planetCenterToCamera = inverseViewMatrix[3].xyz - (pushConstants.modelMatrix * vec2(0.0, 1.0).xxxy).xyz; 

#endif

}

    {
    		
#if 1

    sphereNormal = vec3(uv.xy, 1.0 - (abs(uv.x) + abs(uv.y)));
    sphereNormal = normalize((sphereNormal.z < 0.0) ? vec3((1.0 - abs(sphereNormal.yx)) * vec2((sphereNormal.x < 0.0) ? -1.0 : 1.0, (sphereNormal.y < 0.0) ? -1.0 : 1.0), sphereNormal.z) : sphereNormal);
    
#elif 0

    vec2 uvAbs = abs(uv);
    float d = 1.0 - (uvAbs.x + uvAbs.y), r = 1.0 - abs(d);
    sphereNormal = normalize(vec3((sin((vec2(((r == 0.0) ? 0.0 : ((uvAbs.y - uvAbs.x) / r)) + 1.0) + vec2(1.0, 0.0)) * 1.5707963267948966) *
                                   vec2(uv.x < 0.0 ? -1.0 : 1.0, uv.y < 0.0 ? -1.0 : 1.0)) * r * sqrt(2.0 - (r * r)), 
                                  (1.0 - (r * r)) * (d < 0.0 ? -1.0 : 1.0)));

#else

      float a = uv.y + uv.x;
      float b = uv.y - uv.x;
      
      float r, phi, z;
      
      if(uv.y >= 0.0){
        if(uv.x >= 0.0){	
          // quadrant 1
          if(a <= 1.0){
            // north
            r = a;
            z = 1.0;
            phi = uv.y / r;
          }else{
            // south
            r = 2.0 - a;
            z = -1.0;
            phi = (1.0 - uv.x) / r;
          }
        }else{			
          // quadrant 2
          if(b <= 1.0){
            // north
            r = b;
            z = 1.0;
            phi = 1.0 - (uv.x / r);
          }
          else
          {
            r = 2.0 - b;
            z = -1.0;
            phi = 1.0 + (1.0 - uv.y) / r;
          }
        }
      }else{
        if(uv.x < 0.0){
          // quadrant 3
          if(a >= -1.0){
            // north
            r = -a;
            z = 1.0;
            phi = 2.0 - uv.y / r;
          }else{
        		// south          
            r = 2.0 + a;
            z = -1.0;
            phi = 2.0 + (1.0 + uv.x) / r;
          }
        }else{
          // quadrant 4
          if(b>=-1.0){
            // north
            r = -b;
            z = 1.0;
            phi = 3.0 + (uv.x / r);
          }else{
            // south
            r = 2.0 + b;
            z = -1.0;
            phi = 3.0 + (1.0 + uv.y) / r;
          }
        }
      }
      
      sphereNormal = normalize(vec3(sin(vec2(((r == 0.0) ? 0.0 : phi) * 1.5707963267948966) + vec2(1.5707963267948966, 0.0)) * r * sqrt(2.0 - (r * r)), z * (1.0 - (r * r))));

#endif

    }

