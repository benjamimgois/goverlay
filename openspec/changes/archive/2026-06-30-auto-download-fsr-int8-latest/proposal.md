## Why

When installing or updating OptiScaler, users currently have to manually create the `FSR4_INT8` folder and download the INT8-compatible FSR DLL, as well as manually create the `FSR4_LATEST` folder and copy the default DLL into it. Without these folders and DLLs, GOverlay cannot swap between the FSR versions ("4.0.2c (INT8)" vs "Latest"), which leads to configuration errors or manual user overhead.

## What Changes

- **Automatic Directory Creation**: During both manual updates and automatic installations of OptiScaler, GOverlay will automatically create the `FSR4_INT8` and `FSR4_LATEST` subdirectories inside `.bgmod_original`.
- **Latest FSR Version Copy**: Copy the `amd_fidelityfx_upscaler_dx12.dll` file extracted from the OptiScaler bundle into `FSR4_LATEST/amd_fidelityfx_upscaler_dx12.dll`.
- **INT8 FSR Version Download**: Download `amd_fidelityfx_upscaler_dx12.dll` from the official release URL (`https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8/amd_fidelityfx_upscaler_dx12.dll`) directly into `FSR4_INT8/amd_fidelityfx_upscaler_dx12.dll`.
- **Directory Synchronization**: Sychronize both directories from the pristine `.bgmod_original` store to the global active `bgmod/` folder.

## Capabilities

### New Capabilities
- `auto-configure-fsr-dlls`: Automatically downloads, sets up, and synchronizes the FSR4_INT8 and FSR4_LATEST folders with their respective upscaler DLLs.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Code**: `optiscaler_update.pas` (both GUI installation and auto-install routines).
- **External Dependencies**: Requires network access to download the INT8 DLL from GitHub.
