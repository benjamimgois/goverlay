# Tasks

## 1. Filter Radio Buttons Contrast

- [x] 1.1 In `mangohud_ui.pas` (`InitPerformanceTab`), update `filterRadioGroup` to set `Font.Color := TextColor` and apply stylesheet with explicit `QRadioButton { color: ...; }`
- [x] 1.2 In `mangohud_ui.pas` (`UpdatePerfCardTheme`), update `filterRadioGroup` with theme-appropriate stylesheet (white on dark, dark on light) and verify it is styled on tab switch

## 2. Key Capture Buttons Styling

- [x] 2.1 In `mangohud_ui.pas` (`UpdateVisualCardTheme`), apply standard button QSS (`QPushButton, QToolButton`) and `Font.Color` to `FVisualCaptureBtn`
- [x] 2.2 In `mangohud_ui.pas` (`UpdatePerfCardTheme`), apply standard button QSS (`QPushButton, QToolButton`) and `Font.Color` to `FLimitCaptureBtn`
- [x] 2.3 In `mangohud_ui.pas` (`UpdateExtrasCardTheme`), apply standard button QSS (`QPushButton, QToolButton`) and `Font.Color` to `FLoggingCaptureBtn`

## 3. Columns Stepper and Generic Card Selectors

- [x] 3.1 In `mangohud_ui.pas` (`InitVisualTab` & `UpdateVisualCardTheme`), set `Font.Color := TextColor` on `FColumnsMinusBtn` and `FColumnsPlusBtn` and expand stylesheet selector to `QPushButton, QToolButton`
- [x] 3.2 In `overlayunit.pas` (`UpdateGenericCardTheme`), update card handle stylesheet selector to include `QRadioButton` alongside `QCheckBox`

## 4. Verification

- [x] 4.1 Compile GOverlay with `make LAZBUILDOPTS="--ws=qt6"` and verify clean compilation without warnings
- [x] 4.2 Run test suite (`make test-logic`) and verify all tests pass
