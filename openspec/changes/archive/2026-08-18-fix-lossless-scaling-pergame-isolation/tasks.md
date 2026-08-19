## 1. Tab Activation and Save Dispatch Fixes
- [x] 1.1 In `overlayunit.pas` (`losslessScalingTabSheetShow`), load configuration and update dock/UI state cleanly without premature auto-saving.
- [x] 1.2 In `overlayunit.pas` (`optiscalerTabSheetShow`), ensure load routines run cleanly without premature auto-saving.
- [x] 1.3 In `overlayunit.pas` (`saveBitBtnClick`), position the `losslessScalingTabSheet` save check before the MangoHud save block with an early `Exit`.

## 2. Directory Resolution Alignment
- [x] 2.1 In `lossless_scaling_tab.pas` (`WriteLsfgTomlConfig`), resolve global default output path to `GetGameConfigDir('')`.

## 3. Testing and Verification
- [x] 3.1 In `tests/gui/gui_test_cases.pas`, add test case verifying that setting Lossless Scaling values in Global mode does not overwrite a game profile, and that setting game profile values does not overwrite Global mode.
- [x] 3.2 Run test suites (`make test-logic`, `make test-gui`) and compile release binary.
