#ifndef GLOBAL_ILLUMINATION_SURFEL_GLSL
#define GLOBAL_ILLUMINATION_SURFEL_GLSL

// =====================================================================================================================
//  Surfel-based global illumination — shared data structures, world-space hash grid addressing and SH irradiance
//  sampling, in the spirit of EA SEED's "Global Illumination Based on Surfels" (Halen, 2021).
//
//  A surfel is an oriented surface element (position + normal + radius) that persistently caches indirect radiance as
//  an L1 RGB spherical-harmonics probe. Surfels live in a fixed GPU pool and are indexed by a world-space spatial hash
//  grid so the spawn / coverage / trace / shading passes can find the surfels near any world position in O(cell). Each
//  frame a few rays per surfel are traced against the TLAS (via gi_rt_gather.glsl) and the result is integrated into the
//  surfel's SH as a running average, giving temporally converged, multi-bounce-capable indirect lighting.
//
//  This header is shared by:
//    - the surfel compute passes  (gi_surfel_*.comp)        — they declare the buffers read-write and #include this for
//                                                              the record layout + hashing,
//    - the shading consumers      (mesh.frag, planet_*.frag) — they #define GLOBAL_ILLUMINATION_SURFEL_SAMPLE and a
//                                                              descriptor set index, and this header then declares the
//                                                              read-only buffers + giSurfelSampleIrradiance().
//
//  The GPU buffer layouts below MUST stay in sync with the Pascal side (TpvScene3DRendererInstance surfel resources).
// =====================================================================================================================

#include "sphericalharmonics.glsl"
#include "octahedral.glsl"

// --- Compile-time capacity / hashing configuration (must match the Pascal-side allocation) --------------------------

#ifndef GI_SURFEL_MAX_COUNT
  #define GI_SURFEL_MAX_COUNT 65536           // surfel pool capacity
#endif

#ifndef GI_SURFEL_HASH_CELL_COUNT
  #define GI_SURFEL_HASH_CELL_COUNT 131072    // spatial-hash bucket count; MUST be a power of two (>= ~2x the pool)
#endif

#ifndef GI_SURFEL_MAX_PER_CELL
  #define GI_SURFEL_MAX_PER_CELL 32           // surfel index slots stored per hash cell (overflow is dropped)
#endif

#define GI_SURFEL_HASH_CELL_MASK (uint(GI_SURFEL_HASH_CELL_COUNT) - 1u)

// Confidence / fade-in: a surfel's contribution weight at gather time is scaled by saturate(sampleCount / this), so a freshly
// spawned surfel (count 0, not yet traced -> zero/garbage radiance) contributes nothing and fades in as it converges. Without
// it, fresh surfels dump un-converged radiance into the gather -> flicker + wrong brightness. (count = Surfel.normalCount.w.)
#ifndef GI_SURFEL_CONFIDENCE_SAMPLES
  #define GI_SURFEL_CONFIDENCE_SAMPLES 8.0
#endif

// Spatial anisotropy: the distance component ALONG the surfel normal is multiplied by this before the radius test/falloff,
// so a surfel acts as a flat disc hugging its surface rather than an isotropic sphere. An isotropic sphere intersects a wall
// as a visible circle (the "decal" artefact) and bleeds in front of/behind the surface; squishing the normal axis keeps the
// influence on-surface. Higher = flatter.
#ifndef GI_SURFEL_NORMAL_SQUISH
  #define GI_SURFEL_NORMAL_SQUISH 3.0
#endif

// Per-surfel radial depth atlas for OCCLUSION: a tiny full-sphere octahedral atlas (GI_SURFEL_DEPTH_OCT_SIZE² texels), each
// texel a half-packed Chebyshev moment pair (mean, mean² of the hit distance the surfel's rays saw in that direction). At
// shading the gather rejects a surfel whose recorded geometry occludes the shaded point (point farther than the stored mean
// in the surfel->point direction) → stops surfels leaking irradiance through walls (#1). Stored inline in the surfel record
// (no extra buffer/binding). 0 texel = uninitialized = fully visible.
#ifndef GI_SURFEL_DEPTH_OCT_SIZE
  #define GI_SURFEL_DEPTH_OCT_SIZE 4
#endif
#define GI_SURFEL_DEPTH_TEXELS (GI_SURFEL_DEPTH_OCT_SIZE * GI_SURFEL_DEPTH_OCT_SIZE)
// Hit distances stored in the radial depth atlas are clamped to this (meters) before half-packing: a miss uses the trace's
// huge tMax (~1e6), and mean² of that overflows fp16 (max ~65504) to +Inf, which would stick a texel "visible" forever. Only
// near occluders (within the gather radius) matter for the occlusion test anyway, so a modest cap is both safe and correct.
#ifndef GI_SURFEL_DEPTH_MAX_DIST
  #define GI_SURFEL_DEPTH_MAX_DIST 64.0
#endif

// Surfel "alive" flag bit.
#define GI_SURFEL_FLAG_ALIVE 1u

// --- Compile-time radiance storage representation (mirrors GI_DDGI_STORAGE) -----------------------------------------
// Each surfel caches its incident radiance as either an octahedral irradiance atlas, an L1 RGB SH probe, or an L2 RGB
// SH probe. L1/L2 share all code through the SURFEL_SH_* aliases (same trick as the DDGI DDGI_SH_* macros); OCT is a
// separate small per-surfel octahedral grid. The chosen mode sets the per-surfel payload size (GI_SURFEL_PAYLOAD_UVEC2_COUNT),
// which the Pascal side must mirror when allocating the surfel pool.
#define GI_SURFEL_STORAGE_OCT_VALUE 0  // per-surfel octahedral irradiance atlas (GI_SURFEL_OCT_SIZE^2 RGB texels)
#define GI_SURFEL_STORAGE_L1_VALUE  1  // L1 RGB spherical harmonics (4 coefficients)
#define GI_SURFEL_STORAGE_L2_VALUE  2  // L2 RGB spherical harmonics (9 coefficients)

#ifndef GI_SURFEL_STORAGE
  #define GI_SURFEL_STORAGE GI_SURFEL_STORAGE_L1_VALUE
#endif

#if (GI_SURFEL_STORAGE == GI_SURFEL_STORAGE_L1_VALUE) || (GI_SURFEL_STORAGE == GI_SURFEL_STORAGE_L2_VALUE)
  #define GI_SURFEL_STORAGE_IS_SH 1
#else
  #define GI_SURFEL_STORAGE_IS_SH 0
#endif

#if GI_SURFEL_STORAGE == GI_SURFEL_STORAGE_L2_VALUE
  #define SURFEL_SH_TYPE      SHC3CoefficientsL2
  #define SURFEL_SH_ZERO      SHC3CoefficientsL2Zero
  #define SURFEL_SH_ADD       SHC3CoefficientsL2Add
  #define SURFEL_SH_MUL       SHC3CoefficientsL2Mul
  #define SURFEL_SH_DIV       SHC3CoefficientsL2Div
  #define SURFEL_SH_LERP      SHC3CoefficientsL2Lerp
  #define SURFEL_SH_PROJECT   ProjectOntoSHC3CoefficientsL2
  #define SURFEL_SH_IRRADIANCE SHC3CoefficientsL2CalculateIrradiance
  #define GI_SURFEL_PAYLOAD_UVEC2_COUNT 7  // 9 RGB coeffs = 27 halves -> 28 halves -> 7 uvec2 (4 halves each)
#elif GI_SURFEL_STORAGE == GI_SURFEL_STORAGE_L1_VALUE
  #define SURFEL_SH_TYPE      SHC3CoefficientsL1
  #define SURFEL_SH_ZERO      SHC3CoefficientsL1Zero
  #define SURFEL_SH_ADD       SHC3CoefficientsL1Add
  #define SURFEL_SH_MUL       SHC3CoefficientsL1Mul
  #define SURFEL_SH_DIV       SHC3CoefficientsL1Div
  #define SURFEL_SH_LERP      SHC3CoefficientsL1Lerp
  #define SURFEL_SH_PROJECT   ProjectOntoSHC3CoefficientsL1
  #define SURFEL_SH_IRRADIANCE SHC3CoefficientsL1CalculateIrradiance
  #define GI_SURFEL_PAYLOAD_UVEC2_COUNT 3  // 4 RGB coeffs = 12 halves -> 3 uvec2
#else // GI_SURFEL_STORAGE_OCT_VALUE
  #ifndef GI_SURFEL_OCT_SIZE
    #define GI_SURFEL_OCT_SIZE 4
  #endif
  // One uvec2 per RGB texel (texel-aligned packing: .x = packHalf(R,G), .y = packHalf(B,0)).
  #define GI_SURFEL_PAYLOAD_UVEC2_COUNT ((GI_SURFEL_OCT_SIZE) * (GI_SURFEL_OCT_SIZE))
#endif

// --- Surfel record (std430) -----------------------------------------------------------------------------------------
// Layout mirrored by the Pascal record TpvScene3DRendererInstanceSurfel; the payload size depends on GI_SURFEL_STORAGE
// (L1 = 3, L2 = 7, OCT = ceil(N^2*3/4) uvec2). Base record = 16 + 16 + payload*8 + 8 bytes.
struct Surfel {
  vec4 positionRadius;   // xyz = world position (meters), w = radius (meters)
  vec4 normalCount;      // xyz = world-space surface normal, w = accumulated sample count (as float)
  uvec2 payload[GI_SURFEL_PAYLOAD_UVEC2_COUNT]; // packed radiance: SH (L1/L2) or octahedral irradiance atlas (half-float)
  uint lastFrame;        // frame index this surfel was last touched (for recycling stale surfels)
  uint flags;            // GI_SURFEL_FLAG_* bits
  float skyVisibility;   // fraction of this surfel's trace rays that escaped to the sky (temporally averaged); occludes the
                         // environment IBL specular at shading in enclosed areas — the surfel analogue of DDGI sky-visibility
  uint depth[GI_SURFEL_DEPTH_TEXELS]; // radial depth atlas: per (full-sphere oct) direction, packHalf2x16(meanDist, meanDist²) for the Chebyshev occlusion test
};

// --- Payload (un)packing helpers ------------------------------------------------------------------------------------

#if GI_SURFEL_STORAGE_IS_SH

// Decode the SH probe stored in a surfel's payload.
SURFEL_SH_TYPE surfelLoadSH(const in Surfel surfel){
#if GI_SURFEL_STORAGE == GI_SURFEL_STORAGE_L2_VALUE
  float v[28];
  for(int i = 0; i < 7; i++){
    vec2 a = unpackHalf2x16(surfel.payload[i].x);
    vec2 b = unpackHalf2x16(surfel.payload[i].y);
    v[(i * 4) + 0] = a.x; v[(i * 4) + 1] = a.y; v[(i * 4) + 2] = b.x; v[(i * 4) + 3] = b.y;
  }
  return SHC3CoefficientsL2Create(vec3(v[0], v[1], v[2]),    vec3(v[3], v[4], v[5]),    vec3(v[6], v[7], v[8]),
                                  vec3(v[9], v[10], v[11]),  vec3(v[12], v[13], v[14]), vec3(v[15], v[16], v[17]),
                                  vec3(v[18], v[19], v[20]), vec3(v[21], v[22], v[23]), vec3(v[24], v[25], v[26]));
#else
  return SHC3CoefficientsL1Unpack(PackedSHC3CoefficientsL1(uvec2[3](surfel.payload[0], surfel.payload[1], surfel.payload[2])));
#endif
}

#endif // GI_SURFEL_STORAGE_IS_SH

#if !GI_SURFEL_STORAGE_IS_SH

// Octahedral irradiance atlas helpers (one uvec2 per RGB texel; texel index = y*N + x).
vec3 surfelOctLoadTexel(const in Surfel surfel, const in int texelIndex){
  vec2 rg = unpackHalf2x16(surfel.payload[texelIndex].x);
  vec2 ba = unpackHalf2x16(surfel.payload[texelIndex].y);
  return vec3(rg.x, rg.y, ba.x);
}

// World direction at the centre of an octahedral atlas texel.
vec3 surfelOctTexelDirection(const in int x, const in int y){
  vec2 uv = (vec2(float(x), float(y)) + vec2(0.5)) / float(GI_SURFEL_OCT_SIZE); // [0,1]
  return normalize(octSignedDecode(fma(uv, vec2(2.0), vec2(-1.0))));            // -> [-1,1] -> S^2
}

// Sample the surfel's octahedral irradiance atlas in a direction (bilinear, with wrap-correct edge clamping skipped for
// simplicity — the atlas is tiny and irradiance is smooth, so nearest-with-clamp is visually sufficient).
vec3 surfelOctSample(const in Surfel surfel, const in vec3 direction){
  vec2 uv = fma(octSignedEncode(normalize(direction)), vec2(0.5), vec2(0.5)); // [-1,1] -> [0,1]
  ivec2 texel = clamp(ivec2(uv * float(GI_SURFEL_OCT_SIZE)), ivec2(0), ivec2(GI_SURFEL_OCT_SIZE - 1));
  return surfelOctLoadTexel(surfel, (texel.y * GI_SURFEL_OCT_SIZE) + texel.x);
}

#endif // !GI_SURFEL_STORAGE_IS_SH

// --- Surfel uniform parameters (std140 UBO) -------------------------------------------------------------------------
// Layout mirrored by the Pascal record TpvScene3DRendererInstanceSurfelUniformBufferData.
struct SurfelUniforms {
  vec4 cameraPositionCellSize;  // xyz = camera world position, w = base hash cell size (meters)
  uvec4 countsFrame;            // x = maxSurfels, y = hashCellCount, z = maxPerCell, w = frameIndex
  vec4 params;                  // x = surfel radius, y = temporal hysteresis (0..1), z = recycle frame age, w = spawn coverage threshold
};

// --- World-space hash grid ------------------------------------------------------------------------------------------

// The integer cell coordinate a world position falls into. Fixed cell size for now (a future improvement is camera
// distance dependent clipmap-style cell scaling à la SEED; that only changes this function + the hash level term).
ivec3 giSurfelCellCoord(const in vec3 worldPosition, const in float cellSize){
  return ivec3(floor(worldPosition / max(cellSize, 1e-4)));
}

// Spatial hash of a cell coordinate into [0, GI_SURFEL_HASH_CELL_COUNT). Classic three-prime xor hash.
uint giSurfelCellHash(const in ivec3 cellCoord){
  uint h = (uint(cellCoord.x) * 73856093u) ^ (uint(cellCoord.y) * 19349663u) ^ (uint(cellCoord.z) * 83492791u);
  return h & GI_SURFEL_HASH_CELL_MASK;
}

// --- Per-surfel radial depth (Chebyshev occlusion) -----------------------------------------------------------------
// Texel index in a surfel's radial depth atlas for a (world-space) direction, full-sphere octahedral mapping.
int surfelDepthTexel(const in vec3 dir){
  vec2 uv = fma(octSignedEncode(normalize(dir)), vec2(0.5), vec2(0.5)); // [-1,1] -> [0,1]
  ivec2 t = clamp(ivec2(uv * float(GI_SURFEL_DEPTH_OCT_SIZE)), ivec2(0), ivec2(GI_SURFEL_DEPTH_OCT_SIZE - 1));
  return (t.y * GI_SURFEL_DEPTH_OCT_SIZE) + t.x;
}

// Visibility (0..1) of worldPosition FROM the surfel, via the surfel's radial depth atlas (Chebyshev / VSM). If the point is
// farther than the geometry the surfel recorded in that direction, it is occluded (-> low weight, no leak through walls).
// An uninitialized texel (0) means the surfel never traced that direction -> treat as fully visible.
float surfelDepthOcclusion(const in Surfel surfel, const in vec3 worldPosition){
  vec3 d = worldPosition - surfel.positionRadius.xyz;
  float z = length(d);
  if(z < 1e-4){
    return 1.0;
  }
  vec2 m = unpackHalf2x16(surfel.depth[surfelDepthTexel(d / z)]); // (meanDist, meanDist²)
  if(m.y <= 0.0 || z <= m.x){
    return 1.0; // uninitialized direction, or the point is in front of / at the recorded occluder
  }
  float variance = max(m.y - (m.x * m.x), 1e-5);
  float dd = z - m.x;
  float chebyshev = variance / (variance + (dd * dd));
  return clamp(chebyshev * chebyshev, 0.0, 1.0); // sharpen
}

// =====================================================================================================================
//  Shading-side sampling path (mesh.frag / planet_*.frag).
//
//  The includer must, before the #include:
//    - #define GLOBAL_ILLUMINATION_SURFEL_SAMPLE
//    - #define GI_SURFEL_DESCRIPTOR_SET <set index> (mesh.frag = 2, planets = 4)
//  This then declares the read-only surfel buffers and giSurfelSampleIrradiance().
// =====================================================================================================================

#ifdef GLOBAL_ILLUMINATION_SURFEL_SAMPLE

#ifndef GI_SURFEL_DESCRIPTOR_SET
  #error "global_illumination_surfel.glsl: #define GI_SURFEL_DESCRIPTOR_SET before including with GLOBAL_ILLUMINATION_SURFEL_SAMPLE."
#endif

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 0, std140) uniform SurfelUniformBuffer {
  SurfelUniforms surfelData;
};

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 1, std430) readonly buffer SurfelBuffer {
  Surfel surfels[];
};

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 2, std430) readonly buffer SurfelGridCellBuffer {
  uint surfelGridCells[]; // GI_SURFEL_HASH_CELL_COUNT * GI_SURFEL_MAX_PER_CELL surfel indices
};

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 3, std430) readonly buffer SurfelGridCellCountBuffer {
  uint surfelGridCellCounts[]; // GI_SURFEL_HASH_CELL_COUNT live-surfel counts per cell
};

// Gather the surfels in the hash cell containing worldPosition and blend their cosine-convolved SH irradiance, weighted
// by spatial proximity (smooth falloff over the surfel radius) and normal agreement (back-facing surfels rejected). The
// cell size is chosen (Pascal side) >= the surfel radius so a single-cell gather already covers a point's neighbourhood;
// returns irradiance E (multiply by albedo/PI like getIBLDiffuse's result for the diffuse contribution).
vec3 giSurfelSampleIrradiance(const in vec3 worldPosition, const in vec3 normal, out float skyVisibility){
  float cellSize = surfelData.cameraPositionCellSize.w;
  ivec3 cellCoord = giSurfelCellCoord(worldPosition, cellSize);
  uint cell = giSurfelCellHash(cellCoord);

  uint count = min(surfelGridCellCounts[cell], uint(GI_SURFEL_MAX_PER_CELL));
  uint base = cell * uint(GI_SURFEL_MAX_PER_CELL);

#if GI_SURFEL_STORAGE_IS_SH
  SURFEL_SH_TYPE accumSH = SURFEL_SH_ZERO();
#else
  vec3 accumIrradiance = vec3(0.0);
#endif
  float accumWeight = 0.0;
  float accumSkyVis = 0.0;

  for(uint i = 0u; i < count; i++){
    uint surfelIndex = surfelGridCells[base + i];
    if(surfelIndex >= uint(GI_SURFEL_MAX_COUNT)){
      continue;
    }
    Surfel surfel = surfels[surfelIndex];
    if((surfel.flags & GI_SURFEL_FLAG_ALIVE) == 0u){
      continue;
    }

    float radius = max(surfel.positionRadius.w, 1e-3);
    // Anisotropic ("squished") distance: penalise the component along the surfel normal so the surfel is a flat disc hugging
    // its surface, not an isotropic sphere (which intersects a wall as a visible circle / bleeds off-surface).
    vec3 toSurfel = worldPosition - surfel.positionRadius.xyz;
    float dN = dot(toSurfel, surfel.normalCount.xyz);
    vec3 dT = toSurfel - (dN * surfel.normalCount.xyz);
    float md = sqrt(dot(dT, dT) + ((dN * GI_SURFEL_NORMAL_SQUISH) * (dN * GI_SURFEL_NORMAL_SQUISH)));
    if(md >= radius){
      continue; // outside this surfel's influence
    }

    // Normal agreement: reject surfels facing away from the shaded surface (avoids leaking through thin geometry).
    float normalWeight = clamp(dot(surfel.normalCount.xyz, normal), 0.0, 1.0);
    if(normalWeight <= 0.0){
      continue;
    }

    // Smooth spatial falloff towards the surfel radius.
    float spatialWeight = smoothstep(radius, 0.0, md); // smooth falloff over the (anisotropic) radius -> no hard disc edge

    float weight = spatialWeight * normalWeight * clamp(surfel.normalCount.w * (1.0 / GI_SURFEL_CONFIDENCE_SAMPLES), 0.0, 1.0) // confidence/fade-in: un-converged (low sample-count) surfels contribute proportionally less
                 * surfelDepthOcclusion(surfel, worldPosition); // radial-depth occlusion: surfels whose recorded geometry blocks this point contribute nothing (no leak through walls)
    if(weight <= 0.0){
      continue;
    }

#if GI_SURFEL_STORAGE_IS_SH
    accumSH = SURFEL_SH_ADD(accumSH, SURFEL_SH_MUL(surfelLoadSH(surfel), weight));
#else
    accumIrradiance += surfelOctSample(surfel, normal) * weight; // per-surfel oct atlas already stores irradiance
#endif
    accumWeight += weight;
    accumSkyVis += surfel.skyVisibility * weight;
  }

  if(accumWeight <= 0.0){
    skyVisibility = 1.0; // no surfels here -> leave the env IBL specular unoccluded
    return vec3(0.0);
  }
  skyVisibility = accumSkyVis / accumWeight;

#if GI_SURFEL_STORAGE_IS_SH
  accumSH = SURFEL_SH_DIV(accumSH, accumWeight);
  return max(vec3(0.0), SURFEL_SH_IRRADIANCE(accumSH, normal)); // cosine-convolved evaluation -> irradiance E
#else
  return max(vec3(0.0), accumIrradiance / accumWeight);
#endif
}

#endif // GLOBAL_ILLUMINATION_SURFEL_SAMPLE

// =====================================================================================================================
//  Compute-side read-write path (gi_surfel_*.comp).
//
//  The includer must, before the #include:
//    - #define GLOBAL_ILLUMINATION_SURFEL_COMPUTE
//    - #define GI_SURFEL_DESCRIPTOR_SET <set index>   (the surfel passes use set 0)
//  This declares the buffers read-write plus the allocator / grid-insert helpers shared by the passes.
//
//  Free-list allocation is race-free via parity double-buffering: each frame the RECYCLE pass rebuilds the free list
//  into bank (frameIndex & 1), and the SPAWN pass of the NEXT frame consumes the bank the previous recycle filled
//  (bank ^ 1). The clear pass zeroes the spawn ticket counter and the write bank's count at frame start; the read bank
//  is never written in the same frame the spawn pass reads it, so no read/write hazard exists.
// =====================================================================================================================

#ifdef GLOBAL_ILLUMINATION_SURFEL_COMPUTE

#ifndef GI_SURFEL_DESCRIPTOR_SET
  #error "global_illumination_surfel.glsl: #define GI_SURFEL_DESCRIPTOR_SET before including with GLOBAL_ILLUMINATION_SURFEL_COMPUTE."
#endif

#define GI_SURFEL_INVALID_INDEX 0xffffffffu

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 0, std140) uniform SurfelUniformBuffer {
  SurfelUniforms surfelData;
};

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 1, std430) buffer SurfelBuffer {
  Surfel surfels[];
};

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 2, std430) buffer SurfelGridCellBuffer {
  uint surfelGridCells[]; // GI_SURFEL_HASH_CELL_COUNT * GI_SURFEL_MAX_PER_CELL
};

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 3, std430) buffer SurfelGridCellCountBuffer {
  uint surfelGridCellCounts[]; // GI_SURFEL_HASH_CELL_COUNT
};

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 4, std430) buffer SurfelStatsBuffer {
  uint surfelSpawnCursor;   // atomic spawn ticket (zeroed each frame by the clear pass)
  uint surfelAliveCount;    // live surfel count (debug / coverage budgeting)
  uint surfelFreeCount0;    // free-list length of bank 0
  uint surfelFreeCount1;    // free-list length of bank 1
};

layout(set = GI_SURFEL_DESCRIPTOR_SET, binding = 5, std430) buffer SurfelFreeListBuffer {
  uint surfelFreeList[]; // 2 * GI_SURFEL_MAX_COUNT (two parity banks)
};

uint giSurfelFrameIndex(){ return surfelData.countsFrame.w; }
uint giSurfelFreeBankWrite(){ return giSurfelFrameIndex() & 1u; }
uint giSurfelFreeBankRead(){ return giSurfelFreeBankWrite() ^ 1u; }

// Insert a surfel index into its world-space hash cell (atomic append, overflow dropped).
void giSurfelGridInsert(const in uint surfelIndex, const in vec3 worldPosition){
  uint cell = giSurfelCellHash(giSurfelCellCoord(worldPosition, surfelData.cameraPositionCellSize.w));
  uint slot = atomicAdd(surfelGridCellCounts[cell], 1u);
  if(slot < uint(GI_SURFEL_MAX_PER_CELL)){
    surfelGridCells[(cell * uint(GI_SURFEL_MAX_PER_CELL)) + slot] = surfelIndex;
  }
}

// Allocate a free surfel slot from the read bank (the list the previous frame's recycle filled). Returns
// GI_SURFEL_INVALID_INDEX when the pool is exhausted for this frame.
uint giSurfelAllocate(){
  uint bank = giSurfelFreeBankRead();
  uint available = (bank == 0u) ? surfelFreeCount0 : surfelFreeCount1;
  uint ticket = atomicAdd(surfelSpawnCursor, 1u);
  if(ticket >= available){
    return GI_SURFEL_INVALID_INDEX;
  }
  return surfelFreeList[(bank * uint(GI_SURFEL_MAX_COUNT)) + ticket];
}

// Push a free slot onto the write bank's free list (used by the recycle pass to rebuild the list for next frame).
void giSurfelFree(const in uint surfelIndex){
  uint bank = giSurfelFreeBankWrite();
  uint w;
  if(bank == 0u){
    w = atomicAdd(surfelFreeCount0, 1u);
  }else{
    w = atomicAdd(surfelFreeCount1, 1u);
  }
  if(w < uint(GI_SURFEL_MAX_COUNT)){
    surfelFreeList[(bank * uint(GI_SURFEL_MAX_COUNT)) + w] = surfelIndex;
  }
}

// Coverage estimate at a world position/normal: the summed proximity/normal weight of the surfels in the cell. The
// spawn pass spawns a new surfel when this is below surfelData.params.w. Mirrors the shading gather's weighting.
float giSurfelCoverage(const in vec3 worldPosition, const in vec3 normal){
  uint cell = giSurfelCellHash(giSurfelCellCoord(worldPosition, surfelData.cameraPositionCellSize.w));
  uint count = min(surfelGridCellCounts[cell], uint(GI_SURFEL_MAX_PER_CELL));
  uint base = cell * uint(GI_SURFEL_MAX_PER_CELL);
  float coverage = 0.0;
  for(uint i = 0u; i < count; i++){
    uint surfelIndex = surfelGridCells[base + i];
    if(surfelIndex >= uint(GI_SURFEL_MAX_COUNT)){
      continue;
    }
    Surfel surfel = surfels[surfelIndex];
    if((surfel.flags & GI_SURFEL_FLAG_ALIVE) == 0u){
      continue;
    }
    float radius = max(surfel.positionRadius.w, 1e-3);
    // Anisotropic ("squished") distance: penalise the component along the surfel normal so the surfel is a flat disc hugging
    // its surface, not an isotropic sphere (which intersects a wall as a visible circle / bleeds off-surface).
    vec3 toSurfel = worldPosition - surfel.positionRadius.xyz;
    float dN = dot(toSurfel, surfel.normalCount.xyz);
    vec3 dT = toSurfel - (dN * surfel.normalCount.xyz);
    float md = sqrt(dot(dT, dT) + ((dN * GI_SURFEL_NORMAL_SQUISH) * (dN * GI_SURFEL_NORMAL_SQUISH)));
    if(md >= radius){
      continue;
    }
    // Keep-alive: this surfel covers a currently-visible shading point (the spawn pass runs giSurfelCoverage at every
    // visible depth tile each frame). Refreshing its recycle timer HERE — driven by visibility — is the "still needed"
    // signal; the trace must NOT do it (it touches every surfel every frame, which would keep the whole pool alive forever
    // and starve newly-revealed regions). Surfels no longer near any visible surface stop being refreshed and age out.
    surfels[surfelIndex].lastFrame = giSurfelFrameIndex();
    float normalWeight = clamp(dot(surfel.normalCount.xyz, normal), 0.0, 1.0);
    float spatialWeight = smoothstep(radius, 0.0, md); // same anisotropic falloff as the gather, so coverage matches resolve
    coverage += spatialWeight * normalWeight;
  }
  return coverage;
}

// Compute-side irradiance gather (same weighting as the shading-side giSurfelSampleIrradiance, but on the read-write
// buffers) — used by the trace pass for the previous-frame multi-bounce feedback term.
vec3 giSurfelGatherIrradiance(const in vec3 worldPosition, const in vec3 normal){
  uint cell = giSurfelCellHash(giSurfelCellCoord(worldPosition, surfelData.cameraPositionCellSize.w));
  uint count = min(surfelGridCellCounts[cell], uint(GI_SURFEL_MAX_PER_CELL));
  uint base = cell * uint(GI_SURFEL_MAX_PER_CELL);
#if GI_SURFEL_STORAGE_IS_SH
  SURFEL_SH_TYPE accumSH = SURFEL_SH_ZERO();
#else
  vec3 accumIrradiance = vec3(0.0);
#endif
  float accumWeight = 0.0;
  for(uint i = 0u; i < count; i++){
    uint surfelIndex = surfelGridCells[base + i];
    if(surfelIndex >= uint(GI_SURFEL_MAX_COUNT)){
      continue;
    }
    Surfel surfel = surfels[surfelIndex];
    if((surfel.flags & GI_SURFEL_FLAG_ALIVE) == 0u){
      continue;
    }
    float radius = max(surfel.positionRadius.w, 1e-3);
    // Anisotropic ("squished") distance: penalise the component along the surfel normal so the surfel is a flat disc hugging
    // its surface, not an isotropic sphere (which intersects a wall as a visible circle / bleeds off-surface).
    vec3 toSurfel = worldPosition - surfel.positionRadius.xyz;
    float dN = dot(toSurfel, surfel.normalCount.xyz);
    vec3 dT = toSurfel - (dN * surfel.normalCount.xyz);
    float md = sqrt(dot(dT, dT) + ((dN * GI_SURFEL_NORMAL_SQUISH) * (dN * GI_SURFEL_NORMAL_SQUISH)));
    if(md >= radius){
      continue;
    }
    float normalWeight = clamp(dot(surfel.normalCount.xyz, normal), 0.0, 1.0);
    if(normalWeight <= 0.0){
      continue;
    }
    float spatialWeight = smoothstep(radius, 0.0, md); // smooth falloff over the (anisotropic) radius -> no hard disc edge
    float weight = spatialWeight * normalWeight * clamp(surfel.normalCount.w * (1.0 / GI_SURFEL_CONFIDENCE_SAMPLES), 0.0, 1.0) // confidence/fade-in: un-converged (low sample-count) surfels contribute proportionally less
                 * surfelDepthOcclusion(surfel, worldPosition); // radial-depth occlusion: surfels whose recorded geometry blocks this point contribute nothing (no leak through walls)
    if(weight <= 0.0){
      continue;
    }
#if GI_SURFEL_STORAGE_IS_SH
    accumSH = SURFEL_SH_ADD(accumSH, SURFEL_SH_MUL(surfelLoadSH(surfel), weight));
#else
    accumIrradiance += surfelOctSample(surfel, normal) * weight;
#endif
    accumWeight += weight;
  }
  if(accumWeight <= 0.0){
    return vec3(0.0);
  }
#if GI_SURFEL_STORAGE_IS_SH
  accumSH = SURFEL_SH_DIV(accumSH, accumWeight);
  return max(vec3(0.0), SURFEL_SH_IRRADIANCE(accumSH, normal));
#else
  return max(vec3(0.0), accumIrradiance / accumWeight);
#endif
}

// --- Surfel payload writers (compute-side) --------------------------------------------------------------------------

#if GI_SURFEL_STORAGE_IS_SH
void surfelStoreSH(const in uint surfelIndex, const in SURFEL_SH_TYPE sh){
#if GI_SURFEL_STORAGE == GI_SURFEL_STORAGE_L2_VALUE
  float v[28];
  for(int c = 0; c < 9; c++){ v[(c * 3) + 0] = sh.coefficients[c].r; v[(c * 3) + 1] = sh.coefficients[c].g; v[(c * 3) + 2] = sh.coefficients[c].b; }
  v[27] = 0.0;
  for(int i = 0; i < 7; i++){
    surfels[surfelIndex].payload[i] = uvec2(packHalf2x16(vec2(v[(i * 4) + 0], v[(i * 4) + 1])),
                                            packHalf2x16(vec2(v[(i * 4) + 2], v[(i * 4) + 3])));
  }
#else
  PackedSHC3CoefficientsL1 packed = SHC3CoefficientsL1Pack(sh);
  surfels[surfelIndex].payload[0] = packed.coefficients[0];
  surfels[surfelIndex].payload[1] = packed.coefficients[1];
  surfels[surfelIndex].payload[2] = packed.coefficients[2];
#endif
}
#else
void surfelOctStoreTexel(const in uint surfelIndex, const in int texelIndex, const in vec3 irradiance){
  surfels[surfelIndex].payload[texelIndex] = uvec2(packHalf2x16(vec2(irradiance.x, irradiance.y)),
                                                   packHalf2x16(vec2(irradiance.z, 0.0)));
}
#endif

#endif // GLOBAL_ILLUMINATION_SURFEL_COMPUTE

#endif // GLOBAL_ILLUMINATION_SURFEL_GLSL
