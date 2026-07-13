## ADDED Requirements

### Requirement: Toggle and Default State on Bleeding-edge Channel
When GOverlay is configured to use the OptiScaler bleeding-edge update channel, GOverlay SHALL hide the "Emulate FP8" checkbox, display the "Force FSR4-i8" checkbox in its place, and default the "Force FSR4-i8" checkbox to the checked state.

#### Scenario: Switching to Bleeding-edge Channel
- **WHEN** the user selects the "Bleeding-edge" option in the OptiScaler update channel dropdown
- **THEN** the "Emulate FP8" checkbox is hidden and unchecked, and the "Force FSR4-i8" checkbox is displayed and checked by default.

### Requirement: Hide Force FSR4-i8 on Stable Channel
When GOverlay is configured to use the OptiScaler stable update channel, GOverlay SHALL hide the "Force FSR4-i8" checkbox, and restore the visibility and default behavior of the "Emulate FP8" checkbox.

#### Scenario: Switching to Stable Channel
- **WHEN** the user selects the "Stable Channel" option in the OptiScaler update channel dropdown
- **THEN** the "Force FSR4-i8" checkbox is hidden, and the "Emulate FP8" checkbox is displayed.

### Requirement: Configuration Persistence in OptiScaler.ini
GOverlay SHALL save and load the state of the "Force FSR4-i8" checkbox to/from the `OptiScaler.ini` file using the key prefix `Fsr4ForceEnableInt8=`. When saved, it SHALL write `Fsr4ForceEnableInt8=true` if checked, and `Fsr4ForceEnableInt8=false` if unchecked. When loaded, it SHALL load the saved state or default to checked if the key is absent.

#### Scenario: Saving Checked Force FSR4-i8 Configuration
- **WHEN** the user saves the configuration with the "Force FSR4-i8" checkbox checked
- **THEN** GOverlay writes `Fsr4ForceEnableInt8=true` to the `OptiScaler.ini` file.

#### Scenario: Saving Unchecked Force FSR4-i8 Configuration
- **WHEN** the user saves the configuration with the "Force FSR4-i8" checkbox unchecked
- **THEN** GOverlay writes `Fsr4ForceEnableInt8=false` to the `OptiScaler.ini` file.

#### Scenario: Loading Configuration with Force FSR4-i8 Absent
- **WHEN** GOverlay loads an OptiScaler configuration where `Fsr4ForceEnableInt8=` is absent in the `OptiScaler.ini` file
- **THEN** the "Force FSR4-i8" checkbox is checked by default.
