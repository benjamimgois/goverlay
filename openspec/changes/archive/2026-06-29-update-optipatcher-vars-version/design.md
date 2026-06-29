## Context

When OptiScaler is updated or installed in `optiscaler_update.pas`, GOverlay updates `goverlay.vars` with `OptiScalerVersion`. However, `optipatcher` is not updated, leaving stale version values in `goverlay.vars`.

## Goals / Non-Goals

**Goals:**
- Update `optipatcher` key in `goverlay.vars` to `rolling-yyyy.MM.dd` (using current date) during manual update (`UpdateButtonClick`) and auto-install (`EnsureOptiScalerInstalled`).
- Apply changes to both main `goverlay.vars` and `.bgmod_original/goverlay.vars`.

**Non-Goals:**
- Querying GitHub API for OptiPatcher tags (we use current install date since we always bundle rolling release).

## Decisions

### Decision 1: Format string in optiscaler_update.pas
Use `FormatDateTime('yyyy.MM.dd', Now)` to build `'rolling-' + FormatDateTime('yyyy.MM.dd', Now)`.
In `optiscaler_update.pas` where `OptiScalerVersion` is updated in `VarsList`, search for existing `optipatcher=` line index or append a new line if not found.

## Risks / Trade-offs

- None identified.
