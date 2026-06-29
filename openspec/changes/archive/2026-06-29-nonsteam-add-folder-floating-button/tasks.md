## 1. Implementation

- [x] 1.1 In `games_tab.pas`, call `CreateActionPanel(CardPanel)` when creating card 9998 ("Add non-Steam folder").
- [x] 1.2 In `games_tab.pas`, update `GameCardMouseEnter` to show `ActionPanel` on card 9998, update `ActionPanelClick` to open `ShowRemoveFoldersMenu` for card 9998, and update `GameCardMouseUp` to remove right-click menu.

## 2. Verification

- [x] 2.1 Compile project with `lazbuild goverlay.lpi` and test floating button on card 9998.
