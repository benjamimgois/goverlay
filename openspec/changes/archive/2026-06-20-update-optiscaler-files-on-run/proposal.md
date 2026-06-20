## Why

Currently, when the user updates OptiScaler using GOverlay, existing games configured to use OptiScaler continue to run with the older version of OptiScaler files. This happens because the `bgmod` executable, which runs at game launch, copies DLLs from the game's local configuration folder to the game folder, and those local configuration folders are not updated with the new DLLs. Furthermore, `bgmod` copies the files on every single run, which causes unnecessary disk write cycles. 

We need a mechanism where `bgmod` only copies files to the game folder if they are not already present or if they are outdated, and automatically updates the game's local configuration directory with the latest central/global OptiScaler files on run.

## What Changes

- Implement central-to-local sync in `bgmod`: On execution, `bgmod` will check if the global/central `bgmod` directory contains a newer version of files compared to the game's local config folder by comparing their `goverlay.vars` files. If they differ or the local file is missing, it will sync all new DLLs, folders, and resources.
- Optimize game folder copies in `bgmod`: Instead of unconditionally copying all files on every run, `bgmod` will compare the `goverlay.vars` file in the game folder with the one in the local config folder. It will only perform the copy/overwrite operations if the versions do not match or the proxy DLL/vars file is missing.
- Copy `goverlay.vars` to the game folder: After copying OptiScaler files to the game directory, `bgmod` will copy `goverlay.vars` to the game folder to track the installed version.

## Capabilities

### New Capabilities
- `bgmod-update-optiscaler`: Dynamically check, sync, and update OptiScaler files in the game's directory and local config folder upon game execution.

### Modified Capabilities

## Impact

- Affected files: `bgmod.lpr` (main logic of the `bgmod` launcher).
- No breaking changes. This runs transparently when the game is launched.
