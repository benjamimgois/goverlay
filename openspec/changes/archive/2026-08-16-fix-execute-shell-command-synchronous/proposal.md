## Why

In `apputils.pas`, `ExecuteShellCommand` creates and executes a `TProcess` with `Process.Options := [poNoConsole]`, omitting `poWaitOnExit`. Because of this, shell operations such as copying configuration files (`cp`), creating symlinks (`ln -sf`), and copying binaries/templates execute asynchronously in a detached child process without waiting for completion. Callers proceed immediately, which leads to race conditions when reading files or verifying their existence right after the call (e.g. intermittent failure in `TGoverlayGuiTests.TestGlobalOptiScalerToggleSync` as reported in issue #387).

## What Changes

- **Synchronous Process Execution**: In `apputils.pas`, update `ExecuteShellCommand` to include `poWaitOnExit` in `Process.Options` (`[poNoConsole, poWaitOnExit]`). This guarantees that file operations, symlink creations, and shell commands complete before `ExecuteShellCommand` returns and frees the process.
- **Flaky Test Elimination**: Ensures that tests and runtime procedures asserting the existence or state of files immediately after `ExecuteShellCommand` run deterministically without race conditions.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `process-execution`: Requirements for synchronous shell command execution in `ExecuteShellCommand`.

## Impact

- `apputils.pas`: `ExecuteShellCommand` waits for process termination before returning and destroying `TProcess`.
- `tests/gui/gui_test_cases.pas`: `TestGlobalOptiScalerToggleSync` runs deterministically without flakiness.
