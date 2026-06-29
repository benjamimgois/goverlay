# Capability: optiscaler-fsr-version-ui-clean

Updates OptiScaler FSR version option label to "Latest" and hides the Emulate FP8 checkbox.

## Requirements

### Requirement: Update FSR version combobox options
GOverlay SHALL display "Latest" instead of "Latest (FP8)" as the first option in the OptiScaler FSR version combobox (`fsrversionComboBox`).

#### Scenario: User opens OptiScaler tab FSR version dropdown
- **WHEN** user opens the FSR version dropdown in the OptiScaler tab
- **THEN** GOverlay displays the options "Latest" and "4.0.2c (INT8)".

### Requirement: Hide Emulate FP8 checkbox
GOverlay SHALL hide the "Emulate FP8" checkbox (`emufp8CheckBox`) from the OptiScaler tab user interface.

#### Scenario: User views OptiScaler tab
- **WHEN** user views the OptiScaler tab
- **THEN** the "Emulate FP8" checkbox is not visible in the interface.

### Requirement: Maintain backwards compatibility for configuration files
GOverlay SHALL parse both "Latest" and "Latest (FP8)" strings when loading OptiScaler configuration files.

#### Scenario: Loading legacy configuration file
- **WHEN** GOverlay loads an OptiScaler configuration file containing `fsrversion=Latest (FP8)` or `fsrversion=Latest`
- **THEN** GOverlay selects index 0 ("Latest") in `fsrversionComboBox`.
