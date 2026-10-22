## Context

See `proposal.md` and spec documents. GOverlay uses `bgmod.conf` to control which tools are injected/exported during game launches (`GOVERLAY_MANGOHUD`, `GOVERLAY_VKBASALT`, `GOVERLAY_VKSUMI`, `GOVERLAY_OPTISCALER`, `GOVERLAY_TWEAKS`). However, past implementation in `sidebar_nav.pas` treated tool toggle-off as a destructive wipe, deleting configuration files from the profile directory. Additionally, per-game launch command caching was only updated on configuration modification rather than immediate game selection.

## Goals / Non-Goals

**Goals:**
- Make tool toggling completely non-destructive for user configuration files (`MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, `bgmod.conf [Env]`).
- Ensure `bgmod` at game launch remains responsible for cleaning the game installation directory when `GOVERLAY_OPTISCALER=0`.
- Immediately update `FLaunchCommand` on game selection in `GameCardClick` so that `[✓ Finish]` works accurately on zero-edit workflows.
- Protect `gameconfig/global/` from being overwritten by template files on startup.
- Guard shutdown auto-save triggers.

**Non-Goals:**
- Rewriting the `bgmod` binary launcher logic (its existing `SafeCleanOrRestore` logic is already functional).
- Changing how presets work or how game cards are rendered.

## Decisions

### 1. Non-destructive `NavToolToggleClick`
- **Choice**: When toggling off any tool, write `GOVERLAY_<TOOL>=0` in `bgmod.conf` and do NOT call `DeleteFile` on `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, `OptiScaler.ini`, or overwrite `[Env]` keys with 0.
- **Rationale**: The presence of the configuration file on disk does not activate the tool if `bgmod.conf` has the flag set to `0`. Keeping the file on disk allows the user to re-enable the tool later without losing their custom metrics, colors, hotkeys, or upscaler options.

### 2. Immediate Launch Command Update in `GameCardClick`
- **Choice**: Call `FLaunchCommand := GetLaunchCommand;` and `commandPaintBox.Invalidate;` inside `GameCardClick`.
- **Rationale**: When a user selects a game card to view or copy its launch options via `[✓ Finish]`, the command should immediately reflect that game's path even if the user does not edit any settings.

### 3. Exclude User Configs in `InitializeGlobalConfigDirectory`
- **Choice**: In the rsync command inside `InitializeGlobalConfigDirectory`, add `--exclude=*.conf --exclude=*.ini` in addition to existing excludes.
- **Rationale**: Ensures pristine binary/template updates do not overwrite any user configuration files in `gameconfig/global/`.

## Risks / Trade-offs

- **[Risk]** Existing test cases might have expected `MangoHud.conf` to be deleted when toggling off.
  → **Mitigation**: Update test assertions in `tests/gui/gui_test_cases.pas` to verify that `bgmod.conf` reflects `GOVERLAY_MANGOHUD=0` while `MangoHud.conf` is preserved.
