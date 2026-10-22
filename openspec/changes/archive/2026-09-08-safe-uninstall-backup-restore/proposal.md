## Why

When users invoke "Uninstall changes" from the game card context menu, GOverlay recursively deletes the game's configuration folder (`~/.local/share/goverlay/gameconfig/<GameName>/`) before executing the uninstaller. Because the per-game `backups/` directory lives inside this folder, all backed-up native libraries (such as Streamline's `sl.common.dll`, `sl.interposer.dll`, and `sl.pcl.dll`) are permanently destroyed before the uninstaller can restore them. Furthermore, the uninstaller is invoked from the global template directory without receiving the location of the game's backups, and falls back to treating native Streamline files as mod files, deleting them from the game directory and leaving the game unable to start.

## What Changes

- Invert the uninstallation sequence in `games_tab.pas` so that the uninstaller runs, detects, and restores all backed-up native DLLs before the game's configuration directory is removed.
- Provide the active game's configuration and backup paths to `bgmod-uninstaller` (via environment variables `BGMOD_CONFIG_DIR` and `BGMOD_BACKUPS_DIR`, or by executing the per-game uninstaller directly).
- Update `bgmod-uninstaller.lpr` to read `BGMOD_BACKUPS_DIR` and `BGMOD_CONFIG_DIR` from environment variables, ensuring it accurately locates per-game backups regardless of how it was invoked.
- Ensure `bgmod-uninstaller.lpr` and `bgmod.lpr` properly protect native game libraries during uninstallation, preventing accidental deletion of native Streamline files if backups are temporarily unavailable.

## Capabilities

### New Capabilities
- `safe-uninstall-backup-restore`: Ensures game modification uninstallation restores all original game files from backup and cleans mod artifacts before any configuration data is deleted.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas`: `GameCardUninstallClick` execution order and uninstaller invocation environment.
- `bgmod-uninstaller.lpr`: Backup path resolution from environment variables (`BGMOD_BACKUPS_DIR`, `BGMOD_CONFIG_DIR`) and safe cleanup logic.
- `bgmod.lpr`: Consistency in backup restoration and safe deletion logic when upscalers are disabled.
- Automated tests in `tests/gui/gui_test_cases.pas` covering the "Uninstall changes" flow with backed-up native files.
