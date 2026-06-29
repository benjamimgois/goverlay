## Why

When users uninstall modifications via GOverlay's "Uninstall changes" action, OptiScaler often remains active in games. This happens for two main reasons:
1. In many games (e.g., Unreal Engine games), OptiScaler DLLs are installed in subdirectories (e.g., `Binaries/Win64/`). When uninstalling from the GUI, if `bgmod-uninstaller` is not found, cleanup falls back to the top-level game root directory, leaving the actual binary directory untouched.
2. In the `bgmod` wrapper binary, when OptiScaler is disabled, it currently logs a message and skips cleanup entirely. If proxy DLLs (`dxgi.dll`, `version.dll`, etc.) remain in the game's binary folder, Windows loads them automatically when the game launches, forcing OptiScaler to stay active.

## What Changes

- Update `GameCardUninstallClick` in `games_tab.pas` to recursively search for directories containing OptiScaler markers (`goverlay.vars`, `OptiScaler.dll`, or `OptiScaler.ini`) within the game installation path and execute full cleanup on every matching directory.
- Update `bgmod.lpr` so that when `GOverlayOptiscaler` is disabled (`False`), if `goverlay.vars` or proxy files exist in `GameDir`, it performs cleanup and restores backup DLLs rather than doing nothing.

## Capabilities

### New Capabilities
- `fix-optiscaler-game-uninstall-cleanup`: Fixes game uninstallation and launch wrapper cleanup to ensure OptiScaler and proxy DLLs are reliably removed from binary subdirectories.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas`: Enhanced uninstallation path resolution and recursive marker scanning.
- `bgmod.lpr`: Reactive cleanup when game is launched with OptiScaler disabled.
