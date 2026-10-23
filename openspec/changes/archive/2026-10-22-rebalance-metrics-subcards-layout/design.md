# Design: Rebalance Metrics Sub-Cards Layout

## Context
See `proposal.md` for background. The MangoHud Metrics tab organizes hardware telemetry into sub-cards inside `FMtGpuCard` and `FMtCpuCard`. Currently, differences in row counts lead to large empty regions in `FGpuInfoSec` and `FGpuThermalSec`, while `FCpuMemSec` breaks grid continuity by spanning the full width of the CPU card.

## Goals / Non-Goals

**Goals:**
- Unify GPU sub-cards to uniform 3-row height (`Sec1H_GPU = 114`, `Sec2H_GPU = 114`), saving ~28px of card height.
- Relocate `Process VRAM` to `FGpuCoreSec` alongside `VRAM Usage`.
- Relocate `Throttling` and `Throttling Graph` to `FGpuThermalSec` alongside thermal and fan sensors.
- Streamline `FGpuPowerSec` to 3 clean rows.
- Refactor the CPU card's lower section into two balanced 50% width cards:
  - `FCpuMemSec` ("💾 Memory & Swap"): RAM usage, RAM temp, Process RAM, Swap.
  - `FCpuStorageSec` ("💽 Storage & Disk IO"): Disk IO and indicators.
- Maintain full responsiveness across various window sizes in `ReflowMetricsTab`.

**Non-Goals:**
- Adding or removing metric options from MangoHud configuration.
- Modifying underlying configuration parsing or serialization.

## Decisions

### Decision 1: Relocating Process VRAM and Throttling in GPU Card
- **Choice**:
  - `FprocvramToggle` moves from `FGpuInfoSec` to `FGpuCoreSec` (Row 3, Col 2).
  - `FgputhrottlingToggle` and `FgputhrottlinggraphToggle` move from `FGpuPowerSec` to `FGpuThermalSec` (Row 3, Col 1 & Col 2).
- **Rationale**:
  - `Process VRAM` directly complements `VRAM Usage`.
  - Thermal throttling is a direct consequence of cooling and temperature limits, naturally fitting alongside Junction and Fan metrics.
  - This allows all 4 GPU sub-cards to fit within 3 rows, allowing `Sec2H_GPU` to decrease from 142px to 114px.

### Decision 2: Splitting CPU Memory & Storage into Symmetrical 50% Sub-Cards
- **Choice**:
  - Replace the single full-width `FCpuMemSec` with two side-by-side sub-cards: `FCpuMemSec` (left) and `FCpuStorageSec` (right), matching `SecW` of the row above.
  - Move `FramtempToggle` from `FCpuThermalSec` into `FCpuMemSec` (Row 1, Col 2).
- **Rationale**:
  - RAM temperature belongs contextually with memory metrics rather than general CPU thermals.
  - Symmetrical 2-column layout matches the GPU card, creating consistent visual rhythm throughout the tab.

### Decision 3: New Sub-Card Declaration & Theming
- **Choice**: Introduce `FCpuStorageSec: TPanel` and `storageLabel: TLabel` in `TMangoHudUiHelper`.
- **Rationale**: Enables dedicated caption and paint lifecycle following existing `MakeSubSec` conventions.

## Risks / Trade-offs

- **Risk**: `FCpuStorageSec` initially has fewer toggles (Disk IO) than `FCpuMemSec`.
  - **Mitigation**: Gives Disk IO a dedicated card matching the 2-column grid, with ample room for future IO read/write breakdown options without layout distortion.
