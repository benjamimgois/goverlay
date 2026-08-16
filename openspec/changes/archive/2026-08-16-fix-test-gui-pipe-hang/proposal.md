## Why

When `make test-gui` (or `./tests/gui/gui_tests`) is executed, the process hangs indefinitely and never completes. This deadlock occurs because:
1. `apputils.pas` invokes `InstallStdoutHook` in its `initialization` section, redirecting `stdout` (fd 1) and `stderr` (fd 2) into a pipe read by `TLogPipeThread`.
2. `test_isolation.pas` then re-execs the binary via `execv('/proc/self/exe')` to apply sandbox isolation. `execv` terminates the reader thread, but leaves the file descriptors open.
3. In the re-executed child, `InstallStdoutHook` runs a second time, chaining a new pipe into the orphaned first pipe. When test output exceeds the kernel's 64 KiB pipe buffer, writing blocks and deadlocks the test runner (as reported in issue #381).

## What Changes

- **Bypass Stdout Pipe Hook in Test Mode**: In `apputils.pas` (`InstallStdoutHook`), check `GetEnvironmentVariable('GOVERLAY_TEST') = '1'`. If set, skip stdout pipe redirection so test output flows directly to standard output/stderr without background thread trapping.
- **Enable Close-On-Exec (`FD_CLOEXEC`)**: Set `FD_CLOEXEC` on `FOldStdoutFd`, `FOldStderrFd`, and pipe descriptors in `InstallStdoutHook` to prevent descriptor leakage across `execv` calls.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `logging-and-diagnostics`: Requirements for stdout/stderr log capturing behavior ensuring it does not interfere with test environments or leak file descriptors across re-exec boundaries.

## Impact

- `apputils.pas`: `InstallStdoutHook` is bypassed when `GOVERLAY_TEST=1` is set, and uses `FD_CLOEXEC` on open descriptors.
- `tests/gui/gui_tests`: `make test-gui` runs to completion cleanly without hanging.
