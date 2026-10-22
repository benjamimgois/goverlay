## Why

When configuring the Lossless Scaling tab, moving the multiplier slider to `1x` causes all controls on the tab—including the multiplier slider itself—to become disabled. This leaves the user stuck and unable to adjust any setting or move the slider back.

Historically, `1x` was used to represent "disabled" before explicit engine selection radio buttons were added. With modern engine support (`lsfg-vk` and `MAKO`), the tab should only disable controls when the user explicitly chooses the "None" method or when the "Upscalers" toggle in the sidebar is turned off.

## What Changes

- Modify `TLosslessScalingTabHelper.UpdateControlsEnabled` in `lossless_scaling_tab.pas` so that frame generation controls (`FgActive`) are active whenever `FInterpolationMethod in [imLsfg, imMako]`, regardless of whether `FLsMultiplierTrackBar.Position` is 1 or greater.
- Ensure the multiplier slider and all tuning controls remain fully enabled and interactive at `1x` when `lsfg-vk` or `MAKO` is selected.
- Maintain existing disablement behavior when the user selects the "None" engine (`imNone`) or when the "Upscalers" tool toggle in the sidebar is switched off.
- Keep backend configuration and launch behavior (Option B): at `1x` (non-adaptive, no spatial scaling), `GOVERLAY_LOSSLESS` remains `0` so layer injection is not activated, matching existing launch semantics while giving full interactive freedom in the UI.
- Update GUI test cases in `tests/gui/gui_test_cases.pas` that previously asserted toggles were disabled at `1x` to verify that controls stay enabled at `1x` under `imLsfg`/`imMako` and are only disabled when `imNone` is selected or the tool is disabled.

## Capabilities

### Modified Capabilities
- `lossless-scaling-config`: Update requirement for GUI control enablement so that tuning controls remain enabled when the multiplier is set to `1x`, and are only disabled when method is "None" or Upscalers is toggled off in the sidebar.

## Impact

- Files affected:
  - `lossless_scaling_tab.pas`: `UpdateControlsEnabled`
  - `tests/gui/gui_test_cases.pas`: `TestLosslessScalingCompactToggles` and related assertions
- No external APIs or binary dependencies affected.
