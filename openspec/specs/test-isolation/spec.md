# Capability: Test Environment Isolation

## Requirements

### Requirement: Sandbox Path Safety Verification
`test_isolation.pas` SHALL verify that the isolated test environment directory is strictly located inside the system temporary directory with the `goverlay_test_` prefix before initializing or cleaning up the environment.

#### Scenario: Running test suite with stale or invalid isolation variable
- **WHEN** a test runner starts and `HOME` points to a non-sandbox path (or an externally supplied variable points outside the temporary test directory)
- **THEN** `EnsureIsolatedEnvironment` aborts execution with a fatal error message
- **AND** no tests are run against the real user home directory

### Requirement: Safe Cleanup of Test Sandbox
`CleanupIsolatedEnvironment` SHALL only delete directories that pass strict sandbox verification (`IsSafeSandboxDir`). Under no circumstances SHALL `CleanupIsolatedEnvironment` delete the real user `$HOME`, the root directory, or any directory outside the designated temporary sandbox path.

#### Scenario: Successful test suite run
- **WHEN** all tests pass and `CleanupIsolatedEnvironment(True)` is invoked
- **AND** `FHome` is confirmed to be a temporary sandbox directory matching `GetTempDir + goverlay_test_*`
- **THEN** `CleanupIsolatedEnvironment` deletes the temporary sandbox directory and prints confirmation

#### Scenario: Invalid or unsafe directory in cleanup
- **WHEN** `CleanupIsolatedEnvironment` is called with an `FHome` that does not match the temporary sandbox pattern (e.g. real user home or empty string)
- **THEN** `CleanupIsolatedEnvironment` refuses to delete the directory and logs a warning to `StdErr`
