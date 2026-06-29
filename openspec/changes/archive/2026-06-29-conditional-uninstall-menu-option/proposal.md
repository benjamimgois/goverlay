## Why

Currently, the "Uninstall changes" option in the game card options menu is always visible for every game card, even if GOverlay has never configured or installed OptiScaler/wrapper files for that game. Displaying an uninstall option for clean games creates UI clutter and user confusion.

## What Changes

- Dynamically set the visibility of the "Uninstall changes" menu item (`FUninstallMenuItem`) when opening a game card's options menu (`ActionPanelClick`).
- Show "Uninstall changes" only if game-specific configurations exist (e.g., `GetGameConfigDir(GameName)` directory exists) OR OptiScaler/wrapper markers (`goverlay.vars`, `OptiScaler.dll`, `OptiScaler.ini`) are detected in the game installation directory.

## Capabilities

### New Capabilities
- `conditional-uninstall-menu-option`: Hides the "Uninstall changes" option from the game card context menu unless GOverlay configurations or OptiScaler files exist for that game.

### Modified Capabilities
<!-- None -->

## Impact

- `overlayunit.pas`: Added `FUninstallMenuItem: TMenuItem` field declaration to `Tgoverlayform`.
- `games_tab.pas`: Store `FUninstallMenuItem` reference and evaluate visibility on menu popup in `ActionPanelClick`.
