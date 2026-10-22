# Proposal: Fix Preview Launch Environment to Honor Global Tool Toggles

## Why

When tools (MangoHud, vkBasalt, vkSumi, Lossless Scaling, and EnvVars/Tweaks) are toggled OFF in global mode (`FActiveGameName = ''`), clicking the Preview button (`pascube` / `vkcube`) still launches the 3D demo with those tools enabled.

This occurs because `GetMangoHudLaunchEnv`, `GetVkBasaltLaunchEnv`, and `GetLosslessScalingLaunchEnv` in `overlayunit.pas` only check if the tool is disabled when `FActiveGameName <> ''` (game mode). In global mode, they unconditionally inject activation environment variables (`MANGOHUD=1`, `ENABLE_VKBASALT=1`, `ENABLE_VKSUMI=1`). Additionally, `PreviewBtnClick` does not pass active `[Env]` variables when EnvVars is enabled or suppress them when disabled.

## What Changes

- Update `GetMangoHudLaunchEnv`, `GetVkBasaltLaunchEnv`, `GetVkSumiLaunchEnv`, and `GetLosslessScalingLaunchEnv` in `overlayunit.pas` to check `not FNavToolEnabled[i]` unconditionally (in both global and game-specific modes).
- Add `GetTweaksLaunchEnv` to `overlayunit.pas` to export active `[Env]` variables from `bgmod.conf` to Preview when EnvVars is enabled (`FNavToolEnabled[3] = True`), and return empty when disabled (`FNavToolEnabled[3] = False`).
- Update `PreviewBtnClick` and `AutoLaunchCube` to use the unified launch environment helpers.
- Add automated GUI tests verifying that Preview launch environment strings respect toggle OFF states in both global and per-game modes.

## Capabilities

### Modified Capabilities
- `config-persistence-and-tool-toggling`: Ensure 3D Preview (`pascube` / `vkcube`) strictly respects the enabled/disabled toggle state of all overlay tools in both global and per-game contexts.

## Impact

- Affected files: `overlayunit.pas`, `tests/gui/gui_test_cases.pas`.
- No breaking changes.
