# Change Proposal: Unify Tab Card Left Margins (`unify-tab-card-left-margins`)

## Overview
Currently, different tabs in GOverlay use inconsistent left margins (`MARGIN`) for placing their content cards relative to the left container edge (adjacent to the active sidebar menu highlight).
- **Visual tab**: Uses `MARGIN = 4` (cards sit 4px from sidebar highlight).
- **Performance tab**: Uses `MARGIN = 2`.
- **Metrics tab**: Uses `MARGIN = 8`.
- **Extras & Presets tabs**: Use `MARGIN = 16`.
- **OptiScaler tab**: Uses `MARGIN = 8`.
- **vkBasalt tab**: Uses `MARGIN = 10` / `16`.
- **Home tab**: Uses `CARD_M = 14`.

This proposal standardizes the outer left margin across all tabs to **`MARGIN = 4`**, matching the Visual tab layout so all content cards sit uniformly close to the sidebar highlight, creating a cohesive visual design across the application.

## User Impact
- **Consistent UI Layout**: All tabs will share the same sleek 4px card padding from the sidebar highlight.
- **Maximized Content Area**: Eliminates wasted empty space on the left side of Metrics, Extras, Presets, OptiScaler, and vkBasalt cards.

## Affected Files
- `mangohud_ui.pas`: `ReflowPerformanceTab`, `ReflowMetricsTab`, `ReflowExtrasTab`, `ReflowPresetsTab`
- `optiscaler_tab.pas`: `ReflowOptiScalerTabNew`
- `vkbasalt_tab.pas`: `ReflowVkbasaltTabNew`
- `home_tab.pas`: `CARD_M` constant
- `tweaks_md3.pas`: Card positioning bounds
