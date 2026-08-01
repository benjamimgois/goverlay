# Proposal: Add OptiScaler Frame Generation (FG Input & FG Output) Controls

## Problem Statement
OptiScaler supports Frame Generation (FG), allowing users to double their in-game framerate by selecting an FG Input source and FG Output backend. Currently, GOverlay users must manually edit `OptiScaler.ini` to configure `FGInput`, `FGOutput`, and `Enabled` under the `[FrameGen]` section.

## Proposed Changes
1. **New UI ComboBoxes in OptiScaler Sub-Card**:
   - Add `fgInputComboBox` ("FG Input") with options: `auto`, `nofg`, `dlssg`, `nukems`, `fsrfg`, `upscaler`, `fsrfg30`.
   - Add `fgOutputComboBox` ("FG Output") with options: `auto`, `nofg`, `fsrfg`, `xefg`, `nukems`.
   - Position these comboboxes directly below "File name" and "Preferred upscaler" in Row 2.

2. **Automatic `[FrameGen] Enabled` Logic**:
   - When saving `OptiScaler.ini`, if either `FGInput` or `FGOutput` is set to any value other than `'auto'`, set `[FrameGen] Enabled` to `'true'`.
   - If both `FGInput` and `FGOutput` are `'auto'`, set `[FrameGen] Enabled` to `'auto'`.

3. **Settings Persistence**:
   - Extend `TOptiScalerSettings` in `overlay_config.pas` with `FGInputItemIndex` and `FGOutputItemIndex`.
   - Update `LoadOptiScalerConfig` and `SaveOptiScalerConfigCore` to parse and persist `FGInput` and `FGOutput` in `OptiScaler.ini`.

## Impact
- Enables GUI configuration of Frame Generation in OptiScaler.
- Automatically toggles Frame Generation on when non-default FG inputs/outputs are selected.
- Enhances GOverlay's upscaling and framegen feature set.
