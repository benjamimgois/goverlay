## Why

When navigating back to the "Games" tab from a per-game configuration view (e.g. OptiScaler, MangoHud, or Tweaks), the interface experiences a severe lag (1 to 3+ seconds freeze). This does not occur when clicking "Games" while in global configuration mode.

The freeze happens because `gamesLabelClick` in `overlayunit.pas` unconditionally calls `RefreshGameCards` when returning from game mode. `RefreshGameCards` destroys all card panels and cached bitmaps, re-scans all Steam libraries and non-Steam folders, re-reads all manifests, decodes all cover images, re-processes pixel gradients, and recreates hundreds of UI controls synchronously on the main thread—all merely to refresh the badge on the single game card that was just configured.

## What Changes

- Replace the synchronous full library rebuild (`RefreshGameCards`) in `gamesLabelClick` with a targeted, in-place card badge update for the game that was just edited (`UpdateGameCardBadge`).
- Retain existing cards and bitmaps in memory across game configuration visits so returning to the "Games" tab is instantaneous (< 10 ms), identical to returning from global mode.
- Update `TGamesTabHelper.UpdateGameCardBadge` to inspect only the active game's config files and update or remove its `BdgImg` badge and tooltip in-place without touching any other cards.
- Keep full `RefreshGameCards` exclusively for operations where the game list actually changes (adding/removing non-Steam folders, or when background Steam CDN downloads complete).

## Capabilities

### New Capabilities
- `games-tab-navigation`: Specifies instantaneous tab navigation to the Games library, preserving loaded cards in memory and updating badges in-place upon returning from per-game configuration.

## Impact

- Files affected:
  - `overlayunit.pas`: `gamesLabelClick`
  - `games_tab.pas`: `UpdateGameCardBadge`
  - `tests/gui/gui_test_cases.pas`: test cases for fast return and in-place badge updating
- Eliminates multi-second UI freezes when returning to the games list.
