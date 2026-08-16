## Why

In `tests/common/test_isolation.pas`, the test harness re-executes itself inside a temporary sandbox folder created under `/tmp/goverlay_test_<timestamp>`. It uses `GOVERLAY_TEST_ISOLATED=1` to distinguish Phase B (the re-executed child) from Phase A (the parent). If `GOVERLAY_TEST_ISOLATED=1` is already set in the user's shell environment prior to launching the test suite, Phase B immediately sets `FHome := GetEnvironmentVariable('HOME')` (pointing to the user's real home directory) without creating a sandbox. When the test suite completes successfully, `CleanupIsolatedEnvironment(True)` calls `DeleteDirectory(FHome, False)`, wiping the user's real `$HOME` directory (as reported in issue #382).

## What Changes

- **Strict Sandbox Path Verification**:
  - Replace the generic `GOVERLAY_TEST_ISOLATED=1` indicator with an exact sandbox directory variable `GOVERLAY_TEST_SANDBOX_DIR=<path>`.
  - In Phase B of `EnsureIsolatedEnvironment`, assert that `HOME` matches `GOVERLAY_TEST_SANDBOX_DIR` and starts with the expected temp directory prefix (`GetTempDir(False) + 'goverlay_test_'`). If validation fails, abort immediately with a fatal error instead of running tests against a non-sandbox directory.
- **Safety Guard in `CleanupIsolatedEnvironment`**:
  - Introduce `IsSafeSandboxDir(const ADir: string): Boolean` verifying that `ADir` is non-empty, strictly located under `GetTempDir(False)` with the prefix `'goverlay_test_'`, and is neither the root directory (`/`) nor the real user home.
  - Refuse deletion if `FHome` fails sandbox safety validation.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `test-isolation`: Safety guarantees and strict verification preventing deletion of non-sandbox home directories during test cleanup.

## Impact

- `tests/common/test_isolation.pas`: Immune to accidental `$HOME` deletion caused by stale environment variables or misconfigurations.
