# Tasks

## 1. ReShade Tab Card Reflow & Resizing (`reshade_tab.pas`)

- [x] 1.1 Decouple outer margin (`MARGIN = 4`) from inner padding (`PAD = 14`) and card gap (`GAP = 6`), calculating card width as `TargetCardW := W - (MARGIN * 2)`. Verify constants and card dimension calculations.
- [x] 1.2 Update bounds for `FMethodCard`, `FConfigCard`, `FShadersCard`, `FStatusCard`, and vkBasalt cards so they span from `Left = 4` to `Right = W - 4` (`Width = W - 8`). Verify shader package item bounds inside `FShadersCard`.
- [x] 1.3 Wire `FScrollBox.OnResize := @ReshadeScrollBoxResize;` in `BuildReShadeTab` and update `ReflowReShadeTab(AContentW: Integer)` to respect `AContentW > 100`. Verify reflow triggers properly on scrollbox resize.

## 2. EnvVars Tab Card Margin Harmonization (`tweaks_md3.pas`)

- [x] 2.1 Update `CARD_MARGIN_X` from `8` to `4` across `TweaksPaint`, `TweaksMouseMove`, and `TweaksMouseDown`. Verify category cards span from `Left = 4` to `Right = PB.Width - 4`.
- [x] 2.2 Verify that item column widths and toggle hit-testing boundaries adjust smoothly with the updated 4px margins.

## 3. OptiScaler Tab Reflow & Column Harmonization (`optiscaler_tab.pas`)

- [x] 3.1 Update `ReflowOptiScalerTabNew(AContentW: Integer)` to respect caller-passed `AContentW > 100` and use defensive fallback bounds. Verify responsive card recalculation.
- [x] 3.2 Adjust Options sub-column combobox widths (`filenameComboBox`, `preferredUpscalerComboBox`, etc.) to fill column width (`ColW - 20`) removing the rigid 165px clamp. Verify visual layout in the 4 columns.

## 4. Compilation & Verification

- [x] 4.1 Compile GOverlay with `lazbuild -B goverlay.lpi` and verify that compilation completes with zero errors.
- [x] 4.2 Run unit and regression tests with `./tests/logic/logic_tests` and `./tests/gui/gui_tests` to verify test suite passes.
