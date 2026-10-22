## Context

See proposal.md for motivation. GOverlay supports per-game profiles stored in `~/.local/share/goverlay/gameconfig/<GameName>/`, which contain `bgmod.conf`, `goverlay.vars`, and `backups/`. When a game has native libraries that clash with mods (such as Streamline's `sl.common.dll` in God of War Ragnarök), `bgmod` stores the pre-mod native libraries in `backups/`. In the GUI's `GameCardUninstallClick` handler, `DeleteDirectory(GameCfgDir, False)` was called prior to invoking the uninstaller, destroying `backups/`. Furthermore, `bgmod-uninstaller` was called without knowledge of the per-game `backups/` directory, causing it to fall back to deleting native Streamline DLLs.

## Goals / Non-Goals

**Goals:**
- Invert the sequence in `GameCardUninstallClick` so that the uninstaller runs and restores all backups before deleting `GameCfgDir`.
- Pass `BGMOD_CONFIG_DIR` and `BGMOD_BACKUPS_DIR` as environment variables when executing `bgmod-uninstaller`.
- In `bgmod-uninstaller.lpr`, read `BGMOD_BACKUPS_DIR` and `BGMOD_CONFIG_DIR` from environment variables before falling back to `ParamStr(0) + 'backups'`.
- Ensure `bgmod-uninstaller.lpr` never deletes original game files when backups are missing, and only removes files that are confirmed mod artifacts.

**Non-Goals:**
- Modifying how Steam handles game integrity verification.
- Changing the layout of the `backups/` directory itself.

## Decisions

### Decision 1: Run uninstaller before deleting `GameCfgDir` in `games_tab.pas`
- **Choice**: Call `bgmod-uninstaller` across all candidate target directories first. Only after all uninstallation executions finish, check if `DirectoryExists(GameCfgDir)` and delete `GameCfgDir`.
- **Rationale**: `GameCfgDir` holds the backups needed by `bgmod-uninstaller`. Deleting it beforehand is what caused the data loss.
- **Alternatives considered**: Moving backups to the game directory or `/tmp`. Rejected because keeping backups in `gameconfig/<GameName>/backups/` protects them from game updates and Steam integrity checks.

### Decision 2: Environment variables `BGMOD_CONFIG_DIR` and `BGMOD_BACKUPS_DIR`
- **Choice**: When `games_tab.pas` invokes `bgmod-uninstaller`, prepend `BGMOD_CONFIG_DIR=<GameCfgDir> BGMOD_BACKUPS_DIR=<GameCfgDir>/backups/` to the command line.
- **Rationale**: `bgmod-uninstaller` can be called from different locations (global `bgmod/`, local `gameconfig/`, or `GameDir`). Explicit environment variables eliminate guesswork.
- **Alternatives considered**: Command-line flag `--backups-dir <path>`. Environment variables are consistent with `STEAM_COMPAT_INSTALL_PATH` already used to pass target directory.

### Decision 3: Fallback safety for Streamline libraries
- **Choice**: If a backup file is missing during uninstallation, do not blindly delete `sl.common.dll`, `sl.interposer.dll`, or `sl.pcl.dll` unless `goverlay.vars` or file signatures confirm they were placed by the mod and differ from standard native sizes.
- **Rationale**: Games like God of War Ragnarök and Spider-Man require these DLLs to boot. Treating them as non-critical mod files broke the game when backups were unavailable.

## Risks / Trade-offs

- [Risk] Uninstaller fails mid-way, leaving `GameCfgDir` undeleted. → Mitigation: `GameCfgDir` remaining allows the user or GUI to retry uninstallation without having lost backups.
- [Risk] Game has multiple subdirectories with `goverlay.vars`. → Mitigation: TargetDirs iteration already handles all subdirectories; passing the game config ensures each invocation can find the common backups.
