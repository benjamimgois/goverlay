# Tasks: Modernize Screen Placement Monitor (Option 1)

## 1. Monitor Canvas & Vector Rendering

- [x] 1.1 Declare `FVisMonitorPaintBox: TPaintBox` and anchor hit-test state variables in `mangohud_ui.pas` and verify compilation with `lazbuild -B goverlay.lpi`
- [x] 1.2 Implement `FVisMonitorPaintBoxPaint` to draw the modern bezel, dark/light display screen, stand, 8 anchor points, and the live mini-HUD anchor chip, verifying rendering geometry
- [x] 1.3 Implement mouse event handlers (`OnMouseMove`, `OnMouseDown`, `OnMouseLeave`) on `FVisMonitorPaintBox` with hover feedback and hand cursor, verifying hit-test boundaries

## 2. Synchronization and Layout Integration

- [x] 2.1 Wire anchor click events to check the corresponding `TRadioButton` (`topleftRadioButton` through `bottomrightRadioButton`) and trigger `GenericControlChange(Sender)` for auto-save
- [x] 2.2 Ensure `FVisMonitorPaintBox` repaints when configuration is loaded or reset, verifying live mini-HUD chip matches loaded position
- [x] 2.3 Reposition legacy `Image1` and standard radio buttons to be visually hidden while preserving component hierarchy and test compatibility
- [x] 2.4 Layout `offsetxSpinEdit` and `offsetySpinEdit` in a dedicated labeled container directly below `FVisMonitorPaintBox`

## 3. Verification & Test Suite

- [x] 3.1 Compile complete project with `lazbuild -B goverlay.lpi`
- [x] 3.2 Run unit and logic tests with `make test-logic` and verify all tests pass
- [x] 3.3 Run GUI test suite `./tests/gui/gui_tests` and verify all tests pass without regressions
