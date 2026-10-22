## Context

See proposal.md for problem analysis and motivation.

Currently, `gamesLabelClick` in `overlayunit.pas` executes `RefreshGameCards` whenever `WasInGameMode` is `True`. This discards all existing card panels and cover bitmaps, scans all Steam library paths and manifests, decodes every cover image, processes gradients on the CPU, and creates hundreds of Qt widgets synchronously on the UI thread—solely to update the badge of the single game that was edited.

## Goals / Non-Goals

**Goals:**
- Eliminate the UI freeze when clicking "Games" from a game configuration screen.
- Retain all existing card panels and cover images in memory when navigating between game config and the games library.
- Update only the affected game's badge (`BdgImg` with `Tag = 2`), badge bitmask (`Tag`), and tooltip in-place.
- Ensure the transition takes < 10 ms, matching global mode speed.

**Non-Goals:**
- Removing `RefreshGameCards` where full library reconstruction is genuinely required (adding/removing folder paths, or when Steam CDN background downloads complete).
- Redesigning the card layout or badge visuals.

## Decisions

### Decision 1: Targeted in-place badge update (`UpdateGameCardBadge`)

- **Implementation:** Add `procedure UpdateGameCardBadge(const AGameName: string);` to `TGamesTabHelper` in `games_tab.pas`.
- **Logic:**
  1. Iterate `FCardPanels` to find the panel matching `AGameName` (parsing the game title from line 0 of `Panel.Hint`).
  2. If found, query the game's config directory (`GetGameConfigDir(AGameName)`) for tool configuration files (`MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, `bgmod.conf`).
  3. Calculate `BadgeCount` bitmask.
  4. Compare with `Panel.Tag`:
     - If `BadgeCount > 0`: find or create the `BdgImg` (`Tag = 2`), set its icon, bring to front, and append the `Enabled GOverlay Tools:` tooltip.
     - If `BadgeCount = 0`: if `BdgImg` exists, free or hide it, and strip the badge lines from `Panel.Hint` and `CardImage.Hint`.
     - Update `Panel.Tag := BadgeCount`.
- **Rationale:** Checking 3-4 files on disk for 1 game takes < 0.5 ms. Updating 1 Qt widget is instantaneous. The entire library remains intact and visible.

### Decision 2: Update `gamesLabelClick` in `overlayunit.pas`

- Store `LastGameName := FActiveGameName;` before clearing `FActiveGameName := '';`.
- In `gamesLabelClick`, replace:
  ```pascal
  if WasInGameMode and FGamesLoaded then
    RefreshGameCards;
  ```
  with:
  ```pascal
  if WasInGameMode and FGamesLoaded and Assigned(FGamesHelper) and (LastGameName <> '') then
    TGamesTabHelper(FGamesHelper).UpdateGameCardBadge(LastGameName);
  ```

## Risks / Trade-offs

- [Risk] If a game was deleted or uninstalled outside GOverlay while GOverlay was open, its card will remain until the next folder refresh or app restart.
  - Mitigation: This is standard behavior across desktop launchers (Steam, Lutris, Heroic); full directory rescans are triggered on startup or manual refresh, not on simple internal tab navigation.
