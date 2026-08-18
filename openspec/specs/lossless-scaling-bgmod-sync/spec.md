# Lossless Scaling bgmod.conf Synchronization

## Purpose

Defines persistence and execution integration for Lossless Scaling settings directly within bgmod.conf and the bgmod wrapper.

## Requirements

### Requirement: Save and Load Configuration via bgmod.conf
The system SHALL read and write Lossless Scaling settings directly to and from `bgmod.conf` rather than a separate configuration file.

#### Scenario: Saving Lossless Scaling settings to bgmod.conf
- **WHEN** the user modifies any Lossless Scaling parameter in the UI (DLL path, multiplier, flow scale, performance mode, HDR mode, disable FP16, pacing mode, GPU device)
- **THEN** the system SHALL write `GOVERLAY_LOSSLESS=1` in the `[Config]` section and update the corresponding `LSFGVK_*` key-value pairs in the `[Env]` section of `bgmod.conf`.

#### Scenario: Loading Lossless Scaling settings from bgmod.conf
- **WHEN** the user opens the Lossless Scaling tab or switches between global and game-specific profiles
- **THEN** the system SHALL populate the controls from the `[Env]` section of the active `bgmod.conf` file.

### Requirement: Environment Variable Cleanup on Deactivation
The system SHALL clean up all Lossless Scaling environment variables from `bgmod.conf` when Lossless Scaling is disabled.

#### Scenario: Disabling Lossless Scaling
- **WHEN** Lossless Scaling is turned off or DLL file is removed/invalid
- **THEN** the system SHALL set `GOVERLAY_LOSSLESS=0` under `[Config]` and remove all `LSFGVK_*` keys from the `[Env]` section of `bgmod.conf`.

### Requirement: bgmod Execution Wrapper Export
The `bgmod` wrapper executable SHALL inspect `GOVERLAY_LOSSLESS` and export `LSFGVK_*` environment variables prior to launching the game process.

#### Scenario: Launching a game with Lossless Scaling enabled
- **WHEN** `bgmod` executes and detects `GOVERLAY_LOSSLESS=1` in `bgmod.conf`
- **THEN** `bgmod` SHALL export all `LSFGVK_*` environment variables present in the `[Env]` section before executing the game.

#### Scenario: Launching a game with Lossless Scaling disabled
- **WHEN** `bgmod` executes and detects `GOVERLAY_LOSSLESS=0` (or omitted)
- **THEN** `bgmod` SHALL NOT export `LSFGVK_*` environment variables.
