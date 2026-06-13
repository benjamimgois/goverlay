#ifndef GLOBAL_ILLUMINATION_DDGI_GLSL
#define GLOBAL_ILLUMINATION_DDGI_GLSL

// =====================================================================================================================
//  Dynamic Diffuse Global Illumination (DDGI) - shared probe field definitions, addressing and sampling.
//
//  Based on:
//    - "Dynamic Diffuse Global Illumination with Ray-Traced Irradiance Fields", Majercik, Guertin, Nowrouzezahrai,
//      McGuire, JCGT 2019. https://jcgt.org/published/0008/02/01/
//    - "Scaling Probe-Based Real-Time Dynamic Global Illumination for Production", Majercik et al. 2021.
//
//  This engine variant reuses the cascaded radiance hints snapping infrastructure for probe placement: instead of one
//  irradiance volume, we keep GI_DDGI_CASCADES nested probe grids that snap to the camera, so a small per-cascade probe
//  count covers both near and far field. Each probe stores:
//    - irradiance, either as L1 spherical harmonics in a 3D volume (GI_DDGI_STORAGE_SH, default) or as an octahedral
//      irradiance tile in a 2D atlas (GI_DDGI_STORAGE_OCT) - switchable via the GI_DDGI_STORAGE define.
//    - visibility, always as an octahedral mean / mean-squared distance tile in a 2D atlas, used for the Chebyshev
//      visibility test that prevents the light leaking that plain irradiance volumes (and radiance hints) suffer from.
//
//  The probe radiance is gathered by tracing rays against the scene TLAS; see gi_ddgi_trace.comp / gi_ddgi_probe_update.comp.
// =====================================================================================================================

#include "octahedral.glsl" // octEncode / octDecode (unit vector <-> [-1,1]^2 signed octahedral mapping)

// --- Storage mode -----------------------------------------------------------------------------------------------------
#define GI_DDGI_STORAGE_OCT_VALUE 0  // octahedral irradiance atlas (1 RGBA16F image)
#define GI_DDGI_STORAGE_SH_VALUE 1   // L1 RGB spherical harmonics (4 coefficients, 3 RGBA16F images)
#define GI_DDGI_STORAGE_L2_VALUE 2   // L2 RGB spherical harmonics (9 coefficients, 7 RGBA16F images)
#ifndef GI_DDGI_STORAGE
  #define GI_DDGI_STORAGE GI_DDGI_STORAGE_L2_VALUE
#endif

// Convenience define mirroring GI_DDGI_STORAGE for consumers that select via defined()/!defined() (e.g. mesh.frag's
// IBL block, which is kept for octahedral storage but replaced by the SH dominant-light path for both SH storage modes).
#if GI_DDGI_STORAGE == GI_DDGI_STORAGE_OCT_VALUE
  #define GLOBAL_ILLUMINATION_DDGI_OCT_STORAGE
#endif

// Both L1 and L2 are spherical-harmonics storage (3D image triplet/septuplet); octahedral is the odd one out.
#if (GI_DDGI_STORAGE == GI_DDGI_STORAGE_SH_VALUE) || (GI_DDGI_STORAGE == GI_DDGI_STORAGE_L2_VALUE)
  #define GI_DDGI_STORAGE_IS_SH 1
#else
  #define GI_DDGI_STORAGE_IS_SH 0
#endif

// Storage-order-agnostic spherical-harmonics aliases: the sampling/update/shading code is written once against these
// (DDGI_SH_*), only the per-texel (un)packing of the coefficients into the RGBA16F image set is storage-specific.
#if GI_DDGI_STORAGE == GI_DDGI_STORAGE_L2_VALUE
  #define DDGI_SH_IMAGE_COUNT 7
  #define DDGI_SH_TYPE SHC3CoefficientsL2
  #define DDGI_SH_ZERO SHC3CoefficientsL2Zero
  #define DDGI_SH_ADD SHC3CoefficientsL2Add
  #define DDGI_SH_MUL SHC3CoefficientsL2Mul
  #define DDGI_SH_LERP SHC3CoefficientsL2Lerp
  #define DDGI_SH_PROJECT ProjectOntoSHC3CoefficientsL2
  #define DDGI_SH_SUB SHC3CoefficientsL2Sub
  #define DDGI_SH_CONVOLVE_COSINE SHC3CoefficientsL2ConvolveWithCosineLobe
  #define DDGI_SH_EVALUATE EvaluateSHC3CoefficientsL2
  // Dominant light direction/intensity live in the L0/L1 bands, so the "approximate" method extracts them from the L1
  // reduction (identical to the L1 path); the full L2 detail stays in the residual.
  #define DDGI_SH_APPROX_DOMINANT(sh, dir, color) SHC3CoefficientsL1ApproximateDirectionalLight(SHC3CoefficientsL1FromL2(sh), dir, color)
  #define DDGI_SH_EXTRACT_DOMINANT SHC3CoefficientsL2ExtractAndSubtractDominantAmbientAndDirectionalLights
#elif GI_DDGI_STORAGE == GI_DDGI_STORAGE_SH_VALUE
  #define DDGI_SH_IMAGE_COUNT 3
  #define DDGI_SH_TYPE SHC3CoefficientsL1
  #define DDGI_SH_ZERO SHC3CoefficientsL1Zero
  #define DDGI_SH_ADD SHC3CoefficientsL1Add
  #define DDGI_SH_MUL SHC3CoefficientsL1Mul
  #define DDGI_SH_LERP SHC3CoefficientsL1Lerp
  #define DDGI_SH_PROJECT ProjectOntoSHC3CoefficientsL1
  #define DDGI_SH_SUB SHC3CoefficientsL1Sub
  #define DDGI_SH_CONVOLVE_COSINE SHC3CoefficientsL1ConvolveWithCosineLobe
  #define DDGI_SH_EVALUATE EvaluateSHC3CoefficientsL1
  #define DDGI_SH_APPROX_DOMINANT(sh, dir, color) SHC3CoefficientsL1ApproximateDirectionalLight(sh, dir, color)
  #define DDGI_SH_EXTRACT_DOMINANT SHC3CoefficientsL1ExtractAndSubtractDominantAmbientAndDirectionalLights
#endif

// Dominant-light extraction method for the SH shading path (mesh.frag), compile-time switchable for comparison.
// When GI_DDGI_SH_APPROXIMATE_DOMINANT is defined (the DEFAULT): SHC3CoefficientsL1ApproximateDirectionalLight + residual
// SH with the DC kept (matches the original / HEAD~1 look), applied to both L1 and L2 (L2 extracts from the L1 reduction).
// #undef it (or comment out the line below) to switch to SHC3CoefficientsL{1,2}ExtractAndSubtractDominantAmbientAnd-
// DirectionalLights (separate uniform ambient + DC-zeroed residual + per-direction roughness estimate) — a different fit.
#define GI_DDGI_SH_APPROXIMATE_DOMINANT

// SH-storage glossy toggle (mesh.frag): when defined (together with GI_DDGI_GLOSSY_RADIANCE), the SH shading path adds the
// directional glossy prefiltered-radiance atlas, crossfaded by roughness against the dominant directional light — low
// roughness takes the sharp atlas, high roughness the broad dominant-light specular (see mesh.frag). Comment out for an A/B
// comparison against the dominant-light-only specular. Default ON. Octahedral storage and the diffuse term are unaffected.
#define GI_DDGI_GLOSSY_RESIDUAL

// --- Probe field dimensions -------------------------------------------------------------------------------------------
#ifndef GI_DDGI_CASCADES
  #define GI_DDGI_CASCADES 4
#endif
#ifndef GI_DDGI_PROBES_X
  #define GI_DDGI_PROBES_X 16
#endif
#ifndef GI_DDGI_PROBES_Y
  #define GI_DDGI_PROBES_Y 16
#endif
#ifndef GI_DDGI_PROBES_Z
  #define GI_DDGI_PROBES_Z 16
#endif
#define GI_DDGI_PROBES_PER_CASCADE (GI_DDGI_PROBES_X * GI_DDGI_PROBES_Y * GI_DDGI_PROBES_Z)

// Octahedral tile sizes (interior texels; one guard-band texel is added on each side in the atlas for bilinear filtering).
// Default: NPOT interior sizes (6/14) whose BORDERED tile is power-of-two aligned (6+2=8, 14+2=16) — the RTXGI/Wicked/Flax
// convention (less memory, POT atlas tiles). Comment out GI_DDGI_OCT_ALIGNED_BORDER_NPOT_SIZES (and its Pascal {$define}
// counterpart in PasVulkan.Scene3D.Renderer.Instance.pas) for the legacy 8/16 interior (10/18 bordered, NPOT tiles).
#define GI_DDGI_OCT_ALIGNED_BORDER_NPOT_SIZES
#ifndef GI_DDGI_IRRADIANCE_OCT_SIZE
  #ifdef GI_DDGI_OCT_ALIGNED_BORDER_NPOT_SIZES
    #define GI_DDGI_IRRADIANCE_OCT_SIZE 6
  #else
    #define GI_DDGI_IRRADIANCE_OCT_SIZE 8
  #endif
#endif
#ifndef GI_DDGI_VISIBILITY_OCT_SIZE
  #ifdef GI_DDGI_OCT_ALIGNED_BORDER_NPOT_SIZES
    #define GI_DDGI_VISIBILITY_OCT_SIZE 14
  #else
    #define GI_DDGI_VISIBILITY_OCT_SIZE 16
  #endif
#endif
#define GI_DDGI_IRRADIANCE_OCT_FULL (GI_DDGI_IRRADIANCE_OCT_SIZE + 2)
#define GI_DDGI_VISIBILITY_OCT_FULL (GI_DDGI_VISIBILITY_OCT_SIZE + 2)

// Glossy-radiance octahedral atlas. Separate from the irradiance atlas because it stores prefiltered *radiance*
// (no cosine convolution), integrated with a sharp directional kernel for glossy reflections. Only allocated/updated/sampled
// when GI_DDGI_GLOSSY_RADIANCE is defined (Pascal GlobalIlluminationDDGIGlossyRadiance, mirrored in compileshaders.sh; the
// toggle is opt-in / default OFF). Sized like the visibility atlas (same 14/16 interior + guard band) for reasonable sharpness.
#ifndef GI_DDGI_GLOSSY_OCT_SIZE
  #ifdef GI_DDGI_OCT_ALIGNED_BORDER_NPOT_SIZES
    #define GI_DDGI_GLOSSY_OCT_SIZE 14
  #else
    #define GI_DDGI_GLOSSY_OCT_SIZE 16
  #endif
#endif
#define GI_DDGI_GLOSSY_OCT_FULL (GI_DDGI_GLOSSY_OCT_SIZE + 2)

// Directional prefilter sharpness (Phong-like lobe exponent pow(max(dot,0), n)). Bounded by the ray count (~96 random rays):
// too sharp -> too few rays per texel -> noise (temporal accumulation hides some). ~8 is the practical sharp limit here; the
// planned mip chain (v2) adds *blurrier* levels below this for higher roughness, picked by a roughness->LOD at sample time.
#ifndef GI_DDGI_GLOSSY_SHARPNESS
  #define GI_DDGI_GLOSSY_SHARPNESS 8.0
#endif

// Storage format of the glossy atlas. Default RGB9E5 (E5B9G9R9 shared-exponent, 4 bytes/texel ~= half of RGBA16F): compute
// read/write goes through an R32_UINT alias view (encodeRGB9E5/decodeRGB9E5 in rgb9e5.glsl), and sampling does a manual
// 4-tap bilinear decode because E5B9G9R9 is not reliably hardware-linear-filterable. Build with -DGI_DDGI_GLOSSY_RGBA16F for
// the RGBA16F fallback (8 bytes, hardware bilinear). Whichever is chosen MUST match the Pascal image format.
#if !defined(GI_DDGI_GLOSSY_RGB9E5) && !defined(GI_DDGI_GLOSSY_RGBA16F)
  #define GI_DDGI_GLOSSY_RGB9E5
#endif

// Shading-time roughness band for blending the sharp glossy atlas against the broad source: at/below LO take the sharp
// atlas, at/above HI take the broad source (the atlas prefilter sharpness ~ roughness HI, beyond which the broad source
// is already correct). Only used when GI_DDGI_GLOSSY_RADIANCE.
#ifndef GI_DDGI_GLOSSY_ROUGHNESS_LO
  #define GI_DDGI_GLOSSY_ROUGHNESS_LO 0.0
#endif
#ifndef GI_DDGI_GLOSSY_ROUGHNESS_HI
  #define GI_DDGI_GLOSSY_ROUGHNESS_HI 0.45
#endif

// Number of rays traced per probe per frame.
#ifndef GI_DDGI_RAYS_PER_PROBE
  #define GI_DDGI_RAYS_PER_PROBE 128
#endif

// Temporal blend hysteresis when integrating new ray results into the stored probe data (closer to 1 = more stable / slower).
#ifndef GI_DDGI_HYSTERESIS
  #define GI_DDGI_HYSTERESIS 0.97
#endif

// Sharpness exponent applied to the Chebyshev weight; higher values darken leaking transitions more aggressively.
#ifndef GI_DDGI_VISIBILITY_SHARPNESS
  #define GI_DDGI_VISIBILITY_SHARPNESS 8.0
#endif

// Surface bias when sampling the probe field (mirrors RTXGI probeNormalBias/probeViewBias): the shading point is offset
// along its normal and towards the camera before the probe interpolation + Chebyshev test, which reduces both probe
// self-shadowing and light leaking through thin geometry. Expressed as a fraction of the cascade cell size (probe spacing),
// so it scales with cascade resolution. Tunable; too large makes the GI "slip"/over-darken near edges.
#ifndef GI_DDGI_NORMAL_BIAS
  #define GI_DDGI_NORMAL_BIAS 0.3
#endif
#ifndef GI_DDGI_VIEW_BIAS
  #define GI_DDGI_VIEW_BIAS 0.1
#endif

// Upper bound for the distance written into the visibility (mean / mean^2) statistics, as a multiple of the cascade cell
// size — mirrors RTXGI's probeMaxRayDistance = length(probeSpacing) * 1.5. Keeps the depth statistics on a local scale so
// far hits / sky misses don't inflate the mean and mask a nearby thin-slab occluder (which would otherwise leak). Only
// the stored DISTANCE is clamped; the ray's radiance still gathers light from the full ray length.
#ifndef GI_DDGI_VISIBILITY_MAX_DISTANCE_SCALE
  #define GI_DDGI_VISIBILITY_MAX_DISTANCE_SCALE 1.5
#endif

// --- Probe relocation + classification (RTXGI-style, compile-time toggle) ---------------------------------------------
// When enabled, a per-probe "probe data" image stores xyz = world-space relocation offset (probe pushed out of geometry,
// |offset| <= GI_DDGI_PROBE_MAX_OFFSET * cellSize) and w = state (0 = inactive/inside geometry or empty space -> skipped
// while shading, 1 = active). A dedicated compute pass (gi_ddgi_relocation.comp) traces GI_DDGI_FIXED_RAYS fixed directions
// per probe to compute these. The trace origin and the sampler probe world position both add the offset; the sampler skips
// inactive probes. DEFAULT OFF until the Pascal side (probe-data image + relocation pass + descriptor binding) is wired.
#ifndef GI_DDGI_PROBE_RELOCATION
  #define GI_DDGI_PROBE_RELOCATION 0
#endif
#ifndef GI_DDGI_FIXED_RAYS
  #define GI_DDGI_FIXED_RAYS 32
#endif
#ifndef GI_DDGI_PROBE_MAX_OFFSET            // max relocation offset as a fraction of cell size (RTXGI: 0.45, ellipsoid)
  #define GI_DDGI_PROBE_MAX_OFFSET 0.45
#endif
#ifndef GI_DDGI_PROBE_MIN_FRONTFACE         // keep this much clear space (in cell sizes) in front of a probe
  #define GI_DDGI_PROBE_MIN_FRONTFACE 1.0
#endif
#ifndef GI_DDGI_PROBE_BACKFACE_THRESHOLD    // fixed-ray backface fraction above which a probe counts as inside geometry
  #define GI_DDGI_PROBE_BACKFACE_THRESHOLD 0.25
#endif
#ifndef GI_DDGI_PROBE_BACKFACE_HYSTERESIS   // deadband half-width around the threshold: classification only flips ACTIVE<->
  #define GI_DDGI_PROBE_BACKFACE_HYSTERESIS 0.05  // INACTIVE outside [threshold-h, threshold+h], else keeps the previous state
#endif
#define GI_DDGI_PROBE_STATE_INACTIVE 0.0
#define GI_DDGI_PROBE_STATE_ACTIVE   1.0

// Per-probe convergence warmup (always on). Each probe ramps its temporal hysteresis from GI_DDGI_WARMUP_START_HYSTERESIS up
// to GI_DDGI_STEADY_HYSTERESIS over its first GI_DDGI_WARMUP_FRAMES frames of life, so a freshly-initialized or toroidally-
// scrolled-in probe converges in a few frames instead of ~100 (kills the scroll-in flicker during fast camera motion). The
// per-probe age (frames since (re)init) lives in its own BDA buffer (DDGIAgeBuffer in gi_ddgi_master.glsl): the visibility
// update owns/increments it (reset on firstFrame / scroll-in), the irradiance update reads it back.
#ifndef GI_DDGI_WARMUP_FRAMES
  #define GI_DDGI_WARMUP_FRAMES 16.0
#endif
#ifndef GI_DDGI_WARMUP_START_HYSTERESIS
  #define GI_DDGI_WARMUP_START_HYSTERESIS 0.7
#endif
#ifndef GI_DDGI_STEADY_HYSTERESIS
  #define GI_DDGI_STEADY_HYSTERESIS 0.97
#endif
// Hysteresis for a probe of the given age (frames since (re)init): low right after init, easing up to the steady value.
float ddgiWarmupHysteresis(const in float age){
  return mix(GI_DDGI_WARMUP_START_HYSTERESIS, GI_DDGI_STEADY_HYSTERESIS, min(age / GI_DDGI_WARMUP_FRAMES, 1.0));
}

// Luminance-adaptive hysteresis ("faster GI transitions", Scaling-DDGI / RTXGI ProbeBlendingCS): when a probe's freshly
// integrated irradiance differs a lot in luminance from its stored (temporally smoothed) value — a real runtime lighting
// change, e.g. a light toggles or a door opens — temporarily LOWER the temporal hysteresis so the probe re-converges in a
// few frames instead of ~100; when the field is stable, keep the high steady hysteresis (noise-free). Complements the
// per-probe age warmup (which only covers (re)init / scroll-in); this covers changes on already-converged probes.
// relativeChange = |Lnew - Lprev| / max(Lnew, Lprev); ramps the hysteresis from base toward a floor across the threshold.
// CAVEAT: the per-frame Monte-Carlo noise of the new estimate (~96 rays) is itself a luminance change, so keep the
// threshold above that noise floor or stable probes will spuriously drop hysteresis and get noisier; the floor bounds it.
#ifndef GI_DDGI_ADAPTIVE_HYSTERESIS
  #define GI_DDGI_ADAPTIVE_HYSTERESIS 0   // 0 = off (age-warmup hysteresis only; current default), 1 = on (faster reaction to lighting changes)
#endif
#ifndef GI_DDGI_ADAPTIVE_CHANGE_THRESHOLD  // relative luminance change at which adaptation starts; above ~2x it the floor is reached
  #define GI_DDGI_ADAPTIVE_CHANGE_THRESHOLD 0.25
#endif
#ifndef GI_DDGI_ADAPTIVE_MIN_HYSTERESIS    // hysteresis floor the adaptation can pull down to on a large change (still some smoothing)
  #define GI_DDGI_ADAPTIVE_MIN_HYSTERESIS 0.5
#endif
float ddgiAdaptiveHysteresis(const in float baseHysteresis, const in vec3 newColor, const in vec3 prevColor){
#if GI_DDGI_ADAPTIVE_HYSTERESIS
  const vec3 lumaWeights = vec3(0.2126, 0.7152, 0.0722);
  float newLuma = dot(max(newColor, vec3(0.0)), lumaWeights);
  float prevLuma = dot(max(prevColor, vec3(0.0)), lumaWeights);
  float relativeChange = abs(newLuma - prevLuma) / (max(newLuma, prevLuma) + 1e-4);
  float t = clamp((relativeChange - GI_DDGI_ADAPTIVE_CHANGE_THRESHOLD) / max(GI_DDGI_ADAPTIVE_CHANGE_THRESHOLD, 1e-4), 0.0, 1.0);
  return mix(baseHysteresis, min(baseHysteresis, GI_DDGI_ADAPTIVE_MIN_HYSTERESIS), t);
#else
  return baseHysteresis;
#endif
}

// First ray index the irradiance/visibility integration uses. With relocation enabled the first GI_DDGI_FIXED_RAYS rays
// are the FIXED rays (unrotated, used only by the relocation + classification passes for geometry sampling), so the probe
// blend skips them — exactly RTXGI's `rayIndex = NUM_FIXED_RAYS` when relocation/classification is enabled.
#if GI_DDGI_PROBE_RELOCATION
  #define GI_DDGI_RAY_START uint(GI_DDGI_FIXED_RAYS)
#else
  #define GI_DDGI_RAY_START 0u
#endif

const ivec3 uDDGIProbeCounts = ivec3(GI_DDGI_PROBES_X, GI_DDGI_PROBES_Y, GI_DDGI_PROBES_Z);

// --- Uniform data -----------------------------------------------------------------------------------------------------
// Mirrors the cascaded radiance hints volume uniform layout (one entry per cascade) so the CPU-side snapping code can be
// shared. AABBMin/Max/Scale/Center are the probe grid bounds in world space; the probes sit on the grid lattice spanning
// the AABB, i.e. probe (i,j,k) is at AABBMin + (i,j,k) * cellSize, with cellSize = (AABBMax-AABBMin)/(probeCounts-1).
// The DDGI data block (cascade globals + the BDA sub-buffer pointers) lives in gi_ddgi_data.glsl as one std430 readonly SSBO
// `ddgiData`, declared at the DDGI set's binding 0 (same set/binding the old globals UBO used). Only pulled in when the DDGI
// set is defined (i.e. a DDGI shader, which has GL_EXT_buffer_reference enabled); constants-only includers skip it. The
// addressing/sampling helpers below read ddgiData.ddgiCascade* exactly as before — only the backing storage changed.
#ifdef GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET
#include "gi_ddgi_data.glsl"
#endif

// =====================================================================================================================
//  Addressing helpers
// =====================================================================================================================

// World position -> continuous probe-grid coordinate within a cascade (0..probeCounts-1 spans the AABB).
#ifdef GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET
// Probe spacing is exactly cellSize (= the AABB snap increment), so the lattice stays aligned to the world cell grid as
// the volume snaps/scrolls; probe (i,j,k) sits at AABBMin + (i,j,k)*cellSize (the last probe leaves a one-cell margin
// before AABBMax, which is what the cascade fade band uses).
vec3 ddgiWorldToProbeGrid(const in vec3 worldPosition, const in int cascadeIndex){
  return (worldPosition - ddgiData.ddgiCascadeAABBMin[cascadeIndex].xyz) / ddgiData.ddgiCascadeCellSizes[cascadeIndex].xyz;
}

vec3 ddgiProbeGridToWorld(const in ivec3 probeCoord, const in int cascadeIndex){
  return ddgiData.ddgiCascadeAABBMin[cascadeIndex].xyz + (vec3(probeCoord) * ddgiData.ddgiCascadeCellSizes[cascadeIndex].xyz);
}
#endif

// Linear probe index within a cascade from integer probe coordinates.
int ddgiProbeIndex(const in ivec3 probeCoord){
  return (((probeCoord.z * GI_DDGI_PROBES_Y) + probeCoord.y) * GI_DDGI_PROBES_X) + probeCoord.x;
}

// Inverse of ddgiProbeIndex: integer probe coordinates from a linear index within a cascade.
ivec3 ddgiProbeCoordFromIndex(const in int probeIndex){
  int x = probeIndex % GI_DDGI_PROBES_X;
  int y = (probeIndex / GI_DDGI_PROBES_X) % GI_DDGI_PROBES_Y;
  int z = probeIndex / (GI_DDGI_PROBES_X * GI_DDGI_PROBES_Y);
  return ivec3(x, y, z);
}

// --- Toroidal (clipmap) probe scrolling -------------------------------------------------------------------------------
// The cascade AABB snaps to whole cell-size increments as it follows the camera. To keep a world-fixed probe's temporal
// history on the same storage texel as the volume scrolls, the *logical* probe coordinate (the lattice position within
// the current AABB, 0..count-1) and the *physical* storage slot differ by the cascade's base-cell offset, toroidally:
//   physical = (logical + baseCell) mod count   <=>   logical = (physical - baseCell) mod count.
// A world cell W = baseCell + logical; a physical slot keeps representing the same world cell while it stays inside the
// volume, and only "scrolls in" (gets a new world cell, so its history must be reset) at the leading edges.
#ifdef GLOBAL_ILLUMINATION_VOLUME_UNIFORM_SET
ivec3 ddgiProbeBaseCell(const in int cascadeIndex){
  return (ddgiData.ddgiCascadeProbeScroll[cascadeIndex].w != 0) ? ddgiData.ddgiCascadeProbeScroll[cascadeIndex].xyz : ivec3(0);
}

ivec3 ddgiProbeBaseCellPrev(const in int cascadeIndex){
  return (ddgiData.ddgiCascadeProbeScroll[cascadeIndex].w != 0) ? ddgiData.ddgiCascadeProbeScrollPrev[cascadeIndex].xyz : ivec3(0);
}

// Physical storage coordinate for a logical probe coordinate (used when sampling/reading the field).
ivec3 ddgiProbePhysicalCoord(const in ivec3 logicalCoord, const in int cascadeIndex){
  ivec3 c = uDDGIProbeCounts;
  return (((logicalCoord + ddgiProbeBaseCell(cascadeIndex)) % c) + c) % c;
}

// Logical probe coordinate for a physical storage slot (used by the update passes that iterate physical slots).
ivec3 ddgiProbeLogicalCoord(const in ivec3 physicalCoord, const in int cascadeIndex){
  ivec3 c = uDDGIProbeCounts;
  return (((physicalCoord - ddgiProbeBaseCell(cascadeIndex)) % c) + c) % c;
}

// True if a physical slot now maps to a different world cell than at the previous update of this in-flight slot, i.e. it
// just scrolled into the volume and its stored history is stale and must be discarded.
bool ddgiProbeScrolledIn(const in ivec3 physicalCoord, const in int cascadeIndex){
  ivec3 c = uDDGIProbeCounts;
  ivec3 base = ddgiProbeBaseCell(cascadeIndex);
  ivec3 basePrev = ddgiProbeBaseCellPrev(cascadeIndex);
  ivec3 worldCell     = base     + ((((physicalCoord - base)     % c) + c) % c);
  ivec3 worldCellPrev = basePrev + ((((physicalCoord - basePrev) % c) + c) % c);
  return any(notEqual(worldCell, worldCellPrev));
}
#endif

// Evenly distributed direction on the unit sphere (spherical Fibonacci / golden spiral) for ray index i of n.
vec3 ddgiSphericalFibonacci(const in float i, const in float n){
  const float PHI = 1.6180339887498949; // golden ratio
  float phi = 6.2831853071795864 * fract(i * (PHI - 1.0));
  float cosTheta = 1.0 - ((2.0 * i) + 1.0) * (1.0 / n);
  float sinTheta = sqrt(clamp(1.0 - (cosTheta * cosTheta), 0.0, 1.0));
  return vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
}

// The traced direction for a given ray index, rotated by a per-frame random rotation so that, over several frames, the
// whole sphere is covered while only GI_DDGI_RAYS_PER_PROBE rays are traced per frame. Both the trace and update shaders
// call this with the same rotation (passed as a push constant) so they agree on the directions without storing them.
vec3 ddgiRayDirection(const in int rayIndex, const in mat3 randomRotation){
  return normalize(randomRotation * ddgiSphericalFibonacci(float(rayIndex), float(GI_DDGI_RAYS_PER_PROBE)));
}

// Octahedral atlases pack the probes of a cascade row-major into a 2D grid of tiles. We lay out all cascades vertically
// (one cascade block per GI_DDGI_PROBES_Z*... rows) so a single 2D texture array layer or a tall 2D texture can hold them.
// tilesPerRow chosen as GI_DDGI_PROBES_X * GI_DDGI_PROBES_Y wide is wasteful; instead we use a square-ish layout.
const int GI_DDGI_TILES_PER_ROW = GI_DDGI_PROBES_X; // one row of the atlas holds one X-row of probes

// Top-left interior texel (in full-tile units, i.e. including guard band) of a probe tile inside the atlas for a given
// per-probe full tile size.
ivec2 ddgiProbeTileOrigin(const in ivec3 probeCoord, const in int cascadeIndex, const in int fullTileSize){
  // Atlas grid coordinate of the tile: x advances with probe.x, y advances with probe.y then probe.z then cascade.
  int tileX = probeCoord.x;
  int tileY = probeCoord.y + (GI_DDGI_PROBES_Y * (probeCoord.z + (GI_DDGI_PROBES_Z * cascadeIndex)));
  return (ivec2(tileX, tileY) * fullTileSize) + ivec2(1); // +1 to skip the guard-band texel
}

// Atlas dimensions in texels for a given per-probe full tile size.
ivec2 ddgiAtlasSize(const in int fullTileSize){
  return ivec2(GI_DDGI_PROBES_X, GI_DDGI_PROBES_Y * GI_DDGI_PROBES_Z * GI_DDGI_CASCADES) * fullTileSize;
}

// Normalized [0,1] atlas UV for a direction in a probe's octahedral tile (for sampling with a linear sampler; the guard
// band makes bilinear taps at tile edges correct).
vec2 ddgiProbeOctUV(const in ivec3 probeCoord, const in int cascadeIndex, const in vec3 direction, const in int interiorSize, const in int fullTileSize){
  vec2 oct = fma(octEncode(normalize(direction)), vec2(0.5), vec2(0.5)); // [-1,1] -> [0,1]
  vec2 originTexel = vec2(ddgiProbeTileOrigin(probeCoord, cascadeIndex, fullTileSize));
  vec2 texel = originTexel + (oct * float(interiorSize));
  return texel / vec2(ddgiAtlasSize(fullTileSize));
}

// =====================================================================================================================
//  Probe data declarations and sampling (only when sampling, i.e. in mesh.frag or the probe update shader)
// =====================================================================================================================
#ifdef GLOBAL_ILLUMINATION_DDGI_SAMPLE

  // Irradiance storage.
  #if GI_DDGI_STORAGE_IS_SH
    // RGB spherical harmonics packed into DDGI_SH_IMAGE_COUNT RGBA16F 3D textures per cascade (L1 = 3, L2 = 7); see the
    // consumer's ddgiLoadIrradianceSH for the exact (un)packing. The 3D texture coordinate addresses the probe lattice
    // (size = probe counts, with the cascade stacked along Z).
    #include "sphericalharmonics.glsl"

    // Defined by each consumer against its own resources: the probe update shader loads from a storage image, the
    // shading pass loads from a sampled texture. Returns the stored *radiance* SH (L1 or L2) of the probe.
    DDGI_SH_TYPE ddgiLoadIrradianceSH(const in ivec3 probeCoord, const in int cascadeIndex);

    // Evaluate the diffuse irradiance E(n) for a normal direction: convolve the stored radiance SH with the clamped
    // cosine lobe and evaluate it in the normal direction. The caller multiplies by albedo/PI to get outgoing radiance.
    vec3 ddgiEvaluateIrradiance(const in ivec3 probeCoord, const in int cascadeIndex, const in vec3 normal){
      DDGI_SH_TYPE sh = DDGI_SH_CONVOLVE_COSINE(ddgiLoadIrradianceSH(probeCoord, cascadeIndex));
      return max(vec3(0.0), DDGI_SH_EVALUATE(sh, normalize(normal)));
    }
  #else
    // Octahedral irradiance atlas (RGBA16F).
    vec3 ddgiEvaluateIrradiance(const in ivec3 probeCoord, const in int cascadeIndex, const in vec3 normal);
  #endif

  // Visibility octahedral atlas (RGBA16F): x = mean distance, y = mean distance squared (Chebyshev), z = sky visibility
  // (fraction of probe rays in that direction that escaped to the sky / missed geometry, used as the IBL occlusion factor).
  vec3 ddgiSampleVisibility(const in ivec3 probeCoord, const in int cascadeIndex, const in vec3 direction);

#if GI_DDGI_PROBE_RELOCATION
  // Probe data (xyz = world-space relocation offset, w = state) for the physical probe slot. Provided by the consumer
  // (sampler3D in the shading path / image3D in the trace), like ddgiSampleVisibility above.
  vec4 ddgiLoadProbeData(const in ivec3 probeCoord, const in int cascadeIndex);
#endif

#if defined(GI_DDGI_GLOSSY_RADIANCE)
  // Prefiltered glossy *radiance* (NOT cosine-convolved) for a reflection direction, from the octahedral glossy atlas.
  // Provided by the consumer: a (u)sampler2D with manual/HW bilinear in the shading path. See ddgiSampleGlossyRadiance.
  vec3 ddgiEvaluateGlossyRadiance(const in ivec3 probeCoord, const in int cascadeIndex, const in vec3 reflectionDirection);
#endif

  // ---------------------------------------------------------------------------------------------------------------------
  //  Sample the irradiance field at a world position for a surface with the given normal, with Chebyshev visibility
  //  weighting (the DDGI leak-reduction term) and trilinear + backface weighting. Returns diffuse irradiance.
  // ---------------------------------------------------------------------------------------------------------------------
  vec3 ddgiSampleIrradianceInCascade(const in vec3 worldPosition, const in vec3 normal, const in vec3 viewDirection, const in int cascadeIndex, out float skyVisibility){
    vec3 gridCoord = ddgiWorldToProbeGrid(worldPosition, cascadeIndex);
    ivec3 baseProbe = ivec3(floor(gridCoord));
    vec3 frac = gridCoord - vec3(baseProbe);

    // Surface bias (along normal + towards camera, scaled by the cascade cell size) to reduce probe self-shadowing AND
    // light leaking through thin geometry; the Chebyshev distToProbe below is measured from this lifted position.
    vec3 biasedPosition = worldPosition + ((normal * GI_DDGI_NORMAL_BIAS) + (viewDirection * GI_DDGI_VIEW_BIAS)) * ddgiData.ddgiCascadeCellSizes[cascadeIndex].x;

    vec3 sumIrradiance = vec3(0.0);
    float sumSkyVisibility = 0.0;
    float sumWeight = 0.0;

    for(int i = 0; i < 8; i++){
      ivec3 offset = ivec3(i & 1, (i >> 1) & 1, (i >> 2) & 1);
      ivec3 probeCoord = clamp(baseProbe + offset, ivec3(0), uDDGIProbeCounts - ivec3(1)); // logical (lattice) coord
      ivec3 physProbeCoord = ddgiProbePhysicalCoord(probeCoord, cascadeIndex);              // toroidal storage slot for reads

      vec3 trilinear = mix(vec3(1.0) - frac, frac, vec3(offset));
      float weight = trilinear.x * trilinear.y * trilinear.z;

      vec3 probeWorld = ddgiProbeGridToWorld(probeCoord, cascadeIndex);
#if GI_DDGI_PROBE_RELOCATION
      vec4 probeData = ddgiLoadProbeData(physProbeCoord, cascadeIndex);
      if(probeData.w < 0.5){
        continue; // inactive probe (classified inside geometry / empty space) — skip it in the gather
      }
      probeWorld += probeData.xyz; // relocation offset (probe pushed out of geometry)
#endif
      vec3 probeToPoint = biasedPosition - probeWorld;
      vec3 dirToProbe = normalize(-probeToPoint);

      // Backface / smooth wrap weight: probes "behind" the surface contribute less.
      float wrap = (dot(dirToProbe, normal) + 1.0) * 0.5;
      weight *= (wrap * wrap) + 0.2;

      // Chebyshev visibility test against the probe's stored octahedral depth statistics.
      float distToProbe = length(probeToPoint);
      vec3 vis = ddgiSampleVisibility(physProbeCoord, cascadeIndex, normalize(probeToPoint));
      vec2 moments = vis.xy;
      float meanDist = moments.x;
      if(distToProbe > meanDist){
        float variance = abs((meanDist * meanDist) - moments.y);
        float d = distToProbe - meanDist;
        float chebyshev = variance / (variance + (d * d));
        chebyshev = max(0.0, chebyshev * chebyshev * chebyshev); // sharpen
        weight *= chebyshev;
      }

      // Avoid zero contribution everywhere by keeping a tiny epsilon, then apply a small power to crush near-zero weights.
      const float crushThreshold = 0.2;
      if(weight < crushThreshold){
        weight *= (weight * weight) * (1.0 / (crushThreshold * crushThreshold));
      }

      weight = max(weight, 1e-6);

      sumIrradiance += ddgiEvaluateIrradiance(physProbeCoord, cascadeIndex, normal) * weight;

      // Sky visibility for IBL occlusion: how open the surface hemisphere (normal direction) is to the sky at this probe.
      sumSkyVisibility += ddgiSampleVisibility(physProbeCoord, cascadeIndex, normal).z * weight;

      sumWeight += weight;

    }

    if(sumWeight > 0.0){
      skyVisibility = clamp(sumSkyVisibility / sumWeight, 0.0, 1.0);
      return sumIrradiance / sumWeight;
    } else {
      skyVisibility = 0.0;
      return vec3(0.0);
    }

  }

  // Select cascade by AABB containment with fade-based blending between cascades, then sample. Returns diffuse irradiance;
  // skyVisibility (out) is the IBL occlusion factor (1 = fully open to the sky, 0 = enclosed), 1 outside all cascades.
  vec3 ddgiSampleIrradiance(const in vec3 worldPosition, const in vec3 normal, const in vec3 viewDirection, out float skyVisibility){
    int cascadeIndex = 0;
    while(((cascadeIndex + 1) < GI_DDGI_CASCADES) &&
          (any(lessThan(worldPosition, ddgiData.ddgiCascadeAABBMin[cascadeIndex].xyz)) ||
           any(greaterThan(worldPosition, ddgiData.ddgiCascadeAABBMax[cascadeIndex].xyz)))){
      cascadeIndex++;
    }

    vec3 result = vec3(0.0);
    float sumSkyVisibility = 0.0;
    float sumWeight = 0.0;
    float current = 1.0;
    for(int c = cascadeIndex; c < GI_DDGI_CASCADES; c++){
      float weight;
      if(c == (GI_DDGI_CASCADES - 1)){
        weight = current;
        current = 0.0;
      }else if(all(greaterThanEqual(worldPosition, ddgiData.ddgiCascadeAABBMin[c].xyz)) &&
               all(lessThanEqual(worldPosition, ddgiData.ddgiCascadeAABBMax[c].xyz))){
        vec3 fade = smoothstep(ddgiData.ddgiCascadeAABBFadeStart[c].xyz,
                               ddgiData.ddgiCascadeAABBFadeEnd[c].xyz,
                               abs(worldPosition - ddgiData.ddgiCascadeAABBCenter[c].xyz));
        float f = 1.0 - clamp(max(max(fade.x, fade.y), fade.z), 0.0, 1.0);
        weight = current * f;
        current *= 1.0 - f;
      }else{
        break;
      }
      if(weight > 1e-6){
        float cascadeSkyVisibility;
        result += ddgiSampleIrradianceInCascade(worldPosition, normal, viewDirection, c, cascadeSkyVisibility) * weight;
        sumSkyVisibility += cascadeSkyVisibility * weight;
        sumWeight += weight;
      }
      if(current < 1e-6){
        break;
      }
    }
    skyVisibility = (sumWeight > 0.0) ? clamp(sumSkyVisibility / sumWeight, 0.0, 1.0) : 1.0;
    return result;
  }

#if defined(GI_DDGI_GLOSSY_RADIANCE)
  // ---------------------------------------------------------------------------------------------------------------------
  //  Sample the prefiltered glossy radiance field along a reflection direction. Same probe gather as the irradiance
  //  path (surface bias, trilinear, relocation skip, normal-based backface wrap, Chebyshev visibility) so it stays leak-
  //  consistent — only the per-probe lookup samples the glossy atlas along the *reflection* vector instead of evaluating
  //  cosine-convolved irradiance along the normal. Returns prefiltered radiance (the caller applies the split-sum BRDF).
  // ---------------------------------------------------------------------------------------------------------------------
  vec3 ddgiSampleGlossyRadianceInCascade(const in vec3 worldPosition, const in vec3 normal, const in vec3 reflectionDirection, const in vec3 viewDirection, const in int cascadeIndex){
    vec3 gridCoord = ddgiWorldToProbeGrid(worldPosition, cascadeIndex);
    ivec3 baseProbe = ivec3(floor(gridCoord));
    vec3 frac = gridCoord - vec3(baseProbe);

    vec3 biasedPosition = worldPosition + ((normal * GI_DDGI_NORMAL_BIAS) + (viewDirection * GI_DDGI_VIEW_BIAS)) * ddgiData.ddgiCascadeCellSizes[cascadeIndex].x;

    vec3 sumGlossy = vec3(0.0);
    float sumWeight = 0.0;

    for(int i = 0; i < 8; i++){
      ivec3 offset = ivec3(i & 1, (i >> 1) & 1, (i >> 2) & 1);
      ivec3 probeCoord = clamp(baseProbe + offset, ivec3(0), uDDGIProbeCounts - ivec3(1));
      ivec3 physProbeCoord = ddgiProbePhysicalCoord(probeCoord, cascadeIndex);

      vec3 trilinear = mix(vec3(1.0) - frac, frac, vec3(offset));
      float weight = trilinear.x * trilinear.y * trilinear.z;

      vec3 probeWorld = ddgiProbeGridToWorld(probeCoord, cascadeIndex);
#if GI_DDGI_PROBE_RELOCATION
      vec4 probeData = ddgiLoadProbeData(physProbeCoord, cascadeIndex);
      if(probeData.w < 0.5){
        continue;
      }
      probeWorld += probeData.xyz;
#endif
      vec3 probeToPoint = biasedPosition - probeWorld;
      vec3 dirToProbe = normalize(-probeToPoint);

      float wrap = (dot(dirToProbe, normal) + 1.0) * 0.5;
      weight *= (wrap * wrap) + 0.2;

      float distToProbe = length(probeToPoint);
      vec2 moments = ddgiSampleVisibility(physProbeCoord, cascadeIndex, normalize(probeToPoint)).xy;
      float meanDist = moments.x;
      if(distToProbe > meanDist){
        float variance = abs((meanDist * meanDist) - moments.y);
        float d = distToProbe - meanDist;
        float chebyshev = variance / (variance + (d * d));
        chebyshev = max(0.0, chebyshev * chebyshev * chebyshev);
        weight *= chebyshev;
      }

      const float crushThreshold = 0.2;
      if(weight < crushThreshold){
        weight *= (weight * weight) * (1.0 / (crushThreshold * crushThreshold));
      }
      weight = max(weight, 1e-6);

      sumGlossy += ddgiEvaluateGlossyRadiance(physProbeCoord, cascadeIndex, reflectionDirection) * weight;
      sumWeight += weight;
    }

    return (sumWeight > 0.0) ? (sumGlossy / sumWeight) : vec3(0.0);
  }

  // Cascade selection + fade blend (same scheme as ddgiSampleIrradiance), returning prefiltered glossy radiance along the
  // reflection vector. Outside all cascades returns 0 (the caller falls back to the broad source / environment specular).
  vec3 ddgiSampleGlossyRadiance(const in vec3 worldPosition, const in vec3 normal, const in vec3 reflectionDirection, const in vec3 viewDirection){
    int cascadeIndex = 0;
    while(((cascadeIndex + 1) < GI_DDGI_CASCADES) &&
          (any(lessThan(worldPosition, ddgiData.ddgiCascadeAABBMin[cascadeIndex].xyz)) ||
           any(greaterThan(worldPosition, ddgiData.ddgiCascadeAABBMax[cascadeIndex].xyz)))){
      cascadeIndex++;
    }

    vec3 result = vec3(0.0);
    float sumWeight = 0.0;
    float current = 1.0;
    for(int c = cascadeIndex; c < GI_DDGI_CASCADES; c++){
      float weight;
      if(c == (GI_DDGI_CASCADES - 1)){
        weight = current;
        current = 0.0;
      }else if(all(greaterThanEqual(worldPosition, ddgiData.ddgiCascadeAABBMin[c].xyz)) &&
               all(lessThanEqual(worldPosition, ddgiData.ddgiCascadeAABBMax[c].xyz))){
        vec3 fade = smoothstep(ddgiData.ddgiCascadeAABBFadeStart[c].xyz,
                               ddgiData.ddgiCascadeAABBFadeEnd[c].xyz,
                               abs(worldPosition - ddgiData.ddgiCascadeAABBCenter[c].xyz));
        float f = 1.0 - clamp(max(max(fade.x, fade.y), fade.z), 0.0, 1.0);
        weight = current * f;
        current *= 1.0 - f;
      }else{
        break;
      }
      if(weight > 1e-6){
        result += ddgiSampleGlossyRadianceInCascade(worldPosition, normal, reflectionDirection, viewDirection, c) * weight;
        sumWeight += weight;
      }
      if(current < 1e-6){
        break;
      }
    }
    return (sumWeight > 0.0) ? (result / sumWeight) : vec3(0.0);
  }
#endif // GI_DDGI_GLOSSY_RADIANCE

  #if GI_DDGI_STORAGE_IS_SH
  // ---------------------------------------------------------------------------------------------------------------------
  //  Same sampling as ddgiSampleIrradiance* but returning the blended *radiance* SH (L1 or L2, pre cosine-lobe) instead of
  //  the evaluated diffuse irradiance. The SH-storage shading path uses this to extract a dominant directional light
  //  (proper specular via the analytic BRDF) plus a residual ambient SH (diffuse), mirroring the cascaded radiance hints.
  // ---------------------------------------------------------------------------------------------------------------------
  DDGI_SH_TYPE ddgiSampleRadianceSHInCascade(const in vec3 worldPosition, const in vec3 normal, const in vec3 viewDirection, const in int cascadeIndex, out float skyVisibility){
    vec3 gridCoord = ddgiWorldToProbeGrid(worldPosition, cascadeIndex);
    ivec3 baseProbe = ivec3(floor(gridCoord));
    vec3 frac = gridCoord - vec3(baseProbe);

    // Surface bias (see ddgiSampleIrradianceInCascade): lift along normal + towards camera, scaled by the cell size.
    vec3 biasedPosition = worldPosition + ((normal * GI_DDGI_NORMAL_BIAS) + (viewDirection * GI_DDGI_VIEW_BIAS)) * ddgiData.ddgiCascadeCellSizes[cascadeIndex].x;

    DDGI_SH_TYPE sumSH = DDGI_SH_ZERO();
    float sumSkyVisibility = 0.0;
    float sumWeight = 0.0;

    for(int i = 0; i < 8; i++){
      ivec3 offset = ivec3(i & 1, (i >> 1) & 1, (i >> 2) & 1);
      ivec3 probeCoord = clamp(baseProbe + offset, ivec3(0), uDDGIProbeCounts - ivec3(1)); // logical (lattice) coord
      ivec3 physProbeCoord = ddgiProbePhysicalCoord(probeCoord, cascadeIndex);              // toroidal storage slot for reads

      vec3 trilinear = mix(vec3(1.0) - frac, frac, vec3(offset));
      float weight = trilinear.x * trilinear.y * trilinear.z;

      vec3 probeWorld = ddgiProbeGridToWorld(probeCoord, cascadeIndex);
#if GI_DDGI_PROBE_RELOCATION
      vec4 probeData = ddgiLoadProbeData(physProbeCoord, cascadeIndex);
      if(probeData.w < 0.5){
        continue; // inactive probe (classified inside geometry / empty space) — skip it in the gather
      }
      probeWorld += probeData.xyz; // relocation offset (probe pushed out of geometry)
#endif
      vec3 probeToPoint = biasedPosition - probeWorld;
      vec3 dirToProbe = normalize(-probeToPoint);

      float wrap = (dot(dirToProbe, normal) + 1.0) * 0.5;
      weight *= (wrap * wrap) + 0.2;

      float distToProbe = length(probeToPoint);
      vec3 vis = ddgiSampleVisibility(physProbeCoord, cascadeIndex, normalize(probeToPoint));
      vec2 moments = vis.xy;
      float meanDist = moments.x;
      float chebyshev = 1.0;
      if(distToProbe > meanDist){
        float variance = abs((meanDist * meanDist) - moments.y);
        float d = distToProbe - meanDist;
        chebyshev = variance / (variance + (d * d));
        chebyshev = max(0.0, chebyshev * chebyshev * chebyshev);
      }
      weight *= chebyshev;

      const float crushThreshold = 0.2;
      if(weight < crushThreshold){
        weight *= (weight * weight) * (1.0 / (crushThreshold * crushThreshold));
      }

      weight = max(weight, 1e-6);

      sumSH = DDGI_SH_ADD(sumSH, DDGI_SH_MUL(ddgiLoadIrradianceSH(physProbeCoord, cascadeIndex), weight));
      sumSkyVisibility += ddgiSampleVisibility(physProbeCoord, cascadeIndex, normal).z * weight;
      sumWeight += weight;
    }

    skyVisibility = (sumWeight > 0.0) ? clamp(sumSkyVisibility / sumWeight, 0.0, 1.0) : 0.0;
    return (sumWeight > 0.0) ? DDGI_SH_MUL(sumSH, 1.0 / sumWeight) : DDGI_SH_ZERO();
  }

  DDGI_SH_TYPE ddgiSampleRadianceSH(const in vec3 worldPosition, const in vec3 normal, const in vec3 viewDirection, out float skyVisibility){
    int cascadeIndex = 0;
    while(((cascadeIndex + 1) < GI_DDGI_CASCADES) &&
          (any(lessThan(worldPosition, ddgiData.ddgiCascadeAABBMin[cascadeIndex].xyz)) ||
           any(greaterThan(worldPosition, ddgiData.ddgiCascadeAABBMax[cascadeIndex].xyz)))){
      cascadeIndex++;
    }

    DDGI_SH_TYPE result = DDGI_SH_ZERO();
    float sumSkyVisibility = 0.0;
    float sumWeight = 0.0;
    float current = 1.0;
    for(int c = cascadeIndex; c < GI_DDGI_CASCADES; c++){
      float weight;
      if(c == (GI_DDGI_CASCADES - 1)){
        weight = current;
        current = 0.0;
      }else if(all(greaterThanEqual(worldPosition, ddgiData.ddgiCascadeAABBMin[c].xyz)) &&
               all(lessThanEqual(worldPosition, ddgiData.ddgiCascadeAABBMax[c].xyz))){
        vec3 fade = smoothstep(ddgiData.ddgiCascadeAABBFadeStart[c].xyz,
                               ddgiData.ddgiCascadeAABBFadeEnd[c].xyz,
                               abs(worldPosition - ddgiData.ddgiCascadeAABBCenter[c].xyz));
        float f = 1.0 - clamp(max(max(fade.x, fade.y), fade.z), 0.0, 1.0);
        weight = current * f;
        current *= 1.0 - f;
      }else{
        break;
      }
      if(weight > 1e-6){
        float cascadeSkyVisibility;
        result = DDGI_SH_ADD(result, DDGI_SH_MUL(ddgiSampleRadianceSHInCascade(worldPosition, normal, viewDirection, c, cascadeSkyVisibility), weight));
        sumSkyVisibility += cascadeSkyVisibility * weight;
        sumWeight += weight;
      }
      if(current < 1e-6){
        break;
      }
    }
    skyVisibility = (sumWeight > 0.0) ? clamp(sumSkyVisibility / sumWeight, 0.0, 1.0) : 1.0;
    return result;
  }
  #endif // GI_DDGI_STORAGE_IS_SH

#endif // GLOBAL_ILLUMINATION_DDGI_SAMPLE

#endif // GLOBAL_ILLUMINATION_DDGI_GLSL
