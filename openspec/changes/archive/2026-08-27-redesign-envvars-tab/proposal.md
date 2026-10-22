## Why

The EnvVars tab currently uses full-width saturated blue banners (`RGB(40, 70, 115)`), custom emoji headers, raw text prefixes, and hand-drawn toggle switches on a plain background. This clashes heavily with the modern card-based theme and typography used across other tabs (such as Upscalers, MangoHud, and Lossless Scaling).

Redesigning the EnvVars tab to use structured dark cards (`DARK_CARD_BG` / `DARK_CARD_BORDER`), clean typography, refined switches, and subtle badge chips will establish visual consistency and enhance the user experience.

## What Changes

- **Card-Based Section Layout**: Replace full-width blue banner headers and emoji icons with standard GOverlay dark cards (`General`, `Graphics`, `Performance`, `Latency reduction`, and `Custom Variables`).
- **Refined Toggle Switches**: Update switch styling to be sleek, modern, and harmonious with the dark theme palette.
- **Badge Chips for Prefixes**: Display tags like `[CachyOS]`, `[MESA]`, and `[LowLatency]` as compact rounded badge chips rather than plain colored text in descriptions.
- **Scroll & Floating Dock Integration**: Maintain the global floating action dock (`[ ☰ ] [ + Add ] [ ✓ Finish ]`) at the bottom right while ensuring proper scroll bounds and bottom padding so no options are obscured.

## Capabilities

### New Capabilities
- `envvars-tab-card-redesign`: Modern card-based layout and refined toggle UI for the EnvVars tab.

### Modified Capabilities
<!-- No requirement changes to existing capabilities. -->

## Impact

- Affected files: `tweaks_md3.pas`, `overlayunit.pas` (if interface binding adjustments are needed), and `floating_dock.pas` integration.
- User-facing UI: Visual refresh of the EnvVars tab matching the application design system.
