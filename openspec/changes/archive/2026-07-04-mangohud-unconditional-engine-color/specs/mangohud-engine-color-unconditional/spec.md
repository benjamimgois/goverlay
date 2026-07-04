## ADDED Requirements

### Requirement: Always Write MangoHUD Engine Color
The system MUST always write the `engine_color` setting to the MangoHUD configuration file when saving the configuration, regardless of whether `engine_version` is enabled or disabled in the UI.

#### Scenario: Unconditional engine color saving
- **WHEN** the MangoHUD configuration is saved
- **THEN** the output configuration file MUST contain a line specifying `engine_color` matching the currently set engine color setting
