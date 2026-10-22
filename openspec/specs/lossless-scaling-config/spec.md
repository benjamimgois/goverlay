## Purpose

Manages the generation, persistence, and synchronization of canonical MAKO `conf.toml` configuration files (and backward-compatible `lsfg.toml` mirrors) for Lossless Scaling, ensuring `pascube` preview profiles, vkcube, and game executables are always properly configured with frame generation and spatial scaling parameters.

## Requirements

### Requirement: Lossless Scaling configuration file contains pascube and vkcube preview profiles
The system SHALL generate a canonical MAKO `conf.toml` (version = 2) containing explicit `[[profile]]` entries for `pascube` and `vkcube` using the active multiplier, flow scale, performance mode, FP16, pacing, adaptive, and spatial scaling options whenever Lossless Scaling is configured, and SHALL include the resolved target game executable name (including native Linux binaries without `.exe` when resolved from `bgmod` or cached `TARGET_EXE` in `bgmod.conf`) in the game profile `active_in` list.

#### Scenario: Saving Lossless Scaling configuration
- **WHEN** user configures Lossless Scaling settings with a valid DLL path and active multiplier or spatial scaling
- **THEN** system writes `conf.toml` containing dedicated `[[profile]]` blocks matching `active_in = ["pascube"]` and `active_in = ["vkcube"]` alongside target game executables (including cached or detected native Linux binary names) with matching MAKO frame generation and spatial scaling parameters.

### Requirement: Open configuration file synchronizes active settings before launching editor
The system SHALL ensure `conf.toml` is synchronized with the current GUI state and contains `pascube` and `vkcube` definitions before opening the file in the default desktop editor.

#### Scenario: User clicks Open config file from Lossless Scaling tab
- **WHEN** user selects "Open config file" while viewing the Lossless Scaling tab
- **THEN** system writes or updates `conf.toml` with current settings including `pascube` and `vkcube` blocks before launching `xdg-open`.

### Requirement: Default template initialization includes pascube entry
The system SHALL ensure any default or bundled `conf.toml` template used for initialization includes `pascube` as an entry.

#### Scenario: Initializing game configuration directory
- **WHEN** global configuration is initialized
- **THEN** `conf.toml` contains `pascube` as a defined entry in `active_in` alongside standard demo entries.

### Requirement: Support for Spatial Scaling and Adaptive Frame Generation
The system SHALL serialize MAKO's spatial scaling (`scaling_enabled`, `scaling_method`, `scaling_factor`, `scaling_sharpness`, `scaling_supersampling`) and adaptive frame generation (`adaptive`, `target_fps`, `adaptive_max_multiplier`, `adaptive_auto_base_fps_cap`, `base_fps_cap`, `frame_generation_refresh_threshold`) in the generated `conf.toml` profile.

#### Scenario: Configuring Spatial Scaling with LS1 Quality
- **WHEN** user enables spatial scaling with method `ls1`, factor 1.5, and sharpness 0.8
- **THEN** the profile in `conf.toml` contains `scaling_enabled = true`, `scaling_method = "ls1"`, `scaling_factor = 1.5`, and `scaling_sharpness = 0.8`.

#### Scenario: Configuring Adaptive Frame Generation
- **WHEN** user selects Adaptive Frame Generation with Target FPS 90 and Max Multiplier 3x
- **THEN** the profile in `conf.toml` contains `adaptive = true`, `target_fps = 90`, and `adaptive_max_multiplier = 3`.

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

### Requirement: Unified Software Status Card
The system SHALL render a Software Status card anchored at the bottom of the Lossless Scaling tab, displaying status dots, component names, and detected versions/paths for the active Lossless Scaling library, MAKO engine, lsfg-vk layer, and AFMF layer. All runtime update indicators and action buttons across these components SHALL strictly enforce semantic version comparison (`CompareVersions > 0`), displaying update prompts only when remote is strictly newer and suppressing downgrade actions when remote <= local.

#### Scenario: Viewing software status
- **WHEN** user views the Lossless Scaling tab
- **THEN** system renders green or red status dots for the active Lossless Scaling library (`lsfg-vk.dll` when lsfg-vk is selected, `Lossless.dll` when MAKO is selected), the installed MAKO engine (`libmako-render.so`), and the lsfg-vk Vulkan layer (`VkLayer_LSFGVK_frame_generation.json` with fallback to legacy layer manifests), displaying the appropriate library path with a Browse button and the installed/remote versions.

#### Scenario: Viewing software status with lsfg-vk selected
- **WHEN** user views the Lossless Scaling tab with interpolation method set to lsfg-vk
- **THEN** the Software Status card displays the path to `lsfg-vk.dll` with a Browse button and updates the status dot based on whether `lsfg-vk.dll` exists.

#### Scenario: Viewing software status with MAKO selected
- **WHEN** user views the Lossless Scaling tab with interpolation method set to MAKO
- **THEN** the Software Status card displays the path to `Lossless.dll` with a Browse button and updates the status dot based on whether `Lossless.dll` exists.

#### Scenario: Update check evaluates remote version older or equal to local
- **WHEN** an update check completes for any runtime component (MAKO, lsfg-vk, or AFMF) and remote version is less than or equal to local
- **THEN** system SHALL NOT display an update arrow (`→`) in the status card, SHALL NOT show "Install update", and SHALL keep the status label clean.

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

### Requirement: Canonical lsfg-vk 2.0 configuration serialization
The system SHALL generate a canonical `conf.toml` file adhering to schema version 2 for `lsfg-vk`, containing a `[global]` section with `dll` and `allow_fp16`, and `[[profile]]` sections containing `name`, `active_in`, `multiplier`, `flow_scale`, `performance_mode`, `pacing`, `override_present_mode`, and `preserve_swapchain_image_count`, while strictly omitting MAKO-exclusive properties, and ensuring `active_in` contains the detected target executable name for both Windows PE (`.exe`) and native Linux binaries.

#### Scenario: Serializing lsfg-vk 2.0 configuration
- **WHEN** user configures Lossless Scaling with method `lsfg-vk`
- **THEN** system writes `conf.toml` containing `version = 2`, `[global]` block with `dll` and `allow_fp16`, and `[[profile]]` blocks for preview cubes (`pascube`, `vkcube`) and the target game executable (including native Linux executable names without `.exe`) containing only properties recognized by upstream `lsfg-vk` 2.0.

#### Scenario: Launching native Linux game with lsfg-vk active
- **WHEN** a native Linux game (such as `eurotrucks2`) is launched via `bgmod` with `lsfg-vk` active
- **THEN** `bgmod` regenerates `conf.toml` preserving user tuning parameters and adding a `[[profile]]` whose `active_in` list includes the native Linux binary name.

### Requirement: Non-blocking software status detection and instantaneous tab switching
The system SHALL detect installed software status without executing blocking external shell commands on the GUI thread, parsing the Vulkan layer JSON directly for layer versions and caching results to ensure instantaneous tab display.

#### Scenario: Switching to Lossless Scaling tab
- **WHEN** user navigates to the Lossless Scaling tab
- **THEN** the tab contents render immediately without UI freeze, reading layer metadata directly from disk and avoiding blocking package manager queries.

#### Scenario: On-demand Steam DLL lookup
- **WHEN** the active configuration or profile already contains a configured Lossless.dll path
- **THEN** the system uses the configured path directly and skips full Steam library scans.

### Requirement: MAKO Incompatibility Conflict Guard with Wayland and HDR
The system SHALL automatically prevent conflicting execution of the MAKO renderer with Wayland native Proton mode and HDR mode. When MAKO is the active interpolation method:
1. The system SHALL display a non-blocking floating toast notification informing the user that Wayland and HDR have been disabled due to MAKO incompatibility.
2. The system SHALL display an informational note `(Wayland and HDR envvars are disabled with MAKO)` beside the MAKO version on the Software status card.
3. The system SHALL deactivate and disable the "Enable Wayland" and "Enable HDR" toggles in the EnvVars tab.
4. The system SHALL exclude `PROTON_ENABLE_WAYLAND`, `PROTON_ENABLE_HDR`, `ENABLE_HDR_WSI`, and `DXVK_HDR` from the generated launch environment command and prune them from `bgmod.conf` when saving.
5. When switching from MAKO to `lsfg-vk` or `none`, the system SHALL re-enable the "Enable Wayland" and "Enable HDR" toggles and restore their saved values.

#### Scenario: Selecting MAKO method in Lossless Scaling tab
- **WHEN** user selects the MAKO method in the Lossless Scaling tab
- **THEN** system displays a floating toast notification about Wayland and HDR incompatibility, shows `(Wayland and HDR envvars are disabled with MAKO)` in the Software status card, and deactivates and disables the Wayland and HDR toggles on the EnvVars tab.

#### Scenario: Switching from MAKO to lsfg-vk or None
- **WHEN** user changes the interpolation method from MAKO to lsfg-vk or None
- **THEN** the "Enable Wayland" and "Enable HDR" toggles on the EnvVars tab are re-enabled and their previous checked states are restored.

#### Scenario: Launching games with MAKO active
- **WHEN** user launches a game with MAKO enabled
- **THEN** the launch command does not include `PROTON_ENABLE_WAYLAND`, `PROTON_ENABLE_HDR`, `ENABLE_HDR_WSI`, or `DXVK_HDR` even if previously saved in custom config.

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
