# Spec Delta

## Purpose

Provides automated lifecycle management, verification, on-demand compilation, and deployment for the HelixSR DLSS Model E neural upscaler runtime on AMD Radeon hardware.

## ADDED Requirements

### Requirement: Startup Verification and Download of HelixSR
The system SHALL verify the presence of the HelixSR runtime package in the central data directory during application initialization. If the runtime directory is missing or incomplete, the system SHALL automatically download and unpack the latest verified HelixSR release archive without executing shader compilation during the startup sequence.

#### Scenario: Missing HelixSR assets at startup
- **WHEN** GOverlay launches and checks mandatory runtime libraries
- **AND** `~/.local/share/goverlay/optiscaler-helixsr/` is missing or incomplete
- **THEN** the system SHALL download the HelixSR release archive, unpack it to `optiscaler-helixsr/`, and proceed to the main interface without initiating shader compilation.

#### Scenario: HelixSR assets already present at startup
- **WHEN** GOverlay launches and verifies mandatory runtime libraries
- **AND** `optiscaler-helixsr/` already contains the base setup files
- **THEN** the startup check SHALL succeed immediately without downloading duplicate archives.

### Requirement: On-Demand Neural Shader Compilation
The system SHALL verify whether the HelixSR Direct3D 12 neural network compute shaders have been compiled whenever the user selects the HelixSR method. If the network is uncompiled, the system SHALL display a compilation modal with live step-by-step progress tracking the weights extraction, HLSL generation, and DXC shader compilation via Proton or Wine before finalizing method activation.

#### Scenario: First activation with uncompiled shaders
- **WHEN** the user selects the HelixSR method
- **AND** `amd_fidelityfx_dx12.dll` in `optiscaler-helixsr/` lacks the compiled network marker (`HXSRNET1`)
- **THEN** the system SHALL open a compilation dialog displaying stage progress
- **AND** execute the compilation script using the system's available Proton/Wine runtime
- **AND** mark the HelixSR method as active with a success notification once compilation finishes.

#### Scenario: Subsequent activation with already compiled shaders
- **WHEN** the user selects the HelixSR method
- **AND** the compiled network marker (`HXSRNET1`) is present
- **THEN** the system SHALL immediately activate the HelixSR method without presenting the compilation dialog.

### Requirement: HelixSR Game Profile Synchronization and Deployment
The system SHALL synchronize HelixSR runtime files into active game profiles according to the selected mode. In standard mode, the system SHALL deploy OptiScaler with the HelixSR backend. In experimental Native DLSS mode, the system SHALL deploy the DLSS loader and `nvngx.dll` directly without OptiScaler while displaying a single-player safety notice.

#### Scenario: Standard HelixSR deployment
- **WHEN** the game profile has HelixSR active with Native DLSS disabled
- **THEN** the system SHALL write `UPSCALER_TYPE=3` to `bgmod.conf`
- **AND** deploy `OptiScaler.dll`, `fakenvapi.dll`, and `HelixSR/` containing `amd_fidelityfx_dx12.dll` and `helixsr.ini` into the game directory.

#### Scenario: Experimental Native DLSS deployment
- **WHEN** the game profile has HelixSR active with Native DLSS enabled
- **THEN** the system SHALL write `UPSCALER_TYPE=3` and `HELIXSR_NATIVE_DLSS=1` to `bgmod.conf`
- **AND** deploy `dlss-loader/dxgi.dll` and `nvngx.dll` into the game directory
- **AND** display an advisory notice warning against online multiplayer use with anti-cheat.
