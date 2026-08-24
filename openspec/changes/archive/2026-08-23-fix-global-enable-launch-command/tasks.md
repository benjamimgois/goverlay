## 1. Code Implementation

- [x] 1.1 In `overlayunit.pas` (`saveBitBtnClick`), remove the branch assigning `'MangoHud will be displayed in every vulkan application'` and ensure `FLaunchCommand := GetLaunchCommand;` is executed directly.

## 2. Automated Tests & Verification

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, extend `TestDynamicLaunchCommandGeneration` to assert that when `globalenableMenuItem.Checked` is set to `True`, calling `saveBitBtnClick` and `GetLaunchCommand` still yields a valid `bgmod` executable command string instead of descriptive text.
- [x] 2.2 Run automated test suite (`make test-logic`, `make test-gui`) and ensure clean compilation and all tests passing.
