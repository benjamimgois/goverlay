## MODIFIED Requirements

### Requirement: Dynamic Configuration Card Adaptability
The system SHALL dynamically update visible controls and cards based on the selected method.

#### Scenario: Adapting UI for lsfg-vk
- **WHEN** "lsfg-vk" is active
- **THEN** system presents the Multiplier trackbar (1x bypass to 4x+), Flow Scale trackbar (25% to 100%), Performance Mode toggle, Allow FP16 toggle, Pacing Mode dropdown, and present quirks (Override Present Mode and Preserve Swapchain Image Count), while hiding HDR Mode and the Spatial Scaling card.

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
- **THEN** system renders green or red status dots for Lossless.dll, the installed MAKO engine (`libmako-render.so`), and the lsfg-vk Vulkan layer (`VkLayer_LSFGVK_frame_generation.json` with fallback to legacy layer manifests), displaying the path for Lossless.dll with a Browse button and the installed/remote versions.

### Requirement: MAKO Launch Environment and Layer Isolation
The system SHALL configure the execution environment with `ENABLE_MAKO=1`, `MAKO_CONFIG`, `MAKO_DISABLE_HDR_EXPOSURE=1`, `DISABLE_GAMESCOPE_WSI=1`, and explicit suppression of legacy LSFG layers (`DISABLE_LSFG=1`, `DISABLE_LSFGVK=1`) when launching games or preview binaries with the MAKO interpolation method enabled, while configuring `LSFGVK_CONFIG` pointing to `conf.toml` for `lsfg-vk`, and omitting injection flags when "None" is selected.

#### Scenario: Launching a game with Lossless Scaling enabled
- **WHEN** a game is launched with GOverlay Lossless Scaling enabled and method set to MAKO
- **THEN** the launch command exports `ENABLE_MAKO=1`, points `MAKO_CONFIG` to the game's `conf.toml`, sets `DISABLE_GAMESCOPE_WSI=1`, and suppresses legacy LSFG environment variables.

#### Scenario: Launching a game with lsfg-vk enabled
- **WHEN** a game is launched with GOverlay Lossless Scaling enabled and method set to lsfg-vk
- **THEN** the launch command exports `LSFGVK_CONFIG` pointing to the generated `conf.toml` and does not export `ENABLE_MAKO` or disable LSFGVK layers.

#### Scenario: Launching a game with None selected
- **WHEN** a game is launched with Lossless Scaling method set to None (`GOVERLAY_LOSSLESS=0`)
- **THEN** the launch command does not export `ENABLE_MAKO` or `LSFGVK_CONFIG`.

## ADDED Requirements

### Requirement: Canonical lsfg-vk 2.0 configuration serialization
The system SHALL generate a canonical `conf.toml` file adhering to schema version 2 for `lsfg-vk`, containing a `[global]` section with `dll` and `allow_fp16`, and `[[profile]]` sections containing `name`, `active_in`, `multiplier`, `flow_scale`, `performance_mode`, `pacing`, `override_present_mode`, and `preserve_swapchain_image_count`, while strictly omitting MAKO-exclusive properties.

#### Scenario: Serializing lsfg-vk 2.0 configuration
- **WHEN** user configures Lossless Scaling with method `lsfg-vk`
- **THEN** system writes `conf.toml` containing `version = 2`, `[global]` block with `dll` and `allow_fp16`, and `[[profile]]` blocks for preview cubes (`pascube`, `vkcube`) and the target game executable containing only properties recognized by upstream `lsfg-vk` 2.0.
