# Design: Segmented Dual-Pill Format Selectors

## Visual Architecture

### CSS Pill Styling (`StyleSegmentedFormatBtn`)
- Border radius: `11px` (for 22px height).
- Background: `#1E263C` (dark) / `#E8EEF8` (light).
- Border: `1px solid #3C4A6E` (dark) / `1px solid #BAC8DC` (light).
- Hover: `#2A3656` with `#4C74BA` border (dark) / `#DCE4F2` with `#84A4D4` border (light).
- Pressed: `#161C2C` (dark) / `#CAD6E8` (light).
- Font: `8pt`, `font-weight: 600`, color `rgb(220, 230, 245)` (dark) / `rgb(20, 30, 50)` (light).
- Padding: `1px 6px`.

### Dynamic Text & State Sync
- `coreloadtypeBitBtn`:
  - `ImageIndex = 7` (Graph):
    - Caption: `'%  │  ● Bars'`
    - Hint: `'Core load format: Vertical bars (Bars) · Click to switch to percentage (%)'`
  - Else (`ImageIndex = 6`, Percent):
    - Caption: `'● %  │  Bars'`
    - Hint: `'Core load format: Percentage (%) · Click to switch to vertical bars (Bars)'`
- `gpuframesjouleBitBtn` & `cpuframesjouleBitBtn`:
  - `Tag = 1` (Joules / Frame):
    - Caption: `'F/J  │  ● J/F'`
    - Hint: `'Efficiency format: Joules per Frame (J/F) · Click to switch to Frames per Joule (F/J)'`
  - Else (`Tag = 0`, Frames / Joule):
    - Caption: `'● F/J  │  J/F'`
    - Hint: `'Efficiency format: Frames per Joule (F/J) · Click to switch to Joules per Frame (J/F)'`
