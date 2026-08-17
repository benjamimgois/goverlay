## Context

See `proposal.md` for background. The legacy `goverlaybarPanel` was removed, but layout containers and reflow calculations still reserve `42px` to `50px` of empty vertical space across all tabs.

## Goals / Non-Goals

**Goals:**
- Eliminate `BorderSpacing.Bottom = 42` on `goverlayPageControl` so tabs fill `goverlayPanel`.
- Adjust `TABBAR_H` from `77` to `35` across all MangoHud reflow routines.
- Expand cards on Visual, Metrics, Performance, Extras, OptiScaler, vkBasalt, and EnvVars tabs.
- Ensure the floating action dock floats smoothly above the bottom-right corner without overlapping interactive controls.

**Non-Goals:**
- Modifying configuration settings, persistence keys, or underlying command generation.
- Changing font families or color tokens.

## Decisions

### 1. Zero Bottom Border Spacing on PageControl
- **Decision**: Update `overlayunit.lfm` to `BorderSpacing.Bottom = 0` on `goverlayPageControl` (and ensure code in `overlayunit.pas` reinforces this).
- **Rationale**: The tab sheet viewports immediately gain 42px of height.

### 2. MangoHud Reflow Calculations
- **Decision**: In `mangohud_ui.pas`, update `TABBAR_H = 35` (header height only).
- **Visual Tab**: `ActiveCardH := Max(BASE_CARD_H, TabH - CARD_TOP)`. The extra height flows into `RowsAvail`, proportionally expanding row 1 and row 2 while anchoring the HUD toggle controls at `ActiveCardH - HUD_H`.
- **Metrics Tab**: `FMtScrollBox.ClientHeight` expands, dividing height between GPU and CPU cards (52% / 48%).

### 3. OptiScaler Reflow
- **Decision**: `Options` card expands height (`OptH`) to fill the space between `Method` card and `Software Status` card.

### 4. vkBasalt / vkSumi ReShade Card Height
- **Decision**: Remove static `340px` cap (`if RSHD_H > 340 then RSHD_H := 340`) so `FVkReshadeCard` uses available height while bottom cards remain anchored to the bottom.

## Risks / Trade-offs

- **[Risk]** Floating action dock at bottom right could obscure bottom controls on small windows.
  - *Mitigation*: The floating dock has compact height (38px) and sits with 16px right / 14px bottom margin, leaving sufficient clearance above card backgrounds.
