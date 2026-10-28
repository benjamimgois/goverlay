# Design: Clean Minimalist Typography for Metrics Sub-Cards (Approach 4B)

## Architecture & Layout

### Sub-Card Headers
- Pure typography without prefix badges (`▌`) or emojis (`⚡`, `🌡️`, etc.).
- Label positioning: `Left = 12`, `Top = 8`, `Width = SecW - 24`, `Height = 18`.
- Font attributes:
  - `Font.Size = 9`
  - `Font.Style = [fsBold]`
  - `Transparent = True`
  - `ShowAccelChar = False`
  - Color: `clWhite` (Dark Theme) / `LightTextColor` (Light Theme)
