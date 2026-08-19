## Context

See `proposal.md` for background and motivation. GOverlay's visual assets are stored under `data/icons/` and loaded by the UI and packaging scripts (FPC Lazarus resource files, FreeDesktop desktop entries, AppImage, Flatpak, and Debian packaging).

## Goals / Non-Goals

**Goals:**
- Create a pure, scalable SVG master asset (`data/icons/goverlay.svg`) encoding the exact Slate Navy + Cyan HUD geometry and gradient.
- Render pixel-crisp PNG assets for `512x512`, `256x256`, and `128x128` resolutions.
- Update `data/goverlay_logo.png` and `data/goverlay_splash_small.png` to maintain brand harmony.
- Ensure optimal contrast and clean borders across light and dark backgrounds.

**Non-Goals:**
- Modifying UI button icons (`data/icons/buttons/*.svg`) which already use standard action glyphs.
- Renaming existing icon resource files or modifying desktop entry spec keys.

## Decisions

### Decision 1: Streamlined 4-Bracket Symmetry over Asymmetrical Orbital Dots
- **Rationale:** The legacy icon had small circular arcs scattered on the right and bottom sides. While artistic at 512px, these turned into blurred noise at 16px/32px taskbar resolutions and broke optical centering in system docks. Removing them leaves a perfectly balanced HUD frame.
- **Alternatives Considered:** Keeping the orbital dots recolored in cyan. Rejected due to poor low-resolution legibilidade.

### Decision 2: Multi-Stop Gradient Visor with Cyan Corner Highlights
- **Rationale:** A multi-stop diagonal linear gradient (`#141B23` -> `#1A283B` -> `#154B6E` -> `#219FD1` -> `#3CD0F6`) gives the visor depth and illumination without needing heavy 3D skeuomorphism. The brackets use a neon glow filter combined with a crisp `#E0F7FF` core highlight for sharpness.
- **Alternatives Considered:** Flat 2D colors or heavy 3D raytraced glass. Flat colors looked lifeless; 3D textures didn't scale well down to 16px.

### Decision 3: Automated SVG-to-PNG Vector Build Step
- **Rationale:** Keeping the master in `data/icons/goverlay.svg` ensures future modifications can be easily rendered into any resolution using `rsvg-convert` or ImageMagick without loss of fidelity.

## Risks / Trade-offs

- **[Cache Invalidation in Desktop Environments]** → Linux desktop environments (GNOME, KDE) cache `.desktop` icons in `~/.cache/thumbnails` or `/var/cache/`. Running `update-icon-caches` or restarting desktop sessions resolves cached icon displays.
