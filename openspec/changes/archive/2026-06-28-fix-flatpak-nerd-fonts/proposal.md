## Why

In the GOverlay Flatpak build, Nerd Fonts symbol glyphs are currently unavailable, causing several main menu icons and sidebar elements to render as missing/broken characters. This happens because `flatpak-builder` purges the installed `SymbolsNerdFont-Regular.ttf` font during cleanup due to a misconfigured `cleanup: - "*"` directive in the module manifest, and because the launcher script executes `fc-cache` asynchronously in the background.

## What Changes

- Remove the `cleanup: - "*"` directive from the `nerd-fonts-symbols` module in both Flatpak manifests (`flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`).
- Update `data/goverlay.sh.flatpak` launcher script to run `fc-cache` synchronously (removing the background `&`) so font registration completes before GOverlay GUI starts.

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `nerd-fonts-flatpak`: Update font bundling cleanup behavior and launcher cache synchronization so Nerd Font symbols are properly accessible within the Flatpak sandbox.

## Impact

- `flatpak/io.github.benjamimgois.goverlay.yml`
- `flatpak/io.github.benjamimgois.goverlay.nightly.yml`
- `data/goverlay.sh.flatpak`
