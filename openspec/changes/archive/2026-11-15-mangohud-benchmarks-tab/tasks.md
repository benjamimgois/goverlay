# Tasks

## 1. Extract Embeddable PasPlot Container (`pasplot_form.pas`)

- [x] 1.1 Refactor `TgplotForm` in `pasplot_form.pas` so its UI (`FTopPanel`, `FBottomBar`, `FBodyPanel`, run list, KPIs, charts, `StatsGrid`) lives in a reusable `TPasPlotPanel` (`TPanel` subclass) that can be parented to either `TgplotForm` or `benchmarksTabSheet`; verify standalone `--pasplot` still builds and opens cleanly.
- [x] 1.2 Implement responsive Layout A toolbar and panel reflow (`ReflowLayout(AContentW)`) in `TPasPlotPanel` so the single-row toolbar (`Game` selector + `Refresh`, `Folder`, `Rename`, `Delete`, `Export PNG`) and `FLeftPanel` (~236px when `< 920px`) fit without clipping at ~834px width as well as `1080×720`; verify via unit/GUI test or visual check at both widths.

## 2. Integrate `Benchmarks` Tab into MangoHud (`overlayunit.pas`, `sidebar_nav.pas`, `mangohud_ui.pas`)

- [x] 2.1 Create `benchmarksTabSheet: TTabSheet` (`Caption := 'Benchmarks'`) in `goverlayPageControl` after `extrasTabSheet`, instantiate `TPasPlotPanel` inside it, and wire `benchmarksTabSheet.TabVisible` into `mangohudLabelClick`, initial form setup, and non-MangoHud tab-hide paths (`overlayunit.pas`, `sidebar_nav.pas`); verify `Benchmarks` tab appears only under MangoHud.
- [x] 2.2 Implement `benchmarksTabSheetShow` (organizing/refreshing runs for `FActiveGameName` and hiding `FFADock`), restore `FFADock` on `presetTabSheetShow`/`visualTabSheetShow`/`performanceTabSheetShow`/`metricsTabSheetShow`/`extrasTabSheetShow`, and hook `TPasPlotPanel.ApplyThemeStyling` into Goverlay's theme update path; verify `FFADock` hides on `Benchmarks` and returns on other MangoHud tabs.
- [x] 2.3 Update `Tgoverlayform.GplotBtnClick` (triggered by `FGplotBtn` in `Extras`) to switch `goverlayPageControl.ActivePage := benchmarksTabSheet` instead of opening a separate `TgplotForm` modal; verify clicking `FGplotBtn` navigates to the embedded `Benchmarks` tab.

## 3. Verification & GUI Tests (`tests/gui/gui_test_cases.pas`)

## 4. Option C Redesign (Horizontal Run Chips + Dedicated `Table` View)

- [x] 4.1 Replace the permanent left run-selector sidebar with a horizontal scrollable run-chip strip (`FRunsStripPanel` + `FRunsChipScroll`) below `FTopPanel` with `All`, `None`, `Rename`, `Delete` actions and right-click context menu on chips, keeping `FRunCheckListBox` state synchronized for existing test/API compatibility; verify chips toggle runs, update focused index, and scroll cleanly when many runs exist.
- [x] 4.2 Add the 5th view mode (`gvmTable` / `FTableTabBtn` `'📑 Table'`) to the segmented view switcher and toggle `FStatsPanel` (`Align := alClient`) vs `FChartContainerPanel` (`Align := alClient`) so charts get full height (~365px+) and the 9-column `StatsGrid` gets full ~814px width without horizontal clipping; run `make goverlay && make test-gui` and verify all tests pass.
