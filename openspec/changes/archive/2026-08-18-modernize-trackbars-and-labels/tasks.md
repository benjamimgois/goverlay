# Tasks: Modernize TrackBars and Value Labels Across All Tabs

## 1. Global QSS Styling
- [x] 1.1 In `overlayunit.pas` (`FormShow`), add `QSlider` rules (horizontal groove, sub-page, handle, hover, and vertical groove, add-page, handle, hover) to `GlobalSS`.
- [x] 1.2 In `themeunit.pas` (`DoApplyTheme`), add `QSlider` styling support for both dark and light themes so theme toggling preserves trackbar styling.

## 2. Layout & Typography in MangoHud Visual Tab
- [x] 2.1 In `mangohud_ui.pas` (`Place` calls in `InitVisualTab`), position `alphavalueLabel` to the right of `transpTrackBar` and `fontsizevalueLabel` to the right of `fontsizeTrackBar`.
- [x] 2.2 In `mangohud_ui.pas` (`InitVisualTab`), configure `alphavalueLabel` and `fontsizevalueLabel` font with `CLR_TEXT_ACCENT` and `[fsBold]`.
- [x] 2.3 In `mangohud_ui.pas` (`ReflowVisualTab`), adjust trackbar widths and right-side coordinate positioning for `transpTrackBar`, `alphavalueLabel`, `fontsizeTrackBar`, and `fontsizevalueLabel`.

## 3. Value Label Polish Across Other Tabs
- [x] 3.1 In `overlayunit.lfm` / `vkbasalt_tab.pas`, update `casvalueLabel`, `fxaavalueLabel`, `smaavalueLabel`, and `dlsvalueLabel` font colors to `CLR_TEXT_ACCENT` and `[fsBold]`.
- [x] 3.2 In `overlayunit.lfm` / `overlayunit.pas`, update Performance tab (`afvalueLabel`, `mipmapvalueLabel`) and Extras tab (`durationvalueLabel`, `delayvalueLabel`, `intervalvalueLabel`) to `CLR_TEXT_ACCENT` and `[fsBold]`.
- [x] 3.3 In `overlayunit.lfm` / `overlayunit.pas`, update OptiScaler menu scale label (`mark2Label`) to `CLR_TEXT_ACCENT` and `[fsBold]`.

## 4. Verification & Testing
- [x] 4.1 Verify compilation and run test suites (`make test-logic`, `make test-gui` / `tests/logic/logic_tests`, `tests/gui/gui_tests`).
- [x] 4.2 Inspect visual appearance across all tabs to confirm cohesive modern trackbars and labels.
