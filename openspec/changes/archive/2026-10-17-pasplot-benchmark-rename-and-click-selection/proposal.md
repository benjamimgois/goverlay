# Proposal: PasPlot Benchmark Renaming and Full-Card Click Selection

## Why

In PasPlot (`TpasplotForm`), selecting benchmark runs currently requires clicking within an invisible, narrow 20-pixel strip at the far left of each item because standard `TCheckListBox` hit-testing ignores clicks on the custom-drawn series circle and text labels. Furthermore, runs only display timestamps (e.g. `2026-10-17 15:20:05`), making it difficult to distinguish between different test configurations (such as presets, upscalers, or API versions) across multiple runs.

## What Changes

- **Full-Card Click Selection**:
  - Enable toggling run selection (`Checked`) by clicking anywhere on the run card item (indicator circle, title text, subtitle metrics, or card background).
  - Set the check list cursor to `crHandPoint` to clearly indicate card-level click interactivity.
- **Benchmark Renaming**:
  - Allow assigning a custom label/alias to any benchmark run (e.g., `"Doom DA FSR4"`).
  - Support renaming via double-click on the item, right-click context menu (`"Rename Benchmark... (F2)"`), the `F2` keyboard shortcut, and a new `[Rename Run]` toolbar button adjacent to `[Delete Run]`.
  - Persist custom benchmark names in a lightweight `benchmarks.ini` file located inside each game's log directory (`~/.config/goverlay/logs/<GameName>/benchmarks.ini`).
  - Preserve original MangoHud CSV filenames and companion `_summary.csv` files intact, ensuring full compatibility with external tooling and timestamp ordering.
  - Automatically remove renamed entries from `benchmarks.ini` when a run is deleted via `[Delete Run]`.
  - Revert to the default formatted timestamp if the custom label is cleared by the user.
- **Enhanced Run Card Layout**:
  - When renamed: card title renders the custom label (with `[Baseline]` badge when applicable); card footer/subtitle displays both the original timestamp and metrics (e.g., `2026-10-17 15:20 • 114s • 179 FPS • 285W`).
  - When not renamed: card title renders the standard timestamp; card footer/subtitle displays metrics as before.
  - Automatically propagate the custom name across all PasPlot views, KPI cards, comparative tables, chart legends, and PNG exports via `TGplotRunData.DisplayName`.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `gplot-benchmark-viewer`: Extend run selection hit-testing to the entire card item, introduce benchmark renaming with persistent storage in `benchmarks.ini`, and update card rendering to display timestamps in the footer when custom labels are active.

## Impact

- **Modified Files**: `pasplot_form.pas` (UI events, toolbar buttons, owner-draw logic, INI metadata persistence).
- **Configuration/Storage**: New optional `benchmarks.ini` file inside each game's log folder (`~/.config/goverlay/logs/<GameName>/benchmarks.ini`).
- **Dependencies**: Uses standard Free Pascal `IniFiles` and `Menus` units; no external library dependencies added.
