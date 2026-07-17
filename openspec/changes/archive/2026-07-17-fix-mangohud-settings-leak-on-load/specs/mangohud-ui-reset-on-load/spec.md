## ADDED Requirements

### Requirement: MangoHud UI control redefinition before load
The system SHALL reset all MangoHud-specific UI controls on the main form (checkboxes, comboboxes, trackbars, radio buttons, color buttons, spin edits, etc.) to their default values before loading any MangoHud configuration from file.

#### Scenario: Loading MangoHud configuration file
- **WHEN** the system loads a MangoHud configuration file
- **THEN** it first resets all MangoHud UI controls to their default values
- **AND** it then updates the controls based only on the keys present in the loaded configuration file
