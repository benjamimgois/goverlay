## ADDED Requirements

### Requirement: Isolate global profile configuration folder
When the global profile is active, GOverlay and the `bgmod`/`bgmod-uninstaller` wrappers MUST read and write configuration files (including `bgmod.conf`, `goverlay.vars`, `OptiScaler.ini`, and `fakenvapi.ini`) to a dedicated global game config directory at `~/.local/share/goverlay/gameconfig/global/`. The `~/.local/share/goverlay/bgmod/` folder SHALL only store default template scripts, binaries, and fallback updates, and MUST NOT be used to read or write active user configs.

#### Scenario: Global configuration isolation
- **WHEN** the global profile is active in GOverlay and settings are saved, or when a game is run using the global profile settings
- **THEN** GOverlay and `bgmod` read/write settings to `~/.local/share/goverlay/gameconfig/global/`, leaving `~/.local/share/goverlay/bgmod/` unchanged as a pristine repository.
