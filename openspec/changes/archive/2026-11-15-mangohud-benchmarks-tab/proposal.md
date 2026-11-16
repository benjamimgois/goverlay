# Proposal

## Why

Users reported difficulty discovering the PasPlot benchmark viewer because it is currently tucked inside a secondary button (`FGplotBtn`, labeled `📊 PasPlot Viewer`) at the bottom of the MangoHud `Extras` tab. Promoting PasPlot into a dedicated, top-level MangoHud tab named `Benchmarks` makes benchmark analysis immediately discoverable right alongside `Presets`, `Visual`, `Performance`, `Metrics`, and `Extras`.

## What Changes

- Add a new `Benchmarks` tab (`TTabSheet`) to `goverlayPageControl` under the MangoHud section, embedding the PasPlot benchmark viewer directly inside the standard tab area (~834px content width).
- Extract/refactor the PasPlot UI from `TgplotForm` (`pasplot_form.pas`) into a reusable embeddable container/helper so both the new `Benchmarks` tab and the standalone `--pasplot` / `--gplot` CLI mode share a single implementation without duplicating logic.
- Adopt **Layout A (compact single-row toolbar)** inside the `Benchmarks` tab so the game selector and all action buttons (`Refresh`, `Folder`, `Rename`, `Delete`, `Export PNG`) fit cleanly within the ~834px tab width, with proportional narrowing of the left run-selector panel (`FLeftPanel`) so charts and KPI cards remain readable.
- Hide the floating action dock (`FFADock` — Preview / Menu) when the `Benchmarks` tab is active, since this tab is a read/analysis view rather than a `MangoHud.conf` editor.
- Auto-sync the selected game in `Benchmarks` with `FActiveGameName` when switching to the tab, and update or remove the legacy `FGplotBtn` in `Extras` (or convert it into a shortcut that switches to the `Benchmarks` tab).

## Capabilities

### New Capabilities
<!-- No net-new capability; this evolves the existing benchmark viewer integration. -->

### Modified Capabilities
- `gplot-benchmark-viewer`: Embed the PasPlot benchmark viewer into a dedicated MangoHud `Benchmarks` tab (Layout A single-row compact toolbar, responsive ~834px panel sizing, `FFADock` hidden while active, game context sync with `FActiveGameName`) while preserving standalone `--pasplot` / `--gplot` CLI launch support.

## Impact

- **UI & Navigation**: `overlayunit.pas` (`goverlayPageControl`, `mangohudLabelClick`, `FFADock` visibility, new `benchmarksTabSheet` and `OnShow` handler), `mangohud_ui.pas` (`FGplotBtn` in `FExtLogToolsSec`), `sidebar_nav.pas` (if tab visibility/reflow hooks enumerate MangoHud tabs).
- **PasPlot Component**: `pasplot_form.pas` (`TgplotForm` refactored to host an embeddable view/panel and reflow cleanly at ~834px width as well as standalone `1080×720` via `goverlay.lpr`).
- **Tests**: `tests/gui/gui_test_cases.pas` (update assertions for `FGplotBtn` / new `benchmarksTabSheet` placement and layout).
