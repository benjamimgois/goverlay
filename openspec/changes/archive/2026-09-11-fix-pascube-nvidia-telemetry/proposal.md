## Why

During benchmark execution on Linux systems with NVIDIA graphics cards, PasCube freezes and drops to ~4.8 FPS across all phases (warmup, single-thread, multi-thread, and GPU stress). This occurs because telemetry queries (`GetGPUTemperature` and `GetGPUPower`) run synchronously inside `TPasCubeScreen.Draw` on every frame, repeatedly executing `nvidia-smi` via `TProcess`. Each invocation of `nvidia-smi` takes ~80-120ms, causing each frame to block for ~200ms, triggering a false low-FPS fallback to 360p and corrupting benchmark scores. Moving telemetry to an asynchronous background thread with a unified `nvidia-smi` call resolves this severe regression.

## What Changes

- **Asynchronous Telemetry Thread (`TTelemetryThread`)**: Decouple temperature and power telemetry sampling from the graphics rendering loop (`TPasCubeScreen.Draw`). The background thread samples telemetry at a fixed non-intrusive interval (e.g., 500ms) without blocking frame presentation.
- **Unified NVIDIA Query**: Replace two separate `nvidia-smi` calls (`temperature.gpu` and `power.draw`) with a single invocation: `nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv,noheader,nounits`.
- **Thread-safe Max Value Tracking**: Telemetry thread updates peak metrics (`CPUTempMax`, `GPUTempMax`, `CPUPowerMax`, `GPUPowerMax`) safely, which the render loop simply reads without performing any I/O or process spawning.
- **Render Loop Cleanup**: Remove synchronous `GetGPUTemperature`, `GetCPUTemperature`, `GetGPUPower`, and `UpdateCPUPower` invocations from `TPasCubeScreen.Draw`.

## Capabilities

### New Capabilities
- `pascube-async-telemetry`: Background asynchronous hardware telemetry collection for CPU/GPU temperature and power consumption during PasCube benchmarks, eliminating frame-time hitching and render pipeline stalling.

### Modified Capabilities
<!-- None -->

## Impact

- `pascube_src/src/UnitPasCubeScreen.pas`: Introduction of `TTelemetryThread`, lifecycle management (start during `InitBenchmark`, terminate in `FinishBenchmark`), removal of inline telemetry I/O in `Draw`, and unified parsing of `nvidia-smi` output.
- No external dependency changes.
- Performance on NVIDIA systems restored to native GPU framerates (hundreds of FPS instead of ~4.8 FPS).
