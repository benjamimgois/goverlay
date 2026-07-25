## 1. Window Form Properties Update

- [x] 1.1 Update `overlayunit.lfm` to set `BorderStyle = bsSizeable`, `Constraints.MinWidth = 1045`, and `Constraints.MinHeight = 683`.

## 2. Window Geometry Persistence

- [x] 2.1 Add helper methods `SaveWindowGeometry` and `LoadWindowGeometry` in `overlayunit.pas` reading/writing `[Window]` (`Width`, `Height`, `Maximized`) in `goverlay.ini`.
- [x] 2.2 Call `LoadWindowGeometry` during form initialization in `overlayunit.pas`.
- [x] 2.3 Call `SaveWindowGeometry` during `FormClose` in `overlayunit.pas`.

## 3. Fluid Inner Control Spacing (Horizontal & Vertical)

- [x] 3.1 Implement dynamic column spacing for GPU and CPU metrics in `ReflowMetricsTab` in `mangohud_ui.pas`.
- [x] 3.2 Implement dynamic column spacing for System Info and Logging in `ReflowExtrasTab` in `mangohud_ui.pas`.
- [x] 3.3 Enhance responsive spacing for Performance and Visual tabs in `mangohud_ui.pas`.
- [x] 3.4 Implement vertical dynamic card height scaling and row spacing across Metrics, Extras, Performance, and Visual tabs in `mangohud_ui.pas`.

## 4. Verification

- [x] 4.1 Run `make test` to verify logic and offscreen GUI test suite.
