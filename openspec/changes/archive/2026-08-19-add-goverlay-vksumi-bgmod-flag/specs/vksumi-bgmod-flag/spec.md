## Purpose

Defines the GOVERLAY_VKSUMI configuration flag and automated neutral default detection for decoupled vkSumi post-processing injection.

## ADDED Requirements

### Requirement: GOVERLAY_VKSUMI Config Flag Persistence
The system SHALL support a dedicated `GOVERLAY_VKSUMI` key under `[Config]` in `bgmod.conf` to control vkSumi configuration copying and injection independently from `GOVERLAY_VKBASALT`.

#### Scenario: GOVERLAY_VKSUMI flag present in bgmod.conf template
- **WHEN** GOverlay initializes or generates a new default `bgmod.conf`
- **THEN** `GOVERLAY_VKSUMI=0` is present in the `[Config]` section alongside `GOVERLAY_VKBASALT=0`

### Requirement: Automated Default Detection for vkSumi
The system SHALL evaluate whether all 15 vkSumi parameter sliders match their defined default neutral values, setting `GOVERLAY_VKSUMI` to `0` when all sliders are at default and to `1` when any slider is customized.

#### Scenario: All vkSumi sliders at neutral default positions
- **WHEN** vkSumi configuration is saved and all 15 color grading sliders are at their neutral default positions
- **THEN** `GOVERLAY_VKSUMI` is set to `0` in `bgmod.conf` and `vkSumi.conf` has `enabled = false`

#### Scenario: At least one vkSumi slider altered from default
- **WHEN** vkSumi configuration is saved and at least one color grading slider is set to a non-default position
- **THEN** `GOVERLAY_VKSUMI` is set to `1` in `bgmod.conf` and `vkSumi.conf` has `enabled = true`

### Requirement: Decoupled vkBasalt and vkSumi Injection in bgmod
The `bgmod` wrapper binary SHALL evaluate `GOVERLAY_VKBASALT` and `GOVERLAY_VKSUMI` independently when copying configuration files and exporting environment variables for game processes.

#### Scenario: vkBasalt enabled and vkSumi disabled
- **WHEN** `bgmod` runs with `GOVERLAY_VKBASALT=1` and `GOVERLAY_VKSUMI=0`
- **THEN** `vkBasalt.conf` is copied to the game directory, `ENABLE_VKBASALT=1` is exported, `vkSumi.conf` is removed from the game directory, and `ENABLE_VKSUMI` is not exported

#### Scenario: vkSumi enabled and vkBasalt disabled
- **WHEN** `bgmod` runs with `GOVERLAY_VKBASALT=0` and `GOVERLAY_VKSUMI=1`
- **THEN** `vkSumi.conf` is copied to the game directory, `ENABLE_VKSUMI=1` is exported, `vkBasalt.conf` is removed from the game directory, and `ENABLE_VKBASALT` is not exported

#### Scenario: Both post-processing layers enabled
- **WHEN** `bgmod` runs with `GOVERLAY_VKBASALT=1` and `GOVERLAY_VKSUMI=1`
- **THEN** both `vkBasalt.conf` and `vkSumi.conf` are copied to the game directory and both `ENABLE_VKBASALT=1` and `ENABLE_VKSUMI=1` are exported
