## 1. Process Execution Fix

- [x] 1.1 In `apputils.pas` (`ExecuteShellCommand`), add `poWaitOnExit` to `Process.Options` (`Process.Options := [poNoConsole, poWaitOnExit];`).

## 2. Verification & Testing

- [x] 2.1 Verify compilation with `lazbuild goverlay.lpi --bm=Release`.
- [x] 2.2 Run unit and regression tests with `make test-logic`.
