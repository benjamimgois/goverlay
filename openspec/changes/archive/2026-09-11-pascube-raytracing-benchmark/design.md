## Context

See `proposal.md` for motivation.

PasCube's benchmark currently executes a sequential state machine:
`bpIdleMenu` -> `bpWarmup` -> `bpCPU_Single` -> `bpCPU_Multi` -> `bpGPU_1080p` (3 runs) -> `bpResults`.

The PasVulkan underlying framework includes Vulkan Ray Tracing KHR extension definitions (`VK_KHR_ray_tracing_pipeline`, `VK_KHR_ray_query`, `VK_KHR_acceleration_structure`) and feature structures in `PasVulkan.Framework.pas` and `PasVulkan.Raytracing.pas`.

The results overlay (`DrawResultsOverlay` in `UnitPasCubeScreen.pas`) renders results across a two-column layout:
- Left Column: Main Score (top), Row 1 (CPU ST & MT side-by-side), Row 2 (GPU Score full width), and Score Trend Graph (bottom).
- Right Column: Hardware Comparison list.

## Goals / Non-Goals

**Goals:**
- Detect hardware Vulkan Ray Tracing capability at runtime without throwing exceptions or crashing on non-RT hardware.
- Introduce `bpRT_1080p` phase in the benchmark state machine executed immediately after `bpGPU_1080p` on supported devices.
- Compute an independent Ray Tracing performance score based on throughput (average FPS).
- Redesign Row 2 in `DrawResultsOverlay` into two symmetrical side-by-side cards: `GPU Raster Score` and `Ray Tracing Score`.
- Display graceful fallback information (`N/A - Not Supported`) when running on non-RT hardware.
- Persist Ray Tracing metrics in `benchmark_results.json`.

**Non-Goals:**
- Altering the legacy `TotalScore` weighting formula (`0.35 * cpuST + 0.15 * cpuMT + 0.50 * gpuAvg`).
- Emulating software ray tracing on non-supported GPUs (avoiding unplayable 0.1 FPS slide-shows).
- Changing the schema in a way that breaks existing `benchmark_results.json` histories or PascubeDB submissions.

## Decisions

### Decision 1: Hardware Capability Detection and Seamless Bypass
- **Choice**: Query physical device extensions for `VK_KHR_ray_tracing_pipeline` or `VK_KHR_ray_query` along with `VK_KHR_acceleration_structure` during engine setup. Store a boolean flag `fRayTracingSupported`.
- **Rationale**: Keeps runtime checks fast and prevents driver crashes on older architectures (NVIDIA Pascal, AMD Polaris, Intel UHD/Iris, Raspberry Pi).
- **Alternative considered**: Attempting to run a test shader and catching errors on the fly — rejected because Vulkan validation layers / drivers can abort the entire instance on invalid extension usage.

### Decision 2: State Machine Phase Transition
- **Choice**: When `bpGPU_1080p` finishes all 3 iterations, evaluate `fRayTracingSupported`:
  - If true: transition to `bpRT_1080p`, configure ray tracing workload, and run for standard phase duration (10s).
  - If false: transition directly to `bpResults`.
- **Rationale**: Guarantees zero unnecessary idle or skipped frames on non-RT systems while keeping the sequence natural on modern hardware.

### Decision 3: Preserving TotalScore Formula
- **Choice**: Keep `fCurrentResult.TotalScore` computed solely from CPU Single-Thread, CPU Multi-Thread, and GPU Raster scores. The RT score is recorded in `fCurrentResult.PhaseResults[8]` (and an explicit helper field).
- **Rationale**: 100% backward compatibility with previous benchmark scores, local history trends, and the PascubeDB global leaderboard.

### Decision 4: Symmetrical Results Screen Layout
- **Choice**: Transform Row 2 (previously a single card spanning `leftColWidth` for `GPU Score`) into two equal-width cards of `halfWidth` with a `gap`:
  - Left card: `GPU Raster Score`
  - Right card: `Ray Tracing Score`
- **Rationale**: Perfectly mirrors Row 1 (`CPU Single-Thread` / `CPU Multi-Thread`), preserving vertical spacing, alignment, and leaving the lower Score Trend Graph completely uncompressed.

## Risks / Trade-offs

- **[Risk] Driver reports extension support but fails during acceleration structure or pipeline creation**:
  - *Mitigation*: Wrap ray tracing pipeline initialization in protected initialization blocks; if pipeline creation fails, mark `fRayTracingSupported := false` and proceed without crashing.
- **[Risk] Displaying "N/A" might confuse users thinking the benchmark failed**:
  - *Mitigation*: Render clear secondary subtitle under N/A explaining "No Hardware RT Support" with a neutral muted color instead of an error state.
