# Spec Delta: lossless-scaling-config

## MODIFIED Requirements

### Requirement: Lossless Scaling configuration file contains pascube and vkcube preview profiles
The system SHALL generate a canonical MAKO `conf.toml` (version = 2) containing explicit `[[profile]]` entries for `pascube` and `vkcube` using the active multiplier, flow scale, performance mode, FP16, pacing, adaptive, and spatial scaling options whenever Lossless Scaling is configured, and SHALL include the resolved target game executable name (including native Linux binaries without `.exe` when resolved from `bgmod` or cached `TARGET_EXE` in `bgmod.conf`) in the game profile `active_in` list.

#### Scenario: Saving Lossless Scaling configuration
- **WHEN** user configures Lossless Scaling settings with a valid DLL path and active multiplier or spatial scaling
- **THEN** system writes `conf.toml` containing dedicated `[[profile]]` blocks matching `active_in = ["pascube"]` and `active_in = ["vkcube"]` alongside target game executables (including cached or detected native Linux binary names) with matching MAKO frame generation and spatial scaling parameters.

### Requirement: Canonical lsfg-vk 2.0 configuration serialization
The system SHALL generate a canonical `conf.toml` file adhering to schema version 2 for `lsfg-vk`, containing a `[global]` section with `dll` and `allow_fp16`, and `[[profile]]` sections containing `name`, `active_in`, `multiplier`, `flow_scale`, `performance_mode`, `pacing`, `override_present_mode`, and `preserve_swapchain_image_count`, while strictly omitting MAKO-exclusive properties, and ensuring `active_in` contains the detected target executable name for both Windows PE (`.exe`) and native Linux binaries.

#### Scenario: Serializing lsfg-vk 2.0 configuration
- **WHEN** user configures Lossless Scaling with method `lsfg-vk`
- **THEN** system writes `conf.toml` containing `version = 2`, `[global]` block with `dll` and `allow_fp16`, and `[[profile]]` blocks for preview cubes (`pascube`, `vkcube`) and the target game executable (including native Linux executable names without `.exe`) containing only properties recognized by upstream `lsfg-vk` 2.0.

#### Scenario: Launching native Linux game with lsfg-vk active
- **WHEN** a native Linux game (such as `eurotrucks2`) is launched via `bgmod` with `lsfg-vk` active
- **THEN** `bgmod` regenerates `conf.toml` preserving user tuning parameters and adding a `[[profile]]` whose `active_in` list includes the native Linux binary name.
