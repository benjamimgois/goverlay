## 1. GOverlay Package Type Propagation

- [x] 1.1 Add GetGOverlayPackageEnv helper function to systemdetector.pas or overlayunit.pas.
- [x] 1.2 Update PasCube launch commands in overlayunit.pas to prepend the environment variable GOVERLAY_PACKAGE_TYPE.

## 2. PasCube Data Collection

- [x] 2.1 Add GetCPUArchitecture and GetPackageType helper functions to UnitPasCubeScreen.pas.
- [x] 2.2 Add BenchmarkDuration field to TBenchmarkResult record in UnitPasCubeScreen.pas.
- [x] 2.3 Set fCurrentResult.BenchmarkDuration to fBenchmarkTimer in TPasCubeScreen.FinishBenchmark.

## 3. PasCube JSON Serialization & Submission

- [x] 3.1 Update SaveResultsJSON to write "duration" to benchmark_results.json.
- [x] 3.2 Update LoadResultsJSON to read "duration" from benchmark_results.json.
- [x] 3.3 Update SubmitBenchmarkResults to add "architecture", "package", and "timer" keys to the submission JSON payload.

## 4. PasCube Confirmation Dialog UI

- [x] 4.1 Increase confirmation dialog height boxH to 38.0 * charHeight in IsSubmitConfirmButtonHovered and DrawSubmitConfirm in UnitPasCubeScreen.pas.
- [x] 4.2 Render CPU architecture, package type, and timer values in the confirmation dialog inside UnitPasCubeScreen.pas.

## 5. Verification

- [x] 5.1 Verify that the pascube benchmark compiles and launches correctly.
- [x] 5.2 Run a local run of pascube, verify the confirmation dialog displays the new details, and verify the correct fields are serialized.
