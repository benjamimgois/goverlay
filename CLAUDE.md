# Goverlay — Project Context

## What is this project

Goverlay is a Linux GUI application for configuring gaming enhancement tools:
- **MangoHud** — performance overlay and monitoring
- **vkBasalt** — Vulkan post-processing effects (shaders, color correction)
- **OptiScaler** — AI upscaling and frame generation

The goal is to make these tools accessible without manually editing config files. Distributed primarily via AUR and AppImage, also available on Flathub.

**Dual-target requirement:** all features must work correctly for both native (non-Flatpak) applications and Flatpak-sandboxed games/apps. Follow Flathub packaging guidelines when applicable — this affects config paths, permission scopes, and how external tools are invoked.

## Tech Stack

- **Language:** Free Pascal (FPC)
- **GUI Framework:** Lazarus LCL with Qt6 backend (via libqt6pas)
- **Build tool:** `lazbuild` (Lazarus CLI compiler)
- **Packaging:** AUR and AppImage (primary), Flathub (secondary), native packages

## Build Commands

```bash
make              # compile the project (release mode, -O3)
make install      # install to /usr/local (binary, desktop entry, man page, icons)
make uninstall    # remove installed files
make clean        # remove compiled artifacts
make tests        # validate AppStream metadata and .desktop file
make tarball      # create distribution archive
```

Build output: binary at root, object files in `lib/x86_64-linux/`.

## Project Structure

```
goverlay.lpr          # program entry point — initializes and creates all forms
goverlay.lpi          # Lazarus project config (do not edit manually)
overlayunit.pas       # main UI form (~10k lines) — MangoHud, vkBasalt, OptiScaler tabs
constants.pas         # all app constants: version, URLs, config file names, paths
configmanager.pas     # config path resolution (XDG-compliant, Flatpak-aware)
systemdetector.pas    # detects GPU vendor, session type (X11/Wayland), distro
themeunit.pas         # light/dark theme system
optiscaler_update.pas # OptiScaler/fgmod download and update logic
data/                 # desktop entry, AppStream metadata, icons, man page, fgmod scripts
appimage/             # AppImage packaging files
```

Each dialog or feature area has a `.pas` unit + a `.lfm` visual form file (e.g. `blacklistunit.pas` + `blacklistunit.lfm`).

## Important Conventions

**Config file locations (runtime):**
- MangoHud: `~/.config/MangoHud/MangoHud.conf`
- vkBasalt: `~/.config/vkBasalt/vkBasalt.conf`
- Goverlay metadata: `~/.config/goverlay/`

**Flatpak awareness:** The app must handle two distinct scenarios:
1. **Goverlay itself running as Flatpak** — sandbox restrictions apply; paths and permissions differ from native install.
2. **Target games/apps running as Flatpak** — MangoHud, vkBasalt, and OptiScaler must be injected into Flatpak-sandboxed processes correctly.

Several code paths in `configmanager.pas` and `overlayunit.pas` detect these conditions and adjust paths/permissions accordingly. Always follow Flathub guidelines when touching file I/O, process spawning, or permission handling.

**XDG compliance:** Config and data paths respect the XDG Base Directory spec. Do not hardcode `~/.config` paths; use the helpers in `configmanager.pas`.

## Runtime Dependencies

Required: `mangohud`, `vkbasalt`, `mesa-demos`, `vulkan-tools`, `git`, `libqt6pas`
Optional: `zenergy` (AMD power metrics), `pascube` (OpenGL preview cube)

## Gotchas

- **Do not edit `.lfm` files manually** — they are visual form definitions managed by the Lazarus IDE. Manual edits can corrupt the UI layout.
- `overlayunit.pas` is intentionally large (~10k lines). It is the monolithic main form and has not been split by design.
- `goverlay.lpi` is managed by the Lazarus IDE — avoid manual edits.
- The binary installed by `make install` goes to `/usr/local/libexec/goverlay`; the launcher script at `/usr/local/bin/goverlay` wraps it.
