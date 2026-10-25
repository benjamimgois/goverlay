# mangohud-limiters-ui Specification

## Purpose
Defines the presentation, layout geometry, and responsive organization of the MangoHud FPS Limiter controls and color threshold ruler in the Goverlay Performance tab.

## Requirements

### Requirement: Horizontal MangoHud FPS Limiter Layout
The system SHALL present the MangoHud FPS limit controls in the primary Rate Control sub-card at the top of the Performance tab, featuring quick-preset chips (such as 60, 120, 144, and Off) above or alongside the freeform comma-separated input field, paired with the method selector and limit toggle key button.

#### Scenario: Displaying FPS limit controls in a unified row
- **WHEN** the user navigates to the Performance tab in Goverlay
- **THEN** the FPS limit title, preset chips, input field, method selector, and toggle key button SHALL be rendered within the primary Rate Control sub-card at the top of the tab

#### Scenario: Clicking a quick-preset chip
- **WHEN** the user clicks a quick-preset chip (e.g. '60' or '120')
- **THEN** the system SHALL append or set the corresponding numeric limit in the FPS limit input field

### Requirement: Continuous Segmented Color Ruler with Aligned Breakpoint Controls
The system SHALL display the MangoHud FPS color thresholds as an inline horizontal gradient bar with interactive color swatches and integrated threshold breakpoint spin edit controls.

#### Scenario: Visual alignment of color breakpoint controls
- **WHEN** the FPS color change feature is enabled in the Limiters section
- **THEN** the low, mid, and high color swatches SHALL be rendered in a cohesive horizontal flow alongside their respective threshold cutoff inputs
