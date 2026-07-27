## Why

In several GOverlay tab loaders (`LoadMangoHudConfig`, `LoadVkBasaltConfig`, `LoadVkSumiConfig`), checking `FileExists(...)` occurs before calling control reset logic (`ResetMangoHudControls`, clearing active effects, resetting trackbars). When switching to a profile where the tool configuration file does not exist, the early exit bypasses control resetting, leaving stale controls, colors, trackbars, and lists from the previously selected profile visible on screen.

## What Changes

- Reorder `LoadMangoHudConfig` in `mangohud_ui.pas` to invoke `ResetMangoHudControls` prior to checking `if not FileExists(MANGOHUDCFGFILE) then Exit;`.
- Reorder `LoadVkBasaltConfig` in `overlayunit.pas` to clear `acteffectsListBox` and reset trackbars/labels prior to checking `FileExists(VKBASALTCFGFILE)`.
- Reorder `LoadVkSumiConfig` in `overlayunit.pas` to reset vkSumi controls prior to checking `FileExists(VKSUMICFGFILE)`.
- Update MD3 value labels in `LoadVkBasaltConfig` to reflect reset trackbar values.

## Capabilities

### Modified Capabilities
- `mangohud-ui-reset-on-load`: Updated requirement that `ResetMangoHudControls` runs unconditionally before checking file existence on load.
- `tab-ui-synchronization`: Updated requirement for resetting vkBasalt and vkSumi UI controls prior to file existence checks when loading configs.

## Impact

- `mangohud_ui.pas`: Reordering `ResetMangoHudControls` to execute before `FileExists(MANGOHUDCFGFILE)`.
- `overlayunit.pas`: Reordering control resets in `LoadVkBasaltConfig` and `LoadVkSumiConfig` before `FileExists` checks.
- `tests/gui/gui_test_cases.pas`: Adding GUI tests verifying control resetting when loading profiles with missing config files across MangoHud, vkBasalt, and vkSumi.
