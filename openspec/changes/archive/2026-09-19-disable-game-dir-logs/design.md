# Design

## Context

See `proposal.md` for background and motivation.

When launching games through `bgmod`, the launcher binary initializes logging in three destinations:
1. System temporary file: `/tmp/bgmod.log`
2. Per-game centralized directory: `~/.local/share/goverlay/logs/<GameDirName>/bgmod.log`
3. Game root directory: `<GameDir>/bgmod.log`

Additionally, `bgmod` initializes tool-specific log files (e.g. `mangohud.log`, `optiscaler.log`, `vkbasalt.log`, etc.) in both `CentralLogDir` and `GameDir`, spawning `RunSubprocessLogger` to tee stderr output into both destinations.

`bgmod-uninstaller` follows a similar pattern, writing `bgmod-uninstaller.log` into both `/tmp/`, `CentralLogDir`, and `GameDir`.

The GOverlay UI's *"Open Log File"* action navigates exclusively to `~/.local/share/goverlay/logs/<GameDirName>/` (via `GetGameLogDir`). Writing logs into `GameDir` is completely redundant and causes anti-cheat false positives in games like *Phasmophobia*.

## Goals / Non-Goals

**Goals:**
- Eliminate all creation of `bgmod.log` and `bgmod-uninstaller.log` in `<GameDir>`.
- Eliminate creation of tool log files (`mangohud.log`, `mako.log`, `lsfg.log`, `optiscaler.log`, `dlss-enabler.log`, `vksumi.log`, `vkbasalt.log`, `reshade.log`) in `<GameDir>`.
- Streamline `RunSubprocessLogger` in `bgmod.lpr` to write standard error tool diagnostics exclusively to descriptors in `CentralLogDir`.
- Preserve diagnostic logging to `/tmp/` and `~/.local/share/goverlay/logs/<GameDirName>/`.
- Retain passive synchronization in `SyncGameDirLogsToCentral` so any logs created directly by third-party DLLs (if any) are safely preserved in the central log repository.

**Non-Goals:**
- Changing the GOverlay GUI log viewer behavior (it already points to `GetGameLogDir`).
- Removing `/tmp/` debug logs.
- Adding complex configuration UI toggles (user decided to adopt clean directories by default).

## Decisions

### Decision 1: Remove GameDir write block in `Log()` procedures
In both `bgmod.lpr` and `bgmod-uninstaller.lpr`, the `procedure Log(const Msg: string)` contains a block checking `if GameDir <> '' then AssignFile(F, IncludeTrailingPathDelimiter(GameDir) + ...);`.
- **Action**: Remove the block writing to `<GameDir>/bgmod.log` and `<GameDir>/bgmod-uninstaller.log`.
- **Rationale**: Removes the root cause of anti-cheat triggers when games scan their executable directory immediately upon launch.
- **Alternatives Considered**: Making this conditional on a `LOG_TO_GAME_DIR` flag. Rejected because central logging is already standard across GOverlay and clean game directories are strictly superior for compatibility and file integrity.

### Decision 2: Refactor `RunSubprocessLogger` and tool log initializations
In `bgmod.lpr`:
- Remove `*GameLogFile` variables (`MangoGameLogFile`, `OptiGameLogFile`, `MakoGameLogFile`, etc.).
- Remove the initialization calls `InitToolLogFile(*GameLogFile, ...)`.
- Update `RunSubprocessLogger` parameter list and loop to drop `*GameFd` handles (`MangoGameFd`, `OptiGameFd`, etc.).
- **Rationale**: Halves file descriptor allocations in the supervisor subprocess, removes unnecessary disk I/O to game directories, and simplifies signal handling and file descriptor cleanup.

### Decision 3: Keep fallback log synchronization (`SyncGameDirLogsToCentral`)
`SyncGameDirLogsToCentral` searches for third-party tool logs in `GameDir` and copies them to `CentralLogDir`.
- **Action**: Keep `SyncGameDirLogsToCentral` active before game execution and upon logger termination.
- **Rationale**: While `bgmod` itself will no longer create log files in `GameDir`, if a closed-source game mod or DLL writes a log file in its current working directory, GOverlay will still discover and archive it to central logs without interfering with execution.

## Risks / Trade-offs

- **[Risk] Users expecting logs directly in game folders** → Mitigation: Update `README.md` and documentation to remind users that logs reside in `~/.local/share/goverlay/logs/<Game>/` and can be opened directly from the GOverlay UI via "Open Log File".
- **[Risk] Regression in logger process termination or pipe closing** → Mitigation: Cleanly close all remaining centralized file descriptors on `RunSubprocessLogger` exit, maintaining existing signal handling and supervisor lifecycle patterns.
