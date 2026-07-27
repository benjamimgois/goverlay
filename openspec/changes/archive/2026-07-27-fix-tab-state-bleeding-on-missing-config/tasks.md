## 1. Unconditional Control Reset on Load

- [x] 1.1 Update `LoadMangoHudConfig` in `mangohud_ui.pas` to call `ResetMangoHudControls` before checking `FileExists(MANGOHUDCFGFILE)`.
- [x] 1.2 Update `LoadVkBasaltConfig` in `overlayunit.pas` to execute control/trackbar/MD3 label resets before checking `FileExists(VKBASALTCFGFILE)`.
- [x] 1.3 Update `LoadVkSumiConfig` in `overlayunit.pas` to reset vkSumi controls when config file does not exist.

## 2. Testing and Verification

- [x] 2.1 Add GUI tests in `tests/gui/gui_test_cases.pas` to verify control resetting when loading profiles with missing MangoHud, vkBasalt, and vkSumi configs.
- [x] 2.2 Run `make test` to confirm all tests pass cleanly.
