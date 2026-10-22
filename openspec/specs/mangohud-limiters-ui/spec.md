# mangohud-limiters-ui Specification

## Purpose
Defines the presentation, layout geometry, and responsive organization of the MangoHud FPS Limiter controls and color threshold ruler in the Goverlay Performance tab.

## Requirements

### Requirement: Horizontal MangoHud FPS Limiter Layout
The system SHALL present the MangoHud FPS limit input, method selector, and limit toggle key button horizontally aligned within the top row of the Limiters card section.

#### Scenario: Displaying FPS limit controls in a unified row
- **WHEN** the user navigates to the Performance tab in Goverlay
- **THEN** the FPS limit title and input field, method selector, and toggle key button SHALL be rendered side-by-side in a horizontal row, with an explanatory hint label centered beneath them

### Requirement: Continuous Segmented Color Ruler with Aligned Breakpoint Controls
The system SHALL display the MangoHud FPS color thresholds as a continuous, three-segment horizontal color bar and position the threshold breakpoint spin edit controls centered directly beneath the division boundaries between adjacent color segments.

#### Scenario: Visual alignment of color breakpoint controls
- **WHEN** the FPS color change feature is enabled in the Limiters section
- **THEN** the low, mid, and high color blocks SHALL form a connected segmented bar, the median breakpoint control SHALL align with the boundary between the low and mid color segments, and the high breakpoint control SHALL align with the boundary between the mid and high color segments
