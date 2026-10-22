## Purpose

Provides a dedicated hardware-accelerated Vulkan Ray Tracing benchmark phase in PasCube, producing an independent performance score without altering the primary system score.

## Requirements

### Requirement: Vulkan Ray Tracing Capability Detection
The benchmark engine SHALL query physical device Vulkan Ray Tracing support at initialization and determine whether the hardware ray tracing benchmark phase can be executed.

#### Scenario: GPU supports Vulkan Ray Tracing
- **WHEN** PasCube initializes and queries physical device features, finding `VK_KHR_ray_tracing_pipeline` or `VK_KHR_ray_query` along with acceleration structure support
- **THEN** the engine enables ray tracing features and marks the ray tracing benchmark phase as available.

#### Scenario: GPU does not support Vulkan Ray Tracing
- **WHEN** PasCube initializes and finds that the physical device lacks required Vulkan Ray Tracing extensions
- **THEN** the engine marks ray tracing capability as unavailable and configures the benchmark sequence to bypass the ray tracing phase without error.

### Requirement: Dedicated Ray Tracing Benchmark Phase Execution
The benchmark engine SHALL execute a dedicated ray-tracing stress phase (`bpRT_1080p`) immediately following the rasterized GPU benchmark phase when hardware ray tracing is supported.

#### Scenario: Ray tracing benchmark phase execution
- **WHEN** the rasterized GPU phase (`bpGPU_1080p`) finishes on a system with ray tracing support
- **THEN** the engine transitions to `bpRT_1080p`, executes the ray tracing benchmark workload for the designated phase duration, and records min, max, average FPS, and frame times.

#### Scenario: Bypassing ray tracing phase on unsupported hardware
- **WHEN** the rasterized GPU phase (`bpGPU_1080p`) finishes on a system lacking ray tracing support
- **THEN** the engine immediately transitions to `bpResults`, skipping the `bpRT_1080p` phase without crashing or delaying benchmark completion.

### Requirement: Independent Ray Tracing Score Calculation and Presentation
The benchmark system SHALL calculate an independent Ray Tracing score based on phase throughput while preserving the existing global gaming score formula, and display the result in a dedicated score card on the results overlay.

#### Scenario: Displaying Ray Tracing score on supported hardware
- **WHEN** the benchmark completes on hardware that executed `bpRT_1080p`
- **THEN** the results overlay displays the calculated Ray Tracing score in a dedicated card alongside the GPU Raster score card.

#### Scenario: Displaying unsupported status on non-RT hardware
- **WHEN** the benchmark completes on hardware that bypassed ray tracing
- **THEN** the results overlay displays "N/A - Not Supported" in the Ray Tracing score card with descriptive fallback text.

#### Scenario: Total gaming score remains unaffected
- **WHEN** the final score calculation occurs
- **THEN** `TotalScore` is computed using only CPU Single-Thread, CPU Multi-Thread, and GPU Raster scores (`0.35 * cpuST + 0.15 * cpuMT + 0.50 * gpuAvg`), leaving historical scores and database comparisons intact.

### Requirement: Calibrated Hardware Comparison Reference Scores
The benchmark results overlay SHALL present hardware comparison reference entries calibrated against verified database submissions for both primary benchmark scores and Ray Tracing scores.

#### Scenario: Displaying calibrated Entry Gamer PC reference scores
- **WHEN** the Hardware Comparison card renders the Entry Gamer PC reference item
- **THEN** the entry reflects 1,580 points for Main Score and 761 points for Ray Tracing score with specs indicating `i3 12100F` and `RX 6600 8GB`.

#### Scenario: Displaying calibrated Mid-Range Gamer PC reference scores
- **WHEN** the Hardware Comparison card renders the Mid-Range Gamer PC reference item
- **THEN** the entry reflects 2,751 points for Main Score and 1,713 points for Ray Tracing score with specs indicating `R5 7600` and `RTX 4060 Ti`.

#### Scenario: Displaying calibrated Steam Machine reference scores
- **WHEN** the Hardware Comparison card renders the Steam Machine reference item
- **THEN** the entry reflects 2,087 points for Main Score and 1,250 points for Ray Tracing score with specs indicating Zen 4 and RDNA3 28CU.

#### Scenario: Displaying calibrated Steam Deck reference scores
- **WHEN** the Hardware Comparison card renders the Steam Deck reference item
- **THEN** the entry reflects 818 points for Main Score and 174 points for Ray Tracing score with specs indicating Zen 2 and RDNA2 8CU.
