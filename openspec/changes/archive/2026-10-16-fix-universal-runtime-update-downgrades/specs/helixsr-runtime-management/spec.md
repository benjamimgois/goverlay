# Spec Delta

## MODIFIED Requirements

### Requirement: Startup Verification and Download of HelixSR
The system SHALL verify the presence of the HelixSR runtime package in the central data directory during application initialization. If missing or lacking `amd_fidelityfx_dx12.dll` and `helixsr-setup.sh`, the system SHALL discover the latest release using GitHub REST API and unthrottled Atom feed fallbacks, unpacking the archive without executing shader compilation at startup. Companion OptiScaler files SHALL be synchronized from `optiscaler-stable`. If compiled shaders are present, the system SHALL preserve the runtime and prevent re-download overwrites.

#### Scenario: Missing HelixSR assets at startup
- **WHEN** GOverlay launches and checks mandatory runtime libraries
- **AND** `~/.local/share/goverlay/optiscaler-helixsr/` is missing or lacks `amd_fidelityfx_dx12.dll`
- **THEN** the system SHALL resolve the latest release via GitHub API or unthrottled Atom feed, download the archive, unpack it to `optiscaler-helixsr/`, synchronize companion OptiScaler binaries from `optiscaler-stable`, and proceed to the main interface without initiating shader compilation.

#### Scenario: HelixSR assets already present at startup
- **WHEN** GOverlay launches and verifies mandatory runtime libraries
- **AND** `optiscaler-helixsr/` already contains `amd_fidelityfx_dx12.dll` and `helixsr-setup.sh`
- **THEN** the startup check SHALL succeed immediately without downloading duplicate archives.

#### Scenario: Compiled HelixSR runtime preserved
- **WHEN** `amd_fidelityfx_dx12.dll` in `optiscaler-helixsr/` carries the compiled network marker (`HXSRNET1`)
- **THEN** the startup verification SHALL treat the runtime as fully satisfied and SHALL NOT trigger a re-download of the base release archive.
