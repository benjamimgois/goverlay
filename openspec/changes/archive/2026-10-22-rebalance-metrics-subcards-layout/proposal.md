# Proposal: Rebalance Metrics Sub-Cards Layout

## Why
The MangoHud Metrics tab currently presents visual imbalances and semantic fragmentation across its hardware telemetry sub-cards. In the GPU card, `Power & Efficiency` spans 4 dense rows while adjacent sub-cards like `Hardware & Process` only occupy 2 rows with large empty voids. In the CPU card, `RAM temp` is artificially separated from the memory telemetry, and `Memory & Storage IO` spans full width, breaking the 2-column grid pattern established by the GPU card.

Rebalancing the sub-cards establishes visual symmetry (uniform 3-row height across GPU sub-cards and a consistent 2-column grid across CPU/Memory/Storage), eliminates dead space, and groups related metrics into logically coherent hardware sections.

## What Changes
- **GPU Metrics Rebalance**:
  - Move `Process VRAM` into `FGpuCoreSec` directly next to `VRAM Usage`.
  - Move `Throttling` and `Throttling Graph` into `FGpuThermalSec` alongside temperatures and fan controls.
  - Streamline `FGpuPowerSec` to 3 clean rows (`Power`, `Voltage`, `Power Limit`, `Efficiency`).
  - Equalize GPU sub-card heights to uniform 3-row panels (~114px), saving ~28px of vertical scroll height.
- **CPU & Memory/Storage Rebalance**:
  - Reorganize `FCpuThermalSec` to focus strictly on processor thermals and power.
  - Relocate `RAM temp` into the memory telemetry section next to `RAM Usage`.
  - Divide the bottom region of the CPU card into two balanced 50% width sub-cards:
    - `FCpuMemSec` ("💾 Memory & Swap"): `RAM Usage`, `RAM Temp`, `Process RAM`, `Swap Usage`.
    - `FCpuStorageSec` ("💽 Storage & Disk IO"): `DISK IO` (and read/write color indicator).
- Reflow and dynamic geometry updates in `mangohud_ui.pas` (`ReflowMetricsTab`) and test suite verification.

## Capabilities

### Modified Capabilities
- `mangohud-metrics-modular-ui`: Updates the modular sub-card grouping and layout requirements to enforce symmetrical 2-column sub-card grids and contextual telemetry placement across GPU, CPU, Memory, and Storage.

## Impact
- **Affected Code**: `mangohud_ui.pas` (sub-card construction, parenting, and geometry calculations in `ReflowMetricsTab`).
- **Dependencies/APIs**: None; purely UI layout reflow using existing LCL controls.
- **Breaking Changes**: None; all underlying settings and config keys remain unchanged.
