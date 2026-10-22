## Purpose

Ensures that enabling or disabling overlay tools (MangoHud, vkBasalt, vkSumi, OptiScaler, and Tweaks) persists across application launches without destructively deleting user configuration files or reset values.

## ADDED Requirements

### Requirement: Non-destructive tool toggle state persistence
The system SHALL control tool activation by writing `GOVERLAY_MANGOHUD`, `GOVERLAY_VKBASALT`, `GOVERLAY_VKSUMI`, `GOVERLAY_OPTISCALER`, and `GOVERLAY_TWEAKS` flags into `bgmod.conf` without deleting configuration files (`MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`) or clearing `[Env]` variables.

#### Scenario: User disables MangoHud globally
- **WHEN** user toggles off MangoHud in the sidebar navigation rail
- **THEN** system sets `GOVERLAY_MANGOHUD=0` in `bgmod.conf`
- **THEN** system preserves `MangoHud.conf` on disk so user customization remains intact

#### Scenario: User disables Tweaks globally
- **WHEN** user toggles off Tweaks in the sidebar navigation rail
- **THEN** system sets `GOVERLAY_TWEAKS=0` in `bgmod.conf`
- **THEN** system preserves all key-value entries in the `[Env]` section of `bgmod.conf`

#### Scenario: Application restart preserves disabled tool states
- **WHEN** user restarts GOverlay after disabling tools in global mode
- **THEN** system reads tool states from `bgmod.conf` and keeps those tools disabled
- **THEN** system does not overwrite existing configuration files with default templates

### Requirement: OptiScaler game folder cleanup on toggle-off
The system SHALL preserve user `OptiScaler.ini` preferences in GOverlay's config folder while purging proxy DLLs and restoring original DLL backups in the game's actual installation directory when OptiScaler is disabled.

#### Scenario: OptiScaler disabled for a game
- **WHEN** user toggles off OptiScaler for a specific game
- **THEN** system sets `GOVERLAY_OPTISCALER=0` in that game's `bgmod.conf`
- **THEN** system retains `OptiScaler.ini` in the game profile directory
- **THEN** `bgmod` cleans proxy DLLs and restores original DLL backups when the game is launched
