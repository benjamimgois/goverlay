## Context

The Lossless Scaling tab in Goverlay is managed by `TLosslessScalingTabHelper` in `lossless_scaling_tab.pas`. To mirror the OptiScaler tab architecture where "Software Status" is anchored to the base of the tab, the status card is repositioned to the bottom.

## Goals / Non-Goals

**Goals:**
- Present a dedicated "Software Status" card anchored at the base of the Lossless Scaling tab (below Frame Generation and Spatial Scaling).
- Vertically stack the Lossless Scaling and MAKO Renderer sections across full card width to eliminate cramped horizontal spacing.
- Incorporate the cyber shark mascot (`assets/icons/mako_renderer.png`) at 52x52 to mirror the duck icon.
- Implement `GetMakoLibraryPath` helper to detect `libmako-render.so` location and display it in a read-only `TEdit`.
- Mirror actions: `[Inspect]` for Lossless.dll; conditional `[Install update]` / `[Install MAKO]` for MAKO.
- Position Target GPU Device directly below MAKO within the Software Status card.

**Non-Goals:**
- Altering Frame Generation or Spatial Scaling parameters or behavior.
- Changing backend config formats (`bgmod.conf`, `conf.toml`) or runtime environment variables.

## Decisions

### Decision 1: Vertically stacked layout at the base of the tab
- **Rationale**: Mirroring the OptiScaler tab layout where configuration cards come first and "Software Status" sits at the bottom gives the tab a familiar, consistent UX. Stacking Lossless Scaling above MAKO gives each path input 500px+ of horizontal space, avoiding truncated file paths.
- **Alternatives considered**: 50/50 horizontal column split (tighter text boxes, truncated paths on smaller screens).

### Decision 2: Library detection helper `GetMakoLibraryPath`
- **Rationale**: Checks `$HOME/.local/lib/libmako-render.so` first, followed by `/usr/lib/libmako-render.so`, `/usr/local/lib/libmako-render.so`, and multiarch paths.

### Decision 3: Reactive Update Button vs Static Button
- **Rationale**: `TMakoCheckUpdateThread` automatically checks for GitHub updates. If an update is detected or MAKO is not installed, the button is shown. When up to date, the button is hidden to keep the UI clean.

## Risks / Trade-offs

- **[Risk] Tab total height requiring scrolling** → **Mitigation**: With Frame Generation (276px), Spatial Scaling (154px), and Software Status (224px), total height is ~668px, fitting without scrolling on standard 1080p displays.
