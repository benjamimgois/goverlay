## 1. Supporting Libraries Synchronization Helper

- [x] 1.1 Implement `SyncOptiScalerFilesToDlssEnabler(AIsStable: Boolean)` in `optiscaler_update.pas` to copy all OptiScaler supporting libraries (`amd_fidelityfx_*.dll`, `libxess*.dll`, `libxell.dll`, `fakenvapi.dll`, `fakenvapi.ini`, `dlssg_to_fsr3_amd_is_better.dll`, `OptiScaler.ini`, `OptiScaler.dll`), subdirectories (`D3D12_Optiscaler`, `plugins`, `Licenses`), and wrapper scripts (`bgmod`, `bgmod-uninstaller`, `fgmod`) while strictly preserving native DLSS Enabler binaries (`version.dll`, `sl.*.dll`, `WinPixEventRuntime.dll`, `NvLowLatencyVk.dll`, `nvngx_deepdvc.dll`, and `goverlay.vars`), verifying syntax with `fpc`.
- [x] 1.2 Integrate `SyncOptiScalerFilesToDlssEnabler` into `CheckAndInstallDlssEnabler` after fresh extraction and within the early-exit check to automatically self-heal existing cache directories missing supporting files.

## 2. Automated Testing and Verification

- [x] 2.1 Add automated test cases in `tests/gui/gui_test_cases.pas` verifying that `dlssenabler-stable` and `dlssenabler-edge` receive all OptiScaler supporting files, directories, and FG bridges while preserving DLSS Enabler native binaries.
- [x] 2.2 Run both `./run_gui_tests.sh` and `./tests/run_tests.sh` and verify all tests pass without regression.
