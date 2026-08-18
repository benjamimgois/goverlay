# Tasks: Add Preview Pill and LSFG-VK Environment to 3D Preview on Lossless Scaling Tab

## 1. Floating Action Dock Configuration
- [x] 1.1 In `overlayunit.pas` (`losslessScalingTabSheetShow`), configure `FFADock.UpdateForTab(True, False, False)`.
- [x] 1.2 In `overlayunit.pas` (`optiscalerLabelClick`), set `FFADock.UpdateForTab(True, False, False)` if active tab is `losslessScalingTabSheet`.

## 2. LSFG-VK Launch Environment Helper
- [x] 2.1 In `overlayunit.pas`, declare `function GetLosslessScalingLaunchEnv: string;`.
- [x] 2.2 In `overlayunit.pas`, implement `GetLosslessScalingLaunchEnv` by querying `TLosslessScalingTabHelper(FLosslessScalingHelper).BuildEnvLine`.
- [x] 2.3 In `overlayunit.pas`, include `GetLosslessScalingLaunchEnv` in `PreviewBtnClick`, `runpascubetItemClick`, and `runvkcubeItemClick`.

## 3. Verification & Testing
- [x] 3.1 Build GOverlay with `lazbuild --build-mode=Release goverlay.lpi`.
- [x] 3.2 Add/update GUI test in `tests/gui/gui_test_cases.pas` verifying `FFADock.PreviewVisible` on `losslessScalingTabSheet`.
- [x] 3.3 Run test suites (`make test-logic`, `make test-gui`).
