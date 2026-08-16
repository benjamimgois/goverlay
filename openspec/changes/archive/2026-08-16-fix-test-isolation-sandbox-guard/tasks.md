## 1. Sandbox Verification & Safety Guards

- [x] 1.1 In `tests/common/test_isolation.pas`, add `IsSafeSandboxDir(const ADir: string): Boolean` helper.
- [x] 1.2 In `tests/common/test_isolation.pas` (`EnsureIsolatedEnvironment`), use `GOVERLAY_TEST_SANDBOX_DIR` and validate that `HOME` matches `GOVERLAY_TEST_SANDBOX_DIR` and `IsSafeSandboxDir(FHome)`. Abort with `Halt(2)` if invalid.
- [x] 1.3 In `tests/common/test_isolation.pas` (`CleanupIsolatedEnvironment`), guard `DeleteDirectory` with `IsSafeSandboxDir(FHome)` and emit a warning to `StdErr` if an unsafe directory is passed.
- [x] 1.4 Clear compiler hint on `Args` initialization in `EnsureIsolatedEnvironment`.

## 2. Verification & Testing

- [x] 2.1 Run unit tests with `make test-logic`.
- [x] 2.2 Run a simulated stale variable test (e.g. `GOVERLAY_TEST_SANDBOX_DIR=/tmp/nonexistent ./tests/logic/logic_tests`) and verify it aborts safely without touching `$HOME`.
