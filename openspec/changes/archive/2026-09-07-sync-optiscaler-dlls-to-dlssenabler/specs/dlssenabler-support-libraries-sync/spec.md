## Purpose

Ensures DLSS Enabler cache directories contain all necessary OptiScaler supporting libraries, upscalers, Frame Generation bridges, and plugins for reliable deployment.

## ADDED Requirements

### Requirement: Synchronization of OptiScaler supporting libraries to DLSS Enabler
The system SHALL synchronize all supporting libraries, Frame Generation bridge DLLs, plugins, and helper tools from the corresponding OptiScaler cache directory into the DLSS Enabler cache directory upon installation or verification.

#### Scenario: DLSS Enabler installation populates all OptiScaler supporting DLLs
- **WHEN** DLSS Enabler is installed or extracted into the cache directory
- **THEN** all supporting libraries from the corresponding OptiScaler cache directory (including FSR DLLs, XeSS DLLs, FakeNVAPI, and `dlssg_to_fsr3_amd_is_better.dll`) are copied into the DLSS Enabler cache directory.

#### Scenario: Preservation of native DLSS Enabler binaries
- **WHEN** supporting libraries are synchronized into the DLSS Enabler cache directory
- **THEN** native DLSS Enabler binaries (such as `version.dll`, `sl.*.dll`, `WinPixEventRuntime.dll`, and `goverlay.vars`) are preserved and not overwritten.

#### Scenario: Self-healing synchronization on existing cache directories
- **WHEN** an existing DLSS Enabler cache directory is verified and missing any critical supporting library (such as `dlssg_to_fsr3_amd_is_better.dll` or `amd_fidelityfx_upscaler_dx12.dll`)
- **THEN** the system automatically copies the missing supporting files from the corresponding OptiScaler cache directory without requiring a full re-download.
