# Spec Delta

## Purpose

Provides the native **PasPlot** MangoHud CSV benchmark log parser, per-game benchmark organizer, interactive multi-run chart viewer (`TpasplotForm`), comparative statistics engine, and PNG exporter integrated into GOverlay's MangoHud Extras tab and CLI.

## ADDED Requirements

### Requirement: PasPlot button in MangoHud Extras Logging card
The GOverlay user interface SHALL provide a `PasPlot` button inside the `Logging` card (`FExtLogCard`) of the MangoHud `Extras` tab, positioned adjacent to the `Logging toggle` shortcut capture button (`FLoggingCaptureBtn`) and styled according to the active application theme (Dark or Light).

#### Scenario: Clicking PasPlot button in Extras tab
- **WHEN** the user navigates to the MangoHud `Extras` tab and clicks the `PasPlot` button inside the `Logging` card
- **THEN** the system opens the `PasPlot` (`TpasplotForm`) benchmark viewer window, automatically organizes any loose benchmark CSV logs into `~/.local/share/goverlay/logs/<game>/`, and pre-selects the currently active game profile (if one is selected and has logs) or the first available game with benchmark logs.

### Requirement: CLI launch support for PasPlot
The GOverlay executable SHALL support a `--pasplot` (and `--gplot` alias) command-line flag (with an optional path or game name argument) that launches the `PasPlot` benchmark viewer directly.

#### Scenario: Launching GOverlay with --pasplot flag
- **WHEN** the user runs `goverlay --pasplot` from the terminal
- **THEN** GOverlay opens the `PasPlot` benchmark viewer window directly and loads discovered benchmark logs from `~/.local/share/goverlay/logs/`.

### Requirement: Unrestricted MangoHud CSV parsing and statistics computation
The PasPlot parser SHALL parse MangoHud benchmark CSV files (`<app>_YYYY-MM-DD_HH-MM-SS.csv`) of any sample count and frame rate, extracting system hardware metadata from line 2, column headers from line 3, and numeric telemetry rows from line 4 onward, while ignoring companion `*_summary.csv` files in the run selector list.

#### Scenario: Loading a 60-second pascube benchmark CSV with 600 samples at >9,000 FPS
- **WHEN** PasPlot loads a 60-second `pascube` CSV file containing 600 samples with FPS values around 9,500 FPS
- **THEN** PasPlot parses all 600 samples without rejecting the file for sample count or capping FPS at 1,000, and accurately computes Average FPS, 1% Low FPS, 0.1% Low FPS, Min/Max FPS, and Average Frametime (ms).

#### Scenario: Filtering companion summary CSV files
- **WHEN** a game log directory contains both `<app>_2026-10-17_14-07-18.csv` and `<app>_2026-10-17_14-07-18_summary.csv`
- **THEN** PasPlot lists only `<app>_2026-10-17_14-07-18.csv` as a selectable benchmark run.

### Requirement: Single-run and multi-run comparative visualization
The `PasPlot` window SHALL allow the user to select a game and check one or more benchmark runs to inspect and compare across three views: FPS/Frametime Timeline, Summary Comparison (with `Δ %` deltas), and Hardware Telemetry (GPU/CPU load, temperature, power, and memory).

#### Scenario: Comparing two benchmark runs of the same game
- **WHEN** the user checks two benchmark runs in the PasPlot run list for a selected game
- **THEN** PasPlot overlays both runs using distinct series colors in the timeline charts and displays side-by-side summary bars and percentage delta (`Δ %`) statistics in the comparative table.

### Requirement: Run management and PNG chart export
The `PasPlot` window SHALL provide controls to refresh the game/run list, open the active game's log directory in the system file manager, delete selected benchmark runs (removing both the `.csv` and its companion `_summary.csv`), and export the currently rendered chart and summary view to a `.png` image file.

#### Scenario: Exporting a benchmark comparison to PNG
- **WHEN** the user clicks the `Export PNG` button in `PasPlot` and chooses a destination path
- **THEN** PasPlot renders the active chart canvas, legend, system specs header, and comparative metrics into a `.png` file on disk.
