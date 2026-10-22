# Design

## Context

In GOverlay, UI tabs present settings in container cards rendered within `TScrollBox` containers.
The Lossless Scaling tab (`lossless_scaling_tab.pas`) represents the modern standard:
- 4px outer margin (`MARGIN = 4`), allowing cards to span from `Left = 4` to `Right = ClientWidth - 4`.
- Dynamic reflow hooked to `ScrollBox.OnResize`.
- Dual-column top cards positioned with `GAP = 6` so the right card terminates exactly at `ClientWidth - 4`.

In contrast, `reshade_tab.pas` used `CARD_P = 16` as both outer margin and inner padding, leaving cards 24px narrower than necessary and lacking an `OnResize` hook. `tweaks_md3.pas` (EnvVars) used `CARD_MARGIN_X = 8`, and `optiscaler_tab.pas` clamped sub-column controls to 165px while ignoring caller-provided content widths.

See `proposal.md` for background motivation.

## Goals / Non-Goals

**Goals:**
- Harmonize outer card margins to 4px across ReShade (`reshade_tab.pas`), EnvVars (`tweaks_md3.pas`), and OptiScaler (`optiscaler_tab.pas`), matching Lossless Scaling (`lossless_scaling_tab.pas`).
- Hook `FScrollBox.OnResize` in ReShade to maintain correct width on window resize and maximization.
- Ensure `ReflowReShadeTab` and `ReflowOptiScalerTabNew` accept caller-passed `AContentW` when valid (> 100).
- Allow OptiScaler column comboboxes to expand proportionally (`ColW - 20`) without the rigid 165px restriction.

**Non-Goals:**
- Modifying grid-based poster views (Games tab) or layout tile grids (MangoHud Presets).
- Changing backend configuration saving, shell scripts, or Wine/bgmod injection logic.

## Decisions

### 1. Standardize Outer Margin to 4px (`MARGIN = 4`) and Gap to 6px (`GAP = 6`)
- **Rationale**: 4px matches the bezel radius and viewport boundary across Lazarus/Qt6, maximizing usable screen real estate without clipping borders.
- **Alternatives Considered**: 8px or 12px margins were rejected because they waste 16-24px of horizontal space on standard 720p/800p handhelds and compact laptop screens.

### 2. Decouple Outer Margin from Inner Padding in `reshade_tab.pas`
- **Rationale**: `CARD_P = 16` conflated card positioning with inner control padding. We introduce:
  - `MARGIN = 4`: Outer space between scrollbox edge and card border.
  - `PAD = 14`: Inner padding between card border and controls/buttons.
  - `GAP = 6`: Spacing between cards vertically and horizontally.
- **Alternatives Considered**: Keeping 16px padding everywhere was rejected because it causes double-indentation of nested panels (shader packs).

### 3. Change `CARD_MARGIN_X` from 8 to 4 in `tweaks_md3.pas`
- **Rationale**: EnvVars uses paintbox rendering with `CardLeft := CARD_MARGIN_X` and `CardRight := PB.Width - CARD_MARGIN_X`. Changing `CARD_MARGIN_X = 4` uniformly updates:
  - `TweaksPaint`: Visual card round-rect drawing.
  - `TweaksMouseMove`: Tooltip hit-testing.
  - `TweaksMouseDown`: Item click & toggle hit-testing.
  Because item columns derive from `InnerLeft := CardLeft + CARD_PAD_X` and `InnerRight := CardRight - CARD_PAD_X`, the two-column grid expands seamlessly.

### 4. Wire `FScrollBox.OnResize` and Add Content Width Fallbacks
- **Rationale**: In Qt6/LCL, parent tab sheet resizes do not always trigger child component reflow if not wired to the scrollbox's own viewport changes. Hooking `OnResize` guarantees responsive adjustment when maximizing or resizing the window.

## Risks / Trade-offs

- **[Risk]** Very narrow windows could cause controls inside cards to overlap.
  → *Mitigation*: Both `ReflowReShadeTab` and `ReflowOptiScalerTabNew` clamp minimum layout width to 500px (`if W < 500 then W := 500`), matching Lossless Scaling's defensive design.
