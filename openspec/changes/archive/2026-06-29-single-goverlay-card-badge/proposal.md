## Why

Currently, game cards display multiple stacked feature badges (MangoHud, vkBasalt, OptiScaler, Tweaks) on the top-right corner, resulting in visual clutter and obscuring cover art. Replacing these multiple badges with a single transparent GOverlay icon badge simplifies the card aesthetics while keeping detailed active configuration information available via mouse hover tooltips.

## What Changes

- Replace the multiple stacked badge icons and dark background strip on game cards with a single transparent GOverlay icon badge in the top-right corner.
- Display the GOverlay badge only when at least one custom overlay configuration or tweak is active for the game.
- Add a mouse hover tooltip to the GOverlay badge that lists all active configurations for that game (e.g., "Active configurations: MangoHud, OptiScaler").

## Capabilities

### New Capabilities
- `single-goverlay-card-badge`: Replaces multiple stacked game card badges with a single transparent GOverlay icon badge displaying active configuration tooltips on hover.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas`: Simplifies badge rendering logic in `LoadSteamGames` and `LoadNonSteamFolders`, removing the multi-icon stacking loop and dark graphite background strip (`BdgBg`), replacing it with a single transparent `TImage` badge and dynamic hover hint.
