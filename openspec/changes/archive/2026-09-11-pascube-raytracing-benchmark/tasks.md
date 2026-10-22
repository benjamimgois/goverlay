## 1. Hardware Capability Detection and State Machine Setup

- [x] 1.1 Implement Vulkan Ray Tracing physical device extension query in PasCube and initialize `fRayTracingSupported` flag
- [x] 1.2 Add `bpRT_1080p` to `TBenchmarkPhase` enumeration and wire phase name, duration (10s), and debug logging in `UnitPasCubeScreen.pas`
- [x] 1.3 Update `NextPhase` to transition from `bpGPU_1080p` to `bpRT_1080p` if `fRayTracingSupported`, or bypass directly to `bpResults` if unsupported

## 2. Ray Tracing Benchmark Workload and Score Computation

- [x] 2.1 Implement the ray tracing stress rendering pass / pipeline execution during `bpRT_1080p` with frame time and FPS accumulation
- [x] 2.2 Calculate independent `RTScore` and store phase metrics in `PhaseResults` without altering the global `TotalScore` formula
- [x] 2.3 Extend `benchmark_results.json` serialization and deserialization to persist Ray Tracing phase results and hardware support status

## 3. Results Overlay Layout Redesign

- [x] 3.1 Split Row 2 of `DrawResultsOverlay` into two symmetrical cards (`GPU Raster Score` and `Ray Tracing Score`)
- [x] 3.2 Implement conditional rendering for the Ray Tracing card showing numerical score on supported hardware and "N/A - Not Supported" on non-RT GPUs
- [x] 3.3 Verify text alignment, margins, and vertical harmony with the Score Trend graph and Hardware Comparison card

## 4. Verification and Regression Testing

- [x] 4.1 Compile `pascube` binary and verify clean compilation without warnings or errors
- [x] 4.2 Run GUI test suite (`./tests/gui/gui_tests --all`) to ensure GOverlay integrations and existing test suites pass with 0 errors
