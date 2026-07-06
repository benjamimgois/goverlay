## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Wrapper cleanup on launch when OptiScaler is disabled
The `bgmod` execution wrapper SHALL check for and clean up leftover proxy DLLs (`dxgi.dll`, `version.dll`, `winmm.dll`, etc.) and OptiScaler files in the target game directory when `GOverlayOptiscaler` is disabled. A proxy DLL SHALL be classified as GOverlay-owned (and therefore safe to delete) when its name is a known GOverlay proxy DLL, no `.b` backup exists for it, and a `goverlay.vars` file is present in the same directory. Proxy DLLs without a `.b` backup and without a `goverlay.vars` marker SHALL be treated as third-party and left in place.

#### Scenario: Launching a game with OptiScaler disabled after a bleeding-edge install
- **WHEN** a game was installed with the bleeding-edge channel (proxy DLL size differs from the stable template) and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` detects `goverlay.vars` in the game directory, classifies the leftover proxy DLL as GOverlay-owned, deletes it, restores any `.b` backups, and starts the game without OptiScaler loading.

#### Scenario: Launching a game with OptiScaler disabled after a stable install
- **WHEN** a game was installed with the stable channel and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` performs the same cleanup as today, since the `goverlay.vars` marker is present and the DLL is correctly classified as GOverlay-owned; no regression.

#### Scenario: Launching a game that never had OptiScaler installed
- **WHEN** a game directory contains a third-party `dxgi.dll` (e.g. from ReShade), no `goverlay.vars`, and no `.b` backups, and is launched via `bgmod` with `GOVERLAY_OPTISCALER=0`
- **THEN** `bgmod` leaves the third-party `dxgi.dll` in place.