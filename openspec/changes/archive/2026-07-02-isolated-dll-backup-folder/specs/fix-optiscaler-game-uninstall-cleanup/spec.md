## ADDED Requirements

### Requirement: Original-DLL backups live outside the game directory
GOverlay SHALL back up original game DLLs to `~/.local/share/goverlay/gameconfig/<game>/backups/` (per-game) or `~/.local/share/goverlay/gameconfig/global/backups/` (global-profile), never inside the game installation directory. The backup folder is created on first install and removed together with the per-game config when the user uninstalls the GOverlay configuration for that game.

#### Scenario: First install backs up true originals
- **WHEN** GOverlay installs OptiScaler for a game whose `GameDir` contains an original `dxgi.dll` and `gameconfig/<game>/backups/dxgi.dll` does not yet exist
- **THEN** GOverlay copies `GameDir/dxgi.dll` to `gameconfig/<game>/backups/dxgi.dll` before installing the proxy, and does NOT leave any `dxgi.dll.b` file in `GameDir`.

#### Scenario: Re-install does not overwrite the backup
- **WHEN** GOverlay reinstalls OptiScaler for the same game (channel switch, re-run) and `goverlay.vars` exists in `GameDir`
- **THEN** GOverlay does not modify `gameconfig/<game>/backups/` at all — the backup retains the true original captured on the first install.

#### Scenario: Game without original DLL skips backup
- **WHEN** GOverlay installs OptiScaler for a game that does not ship a `dxgi.dll` (e.g. God of War Ragnarok) and `goverlay.vars` is not present in `GameDir`
- **THEN** GOverlay skips the backup step (no file to back up), creates no `gameconfig/<game>/backups/dxgi.dll`, and proceeds to install the proxy.

#### Scenario: Uninstall restores the true original
- **WHEN** the user runs Uninstall for a game whose `gameconfig/<game>/backups/dxgi.dll` exists
- **THEN** `bgmod-uninstaller` restores that file into `GameDir/dxgi.dll` and removes the backup slot, so the game loads the genuine original and not a previously-installed GOverlay proxy.

#### Scenario: Uninstall with no backup deletes the proxy
- **WHEN** the user runs Uninstall for a game whose `gameconfig/<game>/backups/dxgi.dll` does not exist (the game never shipped one) and a `goverlay.vars` marker exists in `GameDir`
- **THEN** `bgmod-uninstaller` deletes `GameDir/dxgi.dll` using the marker-based `IsGOverlayProxyFile` rule, so the game no longer loads OptiScaler.

## MODIFIED Requirements

### Requirement: Wrapper cleanup on launch when OptiScaler is disabled
The `bgmod` execution wrapper SHALL check for and clean up leftover proxy DLLs (`dxgi.dll`, `version.dll`, `winmm.dll`, etc.) and OptiScaler files in the target game directory when `GOverlayOptiscaler` is disabled. Original game DLLs SHALL be restored from `gameconfig/<game>/backups/` when a backup exists there; proxy DLLs without a backup SHALL be classified as GOverlay-owned using the `goverlay.vars` marker rule and deleted. The wrapper SHALL NOT read or write `<file>.b` files inside the game installation directory.

#### Scenario: Launching a game with OptiScaler disabled, original backed up
- **WHEN** a game was installed with GOverlay (originals backed up to `gameconfig/<game>/backups/`), and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` restores each original DLL from `gameconfig/<game>/backups/` into `GameDir`, removes the backup slots, deletes any leftover GOverlay proxy DLLs and OptiScaler files, and starts the game without OptiScaler loading.

#### Scenario: Launching a game with OptiScaler disabled, no backup
- **WHEN** a game directory contains a GOverlay proxy `dxgi.dll` (no `.b` backup ever existed because the game has no original) plus a `goverlay.vars` marker, and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` deletes the proxy via the marker rule and starts the game without OptiScaler loading.