## Purpose

Manages the generation, persistence, and synchronization of `lsfg.toml` configuration files for Lossless Scaling (`lsfg-vk`), ensuring `pascube` preview profiles and game executables are always properly configured.

## ADDED Requirements

### Requirement: Lossless Scaling configuration file contains pascube and vkcube preview profiles
The system SHALL generate `lsfg.toml` containing explicit `[[game]]` entries for both `pascube` and `vkcube` using the active multiplier, flow scale, performance mode, HDR mode, and pacing options whenever Lossless Scaling is configured.

#### Scenario: Saving Lossless Scaling configuration
- **WHEN** user configures Lossless Scaling settings with a valid DLL path and active multiplier
- **THEN** system writes `lsfg.toml` containing dedicated `[[game]]` blocks for `pascube` and `vkcube` with matching frame generation parameters

### Requirement: Open configuration file synchronizes active settings before launching editor
The system SHALL ensure `lsfg.toml` is synchronized with the current GUI state and contains `pascube` and `vkcube` definitions before opening the file in the default desktop editor.

#### Scenario: User clicks Open config file from Lossless Scaling tab
- **WHEN** user selects "Open config file" from the hamburger menu while viewing the Lossless Scaling tab
- **THEN** system writes or updates `lsfg.toml` with current settings including `pascube` and `vkcube` blocks before launching `xdg-open`

### Requirement: Default template initialization includes pascube entry
The system SHALL ensure any default or bundled `lsfg.toml` template used for initialization includes `pascube` as an entry.

#### Scenario: Initializing game configuration directory
- **WHEN** global configuration is initialized
- **THEN** `lsfg.toml` contains `pascube` as a defined entry alongside standard demo entries
