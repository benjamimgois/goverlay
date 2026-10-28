# Proposal: Separate Memory and Storage Metrics into Dedicated Card

## Motivation
In the current Goverlay MangoHud Metrics tab, CPU metrics, thermals, RAM, Swap, and disk telemetry are all combined under a single card titled "CPU / Memory Metrics". This creates an asymmetrical vertical hierarchy where the CPU card is overloaded with both processor telemetry and distinct system memory/storage telemetry.

Separating "Memory & Swap" and "Storage & Disk IO" into their own dedicated card titled "Memory metrics":
1. Creates a clean, logical separation between compute units (GPU, CPU) and host memory/storage subsystems.
2. Simplifies the CPU card into a focused 2-subcard single-row layout ("Processor Core & Freq" and "CPU Thermals & Power"), retitled to "CPU Metrics".
3. Displays "Memory & Swap" and "Storage & Disk IO" side-by-side in a balanced 2-subcard single-row layout inside the new "Memory metrics" card.

## Proposed Changes
1. **New Card Container**:
   - Introduce `FMtMemCard: TPanel` and title label `FMemTitleLbl: TLabel` (with caption `'Memory metrics'`).
   - Retitle `FCpuTitleLbl.Caption` to `'CPU Metrics'`.
2. **Reparenting Sub-Cards**:
   - Reparent `FCpuMemSec` ("Memory & Swap") and `FCpuStorageSec` ("Storage & Disk IO") to `FMtMemCard`.
3. **Reflow & Responsive Layout**:
   - In `ReflowMetricsTab`, calculate heights:
     - `ActiveCpuH`: Header (56px) + 1 row of CPU subcards (114px) + bottom padding (10px) = 180px.
     - `ActiveMemH`: Header (48px) + 1 row of Memory/Storage subcards (96px) + bottom padding (10px) = 154px.
   - Position `FMtGpuCard`, `FMtCpuCard`, and `FMtMemCard` sequentially with consistent gaps (`GAP = 8`).
   - Adjust `TotalH` and `FMtScrollBox.VertScrollBar.Range`.
4. **Theming**:
   - In `UpdateMetricsCardTheme`, apply card theming to `FMtMemCard` alongside `FMtGpuCard` and `FMtCpuCard`.

## Impact
- **Non-breaking**: All underlying LCL controls (`ramusageCheckBox`, `swapusageCheckBox`, `diskioCheckBox`, `ramColorButton`, `iordrwColorButton`, etc.) remain identical and retain their config bindings.
- **GUI Tests**: All existing automated GUI tests continue to pass without regression.
