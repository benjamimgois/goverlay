# Design: Modernize Steam Finish Dialog Guide

## Context

`finish_dialog.pas` provides `TFinishDialogForm` which renders custom walkthrough animations onto a `TPaintBox` (`FAnimBox`). See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Faithfully replicate modern Steam Properties window aesthetics within the 2D Canvas rendering routine (`PaintAnimSteam`).
- Structure the visual mockup with a dark sidebar (`#131922`), game title in Steam cyan (`#1A9FFF`), vertical navigation list (`General` active pill, muted items), and a right panel (`#171D25`) with `General` header, overlay toggle, and `Launch Options` input section.
- Display English labels (`General`, `Compatibility`, `Updates`, `Installed Files`, `Controller`, `Launch Options`, `Advanced users may choose to enter modifications to their launch options.`, `Enable the Steam Overlay while in-game`).
- Display dynamic game title in the sidebar header when provided, defaulting to `MY GAME` or `GLOBAL OVERLAY`.
- Smooth animated guide cues: pulsing cyan border on input field, blinking cursor, and animated pointing indicator.

**Non-Goals:**
- Embedding webview or external image assets (rely strictly on standard Pascal LCL `TCanvas` drawing primitives for performance and zero-asset footprint).

## Decisions

### Decision 1: Pure Procedural TCanvas Rendering
- **Choice**: Render all window frames, rounded pills, text, toggles, and glow effects using native LCL `TCanvas` methods (`FillRect`, `Rectangle`, `RoundRect`, `TextOut`).
- **Rationale**: Instant load times, clean rendering on all Linux display servers, and complete control over dynamic animations (pulsing highlight border, cursor blinking, bouncing arrow).
- **Alternatives Considered**: Static PNG mockup (would lack dynamic game title and smooth animated highlighting).

### Decision 2: Game Title Propagation
- **Choice**: Update `TFinishDialogForm.Create(AOwner: TComponent; const ALaunchCommand: string; const AGameTitle: string = '')` and `ShowFinishDialog` to accept an optional `AGameTitle`.
- **Rationale**: Gives contextual personalization when finishing configuration from a specific game card, while maintaining full backwards compatibility when called without a game title.

### Decision 3: Canvas Layout Proportions
- **Choice**:
  - Window frame: ~440px wide × ~160px tall centered in `FAnimBox`.
  - Left sidebar: ~120px wide with Game Title at top, `General` active pill (`#2B3947`), and inactive items (`#8F98A0`).
  - Right panel: ~310px wide with `General` title, Steam overlay row with toggle switch, and `Launch Options` section with helper text and input box (`#0E141B`).
  - Top right: Modern window buttons (`— □ ✕`).

## Risks / Trade-offs

- **Risk**: Text clipping on small Canvas dimensions.
  - **Mitigation**: Use compact font sizes (`DejaVu Sans` / `Noto Sans` 7-8pt for titles and 6-7pt for helper text) with explicit clipping bounds and ellipsis truncation for long game titles.
