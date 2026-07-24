## ADDED Requirements

### Requirement: Unified Local Test Entry Point

The project SHALL provide a `make test` target that builds and runs the full local test suite (logic layer and GUI wiring layer) and exits non-zero if any test fails.

#### Scenario: Developer runs make test with all tests passing
- **WHEN** the developer runs `make test` in the repository root and all tests pass
- **THEN** the command exits with status 0 and prints a per-layer test summary

#### Scenario: Developer runs make test with a failing test
- **WHEN** the developer runs `make test` and any test in any layer fails
- **THEN** the command exits non-zero and identifies the failed test by name

### Requirement: Commit-Time Test Gate

The project SHALL provide an installable git hook that runs the local test suite before a commit is finalized, blocking commits that break tests.

#### Scenario: Commit blocked by failing tests
- **WHEN** the git hook is installed and the developer runs `git commit` with failing tests
- **THEN** the commit is aborted and the failing test output is shown

#### Scenario: Commit proceeds with passing tests
- **WHEN** the git hook is installed and the developer runs `git commit` with all tests passing
- **THEN** the commit proceeds normally

#### Scenario: Emergency bypass
- **WHEN** the developer runs `git commit --no-verify`
- **THEN** the hook is skipped and the commit proceeds regardless of test results
