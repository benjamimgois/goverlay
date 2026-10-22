## 1. Directory Cleanup Core Logic

- [x] 1.1 Implement `CleanDirectoryPreservingBackups` and `IsDirectoryEmpty` in `overlay_config.pas` to recursively clean directories while preserving non-empty `backups/` folders and pruning empty ones
- [x] 1.2 Update `THomeTabHelper.ClearConfigBtnClick` in `home_tab.pas` to use `CleanDirectoryPreservingBackups` across data and configuration paths

## 2. Strings and UI Confirmation

- [x] 2.1 Update `rsClearConfigPrompt` in `goverlay_strings.pas` to inform users that application settings will be reset while game backups remain preserved

## 3. Automated Tests and Verification

- [x] 3.1 Add unit tests in `tests/logic/logic_test_cases.pas` covering: preserving non-empty `backups/` subfolders, deleting config files outside `backups/`, pruning empty `backups/` subfolders, and removing empty parent directories
- [x] 3.2 Compile and run the test suite (`./tests/logic/logic_tests`) to verify that all test cases pass without regressions
