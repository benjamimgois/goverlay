## Why

When adding GOverlay as a non-Steam shortcut via "Create Steam Shortcut", Steam only receives the desktop icon path in `shortcuts.vdf`. On Steam Deck (Gaming Mode) and Steam Big Picture, Steam does not use `shortcuts.vdf`'s icon for library cards, banners, or logos—it looks exclusively for custom grid artwork inside `userdata/<user_id>/config/grid/`. As a result, GOverlay currently appears as a generic blank gray rectangle in the Steam Deck library and detail views. Adding complete Steam Grid artwork integration ensures GOverlay looks native and polished across Steam Deck and desktop Steam libraries.

## What Changes

- Bundle dedicated Steam Grid artwork assets (vertical cover/poster, wide banner, hero background, logo, and square icon) in GOverlay's data directory.
- Update `assets/goverlay-steam-shortcut.py` to calculate Steam Grid IDs (both 64-bit and 32-bit for cross-version compatibility) and populate `config/grid/` with the appropriate artwork files (`<id>p.png`, `<id>.png`, `<id>_hero.png`, `<id>_logo.png`, `<id>_icon.png`) when adding a shortcut.
- Update shortcut removal logic in `goverlay-steam-shortcut.py` to clean up associated grid artwork files when the shortcut is removed.
- Ensure build and packaging systems (`Makefile`, Flatpak packaging, AppImage) install and distribute the grid assets correctly.
- Update Pascal shortcut handler in `overlayunit.pas` to resolve the grid assets path and pass it to the helper script.

## Capabilities

### New Capabilities
- `steam-shortcut-artwork`: Automated generation, placement, and management of Steam Grid artwork assets (vertical poster, horizontal banner, hero background, transparent logo, and icon) for GOverlay non-Steam shortcuts.

### Modified Capabilities
<!-- None -->

## Impact

- `assets/goverlay-steam-shortcut.py`: Extended CLI arguments and logic to copy/delete grid assets in user config folders.
- `data/steam_grid/` or `assets/steam_grid/`: New bundled artwork files (cover 600x900, banner 920x430, hero 1920x620, logo 640x360, icon 512x512).
- `overlayunit.pas`: Updated path detection and argument passing for `goverlay-steam-shortcut.py`.
- `Makefile`: Installation rules to deploy grid assets to `/usr/share/goverlay/data/steam_grid/` (or similar).
