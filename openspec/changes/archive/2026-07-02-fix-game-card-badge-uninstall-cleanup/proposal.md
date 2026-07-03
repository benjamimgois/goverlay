## Why

Clicking "Uninstall changes" on a game card removes the Steam/Wine icon badge (top-left corner) along with the GOverlay settings badge (top-right corner). Only the GOverlay badge should disappear, since it indicates active GOverlay configurations. The Steam/Heroic icon identifies the game's platform and must persist regardless of uninstall state.

## What Changes

- Tag the Steam/Heroic badge with `Tag := 1` and the GOverlay badge with `Tag := 2` at creation time in `LoadSteamGames` and `LoadNonSteamFolders`.
- In `GameCardUninstallClick`, filter the badge cleanup loop: only delete images where `Panel.Controls[i].Tag = 2` (GOverlay badge) instead of deleting every `Proportional=True` image.

## Capabilities

### New Capabilities

- `fix-game-card-badge-uninstall-cleanup`: game card badges are correctly preserved or removed on uninstall based on their type.

### Modified Capabilities

_None._

## Impact

- **Affected files**: `games_tab.pas` — badge creation blocks in `LoadSteamGames` and `LoadNonSteamFolders`, and cleanup loop in `GameCardUninstallClick`.
- **No API/path/build changes**: Pascal-level tag assignment only; no binary changes required beyond GOverlay recompilation.