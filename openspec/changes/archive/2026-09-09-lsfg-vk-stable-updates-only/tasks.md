## 1. Remote Version Resolution

- [x] 1.1 In `optiscaler_update.pas`, update `GetLsfgVkLatestRemoteVersion` to match strictly on `Pos('Latest release (', Line) > 0`, removing the `Latest git version` match so development git builds and release candidates are ignored.

## 2. Automated Regression Tests

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, add a test case verifying that `GetLsfgVkLatestRemoteVersion` (or HTML parser helper) extracts the stable release version when both git autobuilds and stable releases are present in the HTML.

## 3. Verification

- [x] 3.1 Compile and run the test suite to verify the regression test and existing test suite pass.
