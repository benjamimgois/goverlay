# mangohud-fps-colors Specification

## Purpose
Defines and persists MangoHud FPS color thresholds (`fps_value`) independently from the FPS limiter (`fps_limit`), ensuring user-customized breakpoint values are preserved on save and reload.

## Requirements

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

### Requirement: Robust MangoHud Color Value Parsing
The system SHALL safely parse MangoHud hex color strings containing optional `#` prefixes or whitespace without throwing conversion exceptions, falling back to a default color if parsing fails.

#### Scenario: Loading hex color with hash prefix
- **WHEN** a MangoHud configuration contains a color directive with a `#` prefix (e.g. `fps_color=#00FF00` or `text_color=#FFFFFF`)
- **THEN** the system SHALL parse the color successfully and assign it to the corresponding UI color control

#### Scenario: Loading malformed hex color string
- **WHEN** a MangoHud configuration contains an invalid or truncated hex color string
- **THEN** the system SHALL fallback to the default color without raising an unhandled exception

### Requirement: Isolated MangoHud Key Loading Errors
The system SHALL isolate parsing errors on individual configuration keys during MangoHud configuration load, ensuring that an error in one key does not abort loading subsequent settings.

#### Scenario: Encountering error during file loading
- **WHEN** a MangoHud configuration file contains a malformed line or invalid key value followed by valid settings
- **THEN** the system SHALL log or catch the error for that line and continue loading the remaining directives
