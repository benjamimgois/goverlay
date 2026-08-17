## Purpose

Provides a toggle in the General category of the EnvVars tab to enable Discord Rich Presence via `PROTON_DISCORD_BRIDGE=1` for proton-cachyos.

## ADDED Requirements

### Requirement: PROTON_DISCORD_BRIDGE Environment Variable Tweak
The system SHALL provide a toggle for `PROTON_DISCORD_BRIDGE=1` in the 'General' section of the EnvVars tab.

#### Scenario: Display PROTON_DISCORD_BRIDGE tweak row
- **WHEN** the user navigates to the EnvVars tab
- **THEN** a tweak row for `PROTON_DISCORD_BRIDGE=1` SHALL be displayed under the 'General' section
- **AND** the description SHALL read `"[proton-cachyos] Enable Discord's Rich Presence."`
- **AND** the `[proton-cachyos]` prefix SHALL be rendered in purple color

#### Scenario: Toggle PROTON_DISCORD_BRIDGE state
- **WHEN** the user toggles the switch for `PROTON_DISCORD_BRIDGE=1`
- **THEN** the state SHALL persist in GOverlay settings and export `PROTON_DISCORD_BRIDGE=1` to the `[Env]` section of `bgmod.conf` when enabled

#### Scenario: Tooltip on hover
- **WHEN** the user hovers over the `PROTON_DISCORD_BRIDGE=1` row
- **THEN** the tooltip SHALL display `"Works only with proton-cachyos"`
