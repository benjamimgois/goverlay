# gplot-benchmark-viewer Specification

## Purpose
Provides the native **PasPlot** MangoHud CSV benchmark log parser, per-game benchmark organizer, interactive multi-run chart viewer (`TpasplotForm`), comparative statistics engine, and PNG exporter integrated into GOverlay's MangoHud Extras tab and CLI.

## Requirements

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
The `PasPlot` window SHALL allow the user to select a game and check one or more benchmark runs to inspect and compare across three views: FPS/Frametime Timeline, Summary Comparison (with `Δ %` deltas), and Hardware Telemetry (GPU/CPU load, temperature, power, and memory). When one or more runs are checked, PasPlot SHALL display a persistent Quick KPI Hero Card strip at the top of the viewing area summarizing core performance and power metrics.

#### Scenario: Comparing two benchmark runs of the same game
- **WHEN** the user checks two benchmark runs in the PasPlot run list for a selected game
- **THEN** PasPlot overlays both runs using distinct series colors in the timeline charts, displays the Quick KPI cards comparing the latest checked run against the baseline, and displays side-by-side summary bars and percentage delta (`Δ %`) statistics in the comparative table.

### Requirement: Run management and PNG chart export
The `PasPlot` window SHALL provide controls to refresh the game/run list, open the active game's log directory in the system file manager, rename benchmark runs, delete selected benchmark runs (removing both the `.csv` and its companion `_summary.csv` as well as any associated name entry from `benchmarks.ini`), and export the currently rendered chart and summary view to a `.png` image file.

#### Scenario: Renaming a benchmark run via toolbar button
- **WHEN** the user selects a benchmark run and clicks the `Rename Run` button
- **THEN** PasPlot opens a text prompt dialog pre-filled with the current display name, and upon confirmation saves the new label to `~/.config/goverlay/logs/<GameName>/benchmarks.ini` under the `[Names]` section with the CSV filename as key, updating all views immediately.

#### Scenario: Renaming a benchmark run via double-click or F2
- **WHEN** the user double-clicks a run card in the sidebar or presses the `F2` key with a run selected
- **THEN** PasPlot prompts for a new name, updates `benchmarks.ini`, and refreshes the run card title and comparative views.

#### Scenario: Resetting a renamed benchmark run to default timestamp
- **WHEN** the user opens the rename dialog for a previously renamed benchmark, clears the text input, and confirms
- **THEN** PasPlot removes the custom name entry from `benchmarks.ini` and reverts the run's display title to the default formatted timestamp.

#### Scenario: Deleting a renamed benchmark run
- **WHEN** the user deletes a checked benchmark run that had a custom name in `benchmarks.ini`
- **THEN** PasPlot deletes the CSV files and also removes the key for that CSV file from `benchmarks.ini`.

#### Scenario: Exporting a benchmark comparison to PNG
- **WHEN** the user clicks the `Export PNG` button in `PasPlot` and chooses a destination path
- **THEN** PasPlot renders the active chart canvas, legend (displaying custom names when set), system specs header, and comparative metrics into a `.png` file on disk.

### Requirement: Quick KPI hero cards with power consumption
The `PasPlot` viewing area SHALL display a 4-card Quick KPI strip positioned above the charts containing:
1. `Avg FPS` with a comparison delta badge (`+X%` vs baseline) when comparing multiple runs.
2. `1% Low & 0.1% Low FPS` with a consistency indicator.
3. `Avg Frametime` (in milliseconds) with target monitor refresh rate pacing indication.
4. `Power & Thermal Status` displaying average GPU/CPU power in Watts and peak temperature in degrees Celsius.

#### Scenario: Inspecting single run KPI metrics
- **WHEN** the user checks a single benchmark run
- **THEN** PasPlot populates all four KPI cards with that run's calculated Average FPS, 1% / 0.1% Low, Average Frametime in ms, and average power in Watts alongside peak temperature.

#### Scenario: Comparing multiple runs KPI metrics
- **WHEN** the user checks two or more benchmark runs
- **THEN** the Avg FPS card highlights the primary selected run and displays the percentage delta relative to the baseline run (`Run 1`).

### Requirement: Segmented pill view switcher
The `PasPlot` window SHALL provide a segmented pill dock container positioned above the KPI cards for switching between `Timeline`, `Summary Comparison`, and `Hardware Telemetry` views, rendering the currently active view with an elevated highlight color matching the application theme.

#### Scenario: Switching to Summary Comparison view via segmented pill
- **WHEN** the user clicks the `Summary Comparison` pill in the segmented navigation dock
- **THEN** PasPlot activates the summary comparison view, applies the active pill theme styling to that tab, and refreshes the canvas to display comparative metric bars.

### Requirement: Custom-drawn run cards with series color badges
The `PasPlot` benchmark run selector SHALL render each run item as an elevated card utilizing custom owner-draw rendering, displaying:
1. A circular series color badge (`●`) matching the line/bar color of the run on the canvas.
2. A title displaying the custom benchmark name if assigned, or the formatted timestamp if no custom name exists, with a distinctive `[Baseline]` badge on the first active run.
3. A footer displaying both the original benchmark timestamp and runtime metrics (duration, average FPS, and average GPU power) when a custom name is set, or displaying runtime metrics when no custom name is set.

#### Scenario: Selecting and viewing run cards in the sidebar
- **WHEN** the user opens PasPlot and loads available benchmark runs for a game
- **THEN** each run in the list displays a custom-drawn card with its assigned series color badge, formatted date/time, duration, average FPS, and average power in Watts.

#### Scenario: Displaying a custom renamed run card
- **WHEN** a benchmark run has a custom name configured (e.g. "Doom DA FSR4")
- **THEN** the card title displays "Doom DA FSR4" (and "[Baseline]" if it is the baseline run), and the footer displays the timestamp and metrics (e.g. "2026-10-17 15:20 • 114s • 179 FPS • 285W").

#### Scenario: Displaying a default unrenamed run card
- **WHEN** a benchmark run has no custom name configured
- **THEN** the card title displays the formatted date and time (e.g. "2026-10-17 15:15:43"), and the footer displays duration, average FPS, and power.

### Requirement: Enhanced canvas rendering with gradient fill and floating tooltip
The `PasPlot` canvas painter SHALL render:
1. A subtle translucent area fill or gradient descending from the primary FPS timeline curve down to the bottom axis.
2. Horizontal reference guide lines for standard refresh rates (60, 120, and 144 FPS).
3. A floating rounded card tooltip on mouse hover displaying the exact synchronized time and metrics for all active runs.
4. Summary comparison bars featuring rounded caps and percentage delta badges.

#### Scenario: Hovering mouse over timeline graph
- **WHEN** the user moves the mouse cursor across the FPS timeline chart
- **THEN** PasPlot draws a crosshair and renders a floating rounded card tooltip displaying the elapsed time in seconds and each active run's color dot, run name, and exact interpolated FPS and frametime values at that timestamp.

### Requirement: Full-card hit-testing and interaction for benchmark run selection
The `PasPlot` run check list SHALL allow toggling a run's checked selection state by clicking anywhere across the run card's surface, and SHALL display an interactive hand cursor on mouse hover.

#### Scenario: Clicking on the title or subtitle text to toggle run selection
- **WHEN** the user clicks on the run title, duration badge, or empty card area to the right of the checkbox zone
- **THEN** PasPlot toggles the run's checked state and immediately recalculates and re-renders the charts, KPIs, and comparative statistics.

#### Scenario: Hovering cursor over benchmark list items
- **WHEN** the user moves the mouse cursor over the benchmark run list in the left panel
- **THEN** the cursor displays `crHandPoint` to indicate that each card is clickable.
