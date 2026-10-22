# Tasks

## 1. Native ELF Mock Compilation in Logic Tests

- [x] 1.1 In `tests/logic/logic_test_cases.pas`, replace the `/bin/true` copy in `TestBgmodNativeLinuxResolution` with a compiled Free Pascal minimal dummy program (`program DummyGame; begin Halt(0); end.`) to prevent multicall Coreutils failures when invoked as `eurotrucks2`.
- [x] 1.2 Run `make test-logic` to verify that `TestBgmodNativeLinuxResolution` compiles and passes cleanly with exit code 0.

## 2. Launch Splash Test Environment Hardening

- [x] 2.1 In `tests/logic/logic_test_cases.pas`, review and strengthen `TestBgmodLaunchSplashGameTitleAndReShade` to ensure mock script execution and asynchronous file polling operate reliably in headless build environments.
- [x] 2.2 Run headless test verification (`DISPLAY="" WAYLAND_DISPLAY="" make test-logic`) and verify full test suite passes with 0 failures and 0 errors.
