# Proposal: Redesign MangoHud Extras Tab with Modular Sub-Cards

## Why

The current MangoHud Extras tab in Goverlay concentrates 24 diverse options across 5 uncontained sections in a single oversized card spanning 6 stretched columns, alongside a fragmented logging card. This outdated layout results in awkward horizontal spacing, misaligned color chips, clipped toggle labels on standard window sizes, and poor visual cohesion compared to the newly modernized Metrics tab. Redesigning Extras into modular, thematic sub-cards in a balanced two-column grid aligns it with the modern Goverlay design language and significantly enhances discoverability and usability.

## What Changes

- **System & Environment Main Card**:
  - Replaces the monolithic `FExtSysCard` layout with four thematic sub-cards in a symmetrical 2x2 grid:
    - **Platform & Display**: Distro Info, Display Server (Wayland/X11), Architecture, Resolution, Refresh Rate, and Time (+ Time Format Config button).
    - **Wine & Compatibility**: Wine Version (+ 20x20 color chip), Engine Version (+ 20x20 color chip), Engine Short version, Wine Sync (esync/fsync), DirectX API, and FEX-Emu translation stats.
    - **Gaming & Integrations**: MangoHud Version, GameMode status, vkBasalt status, FCAT analysis, FSR indicator, and HDR indicator.
    - **Hardware & Session**: Battery metrics (Charge, Wattage, Remaining time, Device name + 20x20 color chip), Media Player (+ 20x20 color chip), Network I/O (+ styled interface dropdown), Temperature Unit segmented pill (`°C | °F`), and styled Custom Text / Exec input.
  - Removes legacy `sysinfoImage` header bitmap in favor of a clean minimalist header with a vertical accent badge.
- **Benchmarks & Logging Main Card**:
  - Reorganizes `FExtLogCard` into two thematic sub-cards in a balanced 1x2 grid:
    - **Session Timings**: Duration, Delay, and Interval trackbars with accent-colored value badges.
    - **Storage & Tools**: Log directory field with Browse button, Trigger Key capture button (`FLoggingCaptureBtn`), and Benchmark Analysis viewer button (`FGplotBtn` / PasPlot).
  - Removes legacy `Image2` header bitmap.
- **Micro-Interactions & Component Polish**:
  - Converts `fahrenheitCheckBox` into a modern segmented dual-pill button `[ °C | °F ]`.
  - Integrates secondary color buttons as compact 20x20 round chips with tooltips aligned directly beside their corresponding toggles.
  - Fixes responsive reflow logic in `ReflowExtrasTab` to dynamically compute symmetrical 2-column widths without arbitrary column division or trailing voids.

## Capabilities

### New Capabilities
- `mangohud-extras-modular-ui`: Defines the modular sub-card presentation, responsive two-column grid layout, and inline secondary control styling for system, compatibility, hardware, and benchmark options on the Goverlay Extras tab.

### Modified Capabilities
<!-- None -->

## Impact

- **UI / Layout**: `mangohud_ui.pas` (`InitExtrasTab`, `ReflowExtrasTab`, `UpdateExtrasCardTheme`, and new sub-card panels).
- **Form Declaration**: `overlayunit.pas` (declaration of sub-card panel containers).
- **Test Suite**: `tests/gui/gui_test_cases.pas` (`TestMangoExtrasTab`, `TestMangoHudExtrasCompactToggles` remain fully passing as all underlying toggles, keys, and helpers are preserved).
