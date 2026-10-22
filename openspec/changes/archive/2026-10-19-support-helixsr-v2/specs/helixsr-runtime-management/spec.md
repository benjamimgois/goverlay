# Spec Delta

## MODIFIED Requirements

### Requirement: Startup Verification and Download of HelixSR
The system SHALL verify the presence of the HelixSR runtime package in the central data directory during application initialization. If missing or lacking `amd_fidelityfx_dx12.dll` (either directly at the cache root or in the `HelixSR-fsrfg/` subdirectory) and `helixsr-setup.sh`, the system SHALL discover the latest release using GitHub REST API and unthrottled Atom feed fallbacks, unpacking the archive without executing shader compilation at startup. The system SHALL mirror `HelixSR-fsrfg/amd_fidelityfx_dx12.dll` and `HelixSR-fsrfg/helixsr.ini` to the cache root for backwards compatibility. Companion OptiScaler files SHALL be synchronized from `optiscaler-stable` or the bundled `helixsr-scaler/` payload. If compiled shaders are present, the system SHALL preserve the runtime and prevent re-download overwrites.

#### Scenario: Missing HelixSR assets at startup
- **WHEN** GOverlay launches and checks mandatory runtime libraries
- **AND** `~/.local/share/goverlay/optiscaler-helixsr/` is missing or lacks `amd_fidelityfx_dx12.dll` in both the cache root and `HelixSR-fsrfg/`
- **THEN** the system SHALL resolve the latest release via GitHub API or unthrottled Atom feed, download the archive, unpack it to `optiscaler-helixsr/`, mirror `HelixSR-fsrfg/amd_fidelityfx_dx12.dll` to root, synchronize companion OptiScaler binaries, and proceed to the main interface without initiating shader compilation.

#### Scenario: HelixSR assets already present at startup
- **WHEN** GOverlay launches and verifies mandatory runtime libraries
- **AND** `optiscaler-helixsr/` already contains `amd_fidelityfx_dx12.dll` (either in the cache root or in `HelixSR-fsrfg/`) and `helixsr-setup.sh`
- **THEN** the startup check SHALL succeed immediately without downloading duplicate archives.

#### Scenario: Compiled HelixSR runtime preserved
- **WHEN** `amd_fidelityfx_dx12.dll` in `optiscaler-helixsr/` or `optiscaler-helixsr/HelixSR-fsrfg/` carries the compiled network marker (`HXSRNET1`)
- **THEN** the startup verification SHALL treat the runtime as fully satisfied and SHALL NOT trigger a re-download of the base release archive.

### Requirement: On-Demand Neural Shader Compilation
The system SHALL verify whether the HelixSR Direct3D 12 neural network compute shaders have been compiled whenever the user selects the HelixSR method. If the network is uncompiled, the system SHALL ensure pre-compilation cleanup of stale temporary prefixes, select and validate a working Wine or Proton compatibility tool with fallback support, and display a compilation modal with live step-by-step progress tracking weights extraction, HLSL generation, and DXC shader compilation before finalizing method activation. Upon successful compilation, the system SHALL mirror the compiled `amd_fidelityfx_dx12.dll` from `HelixSR-fsrfg/` to the cache root.

#### Scenario: First activation with uncompiled shaders
- **WHEN** the user selects the HelixSR method
- **AND** `amd_fidelityfx_dx12.dll` in both `optiscaler-helixsr/` and `optiscaler-helixsr/HelixSR-fsrfg/` lacks the compiled network marker (`HXSRNET1`)
- **THEN** the system SHALL remove any existing temporary prefix directory at `~/.local/share/HelixSR/wineprefix` prior to starting execution
- **AND** open a compilation dialog displaying stage progress
- **AND** execute the compilation script using a validated Wine or Proton runtime with fallback capability
- **AND** synchronize the compiled DLL to the cache root and mark the HelixSR method as active with a success notification once compilation finishes.

#### Scenario: Subsequent activation with already compiled shaders
- **WHEN** the user selects the HelixSR method
- **AND** the compiled network marker (`HXSRNET1`) is present in `optiscaler-helixsr/` or `optiscaler-helixsr/HelixSR-fsrfg/amd_fidelityfx_dx12.dll`
- **THEN** the system SHALL immediately activate the HelixSR method without presenting the compilation dialog.

#### Scenario: Compilation failure handling
- **WHEN** shader compilation fails due to Wine runtime or shader compiler errors
- **THEN** the system SHALL present an informative error notification explaining that Wine or Proton runtime execution failed and advising verification of system Wine or compatible Proton versions.

### Requirement: HelixSR Game Profile Synchronization and Deployment
The system SHALL synchronize HelixSR runtime files into active game profiles according to the selected mode. In standard mode, the system SHALL deploy OptiScaler with the HelixSR backend and copy `helixsr-fg` when available for DLSS Frame Generation support. In experimental Native DLSS mode, the system SHALL deploy the DLSS loader, `nvngx.dll`, and `helixsr-fg` directly without OptiScaler while displaying a single-player safety notice.

#### Scenario: Standard HelixSR deployment
- **WHEN** the game profile has HelixSR active with Native DLSS disabled
- **THEN** the system SHALL write `UPSCALER_TYPE=3` to `bgmod.conf`
- **AND** deploy `OptiScaler.dll`, `fakenvapi.dll`, and `HelixSR/` containing `amd_fidelityfx_dx12.dll`, `helixsr.ini`, and `helixsr-fg/` (when present) into the game directory.

#### Scenario: Experimental Native DLSS deployment
- **WHEN** the game profile has HelixSR active with Native DLSS enabled
- **THEN** the system SHALL write `UPSCALER_TYPE=3` and `HELIXSR_NATIVE_DLSS=1` to `bgmod.conf`
- **AND** deploy `dlss-loader/dxgi.dll`, `nvngx.dll` (from `HelixSR-fsrfg/amd_fidelityfx_dx12.dll`), and `helixsr-fg/` into the game directory
- **AND** display an advisory notice warning against online multiplayer use with anti-cheat.

## ADDED Requirements

### Requirement: HelixSR v2 Advanced Configuration Options
The system SHALL support configuring and persisting HelixSR v2 options in `helixsr.ini`, including `Int8` acceleration and `NetworkResolution` under `[Upscaling]`, and `Preset` under `[DlssFrameGeneration]`.

#### Scenario: Saving and loading Int8 and NetworkResolution
- **WHEN** the user configures HelixSR neural upscaling parameters in the OptiScaler tab
- **THEN** the system SHALL persist `Int8` and `NetworkResolution` into the game profile's `helixsr.ini` under `[Upscaling]`
- **AND** restore these values when switching between game profiles.

#### Scenario: Saving and loading Frame Generation preset
- **WHEN** the user selects the Frame Generation preset (Light or Full) for HelixSR
- **THEN** the system SHALL persist `Preset` under `[DlssFrameGeneration]` in `helixsr.ini`
- **AND** restore the setting when loading the profile.

#### Scenario: HelixSR card UI reorganization
- **WHEN** the HelixSR upscaler method is active
- **THEN** the system SHALL hide the legacy Sharpener and Sharpness controls
- **AND** arrange the active controls vertically as Wave size, Network resolution, INT8 acceleration, Frame generation, and Native DLSS toggle
- **AND** maintain compact card dimensions fitting cleanly within the options container.

