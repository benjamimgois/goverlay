## 1. Tag badges at creation

- [x] 1.1 In `LoadSteamGames`, after creating the Steam icon badge (`BdgImg := TImage.Create(CardPanel)` around line 968), add `BdgImg.Tag := 1;` to mark it as a platform badge that must survive uninstall.
- [x] 1.2 In `LoadSteamGames`, inside the `if BadgeCount > 0 then` block where the GOverlay badge is created (around line 1031), add `BdgImg.Tag := 2;` to mark it as a GOverlay configuration badge that should be cleaned on uninstall.
- [x] 1.3 In `LoadNonSteamFolders`, after creating the Wine/Heroic icon badge (around line 1315), add `BdgImg.Tag := 1;`.
- [x] 1.4 In `LoadNonSteamFolders`, inside the `if BadgeCount > 0 then` block where the GOverlay badge is created (around line 1381), add `BdgImg.Tag := 2;`.

## 2. Filter cleanup by tag

- [x] 2.1 In `GameCardUninstallClick`, change the badge deletion condition from `TImage(Panel.Controls[i]).Proportional` to `Panel.Controls[i].Tag = 2`, so only the GOverlay badge is removed.

## 3. Build and verify

- [x] 3.1 Build the full goverlay project (`lazbuild goverlay.lpi`) and confirm no compile errors.
- [ ] 3.2 Run GOverlay, click "Uninstall changes" on a Steam game with GOverlay configs, and verify the Steam icon persists while the GOverlay badge disappears.
- [ ] 3.3 Repeat for a non-Steam (Heroic) game and verify the Wine/Heroic icon persists while the GOverlay badge disappears.