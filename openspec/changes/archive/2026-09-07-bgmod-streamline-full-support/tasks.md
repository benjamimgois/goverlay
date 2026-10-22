## 1. Streamline SDK Support in bgmod.lpr

- [x] 1.1 Add all Streamline SDK DLLs to `OrigDlls` in `bgmod.lpr` so native game files are safely backed up before replacement and restored on uninstallation.
- [x] 1.2 Update Streamline copy logic in `bgmod.lpr` to copy all available Streamline DLLs (including `sl.pcl.dll`, `sl.deepdvc.dll`, `sl.directsr.dll`, `sl.dlss_d.dll`, `sl.imgui.dll`, `sl.nvperf.dll`) from `SourceDir`.
- [x] 1.3 Compile `bgmod` binary with `fpc bgmod.lpr` and verify exit code 0.

## 2. Automated Testing and Verification

- [x] 2.1 Add automated tests in `tests/gui/gui_test_cases.pas` verifying backup of native Streamline DLLs, deployment of `sl.pcl.dll` and other Streamline libraries, and restoration on cleanup.
- [x] 2.2 Run `./tests/gui/gui_tests --all --format=plain` and `./tests/logic/logic_tests --all --format=plain` and verify all tests pass without regressions.
