## Why

Under modern Linux distributions (Fedora, Arch Linux, Bazzite, SteamOS / Steam Deck) and udisks2, removable storage devices, USB drives, SD cards, and secondary partitions are mounted under `/run/media`. Currently, the Flatpak manifest files for GOverlay only grant read access to `/mnt:ro` and `/media:ro`. This prevents GOverlay from detecting Steam libraries and non-Steam games stored on SD cards or USB/external drives under `/run/media`.

## What Changes

- Add `- --filesystem=/run/media:ro` permission to `flatpak/io.github.benjamimgois.goverlay.yml`.
- Add `- --filesystem=/run/media:ro` permission to `flatpak/io.github.benjamimgois.goverlay.nightly.yml`.

## Capabilities

### New Capabilities
- `add-flatpak-run-media-permission`: Enables read-only access to `/run/media` mounts in GOverlay Flatpak manifests.

### Modified Capabilities

## Impact

- `flatpak/io.github.benjamimgois.goverlay.yml`: Added `/run/media:ro` filesystem permission under finish-args.
- `flatpak/io.github.benjamimgois.goverlay.nightly.yml`: Added `/run/media:ro` filesystem permission under finish-args.
