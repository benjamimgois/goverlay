## Context

In `apputils.pas`:
`InstallStdoutHook` is called during the unit's `initialization` block. It duplicates stdout (fd 1) and stderr (fd 2), creates a pipe, redirects fd 1 and 2 to the write end of the pipe, and spawns `TLogPipeThread` to read from the pipe and write back to the saved original descriptors while capturing log entries into `GGlobalLogList`.

When running in test harnesses (`tests/gui/gui_tests`), `test_isolation.pas` calls `execv('/proc/self/exe')`. The `TLogPipeThread` is killed by `execv`, but the open pipe fds survive across `execv`. The child re-runs `InstallStdoutHook`, creating a cascaded pipe attached to a dead end. When test output exceeds 64 KiB, the writes block and hang forever.

## Goals / Non-Goals

**Goals:**
- Skip `InstallStdoutHook` when `GetEnvironmentVariable('GOVERLAY_TEST') = '1'`.
- Set `FD_CLOEXEC` on `FOldStdoutFd`, `FOldStderrFd`, and pipe fds using `FpFcntl(fd, F_SETFD, FD_CLOEXEC)`.
- Ensure `make test-gui` and `make test-logic` execute to completion and output their full test reports.

**Non-Goals:**
- Altering the log capture format in production GOverlay runs.

## Decisions

### 1. Skip Hook on `GOVERLAY_TEST=1` and Set `FD_CLOEXEC`
- **Choice**:
  In `apputils.pas`:
  ```pascal
  procedure InstallStdoutHook;
  var
    PipeFds: array[0..1] of cInt;
  begin
    if FPipeInstalled then Exit;
    if GetEnvironmentVariable('GOVERLAY_TEST') = '1' then Exit;
    FPipeInstalled := True;

    FOldStdoutFd := fpDup(1);
    FOldStderrFd := fpDup(2);
    if FOldStdoutFd >= 0 then FpFcntl(FOldStdoutFd, F_SETFD, FD_CLOEXEC);
    if FOldStderrFd >= 0 then FpFcntl(FOldStderrFd, F_SETFD, FD_CLOEXEC);

    if fpPipe(PipeFds) = 0 then
    begin
      FpFcntl(PipeFds[0], F_SETFD, FD_CLOEXEC);
      FpFcntl(PipeFds[1], F_SETFD, FD_CLOEXEC);
      fpDup2(PipeFds[1], 1);
      fpDup2(PipeFds[1], 2);
      fpClose(PipeFds[1]);

      TLogPipeThread.Create(PipeFds[0], FOldStdoutFd);
    end;
  end;
  ```
- **Rationale**: Completely prevents test interference while also securing production descriptor inheritance.

## Risks / Trade-offs

- None identified.
