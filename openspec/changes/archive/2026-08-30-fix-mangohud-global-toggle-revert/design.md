## Context

GOverlay manages tool activations (`GOVERLAY_MANGOHUD`, `GOVERLAY_VKBASALT`, etc.) via `bgmod.conf`. The UI uses `FLoadingConfig: Boolean` on `Tgoverlayform` to suppress AutoSave (`GenericControlChange`, `GenericControlClick`) while populating UI components from configuration files.

In `mangohud_ui.pas`, `ResetMangoHudControls` contained its own `try ... finally FLoadingConfig := False; end` block. When called by `LoadMangoHudConfig`, this cleared `FLoadingConfig` prematurely while reading `MangoHud.conf`. Any subsequent control updates during load triggered `TriggerAutoSave` $\rightarrow$ `SaveMangoHudConfigCore`, which unconditionally wrote `GOVERLAY_MANGOHUD=1` to `bgmod.conf`.

## Goals / Non-Goals

**Goals:**
- Maintain `FLoadingConfig = True` uninterrupted throughout `LoadMangoHudConfig`.
- Ensure `SaveMangoHudConfigCore` does not clobber an existing disabled state (`GOVERLAY_MANGOHUD=0`) in `bgmod.conf`.
- Verify behavior with automated GUI tests.

**Non-Goals:**
- Refactoring the entire AutoSave event listener subsystem.
- Changing toggle behavior in the sidebar navigation rail.

## Decisions

### Decision 1: Scope `FLoadingConfig` properly in `ResetMangoHudControls`
- **Choice**: Preserve outer `FLoadingConfig` state in `ResetMangoHudControls` (e.g., `WasLoading := FForm.FLoadingConfig; try ... finally FForm.FLoadingConfig := WasLoading; end;`).
- **Rationale**: This allows `ResetMangoHudControls` to be called safely either standalone or inside `LoadMangoHudConfig` without side effects.
- **Alternative considered**: Removing `FLoadingConfig` manipulation from `ResetMangoHudControls` entirely. (Rejected: `ResetMangoHudControls` might be called standalone from UI resets).

### Decision 2: Guard `GOVERLAY_MANGOHUD` overwrite in `SaveMangoHudConfigCore`
- **Choice**: In `SaveMangoHudConfigCore`, check if `GOVERLAY_MANGOHUD` is already explicitly disabled (`'0'`). If disabled, do not overwrite it with `'1'`.
- **Rationale**: Saving the contents of `MangoHud.conf` should not unilaterally enable MangoHud in `bgmod.conf` if the user turned it off.

## Risks / Trade-offs

- **[Risk]** New profiles might miss default `GOVERLAY_MANGOHUD=1`.
  $\rightarrow$ **Mitigation**: Only prevent overwriting when `GOVERLAY_MANGOHUD` is explicitly `'0'`. If absent or not `'0'`, default behavior is retained.
