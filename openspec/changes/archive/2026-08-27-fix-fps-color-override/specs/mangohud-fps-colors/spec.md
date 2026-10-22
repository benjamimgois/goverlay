## Purpose

Defines and persists MangoHud FPS color thresholds (`fps_value`) independently from the FPS limiter (`fps_limit`), ensuring user-customized breakpoint values are preserved on save and reload.

## ADDED Requirements

### Requirement: Preserve User Defined FPS Color Thresholds
The system SHALL preserve user-defined FPS color breakpoint values when saving configuration, without overwriting or recalculating them based on the FPS limiter settings.

#### Scenario: User saves custom color threshold values
- **WHEN** the user modifies the FPS color breakpoint inputs (e.g. median breakpoint to 45, high breakpoint to 90) and saves the configuration
- **THEN** the system SHALL write `fps_value=45,90` to the MangoHud configuration file and SHALL NOT reset the breakpoint inputs back to default or derived limits

#### Scenario: User saves configuration with active FPS limiter
- **WHEN** the user sets an FPS limit (e.g. `120`) and custom color breakpoints (e.g. `45` and `90`) and saves the configuration
- **THEN** the system SHALL save `fps_limit=120` and `fps_value=45,90` without modifying the user's custom color breakpoints

### Requirement: Load and Default FPS Color Thresholds
The system SHALL load existing `fps_value` parameters from the configuration file into the color breakpoint inputs, and provide default values of 30 (median) and 60 (high) only when no valid `fps_value` directive is present or when resetting to defaults.

#### Scenario: Loading configuration containing fps_value
- **WHEN** the system loads a MangoHud configuration containing `fps_value=50,100`
- **THEN** the median breakpoint input SHALL display 50 and the high breakpoint input SHALL display 100

#### Scenario: Resetting configuration or loading without fps_value
- **WHEN** the configuration is reset to defaults or loaded without an `fps_value` key
- **THEN** the median breakpoint input SHALL default to 30 and the high breakpoint input SHALL default to 60
