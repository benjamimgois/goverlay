# Capability: Logging and Diagnostics

## Requirements

### Requirement: Test-Aware Stdout Interception
`InstallStdoutHook` in `apputils.pas` SHALL NOT install stdout or stderr pipe hooks when `GOVERLAY_TEST=1` is set in the process environment or when running test runner binaries.

#### Scenario: Running test binaries
- **WHEN** a test runner binary is executed
- **THEN** `InstallStdoutHook` skips creating pipe threads and file descriptor redirection
- **AND** standard I/O writes flow directly to terminal output streams without buffering limits

### Requirement: File Descriptor Close-On-Exec
All redirected descriptors and pipe file descriptors created by `InstallStdoutHook` SHALL have the `FD_CLOEXEC` flag enabled to prevent leaking into child processes or across `execv` invocations.

#### Scenario: Re-executing process with active hooks
- **WHEN** a process with installed pipe hooks executes `execv`
- **THEN** the pipe descriptors are automatically closed on exec
- **AND** child processes do not inherit dangling pipe descriptors
