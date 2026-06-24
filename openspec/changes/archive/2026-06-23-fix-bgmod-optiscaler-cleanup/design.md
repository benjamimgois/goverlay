## Context

Currently, `bgmod` runs a cleanup block whenever OptiScaler is disabled, which deletes various libraries and folders (like `plugins/`). Because this cleanup runs unconditionally, games that never had OptiScaler enabled (but are launched with MangoHud or environment variables enabled) have their original folders and other mods' files (such as CET plugins for Cyberpunk 2077) deleted, leading to game crashes.

## Goals / Non-Goals

**Goals:**
- Skip OptiScaler cleanup block in `bgmod` if OptiScaler was never installed in the game directory.
- Verify installation state using the presence of `goverlay.vars` in the game directory.
- Delete `goverlay.vars` upon successful cleanup/uninstallation.

**Non-Goals:**
- Completely rewriting the cleanup/restore logic or changing the list of cleaned files.

## Decisions

### 1. Condition the OptiScaler cleanup block on the presence of `goverlay.vars`
- **Choice**: Check if `goverlay.vars` exists in `GameDir` before executing any cleanup calls in the OptiScaler-disabled block.
- **Rationale**: `goverlay.vars` is only created and copied to the game folder when OptiScaler is successfully installed or updated. Its presence is a reliable indicator that OptiScaler files were actually placed in the game directory by GOverlay.
- **Alternative considered**: Checking for the existence of `OptiScaler.dll`. However, the user or game might have other files (e.g. from third-party wrappers) that resemble OptiScaler or they might have deleted `OptiScaler.dll` manually but left the other files. `goverlay.vars` is uniquely written by GOverlay for version/install tracking.

### 2. Delete `goverlay.vars` during cleanup and uninstallation
- **Choice**: Call `SafeDeleteFile` on `goverlay.vars` at the end of cleanup in `bgmod.lpr` and in the uninstallation routine of `bgmod-uninstaller.lpr`.
- **Rationale**: Once cleanup or uninstallation is complete, the game directory is returned to its clean state. Deleting `goverlay.vars` prevents redundant cleanup passes on subsequent launches.

## Risks / Trade-offs

- **[Risk]** If a user upgrades from a version of GOverlay that did not write `goverlay.vars` and then disables OptiScaler, the cleanup block will be skipped and old OptiScaler files might remain in the game directory.
  - *Mitigation*: This is a rare one-time migration edge case. The user can manually clean up the folder or run the uninstaller if needed. For the vast majority of users, avoiding game file corruption is far more important.
