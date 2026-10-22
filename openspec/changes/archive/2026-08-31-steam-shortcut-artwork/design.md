## Context

GOverlay provides a "Create Steam Shortcut" option from its menu that runs `assets/goverlay-steam-shortcut.py`. Currently, it only configures the executable, name, launch options, and basic `icon` string inside `shortcuts.vdf`. Steam Deck (Gaming Mode) and Steam Big Picture do not use `shortcuts.vdf` for rendering grid cards, banners, or page headers; they read custom artwork from `userdata/<user_id>/config/grid/`.

See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Bundle high quality artwork assets formatted to Steam's exact specifications (`cover.png`, `banner.png`, `hero.png`, `logo.png`, `icon.png`).
- Automate artwork copying with appropriate 64-bit and 32-bit shortcut IDs to all discovered Steam user profile directories (`config/grid/`).
- Handle clean deletion of artwork when removing shortcuts.
- Support both system-installed (native/distro), source tree, Flatpak, and AppImage runtimes.

**Non-Goals:**
- Fetching third-party artwork dynamically from SteamGridDB at runtime (assets should be bundled offline with GOverlay).
- Editing or modifying grid assets for other non-GOverlay shortcuts.

## Decisions

### 1. Asset Storage and Resolution
- Store bundled source artwork in `data/steam_grid/` inside the repository.
- During `make install`, copy `data/steam_grid/` to `$(DESTDIR)$(prefix)$(datadir)/goverlay/data/steam_grid/`.
- In `overlayunit.pas` and `goverlay-steam-shortcut.py`, resolve the artwork directory dynamically using `GetAppBaseDir` or path discovery with local relative fallback.

### 2. Dual AppID File Naming in `config/grid/`
- Steam generates a 32-bit AppID `short_id = crc32(exe + appname) | 0x80000000` and a 64-bit Grid ID `long_id = (short_id << 32) | 0x02000000`.
- Different Steam client versions (Steam Deck Gaming Mode vs Steam Desktop vs Big Picture) may look up artwork using either the 64-bit or 32-bit ID.
- The Python script will write both variations (or hardlink/copy):
  - Cover (Vertical 600x900): `<long_id>p.png` and `<short_id>p.png`
  - Wide Banner (Horizontal 920x430): `<long_id>.png` and `<short_id>.png`
  - Hero (Background 1920x620): `<long_id>_hero.png` and `<short_id>_hero.png`
  - Logo (Title Overlay): `<long_id>_logo.png` and `<short_id>_logo.png`
  - Icon (Square 512x512): `<long_id>_icon.png` and `<short_id>_icon.png`

### 3. Cleanup Strategy on Removal
- When `goverlay-steam-shortcut.py remove` is executed, it calculates the IDs for the shortcut and deletes any matching files in `userdata/<user_id>/config/grid/`.

## Risks / Trade-offs

- **[Steam Overwriting while running]** → Steam must be closed when writing `shortcuts.vdf` or adding grid files. `overlayunit.pas` already checks `IsProcessRunningPure('steam')` before invoking the script.
- **[Multiple Steam Users]** → Steam installs with multiple user IDs in `userdata/` will receive the artwork in all detected active user profiles.
