## MODIFIED Requirements

### Requirement: Main Section Control Placement
The system SHALL place the `File name` combobox, `Scale` trackbar with resolution markers (1080p, 1440p, 4K), `OptiPatcher` checkbox, `Optiscaler toggle` shortcut capture button, and conditional `DLSS-Enabler toggle` button within the "Main" sub-section.

#### Scenario: Interacting with Main sub-section controls
- **WHEN** the user views the Main sub-section
- **THEN** the shortcut key label displays "Optiscaler toggle" above the OptiScaler shortcut capture button.

#### Scenario: Rendering DLSS Enabler toggle shortcut
- **WHEN** DLSS Enabler is selected (`dlssenablerRadioButton.Checked = True`)
- **THEN** the system displays the "DLSS-Enabler toggle" label and a disabled button pre-mapped to `⌨ ` `.

#### Scenario: Hiding DLSS Enabler toggle shortcut when OptiScaler is active
- **WHEN** OptiScaler is selected (`optiscalerRadioButton.Checked = True`)
- **THEN** the system SHALL hide the "DLSS-Enabler toggle" label and its disabled key button.
