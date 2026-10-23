# Design: Integrate HUD Chip Metrics Header

## Context
See `proposal.md` for background and motivation. The MangoHud Metrics tab layout in `mangohud_ui.pas` dynamically positions controls via `ReflowMetricsTab`. Each card (`FMtGpuCard`, `FMtCpuCard`) features a 34px header region holding the card title on the left, the hardware vendor logo on the right, and the custom name/color controls.

## Goals / Non-Goals

**Goals:**
- Unify `gpunameEdit` + `gpuColorButton` and `cpunameEdit` + `cpuColorButton` into cohesive, theme-aware "HUD Chip" pills (`FGpuNamePanel` and `FCpuNamePanel`).
- Place the color picker on the left as an indicator bullet, the name edit in the middle, and a subtle "HUD" label on the right.
- Ensure responsive centering between the card title and vendor logo without overlap.
- Provide descriptive `TextHint` placeholders and tooltips explaining overlay line customization.

**Non-Goals:**
- Modifying backend serialization or parsing of `gpu_text`, `cpu_text`, `gpu_color`, or `cpu_color`.
- Altering any telemetry toggles or secondary sub-card placements within the metrics tab.

## Decisions

### Decision 1: HUD Chip Internal Element Order (Variação 1B)
- **Choice**: `[ TColorButton (22x22) ] [ TEdit (180x24) ] [ TLabel ("HUD") ]` inside a 30px high rounded panel (`LimitSubCardPaint`).
- **Rationale**: In the in-game MangoHud overlay, the color dictates the prefix and metric highlight. Placing the color swatch first acts as a visual bullet marker. Placing the text input right next to it directly binds the color to the name. The trailing "HUD" tag clarifies the context.
- **Alternatives Considered**:
  - *Option 1A (Color on right, Label on left)*: Tested previously; looks like a generic detached form field with a dangling square.
  - *Option 2 (Moving into Hardware Info sub-card)*: Would make the GPU and CPU cards asymmetrical, as CPU lacks an equivalent hardware info section.

### Decision 2: Geometry & Responsive Clamping in `ReflowMetricsTab`
- **Choice**:
  - `PillW := 265; PillH := 30;`
  - `PillLeft := (CW - PillW) div 2;`
  - Clamp against title and logo:
    - `MinLeft := 180;` (covers card title width + padding)
    - `MaxLeft := CW - gpuImage.Width - PillW - 12;`
    - `if PillLeft < MinLeft then PillLeft := MinLeft;`
- **Rationale**: Prevents collision on narrow screens while keeping the chip centered on standard desktop resolutions.

### Decision 3: TextHint and Theme Styling
- **Choice**:
  - `gpunameEdit.TextHint := 'Default (GPU)'`
  - `cpunameEdit.TextHint := 'Default (CPU)'`
  - `FGpuNameLabel.Caption := 'HUD'`
  - `FCpuNameLabel.Caption := 'HUD'`
- **Rationale**: Replaces the redundant and space-consuming `'HUD Label:'` with an elegant, compact tag. The placeholders clarify that empty values trigger default MangoHud device detection.

## Risks / Trade-offs

- **Risk**: Very narrow window widths might squeeze between title and vendor logo.
  - **Mitigation**: With `PillW := 265` and `MinLeft := 180`, the minimum comfortable card width is ~500px, which is well below Goverlay's minimum form width (typically > 850px).
