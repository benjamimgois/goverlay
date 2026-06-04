#ifndef VOXELIZATION_GLOBALS_GLSL
#define VOXELIZATION_GLOBALS_GLSL

#ifdef VOXELIZATION

// Here i'm using 20.12 bit fixed point, since some current GPUs doesn't still support 32 bit floating point atomic add operations, and a RGBA8 
// atomic-compare-and-exchange-loop running average is not enough for a good quality voxelization with HDR-ranged colors for my taste, since 
// RGBA8 has only 8 bits per channel, which is only suitable for LDR colors. In addition to it, i'm using a 32-bit counter per voxel for the 
// post averaging step.

// The RGBA8 running average approach would also need separate volumes for non-emissive and emissive voxels, because of possible range 
// overflows, but where this approach doesn't need it, because it uses 32-bit fixed point, which is enough for HDR colors including emissive 
// colors on top of it. It's just HDR. :-)   

// So:

// 32*(4+1) = 160 bits per voxel, comparing to 32*2=64 bits per voxel (1x non-emission, 1x emission) with the RGBA8 running average approach, but 
// which supports only LDR colors. Indeed, it needs more memory bandwidth, but it's worth it, because it supports HDR colors, and it doesn't need  
// separate volumes for non-emissive and emissive voxels.

// 6 sides, 6 volumes, for multi directional anisotropic voxels, because a cube of voxel has 6 sides

layout (set = 1, binding = 1, std140) readonly uniform VoxelGridData {
  #include "voxelgriddata_uniforms.glsl"
} voxelGridData;

layout (set = 1, binding = 2, std430) coherent buffer VoxelGridContentData {
  uvec4 data[];
} voxelGridContentData;

layout (set = 1, binding = 3, std430) coherent buffer VoxelGridContentMetaData {
  uint data[];
} voxelGridContentMetaData;

bool aabbTriangleIntersection(vec3 aabbMin, vec3 aabbMax, vec3 v0, vec3 v1, vec3 v2){

	if(!(all(greaterThanEqual(aabbMax, min(v0, min(v1, v2)))) && 
       all(lessThanEqual(aabbMin, max(v0, max(v1, v2)))))){
    return false;
  }

  vec3 e0 = v1 - v0,
       e1 = v2 - v1,
       e2 = v0 - v2,
       n = normalize(cross(e0, e1)),
       dp = aabbMax - aabbMin,
       c = vec3(
             (n.x > 0.0) ? dp.x : 0.0,
             (n.y > 0.0) ? dp.y : 0.0,
             (n.z > 0.0) ? dp.z : 0.0
           );

  if(((dot(n, aabbMin) + dot(n, c - v0)) * (dot(n, aabbMin) + dot(n, (dp - c) - v0))) > 0.0){
    return false;
  }

 
  {
    float s = sign(n.z);
    vec2 ne0 = vec2(-e0.y, e0.x) * s,
         ne1 = vec2(-e1.y, e1.x) * s,
         ne2 = vec2(-e2.y, e2.x) * s;
    if(((dot(ne0, aabbMin.xy) + ((max(0.0, dp.x * ne0.x) + max(0.0, dp.y * ne0.y)) - dot(ne0, v0.xy))) < 0.0) ||
       ((dot(ne1, aabbMin.xy) + ((max(0.0, dp.x * ne1.x) + max(0.0, dp.y * ne1.y)) - dot(ne1, v1.xy))) < 0.0) ||
       ((dot(ne2, aabbMin.xy) + ((max(0.0, dp.x * ne2.x) + max(0.0, dp.y * ne2.y)) - dot(ne2, v2.xy))) < 0.0)){
      return false;
    }
  }

  {
    float s = sign(n.y);
    vec2 ne0 = vec2(-e0.x, e0.z) * s,
         ne1 = vec2(-e1.x, e1.z) * s,
         ne2 = vec2(-e2.x, e2.z) * s;
    if(((dot(ne0, aabbMin.zx) + ((max(0.0, dp.z * ne0.x) + max(0.0, dp.x * ne0.y)) - dot(ne0, v0.zx))) < 0.0) ||
       ((dot(ne1, aabbMin.zx) + ((max(0.0, dp.z * ne1.x) + max(0.0, dp.x * ne1.y)) - dot(ne1, v1.zx))) < 0.0) ||
       ((dot(ne2, aabbMin.zx) + ((max(0.0, dp.z * ne2.x) + max(0.0, dp.x * ne2.y)) - dot(ne2, v2.zx))) < 0.0)){
      return false;
    }
  }  

  {
    float s = sign(n.x);
    vec2 ne0 = vec2(-e0.z, e0.y) * s,
         ne1 = vec2(-e1.z, e1.y) * s,
         ne2 = vec2(-e2.z, e2.y) * s;
    return !(((dot(ne0, aabbMin.yz) + ((max(0.0, dp.y * ne0.x) + max(0.0, dp.z * ne0.y)) - dot(ne0, v0.yz))) < 0.0) ||
             ((dot(ne1, aabbMin.yz) + ((max(0.0, dp.y * ne1.x) + max(0.0, dp.z * ne1.y)) - dot(ne1, v1.yz))) < 0.0) ||
             ((dot(ne2, aabbMin.yz) + ((max(0.0, dp.y * ne2.x) + max(0.0, dp.z * ne2.y)) - dot(ne2, v2.yz))) < 0.0));
  }
  
}                

#endif

#endif