## Why

The Lossless Scaling tab currently displays three separate cards, which creates vertical clutter. Additionally, the Multiplier setting is currently a ComboBox rather than an intuitive TrackBar, and the DLL file path input lacks a clear visual status indicator label for locating or missing `Lossless.dll`. Consolidating the cards, upgrading the Multiplier to a 1x-10x slider, adding the program logo and visual status feedback will create a much cleaner and more responsive user experience.

## What Changes

- **LossLess Scaling Card & Logo**:
  - Rename first card title from "DLL file path" to "LossLess Scaling".
  - Add the official Lossless Scaling duck comparison logo (`assets/icons/lossless_scaling.png`) on the left side of the card.
  - Position the DLL path edit and Browse button to the right of the logo.
  - Position status label (`FLsDllStatusLabel`) below the edit:
    - Located: Green `"● DLL file located"` with normal/greenish edit background.
    - Missing: Red `"● Install Lossless scaling on steam or point the correct file path"` with alert reddish edit background and border.
- **Card Consolidation (Option 2 Layout)**:
  - Merge the "Hardware & Pacing" card directly into the "Configuration" card.
  - **Row 1 (Sliders)**: Multiplier TrackBar (1x to 10x) on left | Flow Scale TrackBar (25% to 100%) on right.
  - **Row 2 (Toggles)**: 3-column row for Performance Mode, HDR Mode, and Disable FP16 / Half-Precision checkboxes.
  - **Row 3 (Dropdowns)**: Pacing Mode dropdown on left | Target GPU Device dropdown on right.
- **Multiplier TrackBar Control**:
  - Replace `TComboBox` with `TTrackBar` with static discrete positions from 1 to 10.
  - Position 1 represents 1x (Disabled / no framegen), which grays out downstream configuration controls and sets `GOVERLAY_LOSSLESS=0`.
  - Positions 2-10 represent 2x to 10x frame multipliers with dynamic badges (e.g. `2x (Double FPS)`, `3x (Triple FPS)`, `4x (Quadruple FPS)`).

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `lossless-scaling-tab`: Card consolidation, 1x-10x Multiplier TrackBar, LossLess Scaling logo and DLL status label.

## Impact

- `lossless_scaling_tab.pas`: UI layout creation, event wiring, and reflow calculations.
- `assets/icons/lossless_scaling.png`: Application logo icon.
- `tests/gui/gui_test_cases.pas`: Updates GUI test cases to interact with `MultiplierTrackBar` instead of `MultiplierComboBox`.
