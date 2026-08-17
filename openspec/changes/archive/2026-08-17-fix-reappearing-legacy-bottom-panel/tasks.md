## 1. Clean Up Game Card Navigation

- [x] 1.1 In `games_tab.pas` (`TGamesTabHelper.GameCardClick`), remove legacy assignments `goverlaybarPanel.Visible := True;`, `popupBitBtn.Visible := True;`, `FPreviewBtn.Visible := True;`, and `FForm.UpdateCommandPanelRightAnchor(True);`.
- [x] 1.2 In `games_tab.pas` (`TGamesTabHelper.GameCardClick`), configure `FFADock` via `if Assigned(FFADock) then FFADock.UpdateForTab(True, True, False);` to display the floating action dock when opening a game configuration.

## 2. Suppress Legacy Command Panel on Save

- [x] 2.1 In `overlayunit.pas`, remove `commandPanel.Visible := True` from `SaveVkBasaltConfig`, `saveBitBtnClick`, and general save helper lines.
- [x] 2.2 In `optiscaler_tab.pas`, remove `commandPanel.Visible := True` from `SaveOptiScalerConfig`.
- [x] 2.3 In `tweaks_md3.pas`, remove `FForm.commandPanel.Visible := True` from `SaveTweaksConfig`.

## 3. Verification & Automated Tests

- [x] 3.1 In `tests/gui/gui_test_cases.pas`, add a test case verifying that navigating to a game via game card click keeps `goverlaybarPanel.Visible = False` and `FFADock.Visible = True`.
- [x] 3.2 Build GOverlay and run the GUI test suite (`make test` / GUI test runner) to verify all tests pass without regressions.
