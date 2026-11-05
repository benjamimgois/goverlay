# Design: Modern Action Buttons and Clean Hero Layout in PasCube

## Context

PasCube UI rendering is performed directly in Vulkan via `UnitTextOverlay.pas`. The overlay uses instanced vertex buffers to render glyphs and rounded-corner bounding boxes (`AddBox` with SDF corner radius ~6px and border outlines). Hit-testing for mouse interactions is calculated mathematically in `UnitPasCubeScreen.pas` based on character dimensions (`FontCharWidth`, `FontCharHeight`), font scaling factors, and padding.

Currently, the idle menu renders a hardware pill badge above the start buttons, creating visual clutter. The action buttons on both idle and results screens share a uniform, low-contrast dark-grey palette without clear hierarchy.

## Goals / Non-Goals

**Goals:**
- Remove the redundant hardware specification pill from the idle menu (`DrawMenuOverlay`).
- Implement the "Cyber-Accent Goverlay" visual hierarchy across all idle and results action buttons:
  - Primary CTA buttons (`Start benchmark`, `Return to Menu`) with Goverlay Cyan (`#30BEF0`).
  - Secondary Ghost buttons (`View results`, `Submit results`) with dark input styling (`rgb(22, 26, 40)` / `rgb(55, 70, 108)`).
  - Destructive action (`Clear results`) with refined dark danger styling (`rgb(40, 20, 25)` / `rgb(108, 40, 50)`).
- Synchronize button bounding boxes with their corresponding hover and click hit-test functions.

**Non-Goals:**
- No shader alterations to `textoverlay_frag.spv` (existing SDF pipeline natively supports the required rounded box fills and borders).
- No changes to benchmark logic, telemetry collection, or the results view hardware card layout.

## Decisions

### Decision 1: Visual Hierarchy and Palette Tokens
We adopt the exact RGB color tokens established in Goverlay's dark theme:
- **Primary CTA (`Start benchmark`, `Return to Menu`)**:
  - Normal: Background `rgb(26, 35, 54, 0.95)`, Border `rgb(48, 190, 240, 1.0)`, Text `rgb(255, 255, 255, 1.0)` with prefix glyphs (`▶`, `◀`).
  - Hover: Background `rgb(32, 53, 84, 1.0)`, Border `rgb(82, 210, 255, 1.0)`, Text `rgb(255, 255, 255, 1.0)`.
- **Secondary Ghost (`View results`, `Submit results`)**:
  - Normal: Background `rgb(22, 26, 40, 0.90)`, Border `rgb(55, 70, 108, 1.0)`, Text `rgb(200, 205, 220, 1.0)` with prefix glyphs (`≡`, `↑`).
  - Hover: Background `rgb(38, 46, 72, 1.0)`, Border `rgb(80, 110, 170, 1.0)`, Text `rgb(255, 255, 255, 1.0)`.
- **Destructive Action (`Clear results`)**:
  - Normal: Background `rgb(40, 20, 25, 0.90)`, Border `rgb(108, 40, 50, 1.0)`, Text `rgb(240, 150, 160, 1.0)` with prefix glyph `✕`.
  - Hover: Background `rgb(60, 25, 32, 1.0)`, Border `rgb(244, 63, 94, 1.0)`, Text `rgb(255, 255, 255, 1.0)`.

*Alternative considered:* Flat solid cyan buttons. Rejected because full solid fills are overly aggressive against the obsidian dark backdrop and obscure the floor grid and ambient lighting.

### Decision 2: Geometry and Vertical Anchoring
With the removal of the 52px hardware specification card on the idle menu, the buttons are positioned at a balanced vertical anchor (`dockY := 1080.0 - 110.0`), giving proportional breathing room below the floating cube.

### Decision 3: Hit-Test Synchronization
Hit-testing functions (`IsStartButtonHovered`, `IsViewResultsButtonHovered`, `IsReturnButtonHovered`, `IsSubmitButtonHovered`, `IsClearButtonHovered`) calculate coordinate boundaries directly. Each function will be updated to match the exact string lengths (accounting for glyph prefixes) and padding used in `DrawMenuOverlay` and `DrawResultsOverlay`.

## Risks / Trade-offs

- **[Risk] Hitbox misalignment if glyph padding or string length differs between rendering and hit-testing**:
  → *Mitigation*: Define consistent label constants or string variables for both draw and hit-test routines.
