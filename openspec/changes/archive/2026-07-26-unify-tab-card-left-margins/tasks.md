# Tasks: Unify Tab Card Left Margins (`unify-tab-card-left-margins`)

- [x] 1. Update `mangohud_ui.pas` reflow routines (`ReflowPerformanceTab`, `ReflowMetricsTab`, `ReflowExtrasTab`, `ReflowPresetsTab`) to use `MARGIN = 4`.
- [x] 2. Update `optiscaler_tab.pas` reflow routine (`ReflowOptiScalerTabNew`) to use `MARGIN = 4`.
- [x] 3. Update `vkbasalt_tab.pas` reflow routine (`ReflowVkbasaltTabNew`) to use `MARGIN = 4`.
- [x] 4. Update `home_tab.pas` constant `CARD_M` to `4`.
- [x] 5. Run `make test` to verify all GUI tests and layout reflow assertions pass.
