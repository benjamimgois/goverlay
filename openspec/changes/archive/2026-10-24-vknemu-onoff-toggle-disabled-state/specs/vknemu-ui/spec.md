# vkNemu UI Specification

## ADDED Requirements

### Requirement: Explicit ON/OFF Pill Toggle for vkNemu
The Idle Limiter card shall use the sidebar-style ON/OFF pill button (`TSpeedButton` with `globalbuttonImageList`) positioned in the section header.

#### Scenario: User toggles vkNemu state
- GIVEN the application is running and the Performance tab is active
- WHEN the user clicks `FVkNemuToggleBtn`
- THEN `FVkNemuCheckBox.Checked` toggles between True and False
- AND `FVkNemuToggleBtn.ImageIndex` updates to 1 (green `ON`) when enabled and 0 (gray `OFF`) when disabled.

### Requirement: Visual Dimming when vkNemu is Disabled
When vkNemu is disabled, all child controls, labels, and the flow card inside `FVkNemuSec` shall be visually dormant and disabled.

#### Scenario: vkNemu is in disabled state
- GIVEN vkNemu is disabled
- THEN `FVkNemuIdleFpsSpin`, `FVkNemuTimeoutSpin`, `FVkNemuInputCombo`, `FVkNemuDelaySpin`, and `FVkNemuUnfocusedToggle` are disabled
- AND all control labels display in dimmed muted text color
- AND `FVkNemuFlowCard` renders with dimmed background and muted text and arrow colors.
