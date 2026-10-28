# Design: Modular MangoHud Extras Tab Architecture

## Context

The current Extras tab implementation in `mangohud_ui.pas` uses raw coordinate placements across 6 computed columns inside a monolithic card (`FExtSysCard`) and a loose logging panel (`FExtLogCard`). Following the successful design language of the Metrics tab, this design introduces clean thematic sub-cards, a 2-column symmetrical reflow engine, inline 20x20 color swatches, and segmented pills.

## Goals / Non-Goals

**Goals:**
- Partition the Extras tab into two primary cards: `FExtSysCard` ("System & Environment") and `FExtLogCard` ("Benchmarks & Logging").
- Introduce four modular sub-cards in `FExtSysCard` (2x2 grid) and two sub-cards in `FExtLogCard` (1x2 grid) using `SubCardPaint` and `CARD_BG`.
- Standardize reflow logic using two symmetrical columns (`SecW := (CW - 2 * SEC_PAD - SEC_GAP) div 2`).
- Replace `sysinfoImage` and `Image2` with clean, minimalist typographic headers and vertical accent badges.
- Convert temperature unit (`fahrenheitCheckBox`) to a segmented dual-pill button `[ °C | °F ]`.
- Refine color buttons (`wineColorButton`, `engineColorButton`, `batteryColorButton`, `mediaColorButton`) to 20x20 round chips with tooltips aligned beside their toggles.
- Preserve full backward compatibility with GUI test suite (`TestMangoExtrasTab` and `TestMangoHudExtrasCompactToggles`).

**Non-Goals:**
- Adding new MangoHud configuration parameters outside those already exposed.
- Changing the underlying serialization/deserialization logic in `overlayunit.pas` or `overlay_config.pas`.

## Decisions

### Decision 1: 2-Card Layout (2x2 + 1x2) vs 3-Card Layout
- **Choice**: 2-Card layout (`System & Environment` with 4 sub-cards and `Benchmarks & Logging` with 2 sub-cards).
- **Rationale**: Keeps total scrollbox height to ~560px, fitting comfortably on 1080p and laptop screens without vertical scroll while maintaining visual consistency with the GPU card in Metrics.
- **Alternatives Considered**: 3 separate cards (System, Compatibility, Logging) — rejected as it increased vertical overhead and required excess scrolling.

### Decision 2: Sub-Card Partitioning
- **Row 1**:
  - `FExtPlatformSec` (Left): Distro Info, Display Server, Architecture, Resolution, Refresh Rate, Time + Format config button.
  - `FExtWineSec` (Right): Wine Ver (+ color chip), Engine Ver (+ color chip), Engine Short, Wine Sync, DirectX API, FEX-Emu stats.
- **Row 2**:
  - `FExtGamingSec` (Left): MangoHud Ver, GameMode status, vkBasalt status, FCAT, FSR indicator, HDR indicator.
  - `FExtSessionSec` (Right): Battery (Charge, Wattage, Remaining time, Device + color chip), Media (+ color chip), Network I/O (+ dropdown), Temp Unit (`°C | °F`), Custom text/exec input.
- **Logging Card**:
  - `FExtLogTimingsSec` (Left): Duration, Delay, and Interval trackbars with accent value labels.
  - `FExtLogToolsSec` (Right): Folder input + browse button, Trigger hotkey capture button, and PasPlot launcher button.

### Decision 3: Temperature Dual-Pill
- **Choice**: Segmented pill glyph `[ °C | °F ]` using `SetSegmentedPillGlyph` and `StyleSegmentedFormatBtn` (mirroring `1% low / 0.1% low` in Metrics).
- **Rationale**: Intuitive visual cue for temperature unit; directly drives `fahrenheitCheckBox.Checked` and MangoHud `fahrenheit` parameter.

### Decision 4: Option 1 Polish — Mirrored 3-Row Storage & Tools and Clear Battery Nomenclature
- **Choice**:
  1. In `FExtLogToolsSec`, arrange controls into 3 horizontal functional bands mirrored to the 3 sliders of `FExtLogTimingsSec`:
     - Row 1: Output Folder input + browse button (aligned with Duration).
     - Row 2: Logging hotkey capture button in full column width (aligned with Delay).
     - Row 3: PasPlot Benchmark Viewer launcher button in full column width (aligned with Interval).
  2. In `FExtSessionSec`, rename battery toggle labels from ambiguous "Percentage" / "Time remain" to unambiguous "Battery %" / "Battery Time".
  3. Synchronize `networkComboBox.Enabled` and dimmed appearance with `networkCheckBox.Checked`.
- **Rationale**: Eliminates the vertical dead void in the expanding Benchmarks card, elevates action button ergonomics, and clarifies hardware metric meanings.

## Risks / Trade-offs

- **[Risk] Test suite asserts specific component parenting or visibility** → Mitigation: All underlying checkboxes remain assigned and functional; test methods operate on `Helper.FdistroinfoToggle` etc. and checkboxes directly.
- **[Risk] Sub-card width on narrow screens (< 600px)** → Mitigation: `ReflowExtrasTab` enforces `CW >= 100` and minimum sub-card widths, ensuring toggles wrap or remain accessible.
