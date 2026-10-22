# Proposal: Modernize PasPlot UI and UX

## Why
While PasPlot currently provides robust MangoHud benchmark parsing and multi-run chart visualization, its visual presentation relies on basic LCL controls (flat buttons, unstyled checklist, plain canvas rendering) that do not match the polished Material Design 3 and gaming telemetry aesthetic of modern benchmarking tools like CapFrameX or GOverlay's design system. Modernizing PasPlot's UI/UX provides glanceable high-priority KPI metrics (including power consumption), clear series identification, tactile segmented navigation, and rich visual data analysis.

## What Changes
- **Quick KPI Hero Cards**: Introduce a 4-card KPI strip above the chart area for instant analysis of the primary/compared run(s):
  - *Avg FPS* (bold primary metric + comparison delta badge)
  - *1% Low & 0.1% Low FPS* (stability & stutter metrics)
  - *Avg Frametime* (in ms, with display refresh rate target pacing)
  - *Power Consumption & Thermal Status* (average GPU/CPU power in Watts and peak temperature)
- **Segmented Pill Navigation Bar**: Replace discrete flat tab buttons with a modern capsule-style segmented pill dock (`📈 Timeline`, `📊 Comparison`, `🌡 Telemetry`) with smooth active highlight states conforming to `themeunit.pas`.
- **Custom-Drawn Run Cards (`OwnerDraw`)**: Upgrade the benchmark run selection list from raw plain text to custom-rendered cards featuring:
  - Colored series swatch indicator matching the plot line color (`●`)
  - Formatted timestamp and duration chip (`60.0s`)
  - Performance chips (`Avg FPS`, `Power in Watts`)
  - Distinctive `[Baseline]` badge on the comparison baseline run
- **Canvas Polish & Rich Floating Tooltip**:
  - Gradient translucent area fill beneath the FPS timeline curve
  - Horizontal reference guide lines for standard refresh rates (60, 120, 144 FPS)
  - Rounded bar caps and delta badges on the Summary Comparison view
  - Modern floating rounded card tooltip on mouse hover displaying exact synchronized metrics for all active runs
- **Comparative DataGrid Polish**: Alternating row contrast and color-coded delta indicators (`+X%` in green, `-X%` in red, `Baseline` in accent).

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `gplot-benchmark-viewer`: Extend requirements to mandate KPI hero cards (including power consumption in Watts), segmented pill view switching, custom-drawn run cards with series color badges, and enhanced canvas rendering with gradient area fill and floating tooltip cards.

## Impact
- **Affected code**: `pasplot_form.pas` (UI building, custom drawing, canvas rendering, stats updates), `themeunit.pas` (shared theme tokens and card styling helpers).
- **APIs / Dependencies**: Pure Free Pascal / Lazarus LCL native rendering (`TCanvas`, `TDrawItemEvent`), no external runtime dependencies added.
- **Backward Compatibility**: Fully compatible with existing MangoHud CSV log files and GOverlay CLI `--pasplot` flag.
