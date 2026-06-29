## Context

GOverlay uses Nerd Font symbol glyphs in its GTK/Lazarus user interface for sidebar navigation icons and game card badges. When running inside Flatpak (`org.kde.Platform 6.10`), the environment does not include Nerd Fonts by default. While a build module was introduced to bundle `SymbolsNerdFont-Regular.ttf`, two technical issues prevented it from working:
1. The Flatpak manifest modules included `cleanup: - "*"` for `nerd-fonts-symbols`, causing `flatpak-builder` to delete the installed TTF file upon build completion.
2. The launcher script `data/goverlay.sh.flatpak` ran `fc-cache -f` asynchronously in the background (`&`), allowing the GUI binary to launch before Fontconfig registered the new font.

## Goals / Non-Goals

**Goals:**
- Ensure `SymbolsNerdFont-Regular.ttf` persists in `/app/share/fonts/TTF/` within the compiled Flatpak bundle.
- Ensure font registration via `fc-cache` completes synchronously before the main GUI executable launches inside Flatpak.

**Non-Goals:**
- Modifying font handling for AppImage or native package builds (which are functioning as intended).

## Decisions

### 1. Remove cleanup directive in Flatpak manifests
- **Choice**: Delete the `cleanup: - "*"` block under the `nerd-fonts-symbols` module in `flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`.
- **Rationale**: The `cleanup` key in `flatpak-builder` purges matched files post-build. Removing it allows `/app/share/fonts/TTF/SymbolsNerdFont-Regular.ttf` to remain in the installed sandbox filesystem.

### 2. Synchronous fc-cache execution in launcher
- **Choice**: In `data/goverlay.sh.flatpak`, replace `fc-cache -f "$FONT_DST" >/dev/null 2>&1 &` with `fc-cache -f "$FONT_DST" >/dev/null 2>&1`.
- **Rationale**: Removing the trailing `&` blocks execution until Fontconfig updates its cache index, ensuring GTK and Lazarus pick up the Nerd Font font family on first startup.

## Risks / Trade-offs

- **[Risk] Slight startup delay on first launch** → Mitigated because `fc-cache -f` on a single TTF file takes less than 100ms and only runs when the font is not yet registered in fontconfig.
