## Context

The EnvVars tab is implemented in `tweaks_md3.pas` via `TTweaksMD3Helper`. It currently uses a single `TPaintBox` where category headers are drawn as full-width dark blue rectangles with emojis (`⚙`, `🎮`, `⚡`, `⏱`), and setting rows are drawn directly underneath with heavy toggle switches.

See `proposal.md` for motivation and `specs/envvars-tab-card-redesign/spec.md` for functional requirements.

## Goals / Non-Goals

**Goals:**
- Upgrade the visual presentation in `tweaks_md3.pas` to match GOverlay's card-based dark theme (`DARK_CARD_BG`, `DARK_CARD_BORDER`, `CLR_TEXT_PRIMARY`, `CLR_TEXT_SECONDARY`).
- Render each category (`General`, `Graphics`, `Performance`, `Latency reduction`, `Custom`) as an isolated, styled card with padding and rounded corners.
- Modernize the toggle switch drawing (`DrawToggle`) with sleek dimensions (38x20px) and harmonious theme colors.
- Introduce compact badge chips for prefix annotations (`[CachyOS]`, `[MESA]`, `[low_latency_layer]`).
- Preserve all existing configuration loading/saving logic and hidden checkbox sync.
- Ensure the floating action dock (`TFloatingActionDock`) does not overlap items when scrolled to the bottom.

**Non-Goals:**
- Changing configuration key names or backend parsing in `overlayunit.pas` or `bgmod.conf`.
- Redesigning other unrelated tabs or modifying `floating_dock.pas`.

## Decisions

### 1. Canvas-Based Card Rendering vs Control Tree
- **Choice**: Keep the canvas painting architecture in `TTweaksMD3Helper.Paint` but refactor it to draw cards (rounded rectangles with borders, headers, and item slots).
- **Rationale**: Rendering through `TPaintBox` avoids instantiating dozens of LCL panels and controls while ensuring high rendering performance, pixel-perfect alignment, smooth scrolling, and identical visual styling to `SubCardPaint`.
- **Alternative Considered**: Instantiating separate `TPanel`s and `TCheckBox`es for each row. Rejected because it introduces unnecessary overhead and makes responsive reflowing more complex.

### 2. Header and Typography Hierarchy
- **Choice**: Category headers are drawn inside the top of each card in `Sans Bold 10pt` (`clWhite`) without full-width blue stripes or emoji glyphs.
- **Rationale**: Directly aligns with `StyleMainCard` in `themeunit.pas` used across the Upscalers and MangoHud tabs.

### 3. Modern Switch Styling
- **Choice**: Slim track (38px width, 20px height, 10px radius) with inactive track color `rgb(42, 48, 66)` and active track color `rgb(52, 175, 90)`. White circular thumb (16px diameter).
- **Rationale**: Creates a much cleaner desktop toggle appearance compared to the current bulky pill switches.

### 4. Floating Action Dock Bottom Padding
- **Choice**: Add 75px bottom margin to total content height calculation when updating `FTweaksScrollBar.Max`.
- **Rationale**: Prevents the floating action pill from obscuring the custom variable items when scrolled to the very end.

## Risks / Trade-offs

- **[Risk] Hover and Hit-testing mismatch after card layout changes** → Mitigation: Keep a unified layout calculation function or aligned coordinate mapping between `Paint`, `MouseMove`, and `MouseDown` so that hit rects precisely match visual card boundaries.
- **[Risk] Long description truncation on narrow window sizes** → Mitigation: Retain the responsive column switch (`PB.Width < 700` switches from 2 columns to 1 column) and use clipped text drawing.
