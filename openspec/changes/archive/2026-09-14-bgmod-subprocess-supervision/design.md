## Context

See `proposal.md` for background and problem motivation.

In `bgmod.lpr`, diagnostic tool logging for MangoHud, OptiScaler, vkBasalt, and vkSumi is handled via `RunSubprocessLogger`, which reads lines from a pipe (`PipeFds[0]`) to filter tool output and sync logs. Previously, `bgmod` created the pipe, forked `RunSubprocessLogger`, dup2'd `PipeFds[1]` to file descriptor 2, and immediately executed the game via `execvpe`.

When run under Steam, the command passed to `bgmod` is Steam's wrapper (`steam-launch-wrapper -- .../reaper ...`). Because `execvpe` preserves the process ID, Steam's `reaper` replaces `bgmod` and inherits `RunSubprocessLogger` as a direct child. Steam's `reaper` operates with `PR_SET_CHILD_SUBREAPER` and blocks in `wait()` until all child processes terminate. Because `reaper` holds stderr (the pipe write end) open and is waiting for `RunSubprocessLogger`, while `RunSubprocessLogger` is waiting for `reaper` to exit, neither can terminate, leaving Steam displaying the "STOP" button indefinitely.

## Goals / Non-Goals

**Goals:**
- Isolate `RunSubprocessLogger` from Steam's `reaper` process tree so `reaper` has no dependency on the logger.
- Transform `bgmod` into a lightweight process supervisor that forks `GamePid` and waits for it with `fpWaitPid`.
- Ensure the pipe write descriptor is owned exclusively by the game process tree, guaranteeing natural EOF in the logger upon game exit.
- Guarantee active teardown and reaping of `LoggerPid` when `GamePid` exits.
- Forward external termination signals (`SIGTERM`, `SIGINT`) from `bgmod` to `GamePid` and `LoggerPid`.
- Preserve exact game exit status codes upon termination.

**Non-Goals:**
- Modifying the logging formats, log filtering logic, or destination directories in `RunSubprocessLogger`.
- Changing how the launch splash screen (`bgmod-splash`) is configured or displayed.
- Modifying GOverlay GUI components, configuration keys, or UI tabs.

## Decisions

### 1. Supervisor Model (Fork-and-Wait) vs. Direct `execvpe`
- **Choice**: `bgmod` forks a child process for the game (`GamePid`) and waits for it using `fpWaitPid`.
- **Rationale**: When `bgmod` forks `GamePid`, Steam's `reaper` runs inside `GamePid`. `LoggerPid` was forked earlier from `bgmod`, so `LoggerPid` is a sibling of `GamePid`, NOT a child of `reaper`. Steam's `reaper` only adopts and waits on processes inside its own subtree (Proton, Wine, game). When the game exits, `reaper` exits cleanly without being blocked by `LoggerPid`.
- **Alternatives Considered**:
  - *Double-forking the logger into a daemon*: In Linux, subreapers (`PR_SET_CHILD_SUBREAPER`) adopt orphaned descendants in their hierarchy. If `reaper` is an ancestor, double-forked orphans are still adopted by `reaper`. The supervisor model prevents `LoggerPid` from being in `reaper`'s hierarchy at all.

### 2. Immediate Pipe Write-End Isolation in Supervisor
- **Choice**: Immediately after forking `GamePid`, the parent `bgmod` restores its own stderr stream to the original stderr and closes `PipeFds[1]` and `OrigStderr`.
- **Rationale**: A UNIX pipe returns EOF to readers (`read() <= 0`) only when all open write descriptors are closed across the entire operating system. If `bgmod` keeps `PipeFds[1]` open, `RunSubprocessLogger` will never receive EOF even if the game terminates. Restoring stderr in `bgmod` guarantees that only `GamePid` and its children hold the write end.
- **Alternatives Considered**:
  - *Setting `FD_CLOEXEC` on `PipeFds[1]`*: `PipeFds[1]` must be inherited across `execvpe` into `reaper` and Proton so that stderr is captured. Setting `CLOEXEC` would close the pipe before the game can write to it.

### 3. Active Logger Teardown and Reaping
- **Choice**: When `fpWaitPid(GamePid, GameStatus, 0)` returns in `bgmod`, if `LoggerPid > 0`, `bgmod` checks if the logger is still running. If so, it sends `SIGTERM` to `LoggerPid` and waits with `fpWaitPid(LoggerPid, LoggerStatus, 0)`.
- **Rationale**: While closing the write end naturally triggers EOF in the logger, sending `SIGTERM` after game completion ensures that any edge cases (such as a hung third-party thread) do not delay game exit. `RunSubprocessLogger` already has a signal handler for `SIGTERM` (`LoggerSigHandler`) that performs final synchronization (`SyncGameDirLogsToCentral`) and flushes cleanly.

### 4. Signal Propagation
- **Choice**: `bgmod` registers handlers for `SIGTERM` and `SIGINT` that forward the signal to `GamePid` (and `LoggerPid`).
- **Rationale**: When a user clicks "STOP" or a system shutdown occurs while the game is running, Steam sends `SIGTERM` to the supervisor. Forwarding this signal ensures Proton and the game receive the cancellation promptly.

## Risks / Trade-offs

- **[Risk] Memory footprint of running `bgmod` during game session** → *Mitigation*: `bgmod` is a compiled native Free Pascal binary. Sleeping in `fpWaitPid` consumes 0% CPU and ~2MB resident memory (mostly shared system libraries), which is negligible on modern gaming systems.
- **[Risk] Handling launcher without command arguments** → *Mitigation*: If no target command is provided, `bgmod` exits immediately before forking, maintaining existing behavior.
