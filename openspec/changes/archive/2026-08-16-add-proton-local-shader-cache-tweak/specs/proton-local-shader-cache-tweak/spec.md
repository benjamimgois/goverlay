## Purpose

Provides a toggle in the Performance category of the EnvVars tab to enable per-game shader caching via `PROTON_LOCAL_SHADER_CACHE=1` for proton-cachyos.

## ADDED Requirements

### Requirement: PROTON_LOCAL_SHADER_CACHE Environment Variable Tweak
The system SHALL provide a toggle for `PROTON_LOCAL_SHADER_CACHE=1` in the 'Performance' section of the EnvVars tab.

#### Scenario: Display PROTON_LOCAL_SHADER_CACHE tweak row
- **WHEN** the user navigates to the EnvVars tab
- **THEN** a tweak row for `PROTON_LOCAL_SHADER_CACHE=1` SHALL be displayed under the 'Performance' section
- **AND** the description SHALL read `"[proton-cachyos] Enable per-game shader cache"`
- **AND** the `[proton-cachyos]` prefix SHALL be rendered in purple color

#### Scenario: Toggle PROTON_LOCAL_SHADER_CACHE state
- **WHEN** the user toggles the switch for `PROTON_LOCAL_SHADER_CACHE=1`
- **THEN** the state SHALL persist in GOverlay settings and export `PROTON_LOCAL_SHADER_CACHE=1` to the `[Env]` section of `bgmod.conf` when enabled

#### Scenario: Tooltip on hover
- **WHEN** the user hovers over the `PROTON_LOCAL_SHADER_CACHE=1` row
- **THEN** the tooltip SHALL display `"Works only with proton-cachyos"`
