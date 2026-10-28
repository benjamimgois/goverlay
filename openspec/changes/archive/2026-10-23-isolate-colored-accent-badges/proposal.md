# Change: Isolate Colored Accent Badges with White Sub-Card Titles

## Why
When the sub-card header captions were given subsystem-specific colors, the entire label text was tinted. The user requested keeping the subsystem colors strictly on the vertical accent badges (`▌`), while keeping the section title text white (in dark theme) as it was originally, preserving maximum text readability while retaining distinct color cues.

## What Changes
- Decouple the vertical accent badge (`▌`) and the sub-card title text into separate labels (`ABadge: TLabel` and the section title `TLabel`).
- In `InitMetricsTab`, instantiate and parent 8 dedicated badge labels (`FGpuCoreBadge`, `FGpuThermalBadge`, `FGpuPowerBadge`, `FGpuInfoBadge`, `FCpuCoreBadge`, `FCpuThermalBadge`, `FCpuMemBadge`, `FCpuStorageBadge`) using `'▌'`.
- Clean the titles to plain text without prefixes (`'Core & Telemetry'`, `'Thermals & Cooling'`, `'Power & Energy'`, `'Hardware & Drivers'`, `'Processor Core & Freq'`, `'CPU Thermals & Power'`, `'Memory & Swap'`, `'Storage & Disk IO'`).
- In `ReflowMetricsTab`, position the badge at `Left = 12` and the title label at `Left = 25`.
- In `UpdateMetricsCardTheme`, apply the subsystem accent colors (`CoreColor`, `ThermColor`, `PowerColor`, etc.) only to the badge labels, and apply the theme's default text color (`clWhite` in dark theme, `LightTextColor` in light theme) to the title labels.

## Impact
- Sub-card headers display an elegant, colorful vertical accent bar matching their subsystem while their text title stays crisp and white.
- Fully backwards compatible with all tests.
