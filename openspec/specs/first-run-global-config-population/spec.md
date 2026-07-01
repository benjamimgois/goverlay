# first-run-global-config-population

## Purpose
Ensures the isolated global profile directory is fully populated with OptiScaler runtime assets on the first launch, rather than receiving only the bundled template files.

## Requirements

### Requirement: Populate gameconfig/global/ after OptiScaler is available
GOverlay SHALL ensure the first-time population of `~/.local/share/goverlay/gameconfig/global/` happens only after OptiScaler runtime files have been installed in `~/.local/share/goverlay/bgmod/`.

#### Scenario: First launch with no prior global config
- **WHEN** GOverlay starts for the first time and `~/.local/share/goverlay/gameconfig/global/` does not exist
- **THEN** GOverlay installs OptiScaler into `~/.local/share/goverlay/bgmod/` before copying the complete contents of `bgmod/` into `gameconfig/global/`

#### Scenario: gameconfig/global/ already exists
- **WHEN** GOverlay starts and `~/.local/share/goverlay/gameconfig/global/` already exists
- **THEN** GOverlay synchronizes only binaries and non-configuration assets from `bgmod/` into `gameconfig/global/`, preserving existing user config files (`bgmod.conf`, `goverlay.vars`, `OptiScaler.ini`, `fakenvapi.ini`)
