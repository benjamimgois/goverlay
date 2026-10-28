# Design: Dedicated Memory Metrics Card

## Overview
This design splits the host memory and storage metrics from the overloaded CPU card into a new third card on the MangoHud Metrics tab.

## UI Architecture & Hierarchy

### Card Layout
```text
┌────────────────────────────────────────────────────────┐
│ GPU Metrics          [ Color ] [ Default (GPU) ]       │
│ ┌────────────────────────┐  ┌────────────────────────┐ │
│ │ Core & Telemetry       │  │ Thermals & Cooling     │ │
│ └────────────────────────┘  └────────────────────────┘ │
│ ┌────────────────────────┐  ┌────────────────────────┐ │
│ │ Power & Energy         │  │ Hardware & Drivers     │ │
│ └────────────────────────┘  └────────────────────────┘ │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ CPU Metrics          [ Color ] [ Default (CPU) ]       │
│ ┌────────────────────────┐  ┌────────────────────────┐ │
│ │ Processor Core & Freq  │  │ CPU Thermals & Power   │ │
│ └────────────────────────┘  └────────────────────────┘ │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ Memory metrics                                         │
│ ┌────────────────────────┐  ┌────────────────────────┐ │
│ │ Memory & Swap          │  │ Storage & Disk IO      │ │
│ └────────────────────────┘  └────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

### Component Details
1. **New Fields**:
   - In `overlayunit.pas` (in `TGoverlayform` public section):
     - `FMtMemCard: TPanel;`
   - In `mangohud_ui.pas` (`TMangoHudUiHelper` private section):
     - `FMemTitleLbl: TLabel;`
     - Renaming or aliasing subcards: `FCpuMemSec` and `FCpuStorageSec` reparented to `FMtMemCard`.
2. **Card Instantiation (`InitMetricsTab`)**:
   - `MakeCard(FMtMemCard, FMemTitleLbl, 'Memory metrics');`
   - `MakeSubSec(FCpuMemSec, FMtMemCard);`
   - `MakeSubSec(FCpuStorageSec, FMtMemCard);`
   - CPU card initialized with: `MakeCard(FMtCpuCard, FCpuTitleLbl, 'CPU Metrics');`
3. **Responsive Reflow (`ReflowMetricsTab`)**:
   - `ActiveCpuH := CpuRow1Top + SecH_CPU + 10;` (since CPU only has 1 row now, `CpuRow1Top = 56`, `SecH_CPU = 114`, `ActiveCpuH = 180`).
   - `ActiveMemH := MemRow1Top + SecH_Mem + 10;` (`MemRow1Top = 48`, `SecH_Mem = 96`, `ActiveMemH = 154`).
   - Sizing and bounds:
     - `FMtGpuCard.SetBounds(MARGIN, MARGIN, CW, ActiveGpuH);`
     - `FMtCpuCard.SetBounds(MARGIN, MARGIN + ActiveGpuH + GAP, CW, ActiveCpuH);`
     - `FMtMemCard.SetBounds(MARGIN, MARGIN + ActiveGpuH + GAP + ActiveCpuH + GAP, CW, ActiveMemH);`
   - Total scrollbox content height:
     - `TotalH := MARGIN + ActiveGpuH + GAP + ActiveCpuH + GAP + ActiveMemH + DOCK_PADDING;`
4. **Theme Synchronization (`UpdateMetricsCardTheme`)**:
   - `UpdateGenericCardTheme(FMtMemCard);`
   - `ApplySectLabel(FMemTitleLbl, TitleColor);` (handled by card title styling / `StyleMainCard`).
