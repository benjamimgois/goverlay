## Context

`Tgoverlayform` was originally configured with `BorderStyle = bsSingle`, `Width = 1045`, and `Height = 683`. To enable window resizability without clipping native UI elements, `BorderStyle` is changed to `bsSizeable` with minimum constraints set to `1045x683` px.

## Goals / Non-Goals

**Goals:**
- Enable window resizability and maximization via `BorderStyle = bsSizeable`.
- Set minimum constraints to `1045x683` px so no UI elements clip or overlap.
- Implement dynamic column and row spacing in `ReflowMetricsTab`, `ReflowExtrasTab`, `ReflowPerformanceTab`, and `ReflowVisualTab` so inner controls and card heights scale proportionally to fill both available width and height when expanded beyond 1045x683 px.
- Persist window dimensions (`Width`, `Height`) and state (`Maximized`) into `goverlay.ini` under `[Window]`.
- Restore saved window dimensions and state on startup (`FormCreate`/`FormShow`).

**Non-Goals:**
- Allowing sidebar `goverlayPaintBox` width (211px) to be manually resized.

## Decisions

### Decision 1: LFM Form Properties
- Update `overlayunit.lfm` with:
  - `BorderStyle = bsSizeable`
  - `Constraints.MinWidth = 1045`
  - `Constraints.MinHeight = 683`

### Decision 2: Fluid Inner Control Column and Row Spacing
- In `mangohud_ui.pas`:
  - `ReflowMetricsTab`: Dynamically compute card heights (`GpuH`, `CpuH`) to fill `FMtScrollBox.ClientHeight` when expanded, and compute row `Y` offsets and column `X` offsets across `CardW` for `GPU Metrics` and `CPU Metrics` sections.
  - `ReflowExtrasTab`: Dynamically compute card heights (`SysH`, `LogH`) to fill `FExtScrollBox.ClientHeight` when expanded, and compute row `Y` offsets and column `X` offsets across `CardW` for `System Info` and `Logging` sections.
  - `ReflowPerformanceTab`: Dynamically scale row heights (`Row1H`, `Row2H`) to fill `ContentH`, and balance sub-sections (`Information`, `Limiters`, `VSYNC`, `Filters`) vertically and horizontally.
  - `ReflowVisualTab`: Dynamically scale card height and row section heights (`R1_H`, `R2H`) to fill `ContentH`.

### Decision 3: Geometry Storage in `goverlay.ini`
- Section: `[Window]`
- Keys: `Width` (Integer), `Height` (Integer), `Maximized` (Boolean)
- Save during `FormClose` in `overlayunit.pas`.
- Restore during `FormCreate` / `FormShow` in `overlayunit.pas`.

## Risks / Trade-offs

- [Risk] Displays with resolution under 1080p in height.
  - *Mitigation*: 683px height fits comfortably on 768p, 1080p, and higher displays.
