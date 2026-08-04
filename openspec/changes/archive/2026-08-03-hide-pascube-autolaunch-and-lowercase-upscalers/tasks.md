# Tasks: Hide PasCube AutoLaunch and Lowercase Preferred Upscalers

## 1. Hide PasCube Auto-Launch Menu Option

- [x] 1.1 In `sidebar_nav.pas` (`BuildSettingsMenu`), set `FForm.FCubeAutoLaunchItem.Visible := False`.

## 2. Lowercase Preferred Upscaler Options

- [x] 2.1 In `overlayunit.lfm`, update `preferredUpscalerComboBox` items to lowercase strings (`auto`, `xess`, `fsr21`, `fsr22`, `fsr4`, `dlss`).

## 3. Automated GUI Unit Tests

- [x] 3.1 In `tests/gui/gui_test_cases.pas`, add/update GUI unit tests asserting `FCubeAutoLaunchItem.Visible = False` and `preferredUpscalerComboBox.Items[0] = 'auto'`.
