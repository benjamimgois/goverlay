## Context

Flatpak `org.kde.Platform 6.10` runtime ships Noto Sans and DejaVu but no Nerd Fonts. GOverlay sidebar and game card ribbons use Nerd Font PUA glyphs rendered with `'Noto Sans'` font face. The native launcher (`goverlay.sh.in`) already handles this — it copies a bundled `SymbolsNerdFont-Regular.ttf` to `~/.local/share/fonts/` and runs `fc-cache`. The Flatpak launcher (`goverlay.sh.flatpak`) and build manifest do not.

Two items (MangoHud, OptiScaler) in sidebar already use PNG images loaded from bundled assets. The remaining three (Games, Post Processing, EnvVars) plus game card ribbons still use TLabel glyphs.

## Goals / Non-Goals

**Goals:**
- Make Nerd Font symbols available inside Flatpak sandbox at app startup
- Follow the same pattern as the native launcher (copy font + fc-cache)
- Add font as a Flatpak module with minimal overhead (~2MB download)

**Non-Goals:**
- Converting remaining sidebar items to PNG images (can be done later, orthogonal)
- Changing the font rendering code in sidebar_nav.pas or games_tab.pas
- Bundling the full Nerd Fonts package (just Symbols-Only variant)

## Decisions

### 1. Download Nerd Font Symbols from GitHub as Flatpak module

- **Choice**: Add a `flatpak-module-nerd-fonts` module that downloads `SymbolsNerdFont-Regular.ttf` from https://github.com/ryanoasis/nerd-fonts/releases
- **Rationale**: Repo-agnostic, automatic during Flatpak build, no need to commit binary font file to git. Same pattern as other modules (git, p7zip, volk).
- **Alternative considered**: Bundling font file in repo. Rejected — 2MB binary in git history is wasteful when it's publicly available from upstream releases.

### 2. Install font to `/app/share/fonts/TTF/` during build

- **Choice**: `install -Dm644 SymbolsNerdFont-Regular.ttf /app/share/fonts/TTF/SymbolsNerdFont-Regular.ttf`
- **Rationale**: Standard Flatpak font path. Allows font to be found by fontconfig as a fallback.

### 3. Copy font to `~/.local/share/fonts/` on app startup

- **Choice**: In `goverlay.sh.flatpak`, check if Nerd Font installed via `fc-list`, if not, copy from `/app/share/fonts/TTF/` and run `fc-cache -f`.
- **Rationale**: Mirrors the native launcher pattern. `~/.local/share/fonts/` is always in fontconfig search path. `fc-cache` ensures font is registered before the GUI opens.

### 4. Update native launcher font source path

- **Choice**: In `goverlay.sh.in`, add bundled path `@datadir@/goverlay/data/fonts/SymbolsNerdFont-Regular.ttf` as an additional source.
- **Rationale**: Native installs via `make install` already put fonts in `$(datadir)/goverlay/data/fonts/`. This ensures the native build also finds the font when system package isn't installed.

## Risks / Trade-offs

- **[Risk]** Font download URL may change or become unavailable → build failure.
  - **Mitigation**: Use specific release tag URL. If needed, mirror the font file in the repo as a fallback.
- **[Risk]** `fc-cache` may fail silently inside Flatpak sandbox → icons still missing.
  - **Mitigation**: `fc-cache` runs in background (`&`) to not block startup. If it fails, user sees tofu icons — same as current broken state. Can add the font to `/app/fonts/` as a secondary location.
