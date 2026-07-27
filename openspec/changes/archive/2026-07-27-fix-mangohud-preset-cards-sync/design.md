## Context

Preset layout and color theme selection states are tracked in `FActiveLayoutCard` and `FActiveColorCard` fields of `Tgoverlayform`. When switching contexts (e.g. going from a game profile to the Global Profile or another game profile), `LoadMangoHudConfig` in `mangohud_ui.pas` calls `ResetMangoHudControls`. However, `ResetMangoHudControls` does not reset `FActiveLayoutCard` or `FActiveColorCard`, nor does `LoadMangoHudConfig` trigger `UpdatePresetCardVisuals`. Consequently, card borders remain highlighted according to whatever preset was selected in the previously viewed game profile.

## Goals / Non-Goals

**Goals:**
- Clear `FActiveLayoutCard := -1` and `FActiveColorCard := -1` when resetting MangoHud controls in `ResetMangoHudControls`.
- Call `UpdatePresetCardVisuals` at the end of `LoadMangoHudConfig` to redraw card visual selection states based on the loaded configuration.
- Add GUI tests to ensure `FActiveLayoutCard` and `FActiveColorCard` clear on context switch.

**Non-Goals:**
- Changing preset layout parsing or preset card creation logic.

## Decisions

### 1. Clear Preset Selection Variables on Control Reset
- **Decision**: In `ResetMangoHudControls` in `mangohud_ui.pas`, add:
  ```pascal
  FActiveLayoutCard := -1;
  FActiveColorCard  := -1;
  ```

### 2. Trigger Visual Refresh on Config Load
- **Decision**: At the end of `LoadMangoHudConfig` in `mangohud_ui.pas`, invoke `UpdatePresetCardVisuals;` following `UpdatePerfCardTheme;`.

## Risks / Trade-offs

- [Risk] Cards will revert to unselected/neutral borders if a custom config doesn't match a predefined preset card. → Mitigation: This is the correct behavior; custom configs should not highlight predefined preset cards unless explicitly clicked or matching.
