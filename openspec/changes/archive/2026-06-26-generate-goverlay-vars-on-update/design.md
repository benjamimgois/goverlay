## Context

No `goverlay.vars` in auto-packaged `.7z`. Need GOverlay to generate it with the correct `OptiScalerVersion` key upon installation.

## Goals / Non-Goals

**Goals:**
- Add `OptiScalerVersion` key generation logic inside `UpdateButtonClick`.

**Non-Goals:**
- Do not extract or parse FSR/XeSS versions automatically; they are not required for GOverlay update checks.

## Decisions

### Write OptiScalerVersion in the same block as dlssversion
- **Why:** Reuses existing `TStringList` file load/save flow in `optiscaler_update.pas`. Keeps logic unified.

## Risks / Trade-offs

- None.
