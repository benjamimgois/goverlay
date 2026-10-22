# Spec Delta: helixsr-runtime-management

## MODIFIED Requirements

### Requirement: On-Demand Neural Shader Compilation
The system SHALL verify whether the HelixSR Direct3D 12 neural network compute shaders have been compiled whenever the user selects the HelixSR method. If the network is uncompiled, the system SHALL ensure pre-compilation cleanup of stale temporary prefixes, select and validate a working Wine or Proton compatibility tool with fallback support, and display a compilation modal with live step-by-step progress tracking weights extraction, HLSL generation, and DXC shader compilation before finalizing method activation.

#### Scenario: First activation with uncompiled shaders
- **WHEN** the user selects the HelixSR method
- **AND** `amd_fidelityfx_dx12.dll` in `optiscaler-helixsr/` lacks the compiled network marker (`HXSRNET1`)
- **THEN** the system SHALL remove any existing temporary prefix directory at `~/.local/share/HelixSR/wineprefix` prior to starting execution
- **AND** open a compilation dialog displaying stage progress
- **AND** execute the compilation script using a validated Wine or Proton runtime with fallback capability
- **AND** mark the HelixSR method as active with a success notification once compilation finishes.

#### Scenario: Subsequent activation with already compiled shaders
- **WHEN** the user selects the HelixSR method
- **AND** the compiled network marker (`HXSRNET1`) is present
- **THEN** the system SHALL immediately activate the HelixSR method without presenting the compilation dialog.

#### Scenario: Compilation failure handling
- **WHEN** shader compilation fails due to Wine runtime or shader compiler errors
- **THEN** the system SHALL present an informative error notification explaining that Wine or Proton runtime execution failed and advising verification of system Wine or compatible Proton versions.
