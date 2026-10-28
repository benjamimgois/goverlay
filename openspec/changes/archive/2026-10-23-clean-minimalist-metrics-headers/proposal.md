# Change: Clean Minimalist Typography for Metrics Sub-Cards (Approach 4B)

## Why
The user evaluated Approach 4A (colored accent badges) and preferred Approach 4B: clean, minimalist typography without emojis and without vertical badges. This matches the sober, professional styling of system configuration utilities like SteamOS and KDE System Settings, achieving maximum consistency across Goverlay tabs.

## What Changes
- Remove the separate badge labels (`FGpuCoreBadge`, etc.) from sub-card headers.
- Keep clean, minimalist titles without emojis or symbol prefixes:
  - `Core & Telemetry`
  - `Thermals & Cooling`
  - `Power & Energy`
  - `Hardware & Drivers`
  - `Processor Core & Freq`
  - `CPU Thermals & Power`
  - `Memory & Swap`
  - `Storage & Disk IO`
- Position sub-card title labels at `Left = 12`, `Top = 8`.
- In `UpdateMetricsCardTheme`, render title labels with standard theme text color (`clWhite` in dark theme, `LightTextColor` in light theme).

## Impact
- Clean, distraction-free sub-card presentation.
- Zero emoji rendering or glyph alignment issues.
- All 148 automated GUI tests continue to pass.
