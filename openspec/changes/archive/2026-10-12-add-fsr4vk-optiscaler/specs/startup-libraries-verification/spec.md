# Spec Delta

## MODIFIED Requirements

### Requirement: Mandatory Startup Libraries Verification
The system SHALL verify the presence of all mandatory DLSS, upscaler, and post-processing libraries during application startup before launching the main window.
Mandatory libraries include:
- `OptiScaler.dll` and `amd_fidelityfx_upscaler_dx12.dll` in the OptiScaler stable cache directory
- `nvngx_dlss.dll`, `nvngx_dlssd.dll`, `nvngx_dlssg.dll`, `dlssg_to_fsr3_amd_is_better.dll`, and `fakenvapi.dll` in the OptiScaler stable cache directory
- `Latest/amd_fidelityfx_upscaler_dx12.dll`, `4.1.1b/amd_fidelityfx_upscaler_dx12.dll`, and `4.0.2c/amd_fidelityfx_upscaler_dx12.dll` in the central `FSR4/` directory
- `OptiScaler.dll` and `OptiScaler/amd_fidelityfx_upscaler_vk.dll` in the `optiscaler-fsr4vk/` cache directory
- DLSS Enabler `version.dll` in the DLSS Enabler stable directory
- `ReShade64.dll` and `ReShade32.dll` in the central ReShade directory (`~/.local/share/goverlay/reshade/bin/`)
- Standard Shaders directory (`~/.local/share/goverlay/reshade/shaders/Shaders/`) containing default shader files
- vkBasalt ReShade shaders repository directory (`~/.config/vkBasalt/reshade-shaders/`) containing shader files

#### Scenario: All mandatory libraries exist
- **WHEN** GOverlay launches and all mandatory libraries exist on disk
- **THEN** the system bypasses the download splash screen and displays the main application window immediately.

#### Scenario: One or more mandatory libraries are missing
- **WHEN** GOverlay launches and any mandatory library is missing
- **THEN** the system displays the boot splash screen and initiates background downloads for the missing files.

### Requirement: Targeted Self-Healing Downloads
The system SHALL download only missing libraries without forcing a complete re-download of already installed components.

#### Scenario: Only FSR4 or companion libraries missing
- **WHEN** `OptiScaler.dll` exists but specific companion DLLs or FSR4 version DLLs are missing
- **THEN** the system preserves the existing OptiScaler installation and downloads only the missing companion and FSR4 files.

#### Scenario: FSR4VK binaries missing
- **WHEN** `optiscaler-fsr4vk/` binaries are missing
- **THEN** the system initiates a background download of the latest release from `dvj5411/fsr4vk` and extracts it into `optiscaler-fsr4vk/`.
