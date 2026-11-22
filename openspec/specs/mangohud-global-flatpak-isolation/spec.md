# mangohud-global-flatpak-isolation Specification

## Purpose

Isolates global MangoHud mirror targets, including the Steam Flatpak configuration path, from per-game configuration writes so game-specific settings and log paths never overwrite global defaults.

## Requirements

### Requirement: Global Steam Flatpak mirror isolation
The system SHALL write MangoHud configuration to the Steam Flatpak global configuration path only when saving in global mode (`ActiveGameName` is empty), for both standard and `fps_only` configuration saves.

#### Scenario: Per-game standard save does not overwrite Steam Flatpak global config
- **WHEN** user saves MangoHud settings for a specific game while the Steam Flatpak directory exists
- **THEN** system writes the game configuration only to the game's profile directory and updates that game's `bgmod.conf`
- **THEN** system does not modify the Steam Flatpak global `MangoHud.conf`

#### Scenario: Per-game fps_only save does not overwrite Steam Flatpak global config
- **WHEN** user activates the `fps_only` preset for a specific game while the Steam Flatpak directory exists
- **THEN** system writes `fps_only` only to the game's `MangoHud.conf`
- **THEN** system does not overwrite the Steam Flatpak global `MangoHud.conf`

#### Scenario: Global save mirrors to Steam Flatpak global config
- **WHEN** user saves MangoHud settings in global mode while the Steam Flatpak directory exists
- **THEN** system writes the global configuration to the active global profile, the host MangoHud config directory, and the Steam Flatpak global `MangoHud.conf`
