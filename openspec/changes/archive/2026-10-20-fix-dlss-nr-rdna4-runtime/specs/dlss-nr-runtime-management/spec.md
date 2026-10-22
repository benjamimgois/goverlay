# Spec Delta

## MODIFIED Requirements

### Requirement: GPU Architecture Detection and Override
The system SHALL detect whether the active AMD graphics hardware is RDNA3 or RDNA4 and default the DLSS-NR architecture selector accordingly. The user SHALL be able to manually override the selected architecture between Auto-detect, RDNA4, and RDNA3. Detection SHALL inspect driver model strings and sysfs PCI device IDs, including RDNA 4 Navi 44 and Navi 48 device IDs.

#### Scenario: Auto-detecting RDNA3 GPU
- **WHEN** the system initializes on a host with an RDNA3 AMD graphics card (such as RX 7900 series or gfx11)
- **THEN** the architecture selector defaults to Auto-detect, resolving to the RDNA3 runtime profile
- **AND** the Model Resolution control defaults to 50% for optimal frame times.

#### Scenario: Auto-detecting RDNA4 GPU
- **WHEN** the system initializes on a host with an RDNA4 AMD graphics card (such as RX 9000 series, gfx12, or PCI device IDs 7590-7593, 7500-7506)
- **THEN** the architecture selector defaults to Auto-detect, resolving to the RDNA4 runtime profile
- **AND** the Model Resolution control defaults to 100%.

#### Scenario: User manually overrides architecture
- **WHEN** the user manually changes the architecture selector to a specific generation (e.g. RDNA3 or RDNA4)
- **THEN** the system switches the active download target, runtime directory, and configuration defaults to match the selected architecture.

### Requirement: Central Runtime Download and Storage
The system SHALL download and cache the appropriate DLSS-NR release package into a central data directory for the selected architecture. The system SHALL prevent redundant re-downloads when the current release is already cached. During model extraction and setup, the system SHALL download the runtime matching the target architecture rather than hardcoding RDNA3.

#### Scenario: Downloading DLSS-NR release package
- **WHEN** DLSS-NR is selected and the required architecture runtime package is not present in central storage
- **THEN** the system downloads the latest release archive from the corresponding repository (RDNA4 from mochizuki0323/DLSSNR-AMD into dlss-nr-rdna4 or RDNA3 from mauri870/DLSSNR-RDNA3 into dlss-nr-rdna3)
- **AND** unpacks the binaries and support tools into the central DLSS-NR directory while updating the cached version string.

### Requirement: Direct File Deployment to Game Profiles
The system SHALL synchronize DLSS-NR runtime files into the target game directory using direct file copies without invoking external installer shell scripts. When architecture is set to Auto-detect, the deployment launcher SHALL resolve the effective architecture based on the active GPU and deploy the matching architecture channel rather than defaulting to RDNA3.

#### Scenario: Deploying DLSS-NR with OptiScaler route
- **WHEN** DLSS-NR is deployed to a game directory using the OptiScaler route
- **THEN** the system copies the OptiScaler-NR proxy DLL, the DLSS-NR backend library, the extracted neural model binaries, and generated dlssnr-amd.ini directly into the game folder from the resolved architecture runtime channel (dlss-nr-rdna4 for RDNA4 or dlss-nr-rdna3 for RDNA3)
- **AND** writes an install manifest listing all copied files.

#### Scenario: Uninstalling DLSS-NR from game directory
- **WHEN** the user requests to uninstall or remove DLSS-NR from a game profile
- **THEN** the system removes only the files tracked in the install manifest and deletes the manifest file.
