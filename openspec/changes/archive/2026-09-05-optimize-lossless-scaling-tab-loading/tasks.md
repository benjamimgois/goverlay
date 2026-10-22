## 1. Eliminate Blocking Process Execution

- [x] 1.1 Refactor `GetLsfgVkInstalledVersion` to parse `"implementation_version"` directly from `ALayerJsonPath` using JSON parsing without calling external shell processes, verifying with tests
- [x] 1.2 Add caching for detected `lsfg-vk` and `MAKO` versions to avoid repeated file reads on subsequent tab activations

## 2. Decouple Layout, Styling, and State Cascades

- [x] 2.1 Remove `UpdateDllStatus` from `ApplyThemeStyles` and remove `UpdateEngineStatus` from `UpdateDllStatus` in `lossless_scaling_tab.pas`
- [x] 2.2 Remove `ApplyThemeStyles` from `ReflowLosslessScalingTab` so layout reflow does not trigger theme reapplications or state updates
- [x] 2.3 Optimize `LoadLosslessConfig` to call `UpdateDllStatus`, `UpdateEngineStatus`, and `UpdateStatusCard` in sequence exactly once without re-entrant calls
- [x] 2.4 Fix `TMakoCheckUpdateThread.SyncResult` to update UI elements directly without triggering `ReflowLosslessScalingTab` or re-spawning threads

## 3. On-Demand Steam Library Scanning and Show Deduplication

- [x] 3.1 Make `DetectSteamLosslessDll` lazy in `LoadLosslessConfig`, running only if `FLsDllPathEdit.Text` is empty after checking profile configuration
- [x] 3.2 Guard `losslessScalingTabSheetShow` against redundant back-to-back executions during tab switches

## 4. Verification and Benchmark

- [x] 4.1 Run full GUI test suite (`tests/gui/gui_tests --all`) and verify all tests pass
- [x] 4.2 Run logic test suite (`tests/logic/logic_tests --all`) and verify all tests pass
- [x] 4.3 Build and verify `goverlay` binary compilation
