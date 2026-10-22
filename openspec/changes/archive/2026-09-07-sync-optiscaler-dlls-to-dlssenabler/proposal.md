## Why

When DLSS Enabler is downloaded and installed, only the core DLSS Enabler archive and Streamline SDK files (`version.dll`, `sl.*.dll`, `WinPixEventRuntime.dll`, etc.) are extracted into `dlssenabler-stable` or `dlssenabler-edge`. The supporting libraries and folders used by OptiScaler—such as AMD FidelityFX FSR DLLs, Intel XeSS/XeLL DLLs, FakeNVAPI, `dlssg_to_fsr3_amd_is_better.dll`, `D3D12_Optiscaler/`, `plugins/`, and `bgmod`—are missing from the DLSS Enabler cache folders. When deploying game assets with DLSS Enabler enabled (`UPSCALER_TYPE=1`), the game configuration and game directory fail to receive these critical files, causing DLSS Enabler system checks to fail and games (like God of War Ragnarök) to crash on startup.

## What Changes

- Implement `SyncOptiScalerFilesToDlssEnabler` in `optiscaler_update.pas` to copy all supporting DLLs (`amd_fidelityfx_*.dll`, `libxess*.dll`, `libxell.dll`, `dlssg_to_fsr3_amd_is_better.dll`, `fakenvapi.dll`, `fakenvapi.ini`, `OptiScaler.ini`, `OptiScaler.dll`), tool binaries (`bgmod`, `bgmod-uninstaller`, `fgmod`), and folders (`D3D12_Optiscaler/`, `plugins/`, `Licenses/`) from the matching OptiScaler cache directory into the DLSS Enabler cache directory.
- Preserve all DLSS Enabler native binaries (`version.dll`, `sl.*.dll`, `WinPixEventRuntime.dll`, `NvLowLatencyVk.dll`, `nvngx_deepdvc.dll`, and `goverlay.vars`) so that DLSS Enabler components are never overwritten.
- Trigger synchronization automatically after downloading and extracting DLSS Enabler and Streamline SDK in `CheckAndInstallDlssEnabler`.
- Trigger automatic self-healing synchronization in `CheckAndInstallDlssEnabler` whenever an existing DLSS Enabler cache directory is detected but missing essential supporting files (such as `dlssg_to_fsr3_amd_is_better.dll` or `amd_fidelityfx_upscaler_dx12.dll`), avoiding the need to re-download DLSS Enabler to fix an existing installation.
- Add automated GUI tests in `tests/gui/gui_test_cases.pas` to verify that all OptiScaler supporting libraries and folders are properly synchronized into DLSS Enabler cache directories.

## Capabilities

### New Capabilities
- `dlssenabler-support-libraries-sync`: Defines the requirement that DLSS Enabler cache directories (`dlssenabler-stable` and `dlssenabler-edge`) contain all supporting libraries, Frame Generation bridge DLLs, plugins, and helper tools from the corresponding OptiScaler cache directory.

### Modified Capabilities
<!-- None -->

## Impact

- `optiscaler_update.pas`: `CheckAndInstallDlssEnabler` and new helper `SyncOptiScalerFilesToDlssEnabler`.
- `tests/gui/gui_test_cases.pas`: New unit/GUI test verifying supporting files sync for DLSS Enabler stable and edge directories.
