# Tasks: Modernize PasPlot UI and UX

## 1. Quick KPI Hero Cards

- [x] 1.1 Create `FKpiContainerPanel` and four child card panels (`FKpiCardAvgFps`, `FKpiCardLows`, `FKpiCardFrametime`, `FKpiCardPower`) with category titles, big bold values, and secondary tags, and verify layout spacing in `pasplot_form.pas`.
- [x] 1.2 Implement `UpdateKpiHeroCards` to calculate and render single-run and multi-run delta metrics, including Avg FPS, 1% and 0.1% Lows, frametime pacing, and average power in Watts with peak temperature, and verify updates when checking/unchecking runs.
- [x] 1.3 Apply `themeunit.pas` card styling and typography tokens to the KPI strip in `ApplyThemeStyling` and verify theme consistency.

## 2. Segmented Pill View Switcher

- [x] 2.1 Refactor the view tab buttons into a capsule-style dock panel (`FViewTabsPanel`) with smooth rounded container styling and modern icons (`📈 Timeline`, `📊 Comparison`, `🌡 Telemetry`).
- [x] 2.2 Implement active and inactive tab button states with accent pill highlight in `UpdateViewTabButtons` and verify view switching.

## 3. Custom-Drawn Run Cards (`OwnerDraw`)

- [x] 3.1 Configure `FRunCheckListBox` for owner-drawing (`lbOwnerDrawFixed`, dynamic DPI item height) and implement `RunCheckListDrawItem`.
- [x] 3.2 Render series color badge dots (`●`), clean timestamp titles, duration pills (`60.0s`), performance metrics (Avg FPS & Power in Watts), and `[Baseline]` tags in `RunCheckListDrawItem`.
- [x] 3.3 Verify checkbox click selection, keyboard navigation, and checked item styling synchronization.

## 4. Canvas Visualization & Tooltip Polish

- [x] 4.1 Implement translucent gradient/shaded area fill beneath the primary FPS curve in `DrawTimelineView`.
- [x] 4.2 Add horizontal reference guide lines for standard refresh rates (60 FPS, 120 FPS, 144 FPS) with subtle labels.
- [x] 4.3 Implement multi-series floating rounded card tooltip in `DrawTimelineView` and `DrawHardwareView` during mouse hover, rendering synchronized metrics with colored series indicator swatches.
- [x] 4.4 Update `DrawSummaryView` with rounded bar caps and inline delta badges.
- [x] 4.5 Run compilation and automated GUI/backend test suite to verify 0 regressions across all tests.
