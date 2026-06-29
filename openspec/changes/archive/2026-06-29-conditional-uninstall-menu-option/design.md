## Context

In `games_tab.pas`, the game options menu is displayed when clicking the 3-dots `ActionPanel` button on a game card. `UninstallItem` is added to `FGameCardMenu`. Currently, it is always visible for every game card.

## Goals / Non-Goals

**Goals:**
- Add `FUninstallMenuItem: TMenuItem` field to `Tgoverlayform` in `overlayunit.pas` and assign it during menu creation in `games_tab.pas`.
- In `ActionPanelClick` (`games_tab.pas`), resolve `GameName` and `GamePath` from `CardPanel.Hint`.
- Check if `DirectoryExists(GetGameConfigDir(GameName))` is true OR if `goverlay.vars`, `OptiScaler.dll`, or `OptiScaler.ini` exist within `GamePath` using `FindAllFiles`.
- Update `FUninstallMenuItem.Visible` accordingly before calling `FGameCardMenu.PopUp`.

**Non-Goals:**
- Changing other menu items or card behavior.

## Decisions

### Decision 1: Combined condition check
A game has modifications if either:
1. The GOverlay config dir exists: `DirectoryExists(GetGameConfigDir(GameName))`
2. Marker files exist in install folder: `FindAllFiles(GamePath, 'goverlay.vars;OptiScaler.dll;OptiScaler.ini;bgmod-uninstaller;bgmod-uninstaller.sh', True)` returns Count > 0.

## Risks / Trade-offs

- None identified.
