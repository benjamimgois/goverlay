# Design

## Context

The navigation rail and tab styling are defined in `sidebar_nav.pas` and `tweaks_md3.pas`. The tab contains general/graphics/performance/latency presets, custom environment variables, curated launch arguments, and custom launch arguments.

## Goals / Non-Goals

**Goals:**
- Update sidebar navigation rail item caption from `'EnvVars'` to `'Tweaks'`.
- Render subtle contextual subtitle hint text in the Custom Variables card and Launch Arguments card headers.
- Dynamically adapt the subtitle text based on whether Global mode or an individual Game Profile is active.
- Ensure all hit-testing, mouse moves, hover states, and scrolling calculations in `tweaks_md3.pas` remain perfectly aligned with the adjusted header dimensions.

**Non-Goals:**
- Altering the persistence keys, INI sections, or execution logic of `bgmod`.
- Adding invasive dialogs or intrusive tooltips.

## Decisions

### 1. Navigation Caption Update
In `sidebar_nav.pas` `ITEMS` array, update index 4 caption:
```pascal
(Icon: '󰒓'; Caption: 'Tweaks')
```

### 2. Contextual Info Chip Banner Design (Option B)
In `tweaks_md3.pas`, a dedicated info banner (`BANNER_H = 34`) is rendered immediately before the Custom Variables and Launch Arguments cards:
- **Container**: `PB.Canvas.RoundRect` with subtle dark background `RGBToColor(20, 26, 38)` and border `RGBToColor(38, 52, 78)`.
- **Icon**: Cyan info icon `ⓘ` in DejaVu Sans 9pt Bold (`RGBToColor(56, 189, 201)`).
- **Text**: DejaVu Sans 8pt Regular (`RGBToColor(140, 160, 190)`):
  - In Global mode: `"Custom items added in Global mode are cataloged and can be toggled per game."`
  - In Game Profile mode: `"Global catalog items are listed below. Toggling applies only to this game."`

### 3. Card Header & Hit-Testing Uniformity
All 6 cards (4 predefined categories + Custom Variables + Launch Arguments) use standard `CARD_HDR_H = 32`.
`Paint`, `MouseMove`, and `MouseDown` cleanly account for `BANNER_H + CARD_GAP` before processing custom and launch argument card coordinates, guaranteeing exact hit-testing alignment.

## Risks / Trade-offs

- **[Hit-test offset mismatch]** → Mitigated by applying the exact same `BANNER_H + CARD_GAP` offset across `Paint`, `MouseMove`, and `MouseDown`.
- **[Content height and scrolling]** → Total content height calculations automatically incorporate the banner height and gap.
