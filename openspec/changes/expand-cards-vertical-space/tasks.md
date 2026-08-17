## 1. PageControl Full Height Configuration

- [x] 1.1 In `overlayunit.lfm` and `overlayunit.pas`, set `goverlayPageControl.BorderSpacing.Bottom := 0`.

## 2. MangoHud Cards Expansion

- [x] 2.1 In `mangohud_ui.pas`, update `TABBAR_H` from `77` to `35` across all reflow routines.
- [x] 2.2 In `mangohud_ui.pas`, verify `ReflowVisualTab` distributes extra height between row 1, row 2, and anchors HUD toggle bar to the bottom.
- [x] 2.3 In `mangohud_ui.pas`, verify `ReflowMetricsTab` expands GPU and CPU cards to fill `FMtScrollBox`.
- [x] 2.4 In `mangohud_ui.pas`, verify `ReflowPerformanceTab` and `ReflowExtrasTab` expand bottom cards.

## 3. OptiScaler, Post-Processing & EnvVars Tabs

- [x] 3.1 In `optiscaler_tab.pas`, adjust `ReflowOptiScalerTabNew` so `Options` card expands while `Software Status` anchors to the base.
- [x] 3.2 In `vkbasalt_tab.pas` and `vksumi_tab.pas`, remove `340px` cap on `RSHD_H` so ReShade card fills available space.
- [x] 3.3 In `tweaks_md3.pas`, verify tweaks paintbox fills the expanded tab sheet down to the bottom.

## 4. Verification & Testing

- [x] 4.1 Update/add layout assertions in `tests/gui/gui_test_cases.pas`.
- [x] 4.2 Run test suite with `make test` and build with `make`.
