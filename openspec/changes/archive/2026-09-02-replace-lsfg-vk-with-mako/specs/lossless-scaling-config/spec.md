## MODIFIED Requirements

### Requirement: Lossless Scaling configuration file contains pascube and vkcube preview profiles
The system SHALL generate a canonical MAKO `conf.toml` (version = 2) containing explicit `[[profile]]` entries for `pascube` and `vkcube` using the active multiplier, flow scale, performance mode, FP16, pacing, adaptive, and spatial scaling options whenever Lossless Scaling is configured.

#### Scenario: Saving Lossless Scaling configuration
- **WHEN** user configures Lossless Scaling settings with a valid DLL path and active multiplier or spatial scaling
- **THEN** system writes `conf.toml` containing dedicated `[[profile]]` blocks matching `active_in = ["pascube"]` and `active_in = ["vkcube"]` alongside target game executables with matching MAKO frame generation and spatial scaling parameters.

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

## ADDED Requirements

### Requirement: Support for Spatial Scaling and Adaptive Frame Generation
The system SHALL serialize MAKO's spatial scaling (`scaling_enabled`, `scaling_method`, `scaling_factor`, `scaling_sharpness`, `scaling_supersampling`) and adaptive frame generation (`adaptive`, `target_fps`, `adaptive_max_multiplier`, `adaptive_auto_base_fps_cap`, `base_fps_cap`, `frame_generation_refresh_threshold`) in the generated `conf.toml` profile.

#### Scenario: Configuring Spatial Scaling with LS1 Quality
- **WHEN** user enables spatial scaling with method `ls1`, factor 1.5, and sharpness 0.8
- **THEN** the profile in `conf.toml` contains `scaling_enabled = true`, `scaling_method = "ls1"`, `scaling_factor = 1.5`, and `scaling_sharpness = 0.8`.

#### Scenario: Configuring Adaptive Frame Generation
- **WHEN** user selects Adaptive Frame Generation with Target FPS 90 and Max Multiplier 3x
- **THEN** the profile in `conf.toml` contains `adaptive = true`, `target_fps = 90`, and `adaptive_max_multiplier = 3`.

### Requirement: MAKO Launch Environment and Layer Isolation
The system SHALL configure the execution environment with `ENABLE_MAKO=1`, `MAKO_CONFIG`, `MAKO_DISABLE_HDR_EXPOSURE=1`, `DISABLE_GAMESCOPE_WSI=1`, and explicit suppression of legacy LSFG layers (`DISABLE_LSFG=1`, `DISABLE_LSFGVK=1`) when launching games or preview binaries with Lossless Scaling enabled.

#### Scenario: Launching a game with Lossless Scaling enabled
- **WHEN** a game is launched with GOverlay Lossless Scaling enabled
- **THEN** the launch command exports `ENABLE_MAKO=1`, points `MAKO_CONFIG` to the game's `conf.toml`, sets `DISABLE_GAMESCOPE_WSI=1`, and suppresses legacy LSFG environment variables.
