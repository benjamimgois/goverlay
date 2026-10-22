# Tasks

## 1. HelixSR Startup Verification & Companion Seeding

- [x] 1.1 In `optiscaler_update.pas`, update `GetMissingOptiScalerComponents` so HelixSR presence check requires `amd_fidelityfx_dx12.dll` without failing on missing `optiscaler/OptiScaler.dll`.
- [x] 1.2 In `optiscaler_update.pas`, update `CheckAndInstallHelixSR` verification to recognize compiled neural runtimes (`IsHelixSRCompiled`) and avoid triggering redundant downloads.
- [x] 1.3 In `optiscaler_update.pas`, add companion synchronization from `GetBGModOriginalPath` (stable OptiScaler cache) into `optiscaler-helixsr/optiscaler/` (`OptiScaler.dll`, `fakenvapi.dll`, `fakenvapi.ini`) when not bundled in upstream archive.

## 2. Testing and Validation

- [x] 2.1 Add test in `tests/gui/gui_test_cases.pas` asserting that `GetMissingOptiScalerComponents` passes when HelixSR compiled runtime is present and companions are synced.
- [x] 2.2 Run `make test` and ensure all GUI and logic test cases pass with 0 errors and 0 failures.
