# Capability: fix-optiscaler-game-uninstall-cleanup

Fixes game uninstallation and launch wrapper cleanup to ensure OptiScaler and proxy DLLs are reliably removed from binary subdirectories.

## ADDED Requirements

### Requirement: Recursive binary folder resolution during GUI uninstallation
GOverlay SHALL scan the entire game installation tree for directories containing OptiScaler installation markers (`goverlay.vars`, `OptiScaler.dll`, or `OptiScaler.ini`) when "Uninstall changes" is executed in the GUI, and run cleanup on all identified directories.

#### Scenario: Uninstalling changes on a game with binary subdirectories
- **WHEN** user clicks "Uninstall changes" on a game card
- **THEN** GOverlay cleans up proxy DLLs and OptiScaler files in all subdirectories containing installation markers.

### Requirement: Wrapper cleanup on launch when OptiScaler is disabled
The `bgmod` execution wrapper SHALL check for and clean up leftover proxy DLLs (`dxgi.dll`, `version.dll`, `winmm.dll`, etc.) and OptiScaler files in the target game directory when `GOverlayOptiscaler` is disabled.

#### Scenario: Launching a game with OptiScaler disabled
- **WHEN** a game is launched via `bgmod` with OptiScaler disabled and `goverlay.vars` or proxy DLLs exist in `GameDir`
- **THEN** `bgmod` cleans up proxy files and restores original DLL backups before starting the game.
