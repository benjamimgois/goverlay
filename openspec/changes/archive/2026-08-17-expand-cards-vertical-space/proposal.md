## Why

With the legacy bottom panel (`goverlaybarPanel`) removed across all tabs in favor of the compact floating action dock, approximately 42–50px of vertical space at the bottom of the window is currently left empty. This change expands UI cards and reflow layouts across all configuration tabs (MangoHud, OptiScaler, vkBasalt, vkSumi, EnvVars) to gracefully occupy the full vertical canvas.

## What Changes

- **PageControl Vertical Fill**: Remove the legacy 42px bottom border spacing (`BorderSpacing.Bottom := 0`) from `goverlayPageControl`, allowing all tab sheets to reach the bottom edge of `goverlayPanel`.
- **MangoHud Reflow Offsets**: Update `TABBAR_H` from `77` to `35` across MangoHud reflow routines (`mangohud_ui.pas`), reclaiming 42px for:
  - **Visual Tab**: Expand `Visual Settings` card and inner section panels, anchoring the bottom HUD controls row cleanly to the card bottom.
  - **Metrics Tab**: Proportionally distribute the additional height between `GPU Metrics` (52%) and `CPU / Memory Metrics` (48%) with relaxed metric row spacing.
  - **Performance Tab**: Expand the second row cards (`FPS Limit` and `Filters`) downward to fill the bottom.
  - **Extras Tab**: Proportionally expand `System Information` and `Logging` cards.
- **OptiScaler / Upscalers Tab**: Allow the `Options` card to dynamically expand its height (~365px vs 315px) while keeping `Software Status` anchored to the bottom.
- **Post-Processing (vkBasalt & vkSumi)**: Lift the hardcoded `340px` height cap on `FVkReshadeCard`, allowing the ReShade shader list to display more items while anchoring `Built-in Effects` and `Toggle Key` cards to the bottom.
- **EnvVars Tab**: Extend the custom environment variable canvas down to the bottom edge.

## Capabilities

### New Capabilities

- `expanded-vertical-tab-cards`: Dynamic vertical expansion of tab cards, scroll areas, and control rows across all configuration tabs to utilize the reclaimed bottom panel space.

## Impact

- `overlayunit.lfm`, `overlayunit.pas`: `goverlayPageControl.BorderSpacing.Bottom` reset to 0.
- `mangohud_ui.pas`: `TABBAR_H` updated and card heights recalculated.
- `optiscaler_tab.pas`: `ReflowOptiScalerTabNew` adjusted for expanded height.
- `vkbasalt_tab.pas`, `vksumi_tab.pas`: Reshade card height calculation updated.
- `tweaks_md3.pas`: Extended scrollable canvas.
- `tests/gui/gui_test_cases.pas`: Updated GUI layout tests.
