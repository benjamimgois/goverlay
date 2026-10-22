## ADDED Requirements

### Requirement: Multi-Engine Interpolation Method Selection
The system SHALL provide a Method selector allowing the user to select between "None", "lsfg-vk", and "MAKO" engines via radio buttons and clickable logos, persisting the selection in `bgmod.conf`.

#### Scenario: User selects None method
- **WHEN** user selects the "None" method
- **THEN** system sets `GOVERLAY_LOSSLESS=0`, adjusts the multiplier to 1x, updates the radio/logo opacity, and disables frame generation injection flags.

#### Scenario: User selects lsfg-vk method
- **WHEN** user selects the "lsfg-vk" method
- **THEN** system sets `GOVERLAY_LOSSLESS=1`, sets `INTERPOLATION_METHOD=lsfg` in `bgmod.conf`, highlights the Lossless Scaling logo, and switches the middle UI to the streamlined lsfg-vk controls from branch main.

#### Scenario: User selects MAKO method
- **WHEN** user selects the "MAKO" method
- **THEN** system sets `GOVERLAY_LOSSLESS=1`, sets `INTERPOLATION_METHOD=mako` in `bgmod.conf`, highlights the MAKO logo, and displays the full MAKO configuration suite (Fixed/Adaptive FG and Spatial Scaling).

### Requirement: Dynamic Configuration Card Adaptability
The system SHALL dynamically update visible controls and cards based on the selected method.

#### Scenario: Adapting UI for lsfg-vk
- **WHEN** "lsfg-vk" is active
- **THEN** system presents the classic Multiplier trackbar, Flow Scale trackbar, Performance Mode toggle, HDR Mode toggle, No FP16 toggle, and Pacing dropdown, while hiding the Spatial Scaling card.

#### Scenario: Adapting UI for MAKO
- **WHEN** "MAKO" is active
- **THEN** system presents the Frame Generation card with Fixed/Adaptive modes, Target FPS slider, Max Multiplier, live toggles, and renders the Spatial Scaling card with LS1/Bicubic/Lanczos options.

#### Scenario: Adapting UI for None
- **WHEN** "None" is active
- **THEN** system disables or hides interpolation tuning controls and displays an informative message stating that interpolation is currently disabled.

### Requirement: Unified Software Status Card
The system SHALL render a Software Status card anchored at the bottom of the Lossless Scaling tab, displaying status dots, component names, and detected versions/paths for Lossless.dll, MAKO engine, and lsfg-vk layer.

#### Scenario: Viewing software status
- **WHEN** user views the Lossless Scaling tab
- **THEN** system renders green or red status dots for Lossless.dll, the installed MAKO engine (`libmako-render.so`), and the lsfg-vk Vulkan layer, displaying the path for Lossless.dll with a Browse button and the installed version for MAKO.

## MODIFIED Requirements

### Requirement: MAKO Launch Environment and Layer Isolation
The system SHALL configure the execution environment with `ENABLE_MAKO=1`, `MAKO_CONFIG`, `MAKO_DISABLE_HDR_EXPOSURE=1`, `DISABLE_GAMESCOPE_WSI=1`, and explicit suppression of legacy LSFG layers (`DISABLE_LSFG=1`, `DISABLE_LSFGVK=1`) when launching games or preview binaries with the MAKO interpolation method enabled, while configuring `LSFG_CONFIG` for `lsfg-vk`, and omitting injection flags when "None" is selected.

#### Scenario: Launching a game with Lossless Scaling enabled
- **WHEN** a game is launched with GOverlay Lossless Scaling enabled and method set to MAKO
- **THEN** the launch command exports `ENABLE_MAKO=1`, points `MAKO_CONFIG` to the game's `conf.toml`, sets `DISABLE_GAMESCOPE_WSI=1`, and suppresses legacy LSFG environment variables.

#### Scenario: Launching a game with lsfg-vk enabled
- **WHEN** a game is launched with GOverlay Lossless Scaling enabled and method set to lsfg-vk
- **THEN** the launch command exports `LSFG_CONFIG` pointing to `lsfg.toml` and does not export `ENABLE_MAKO` or disable LSFG layers.

#### Scenario: Launching a game with None selected
- **WHEN** a game is launched with Lossless Scaling method set to None (`GOVERLAY_LOSSLESS=0`)
- **THEN** the launch command does not export `ENABLE_MAKO` or `LSFG_CONFIG`.
