## Context

The MangoHud Metrics tab contains header controls (`gpunameEdit`, `gpuColorButton`, `cpunameEdit`, `cpuColorButton`) for customizing GPU and CPU overlay labels and their main bar colors. Currently, these controls are placed with fixed left margins (`285` and `281`) in `InitMetricsTab`. As window width increases when maximized, `ReflowMetricsTab` recalculates column offsets `X0..X5` for metric items across card width `CW`, but does not update the `Left` property of these header edit fields and color buttons, leaving them misaligned.

## Goals / Non-Goals

**Goals:**
- Dynamically recalculate `gpunameEdit.Left`, `gpuColorButton.Left`, `cpunameEdit.Left`, and `cpuColorButton.Left` in `TMangoHudUiHelper.ReflowMetricsTab`.
- Maintain horizontal alignment centered on `CW` at all window resolutions.

**Non-Goals:**
- Changing the vertical positioning or font styling of `gpunameEdit` or `cpunameEdit`.
- Modifying metric column spacing algorithms.

## Decisions

### Decision 1: Horizontal Centering in `ReflowMetricsTab`
- Calculate `gpunameEdit.Left := (CW - gpunameEdit.Width) div 2` and `gpuColorButton.Left := (CW - gpuColorButton.Width) div 2` inside `ReflowMetricsTab`.
- Do the same for `cpunameEdit.Left` and `cpuColorButton.Left`.
- **Rationale**: Uses card content width `CW` directly, matching the reflow logic used for card images and columns.

## Risks / Trade-offs

- [Risk] Header edit control overlap with right-aligned card icon when width is extremely small (<400px).
  → Mitigation: `CW` has a minimum bound based on minimum window width 1045px.
