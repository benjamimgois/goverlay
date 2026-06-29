## Context

Currently, regular game cards use a floating action button (`ActionPanel`, Tag 9990) for card options and disabling right-click context menus. The "Add non-Steam folder" card (Tag 9998) relied on right-clicking to show `ShowRemoveFoldersMenu`. We align card 9998 with regular game cards.

## Goals / Non-Goals

**Goals:**
- Call `CreateActionPanel(CardPanel)` for card 9998 in `games_tab.pas`.
- Update `GameCardMouseEnter` to show `ActionPanel` for card 9998.
- Update `ActionPanelClick` so if `CardPanel.Tag = 9998`, it invokes `ShowRemoveFoldersMenu(Panel, Panel.Width div 2, Panel.Height div 2)`.
- Update `GameCardMouseUp` to disable right-click menu on card 9998.

**Non-Goals:**
- Modifying non-Steam folder storage format.

## Decisions

### Decision 1: Uniform floating button behavior on card 9998
In `games_tab.pas`:
- Add `CreateActionPanel(CardPanel)` after initializing card 9998 controls.
- Remove `if Panel.Tag <> 9998` guard in `GameCardMouseEnter`.
- In `ActionPanelClick`, add early check for card 9998 to open `ShowRemoveFoldersMenu`.

## Risks / Trade-offs

- None identified.
