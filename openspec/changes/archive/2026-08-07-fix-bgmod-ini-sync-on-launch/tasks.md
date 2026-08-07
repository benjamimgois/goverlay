# Implementation Tasks: Fix INI File Sync on Launch in bgmod

- [x] 1. Update INI Synchronization Logic in `bgmod.lpr`
  - [x] 1.1 In `bgmod.lpr`, update `SyncOptiScalerIni` to always copy `ConfigDir/OptiScaler.ini` to `GameDir/OptiScaler.ini` whenever `ConfigDir/OptiScaler.ini` exists.
  - [x] 1.2 In `bgmod.lpr`, add `SyncFakeNvapiIni` to copy `ConfigDir/fakenvapi.ini` to `GameDir/fakenvapi.ini` whenever `ConfigDir/fakenvapi.ini` exists.
  - [x] 1.3 In `bgmod.lpr`, remove the default `OptiBaseDir/OptiScaler.ini` template copy in section 5a (DLSS Enabler setup) to prevent overwriting user settings.
  - [x] 1.4 In `bgmod.lpr`, ensure `SyncOptiScalerIni` and `SyncFakeNvapiIni` are called during both upscaler update and upscaler skip-copy branches.

- [x] 2. Build & Verification
  - [x] 2.1 Rebuild `bgmod` using `fpc -O3 bgmod.lpr` and `make`.
  - [x] 2.2 Verify that modifications to `OptiScaler.ini` and `fakenvapi.ini` in `ConfigDir` are synchronized to `GameDir` on launch.
