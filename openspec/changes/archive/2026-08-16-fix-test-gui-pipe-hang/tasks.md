## 1. Stdout Hook Protection & FD_CLOEXEC

- [x] 1.1 In `apputils.pas` (`InstallStdoutHook`), check `GetEnvironmentVariable('GOVERLAY_TEST') = '1'` and exit early if set.
- [x] 1.2 In `apputils.pas` (`InstallStdoutHook`), add `FD_CLOEXEC` to duplicated and pipe file descriptors using `FpFcntl`.

## 2. Verification & Testing

- [x] 2.1 Verify compilation with `lazbuild goverlay.lpi --bm=Release`.
- [x] 2.2 Run unit tests with `make test-logic`.
- [x] 2.3 Run full GUI test suite with `make test-gui` and verify it runs to completion without hanging.
