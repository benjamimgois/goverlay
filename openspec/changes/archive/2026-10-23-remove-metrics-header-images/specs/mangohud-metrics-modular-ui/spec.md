# mangohud-metrics-modular-ui Delta Specification

## MODIFIED Requirements

### Requirement: HUD Chip Header Integration
The system SHALL present custom hardware name inputs and line color indicators as unified, styled HUD Chip pills inside the GPU Metrics and CPU / Memory Metrics card headers without legacy asymmetrical illustrations.

#### Scenario: GPU HUD Chip layout and hint
- **WHEN** the user inspects the GPU Metrics card header
- **THEN** the system SHALL display a unified chip containing the line color button on the left, the name input in the middle with placeholder 'Default (GPU)', and a 'HUD' tag on the right

#### Scenario: CPU HUD Chip layout and hint
- **WHEN** the user inspects the CPU / Memory Metrics card header
- **THEN** the system SHALL display a unified chip containing the line color button on the left, the name input in the middle with placeholder 'Default (CPU)', and a 'HUD' tag on the right

#### Scenario: Responsive alignment in card header
- **WHEN** the Metrics tab content area is resized
- **THEN** each HUD Chip SHALL maintain its horizontal position centered beside the card title without overlapping
