# Design: Unify Tab Card Left Margins (`unify-tab-card-left-margins`)

## Architecture & Layout Strategy

### 1. Consistent Margin Baseline (`MARGIN = 4`)
The Visual tab in `mangohud_ui.pas` sets `MARGIN = 4`. This places the outer edge of cards 4px away from the left border of the content area. We adopt `MARGIN = 4` as the single unified baseline across all tab sheets.

```
  ┌───────────────┬─ 4px ─┬────────────────────────────────────────────┐
  │ ░░░░░░░░░░░░░ │       │ ┌────────────────────────────────────────┐ │
  │ ▌ MangoHud ON │       │ │ Card Background (#222638)            │ │
  │ ░░░░░░░░░░░░░ │       │ └────────────────────────────────────────┘ │
  └───────────────┴───────┴────────────────────────────────────────────┘
```

### 2. Component Reflow Updates

#### A. MangoHud Tabs (`mangohud_ui.pas`)
- `ReflowPerformanceTab`: Set `MARGIN = 4` (from `2`).
- `ReflowMetricsTab`: Set `MARGIN = 4` (from `8`). Update card width calculation `CW := FMtScrollBox.ClientWidth - 2 * MARGIN`.
- `ReflowExtrasTab`: Set `MARGIN = 4` (from `16`). Update card width `CW := FExScrollBox.ClientWidth - 2 * MARGIN`.
- `ReflowPresetsTab`: Set `MARGIN = 4` (from `16`). Update card width `CW := FPrScrollBox.ClientWidth - 2 * MARGIN`.

#### B. OptiScaler Tab (`optiscaler_tab.pas`)
- `ReflowOptiScalerTabNew`: Set `MARGIN = 4` (from `8`). Update card width `CW := FOsScrollBox.ClientWidth - 2 * MARGIN`.

#### C. vkBasalt Tab (`vkbasalt_tab.pas`)
- `ReflowVkbasaltTabNew`: Set `MARGIN = 4` (from `10` / `16`). Update card bounds and scrollbox container width.

#### D. Home Tab (`home_tab.pas`)
- Set `CARD_M = 4` (from `14`). Update grid padding calculations.

## Verification
- Run `make test` to verify headless GUI tests pass without regression across all tab switches and window reflows.
