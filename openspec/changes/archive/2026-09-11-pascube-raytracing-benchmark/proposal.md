## Why

Ray tracing (RT) has become a fundamental rendering technology in modern PC gaming for realistic reflections, global illumination, and shadows. PasCube currently tests CPU performance (single-thread and multi-thread via 7-Zip) and rasterized GPU stress at 1080p, but lacks a dedicated phase to measure hardware-accelerated ray tracing throughput. 

Adding an RT phase with an independent, dedicated score allows users to benchmark their GPU's ray-tracing capabilities without altering or invalidating existing overall benchmark scores or penalizing systems with GPUs that lack hardware RT support.

## What Changes

- Add a new benchmark phase `bpRT_1080p` executed after `bpGPU_1080p` when the GPU supports Vulkan Ray Tracing extensions (`VK_KHR_ray_tracing_pipeline` / `VK_KHR_acceleration_structure` or `VK_KHR_ray_query`).
- Automatically detect Vulkan Ray Tracing hardware capability at runtime; seamlessly bypass `bpRT_1080p` directly to `bpResults` if the GPU lacks hardware RT support.
- Maintain an independent Ray Tracing Score (`RTScore`), preserving the legacy `TotalScore` formula (`0.35 * cpuST + 0.15 * cpuMT + 0.50 * gpuAvg`) intact for backward compatibility with existing benchmarks, reference hardware comparisons, and PascubeDB.
- Redesign Row 2 of the Results screen (`DrawResultsOverlay`) to feature two balanced side-by-side cards: `GPU Raster Score` on the left and `Ray Tracing Score` on the right (displaying the computed score or `N/A - Not Supported` when hardware lacks RT capability).
- Persist Ray Tracing benchmark metrics (`score`, `fps_avg`, `fps_min`, `fps_max`, `frame_time_ms`, and RT hardware support flag) in `benchmark_results.json` within the phase results history.

## Capabilities

### New Capabilities
- `pascube-raytracing-benchmark`: Implements Vulkan Ray Tracing hardware capability detection, execution of a dedicated RT stress phase in PasCube, independent scoring calculation, and results overlay presentation.

### Modified Capabilities
*(None)*

## Impact
- `pascube_src/src/UnitPasCubeScreen.pas`: Phase state machine, timer handling, Vulkan RT detection, score calculation, JSON serialization, and UI overlay rendering.
- `pascube_src/src/UnitPasCubeApplication.pas` and Vulkan instance/device initialization: ensure required Ray Tracing extensions and features are queried and enabled conditionally when supported by the physical device.
- `benchmark_results.json`: Extended phase results record to store RT phase metrics without breaking schema compatibility.
