# Tasks: Add DLSS-Enabler Toggle Key Display

## 1. Control Declarations & Label Renaming

- [x] 1.1 In `overlayunit.pas` (`Tgoverlayform`), declare `dlssenablerToggleLabel: TLabel` and `dlssenablerToggleBtn: TBitBtn`.
- [x] 1.2 In `optiscaler_tab.pas` and `overlayunit.lfm`, update `shortcutkeyLabel` caption to `'Optiscaler toggle'`.
- [x] 1.3 In `optiscaler_tab.pas`, instantiate `dlssenablerToggleLabel` (Caption: `'DLSS-Enabler toggle'`) and `dlssenablerToggleBtn` (Caption: `'⌨ ` '`, `Enabled := False`).

## 2. Dynamic Visibility & Layout Reflow

- [x] 2.1 In `optiscaler_tab.pas` (`UpdateFrameGenOptionsUI`), toggle visibility of `dlssenablerToggleLabel` and `dlssenablerToggleBtn` based on `dlssenablerRadioButton.Checked`.
- [x] 2.2 In `optiscaler_tab.pas` (`ReflowOptiScalerTab`), update Y bounds for `dlssenablerToggleLabel` / `dlssenablerToggleBtn` and set `MinOptH := 315`.

## 3. Automated GUI Unit Tests

- [x] 3.1 In `tests/gui/gui_test_cases.pas`, add unit test `TestOptiscalerAndDlssEnablerToggleKeyDisplay` asserting label captions, disabled state of DLSS Enabler toggle button, and conditional visibility when toggling upscaler radio buttons.
