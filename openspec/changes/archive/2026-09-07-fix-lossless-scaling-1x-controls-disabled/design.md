## Context

See proposal.md for motivation and problem background.

In `TLosslessScalingTabHelper.UpdateControlsEnabled`, `FgActive` historically required `(FLsMultiplierTrackBar.Position > 1)`. When the user changes the multiplier to `1x`, `FgActive` becomes `False`, which disables `FLsMultiplierTrackBar` and all frame generation controls. The user is left unable to interact with the trackbar to change it back.

## Goals / Non-Goals

**Goals:**
- Decouple `FgActive` from `FLsMultiplierTrackBar.Position > 1` so that `FgActive` is `True` whenever `FInterpolationMethod in [imLsfg, imMako]`.
- Keep all controls on the Lossless Scaling tab enabled and interactive at `1x`.
- Only disable tab controls when "None" is selected (`imNone`) or when the "Upscalers" tool in the sidebar is turned off.
- Update GUI tests in `tests/gui/gui_test_cases.pas` to assert that controls remain enabled at `1x` under `imLsfg`/`imMako` and disable properly under `imNone`.

**Non-Goals:**
- Altering the backend save/launch semantics at `1x` (Option B): `SaveLosslessConfig` and `GetActiveEnvVars` continue requiring `Position > 1` (or adaptive/scaling active) to mark `GOVERLAY_LOSSLESS=1` for runtime injection.
- Redesigning the visual layout of the Lossless Scaling tab.

## Decisions

### Decision 1: Redefine `FgActive` based purely on interpolation method

In `lossless_scaling_tab.pas` within `TLosslessScalingTabHelper.UpdateControlsEnabled`:
- Change:
  ```pascal
  FgActive := (FInterpolationMethod in [imLsfg, imMako]);
  ```
- Rationale: The radio button selection (`None`, `lsfg-vk`, `MAKO`) already represents whether the engine is active or inactive. The multiplier value is a parameter of the engine, not an activation toggle for the GUI controls. Disabling the slider based on its own position trapped the user.
- Alternatives considered:
  - Keep slider enabled but disable other controls: Rejected because toggles (e.g. Allow FP16, Pacing) are still parameters for the chosen engine, and user specifically requested only disabling on "None" or Upscalers toggle.

### Decision 2: Backend runtime injection remains at >= 2x or Adaptive/Scaling (Option B)

- Keep `SaveLosslessConfig` and `GetActiveEnvVars` condition where `Position > 1` (or adaptive mode or spatial scaling) is required for `GOVERLAY_LOSSLESS = '1'`.
- Rationale: Prevents unexpected runtime activation when users just have 1x selected, while giving them full interactive control in the GOverlay UI.

### Decision 3: Update `TestLosslessScalingCompactToggles` to match the new behavior

- Update `TestLosslessScalingCompactToggles` in `tests/gui/gui_test_cases.pas`:
  - When multiplier is 1x under `imLsfg`, verify that `PerfModeToggle.Enabled` is `True` (controls stay interactive).
  - Verify that controls are disabled when `imNone` is set.

## Risks / Trade-offs

- [Risk] Existing test expecting disabled toggles at 1x will fail.
  - Mitigation: Update `TestLosslessScalingCompactToggles` to assert that toggles remain enabled at 1x under `imLsfg` and are disabled under `imNone`.
