## Context

Tab configuration loaders in GOverlay currently check file existence before clearing control states:
- `LoadMangoHudConfig` in `mangohud_ui.pas` does `if not FileExists(MANGOHUDCFGFILE) then Exit;` BEFORE `ResetMangoHudControls;`.
- `LoadVkBasaltConfig` in `overlayunit.pas` does `if not FileExists(VKBASALTCFGFILE) then Exit;` BEFORE clearing `acteffectsListBox` and resetting trackbars.
- `LoadVkSumiConfig` in `overlayunit.pas` exits early when `LoadVkSumiConfig` returns `False` before resetting trackbars and checkboxes.

This architecture causes stale settings to persist on UI controls when switching to a profile that has no config file for that tool.

## Goals / Non-Goals

**Goals:**
- Move control reset execution (`ResetMangoHudControls`, `acteffectsListBox.Items.Clear`, trackbar resets) to occur unconditionally before checking `FileExists(...)` in `LoadMangoHudConfig`, `LoadVkBasaltConfig`, and `LoadVkSumiConfig`.
- Update MD3 value labels (`FVkCasValLbl`, `FVkFxaaValLbl`, `FVkSmaaValLbl`, `FVkDlsValLbl`) when resetting vkBasalt controls.
- Add GUI tests covering missing configuration files across MangoHud, vkBasalt, and vkSumi.

**Non-Goals:**
- Changing file reading or format parsing logic in `overlay_config.pas`.

## Decisions

### 1. Unconditional Control Reset Execution
- **Decision**: In `LoadMangoHudConfig`, execute `ResetMangoHudControls` as the first step before checking `FileExists(MANGOHUDCFGFILE)`.
- **Decision**: In `LoadVkBasaltConfig`, move the trackbar resets, `acteffectsListBox.Items.Clear`, and MD3 label resets above `if not FileExists(VKBASALTCFGFILE) then Exit;`.
- **Decision**: In `LoadVkSumiConfig`, add a reset helper for vkSumi trackbars and checkboxes to run before `if not overlay_config.LoadVkSumiConfig(...) then Exit;`.

## Risks / Trade-offs

- [Risk] Resetting controls unconditionally means UI will display default/unselected states when opening a profile with missing config. → Mitigation: This is the expected and correct behavior when a profile has no saved settings.
