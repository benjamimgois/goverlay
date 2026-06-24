## Why

Sidebar navigation icons (Games, Post Processing, EnvVars) and game card ribbon icons render Nerd Font Private Use Area glyphs via TLabel with `'Noto Sans'` font face. Inside Flatpak sandbox, the `org.kde.Platform` runtime has no Nerd Font — glyphs display as tofu (missing-character boxes). Only MangoHud and OptiScaler sidebar items work because they were already converted to PNG images.

## What Changes

- **Bundle** `SymbolsNerdFont-Regular.ttf` (symbols-only, ~2MB) in the Flatpak manifest via a download module.
- Install font to `/app/share/fonts/TTF/` during Flatpak build so fontconfig discovers it automatically.
- **Update** `data/goverlay.sh.flatpak` to copy the bundled font to `~/.local/share/fonts/` and run `fc-cache -f` on startup for backwards compatibility with existing image-based sandboxes.
- **Update** `data/goverlay.sh.in` (native launcher) to copy font from the bundled `/usr/share/goverlay/data/fonts/` directory instead of relying on host-installed font path.

## Capabilities

### New Capabilities

- `nerd-fonts-flatpak`: Ensure Nerd Font Symbols typeface is available inside Flatpak sandbox for icon rendering.

### Modified Capabilities

*(None)*

## Impact

- `flatpak/io.github.benjamimgois.goverlay.yml` — add font download and install module
- `flatpak/io.github.benjamimgois.goverlay.nightly.yml` — same
- `data/goverlay.sh.flatpak` — add font copy + fc-cache on startup
- `data/goverlay.sh.in` — update font source path to use bundled location
