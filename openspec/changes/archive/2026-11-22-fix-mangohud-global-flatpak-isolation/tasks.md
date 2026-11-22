# Tasks

## 1. Steam Flatpak Global Mirror Isolation

- [x] 1.1 Guard the Steam Flatpak `MangoHud.conf` mirroring blocks in `SaveMangoHudConfigCore` (`overlay_config.pas`, both standard save and `fps_only` shortcut) with `if Settings.ActiveGameName = '' then`, and verify the project compiles cleanly.
- [x] 1.2 Add unit tests in `tests/logic/logic_test_cases.pas` verifying that per-game `SaveMangoHudConfigCore` saves (standard and `fps_only`) do not overwrite `.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf`, while global saves (`ActiveGameName = ''`) still mirror to it; run the logic test suite and verify all tests pass.

## 2. Profile Context Synchronization & Auto-Save Debounce

- [x] 2.1 Cancel any pending `autoSaveTimer` (`autoSaveTimer.Enabled := False`) before changing `FActiveGameName` / `MANGOHUDCFGFILE` in `GameCardClick` (`games_tab.pas`), `GamesEmptySpaceClick` (`games_tab.pas`), and `gamesLabelClick` (`overlayunit.pas`), and call `LoadMangoHudConfig` when returning to global mode (`gamesLabelClick`, `GamesEmptySpaceClick`); verify the project compiles cleanly.
- [x] 2.2 Add GUI regression tests in `tests/gui/gui_test_cases.pas` verifying that editing MangoHud in a game profile and returning to global mode reloads global controls (including `logfolderEdit.Text`) and cancels pending `autoSaveTimer` without leaking the game's `output_folder` into global `MangoHud.conf`; run the GUI test suite and verify all tests pass.
