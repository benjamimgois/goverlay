## Why

When games are launched through `bgmod` on Steam (using launch options such as `"/path/to/bgmod" %command%`), the game remains marked as running in Steam (showing the blue "STOP" button) even after the player exits the game, requiring manual termination via the Steam UI.

This occurs because `bgmod` creates a pipe and forks a background stderr reader (`RunSubprocessLogger`) when tool logging is enabled, before immediately executing Steam's launch wrapper (`reaper` / `pressure-vessel` / Proton) via `execvpe`. In POSIX systems, `execvpe` replaces the process image while preserving the process ID (PID) and open file descriptors:
1. `RunSubprocessLogger` becomes an immediate child of Steam's `reaper`.
2. Steam's `reaper` sets `PR_SET_CHILD_SUBREAPER` and blocks in `wait()` until all child processes terminate.
3. Steam's `reaper` retains file descriptor 2 (the pipe's write end) open for its entire lifetime.
4. `RunSubprocessLogger` never receives EOF on the pipe (because `reaper` holds the write end open) and never detects parent termination (because `reaper` is waiting for `RunSubprocessLogger` to exit).

This creates a circular process deadlock between `reaper` and `RunSubprocessLogger`. To resolve this permanently, `bgmod` must supervise the game process lifecycle cleanly, isolating the logger from Steam's `reaper` and ensuring deterministic pipe closure and process termination upon game exit.

## What Changes

- **Supervised Process Spawning**: `bgmod` forks the game execution command (`GamePid`) instead of unconditionally replacing itself via `execvpe`.
- **Pipe Write-End Isolation**: In the supervisor parent (`bgmod`), the pipe write descriptor is closed and the original stderr is restored immediately after launching the child, ensuring only the game process tree holds the pipe write end.
- **Deterministic Logger Termination**: When the game child process exits, `bgmod` receives its termination via `fpWaitPid`, signals `RunSubprocessLogger` if needed, reaps both child processes, and exits with the game's exit code.
- **Signal Forwarding**: `bgmod` registers signal handlers for `SIGTERM` and `SIGINT` to forward termination signals to `GamePid` and `LoggerPid` if Steam requests game cancellation.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `centralized-tools-logging`: Add lifecycle and process supervision requirements ensuring that background logging processes do not deadlock with subreaper supervisors (like Steam's `reaper`) and terminate cleanly upon game process exit.

## Impact

- **Affected Code**: `bgmod.lpr` (process spawning, pipe management, supervision loop, signal forwarding).
- **Compatibility**: Fully compatible with Steam (Steam Linux Runtime / pressure-vessel / Proton), Heroic Games Launcher, Lutris, and direct execution.
- **Performance**: Negligible memory footprint (~2 MB sleeping in `waitpid` with 0% CPU) while solving process hangs.
