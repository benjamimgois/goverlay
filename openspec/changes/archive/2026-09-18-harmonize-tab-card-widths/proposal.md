# Proposal

## Why

Currently, container cards across GOverlay's tabs have inconsistent horizontal margins and widths:
- **Lossless Scaling** uses an optimal 4px outer margin (`MARGIN = 4`, `CW := ClientWidth - 8`), allowing cards to span almost the entire available horizontal space.
- **ReShade** uses `CARD_P = 16` as both its outer margin and inner padding, leaving cards 24px narrower (`ClientWidth - 32`) with noticeable empty gaps on the sides, and lacks an `OnResize` event handler on its scrollbox.
- **EnvVars** uses `CARD_MARGIN_X = 8`, making cards 8px narrower (`ClientWidth - 16`).
- **OptiScaler** inner option columns cap control widths at 165px, leaving dead space on the right of columns, and its reflow ignores caller-provided content widths.

This change homogenizes all tabs to match Lossless Scaling's geometry (`MARGIN = 4`, `Width = ClientWidth - 8`), unifying the visual rhythm across the application and ensuring responsive layout upon window resizing.

## What Changes

- **ReShade Tab (`reshade_tab.pas`)**:
  - Decouple outer margin (`MARGIN = 4`) from inner padding (`PAD = 14`).
  - Standardize card width to `TargetCardW := W - (MARGIN * 2)` and card gap to `GAP = 6`.
  - Align top row cards (Method and Config/Toggle) so left is `4`, right ends at `W - 4`.
  - Align full-width cards (Shaders card, Software Status card, and vkBasalt cards) from `Left = 4` to `Right = W - 4`.
  - Wire `FScrollBox.OnResize` to trigger `ReflowReShadeTab` on window resize and maximization.
  - Make `ReflowReShadeTab` respect `AContentW` when provided (> 100).
- **EnvVars Tab (`tweaks_md3.pas`)**:
  - Update `CARD_MARGIN_X` from `8` to `4` across paint, mouse move, and mouse click handlers.
  - Cards for General, Graphics, Performance, and Custom Variables will expand from `Left = 4` to `Right = Width - 4`.
- **OptiScaler Tab (`optiscaler_tab.pas`)**:
  - Update `ReflowOptiScalerTabNew` to respect `AContentW` parameter.
  - Adjust dropdown and control widths in the four Options columns to fill available column space (`ColW - 20`) without a restrictive 165px clamp.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `reshade-post-processing`: Update tab reflow and card geometry to use a 4px outer margin, dynamic resizing via `OnResize`, and full horizontal card span matching Lossless Scaling.
- `envvars-tab-card-redesign`: Update card margin to 4px horizontal margin (`CARD_MARGIN_X = 4`) so cards occupy the full available width.

## Impact

- **Affected Files**:
  - `reshade_tab.pas`: Card bounds, padding constants, scrollbox resize handler.
  - `tweaks_md3.pas`: Card margin constants, hit testing.
  - `optiscaler_tab.pas`: Reflow parameter handling, inner column control widths.
- **No breaking changes**: Pure UI layout harmonization; all underlying settings, configs, and persistence remain intact.
