# Spec Delta

## ADDED Requirements

### Requirement: Dedicated PasPlot tab in MangoHud
The GOverlay MangoHud section SHALL provide a top-level `PasPlot` tab alongside `Presets`, `Visual`, `Performance`, `Metrics`, and `Extras` that embeds the PasPlot benchmark viewer directly inside the main tab container.

#### Scenario: Navigating to PasPlot tab from MangoHud
- **WHEN** the user selects `MangoHud` in the sidebar and clicks the `PasPlot` tab
- **THEN** GOverlay displays the embedded PasPlot benchmark viewer, organizes any loose benchmark CSV logs into `~/.local/share/goverlay/logs/<game>/`, pre-selects the currently active game profile (`FActiveGameName`) if it has logs or the first available game, and checks all discovered benchmark runs by default so charts and comparisons render immediately.

#### Scenario: Floating action dock hidden on PasPlot tab
- **WHEN** the `PasPlot` tab is active in `goverlayPageControl`
- **THEN** GOverlay hides the MangoHud floating action dock (`FFADock`) so it does not overlap the benchmark viewer or imply `MangoHud.conf` editing, and restores `FFADock` when switching back to any configuration tab (`Presets`, `Visual`, `Performance`, `Metrics`, `Extras`).

### Requirement: Layout B toolbar and responsive tab layout
The embedded `PasPlot` tab SHALL organize benchmark runs in a horizontal scrollable chip strip below the top toolbar (with `Select All`, `Clear`, `Rename`, and `Delete` actions), place a 5-pill view switcher (`Resume`, `Timeline`, `Comparison`, `Telemetry`, and `Table`), and use the full ~814px content width for KPI cards, charts, and the `Table` view so all metrics fit cleanly without horizontal clipping on desktop (`1045×683`) or Steam Deck (`1280×800`).

#### Scenario: Viewing PasPlot tab at standard window dimensions
- **WHEN** GOverlay is displayed at its standard `1045×683` window size with the `PasPlot` tab active
- **THEN** all toolbar controls, the horizontal run-chip strip, the high-contrast 5-pill view switcher, the 4 KPI cards, and the active chart or `Table` view fit cleanly within the ~834px tab content width without overlapping or horizontal clipping, with maximum vertical space for charts.

## MODIFIED Requirements

### Requirement: PasPlot button in MangoHud Extras Logging card
The GOverlay user interface SHALL provide a `PasPlot` button inside the `Logging` card (`FExtLogCard`) of the MangoHud `Extras` tab, positioned adjacent to the `Logging toggle` shortcut capture button (`FLoggingCaptureBtn`) and styled according to the active application theme (Dark or Light).

#### Scenario: Clicking PasPlot button in Extras tab
- **WHEN** the user navigates to the MangoHud `Extras` tab and clicks the `PasPlot` button inside the `Logging` card
- **THEN** the system switches `goverlayPageControl` directly to the MangoHud `PasPlot` tab, automatically organizes any loose benchmark CSV logs into `~/.local/share/goverlay/logs/<game>/`, and pre-selects the currently active game profile (if one is selected and has logs) or the first available game with benchmark logs.
