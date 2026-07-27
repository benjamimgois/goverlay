## Context

While navigating between tabs and switching between Global Profile and Game Profiles, several GOverlay tabs can display stale UI states or reference incorrect configuration files:
1. `mangohudLabelClick` and `vkbasaltLabelClick` update config paths when `FActiveGameName <> ''`, but lack an `else` clause to explicitly reset `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, and `VKSUMICFGFILE` to global directory paths when `FActiveGameName = ''`.
2. `LoadTweaksFromFGMod` in `tweaks_md3.pas` exits early when `bgmod.conf` does not exist before calling control reset code, leaving previous game or global tweak states checked in the UI.
3. MangoHud preset selection cards do not refresh visual highlights when loading configs from disk.

## Goals / Non-Goals

**Goals:**
- Guarantee that sidebar tab click handlers (`mangohudLabelClick`, `vkbasaltLabelClick`) explicitly assign target config paths for both game-specific mode and global mode.
- Ensure `LoadTweaksFromFGMod` resets all UI checkboxes and custom environment controls before checking `FileExists(ConfigPath)`.
- Add GUI tests to verify tab path resets and Tweaks UI control clearing on missing config.

**Non-Goals:**
- Restructuring the layout of MangoHud or vkBasalt tab pages.
- Modifying underlying INI file parsing logic in `overlay_config.pas`.

## Decisions

### 1. Explicit `else` Branch in Sidebar Tab Click Handlers
- **Decision**: In `mangohudLabelClick` and `vkbasaltLabelClick` in `overlayunit.pas`, add an `else` branch when `FActiveGameName = ''` that explicitly re-assigns `MANGOHUDCFGFILE := GetGameConfigDir('') + 'MangoHud.conf'`, `VKBASALTCFGFILE := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf'`, and `VKSUMICFGFILE := IncludeTrailingPathDelimiter(GetVkSumiConfigDir()) + 'vkSumi.conf'`.

### 2. Move Control Reset Above File Check in `LoadTweaksFromFGMod`
- **Decision**: In `tweaks_md3.pas`, move the control reset logic (unchecking general, graphics, performance checkboxes, antilag, RT, Proton Vkd3d LowLatency, and clearing custom env list) to execute before `if not FileExists(ConfigPath) then Exit;`.

## Risks / Trade-offs

- [Risk] Unchecking Tweaks checkboxes on missing config might clear transient user edits if the file is suddenly deleted. → Mitigation: Controls are only reset when loading config from disk for a profile switch or tab click, which is expected behavior when a profile has no config file.
