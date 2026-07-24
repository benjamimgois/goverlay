## ADDED Requirements

### Requirement: PROTON_VKD3D_LOWLATENCY environment variable tweak
The system SHALL provide a toggle for `PROTON_VKD3D_LOWLATENCY=1` in the 'Latency reduction' section of the EnvVars tab.

#### Scenario: Display PROTON_VKD3D_LOWLATENCY tweak row
- **WHEN** the EnvVars tab is opened
- **THEN** a tweak row for `PROTON_VKD3D_LOWLATENCY=1` SHALL be displayed under the 'Latency reduction' section
- **THEN** the description SHALL read `"[proton-cachyos] low-latency frame pacing capabilities"`

#### Scenario: Toggle PROTON_VKD3D_LOWLATENCY state
- **WHEN** the user toggles the switch for `PROTON_VKD3D_LOWLATENCY=1`
- **THEN** the state SHALL persist in GOverlay settings and export `PROTON_VKD3D_LOWLATENCY=1` to the environment configuration when enabled
