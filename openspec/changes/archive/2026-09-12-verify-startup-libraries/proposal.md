## Why

Some users reported that FSR4 libraries (such as `4.1.1b` and `4.0.2c`) were not present after application startup or upgrade, forcing them to perform a full "Clear configuration" to re-download all assets from scratch. This occurred because initial startup checks only verified `OptiScaler.dll` and DLSS Enabler's `version.dll`, skipping downloads entirely if `OptiScaler.dll` already existed, and because `CheckAndInstallOptiScaler` exited early without verifying companion DLLs or FSR4 subdirectories.

All DLSS and FSR4 libraries are mandatory for proper operation and avoiding runtime errors in games. GOverlay should automatically detect any missing mandatory libraries on startup, display the splash screen to download only the missing components, open normally if network downloads fail, and inform the user via a toast notification regarding which files could not be obtained.

## What Changes

- Add a startup integrity verification routine (`HasMissingMandatoryLibraries` / `GetMissingMandatoryLibraries`) that checks for:
  - OptiScaler core: `OptiScaler.dll` and `amd_fidelityfx_upscaler_dx12.dll`
  - NVIDIA DLSS companion libraries: `nvngx_dlss.dll`, `nvngx_dlssd.dll`, `nvngx_dlssg.dll`
  - FrameGen bridge: `dlssg_to_fsr3_amd_is_better.dll`
  - FakeNVAPI: `fakenvapi.dll`
  - FSR4 versions: `Latest/amd_fidelityfx_upscaler_dx12.dll`, `4.1.1b/amd_fidelityfx_upscaler_dx12.dll`, and `4.0.2c/amd_fidelityfx_upscaler_dx12.dll`
  - DLSS Enabler core and companion libraries: `version.dll` and supporting files
- Update `StartupDownloadsAsync` to trigger the boot splash whenever any mandatory library is missing, rather than only checking `OptiScaler.dll` and `version.dll`.
- Make `CheckAndInstallOptiScaler` and startup download routines self-healing: if `OptiScaler.dll` already exists, check companion DLLs and FSR4 files, downloading only what is missing without redownloading the entire OptiScaler package.
- Ensure fault tolerance during startup downloads: if curl fails (due to no internet, timeout, or server error), the thread continues processing remaining files and collects the names of failed items without crashing or hanging.
- Ensure GOverlay always opens normally even if startup downloads fail.
- Display a toast notification (`ShowToast`) upon opening if any mandatory library could not be downloaded, listing the missing file(s).

## Capabilities

### New Capabilities
- `startup-libraries-verification`: Verifies mandatory upscaler and companion libraries on application startup, performs targeted self-healing downloads with the splash screen, guarantees normal application startup on download failure, and notifies the user with the list of files that could not be downloaded.

### Modified Capabilities
- `optiscaler-fsr4-versions`: Modifies requirement 2 to ensure FSR4 directories and alternative DLLs are verified and automatically downloaded/repaired during startup if missing, rather than only during full OptiScaler download or update.

## Impact

- `overlayunit.pas`: `StartupDownloadsAsync`, `TStartupDownloadThread`, and post-splash completion handling.
- `optiscaler_update.pas`: Self-healing download logic for OptiScaler companion DLLs and FSR4 versions when `OptiScaler.dll` already exists; error tracking for failed downloads.
- `goverlay_strings.pas`: Resourcestring for download failure toast notifications.
- No breaking changes for existing configurations or game profiles.
