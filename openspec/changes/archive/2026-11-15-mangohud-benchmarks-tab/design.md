# Design

## Context

See `proposal.md` for motivation. Currently:
- `TgplotForm` (`pasplot_form.pas`) is a standalone `TForm` sized for `1080×720` (`Constraints.MinWidth := 860`, `MinHeight := 560`), invoked both from `Tgoverlayform.GplotBtnClick` (`overlayunit.pas`) and from `goverlay.lpr` via `--pasplot` / `--gplot`.
- `goverlayform` (`overlayunit.lfm`) has fixed dimensions `1045×683` (`biMaximize` disabled), with a `211px` left navigation sidebar (`sidebar_nav.pas`), leaving ~`834px` of content width for `goverlayPageControl` tabs.

## Goals / Non-Goals

**Goals:**
- Embed the full PasPlot experience inside a new `benchmarksTabSheet` (`Caption := 'Benchmarks'`) in `goverlayPageControl`.
- Share a single UI/logic implementation between the embedded `Benchmarks` tab and the standalone `--pasplot` CLI `TgplotForm`.
- Fit all controls cleanly in ~`834px` width using Layout A (compact single-row toolbar) and dynamic reflow on tab show/resize.
- Hide `FFADock` on `benchmarksTabSheet` and restore it on MangoHud configuration tabs.

**Non-Goals:**
- Changing the main `goverlayform` window dimensions (`1045×683`) or enabling window maximization.
- Redesigning PasPlot's chart rendering, CSV parser, or KPI calculation logic.
- Removing `--pasplot` / `--gplot` CLI standalone support.

## Decisions

### 1. Embeddable PasPlot Container (`TPasPlotPanel` / `TGplotView`) vs. Duplicating UI
- **Decision:** Extract the PasPlot UI body (`FTopPanel`, `FBottomBar`, `FBodyPanel`, event handlers, data loading, and chart rendering) from `TgplotForm` into a reusable `TPanel`-based component or helper class (`TPasPlotPanel` in `pasplot_form.pas`) that accepts any `TWinControl` parent. `TgplotForm` becomes a thin `1080×720` wrapper hosting `TPasPlotPanel`, while `benchmarksTabSheet` hosts an instance of `TPasPlotPanel` directly inside `goverlayform`.
- **Rationale:** Zero code duplication between the tab and `--pasplot` CLI mode; theme updates (`ApplyThemeStyling`) and `RefreshGamesAndRuns` work identically in both contexts.
- **Alternative considered:** Re-parenting `TgplotForm` via `BorderStyle := bsNone` / `Parent := benchmarksTabSheet`. Rejected because LCL Qt5/Qt6 form re-parenting can trigger focus, shortcut (`F2`), and modal/menu quirks.

### 2. Option C Layout (Horizontal Run Chips + Dedicated `Table` View Tab)
- **Decision:** Replace the permanent left run-selector column (`FLeftPanel`) with a compact horizontal scrollable chip strip (`FRunsChipScroll: TScrollBox` inside `FRunsStripPanel`) directly below `FTopPanel`, alongside `All`, `None`, `Rename`, and `Delete` buttons, and move `FStatsPanel` (`Comparative Statistics` table) from a fixed bottom split into a dedicated 5th view pill (`📑 Table`, `gvmTable`) alongside `Resume`, `Timeline`, `Comparison`, and `Telemetry`.
- **Rationale:** Frees `~236px` horizontally (giving KPIs, charts, and the 9-column table the full `~814px` width with zero clipping) and `~165px` vertically for charts, while keeping 1-click run toggling and large touch/gamepad-friendly targets for Steam Deck (`1280×800`).
- **Backwards compatibility:** Keep `FRunCheckListBox` synchronized (hidden when `FUseChipsLayout` or kept as underlying model/state) so existing `TgplotForm` / `TPasPlotPanel` test hooks (`RunCheckListBox`, `SelectedRunCount`, `StatsGrid`) continue to work seamlessly.

### 3. Tab Lifecycle, `FFADock`, and `Extras` Button Behavior
- **Decision:**
  - Add `benchmarksTabSheet: TTabSheet` to `goverlayPageControl` right after `extrasTabSheet`.
  - Toggle `benchmarksTabSheet.TabVisible` alongside the other 5 MangoHud tabs in `mangohudLabelClick` and hide it when switching away to non-MangoHud sidebar items (`Games`, `vkBasalt`, `Tweaks`, etc.).
  - In `benchmarksTabSheetShow`, call `FFADock.UpdateForTab(False, False, False)` (or `Visible := False`) to hide Preview/Menu buttons, and call `RefreshGamesAndRuns(FActiveGameName)` to sync with the active game. Restore `FFADock.UpdateForTab(True, True, False)` on the other 5 MangoHud tab `OnShow` handlers.
  - Update `Tgoverlayform.GplotBtnClick` (from `Extras` tab) to switch `goverlayPageControl.ActivePage := benchmarksTabSheet` instead of opening a separate `TgplotForm` dialog.

## Risks / Trade-offs

- **Chart density at ~580px width** → Mitigation: Narrowing `FLeftPanel` to `236px` and compacting toolbar margins preserves usable chart width; if user feedback later shows charts feel cramped, we can revisit a collapsible run list or pop-out button in a follow-up.
- **Theme sync on live theme switch** → Mitigation: Hook `benchmarksTabSheet` / `TPasPlotPanel.ApplyThemeStyling` into `Tgoverlayform`'s theme-change update path alongside `UpdateExtrasCardTheme`.
- **Existing GUI tests** → Mitigation: `tests/gui/gui_test_cases.pas` checks `FGplotBtn` and `TgplotForm`; update/add test cases to verify `benchmarksTabSheet` visibility, `FFADock` hiding, and `TPasPlotPanel` reflow at ~834px.
