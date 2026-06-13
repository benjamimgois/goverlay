#ifndef PARTICLE_BVH_GLSL
#define PARTICLE_BVH_GLSL

// Shared layout for the per-frame GPU-constructed particle LBVH (Morton -> radix sort -> Karras hierarchy -> AABB refit),
// software-traced from gi_ddgi_trace.comp to inject emissive/transparent particles (not in the hardware ray-tracing BLAS)
// into the DDGI probe irradiance. All build shaders bind the same descriptor set (set 0, bindings below); each uses a subset.
//
// The array is always processed at the fixed padded size PARTICLE_BVH_CAPACITY (= MaxParticles, a power of two), with the
// [particleCount, PARTICLE_BVH_CAPACITY) tail filled with sentinel Morton keys (0xffffffff) so the sort is dispatch-count-static;
// the hierarchy/traversal only ever look at the first particleCount sorted entries.

#define PARTICLE_BVH_CAPACITY 65536u   // must match TpvScene3D.MaxParticles
#define PARTICLE_BVH_MAX_NODES 131072u // 2*CAPACITY (>= 2*N-1 for any N<=CAPACITY)
#define PARTICLE_BVH_RADIX_BITS 8u
#define PARTICLE_BVH_RADIX_BINS 256u   // 1u << PARTICLE_BVH_RADIX_BITS
#define PARTICLE_BVH_WORKGROUP 256u
#define PARTICLE_BVH_NUM_GROUPS 256u   // CAPACITY / WORKGROUP
#define PARTICLE_BVH_INVALID 0xffffffffu

// Emitter sphere extracted from one alive particle.
struct ParticleEmitter {
  vec4 positionRadius; // xyz = world-space center, w = radius
  vec4 emissionType;   // xyz = emissive radiance (linear), w = type: 0.0 = additive/transparent, 1.0 = opaque
};

// Unified LBVH node. Internal nodes occupy indices [0, N-2], leaf nodes [N-1, 2N-2] (leaf k -> node N-1+k).
// A node at index >= (N-1) is a leaf. Internal: aabbMin.w = left child index, aabbMax.w = right child index (uint bitcast).
// Leaf: aabbMin.w = primitive (emitter) index, aabbMax.w = PARTICLE_BVH_INVALID sentinel.
struct ParticleBVHNode {
  vec4 aabbMin; // xyz = AABB min, w = leftChild (internal) | primIndex (leaf)
  vec4 aabbMax; // xyz = AABB max, w = rightChild (internal) | PARTICLE_BVH_INVALID (leaf)
};

#ifdef PARTICLE_BVH_BINDINGS
// The build-pass descriptor set (set 0). gi_ddgi_trace.comp does NOT include this; it binds emitters+nodes on its own set.

layout(set = 0, binding = 0, std430) buffer ParticleEmitterBuffer {
  ParticleEmitter emitters[];
} particleEmitterBuffer;

layout(set = 0, binding = 1, std430) buffer ParticleMortonBufferA {
  uvec2 data[]; // x = Morton key (sentinel 0xffffffff for padding), y = emitter index payload
} particleMortonBufferA;

layout(set = 0, binding = 2, std430) buffer ParticleMortonBufferB {
  uvec2 data[];
} particleMortonBufferB;

layout(set = 0, binding = 3, std430) buffer ParticleRadixHistogramBuffer {
  uint data[]; // PARTICLE_BVH_RADIX_BINS * PARTICLE_BVH_NUM_GROUPS, laid out as [bin * NUM_GROUPS + group]
} particleRadixHistogramBuffer;

layout(set = 0, binding = 4, std430) coherent buffer ParticleBVHNodeBuffer {
  ParticleBVHNode nodes[];
} particleBVHNodeBuffer;

layout(set = 0, binding = 5, std430) buffer ParticleBVHParentBuffer {
  uint parents[]; // parent node index per node (PARTICLE_BVH_INVALID for the root)
} particleBVHParentBuffer;

layout(set = 0, binding = 6, std430) coherent buffer ParticleBVHRefitCounterBuffer {
  uint counters[]; // one atomic visit counter per internal node, reset each build
} particleBVHRefitCounterBuffer;

layout(set = 0, binding = 7, std430) coherent buffer ParticleBVHBoundsBuffer {
  uint data[6]; // [0..2] = min (ordered-uint flipped), [3..5] = max (ordered-uint flipped)
} particleBVHBoundsBuffer;
#endif // PARTICLE_BVH_BINDINGS

// --- float <-> monotonic-uint mapping for atomic min/max bounds (canonical radix "float flip") ---
uint particleBVHFloatFlip(float f){
  uint i = floatBitsToUint(f);
  uint mask = uint(-int(i >> 31u)) | 0x80000000u;
  return i ^ mask;
}
float particleBVHFloatUnflip(uint u){
  uint mask = ((u >> 31u) - 1u) | 0x80000000u;
  return uintBitsToFloat(u ^ mask);
}

// --- 30-bit Morton code from a position normalized to [0,1]^3 ---
uint particleBVHExpandBits10(uint v){ // v in [0,1023] -> bits spread with two zero bits between each
  v = (v * 0x00010001u) & 0xFF0000FFu;
  v = (v * 0x00000101u) & 0x0F00F00Fu;
  v = (v * 0x00000011u) & 0xC30C30C3u;
  v = (v * 0x00000005u) & 0x49249249u;
  return v;
}
uint particleBVHMorton3D(vec3 p){ // p in [0,1]
  vec3 q = clamp(p * 1024.0, vec3(0.0), vec3(1023.0));
  uint xx = particleBVHExpandBits10(uint(q.x));
  uint yy = particleBVHExpandBits10(uint(q.y));
  uint zz = particleBVHExpandBits10(uint(q.z));
  return (xx << 2u) | (yy << 1u) | zz;
}

#endif // PARTICLE_BVH_GLSL
