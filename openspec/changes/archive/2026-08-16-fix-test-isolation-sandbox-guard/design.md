## Context

`tests/common/test_isolation.pas` implements a two-phase process runner:
- **Phase A**: Creates a temporary sandbox directory in `GetTempDir(False) + 'goverlay_test_' + <timestamp>`, populates seed config files, sets `HOME` and an isolation environment variable, and re-executes itself via `execv('/proc/self/exe')`.
- **Phase B**: Identifies itself as the re-executed child, runs the test suite, and then in `CleanupIsolatedEnvironment(True)`, calls `DeleteDirectory(FHome, False)`.

If the environment already contains the isolation variable before Phase A starts, Phase B executes immediately without creating a sandbox, setting `FHome := GetEnvironmentVariable('HOME')` (the user's real home). Upon success, `DeleteDirectory(FHome, False)` recursively deletes the real user home.

## Goals / Non-Goals

**Goals:**
- Implement `IsSafeSandboxDir(const ADir: string): Boolean` in `test_isolation.pas`.
- Ensure `IsSafeSandboxDir` checks that `ADir` starts with `IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_'` and is non-empty.
- In `EnsureIsolatedEnvironment`:
  - Pass `GOVERLAY_TEST_SANDBOX_DIR=<exact_path>` from Phase A to Phase B.
  - In Phase B, verify that `GetEnvironmentVariable('GOVERLAY_TEST_SANDBOX_DIR')` is non-empty, matches `GetEnvironmentVariable('HOME')`, and passes `IsSafeSandboxDir`. If any check fails, immediately halt with an error.
- In `CleanupIsolatedEnvironment`:
  - Guard `DeleteDirectory(FHome, False)` with `IsSafeSandboxDir(FHome)`.

**Non-Goals:**
- Changing test suites logic or test cases.

## Decisions

### 1. Dedicated Sandbox Verification Function
- **Choice**:
  ```pascal
  function IsSafeSandboxDir(const ADir: string): Boolean;
  var
    TempPrefix: string;
  begin
    if ADir = '' then Exit(False);
    TempPrefix := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_';
    Result := (Pos(TempPrefix, ADir) = 1) and (Length(ADir) > Length(TempPrefix));
  end;
  ```
- **Rationale**: Direct, robust, and centralizes sandbox validation logic for both initialization and cleanup.

## Risks / Trade-offs

- None identified.
