# Spec Delta

## Purpose

Provides automated lifecycle management, release downloads, one-time neural weights extraction from user-provided NVIDIA DLLs, configuration generation, and direct-file game deployment for DLSS 5 Neural Rendering (DLSS-NR) on AMD Radeon GPUs.

## ADDED Requirements

### Requirement: GPU Architecture Detection and Override
The system SHALL detect whether the active AMD graphics hardware is RDNA3 or RDNA4 and default the DLSS-NR architecture selector accordingly. The user SHALL be able to manually override the selected architecture between Auto-detect, RDNA4, and RDNA3.

#### Scenario: Auto-detecting RDNA3 GPU
- **WHEN** the system initializes on a host with an RDNA3 AMD graphics card (such as RX 7900 series or gfx11)
- **THEN** the architecture selector defaults to Auto-detect, resolving to the RDNA3 runtime profile
- **AND** the Model Resolution control defaults to 50% for optimal frame times.

#### Scenario: Auto-detecting RDNA4 GPU
- **WHEN** the system initializes on a host with an RDNA4 AMD graphics card (such as RX 9000 series or gfx12)
- **THEN** the architecture selector defaults to Auto-detect, resolving to the RDNA4 runtime profile
- **AND** the Model Resolution control defaults to 100%.

#### Scenario: User manually overrides architecture
- **WHEN** the user manually changes the architecture selector to a specific generation (e.g. RDNA3 or RDNA4)
- **THEN** the system switches the active download target, runtime directory, and configuration defaults to match the selected architecture.

### Requirement: Central Runtime Download and Storage
The system SHALL download and cache the appropriate DLSS-NR release package into a central data directory for the selected architecture. The system SHALL prevent redundant re-downloads when the current release is already cached.

#### Scenario: Downloading DLSS-NR release package
- **WHEN** DLSS-NR is selected and the required architecture runtime package is not present in central storage
- **THEN** the system downloads the latest release archive from the corresponding repository (RDNA4 from mochizuki0323/DLSSNR-AMD or RDNA3 from mauri870/DLSSNR-RDNA3)
- **AND** unpacks the binaries and support tools into the central DLSS-NR directory while updating the cached version string.

### Requirement: One-Time Neural Weights Extraction
The system SHALL allow the user to select their own copy of `nvngx_dlssnr.dll` or a containing archive to extract the neural network weights into central storage. Extraction SHALL occur once and be verified against known SHA-256 checksums, enabling persistent offline installations.

#### Scenario: Successful model weights extraction
- **WHEN** the user selects a valid `nvngx_dlssnr.dll` file (v310.9.16 or v310.8.0) via the file picker
- **THEN** the system runs the model extraction tool against the provided DLL
- **AND** verifies the SHA-256 checksums of the generated binary models (`dlssnr.bin` and optionally `dlssnr-small.bin`)
- **AND** marks the model status indicator as ready in the UI.

#### Scenario: User provides invalid or corrupted DLL
- **WHEN** the user provides an incompatible DLL version or corrupted file
- **THEN** the system notifies the user of the invalid checksum or unsupported version without corrupting central cache.

### Requirement: Direct File Deployment to Game Profiles
The system SHALL synchronize DLSS-NR runtime files into the target game directory using direct file copies without invoking external installer shell scripts. The system SHALL record all installed files in a manifest to ensure clean uninstallation.

#### Scenario: Deploying DLSS-NR with OptiScaler route
- **WHEN** DLSS-NR is deployed to a game directory using the OptiScaler route
- **THEN** the system copies the OptiScaler-NR proxy DLL, the DLSS-NR backend library, the extracted neural model binaries, and generated `dlssnr-amd.ini` directly into the game folder
- **AND** writes an install manifest listing all copied files.

#### Scenario: Uninstalling DLSS-NR from game directory
- **WHEN** the user requests to uninstall or remove DLSS-NR from a game profile
- **THEN** the system removes only the files tracked in the install manifest and deletes the manifest file.

### Requirement: Software Status Version Reporting
The system SHALL display the installed DLSS-NR version, target architecture, and model readiness status in the Home tab's Software Status section.

#### Scenario: Displaying DLSS-NR status when installed and ready
- **WHEN** DLSS-NR runtime is installed and valid model weights are cached
- **THEN** the Software Status displays "DLSS-NR" with the installed version tag, target architecture (RDNA3/RDNA4), and a green status indicator.

#### Scenario: Displaying DLSS-NR status when weights are missing
- **WHEN** DLSS-NR runtime is present but model weights have not yet been extracted
- **THEN** the Software Status displays "DLSS-NR" with an amber status indicator indicating that the model DLL needs to be provided.

### Requirement: Configuration Options and INI Generation
The system SHALL provide UI controls for Route, Model Version, Model Resolution Scale, Int4 Mixed, RenoDX Style, and Preprocess Auto-exposure, writing the selections into `dlssnr-amd.ini` in the game directory.

#### Scenario: Generating dlssnr-amd.ini with custom options
- **WHEN** DLSS-NR configuration is saved for a game
- **THEN** the system generates `dlssnr-amd.ini` containing the configured network model, resolution scale, RenoDX style state, and preprocess settings.
