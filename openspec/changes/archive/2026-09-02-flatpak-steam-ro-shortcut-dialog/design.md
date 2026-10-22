## Context

Flathub moderation flags write access to foreign application directories like Steam (`~/.local/share/Steam:rw`). While native packages (e.g. deb, rpm, AUR) can safely modify Steam's `shortcuts.vdf` directly via the bundled Python helper, Flatpak sandboxing strictly limits cross-app filesystem mutation. In Flatpak, GOverlay only needs read-only access to Steam directories to detect installed games, library locations, and covers.

## Goals / Non-Goals

### Goals
- Switch Steam filesystem permissions to `:ro` in both `io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml`.
- Display a clear, user-friendly informational dialog in English when a Flatpak user clicks "Create Steam Shortcut".
- Retain full automated shortcut creation functionality for native (non-Flatpak) installations.

### Non-Goals
- Attempting sandbox escape via portals or DBus host command execution.

## Decisions

1. **Manifest File Permissions**: Change `~/.local/share/Steam:rw`, `~/.steam:rw`, and `~/.var/app/com.valvesoftware.Steam:rw` to `:ro`.
2. **Runtime Detection**: Use `IsRunningInFlatpak` in `CreateSteamShortcutMenuItemClick` in `overlayunit.pas`.
3. **User Guidance**: Present an English dialog detailing:
   - Method 1: Right-click GOverlay in Application Menu -> "Add to Steam".
   - Method 2: Steam Client -> Games -> "Add a Non-Steam Game to My Library...".
