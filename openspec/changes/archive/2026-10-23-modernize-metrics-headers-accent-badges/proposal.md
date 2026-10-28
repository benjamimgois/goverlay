# Proposal: Modernize Metrics Headers with Accent Badges

## Why
On the MangoHud Metrics tab, sub-card section titles currently rely on text emojis (`⚡`, `🌡️`, `🔋`, `ℹ️`, `💾`, `💽`). In desktop Linux environments across various distributions and desktop environments (KDE Plasma, GNOME, XFCE), emoji rendering is highly inconsistent—often falling back to monochrome outlines, awkward font spacing, or tofu blocks. Furthermore, emojis give a casual mobile aesthetic rather than the professional, polished look of a hardware tuning utility.

Replacing text emojis with clean vertical accent badges (`▌`) paired with semantic subsystem color coding (Approach 4A) delivers a crisp, native, and visually distinct hierarchy across all Linux distributions.

## What Changes
- Replace emoji prefixes in all Metrics tab sub-card titles with a clean accent badge `▌`:
  - `mainmetricLabel`: `▌ Core & Telemetry`
  - `gputempLabel`: `▌ Thermals & Cooling`
  - `gpupowerLabel`: `▌ Power & Energy`
  - `gpuinfoLabel`: `▌ Hardware & Drivers`
  - `cpumainmetricsLabel`: `▌ Processor Core & Freq`
  - `cputempLabel`: `▌ CPU Thermals & Power`
  - `memLabel`: `▌ Memory & Swap`
  - `FStorageLabel`: `▌ Storage & Disk IO`
- Introduce theme-aware semantic subsystem color palettes in `UpdateMetricsCardTheme`:
  - Core / Frequency: Amber / Gold
  - Thermals & Cooling: Coral / Warm Red
  - Power & Energy: Emerald Green
  - Hardware & Drivers: Electric Blue
  - Memory & Swap: Indigo / Purple
  - Storage & Disk IO: Bronze / Warm Amber
- Support high-contrast variants for both Dark and Light themes.

## Capabilities

### Modified Capabilities
- `mangohud-metrics-modular-ui`: Extends sub-card modular styling requirements to specify semantic color-coded accent badges and emoji-free titles.

## Impact
- **Affected Code**: `mangohud_ui.pas` (title strings and `UpdateMetricsCardTheme` color assignments).
- **Dependencies/APIs**: None.
- **Breaking Changes**: None.
