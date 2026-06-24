## Why

`bgmod` executes file deletion/cleanup in the game directory whenever OptiScaler is toggled off, even when OptiScaler was never installed. The `goverlay.vars` guard added in a prior fix is insufficient — edge cases (stale vars files, partial copies, leftover from other operations) cause bgmod to still delete game directories like `plugins/`, proxy DLLs needed by other mods, and original game files, leading to crashes. Users report corruption of Cyberpunk 2077, Cyberpunk, Ghost of Tsushima, Helldivers 2, and others (GitHub issue #333).

## What Changes

- **Remove** the entire OptiScaler cleanup block from `bgmod.lpr`'s disabled branch. No file deletion, restoration, or plugins directory removal when OptiScaler is disabled.
- **Keep** cleanup only in the explicit uninstaller (`bgmod-uninstaller.lpr`), which is user-invoked.
- **Keep** `goverlay.vars` deletion in the uninstaller for tracking purposes.
- **Retain** the sidebar GUI cleanup in `sidebar_nav.pas` (operates on GOverlay config dir, not the live game folder — safe).

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `bgmod-update-optiscaler`: Remove the requirement that bgmod performs cleanup when OptiScaler is disabled. Replace with requirement that bgmod SHALL NOT modify any game directory files when OptiScaler is disabled, regardless of `goverlay.vars` presence.

## Impact

- `bgmod.lpr`: Delete the entire `else` cleanup block (~55 lines, lines 923-978) and replace with a single `Log('OptiScaler disabled, skipping')` line.
- `bgmod-uninstaller.lpr`: No changes needed — already handles full cleanup correctly.
- `openspec/specs/bgmod-update-optiscaler/spec.md`: Delta spec to modify the cleanup requirement.
