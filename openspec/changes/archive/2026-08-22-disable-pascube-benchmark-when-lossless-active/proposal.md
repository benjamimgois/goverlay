## Why

When Lossless Scaling (LSFG-VK) frame generation is active in GOverlay, running the PasCube system benchmark results in corrupt benchmark scores because interpolated frames inflate the reported GPU framerate (e.g., 2x, 3x, or 4x multiplier). This corrupts local benchmark history (`benchmark_results.json`) and leaderboard submissions. We need an effective mechanism to disallow benchmark execution while still allowing users to run PasCube in 3D preview mode with Lossless Scaling enabled.

## What Changes

- **Detect Lossless Scaling in PasCube**: PasCube checks if Lossless Scaling is active by inspecting environment variables (`LSFG_CONFIG`, `ENABLE_LSFGVK`) and command line parameters (`--lossless-scaling`, `--lsfg-active`).
- **Pass Lossless Scaling Indicator from GOverlay**: When GOverlay launches PasCube with `GetLosslessScalingLaunchEnv`, it passes `--lossless-scaling` in the parameter list.
- **Disable Benchmark Start in PasCube UI**: When Lossless Scaling is active, PasCube renders the "Start benchmark" button in a disabled/dimmed state, ignores click and keypress triggers to start the benchmark, and displays an informative warning banner: `[!] Benchmark disabled: Lossless Scaling is active. Disable it in GOverlay to run benchmarks.`
- **Prevent Corrupted Result Submissions & Saves**: PasCube enforces a secondary guard in `StartBenchmark` and `SubmitBenchmarkResults` to reject execution and submission if Lossless Scaling is detected.
- **Preserve 3D Preview and History**: Users can still view previously recorded benchmark results and use the 3D rotating cubes preview to visually evaluate Lossless Scaling smoothness.

## Capabilities

### Modified Capabilities
- `lossless-scaling-tab`: GOverlay passes `--lossless-scaling` when launching PasCube preview with active Lossless Scaling environment.
- `pascube-benchmark-compatibility`: PasCube detects active Lossless Scaling, disables the benchmark button, displays an explanatory message, and prevents benchmark recording or leaderboard submission.

## Impact

- `pascube_src/src/UnitPasCubeScreen.pas`: Implements detection, UI disabling/warning banner, and guards against starting/submitting benchmarks when Lossless Scaling is active.
- `pascube_src/src/UnitPasCubeApplication.pas`: Adds CLI parameter parsing for `--lossless-scaling`.
- `overlayunit.pas`: Appends `--lossless-scaling` to PasCube execution command when Lossless Scaling launch env is present.
