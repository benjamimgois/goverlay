## 1. Data Model and Serialization Update

- [x] 1.1 Add `CPUMaxFreq` and `GPUMaxFreq` integer fields to the `TBenchmarkResult` record in `UnitPasCubeScreen.pas`.
- [x] 1.2 Update `SaveResultsJSON` in `UnitPasCubeScreen.pas` to serialize `"cpu_max_freq"` and `"gpu_max_freq"`.
- [x] 1.3 Update `LoadResultsJSON` in `UnitPasCubeScreen.pas` to deserialize `"cpu_max_freq"` and `"gpu_max_freq"`.

## 2. Telemetry Detection Implementation

- [x] 2.1 Implement helper function `ExtractMaxFreqFromPPDPM(const Content: string): Integer` to parse AMD `pp_dpm_sclk` output.
- [x] 2.2 Implement `GetCPUMaxFreq: Integer` in `UnitPasCubeScreen.pas` scanning sysfs paths and converting kHz to MHz.
- [x] 2.3 Implement `GetGPUMaxFreq: Integer` in `UnitPasCubeScreen.pas` for Intel/AMD/NVIDIA clock detection.
- [x] 2.4 Query and store CPU and GPU max frequencies into `fCurrentResult` at the start of the benchmark in `StartBenchmark`.

## 3. Submission Integration

- [x] 3.1 Update `SubmitBenchmarkResults` in `UnitPasCubeScreen.pas` to add `"cpumaxfreq"` and `"gpumaxfreq"` to the JSON payload.

## 4. Verification

- [x] 4.1 Build Goverlay and run Pascube benchmark to verify local results serialization.
- [x] 4.2 Verify the submitted payload contains the new keys `"cpumaxfreq"` and `"gpumaxfreq"`.

## 5. UI Integration

- [x] 5.1 Render CPU and GPU maximum frequencies in the submit confirmation dialog, increasing box height to 49.0.
