#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable
#if defined(USEDEMOTE)
  #extension GL_EXT_demote_to_helper_invocation : enable
#endif

layout(points) in;
layout(triangle_strip, max_vertices = 24) out;

layout(location = 0) in vec3 inPosition[];
layout(location = 1) flat in int inCascadeIndex[];
layout(location = 2) flat in mat4 inViewProjectionMatrix[];

layout(location = 0) out vec4 outColor;

layout (set = 1, binding = 0, std140) readonly uniform VoxelGridData {
  #include "voxelgriddata_uniforms.glsl"
} voxelGridData;

layout(set = 1, binding = 1) uniform sampler3D uVoxelGridOcclusion[];

layout(set = 1, binding = 2) uniform sampler3D uVoxelGridRadiance[];

void main(){

  ivec3 position = ivec3(inPosition[0]); // gl_in[0].gl_Position.xyz
  int cascadeIndex = inCascadeIndex[0];

  if((cascadeIndex == 0) || // First cascade is always the highest resolution cascade, so no further check is needed here
     !(all(greaterThanEqual(position, voxelGridData.cascadeAvoidAABBGridMin[cascadeIndex].xyz)) &&
       all(lessThan(position, voxelGridData.cascadeAvoidAABBGridMax[cascadeIndex].xyz)))){

    vec4 colors[6] = vec4[6](
      texelFetch(uVoxelGridRadiance[(cascadeIndex * 6) + 0], position, 0),
      texelFetch(uVoxelGridRadiance[(cascadeIndex * 6) + 1], position, 0),
      texelFetch(uVoxelGridRadiance[(cascadeIndex * 6) + 2], position, 0),
      texelFetch(uVoxelGridRadiance[(cascadeIndex * 6) + 3], position, 0),
      texelFetch(uVoxelGridRadiance[(cascadeIndex * 6) + 4], position, 0),
      texelFetch(uVoxelGridRadiance[(cascadeIndex * 6) + 5], position, 0)
    ); 

    mat4 viewProjectionMatrix = inViewProjectionMatrix[0];

    float cellSize = voxelGridData.cascadeCellSizes[cascadeIndex >> 2][cascadeIndex & 3];
    vec3 aabbMin = voxelGridData.cascadeAABBMin[cascadeIndex].xyz;

    vec4 vertices[8] = vec4[8](
      viewProjectionMatrix * vec4(fma(vec3(ivec3(ivec3(position) + ivec3(0, 0, 0))), vec3(cellSize), aabbMin), 1.0),
      viewProjectionMatrix * vec4(fma(vec3(ivec3(ivec3(position) + ivec3(1, 0, 0))), vec3(cellSize), aabbMin), 1.0),
      viewProjectionMatrix * vec4(fma(vec3(ivec3(ivec3(position) + ivec3(0, 1, 0))), vec3(cellSize), aabbMin), 1.0),
      viewProjectionMatrix * vec4(fma(vec3(ivec3(ivec3(position) + ivec3(1, 1, 0))), vec3(cellSize), aabbMin), 1.0),
      viewProjectionMatrix * vec4(fma(vec3(ivec3(ivec3(position) + ivec3(0, 0, 1))), vec3(cellSize), aabbMin), 1.0),
      viewProjectionMatrix * vec4(fma(vec3(ivec3(ivec3(position) + ivec3(1, 0, 1))), vec3(cellSize), aabbMin), 1.0),
      viewProjectionMatrix * vec4(fma(vec3(ivec3(ivec3(position) + ivec3(0, 1, 1))), vec3(cellSize), aabbMin), 1.0),
      viewProjectionMatrix * vec4(fma(vec3(ivec3(ivec3(position) + ivec3(1, 1, 1))), vec3(cellSize), aabbMin), 1.0)
    );

    const ivec4 quadIndicesArray[6] = ivec4[6](
      ivec4(1, 5, 7, 3), // +X
      ivec4(2, 3, 7, 6), // +Y
      ivec4(4, 6, 7, 5), // +Z
      ivec4(0, 2, 6, 4), // -X
      ivec4(0, 4, 5, 1), // -Y
      ivec4(0, 1, 3, 2)  // -Z
    );

    [[unroll]] for(int quadIndexCounter = 0; quadIndexCounter < 6; quadIndexCounter++){
      
      ivec4 quadIndices = quadIndicesArray[quadIndexCounter];
            
      if(colors[quadIndexCounter].w > 1e-6){
      
        outColor = colors[quadIndexCounter];
      
        gl_Position = vertices[quadIndices.x];
        EmitVertex();
      
        gl_Position = vertices[quadIndices.y];
        EmitVertex();
      
        gl_Position = vertices[quadIndices.z];
        EmitVertex();
      
        gl_Position = vertices[quadIndices.w];
        EmitVertex();
      
        EndPrimitive();

      }

    }
  
  }

}