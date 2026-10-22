## Context

When launching the 3D preview (`pascube` or `vkcube`), `Tgoverlayform.PreviewBtnClick` in `overlayunit.pas` constructs the shell command by concatenating environment variables returned by `GetMangoHudLaunchEnv`, `GetVkBasaltLaunchEnv`, `GetVkSumiLaunchEnv`, and `GetLosslessScalingLaunchEnv`.

Previously, these methods contained conditions such as `if (FActiveGameName <> '') and not FNavToolEnabled[0] then Result := '' else ...`. In global mode (`FActiveGameName = ''`), the condition evaluated to `False` and returned activation strings (`MANGOHUD=1`, `ENABLE_VKBASALT=1`, `ENABLE_VKSUMI=1`) regardless of whether the tools were toggled OFF. Furthermore, active EnvVars/Tweaks were not parameterized into Preview.

## Goals / Non-Goals

**Goals:**
- Ensure `GetMangoHudLaunchEnv`, `GetVkBasaltLaunchEnv`, `GetVkSumiLaunchEnv`, and `GetLosslessScalingLaunchEnv` return an empty string whenever their corresponding tool toggle (`FNavToolEnabled[i]`) is `False`, regardless of whether the current profile is global or game-specific.
- Provide `GetTweaksLaunchEnv` to inject active environment variables from `bgmod.conf` `[Env]` when `FNavToolEnabled[3]` is `True`, and return empty when `False`.
- Update `PreviewBtnClick` and `AutoLaunchCube` to use the unified environment helpers.

**Non-Goals:**
- Modifying how `bgmod` itself executes binary games (which already properly respects `GOVERLAY_*` flags).

## Decisions

### Decision 1: Unify Toggle Checks in Launch Env Helpers
- **Choice**: Check `if not FNavToolEnabled[toolIdx] then Exit('');` directly without scoping to `FActiveGameName <> ''`.
- **Rationale**: The sidebar toggle state `FNavToolEnabled[toolIdx]` accurately reflects whether the tool is active in the currently selected profile (global or game-specific).

### Decision 2: Add `GetTweaksLaunchEnv` for EnvVars Tab
- **Choice**: Read `bgmod.conf` `[Env]` section for the active profile, filter out internal tool flags (`MANGOHUD_CONFIGFILE`, `DXIL_SPIRV_CONFIG`, `LSFG_*`, `game-performance`), and format active variables as `KEY="VAL" `.
- **Rationale**: Allows 3D preview to accurately reflect user-defined environment variables and tweaks when EnvVars is ON, while cleanly omitting them when OFF.

## Risks / Trade-offs

- **[Risk]** Missing custom variables if `bgmod.conf` is not yet saved to disk.
  $\rightarrow$ **Mitigation**: AutoSave and save actions ensure `bgmod.conf` is in sync before launching preview.
