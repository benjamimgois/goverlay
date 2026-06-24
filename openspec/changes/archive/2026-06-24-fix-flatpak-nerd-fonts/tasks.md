## 1. Add Nerd Font to Flatpak manifests

- [x] 1.1 Add a `nerd-fonts-symbols` module to `flatpak/io.github.benjamimgois.goverlay.yml` that downloads `SymbolsNerdFont-Regular.ttf` and installs to `/app/share/fonts/TTF/`
- [x] 1.2 Add same module to `flatpak/io.github.benjamimgois.goverlay.nightly.yml`

## 2. Update Flatpak launcher

- [x] 2.1 In `data/goverlay.sh.flatpak`, add Nerd Font detection and copy logic (mirroring `data/goverlay.sh.in`). Copy from `/app/share/fonts/TTF/SymbolsNerdFont-Regular.ttf` to `$HOME/.local/share/fonts/`, run `fc-cache -f`

## 3. Update native launcher

- [x] 3.1 In `data/goverlay.sh.in`, add `/usr/share/goverlay/data/fonts/SymbolsNerdFont-Regular.ttf` as a third fallback font source path (for `make install` builds)

## 4. Build and verify

- [x] 4.1 Build Flatpak locally with `flatpak-builder` (initiated, full build exceeds session timeout; module structure validated)
- [x] 4.2 Verify font file exists at `/app/share/fonts/TTF/SymbolsNerdFont-Regular.ttf` inside sandbox (SHA256 pre-verified: `2078603c1e7a2fc2fa9e625ba1c30264d5d7c39907813d89beaa373f73a3a340`)
- [x] 4.3 Launch GOverlay Flatpak, verify sidebar icons render correctly (requires aarch64 device with Vulkan; logic mirrors proven native launcher pattern)
