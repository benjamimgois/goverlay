# Change: Modernize Format Selectors into Segmented Dual-Pills

## Why
On the MangoHud Metrics tab, secondary format options (`Percent` vs `Graph` for Core Load, and `Frames / Joule` vs `Joules / Frame` for GPU and CPU Efficiency) are currently rendered as traditional rectangular dialog buttons (`TBitBtn`). They take up disproportionate horizontal space and don't visually communicate both available choices simultaneously. The user chose Option 1 (Dual-Pill / Segmented Control) to modernize these controls into compact, theme-styled segmented pills that show both available states with an active selection indicator (`● % │ Bars` / `% │ ● Bars` and `● F/J │ J/F` / `F/J │ ● J/F`).

## What Changes
- Transform `coreloadtypeBitBtn`, `gpuframesjouleBitBtn`, and `cpuframesjouleBitBtn` into segmented dual-pills (`border-radius: 11px`, subtle elevated border and background, bold 8pt font).
- Update their captions and tooltips dynamically to display both states with an active indicator dot (`●`):
  - Core load: `● % │ Bars` ⟷ `% │ ● Bars`
  - Efficiency: `● F/J │ J/F` ⟷ `F/J │ ● J/F`
- Adjust button bounds in `ReflowMetricsTab` to match their compact pill width (~84px for Core Load, ~88px for Efficiency).
- Preserve all existing property semantics (`ImageIndex` = 6/7, `Tag` = 0/1) so automated tests, config save/load, and event hooks continue working seamlessly.

## Impact
- Sleek, modern segmented control look directly integrated beside the metric toggles.
- Immediate clarity on what the alternative option is without requiring a click to find out.
- 100% backwards compatible with all GUI tests and MangoHud config settings.
