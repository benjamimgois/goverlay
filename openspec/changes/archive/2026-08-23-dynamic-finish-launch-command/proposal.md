## Why

When configuring game profiles in GOverlay and clicking the floating action dock's "Finish" pill button (`DockFinishClick`), the Finish Configuration dialog frequently displays the global profile path (`/home/user/.local/share/goverlay/gameconfig/global/bgmod`) instead of the active game's configuration folder (`/home/user/.local/share/goverlay/gameconfig/<game>/bgmod`).

This occurs because `DockFinishClick` passes a static, cached string variable `FLaunchCommand` to `ShowFinishDialog`. `FLaunchCommand` is not updated when selecting a game card in the Games tab (`GameCardClick`), nor during MangoHud or Lossless Scaling auto-saves, nor during silent OptiScaler auto-saves. As a result, the dialog displays an outdated command string from whatever global or previous game session was loaded before.

## What Changes

- **Centralized Dynamic Launch Command Resolution**: Implement a single helper function `GetLaunchCommand: string` in `overlayunit.pas` that computes the launch command dynamically based on the current context (`FActiveGameName`, `FActiveGameIsNonSteam`, Gamemode option, and RE Engine RT workaround flag).
- **Direct Dialog Invocation**: Update `Tgoverlayform.DockFinishClick` to invoke `GetLaunchCommand` on demand when opening `ShowFinishDialog`, guaranteeing that the Finish Configuration dialog always receives the exact, current profile command.
- **Refactor Redundant Launch Command Construction**: Replace duplicate launch command building blocks across `SaveVkSumiConfig`, `SaveVkBasaltConfig`, `SaveTweaksConfig`, `saveBitBtnClick`, and `optiscaler_tab.pas` with `GetLaunchCommand`.
- **Automated Regression Tests**: Add GUI test cases in `tests/gui/gui_test_cases.pas` to assert that `GetLaunchCommand` and the Finish Configuration dialog accurately reflect the global path when no game is active, the game path when a Steam game is active, and the wrapper path when a non-Steam/Heroic game is active.

## Capabilities

### Modified Capabilities
- `finish-configuration-dialog`: Ensure the launch command passed to and displayed by the Finish Configuration dialog dynamically resolves the active profile's configuration directory.

## Impact

- `overlayunit.pas`: Declare and implement `GetLaunchCommand`, update `DockFinishClick`, unify command generation.
- `optiscaler_tab.pas`, `tweaks_md3.pas`: Clean up redundant command construction.
- `tests/gui/gui_test_cases.pas`: Add test cases verifying launch command generation across global, Steam game, and Non-Steam game contexts.
