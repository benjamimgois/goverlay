# Tasks

## 1. Wrapper Versioning

- [x] 1.1 Add `BGMOD_VERSION` constant to `bgmod.lpr` and include it in initial log output, verifying via `/tmp/bgmod.log`
- [x] 1.2 Add `BGMOD_UNINSTALLER_VERSION` constant to `bgmod-uninstaller.lpr` and include it in initial log output, verifying via `/tmp/bgmod-uninstaller.log`

## 2. Wrapper Binary Synchronization

- [x] 2.1 Implement `SyncAllGameConfigBinaries` in `bgmod_resources.pas` to iterate through all game subdirectories in `gameconfig/` and copy updated `bgmod`, `bgmod-uninstaller`, and `bgmod-splash` from the active `bgmod` template, ensuring `chmod 755` and `fgmod` symlink while preserving user configs
- [x] 2.2 Wire `SyncAllGameConfigBinaries` into `FormCreate` in `overlayunit.pas` immediately following `InitializeGlobalConfigDirectory`
- [x] 2.3 Ensure any game card click in `games_tab.pas` preserves consistent wrapper permissions and symlinks

## 3. Automated Tests & Verification

- [x] 3.1 Add unit tests in `tests/logic/logic_test_cases.pas` verifying that pre-existing game configuration directories with stale wrapper binaries are updated to match the template while preserving `bgmod.conf`, `MangoHud.conf`, and `OptiScaler.ini`
- [x] 3.2 Run test suite (`make test` or `tests/logic/test_logic`) and verify all tests pass
