# Capability: Process Execution Utilities

## Requirements

### Requirement: Synchronous Shell Command Execution
`ExecuteShellCommand` in `apputils.pas` SHALL execute the specified shell command using `TProcess` with `poNoConsole` and `poWaitOnExit` options, blocking until the command finishes execution before returning and freeing the process instance.

#### Scenario: Copying or creating files via shell command
- **WHEN** `ExecuteShellCommand` is called with a command (e.g. `cp -rn ...` or `ln -sf ...`)
- **THEN** `ExecuteShellCommand` blocks and waits for the child process to exit
- **AND** all file system changes performed by the command are completed before `ExecuteShellCommand` returns
