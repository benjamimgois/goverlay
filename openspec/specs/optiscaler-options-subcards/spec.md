# OptiScaler Options Sub-Cards Capability

## Requirements

### Requirement: Four Independent Options Sub-Cards
The system SHALL display the OptiScaler options panel as 4 independent sub-cards ("Main", "Spatial Upscaler", "Temporal Upscaler", and "Reflex / Antilag") of equal width inside the "Options" card.

#### Scenario: Displaying the OptiScaler options card
- **WHEN** the user views the OptiScaler tab
- **THEN** 4 distinct sub-card boxes with subtle borders and individual headers are rendered side by side across the Options card

### Requirement: Control Organization Across Sub-Cards
The system SHALL group controls into their corresponding sub-card panel:
- "Main": File name selection, Menu scale, OptiPatcher toggle, and Shortcut toggle key.
- "Spatial Upscaler": Preferred upscaler selection, Spoof DLSS toggle, and Force FSR4-i8 toggle.
- "Temporal Upscaler": FG Input selection, FG Output selection, and Force MLFG toggle.
- "Reflex / Antilag": Force Reflex toggle & mode, and Force LatencyFlex toggle & mode.

#### Scenario: Interacting with controls in independent sub-cards
- **WHEN** the user modifies settings in any of the 4 sub-cards
- **THEN** settings update and persist correctly without layout clipping or misalignment
