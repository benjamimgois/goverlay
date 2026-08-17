## Why

Following the transition to the Floating Action Dock (`FFADock`) and modal Finish Configuration dialog (`FFinishDialog`), the legacy bottom bar (`goverlaybarPanel`) and its embedded launch command panel (`commandPanel`) were deprecated and hidden on application startup. However, legacy visibility calls in `GameCardClick` (when selecting any game in the Games tab) and in configuration save routines (`SaveMangoHudConfig`, `SaveVkBasaltConfig`, `SaveOptiScalerConfig`, `SaveTweaksConfig`) re-enable `goverlaybarPanel.Visible := True` and `commandPanel.Visible := True`. This causes the old full-width bottom bar with the `%command%` text box to reappear at the bottom of the window, clashing with and rendering underneath the floating action dock.

## What Changes

- **Clean Up Game Card Navigation**: In `games_tab.pas` (`TGamesTabHelper.GameCardClick`), remove calls enabling `goverlaybarPanel`, `popupBitBtn`, `FPreviewBtn`, and `UpdateCommandPanelRightAnchor`. Instead, update `FFADock` via `FFADock.UpdateForTab(True, True, False)` to show the modern floating dock for MangoHud.
- **Suppress Legacy Command Panel on Save**: In `overlayunit.pas`, `optiscaler_tab.pas`, and `tweaks_md3.pas`, remove obsolete calls to `commandPanel.Visible := True` in save and configuration apply methods.
- **Ensure Permanent Invisibility of Legacy Bottom Bar**: Guarantee that `goverlaybarPanel` and `commandPanel` remain strictly invisible across all tab switches, game card selections, and configuration save operations.
- **Automated Regression Test**: Add a GUI test verifying that selecting a game card from the Games tab keeps `goverlaybarPanel` hidden while properly displaying `FFADock`.

## Capabilities

### Modified Capabilities
- `floating-action-dock`: Ensure the floating action dock is properly activated and the legacy bottom bar (`goverlaybarPanel`) and command panel (`commandPanel`) remain permanently hidden when selecting game cards and saving configurations.

## Impact

- `games_tab.pas`: `GameCardClick` updated to use `FFADock` and not touch `goverlaybarPanel`.
- `overlayunit.pas`: Removed lingering `commandPanel.Visible := True` invocations in `SaveMangoHudConfig`, `SaveVkBasaltConfig`, and `saveBitBtnClick`.
- `optiscaler_tab.pas`: Removed `commandPanel.Visible := True` in `SaveOptiScalerConfig`.
- `tweaks_md3.pas`: Removed `commandPanel.Visible := True` in `SaveTweaksConfig`.
- `tests/gui/gui_test_cases.pas`: New GUI test asserting `goverlaybarPanel.Visible = False` after navigating from Games tab via game card click.
