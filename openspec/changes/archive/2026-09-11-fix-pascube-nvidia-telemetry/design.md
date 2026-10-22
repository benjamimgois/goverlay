## Context

PasCube collects CPU/GPU peak temperature and power metrics to include in benchmark submissions. Previously, these queries were executed synchronously within `TPasCubeScreen.Draw` whenever `fBenchmarkTimer - fLastTelemetryTime > 0.1`. On NVIDIA systems, this caused two separate `nvidia-smi` calls per frame, locking frame rates to ~4.8 FPS and causing a cascade of issues (false low-FPS fallback, invalid scores). See `proposal.md` for background.

## Goals / Non-Goals

**Goals:**
- Decouple all telemetry collection from the Vulkan rendering thread by introducing `TTelemetryThread : class(TThread)`.
- Replace dual `nvidia-smi` queries with a single atomic query returning both metrics: `nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv,noheader,nounits`.
- Maintain full compatibility with AMD (`amdgpu` hwmon) and Intel (`i915`/`xe` hwmon/RAPL) sysfs readers.
- Completely eliminate process spawning and file reading from `TPasCubeScreen.Draw`.

**Non-Goals:**
- Creating dynamic C bindings to `libnvidia-ml.so` (NVML) directly in Pascal; keeping the unified `nvidia-smi` call in a background thread gives ~0% render overhead without adding complex C runtime linkage or headers.
- Real-time graphing or telemetry history streaming.

## Decisions

### Decision 1: Thread Lifecycle Management
- **Choice**: Spawn `TTelemetryThread` during `InitBenchmark` and terminate/free it during `FinishBenchmark` (and clean up in `TPasCubeScreen.Destroy`).
- **Alternative**: Spawning one-shot threads for every sample.
- **Rationale**: A persistent thread during the benchmark loop avoids thread creation overhead. It sleeps for 500ms between samples, waking up only to collect and record peak metrics.

### Decision 2: Sampling Frequency (500ms)
- **Choice**: Loop with `Sleep(500)` inside `TTelemetryThread.Execute` while not `Terminated`.
- **Alternative**: 100ms or 1000ms.
- **Rationale**: Thermal mass prevents significant temperature swings within 100ms, and power plateau is reached over seconds. 500ms provides high peak capture accuracy with virtually no CPU footprint.

### Decision 3: Unified NVIDIA Query & Parsing
- **Choice**: A dedicated routine in the thread executes:
  `nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv,noheader,nounits`
  Output format: `<temp_int>, <power_float>` (e.g. `65, 230.45`).
- **Alternative**: Retaining two separate routines for temp and power.
- **Rationale**: Halves process spawns and NVML initializations, sampling temperature and power simultaneously.

### Decision 4: Thread Synchronization
- **Choice**: The thread updates `fCurrentResult.CPUTempMax`, `fCurrentResult.GPUTempMax`, `fCurrentResult.CPUPowerMax`, `fCurrentResult.GPUPowerMax` directly (or via protected setter), as scalar Double assignments are atomic on x86_64, and telemetry is only read for final display after `FinishBenchmark`.
- **Alternative**: Heavy mutex locking on every frame.
- **Rationale**: `Draw` no longer touches telemetry during frames; results are only consumed on the results screen when the benchmark is complete.

## Risks / Trade-offs

- **[Risk] Thread termination delay** → When benchmark ends, the thread could be inside a 500ms sleep or `nvidia-smi` call.
  - *Mitigation*: Use a loop checking `Terminated` in smaller sleep increments (e.g., 10x 50ms) or ensure `WaitFor` terminates gracefully before final submission.
