## Context

On the bleeding-edge channel, OptiScaler includes FSR 4.1.1. When GOverlay updates or auto-installs OptiScaler on this channel (`not IsStableChannel`), `goverlay.vars` should record `fsrversion=4.1.1`.

## Goals / Non-Goals

**Goals:**
- Update `fsrversion` key in `goverlay.vars` to `4.1.1` when installing or updating bleeding-edge OptiScaler.
- Apply to both main `goverlay.vars` and `.bgmod_original/goverlay.vars`.

**Non-Goals:**
- Dynamically detecting FSR version binaries (will be addressed in a future update).

## Decisions

### Decision 1: Update in optiscaler_update.pas
In `optiscaler_update.pas` where `goverlay.vars` is updated inside `UpdateButtonClick` and `EnsureOptiScalerInstalled`, check `if not IsStableChannel then`: search for `fsrversion=` in `VarsList` and update to `fsrversion=4.1.1` (or append if not found).

## Risks / Trade-offs

- None.
