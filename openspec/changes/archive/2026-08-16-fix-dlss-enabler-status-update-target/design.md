## Context

On the Upscalers tab, `TOptiScalerTabHelper.RefreshOsStatusDots` (in `optiscaler_tab.pas`) updates the 6 status indicators in the Software Status card (OptiScaler, DLSS/FSR/XeSS, DLSS Enabler, FakeNVAPI, Streamline SDK, OptiPatcher).

When background update checking (`TOptiUpdateThread.SyncUpdateUI`) detects an update while DLSS Enabler is active, it sets `optLabel2.Hint` to the new tag (e.g. `4.8.13.19`) and makes `optLabel2.Visible := True`. However, `RefreshOsStatusDots` currently associates `optLabel2` exclusively with row 0 (OptiScaler). Consequently, OptiScaler's label gets formatted as `stable-0.9.4 → 4.8.13.19`, and DLSS Enabler's row remains static at `4.8.12`.

## Goals / Non-Goals

**Goals:**
- In `RefreshOsStatusDots`, distinguish whether DLSS Enabler is active (`IsDlssEnablerActive := Assigned(dlssenablerRadioButton) and dlssenablerRadioButton.Checked`).
- When `IsDlssEnablerActive` is True and `optLabel2` has an update, apply `→ NewTag` and `CLR_UPDATE` to `FOsStatVerLbls[2]` (DLSS Enabler), keeping `FOsStatVerLbls[0]` (OptiScaler) in `PURPLE` with its installed version.
- When `IsDlssEnablerActive` is False and `optLabel2` has an update, apply `→ NewTag` and `CLR_UPDATE` to `FOsStatVerLbls[0]` (OptiScaler).
- Add automated GUI test coverage validating both rows when a DLSS Enabler update is found.

**Non-Goals:**
- Changing background release downloading or parsing algorithms in `optiscaler_update.pas`.

## Decisions

### 1. Route `optLabel2` update notifications based on active upscaler mode
- **Choice**: In `TOptiScalerTabHelper.RefreshOsStatusDots`:
  - For `case 0 (OptiScaler)`: only check `optLabel2.Visible` when `not IsDlssEnablerActive`. If `IsDlssEnablerActive` is True, display installed `optlabel1.Caption` directly.
  - For `case 2 (DLSS Enabler)`: when `IsDlssEnablerActive` is True, check `optLabel2.Visible and (optLabel2.Caption <> '')` and `optLabel2.Hint <> ''`. If an update is present, format `VerCaption := VerCaption + ' → ' + optLabel2.Hint;`, set `FOsStatVerLbls[2].Font.Color := CLR_UPDATE` and `FOsStatDots[2].Brush.Color := CLR_OK`.
- **Rationale**: Clean, direct, and eliminates the cross-contamination between OptiScaler and DLSS Enabler status rows.

## Risks / Trade-offs

- None identified; this is an isolated UI status routing fix.
