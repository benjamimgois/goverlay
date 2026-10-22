## 1. Bidirectional INI Synchronization in bgmod

- [x] 1.1 Add `PreserveFileTimestamp(Src, Dest)` helper in `bgmod.lpr` to copy modification times between files
- [x] 1.2 Refactor `SyncOptiScalerIni` in `bgmod.lpr` to perform bidirectional timestamp-based sync (`AgeGame > AgeConfig` vs `AgeConfig > AgeGame`) and preserve timestamps
- [x] 1.3 Update `SyncFakeNvapiIni` in `bgmod.lpr` to safely sync and preserve timestamps
- [x] 1.4 Ensure `PRESERVE_INI=false` forces one-way copy from `ConfigDir` to `GameDir`

## 2. Compilation and Verification

- [x] 2.1 Compile `bgmod` using `fpc -O3 bgmod.lpr` and ensure clean build with no errors
- [x] 2.2 Verify timestamp comparisons and file synchronization logic in test cases or simulated runs
