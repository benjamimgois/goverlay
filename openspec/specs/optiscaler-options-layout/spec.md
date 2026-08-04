## Purpose

Defines the behavior and layout of the reorganized OptiScaler Options card featuring 3 internal sections ("Main", "Spatial Upscaler", "Temporal Upscaler") separated by vertical dividers, alongside the FakeNVAPI side-card.

## Requirements

### Requirement: OptiScaler Options Sub-Sections Layout
The system SHALL layout the OptiScaler options panel into 3 distinct vertical sub-sections titled "Main", "Spatial Upscaler", and "Temporal Upscaler", separated by subtle 1px vertical section dividers.

#### Scenario: Rendering OptiScaler options card
- **WHEN** the Upscalers tab is displayed with OptiScaler options
- **THEN** the OptiScaler sub-card renders 3 vertically separated columns containing "Main", "Spatial Upscaler", and "Temporal Upscaler" controls respectively

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

### Requirement: Spatial Upscaler Section Control Placement
The system SHALL place the `Preferred upscaler` combobox, `Spoof DLSS` checkbox, and `Force FSR4-i8` checkbox within the "Spatial Upscaler" sub-section.

#### Scenario: Configuring Spatial Upscaler settings
- **WHEN** the user selects a preferred spatial upscaler or toggles DLSS spoofing or FSR4-i8 forcing
- **THEN** the Spatial Upscaler settings update and save to the configuration file

### Requirement: Temporal Upscaler Section Control Placement
The system SHALL place the `FG Input` combobox, `FG Output` combobox, and `Emulate FP8` checkbox within the "Temporal Upscaler" sub-section.

#### Scenario: Configuring Temporal Upscaler settings
- **WHEN** the user adjusts Frame Generation Input/Output or FP8 emulation
- **THEN** the Temporal Upscaler settings update and save to the configuration file
