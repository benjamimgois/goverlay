# Design: Isolate Colored Accent Badges with White Sub-Card Titles

## Component Architecture

Each of the 8 sub-cards receives a dedicated `TLabel` for the vertical badge glyph (`▌`) while retaining its existing `TLabel` for the title text.

### Visual Layout
- Badge: `Left: 12`, `Top: 8`, `Caption: '▌'`, `Font.Style: [fsBold]`, `Font.Size: 9`, `Transparent: True`, colored with the subsystem color.
- Title: `Left: 25`, `Top: 8`, `Caption: '<Subsystem Title>'`, `Font.Style: [fsBold]`, `Font.Size: 9`, `Transparent: True`, colored with `clWhite` (dark mode) or `LightTextColor` (light mode).

### Subsystem Colors applied to Badges
- Core: `$0025B8F5` (dark) / `$000A78B4` (light)
- Thermals: `$006850F4` (dark) / `$003223BE` (light)
- Power: `$0078D830` (dark) / `$003C8C14` (light)
- Hardware: `$00F09838` (dark) / `$00B45A14` (light)
- Memory: `$00F070B0` (dark) / `$00A0286E` (light)
- Storage: `$0038D0E8` (dark) / `$000A68A0` (light)
