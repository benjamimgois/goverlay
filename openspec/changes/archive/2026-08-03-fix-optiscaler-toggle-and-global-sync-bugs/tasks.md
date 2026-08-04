# Tasks: OptiScaler Toggle and Global Sync Fixes

## 1. Driver Constraint Re-enforcement & MESA Defaults

- [x] 1.1 In `sidebar_nav.pas` (`ApplyToolEnabledState`), re-evaluate `nvidiaRadioButton.Checked` when enabling OptiScaler (`AToolIdx = 2`, `AEnabled = True`), setting `spoofCheckBox.Enabled := False`, `forcereflexCheckBox.Enabled := False`, and `reflexComboBox.Enabled := False`.
- [x] 1.2 In `sidebar_nav.pas` / `optiscaler_tab.pas`, apply MESA recommended Reflex defaults when OptiScaler is enabled and `mesaRadioButton.Checked` is True.

## 2. Immediate Global Profile OptiScaler Sync

- [x] 2.1 In `sidebar_nav.pas` (`NavToolToggleClick`), add immediate file sync to `gameconfig/global/` when `Idx = 2` (OptiScaler) is toggled `ON` in global mode (`FActiveGameName = ''`).

## 3. GUI Tests

- [x] 3.1 In `tests/gui/gui_test_cases.pas`, add unit test `TestOptiScalerToggleNvidiaReEnableState` verifying that toggling OptiScaler OFF and ON with NVIDIA selected leaves `spoofCheckBox` and `forcereflexCheckBox` disabled.
- [x] 3.2 In `tests/gui/gui_test_cases.pas`, add unit test `TestGlobalOptiScalerToggleSync` verifying immediate population of `gameconfig/global/` upon toggling OptiScaler ON in global mode.
