# Capability Spec: DLSS-Enabler Streamline SDK Integration

## Specification

### Streamline SDK Download & Caching
- GOverlay SHALL query `https://api.github.com/repos/NVIDIA-RTX/Streamline/releases/latest` to retrieve the latest Streamline SDK release.
- GOverlay SHALL download the release ZIP asset and extract all `.dll` files located in the `/bin/x64/` directory into `~/.local/share/goverlay/dlssenabler-stable/` and `~/.local/share/goverlay/dlssenabler-edge/`.
- GOverlay SHALL write `streamlineversion=<version>` to `goverlay.vars` in the respective cache directory.

### Software Status UI Card
- The Software Status card on the Upscalers tab SHALL display a row for `Streamline SDK` with the installed version (e.g. `2.12.0`).

### Game Directory Deployment (`bgmod`)
- WHEN `UPSCALER_TYPE=1` (DLSS Enabler), `bgmod` SHALL copy Streamline DLLs (`sl.*.dll`) from the active DLSS Enabler cache directory into the target game directory.
