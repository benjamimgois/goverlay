## 1. MangoHud UI Reset Implementation

- [x] 1.1 In `mangohud_ui.pas`, declare `procedure ResetMangoHudControls;` in `TMangoHudUiHelper` interface.
- [x] 1.2 In `mangohud_ui.pas` implementation, implement `TMangoHudUiHelper.ResetMangoHudControls` to reset all checkboxes on the 5 MangoHud tabs and other specific settings controls to default values.
- [x] 1.3 In `mangohud_ui.pas`, call `ResetMangoHudControls` at the beginning of `LoadMangoHudConfig` (right after verifying the config file exists).

## 2. Verification

- [x] 2.1 Recompile GOverlay.
- [x] 2.2 Verify that switching from a game-specific config containing custom MangoHud options to the global configuration successfully resets those options in the GOverlay UI (instead of leaking them).
- [x] 2.3 Verify that saving global settings after visiting a game-specific config no longer writes game-specific settings to the global configuration.
