## 1. Telemetry Thread Implementation

- [x] 1.1 Define and implement `TTelemetryThread` in `pascube_src/src/UnitPasCubeScreen.pas` with background sampling loop and responsive termination check.
- [x] 1.2 Implement unified NVIDIA telemetry query using `nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv,noheader,nounits` with comma-delimited parsing for temperature and power.
- [x] 1.3 Move AMD/Intel sysfs/hwmon and RAPL temperature and power collection routines to execute within `TTelemetryThread`.

## 2. Integration and Render Loop Decoupling

- [x] 2.1 Wire `TTelemetryThread` lifecycle in `TPasCubeScreen` (start in `InitBenchmark`, stop and free in `FinishBenchmark` and destructor).
- [x] 2.2 Remove synchronous telemetry calls (`GetGPUTemperature`, `GetCPUTemperature`, `GetGPUPower`, `UpdateCPUPower`) and telemetry timing checks from `TPasCubeScreen.Draw`.

## 3. Verification

- [x] 3.1 Compile PasCube with `lazbuild` or `fpc` and verify error-free build.
- [x] 3.2 Verify PasCube benchmark runs with uncapped/native framerates on NVIDIA GPUs without triggering the 360p fallback.
