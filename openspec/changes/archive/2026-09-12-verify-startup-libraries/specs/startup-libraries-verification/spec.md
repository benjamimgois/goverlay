## Purpose

Ensures all mandatory upscaler and companion libraries are verified at application startup, triggers self-healing background downloads with a splash screen when files are missing, guarantees uninterrupted application access if downloads fail, and alerts the user with a notification.

## ADDED Requirements

### Requirement: Mandatory Startup Libraries Verification
The system SHALL verify the presence of all mandatory DLSS and upscaler libraries during application startup before launching the main window.
Mandatory libraries include:
- `OptiScaler.dll` and `amd_fidelityfx_upscaler_dx12.dll` in the OptiScaler stable cache directory
- `nvngx_dlss.dll`, `nvngx_dlssd.dll`, `nvngx_dlssg.dll`, `dlssg_to_fsr3_amd_is_better.dll`, and `fakenvapi.dll` in the OptiScaler stable cache directory
- `Latest/amd_fidelityfx_upscaler_dx12.dll`, `4.1.1b/amd_fidelityfx_upscaler_dx12.dll`, and `4.0.2c/amd_fidelityfx_upscaler_dx12.dll` in the central `FSR4/` directory
- DLSS Enabler `version.dll` in the DLSS Enabler stable directory

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

### Requirement: Fault-Tolerant Startup and Missing File Notification
The system SHALL allow GOverlay to open normally if any startup download fails and display a user notification detailing which files could not be obtained.

#### Scenario: Network download failure during startup
- **WHEN** a required file fails to download due to network failure, connection timeout, or server error
- **THEN** the boot splash closes, the main application window opens normally, and a toast notification is displayed listing the files that could not be downloaded.
