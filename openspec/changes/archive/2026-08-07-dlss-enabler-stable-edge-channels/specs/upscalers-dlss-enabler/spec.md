# Capability Spec: DLSS-Enabler Dual Channel (Stable & Bleeding-edge)

## Specification

### Channel & Download Resolution
- GOverlay SHALL query `https://api.github.com/repos/benjamimgois/OptiScaler-builds/contents/de?ref=nightly-action` to list available builds.
- GOverlay SHALL parse the version string from matching build filenames by extracting the text segment following `"DLSS Enabler "` up to the first space.
- WHEN Stable channel is selected for DLSS Enabler (`OPT_CHANNEL=0`), GOverlay SHALL download the build filename containing `"STABLE"` into `~/.local/share/goverlay/dlssenabler-stable/`.
- WHEN Bleeding-edge channel is selected for DLSS Enabler (`OPT_CHANNEL=1`), GOverlay SHALL download the build filename containing `"TRUNK"` into `~/.local/share/goverlay/dlssenabler-edge/`.
- GOverlay SHALL extract `version.dll` from the downloaded ZIP archive into the respective channel cache directory.
- GOverlay SHALL write `dlssenablerversion=<parsed_version>` and `upscalertype=1` to `goverlay.vars` inside the channel directory.

### Game Directory Deployment (`bgmod`)
- WHEN `UPSCALER_TYPE=1` (DLSS Enabler) is set in `bgmod.conf`, `bgmod` SHALL install standard OptiScaler base files (`OptiScaler.ini`, `libxess.dll`, `fakenvapi.dll`, `plugins/`, etc.) from `optiscaler-stable` into the game directory.
- `bgmod` SHALL copy `version.dll` from the active DLSS Enabler channel directory (`dlssenabler-stable` or `dlssenabler-edge`) over `GameDir/OptiScaler.dll`.
- `bgmod` SHALL copy `GameDir/OptiScaler.dll` (which contains DLSS Enabler's `version.dll`) to the configured `DllName` (e.g., `dxgi.dll`, `version.dll`, `winmm.dll`).
- `bgmod` SHALL write `goverlay.vars` to `GameDir` with `upscalertype=1` and `dlssenablerversion=<version>`.
