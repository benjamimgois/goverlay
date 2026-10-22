# Spec Delta: envvars-tab-card-redesign

## MODIFIED Requirements

### Requirement: Card-Based Grouped Layout for EnvVars
The EnvVars tab SHALL organize environment variables and tweaks into distinct themed cards (`General`, `Graphics`, `Performance`, `Latency reduction`, and `Custom Variables`) using standard GOverlay card background and border styling. All category cards SHALL span across nearly the entire horizontal client width with a 4px margin on both sides (`Left = 4`, `Right = ClientWidth - 4`), matching the standard geometry of Lossless Scaling.

#### Scenario: Viewing EnvVars tab categories
- **WHEN** the user navigates to the EnvVars tab
- **THEN** the settings are displayed within structured dark cards with clear category headers, spanning from `Left = 4` to `Right = ClientWidth - 4` with uniform 4px side margins.

#### Scenario: Resizing window with EnvVars tab active
- **WHEN** the user resizes the application window
- **THEN** the EnvVars category cards and their two-column item layouts dynamically adapt to fill the available width while maintaining the 4px side margins.
