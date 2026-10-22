# Design: Modernize PasPlot UI and UX

## Context
PasPlot (`pasplot_form.pas`) is implemented using native Lazarus LCL controls (`TPanel`, `TCheckListBox`, `TPaintBox`, `TStringGrid`, `TBitBtn`). The application's theme system (`themeunit.pas`) provides design tokens (`DARK_CARD_BG`, `DARK_CARD_BORDER`, `DARK_INPUT_BG`, `CLR_TEXT_PRIMARY`, `CLR_TEXT_HIGHLIGHT`, etc.) and helper procedures for cards and buttons.

The current UI is functional but visually flat. To achieve a modern Material Design 3 and gaming telemetry aesthetic matching tools like CapFrameX without introducing heavy external dependencies, we will enhance `pasplot_form.pas` with native LCL custom-drawing (`OwnerDraw`), composable card panels, and refined `TCanvas` rendering techniques.

## Goals / Non-Goals

**Goals:**
- Provide instant, high-contrast visual metrics via 4 Quick KPI Hero Cards (Avg FPS, 1%/0.1% Low, Frametime, and Power Consumption in Watts / Temperature).
- Deliver a unified Segmented Pill View Switcher (`📈 Timeline`, `📊 Comparison`, `🌡 Telemetry`) with clear active/hover states.
- Enhance the run list using `OwnerDraw` cards displaying series color swatches, formatted dates, performance badges, and baseline tags.
- Elevate `TPaintBox` visuals with gradient area fills beneath FPS curves, standard monitor refresh rate reference lines (60, 120, 144 FPS), rounded comparison bars, and an informative multi-series floating card tooltip on hover.

**Non-Goals:**
- Introducing external chart libraries (e.g. TAChart package or web-based webviews); all rendering remains native LCL `TCanvas`.
- Modifying the underlying MangoHud CSV parsing logic or file organization structure.

## Decisions

### Decision 1: OwnerDraw `TCheckListBox` vs. ScrollBox of Panels
- **Choice**: Use `TCheckListBox` with `Style := lbOwnerDrawFixed` (height 52px) and an `OnDrawItem` event handler.
- **Rationale**: `TCheckListBox` with owner-draw handles large numbers of runs (e.g. 100+ benchmark runs) with zero allocation overhead and minimal memory consumption, while maintaining native keyboard navigation and checkbox toggle behavior.
- **Alternative considered**: `TScrollBox` dynamically populated with `TPanel` cards. Rejected due to heavy widget creation overhead on Qt/GTK when a user has dozens of benchmark runs.

### Decision 2: 4-Card KPI Strip Architecture
- **Choice**: A dedicated `FKpiContainerPanel` placed directly below the segmented pill switcher, containing 4 child `TPanel` cards (`FKpiCardAvgFps`, `FKpiCardLows`, `FKpiCardFrametime`, `FKpiCardPower`).
- **Rationale**: Each card is styled using `themeunit.StyleSubCard`, featuring a muted category label, a prominent bold metric value (15pt-18pt), and a contextual secondary tag (e.g. `▲ +14.2% vs Baseline`, `Estável`, `144Hz Pacing`, `Avg GPU Power`).
- **Alternative considered**: Storing metrics only in the bottom `TStringGrid`. Rejected because users want immediate glanceable performance indicators without scanning tabular data.

### Decision 3: Canvas Polish and Floating Card Tooltip
- **Choice**:
  - Semi-transparent gradient/hachure fill under the primary FPS curve by calculating vertical gradient slices down to the X-axis.
  - Dashed or muted reference horizontal lines for 60, 120, and 144 FPS markers with right-aligned tags.
  - Floating tooltip rendered as a rounded rectangle with dark fill, subtle border, and multi-line item list (color swatch, run name, FPS, and frametime).
- **Rationale**: Elevates visual telemetry to the standards expected in gaming benchmarking tools while preserving high 60 FPS redraw speeds on LCL canvas.
- **Alternative considered**: Native OS tooltip (`Hint`). Rejected because standard hints cannot render multi-series color swatches or synchronized multi-run deltas with custom typography.

### Decision 4: Segmented Pill Dock Container
- **Choice**: A parent capsule panel `FViewTabsPanel` with rounded bevel and a dark input background, housing the 3 view switch buttons with customized theme styling (active tab receives highlighted accent background and white text, inactive tabs receive muted text).
- **Rationale**: Seamlessly reflects Material Design 3 segmented button conventions and matches GOverlay's existing visual dock styling.

## Risks / Trade-offs

- **[Risk]** Item clipping in `TCheckListBox` with custom item height on different DPI settings.
  → **Mitigation**: Calculate `ItemHeight` dynamically based on canvas font metrics (`Max(48, Canvas.TextHeight('Wg') * 3 + 8)`).
- **[Risk]** Tooltip flicker during fast mouse movement across the canvas.
  → **Mitigation**: Ensure container panels and chart paintbox have double buffering enabled, and invalidate only the necessary bounds or use memory canvas off-screen painting.
