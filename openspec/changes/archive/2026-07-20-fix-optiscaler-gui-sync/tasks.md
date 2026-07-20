## 1. Synchronous Save on GPU Driver Change

- [x] 1.1 Add `SaveOptiScalerConfig;` call to `Tgoverlayform.mesaRadioButtonChange` (overlayunit.pas)
- [x] 1.2 Add `SaveOptiScalerConfig;` call to `Tgoverlayform.nvidiaRadioButtonChange` (overlayunit.pas)

## 2. Consistently Update UI and Save Button in Global Mode

- [x] 2.1 Remove `if FActiveGameName <> '' then` guard around `ApplyToolEnabledState(2, FNavToolEnabled[2])` and `SetSaveBtnEnabled` in `Tgoverlayform.optiscalerLabelClick` (overlayunit.pas)
- [x] 2.2 Remove `if FActiveGameName <> '' then` guard around `ApplyToolEnabledState(1, FNavToolEnabled[1])` and `SetSaveBtnEnabled` in `Tgoverlayform.vkbasaltLabelClick` (overlayunit.pas)
- [x] 2.3 Remove `if FActiveGameName <> '' then` guard around `ApplyToolEnabledState(3, FNavToolEnabled[3])` and `SetSaveBtnEnabled` in `Tgoverlayform.tweaksLabelClick` (overlayunit.pas)

## 3. Verification

- [x] 3.1 Verify clean compile with `make`
