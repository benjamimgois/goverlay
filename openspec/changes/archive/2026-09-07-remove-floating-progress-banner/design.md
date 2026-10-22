## Context

See `proposal.md` for motivation. In `overlayunit.pas`, component downloads (OptiScaler and DLSS-Enabler) and ReShade shader syncs invoke `FFloatingProgress` methods (`ShowProgress`, `HideProgress`, `UpdateProgress`). Concurrently, each view already provides dedicated, embedded progress controls:
- Software Status card embeds `updateProgressBar` and `updatestatusLabel`.
- vkBasalt toggle card embeds `FReshadeProgressBar` and `FReshadePhaseLabel`.
- Lossless Scaling tab embeds `FLsProgressBar`.

The floating progress banner (`FFloatingProgress: TFloatingProgressBanner`) appears at the top of the form, obscures top navigation/tabs, stays static at 0% for DLSS-Enabler / OptiScaler updates, and displays misleading labels.

## Goals / Non-Goals

**Goals:**
- Eliminate invocations of `FFloatingProgress` during component updates (`updateBitBtnClick`) and ReShade sync (`ReshadeGitProgress`).
- Ensure all progress feedback is displayed cleanly and solely through the integrated in-card UI controls.
- Add automated GUI regression test to verify `FFloatingProgress` is not shown when starting an update.

**Non-Goals:**
- Deleting or refactoring the underlying `TFloatingProgressBanner` class from `floating_overlay.pas` (it remains available and covered by existing unit tests).
- Modifying the progress calculation or download logic of OptiScaler, DLSS-Enabler, or ReShade.

## Decisions

### 1. Remove `FFloatingProgress` lifecycle calls from `Tgoverlayform.updateBitBtnClick`
- **Choice**: Remove lines calling `FFloatingProgress.ShowProgress(...)` and `FFloatingProgress.HideProgress(...)` around `FOptiscalerUpdate.UpdateButtonClick`.
- **Rationale**: The Software Status card already controls and renders progress via `updateProgressBar` and `updatestatusLabel`. The floating banner was hardcoded to "Downloading OptiScaler components... 0%" regardless of whether OptiScaler or DLSS-Enabler was being updated, and was never wired to actual progress events.
- **Alternatives considered**: Wiring `FFloatingProgress` to download progress events. Rejected because having two progress bars (one floating at top, one inside the status card) is visually redundant, confusing to the user, and wastes screen space.

### 2. Remove `FFloatingProgress` calls from `Tgoverlayform.ReshadeGitProgress`
- **Choice**: Remove `FFloatingProgress.UpdateProgress(Phase, Progress)` from `ReshadeGitProgress`.
- **Rationale**: Progress is already rendered inside `FVkToggleCard` via `FReshadeProgressBar` and `FReshadePhaseLabel`. Removing this call establishes uniform in-card progress reporting across all tabs.
- **Alternatives considered**: Keeping the floating progress bar for git operations only. Rejected for inconsistency with the rest of the application design.

### 3. Decouple rather than delete `TFloatingProgressBanner`
- **Choice**: Keep `TFloatingProgressBanner` in `floating_overlay.pas` and keep its unit test `TestFloatingActionDockAndFinishDialog` in `tests/gui/gui_test_cases.pas`.
- **Rationale**: Isolates the fix to UI flow behavior without removing utility components, preserving test suite integrity.
- **Alternatives considered**: Deleting `TFloatingProgressBanner` class entirely. Rejected to minimize ripple effects and keep component-level unit test suites passing.

## Risks / Trade-offs

- **[Risk]** Potential remaining references to `FFloatingProgress` in codebase.
  → **Mitigation**: Codebase-wide grep confirmed `FFloatingProgress` was only called in `updateBitBtnClick`, `ReshadeGitProgress`, and form creation/destruction.
- **[Risk]** Test regression in existing GUI test suite.
  → **Mitigation**: Existing tests (`make test-gui` and `make test-logic`) will be executed, plus a new GUI test validating `FFloatingProgress.Visible = False` on update click.
