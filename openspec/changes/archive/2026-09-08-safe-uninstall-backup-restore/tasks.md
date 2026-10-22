## 1. Uninstaller Environment and Backup Path Resolution

- [x] 1.1 Update `bgmod-uninstaller.lpr` to read `BGMOD_BACKUPS_DIR` and `BGMOD_CONFIG_DIR` environment variables for resolving `BackupsDir`, falling back to local binary path.
- [x] 1.2 Update `bgmod-uninstaller.lpr` to avoid deleting native Streamline DLLs (`sl.common.dll`, `sl.interposer.dll`, `sl.pcl.dll`) if no backup is found unless confirmed as mod-placed.
- [x] 1.3 Compile `bgmod-uninstaller` binary with `fpc bgmod-uninstaller.lpr` and verify exit code 0.

## 2. Invert Uninstall Sequence and Pass Context in GOverlay GUI

- [x] 2.1 Update `GameCardUninstallClick` in `games_tab.pas` to execute `bgmod-uninstaller` across candidate directories with `BGMOD_CONFIG_DIR` and `BGMOD_BACKUPS_DIR` set, before calling `DeleteDirectory(GameCfgDir)`.
- [x] 2.2 Delete `GameCfgDir` only after the uninstaller invocations finish, ensuring backups remain intact during the restoration phase.

## 3. Automated Tests and Verification

- [x] 3.1 Add automated test in `tests/gui/gui_test_cases.pas` verifying that triggering "Uninstall changes" on a game with native Streamline backups restores native DLLs and cleans mod artifacts before deleting the config directory.
- [x] 3.2 Run test suite `./tests/gui/gui_tests --all --format=plain` and `./tests/logic/logic_tests --all --format=plain` and verify all tests pass.
