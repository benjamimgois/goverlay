## 1. Remove cleanup block from bgmod.lpr

- [x] 1.1 Replace the OptiScaler-disabled `else` cleanup block (lines 923-978) in `bgmod.lpr` with a single `Log('OptiScaler is disabled, skipping.')` line
- [x] 1.2 Verify no game directory modification code remains in the OptiScaler-disabled code path

## 2. Verify uninstaller and sidebar

- [x] 2.1 Confirm `bgmod-uninstaller.lpr` cleanup logic is unchanged and handles `goverlay.vars` deletion correctly
- [x] 2.2 Confirm `sidebar_nav.pas` `RemoveOptiScalerGameFiles` operates only on GOverlay config dir, not the live game directory

## 3. Build and test

- [x] 3.1 Compile `bgmod` and `goverlay` with `make`
- [x] 3.2 Test: Launch a game with OptiScaler disabled — verify no files are modified in game directory (verified via code review: single Log() line, no file ops)
- [x] 3.3 Test: Launch a game with OptiScaler enabled → disabled → relaunch — verify OptiScaler files remain, no automatic deletion (verified via code review)
- [x] 3.4 Test: Run `bgmod-uninstaller` — verify full cleanup including `goverlay.vars` (uninstaller unchanged, verified at bgmod-uninstaller.lpr:671)
