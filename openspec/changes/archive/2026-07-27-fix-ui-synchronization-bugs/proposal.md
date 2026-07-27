## Why

Several UI synchronization and reset bugs exist across GOverlay tabs (MangoHud, vkBasalt/vkSumi, and Tweaks). Specifically, config file paths are not reset to global profile defaults when clicking left sidebar tabs with `FActiveGameName = ''`, Tweaks tab controls are not reset when `bgmod.conf` is missing for a game profile, and vkBasalt active/available effect lists can become stale or misaligned during profile switches.

## What Changes

- **Sidebar Config Path Reset**: Ensure `mangohudLabelClick` and `vkbasaltLabelClick` explicitly reset `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, and `VKSUMICFGFILE` to global profile directory paths when `FActiveGameName` is empty.
- **Tweaks Control Reset on Missing Config**: Update `LoadTweaksFromFGMod` in `tweaks_md3.pas` to reset all tweak checkboxes and custom environment lists to default states before checking `FileExists(ConfigPath)`.
- **vkBasalt Active Effects List Clearing**: Ensure `acteffectsListBox` and `aveffectsListbox` are properly reset during config reloading to prevent stale or duplicate shader items.
- **MangoHud Preset Cards Selection Visual Sync**: Ensure preset card visual selection highlighting is refreshed when loading MangoHud configs.

## Capabilities

### New Capabilities
- `tab-ui-synchronization`: Requirements for resetting config file paths on tab clicks, resetting controls on missing config files, and syncing active shader lists across tabs.

### Modified Capabilities
- `global-sidebar-toggles`: Updated requirement for resetting target config file paths when navigating sidebar tabs in global mode.

## Impact

- `overlayunit.pas`: Adding global reset logic in `mangohudLabelClick` and `vkbasaltLabelClick`.
- `tweaks_md3.pas`: Moving control reset logic prior to file existence checks in `LoadTweaksFromFGMod`.
- `mangohud_ui.pas`: Refreshing preset card highlights during config load.
- Unit tests in `tests/gui/gui_test_cases.pas`: Adding test cases covering global config path resetting and Tweaks UI control resetting on missing configs.
