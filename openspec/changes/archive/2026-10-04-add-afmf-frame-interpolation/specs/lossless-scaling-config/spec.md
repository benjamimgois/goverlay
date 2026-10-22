# Spec Delta

## MODIFIED Requirements

### Requirement: Multi-Engine Interpolation Method Selection
The system SHALL provide a Method selector allowing the user to select between "None", "lsfg-vk", "MAKO", and "AFMF" engines via radio buttons and adjacent clickable rectangular banner images, persisting the selection in `bgmod.conf`. The "lsfg-vk", "MAKO", and "AFMF" methods SHALL use self-contained rectangular banner images integrating squircle rounded icons with uniform white bold typography. The active method logo SHALL display at 100% full brightness, and unselected method logos SHALL display visibly dimmed to approximately 35% RGB brightness with preserved alpha transparency without separate text labels. The containing tab and all UI references SHALL be titled "Frame Interpolation".

#### Scenario: User selects None method
- **WHEN** user selects the "None" method
- **THEN** system sets `GOVERLAY_LOSSLESS=0`, sets `INTERPOLATION_METHOD=none` in `bgmod.conf`, displays the None logo at 100% full brightness, dims the "lsfg-vk", "MAKO", and "AFMF" banner images to approximately 35% brightness, and disables frame generation injection flags.

#### Scenario: User selects lsfg-vk method
- **WHEN** user selects the "lsfg-vk" method via its radio button or its rectangular banner image
- **THEN** system sets `GOVERLAY_LOSSLESS=1`, sets `INTERPOLATION_METHOD=lsfg` in `bgmod.conf`, displays the "lsfg-vk" banner at 100% full brightness while dimming the None, MAKO, and AFMF images to approximately 35% brightness, and switches the middle UI to the streamlined lsfg-vk controls.

#### Scenario: User selects MAKO method
- **WHEN** user selects the "MAKO" method via its radio button or its rectangular banner image
- **THEN** system sets `GOVERLAY_LOSSLESS=1`, sets `INTERPOLATION_METHOD=mako` in `bgmod.conf`, displays the "MAKO" banner at 100% full brightness while dimming the None, lsfg-vk, and AFMF images to approximately 35% brightness, and displays the full MAKO configuration suite.

#### Scenario: User selects AFMF method
- **WHEN** user selects the "AFMF" method via its radio button or its rectangular banner image
- **THEN** system sets `GOVERLAY_LOSSLESS=1`, sets `INTERPOLATION_METHOD=afmf` in `bgmod.conf`, displays the "AFMF" banner at 100% full brightness while dimming the None, lsfg-vk, and MAKO images to approximately 35% brightness, and switches the configuration cards to the AFMF parameter suite.

### Requirement: Dynamic Configuration Card Adaptability
The system SHALL dynamically update visible controls and card states based on the selected method and ensure tuning controls remain enabled at all multiplier values, only disabling controls when "None" is selected or when the Upscalers tool is toggled off. When "MAKO" is active in standard mode, the frame generation toggles (Performance Mode, Ultra Performance, Allow FP16, and Live FG Switch) SHALL be aligned on a single horizontal row across 4 columns, the Software Status card SHALL be anchored to the bottom of the viewport, and middle configuration cards SHALL dynamically adjust their heights to consume available vertical space when the window is resized. When "AFMF" is active, Steam DLL and Mako engine cards SHALL be hidden, and AFMF-specific tuning cards (Performance/Search Mode, Cadence/Pacing, Optimizations/Gamescope, and Diagnostics) SHALL be displayed.

#### Scenario: Adapting UI for lsfg-vk
- **WHEN** "lsfg-vk" is active
- **THEN** system presents the Multiplier trackbar (1x bypass to 4x+), Flow Scale trackbar (25% to 100%), Performance Mode toggle, Allow FP16 toggle, Pacing Mode dropdown, and present quirks (Override Present Mode and Preserve Swapchain Image Count) as fully enabled and interactive regardless of the active multiplier value, while hiding HDR Mode, the Spatial Scaling card, and AFMF cards.

#### Scenario: Adapting UI for MAKO
- **WHEN** "MAKO" is active
- **THEN** system presents the Frame Generation card with Fixed/Adaptive modes, Target FPS slider, Max Multiplier, and live toggles as fully enabled and interactive regardless of the active multiplier value
- **AND** aligns `FLsPerfModeToggle`, `FLsUltraPerfToggle`, `FLsAllowFp16Toggle`, and `FLsFgLiveToggle` horizontally on a single row in 4-column layout when in standard mode
- **AND** anchors the Software Status card to the bottom of the viewport and dynamically scales card heights on window resize to avoid empty voids.

#### Scenario: Adapting UI for AFMF
- **WHEN** "AFMF" is active
- **THEN** system hides the Multiplier trackbars, Adaptive controls, Steam DLL path edit, and Spatial Scaling cards
- **AND** displays the AFMF Performance/Search mode card, Pacing/Cadence card, Optimizations card, and Vulkan layer status in the status card.

#### Scenario: Multiplier set to 1x remains interactive
- **WHEN** user moves the multiplier slider to 1x under "lsfg-vk" or "MAKO"
- **THEN** the multiplier slider and all tuning controls remain enabled and interactive, allowing immediate adjustment without becoming disabled.

#### Scenario: Adapting UI for None
- **WHEN** "None" is active
- **THEN** system disables interpolation tuning controls, keeps method selection radio buttons enabled, and displays an informative message stating that interpolation is currently disabled.

#### Scenario: Disabling Upscalers tool from sidebar
- **WHEN** user toggles off the "Upscalers" tool in the sidebar navigation
- **THEN** system disables all controls on the Frame Interpolation tab.

## ADDED Requirements

### Requirement: Frame Interpolation and OptiScaler Conflict Guard
The system SHALL prevent concurrent activation of AFMF frame interpolation and OptiScaler / DLSS Enabler upscalers for any game or global profile, presenting a confirmation dialog to resolve conflicts by disabling the conflicting tool.

#### Scenario: User selects AFMF while OptiScaler is active
- **WHEN** user selects AFMF as the interpolation method while OptiScaler or DLSS Enabler is enabled for the active profile
- **THEN** system displays a confirmation dialog stating that AFMF is incompatible with OptiScaler / DLSS Enabler
- **AND** upon user confirmation, disables OptiScaler (setting its upscaler type to None) and activates AFMF
- **AND** upon user cancellation, restores the previously selected interpolation method.

#### Scenario: User activates OptiScaler while AFMF is active
- **WHEN** user selects OptiScaler or DLSS Enabler while AFMF is the active interpolation method
- **THEN** system displays a confirmation dialog stating that activating OptiScaler will disable AFMF frame interpolation
- **AND** upon user confirmation, sets the interpolation method to None and activates OptiScaler
- **AND** upon user cancellation, restores OptiScaler selection to None.
