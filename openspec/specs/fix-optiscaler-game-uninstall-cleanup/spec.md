# Capability: fix-optiscaler-game-uninstall-cleanup

Fixes game uninstallation and launch wrapper cleanup to ensure OptiScaler and proxy DLLs are reliably removed from binary subdirectories.

## Requirements

### Requirement: Recursive binary folder resolution during GUI uninstallation
GOverlay SHALL scan the entire game installation tree for directories containing OptiScaler installation markers (`goverlay.vars`, `OptiScaler.dll`, or `OptiScaler.ini`) when "Uninstall changes" is executed in the GUI, and run cleanup on all identified directories.

#### Scenario: Uninstalling changes on a game with binary subdirectories
- **WHEN** user clicks "Uninstall changes" on a game card
- **THEN** GOverlay cleans up proxy DLLs and OptiScaler files in all subdirectories containing installation markers.

### Requirement: Marker-based proxy DLL ownership detection
When `bgmod` or `bgmod-uninstaller` needs to decide whether a proxy DLL in a game directory was placed by GOverlay (and should therefore be cleaned up), it SHALL treat the DLL as GOverlay-owned when all of the following are true: the file name is a known GOverlay proxy DLL (`dxgi.dll`, `winmm.dll`, `dbghelp.dll`, `version.dll`, `wininet.dll`, `winhttp.dll`), no `.b` backup exists for it in the same directory, and a `goverlay.vars` file exists in the same directory. The `goverlay.vars` marker SHALL be the authoritative ownership signal, replacing any file-size comparison against the global pristine template.

#### Scenario: Bleeding-edge proxy DLL is cleaned up on uninstall
- **WHEN** a game was installed with the bleeding-edge channel (proxy DLL size differs from the stable template) and the user runs the uninstaller
- **THEN** `bgmod-uninstaller` detects `goverlay.vars` in the game directory, classifies the leftover proxy DLL as GOverlay-owned, and deletes it, so the game no longer loads OptiScaler when launched without `bgmod`.

#### Scenario: Third-party proxy DLL is preserved when no marker present
- **WHEN** a game directory contains a `dxgi.dll` placed by a third-party tool (e.g. ReShade) and no `goverlay.vars` file
- **THEN** `bgmod-uninstaller` (and the launch-wrapper cleanup path in `bgmod`) leaves the `dxgi.dll` in place, treating it as third-party.

#### Scenario: Original-game DLL restore path is unaffected
- **WHEN** a game directory has a `dxgi.dll.b` backup from GOverlay's install step
- **THEN** the existing backup-restore logic runs first, restoring the original DLL; the marker-based classification is only consulted when no `.b` backup exists.

#### Scenario: Existing stable installs continue to uninstall cleanly
- **WHEN** a game was installed with the stable channel (proxy DLL size matches the global template) and the user runs the uninstaller
- **THEN** the marker `goverlay.vars` is present (written by the install flow), the stable proxy DLL is classified as GOverlay-owned, and the uninstaller removes it exactly as before — no behavioral regression.

### Requirement: Wrapper cleanup on launch when OptiScaler is disabled
The `bgmod` execution wrapper SHALL check for and clean up leftover proxy DLLs (`dxgi.dll`, `version.dll`, `winmm.dll`, etc.) and OptiScaler files in the target game directory when `GOverlayOptiscaler` is disabled. A proxy DLL SHALL be classified as GOverlay-owned (and therefore safe to delete) when its name is a known GOverlay proxy DLL, no `.b` backup exists for it, and a `goverlay.vars` file is present in the same directory. Proxy DLLs without a `.b` backup and without a `goverlay.vars` marker SHALL be treated as third-party and left in place.

#### Scenario: Launching a game with OptiScaler disabled, original backed up
- **WHEN** a game was installed with GOverlay (originals backed up to `gameconfig/<game>/backups/`), and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` restores each original DLL from `gameconfig/<game>/backups/` into `GameDir`, removes the backup slots, deletes any leftover GOverlay proxy DLLs and OptiScaler files, and starts the game without OptiScaler loading.

#### Scenario: Launching a game with OptiScaler disabled, no backup
- **WHEN** a game directory contains a GOverlay proxy `dxgi.dll` (no backup ever existed because the game has no original) plus a `goverlay.vars` marker, and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` deletes the proxy via the marker rule and starts the game without OptiScaler loading.

#### Scenario: Launching a game with OptiScaler disabled after a bleeding-edge install
- **WHEN** a game was installed with the bleeding-edge channel (proxy DLL size differs from the stable template) and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` detects `goverlay.vars` in the game directory, classifies the leftover proxy DLL as GOverlay-owned, deletes it, restores any `.b` backups, and starts the game without OptiScaler loading.

#### Scenario: Launching a game with OptiScaler disabled after a stable install
- **WHEN** a game was installed with the stable channel and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` performs the same cleanup as today, since the `goverlay.vars` marker is present and the DLL is correctly classified as GOverlay-owned; no regression.

#### Scenario: Launching a game that never had OptiScaler installed
- **WHEN** a game directory contains a third-party `dxgi.dll` (e.g. from ReShade), no `goverlay.vars`, and no `.b` backups, and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` leaves the third-party `dxgi.dll` in place.

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
