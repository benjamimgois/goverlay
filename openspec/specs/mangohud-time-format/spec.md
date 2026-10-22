# mangohud-time-format Specification

## Purpose

Enables configuring and customizing MangoHud's time format string via an intuitive settings dialog with presets and live preview, persisting the format across sessions.

## Requirements

### Requirement: Time format configuration button and dialog
The system SHALL provide a settings button adjacent to the Time toggle in the Extras tab that opens a time format configuration dialog when clicked, enabled only when the Time toggle is active.

#### Scenario: Configuration button state tracks Time toggle
- **WHEN** user enables or disables the Time toggle in the Extras tab
- **THEN** the adjacent time format configuration button is enabled or disabled accordingly

#### Scenario: Opening configuration dialog
- **WHEN** user clicks the time format configuration button while Time is enabled
- **THEN** the modal dialog opens presenting the active format, available presets, and a live preview of the current local time

### Requirement: Time format presets and live preview
The system SHALL provide standard time format presets and permit arbitrary custom format strings conforming to std::put_time, displaying a live formatted preview of local time.

#### Scenario: Selecting a preset
- **WHEN** user selects a preset (e.g. 24h short %R or 12h AM/PM %I:%M %p)
- **THEN** the format string updates, the preview updates, and the format is applied immediately to the MangoHud configuration and live preview (PasCube) without requiring an Apply button

#### Scenario: Entering custom format string
- **WHEN** user enters a custom format string in the format input
- **THEN** the preview label updates in real-time with the local time formatted according to the input string

### Requirement: MangoHud time format persistence and serialization
The system SHALL persist the configured time format in settings and serialize `time_format=<format>` to the MangoHud configuration file when Time is enabled, restoring it upon load and resetting to `%T` on defaults.

#### Scenario: Serializing to configuration file
- **WHEN** user saves configuration with Time enabled and a custom format string
- **THEN** the generated MangoHud config file includes `time_format=<format>` alongside `time` and `time_no_label`

#### Scenario: Parsing from configuration file
- **WHEN** GOverlay loads a MangoHud config file containing `time_format=<format>`
- **THEN** GOverlay loads the format string and restores it in the time format settings

#### Scenario: Resetting to defaults
- **WHEN** user resets MangoHud settings to default
- **THEN** the time format is restored to `%T`
