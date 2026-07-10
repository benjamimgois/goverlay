## 1. Data Model and Initialization

- [x] 1.1 Add `CPUPowerMax` and `GPUPowerMax` fields (type `Double`) to the `TBenchmarkResult` record in `UnitPasCubeScreen.pas`.
- [x] 1.2 Add private field declarations `fLastCPUEnergy` (type `Int64`), `fLastCPUTime` (type `TpvDouble`), and `fLastTelemetryTime` (type `TpvDouble`) to the `TPasCubeScreen` class.
- [x] 1.3 Initialize the new telemetry fields to `0` and `0.0` at the start of the benchmark in `TPasCubeScreen.StartBenchmark` (or equivalent initialization block).

## 2. Power and Temperature Monitoring

- [x] 2.1 Implement `TPasCubeScreen.UpdateCPUPower` to read RAPL `/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj` and fallback to `/sys/class/hwmon/hwmon*/power1_input`.
- [x] 2.2 Implement `TPasCubeScreen.GetGPUPower` to query `/sys/class/hwmon/hwmon*/power1_average` on AMD/Intel, and execute `nvidia-smi` on NVIDIA cards.
- [x] 2.3 Update the benchmark draw/update loop to query and update maximum CPU/GPU temperatures and powers at a throttled rate (every 100ms) using `fLastTelemetryTime`.
- [x] 2.4 Call `UpdateCPUPower` inside `FinishBenchmark` to guarantee final maximum power values are captured.

## 3. Payload and Local History Serialization

- [x] 3.1 Update `SubmitBenchmarkResults` to serialize and attach `cpu_max_temp`, `cpu_temp_max`, `cpu_temp_delta`, `cpu_delta_temp`, `cpumaxpower`, `gpumaxpower`, and `goverlayversion` (using `pvApplication.Version`) to the submission payload.
- [x] 3.2 Update `LoadResultsJSON` and local save JSON functions in `UnitPasCubeScreen.pas` to persist and load CPU/GPU max powers in `benchmark_results.json`.

## 4. Confirmation UI Dialog

- [x] 4.1 Increase confirmation dialog height constant `boxH` from `36.0 * charHeight` to `42.0 * charHeight` in `IsSubmitConfirmButtonHovered`.
- [x] 4.2 Increase confirmation dialog height constant `boxH` from `36.0 * charHeight` to `42.0 * charHeight` in `Draw` (the submit confirmation rendering section).
- [x] 4.3 Add drawing calls for the 5 new telemetry values in the confirmation UI section of `Draw` at the designated vertical offsets.
