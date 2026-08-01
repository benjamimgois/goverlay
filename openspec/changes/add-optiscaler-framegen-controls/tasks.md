# Tasks: Add OptiScaler Frame Generation Controls

## Implementation Steps
- [x] 1. Update `overlay_config.pas`:
  - [x] 1.1 Add `FGInputItemIndex` and `FGOutputItemIndex` to `TOptiScalerSettings`.
  - [x] 1.2 Update `LoadOptiScalerConfig` to parse `[FrameGen] FGInput` and `[FrameGen] FGOutput`.
  - [x] 1.3 Update `SaveOptiScalerConfigCore` to write `FGInput`, `FGOutput`, and update `[FrameGen] Enabled`.
- [x] 2. Update UI in `optiscaler_tab.pas` and `overlayunit.pas`:
  - [x] 2.1 Declare `fgInputLabel`, `fgInputComboBox`, `fgOutputLabel`, `fgOutputComboBox` on form.
  - [x] 2.2 Instantiate, style, and position the new controls in `FOsOptiSec`.
  - [x] 2.3 Wire load/save synchronization in `LoadOptiScalerConfig` and `SaveOptiScalerConfig`.
- [x] 3. Build & verify:
  - [x] 3.1 Recompile with `lazbuild --build-mode=Release goverlay.lpi`.
  - [x] 3.2 Verify FrameGen selection persistence and `OptiScaler.ini` generation.
