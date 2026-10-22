## Context

In GOverlay, MangoHud settings are coordinated between UI helper methods in `mangohud_ui.pas` and serialization logic in `overlay_config.pas`.
Currently, `TMangoHudUiHelper.SaveMangoHudConfig` parses `FFpsLimitEdit.Text` and forcibly assigns `MaxFPS` and `Round(MaxFPS / 2)` to `fpscolor3SpinEdit` and `fpscolor2SpinEdit` before saving `Settings.FpsColorValues`.

See `proposal.md` and `specs/mangohud-fps-colors/spec.md` for background and behavior specifications.

## Goals / Non-Goals

**Goals:**
- Eliminate the automatic overwriting of `fpscolor2SpinEdit.Value` and `fpscolor3SpinEdit.Value` during `SaveMangoHudConfig`.
- Direct persistence of `fpscolor2SpinEdit` and `fpscolor3SpinEdit` values into `Settings.FpsColorValues` (`fps_value=val1,val2`).
- Clean up legacy startup calculation in `overlayunit.pas` (`FormCreate`).
- Update automated GUI tests to ensure custom color threshold preservation is continuously tested.

**Non-Goals:**
- Changing MangoHud's configuration directive format (`fps_value` and `fps_color`).
- Implementing complex state tracking or heuristic auto-sync between limiter and color thresholds.

## Decisions

### Decision 1: Full Decoupling of FPS Limiter and Color Breakpoints
- **Rationale**: The UI explicitly provides `fpscolor2SpinEdit` and `fpscolor3SpinEdit` to allow users to set custom breakpoint thresholds. Overwriting UI inputs upon clicking "Save" is an anti-pattern. Decoupling ensures that what the user sees in the UI is strictly what gets saved.
- **Alternatives Considered**:
  - *Auto-fill on typing FPS limit*: Automatically adjusting spin edits when typing in `FFpsLimitEdit`. Rejected because it introduces hidden state heuristics and could unexpectedly mutate values a user purposefully configured.

### Decision 2: Retain 30 / 60 Default Breakpoints
- **Rationale**: When resetting controls or when `fps_value` is absent from `MangoHud.conf`, the spin edits default to `30` (median) and `60` (high), matching MangoHud's upstream defaults.

## Risks / Trade-offs

- **[Existing tests expecting old coupled behavior]** → Update `tests/gui/gui_test_cases.pas` to set custom spin edit values and assert that `fps_value` in the generated config matches those spin edit values independently of `FFpsLimitEdit`.
- **[Users expecting auto-derived thresholds from FPS limit]** → The default remains 30/60. Users can explicitly configure any desired threshold (e.g. 60/120 or 72/144) once and have it permanently preserved.
