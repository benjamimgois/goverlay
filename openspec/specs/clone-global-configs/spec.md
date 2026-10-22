# Spec: Clone Global Configs

## Purpose

Provides a fast one-click mechanism to replicate all global overlay, post-processing, and performance tool configurations to a specific game profile without manual reconfiguration.

## Requirements

### Requirement: Clone global configs from game card context menu
The system SHALL provide a "Clone global configs" option in the game card context menu on the Games tab, located immediately below the "Open prefix folder" item.

#### Scenario: Clone to unconfigured game without confirmation
- **WHEN** user clicks "Clone global configs" on a game card that has no existing configurations or mods
- **THEN** system copies all global configuration files to the game's configuration directory without prompting
- **THEN** system rewrites the `MANGOHUD_CONFIGFILE` path in the game's `bgmod.conf` to target the game's configuration directory
- **THEN** system updates the game card's ribbon badges in-place and displays a completion notification while keeping the user on the Games tab

#### Scenario: Prompt confirmation when cloning to game with existing configurations
- **WHEN** user clicks "Clone global configs" on a game card that already contains existing configurations or mods
- **THEN** system prompts the user with a confirmation dialog before overwriting existing configurations
- **THEN** if confirmed, system proceeds with cloning, badge update, and notification
- **THEN** if rejected, system aborts without modifying any game configuration files

### Requirement: Clone global configs from floating dock in game mode
The system SHALL provide a "Clone global configs" option in the floating action dock menu (`popsaveMenu`) visible exclusively when actively configuring a game profile.

#### Scenario: Clone from dock menu with UI reload
- **WHEN** user opens the dock menu while configuring an active game and selects "Clone global configs"
- **THEN** system displays a confirmation dialog to prevent accidental overwrites
- **THEN** upon confirmation, system replicates all global configuration files to the active game's directory
- **THEN** system immediately reloads the active tab controls and sidebar toggle states to reflect the cloned values
