## Purpose

Provides a dedicated hardware-accelerated Vulkan Ray Tracing benchmark phase in PasCube, producing an independent performance score without altering the primary system score.

## ADDED Requirements

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
