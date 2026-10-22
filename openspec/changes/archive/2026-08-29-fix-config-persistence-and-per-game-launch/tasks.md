## 1. Tool Toggling and Configuration Persistence

- [x] 1.1 Update `NavToolToggleClick` in `sidebar_nav.pas` to avoid deleting `MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, or clearing `[Env]` keys on toggle-off
- [x] 1.2 Update `GetGameToolEnabled` in `sidebar_nav.pas` to evaluate default tool states cleanly from `bgmod.conf` without relying on config file existence as enabling flag
- [x] 1.3 Update `InitializeGlobalConfigDirectory` in `bgmod_resources.pas` to exclude `*.conf` and `*.ini` from rsync clobbering

## 2. Per-Game Launch Command Generation

- [x] 2.1 Update `GameCardClick` in `games_tab.pas` to immediately recalculate `FLaunchCommand := GetLaunchCommand;` and invalidate `commandPaintBox`
- [x] 2.2 Verify shutdown auto-save safety by guarding `GenericControlClick` and `GenericControlChange` in `overlayunit.pas` with `if FClosing then Exit;`

## 3. Testing and Verification

- [x] 3.1 Update existing GUI test cases in `tests/gui/gui_test_cases.pas` to match non-destructive tool toggling behavior
- [x] 3.2 Add regression tests for per-game launch command generation upon card click and multi-launch persistence of disabled tool states
- [x] 3.3 Build and run the complete test suite (`lazbuild --ws=qt6 tests/gui/gui_tests.lpi && ./tests/gui/gui_tests --all --format=plain`) and verify all tests pass
