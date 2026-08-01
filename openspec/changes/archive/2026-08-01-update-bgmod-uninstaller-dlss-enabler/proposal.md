## Why

The `bgmod-uninstaller` utility currently cleans up OptiScaler files and legacy cache directories, but does not remove DLSS Enabler files (`dlssenabler-edge`) during global uninstallation or the `OptiScaler/` subdirectory deployed into game directories. Updating the uninstaller ensures a complete and clean removal of all upscaler assets and caches.

## What Changes

- Add removal of `~/.local/share/goverlay/dlssenabler-edge` during global uninstallation (`--global` / `-g`).
- Add removal of the `OptiScaler/` subdirectory from game directories during game-level uninstallation.

## Capabilities

### Modified Capabilities
- `upscalers-dlss-enabler`: Update uninstallation requirements to cover DLSS Enabler cache directories and game folder subdirectories.

## Impact

- Affected files: `bgmod-uninstaller.lpr`.
- Recompilation of `bgmod-uninstaller` binary.
