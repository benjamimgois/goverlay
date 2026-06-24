## Why

When `bgmod` is executed with OptiScaler disabled, it unconditionally runs cleanup routines in the game directory. This deletes generic folders like `plugins/` and other files without verifying if OptiScaler was ever installed in the game directory. This corrupts game files (e.g., deleting Cyber Engine Tweaks plugins in Cyberpunk 2077) and causes the game to crash.

## What Changes

- Modify `bgmod` to only execute the OptiScaler cleanup logic if `goverlay.vars` exists in the game directory (which indicates OptiScaler was previously installed).
- Ensure `goverlay.vars` is deleted from the game directory at the end of the cleanup routine in `bgmod`.
- Ensure `goverlay.vars` is deleted during the uninstallation routine in `bgmod-uninstaller`.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `bgmod-update-optiscaler`: Add a requirement that OptiScaler cleanup/restoring logic is only executed if `goverlay.vars` exists in the game directory, and that `goverlay.vars` is deleted when cleanup completes.

## Impact

- `bgmod.lpr`: Modify the OptiScaler disabled cleanup block.
- `bgmod-uninstaller.lpr`: Modify the uninstall cleanup block.
