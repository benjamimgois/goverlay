#ifndef GI_DDGI_DATA_GLSL
#define GI_DDGI_DATA_GLSL

// =====================================================================================================================
//  DDGI data block — the unified per-in-flight DDGI field data.
//
//  ONE std430 readonly SSBO `ddgiData`, bound at the DDGI set's binding 0 (compute set 1 / mesh set 2 / planet set 4 — via
//  GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET/BINDING), shared identically by the compute passes and the fragment consumers. It
//  holds the cascade globals (the former uboGlobalIlluminationDDGIData) followed by the device-address pointers to the
//  point-access sub-buffers (ray-data, probe-data, SH-irradiance, age). Those sub-buffers stay buffer_reference (their
//  addresses live in this block); the bilinear-sampled atlases (visibility moments/sky, OCT irradiance) remain
//  descriptor-bound sampled images and are NOT part of this block.
//
//  The block is `readonly` (its own members — globals + pointers — are never written by the shaders); the buffers the
//  pointers reference ARE written, through the (non-readonly) buffer_reference handles read out of here (callers launder
//  the handle into a local first, so the readonly memory qualifier is not dropped on the accessor argument).
//
//  Requires GL_EXT_buffer_reference and the GI_DDGI_* dimension constants — it is included from global_illumination_ddgi.glsl
//  AFTER those constants (and only when GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET is defined, i.e. a DDGI shader with the
//  extension enabled), so it is never pulled into a constants-only includer.
// =====================================================================================================================

layout(buffer_reference, std430, buffer_reference_align = 16) buffer DDGIRayDataBuffer { vec4 data[]; };       // rgb = shaded radiance, a = distance (signed for fixed rays); idx = globalProbe*raysPerProbe + ray
layout(buffer_reference, std430, buffer_reference_align = 16) buffer DDGIProbeDataBuffer { vec4 data[]; };     // xyz = relocation offset, w = state; idx = physical probe slot + cascade*probesPerCascade

// SH-irradiance: ONE contiguous element (DDGI_SH_IMAGE_COUNT packed vec4) per probe, so a probe's whole SH is a single linear
// load/store (better coalescing than indexing individual vec4 by probe*COUNT+i). Indexed by the probe linear index.
#ifdef DDGI_SH_IMAGE_COUNT
struct DDGISHProbe { vec4 c[DDGI_SH_IMAGE_COUNT]; };
layout(buffer_reference, std430, buffer_reference_align = 16) buffer DDGIIrradianceSHBuffer { DDGISHProbe probes[]; };
#else
layout(buffer_reference, std430, buffer_reference_align = 16) buffer DDGIIrradianceSHBuffer { vec4 data[]; }; // OCT mode: unused placeholder (irradiance is a sampled image there)
#endif

// Per-probe convergence age (frames since (re)init, capped at the warmup length): a plain uint count, point-access only (the
// visibility update writes it, the irradiance update reads it for the warmup hysteresis ramp; never sampled by shading).
layout(buffer_reference, std430, buffer_reference_align = 16) buffer DDGIAgeBuffer { uint age[]; };

#ifdef GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET
// The unified data block: cascade globals (all vec4/ivec4 -> std140 == std430) followed by the BDA sub-buffer pointers. Bound
// to the per-in-flight data buffer (CPU writes the globals each frame; the sub-pointers are written once). Layout must match
// TGlobalIlluminationDDGIDataBufferData on the Pascal side.
layout(set = GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET, binding = GLOBAL_ILLUMINATION_VOLUME_UNIFORM_BINDING, std430) readonly buffer DDGIData {
  vec4 ddgiCascadeAABBMin[GI_DDGI_CASCADES];        // xyz = world space min corner of the probe lattice
  vec4 ddgiCascadeAABBMax[GI_DDGI_CASCADES];        // xyz = world space max corner of the probe lattice
  vec4 ddgiCascadeAABBScale[GI_DDGI_CASCADES];      // xyz = 1.0 / (max - min)
  vec4 ddgiCascadeCellSizes[GI_DDGI_CASCADES];      // xyz = world space spacing between adjacent probes, w = max probe ray distance
  vec4 ddgiCascadeAABBCenter[GI_DDGI_CASCADES];     // xyz = AABB center (for cascade fade computation)
  vec4 ddgiCascadeAABBFadeStart[GI_DDGI_CASCADES];  // xyz = distance from center where this cascade begins to fade out
  vec4 ddgiCascadeAABBFadeEnd[GI_DDGI_CASCADES];    // xyz = distance from center where this cascade is fully faded out
  ivec4 ddgiCascadeProbeScroll[GI_DDGI_CASCADES];     // xyz = base cell offset floor(AABBMin/cellSize) (this frame), w = scrolling enabled (1) / disabled (0)
  ivec4 ddgiCascadeProbeScrollPrev[GI_DDGI_CASCADES]; // xyz = base cell offset of the previous update of this in-flight slot (for re-initializing scrolled-in probes)
  DDGIRayDataBuffer rayData;            // -> ray-data sub-buffer
  DDGIProbeDataBuffer probeData;        // -> probe-data sub-buffer (null when relocation off)
  DDGIIrradianceSHBuffer irradianceSH;  // -> SH-irradiance sub-buffer (null in octahedral storage mode)
  DDGIAgeBuffer age;                    // -> per-probe convergence age sub-buffer
} ddgiData;
#endif

// Ray-data linear index: rows of raysPerProbe per probe (matches the old image layout image[y=globalProbe][x=ray]).
uint ddgiRayDataIndex(const in uint globalProbeIndex, const in uint rayIndex, const in uint raysPerProbe){
  return (globalProbeIndex * raysPerProbe) + rayIndex;
}

// The accessors take the sub-buffer reference directly (not ddgiData) so the caller can hoist the single deref into a local
// once per invocation (which also launders the readonly memory qualifier off ddgiData's member), instead of re-reading it.
vec4 ddgiLoadRay(const in DDGIRayDataBuffer aRayData, const in uint globalProbeIndex, const in uint rayIndex, const in uint raysPerProbe){
  return aRayData.data[ddgiRayDataIndex(globalProbeIndex, rayIndex, raysPerProbe)];
}

void ddgiStoreRay(const in DDGIRayDataBuffer aRayData, const in uint globalProbeIndex, const in uint rayIndex, const in uint raysPerProbe, const in vec4 aValue){
  aRayData.data[ddgiRayDataIndex(globalProbeIndex, rayIndex, raysPerProbe)] = aValue;
}

// Probe-data linear index (one vec4 per physical probe slot): matches the old 3D image addressing
// ivec3(probeCoord.xy, probeCoord.z + cascade*GI_DDGI_PROBES_Z) flattened row-major (x fastest).
uint ddgiProbeDataIndex(const in ivec3 probeCoord, const in int cascadeIndex){
  return uint(probeCoord.x + (probeCoord.y * GI_DDGI_PROBES_X) + ((probeCoord.z + (cascadeIndex * GI_DDGI_PROBES_Z)) * GI_DDGI_PROBES_X * GI_DDGI_PROBES_Y));
}

vec4 ddgiLoadProbeDataBuffer(const in DDGIProbeDataBuffer aProbeData, const in ivec3 probeCoord, const in int cascadeIndex){
  return aProbeData.data[ddgiProbeDataIndex(probeCoord, cascadeIndex)];
}

void ddgiStoreProbeDataBuffer(const in DDGIProbeDataBuffer aProbeData, const in ivec3 probeCoord, const in int cascadeIndex, const in vec4 aValue){
  aProbeData.data[ddgiProbeDataIndex(probeCoord, cascadeIndex)] = aValue;
}

#ifdef DDGI_SH_IMAGE_COUNT
// Whole-probe SH load/store: one contiguous DDGISHProbe element per probe (probe linear index matches ddgiProbeDataIndex).
// Reading/writing the probe as a unit lets the compiler emit wide/coalesced loads instead of COUNT separate indexed reads.
DDGISHProbe ddgiLoadSHProbe(const in DDGIIrradianceSHBuffer aSH, const in ivec3 probeCoord, const in int cascadeIndex){
  return aSH.probes[ddgiProbeDataIndex(probeCoord, cascadeIndex)];
}

void ddgiStoreSHProbe(const in DDGIIrradianceSHBuffer aSH, const in ivec3 probeCoord, const in int cascadeIndex, const in DDGISHProbe aProbe){
  aSH.probes[ddgiProbeDataIndex(probeCoord, cascadeIndex)] = aProbe;
}
#endif

// Per-probe age (probe linear index matches ddgiProbeDataIndex).
uint ddgiLoadAge(const in DDGIAgeBuffer aAge, const in ivec3 probeCoord, const in int cascadeIndex){
  return aAge.age[ddgiProbeDataIndex(probeCoord, cascadeIndex)];
}

void ddgiStoreAge(const in DDGIAgeBuffer aAge, const in ivec3 probeCoord, const in int cascadeIndex, const in uint aValue){
  aAge.age[ddgiProbeDataIndex(probeCoord, cascadeIndex)] = aValue;
}

#endif // GI_DDGI_DATA_GLSL
