## ADDED Requirements

### Requirement: Automatic download and configuration of FSR INT8 and Latest DLLs
The system SHALL automatically create the folders `FSR4_INT8` and `FSR4_LATEST` inside the pristine OptiScaler installation directory (`.bgmod_original`) after extracting a newly downloaded OptiScaler release.
The system SHALL copy the extracted `amd_fidelityfx_upscaler_dx12.dll` (default latest version) to the `FSR4_LATEST/amd_fidelityfx_upscaler_dx12.dll` path.
The system SHALL download the FSR INT8 DLL from `https://github.com/benjamimgois/OptiScaler-builds/releases/download/fsr-int8/amd_fidelityfx_upscaler_dx12.dll` to `FSR4_INT8/amd_fidelityfx_upscaler_dx12.dll`.
The system SHALL synchronize the folders `FSR4_LATEST` and `FSR4_INT8` from `.bgmod_original` to the working `bgmod` directory.

#### Scenario: Manual Update
- **WHEN** the user updates OptiScaler using the "Update" button in the GOverlay interface
- **THEN** GOverlay creates the folders `FSR4_LATEST` and `FSR4_INT8` under `.bgmod_original`, copies the Latest DLL to `FSR4_LATEST`, downloads the INT8 DLL to `FSR4_INT8`, and synchronizes these folders to `bgmod/`

#### Scenario: Automatic Installation on startup
- **WHEN** GOverlay automatically downloads and installs OptiScaler on startup
- **THEN** GOverlay creates the folders `FSR4_LATEST` and `FSR4_INT8` under `.bgmod_original`, copies the Latest DLL to `FSR4_LATEST`, downloads the INT8 DLL to `FSR4_INT8`, and recursively copies the folders to the global `bgmod/` folder
