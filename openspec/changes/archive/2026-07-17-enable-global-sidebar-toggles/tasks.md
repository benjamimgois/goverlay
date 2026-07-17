## 1. Sidebar Toggles Visibility and Logic

- [x] 1.1 In `sidebar_nav.pas`, update `UpdateNavToolToggleVisibility` visibility condition to `ShouldShow := FForm.FNavActive <> 0;`.
- [x] 1.2 In `sidebar_nav.pas`, update `LoadGameToggleStates` to load global configuration files presence as toggle states when `FActiveGameName` is empty.
- [x] 1.3 In `sidebar_nav.pas`, update `NavToolToggleClick` to delete the global configuration file and apply disabled state when toggling OFF in global mode.

## 2. Main Form Navigation Adjustments

- [x] 2.1 In `overlayunit.pas`, update `mangohudLabelClick` to unconditionally apply the tool enabled state and save button state.
- [x] 2.2 In `overlayunit.pas`, update `vkbasaltLabelClick` to unconditionally apply the tool enabled state and save button state.

## 3. Verification

- [x] 3.1 Recompile GOverlay.
- [x] 3.2 Verify that toggles are hidden on the Games tab.
- [x] 3.3 Verify that toggles are visible on global configuration tabs (MangoHud, vkBasalt) and behave correctly (greying out the UI and deleting the global config file when toggled OFF, and enabling the UI when toggled ON).
