# Spec Delta: gplot-benchmark-viewer

## MODIFIED Requirements

### Requirement: Single-run and multi-run comparative visualization
The `PasPlot` window SHALL allow the user to select a game and check one or more benchmark runs to inspect and compare across three views: FPS/Frametime Timeline, Summary Comparison (with `Δ %` deltas), and Hardware Telemetry (GPU/CPU load, temperature, power, and memory). When one or more runs are checked, PasPlot SHALL display a persistent Quick KPI Hero Card strip at the top of the viewing area summarizing core performance and power metrics.

#### Scenario: Comparing two benchmark runs of the same game
- **WHEN** the user checks two benchmark runs in the PasPlot run list for a selected game
- **THEN** PasPlot overlays both runs using distinct series colors in the timeline charts, displays the Quick KPI cards comparing the latest checked run against the baseline, and displays side-by-side summary bars and percentage delta (`Δ %`) statistics in the comparative table.

## ADDED Requirements

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
2. A formatted timestamp title and run duration badge (e.g. `60.0s`).
3. An average FPS metric badge and average power metric badge (in Watts).
4. A distinctive `[Baseline]` label on the first run of the current comparison set.

#### Scenario: Selecting and viewing run cards in the sidebar
- **WHEN** the user opens PasPlot and loads available benchmark runs for a game
- **THEN** each run in the list displays a custom-drawn card with its assigned series color badge, formatted date/time, duration, average FPS, and average power in Watts.

### Requirement: Enhanced canvas rendering with gradient fill and floating tooltip
The `PasPlot` canvas painter SHALL render:
1. A subtle translucent area fill or gradient descending from the primary FPS timeline curve down to the bottom axis.
2. Horizontal reference guide lines for standard refresh rates (60, 120, and 144 FPS).
3. A floating rounded card tooltip on mouse hover displaying the exact synchronized time and metrics for all active runs.
4. Summary comparison bars featuring rounded caps and percentage delta badges.

#### Scenario: Hovering mouse over timeline graph
- **WHEN** the user moves the mouse cursor across the FPS timeline chart
- **THEN** PasPlot draws a crosshair and renders a floating rounded card tooltip displaying the elapsed time in seconds and each active run's color dot, run name, and exact interpolated FPS and frametime values at that timestamp.
