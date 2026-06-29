## 1. Implementation

- [x] 1.1 In `overlayunit.pas`, declare `FUninstallMenuItem: TMenuItem` in `Tgoverlayform`.
- [x] 1.2 In `games_tab.pas`, assign `FUninstallMenuItem := UninstallItem` during `FGameCardMenu` initialization.
- [x] 1.3 In `games_tab.pas`, update `ActionPanelClick` to evaluate game modifications and set `FUninstallMenuItem.Visible` before popping up `FGameCardMenu`.

## 2. Verification

- [x] 2.1 Verify project compiles with `lazbuild goverlay.lpi`.
