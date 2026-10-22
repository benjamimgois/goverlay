# Proposal

## Why

When users update GOverlay (e.g., from 1.9.2 to a newer release or nightly build), existing game profiles under `~/.local/share/goverlay/gameconfig/<GameName>/` retain obsolete copies of the `bgmod` execution wrapper. Because Steam launch options invoke `gameconfig/<GameName>/bgmod` directly, critical bug fixes in the wrapper (such as process supervision and clean exit detection in issue #413) do not reach existing games unless the user manually deletes their GOverlay data or re-clicks every individual game card in the UI. Furthermore, troubleshooting is impeded because `bgmod` logs do not output an explicit version number.

## What Changes

- Automatically synchronize wrapper binaries (`bgmod`, `bgmod-uninstaller`, `bgmod-splash`) and ensure the `fgmod` symlink across all existing game profile directories in `~/.local/share/goverlay/gameconfig/*/` during GOverlay startup (`FormCreate`).
- Guarantee execution permissions (`chmod 755`) for all synchronized wrapper executables in every game profile folder.
- Strictly preserve all user configuration files (`bgmod.conf`, `MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, `fakenvapi.ini`, `goverlay.vars`, and `backups/`) during wrapper updates.
- Introduce explicit version constants in `bgmod.lpr` and `bgmod-uninstaller.lpr` and log the wrapper version upon execution to simplify diagnostics and issue tracking.

## Capabilities

### New Capabilities
- `game-wrapper-binary-sync`: Automatically synchronizes wrapper binaries across all existing per-game configuration folders on application startup and logs explicit wrapper version information during launch.

### Modified Capabilities
<!-- None -->

## Impact

- `bgmod_resources.pas`: Add routines to iterate and update wrapper binaries in all subdirectories of `gameconfig/`.
- `overlayunit.pas`: Trigger per-game wrapper synchronization during initialization.
- `bgmod.lpr` and `bgmod-uninstaller.lpr`: Add `BGMOD_VERSION` constant and include it in initial log output.
- `tests/`: Automated unit tests verifying that pre-existing game profiles with outdated wrapper binaries get updated while preserving user configs.
