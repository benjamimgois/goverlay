## 1. Core Functions & FSR4 Modularization

- [x] 1.1 Implement `CheckAndInstallFsr4` in `optiscaler_update.pas` and verify it checks/downloads `Latest`, `4.1.1b`, and `4.0.2c` into `GetFSR4BasePath` with progress reporting and error capture
- [x] 1.2 Implement self-healing companion checks in `CheckAndInstallOptiScaler` in `optiscaler_update.pas` so that existing `OptiScaler.dll` installations still fetch missing NVIDIA DLSS DLLs, FrameGen bridge, and FakeNVAPI
- [x] 1.3 Implement `HasMissingMandatoryLibraries` in `optiscaler_update.pas` to audit all required DLSS, OptiScaler, and FSR4 files

## 2. Startup Flow & Error Reporting

- [x] 2.1 Update `StartupDownloadsAsync` in `overlayunit.pas` to use `HasMissingMandatoryLibraries` and trigger boot splash when any mandatory library is absent
- [x] 2.2 Update `TStartupDownloadThread` in `overlayunit.pas` to invoke `CheckAndInstallFsr4`, record download failures, and proceed gracefully without thread crashes
- [x] 2.3 Add toast notification strings to `goverlay_strings.pas` and trigger `ShowToast` after `HideBootSplash` and `Self.Show` in `overlayunit.pas` if any required file failed to download

## 3. Verification & Build

- [x] 3.1 Build GOverlay using `make` or `lazbuild` to verify clean compilation without syntax or linkage errors
- [x] 3.2 Verify startup behavior with simulated missing files to ensure targeted downloads and fault-tolerant notification display
