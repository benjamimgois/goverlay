# Tasks

## 1. Core Cloning Logic

- [x] 1.1 Implement `CloneGlobalConfigToGame(const AGameName: string; const AGamePath: string): Boolean` in `TGamesTabHelper` or shared unit, copying `MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, `fakenvapi.ini`, `goverlay.vars`, `lsfg.toml`, `conf.toml`, and `bgmod.conf`.
- [x] 1.2 Implement rewriting of `[Env] MANGOHUD_CONFIGFILE` inside the cloned `bgmod.conf` to target the game's directory.
- [x] 1.3 Ensure `bgmod`, `bgmod-uninstaller`, `fgmod` link exist and invoke `CopyOptiScalerGameFiles` if `GOVERLAY_OPTISCALER=1` in cloned `bgmod.conf`.

## 2. Games Tab Card Menu Integration

- [x] 2.1 Add `FCloneGlobalMenuItem` to `FGameCardMenu` directly below `FOpenPrefixMenuItem` with caption "Clone global configs".
- [x] 2.2 Implement `GameCardCloneGlobalClick` handler checking existing configs on `FRightClickedCard`, prompting confirmation if existing configs are detected, executing the clone, updating badges via `UpdateGameCardBadge`, and showing notification.

## 3. Floating Dock Menu Integration

- [x] 3.1 Add "Clone global configs" item to `popsaveMenu` in `overlayunit.pas`.
- [x] 3.2 Update `popupBitBtnClick` to make the dock clone item visible only when in game mode (`FActiveGameName <> ''`).
- [x] 3.3 Implement the dock clone item click handler: prompt confirmation, clone to `FActiveGameName`, reload toggle states and active tab controls, and show notification.

## 4. Testing & Verification

- [x] 4.1 Add automated test in `tests/gui/gui_test_cases.pas` verifying that clicking "Clone global configs" on an unconfigured game copies global files, adjusts `MANGOHUD_CONFIGFILE`, and updates card badges.
- [x] 4.2 Add automated test verifying the dock menu item visibility and UI reloading behavior when cloning in game mode.
- [x] 4.3 Run full test suite (`make test_gui` / `make test_logic`) and verify clean compilation and passing tests.
