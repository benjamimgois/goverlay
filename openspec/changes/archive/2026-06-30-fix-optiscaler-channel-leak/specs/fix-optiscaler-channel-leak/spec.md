## ADDED Requirements

### Requirement: Default OptiScaler channel to Stable on load
When GOverlay loads the configuration for a game or global settings, if the configuration does not contain a saved `OPT_CHANNEL` index (or if it is invalid/not set), GOverlay SHALL default the update channel combobox selection to index `0` ("Stable Channel").

#### Scenario: Loading new or unedited game configuration
- **WHEN** user selects a game config that has no saved `OPT_CHANNEL` setting
- **THEN** GOverlay selects index 0 ("Stable Channel") in `optversionComboBox` instead of leaking the previously loaded game's selection.

#### Scenario: Loading new or unedited global configuration
- **WHEN** user switches back to global configuration and it has no saved `OPT_CHANNEL` setting
- **THEN** GOverlay selects index 0 ("Stable Channel") in `optversionComboBox`.
