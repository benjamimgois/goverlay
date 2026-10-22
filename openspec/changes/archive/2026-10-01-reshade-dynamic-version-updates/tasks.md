# Tasks

## 1. ReShade Version Resolution & Runtime Installation

- [x] 1.1 Implement `GetReShadeInstalledVersion` in `optiscaler_update.pas` to read `~/.local/share/goverlay/reshade/version.txt` with graceful fallback to `6.4.0` if `ReShade64.dll` exists, and verify via unit test.
- [x] 1.2 Implement `GetReShadeLatestRemoteVersion(out AUrl: string)` in `optiscaler_update.pas` to query official GitHub tags (`crosire/reshade`) with fallback to parsing `reshade.me` download links and safe baseline fallback, and verify version/URL resolution via unit test.
- [x] 1.3 Update `CheckAndInstallReShade` in `optiscaler_update.pas` to dynamically fetch the resolved Add-on installer URL, write `version.txt` upon successful extraction, add explicit completion logging, and call `Flush(Output)` before external process execution.

## 2. UI Integration & Status Display

- [x] 2.1 Update `RefreshStatus` in `reshade_tab.pas` to dynamically display the installed ReShade version via `GetReShadeInstalledVersion` instead of static `'6.4 (Add-on Edition)'`.
- [x] 2.2 Update `RefreshHomeOptiStatus` in `home_tab.pas` to display the dynamic ReShade version in the Libraries card row on the Home tab.
- [x] 2.3 Ensure `OnUpdateBtnClick` in `reshade_tab.pas` executes `CheckAndInstallReShade(True, ...)` and refreshes UI labels and button states upon completion.

## 3. Test Suites & Verification

- [x] 3.1 Add test cases to `tests/logic/logic_test_cases.pas` validating `GetReShadeInstalledVersion`, version persistence, and remote tag resolution.
- [x] 3.2 Add test cases to `tests/gui/gui_test_cases.pas` validating ReShade version label rendering in both ReShade tab and Home tab.
- [x] 3.3 Execute logic and GUI test suites (`./tests/logic/run_tests.sh` and `./tests/gui/run_tests.sh`) and verify all tests pass without regressions.
