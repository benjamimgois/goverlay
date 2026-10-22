# Design

## Context

The Metrics tab in Goverlay is created and updated in `mangohud_ui.pas` by `TMangoHudUiHelper.InitMetricsTab` and `ReflowMetricsTab`. All controls are parented to `FMtGpuCard` (GPU Metrics) and `FMtCpuCard` (CPU / Memory Metrics).

See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**
- Partition `FMtGpuCard` into 4 dedicated sub-cards (Core Telemetry, Thermals & Cooling, Power & Efficiency, Hardware & Process).
- Partition `FMtCpuCard` into 3 dedicated sub-cards (Processor Core & Freq, Thermals & Power, Memory & Storage IO).
- Style all sub-cards with `SubCardPaint` for subtle background elevation, rounded corners, and consistent padding.
- Align all secondary controls (color gradient buttons, individual color buttons, format buttons) on the same horizontal row as their parent toggles.
- Maintain responsive reflow across different window widths and scaling factors.

**Non-Goals:**
- Changing MangoHud config serialization keys (`gpu_stats`, `vram`, `cpu_stats`, `core_load`, `ram`, etc.).
- Adding or removing metric parameters.

## Decisions

### 1. Dedicated Sub-Panel Containers
- **Choice:** Create typed `TPanel` sub-cards inside `FMtGpuCard` and `FMtCpuCard` with `SubCardPaint`, rather than floating loose controls directly on the main card background.
- **Rationale:** Groups related telemetries into digestible visual modules and ensures visual consistency with the Performance tab.

### 2. Inline Horizontal Placement for Secondary Controls
- **Choice:** Position `gpuload1/2/3ColorButton`, `vramColorButton`, `coreloadtypeBitBtn`, `gpuframesjouleBitBtn`, `cpuframesjouleBitBtn`, `ramColorButton`, and `iordrwColorButton` immediately to the right of their respective toggle switches on the same vertical baseline.
- **Rationale:** Prevents vertical drift and eliminates the unsightly "fallen buttons" look under the labels.

## Risks / Trade-offs

- **[Risk] Width contention on narrow screens:** Secondary buttons beside toggles could get squeezed.
  - **Mitigation:** Calculate column widths dynamically in `ReflowMetricsTab` and use compact button dimensions.
