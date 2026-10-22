# Spec Delta

## MODIFIED Requirements

### Requirement: Startup Verification and Download of HelixSR
The system SHALL verify the presence of the HelixSR runtime package in the central data directory during application initialization. If the runtime directory is missing or lacks `amd_fidelityfx_dx12.dll` and `helixsr-setup.sh`, the system SHALL automatically download and unpack the latest verified HelixSR release archive without executing shader compilation during the startup sequence. Companion OptiScaler files (`optiscaler/OptiScaler.dll`, `fakenvapi.dll`, `fakenvapi.ini`) SHALL be synchronized from the central stable OptiScaler cache (`optiscaler-stable`) if they are not bundled in the upstream HelixSR archive. If `amd_fidelityfx_dx12.dll` contains compiled neural compute shaders, the system SHALL preserve the compiled runtime and prevent re-download overwrites.

#### Scenario: Missing HelixSR assets at startup
- **WHEN** GOverlay launches and checks mandatory runtime libraries
- **AND** `~/.local/share/goverlay/optiscaler-helixsr/` is missing or lacks `amd_fidelityfx_dx12.dll`
- **THEN** the system SHALL download the HelixSR release archive, unpack it to `optiscaler-helixsr/`, synchronize companion OptiScaler binaries from `optiscaler-stable`, and proceed to the main interface without initiating shader compilation.

#### Scenario: HelixSR assets already present at startup
- **WHEN** GOverlay launches and verifies mandatory runtime libraries
- **AND** `optiscaler-helixsr/` already contains `amd_fidelityfx_dx12.dll` and `helixsr-setup.sh`
- **THEN** the startup check SHALL succeed immediately without downloading duplicate archives.

#### Scenario: Compiled HelixSR runtime preserved
- **WHEN** `amd_fidelityfx_dx12.dll` in `optiscaler-helixsr/` carries the compiled network marker (`HXSRNET1`)
- **THEN** the startup verification SHALL treat the runtime as fully satisfied and SHALL NOT trigger a re-download of the base release archive.
