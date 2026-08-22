## 1. GOverlay Parameter Synthesis

- [x] 1.1 In `overlayunit.pas`, declare and implement `GetPasCubeLosslessParam: string;` and append it to `PreviewBtnClick` and `runpascubetItemClick` when Lossless Scaling launch env is active.

## 2. PasCube Lossless Scaling Detection & CLI Parsing

- [x] 2.1 In `pascube_src/src/UnitPasCubeApplication.pas`, add property `LosslessScalingActive: Boolean` and parse `--lossless-scaling` / `--lsfg-active` CLI flags, with fallback checking for `LSFG_CONFIG` / `ENABLE_LSFGVK` environment variables.

## 3. PasCube UI Disabling & Warning Banner

- [x] 3.1 In `pascube_src/src/UnitPasCubeScreen.pas`, update `DrawIdleMenu` to render the "Start benchmark" button in a disabled/dimmed style when `LosslessScalingActive` is true.
- [x] 3.2 In `pascube_src/src/UnitPasCubeScreen.pas`, render a centered amber warning banner on the idle menu informing that benchmarks are disabled due to Lossless Scaling.
- [x] 3.3 In `pascube_src/src/UnitPasCubeScreen.pas`, ensure `IsStartButtonHovered` returns false when `LosslessScalingActive` is true, and add defensive guards in `StartBenchmark` and `SubmitBenchmarkResults`.

## 4. Verification and Build

- [x] 4.1 Recompile `goverlay` and `pascube` with `make clean && make` and verify 0 compilation errors.
- [x] 4.2 Run the full GUI test suite (`lazbuild --ws=qt6 tests/gui/gui_tests.lpi && xvfb-run ./tests/gui/gui_tests --all`) and verify all tests pass.
