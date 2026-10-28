# Design: Modernize Metrics Headers with Accent Badges

## Context
See `proposal.md` for motivation. Sub-card section labels currently embed text emojis in `InitMetricsTab` and are colored using a single generic foreground color in `UpdateMetricsCardTheme`.

## Goals / Non-Goals

**Goals:**
- Replace emojis with clean UTF-8 vertical bar accents (`▌`) across all 8 sub-card headers.
- Implement distinct, theme-aware semantic color palettes for each hardware subsystem.
- Maintain high contrast across both Dark and Light themes.

**Non-Goals:**
- Changing control coordinates or sub-card sizing.
- Adding complex canvas-drawn vector icons where simple, robust typography and color-coding suffices.

## Decisions

### Decision 1: UTF-8 Vertical Accent Bar (`▌`)
- **Choice**: Prefix each section caption with `▌ ` (U+258C, Left Half Block).
- **Rationale**: The vertical bar acts as a native accent indicator that inherits the font's color. It renders reliably across all Linux distributions, font engines, and desktop environments without requiring emoji font packages.

### Decision 2: Subsystem Color Palette
- **Choice**:
  - **Core Telemetry**: Amber-Gold (`$0025B8F5` dark / `$000A78B4` light)
  - **Thermals & Cooling**: Coral Red (`$006850F4` dark / `$003223BE` light)
  - **Power & Energy**: Emerald Green (`$0078D830` dark / `$003C8C14` light)
  - **Hardware & Drivers**: Electric Blue (`$00F09838` dark / `$00B45A14` light)
  - **Memory & Swap**: Indigo Purple (`$00F070B0` dark / `$00A0286E` light)
  - **Storage & Disk IO**: Bronze Amber (`$0038D0E8` dark / `$000A68A0` light)
- **Rationale**: Enhances cognitive scanning—users instantly identify the subsystem by both its accent color and its title without reading each letter.

## Risks / Trade-offs

- **Risk**: Very old terminal/system fonts lacking U+258C.
  - **Mitigation**: U+258C is part of standard Unicode Block Elements (present in all modern standard fonts like Noto Sans, DejaVu Sans, Ubuntu, Liberation).
