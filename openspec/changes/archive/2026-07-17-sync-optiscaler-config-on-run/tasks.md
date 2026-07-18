## 1. Implementation of Config Sync in bgmod.lpr

- [x] 1.1 Add helper function `SyncOptiScalerIni` in `bgmod.lpr` to compare modification times and sync `OptiScaler.ini`.
- [x] 1.2 Update the copy-skipped block in `bgmod.lpr` to call `SyncOptiScalerIni` and copy `fakenvapi.ini`.
- [x] 1.3 Update the install/update block in `bgmod.lpr` (specifically around step 6) to use the new `SyncOptiScalerIni` helper.

## 2. Compilation and Verification

- [x] 2.1 Compile `bgmod.lpr` using `fpc` to verify there are no syntax or type errors.
- [x] 2.2 Verify that `bgmod` runs and copies `OptiScaler.ini` and `fakenvapi.ini` appropriately based on the mtime rules.
