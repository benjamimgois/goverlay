## MODIFIED Requirements

### Requirement: MangoHud UI control redefinition before load
The system SHALL reset all MangoHud-specific UI controls on the main form (checkboxes, comboboxes, trackbars, radio buttons, color buttons, spin edits, active preset card selection indices `FActiveLayoutCard` and `FActiveColorCard`, etc.) to their default values before loading any MangoHud configuration from file, and SHALL refresh preset card selection visuals after loading. The default background transparency trackbar position SHALL be 6 (`background_alpha=0.6`).

#### Scenario: Loading MangoHud configuration file
- **WHEN** the system loads a MangoHud configuration file
- **THEN** it first resets all MangoHud UI controls and preset selection card indices (`FActiveLayoutCard`, `FActiveColorCard`) to their default unselected values (`-1`)
- **AND** it sets `transpTrackBar.Position` to `6` and `alphavalueLabel.Caption` to `'0.6'`
- **AND** it updates controls and refreshes preset card visual highlighting based on the loaded configuration
