## 1. Centralized Launch Command Helper

- [x] 1.1 In `overlayunit.pas`, declare and implement `function Tgoverlayform.GetLaunchCommand: string;` that dynamically resolves the launch command from `FActiveGameName`, `FActiveGameIsNonSteam`, Gamemode state, and RE Engine RT flag.
- [x] 1.2 In `overlayunit.pas` (`DockFinishClick`), update `ShowFinishDialog` invocation to pass `GetLaunchCommand` instead of `FLaunchCommand`.
- [x] 1.3 In `overlayunit.pas` (`SaveVkSumiConfig`, `SaveVkBasaltConfig`, `saveBitBtnClick`), `tweaks_md3.pas` (`SaveTweaksConfig`), and `optiscaler_tab.pas`, refactor manual command building to use `GetLaunchCommand`.

## 2. Automated Tests & Verification

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, add a test case verifying that `GetLaunchCommand` generates the global path in Global mode, the game-specific path when selecting a Steam game, and the unquoted wrapper path when selecting a Non-Steam/Heroic game.
- [x] 2.2 In `tests/gui/gui_test_cases.pas`, verify that opening the Finish dialog after selecting a game card passes the game-specific command without requiring a manual save.
- [x] 2.3 Run automated test suite (`make test-logic`, `make test-gui`) and ensure clean compilation and all tests passing.
