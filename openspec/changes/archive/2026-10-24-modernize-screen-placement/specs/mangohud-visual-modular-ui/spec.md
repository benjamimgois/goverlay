# Spec Delta: mangohud-visual-modular-ui

## MODIFIED Requirements

### Requirement: Uncluttered Screen Placement and Offset Controls
The system SHALL isolate fine-tuning coordinate offsets from the visual monitor graphic, rendering interactive anchor buttons on the monitor surface while positioning X and Y offset inputs in dedicated labeled fields cleanly below the monitor.

#### Scenario: Monitor grid anchor selection
- **WHEN** the user clicks any of the 8 anchor points on the modern vector monitor (Top-Left, Top-Center, Top-Right, Middle-Left, Middle-Right, Bottom-Left, Bottom-Center, Bottom-Right)
- **THEN** the system SHALL update the active overlay anchor position, highlight the selected anchor point, render the live mini-HUD preview chip at that anchor, and trigger auto-saving

#### Scenario: Dedicated offset coordinate inputs
- **WHEN** the user configures fine-tuning offsets
- **THEN** the system SHALL accept pixel values via dedicated, labeled offset controls located outside the monitor boundary without obstructing the anchor buttons
