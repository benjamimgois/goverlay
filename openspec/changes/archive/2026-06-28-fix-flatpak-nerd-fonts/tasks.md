## 1. Manifest Cleanup Fix

- [x] 1.1 Remove `cleanup: - "*"` from `nerd-fonts-symbols` module in `flatpak/io.github.benjamimgois.goverlay.yml`.
- [x] 1.2 Remove `cleanup: - "*"` from `nerd-fonts-symbols` module in `flatpak/io.github.benjamimgois.goverlay.nightly.yml`.

## 2. Launcher Synchronization Fix

- [x] 2.1 Update `data/goverlay.sh.flatpak` to run `fc-cache -f "$FONT_DST"` synchronously (remove background `&`).
