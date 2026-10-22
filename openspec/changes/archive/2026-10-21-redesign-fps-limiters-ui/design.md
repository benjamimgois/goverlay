# Design

## Context

The MangoHud Limiters section in Goverlay is created and positioned dynamically in `mangohud_ui.pas` by `TMangoHudUiHelper` (specifically in `InitPerformanceTab`, `BuildFpsLimitEdit`, and `ReflowPerformanceTab`). All controls are parented to `FPerfLimitSec: TPanel`. Directly below this sub-card sits the vkNemu Idle Limiter separated by `FVkNemuDivider`.

See `proposal.md` for problem context and motivation.

## Goals / Non-Goals

**Goals:**
- Consolidate the FPS limit entry, method combobox, and key capture button into a clean single-row header with an explanatory subtitle hint.
- Scale down the FPS Limit edit box to match standard control heights (~28px) with clean margins and modern typography.
- Transform the three discrete color buttons into a connected 3-segment color bar.
- Geometrically center `fpscolor2SpinEdit` and `fpscolor3SpinEdit` directly beneath the transition seams between color segments (Low-to-Mid and Mid-to-High).
- Preserve existing Qt stylesheet theming across Dark and Light themes.
- Gain ~80px of vertical margin above the vkNemu divider.

**Non-Goals:**
- Modifying `mangohud.pas` config persistence, keys, or serialization (`fps_limit`, `fps_limit_method`, `fps_value`, `fps_color`).
- Altering the vkNemu Idle Limiter controls or their layout in the lower portion of `FPerfLimitSec`.

## Decisions

### 1. Header Layout Geometry
- **Choice:** Arrange `FFpsLimitTitleLbl` + `FFpsLimitEdit`, `methodLabel` + `fpslimmetComboBox`, and `limtoggleLabel` + `FLimitCaptureBtn` in a three-column horizontal row.
- **Rationale:** Groups all functional limiter settings together at the top, freeing vertical space and making keybindings directly adjacent to the limiter they control.
- **Alternatives Considered:** Keeping the 6-level vertical stack (rejected: causes claustrophobic layout).

### 2. Seam-Centered Threshold Controls
- **Choice:** Compute the exact boundaries between the three color blocks:
  ```pascal
  ColW := ColorGroupW div 3;
  Div1 := ColorStart + ColW;
  Div2 := ColorStart + 2 * ColW;
  fpscolor2SpinEdit.Left := Div1 - (fpscolor2SpinEdit.Width div 2);
  fpscolor3SpinEdit.Left := Div2 - (fpscolor3SpinEdit.Width div 2);
  ```
- **Rationale:** Clarifies intuitively that breakpoint 1 separates Low and Mid colors, while breakpoint 2 separates Mid and High colors, removing the previous visual void beneath the Low (red) block.

## Risks / Trade-offs

- **[Risk] Minimum Width Contraction:** On very narrow window resizes, 3 controls side-by-side might crowd each other.
  - **Mitigation:** Calculate widths proportionally with safety minimums (`TotalRowW := LimitW + Gap + MethodW + Gap + ToggleW;`) and center the group within `FPerfLimitSec.ClientWidth`.
