## 1. Launch Environment Helper Updates

- [x] 1.1 Update `GetMangoHudLaunchEnv`, `GetVkBasaltLaunchEnv`, `GetVkSumiLaunchEnv`, and `GetLosslessScalingLaunchEnv` in `overlayunit.pas` to return empty strings whenever `not FNavToolEnabled[i]`, in both global and game modes.
- [x] 1.2 Implement `GetTweaksLaunchEnv` in `overlayunit.pas` to export active `[Env]` variables when `FNavToolEnabled[3]` is `True` and return `''` when disabled.
- [x] 1.3 Update `PreviewBtnClick` and `AutoLaunchCube` in `overlayunit.pas` to incorporate `GetTweaksLaunchEnv` and ensure previews respect tool enabled states.

## 2. Automated Tests and Verification

- [x] 2.1 Add GUI tests in `tests/gui/gui_test_cases.pas` verifying that all launch environment helper functions return empty strings when disabled and correct flags when enabled in global mode.
- [x] 2.2 Run full project test suite (`make test`) to verify that all unit and GUI tests pass.
