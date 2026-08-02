## 1. UI Structure & Reparenting

- [x] 1.1 Reparent ImGUI menu controls (`menuscaleTrackBar`, `menuscalevalueLabel`, `mark1Label..mark3Label`, `shortcutkeyLabel`, `FOsShortcutCaptureBtn`) from `FOsImgSec` to `FOsOptiSec` in `optiscaler_tab.pas`.
- [x] 1.2 Hide `FOsImgSec` sub-card panel.
- [x] 1.3 Add sub-headers ("Main", "Spatial Upscaler", "Temporal Upscaler") inside `FOsOptiSec`.

## 2. Reflow & Layout Calculation

- [x] 2.1 Update `ReflowOptiScalerTab` in `optiscaler_tab.pas` to set `FOsOptiSec` width to ~67% and `FOsFakeSec` width to ~33%.
- [x] 2.2 Calculate 3 equal sub-columns inside `FOsOptiSec` and position controls vertically under Main, Spatial Upscaler, and Temporal Upscaler.
- [x] 2.3 Add vertical divider line drawing in `FOsOptiSec.OnPaint` between the 3 sub-columns.

## 3. Build & Verification

- [x] 3.1 Compile GOverlay with `lazbuild --build-mode=Release` to verify zero build errors.
- [x] 3.2 Verify visual layout and control functionality in OptiScaler tab.
