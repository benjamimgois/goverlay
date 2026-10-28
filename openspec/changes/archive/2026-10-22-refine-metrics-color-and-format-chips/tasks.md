# Tasks

## 1. Swatch Dimensions & Layout

- [x] 1.1 In `mangohud_ui.pas` (`ReflowMetricsTab`), resize `gpuload1/2/3ColorButton` and `cpuload1/2/3ColorButton` to `20x20` px and align vertically with the toggle baseline.
- [x] 1.2 In `mangohud_ui.pas` (`ReflowMetricsTab`), resize `vramColorButton`, `ramColorButton`, and `iordrwColorButton` to `20x20` px.

## 2. Tooltips & Button Styling

- [x] 2.1 In `hintsunit.pas`, add specific tooltips for `gpuload1/2/3ColorButton`, `cpuload1/2/3ColorButton`, `vramColorButton`, `ramColorButton`, and `iordrwColorButton` indicating load threshold bands and telemetry targets.
- [x] 2.2 In `themeunit.pas` (`StyleBitBtnTheme`), update button styling with `border-radius: 6px;` and compact padding for modern pill-style presentation.

## 3. Verification

- [x] 3.1 Compile the project with `lazbuild goverlay.lpi` and verify zero errors.
- [x] 3.2 Run the GUI test suite (`./tests/gui/gui_tests --all`) and confirm all tests pass without regressions.
