## Context

See proposal.md for motivation. `games_tab.pas` generates and loads fallback covers for Steam and Non-Steam games when cover artwork cannot be acquired from Steam CDN or web image search.

## Goals / Non-Goals

**Goals:**
- Render the new official GOverlay branding logo cleanly on fallback card covers.
- Improve resource lookup order in `GenerateFallbackCover` so local app assets (`assets/icons/goverlay.png`, `data/icons/256x256/goverlay.png`) take precedence over stale system icons.
- Ensure that existing fallback covers (files with `.fallback` marker) can be updated to the new visual.

**Non-Goals:**
- Changing cover download logic from Steam CDN or web search.
- Changing grid dimensions (`150x215`) or card layout mechanics.

## Decisions

1. **Logo asset source**: Use `assets/icons/goverlay.png` (or `data/icons/256x256/goverlay.png`) which contains the high-resolution modern logo with transparent background.
   - *Rationale*: Guarantees crisp scaling to 80-96px on the card canvas.
2. **Card background**: `#20242C` (dark slate gray).
   - *Rationale*: Matches the dark MD3 theme and complements the blue/cyan accent lines of the logo.
3. **Fallback cover refresh**: When loading cached covers with a `.fallback` marker, if the image needs updating or on fallback generation, regenerate with the new icon.
   - *Rationale*: Prevents users from being stuck with stale legacy icons in `~/.cache/goverlay/nonsteam_covers/`.

## Risks / Trade-offs

- [Risk] Regenerating large numbers of fallbacks could add startup latency → *Mitigation*: Fallback regeneration is fast (local in-memory bitmap) and only happens for games without covers.
