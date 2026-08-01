# Design: Redesign Upscalers Tab Layout to Fill Viewport

## Architecture Overview
The Upscalers tab layout is reflowed by `ReflowOptiScalerTabNew` in `optiscaler_tab.pas`.

### Layout Mathematics

```
┌─────────────────────────────────────────────────────────────┐
│ MARGIN (4px)                                                │
│ ┌──────────────────────────┐   ┌──────────────────────────┐ │
│ │ Upscaler (50%)           │   │ GPU Driver (50%)         │ │
│ └──────────────────────────┘   └──────────────────────────┘ │
│ GAP (6px)                                                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Options (Dynamic OPT_H - fills vertical viewport space) │ │
│ │ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐   │ │
│ │ │ OptiSec (33%) │ │ ImgSec (33%)  │ │ FakeSec (33%) │   │ │
│ │ └───────────────┘ └───────────────┘ └───────────────┘   │ │
│ └─────────────────────────────────────────────────────────┘ │
│ GAP (6px)                                                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Software Status (Anchored to Bottom - STAT_H = 170px)   │ │
│ └─────────────────────────────────────────────────────────┘ │
│ MARGIN (4px)                                                │
└─────────────────────────────────────────────────────────────┘
```

1. **Top Section**:
   - `FOsUpscalerCard` (left 50%) and `FOsGpuCard` (right 50%) at `Top = MARGIN` (4px), `GPU_H = 130px`.

2. **Bottom Section**:
   - `FOsStatusCard`: `CardTop := TotalH - MARGIN - STAT_H` (where `STAT_H = 170px`).

3. **Middle Section**:
   - `FOsOptionsCard`: `CardTop := MARGIN + GPU_H + GAP` (140px).
   - `OPT_H := FOsStatusCard.Top - GAP - 140px`.
   - `BOX_H := OPT_H - HDR - 12`.

4. **3-Column Expansion**:
   - `SubCardW := (InnerW - 2 * IGAP) div 3`.
   - `FOsOptiSec`: `Left := IMARGIN`, `Width := SubCardW`.
   - `FOsImgSec`: `Left := IMARGIN + SubCardW + IGAP`, `Width := SubCardW`.
   - `FOsFakeSec`: `Left := IMARGIN + 2 * (SubCardW + IGAP)`, `Width := CW - IMARGIN - Left`.
