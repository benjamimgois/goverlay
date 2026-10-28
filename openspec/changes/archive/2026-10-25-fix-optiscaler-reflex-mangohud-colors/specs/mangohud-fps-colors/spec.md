# Spec Delta

## ADDED Requirements

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
