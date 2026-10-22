# Spec Delta: lossless-scaling-config

## MODIFIED Requirements

### Requirement: Dynamic Configuration Card Adaptability
The system SHALL dynamically update visible controls and card states based on the selected method and ensure tuning controls remain enabled at all multiplier values, only disabling controls when "None" is selected or when the Upscalers tool is toggled off. When "MAKO" is active in standard mode, the frame generation toggles (Performance Mode, Ultra Performance, Allow FP16, and Live FG Switch) SHALL be aligned on a single horizontal row across 4 columns to optimize vertical space and avoid vertical scrolling.

#### Scenario: Adapting UI for lsfg-vk
- **WHEN** "lsfg-vk" is active
- **THEN** system presents the Multiplier trackbar (1x bypass to 4x+), Flow Scale trackbar (25% to 100%), Performance Mode toggle, Allow FP16 toggle, Pacing Mode dropdown, and present quirks (Override Present Mode and Preserve Swapchain Image Count) as fully enabled and interactive regardless of the active multiplier value, while hiding HDR Mode and the Spatial Scaling card.

#### Scenario: Adapting UI for MAKO
- **WHEN** "MAKO" is active
- **THEN** system presents the Frame Generation card with Fixed/Adaptive modes, Target FPS slider, Max Multiplier, and live toggles as fully enabled and interactive regardless of the active multiplier value
- **AND** aligns `FLsPerfModeToggle`, `FLsUltraPerfToggle`, `FLsAllowFp16Toggle`, and `FLsFgLiveToggle` horizontally on a single row in 4-column layout when in standard mode
- **AND** reduces the Frame Generation card height to fit the entire tab content within standard window dimensions without activating vertical scrollbars.

#### Scenario: Multiplier set to 1x remains interactive
- **WHEN** user moves the multiplier slider to 1x under "lsfg-vk" or "MAKO"
- **THEN** the multiplier slider and all tuning controls remain enabled and interactive, allowing immediate adjustment without becoming disabled.

#### Scenario: Adapting UI for None
- **WHEN** "None" is active
- **THEN** system disables interpolation tuning controls, keeps method selection radio buttons enabled, and displays an informative message stating that interpolation is currently disabled.

#### Scenario: Disabling Upscalers tool from sidebar
- **WHEN** user toggles off the "Upscalers" tool in the sidebar navigation
- **THEN** system disables all controls on the Lossless Scaling tab.
