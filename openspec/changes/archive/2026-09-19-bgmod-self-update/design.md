# Design

## Context

`bgmod` acts as the execution wrapper in per-game directories (`~/.local/share/goverlay/gameconfig/<Game>/bgmod`). When distro packages or Flatpak runtimes are updated, the new binaries reside in system paths (`/usr/libexec/goverlay/`, `/var/lib/flatpak/...`) or the user template cache, but existing game wrappers remain untouched unless the GOverlay GUI is opened. 

## Goals / Non-Goals

**Goals:**
- Enable `bgmod` to autonomously detect when its local copy or sibling binaries (`bgmod-uninstaller`, `bgmod-splash`) are outdated relative to the master binaries.
- Implement atomic file replacement (`.tmp` + `fpChmod` + `fpRename`) to circumvent Linux `ETXTBSY` constraints on running executables.
- Re-execute the updated `bgmod` immediately via `fpexecv` so games launch with the newest logic on the first run.
- Add `"BGMod updated"` to the `bgmod-splash` checklist when an update occurred during the launch.
- Record self-update events in the central GOverlay log.

**Non-Goals:**
- Downloading binaries from remote internet servers (updates originate exclusively from locally installed packages, Flatpak, or user template cache).
- Modifying user configuration files (`.conf`, `.ini`, `.vars`).

## Decisions

### 1. Master Binary Candidate Resolution Order
`bgmod` will query master binary locations in order of precedence:
1. **System libexec directories:** `/usr/libexec/goverlay/`, `/usr/lib/goverlay/`, `/usr/local/libexec/goverlay/`
2. **Flatpak Host locations:** `/var/lib/flatpak/app/io.github.benjamimgois.goverlay/current/active/files/libexec/goverlay/`, `~/.local/share/flatpak/app/io.github.benjamimgois.goverlay/current/active/files/libexec/goverlay/`
3. **User template cache:** `~/.local/share/goverlay/bgmod/`

*Rationale*: Prioritizes package manager-delivered files while supporting Flatpak host executions and local user template caches.

### 2. Difference Detection Strategy
A binary is considered outdated if:
- The master binary `FileAge` is strictly newer than the target binary `FileAge`; OR
- The master binary `FileSize` differs from the target binary `FileSize`.

*Rationale*: Extremely fast filesystem stat check (< 1ms), avoiding unnecessary hashing overhead during game startup.

### 3. Atomic File Replacement Pattern
To avoid `ETXTBSY` ("Text file busy"):
```
Master Binary ──Copy──> <Target>.tmp ──fpChmod(0755)──> fpRename(<Target>.tmp, <Target>)
```
Applied to `bgmod`, `bgmod-uninstaller`, and `bgmod-splash` in the executing game directory.

*Rationale*: Linux permits replacing the filesystem directory entry of a running executable via `rename` without conflicting with the running process's open file handle.

### 4. Seamless Re-Execution and Recursion Guard
1. If `GetEnvironmentVariable('BGMOD_UPDATED') = '1'`, skip self-update check immediately.
2. When `bgmod` updates itself:
   - Set environment variable `BGMOD_UPDATED=1`.
   - Reconstruct arguments array `argv`.
   - Call `fpexecv(PChar(ParamStr(0)), @Args[0])`.
3. If re-exec is entered (or `BGMOD_UPDATED=1` was set), `bgmod` notes that it was updated and includes `"BGMod updated"` in the `SplashItems` list for `bgmod-splash`.

*Rationale*: Guarantees single-pass update and prevents infinite recursion while ensuring game launches with the fresh binary.

## Risks / Trade-offs

- **[Recursion Loop Risk]** → Mitigated by checking `BGMOD_UPDATED=1` before performing any master check. Once set, no further self-update checks are performed in the process tree.
- **[Read-Only / Permission Errors]** → Mitigated by error trapping: if writing `.tmp` or renaming fails, log a warning and proceed with normal execution using the existing binary without crashing the game.
- **[Launch Latency]** → Mitigated by stat-only checks without checksum hashing, taking < 1ms.
