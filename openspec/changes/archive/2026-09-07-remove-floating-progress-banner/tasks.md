## 1. Remove Floating Progress Invocations

- [x] 1.1 Remove `FFloatingProgress.ShowProgress` and `FFloatingProgress.HideProgress` calls from `updateBitBtnClick` in `overlayunit.pas` and verify compilation succeeds
- [x] 1.2 Remove `FFloatingProgress.UpdateProgress` call from `ReshadeGitProgress` in `overlayunit.pas` and verify compilation succeeds

## 2. Automated Tests & Verification

- [x] 2.1 Add automated GUI test in `tests/gui/gui_test_cases.pas` verifying that initiating an update keeps `FFloatingProgress.Visible` set to `False`
- [x] 2.2 Run `make test-logic` and `make test-gui` to ensure all tests pass with zero failures
