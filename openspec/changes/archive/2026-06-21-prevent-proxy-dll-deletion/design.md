## Context

Currently, GOverlay's execution wrappers (`bgmod` and the `fgmod` script) manage proxy DLLs (`dxgi.dll`, `winmm.dll`, etc.) by unconditionally backing them up or deleting them during launch and cleanup. This disrupts third-party tools like Reshade that rely on these same proxy DLL filenames, especially when GOverlay is configured to use a different proxy DLL (e.g., `winmm.dll` while Reshade uses `dxgi.dll`).

## Goals / Non-Goals

**Goals:**
- Only back up and overwrite the active proxy DLL (`DllName`) during game launch when OptiScaler is enabled.
- Restore backup files for inactive proxy DLLs if they exist, but do not delete or rename existing files that do not belong to GOverlay.
- Clean up GOverlay's proxy DLLs when disabling OptiScaler by verifying if the file in the game directory matches GOverlay's master proxy files by size, or if a GOverlay-created backup file (`.b`) exists.

**Non-Goals:**
- Managing non-proxy DLLs (e.g., `nvngx.dll`) with size verification, since these are original game files or specific supporting files.
- Modifying proxy DLL behavior for tools other than OptiScaler.

## Decisions

### 1. File Size Verification for Deletion
- **Decision:** Introduce a helper function `IsGOverlayProxyFile` in `bgmod.lpr` to check if a DLL's size matches the size of GOverlay's master DLLs (`BgmodPath/renames/<DllName>` or `BgmodPath/OptiScaler.dll`) in either the local or global `bgmod` directory.
- **Rationale:** Since GOverlay copies the DLL directly from these sources, their sizes will match exactly. Third-party files (like Reshade's `dxgi.dll`) will have different sizes, preventing accidental deletion.

### 2. Refactor Wrapper Active Proxy Backup/Cleanup Loop
- **Decision:** In `bgmod.lpr`, instead of unconditionally backing up all proxy DLLs in a loop, only back up the active `DllName`. For all other inactive proxy DLLs, safely restore their backups if they exist, or leave them untouched.
- **Rationale:** This keeps inactive proxy DLLs (like Reshade's `dxgi.dll` when OptiScaler is using `winmm.dll`) functional while the game is running.

### 3. Refactor `fgmod` Script
- **Decision:** In `data/fgmod/fgmod`, replace the unconditional `rm -f` of all proxy DLLs with a conditional logic that only removes/backs up the active proxy DLL, and preserves inactive ones unless size-matching confirms they were placed by GOverlay.
- **Rationale:** Ensures parity between the FPC wrapper (`bgmod`) and the shell script wrapper (`fgmod`).

## Risks / Trade-offs

- **Risk:** A third-party DLL could theoretically have the exact same size as GOverlay's master DLL.
  - *Mitigation:* The probability of this is extremely low given the typical size of these compiled DLLs (several hundred KB or MB).
- **Risk:** Future updates of OptiScaler change the master file sizes, making old installed files unrecognized during cleanup.
  - *Mitigation:* GOverlay updates always run the launch sequence, which will overwrite old files if the version check (`goverlay.vars`) fails. For cleanup, checking against both local and global `BgmodPath` sizes minimizes this risk.
