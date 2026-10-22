# Tasks

## 1. bgmod Logging for HelixSR, AFMF, and Tool Subdirectories

- [x] 1.1 Update `SyncGameDirLogsToCentral` in `bgmod.lpr` to synchronize `helixsr.log`, `helixsr_loader.log`, `nvexec.log`, and `afmf.log` from both `<GameDir>` and `<GameDir>/HelixSR/` (and subdirectories) into `CentralLogDir`.
- [x] 1.2 Update `RunSubprocessLogger` and logging initialization in `bgmod.lpr` to capture and route stderr output for HelixSR (`helixsr.log`) and AFMF (`afmf.log`).
- [x] 1.3 Rebuild `bgmod` binary using `make bgmod` and verify binary compilation succeeds.

## 2. GOverlay UI Active Tab Log Resolution

- [x] 2.1 Update `GetActiveTabLogFile` in `overlayunit.pas` to resolve `helixsr.log` when HelixSR is active on the OptiScaler tab, `afmf.log` when AFMF is active on the Frame Interpolation tab, and `reshade.log` on the ReShade tab.

## 3. Automated Verification and Tests

- [x] 3.1 Add tests in `tests/gui/gui_test_cases.pas` verifying that `GetActiveTabLogFile` correctly resolves `helixsr.log`, `afmf.log`, and `reshade.log` for their respective active tabs.
- [x] 3.2 Add tests in `tests/logic/logic_test_cases.pas` verifying that `SyncGameDirLogsToCentral` discovers and syncs logs from `<GameDir>` and `<GameDir>/HelixSR/`.
- [x] 3.3 Execute `make test` to verify complete test suite pass with 0 errors and 0 failures.
