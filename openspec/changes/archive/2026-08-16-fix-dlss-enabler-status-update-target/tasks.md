## 1. UI Status Label Routing

- [x] 1.1 In `optiscaler_tab.pas` (`TOptiScalerTabHelper.RefreshOsStatusDots`), check `IsDlssEnablerActive` (`Assigned(dlssenablerRadioButton) and dlssenablerRadioButton.Checked`).
- [x] 1.2 In `case 0 (OptiScaler)`, only process `optLabel2` update arrow if `not IsDlssEnablerActive`. When `IsDlssEnablerActive` is True, display the installed OptiScaler version in `PURPLE` without update arrow.
- [x] 1.3 In `case 2 (DLSS Enabler)`, when `IsDlssEnablerActive` is True and `optLabel2.Visible` with `optLabel2.Hint <> ''`, format `VerCaption := VerCaption + ' → ' + optLabel2.Hint`, set font color to `CLR_UPDATE` ($0044AAFF) and dot color to `CLR_OK`.

## 2. Automated Testing & Verification

- [x] 2.1 Add/update GUI test in `tests/gui/gui_test_cases.pas` to verify that when DLSS Enabler has an update, `FOsStatVerLbls[2]` shows `<installed> → <new>` and `FOsStatVerLbls[0]` shows `<installed>` without arrow.
- [x] 2.2 Verify compilation with `lazbuild goverlay.lpi --bm=Release` and run unit tests.
