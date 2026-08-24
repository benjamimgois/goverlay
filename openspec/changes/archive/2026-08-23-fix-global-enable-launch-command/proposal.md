## Why

When MangoHud "Global Enable" is active in GOverlay, saving settings in `saveBitBtnClick` was historically replacing `FLaunchCommand` with the descriptive string `"MangoHud will be displayed in every vulkan application"`. This legacy informational text causes issues (such as reported in GitHub Issue #397) by overriding the real `bgmod` launch command needed for multi-tool overlay execution, per-game configurations, OptiScaler, vkBasalt, and Steam/Heroic launch options.

## What Changes

- In `saveBitBtnClick` in `overlayunit.pas`, remove the conditional branch that overwrote `FLaunchCommand` with `'MangoHud will be displayed in every vulkan application'`.
- Ensure `saveBitBtnClick` consistently assigns `FLaunchCommand := GetLaunchCommand;` regardless of `globalenableMenuItem.Checked` state.
- Add automated test assertions verifying that when `globalenableMenuItem.Checked` is true, saving or requesting the launch command still produces a valid executable launch command (pointing to `bgmod`) rather than informative text.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `finish-configuration-dialog`: Ensure launch commands remain valid executable paths even when MangoHud Global Enable is toggled on.

## Impact

- `overlayunit.pas`: `saveBitBtnClick` will no longer set `FLaunchCommand` to a descriptive string.
- `tests/gui/gui_test_cases.pas`: Enhanced test cases checking launch command generation with global enable checked.
