# Tasks

## 1. Constants and Defaults Setup

- [x] 1.1 Define `COLOR_LOAD_LOW`, `COLOR_LOAD_MED`, `COLOR_LOAD_HIGH`, and `COLOR_GOVERLAY_CYAN` in `constants.pas`.
- [x] 1.2 Update `ResetMangoHudControls` in `mangohud_ui.pas` to set default CPU and GPU load swatches to White, Orange, and Red.

## 2. Preset Theme Implementation

- [x] 2.1 Update `mangocolorBitBtnClick` (MangoHud Stock) in `overlayunit.pas` to set CPU and GPU load swatches to White, Orange, and Red.
- [x] 2.2 Update `goverlayBitBtnClick` (Goverlay) in `overlayunit.pas` to set CPU and GPU load swatches to GOverlay Cyan, Orange, and Red.
- [x] 2.3 Update `whitecolorBitBtnClick` (Simple White) and `afterburnercolorBitBtn1Click` (Old Afterburner) in `overlayunit.pas` to set all 3 load swatches to White and Pink respectively.

## 3. Testing and Verification

- [x] 3.1 Add test cases in `tests/gui/gui_test_cases.pas` verifying each preset theme sets the expected load colors for both CPU and GPU.
- [x] 3.2 Run `make test-logic` and GUI test suites to verify passing status with zero regressions.
