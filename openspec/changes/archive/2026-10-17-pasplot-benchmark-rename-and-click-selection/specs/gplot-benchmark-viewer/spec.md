# Spec Delta: gplot-benchmark-viewer

## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Full-card hit-testing and interaction for benchmark run selection
The `PasPlot` run check list SHALL allow toggling a run's checked selection state by clicking anywhere across the run card's surface, and SHALL display an interactive hand cursor on mouse hover.

#### Scenario: Clicking on the title or subtitle text to toggle run selection
- **WHEN** the user clicks on the run title, duration badge, or empty card area to the right of the checkbox zone
- **THEN** PasPlot toggles the run's checked state and immediately recalculates and re-renders the charts, KPIs, and comparative statistics.

#### Scenario: Hovering cursor over benchmark list items
- **WHEN** the user moves the mouse cursor over the benchmark run list in the left panel
- **THEN** the cursor displays `crHandPoint` to indicate that each card is clickable.
