# Design: Grant Flatpak Write Permission for Steam Shortcuts and Deduplicate Paths

## Context

GOverlay provides a "Create Steam shortcut" option in its settings popup to add GOverlay to Steam as a non-Steam shortcut.
The underlying implementation uses `assets/goverlay-steam-shortcut.py` executed by `overlayunit.pas`.
In Flatpak builds, the sandbox was granted write access to `~/.var/app/com.valvesoftware.Steam`, but only read-only access (`:ro`) to `~/.local/share/Steam` and `~/.steam`.
As a result, Steam Deck and Linux desktop users with native Steam receive permission errors when creating the shortcut from Flatpak GOverlay.

## Goals / Non-Goals

**Goals:**
- Update Flatpak manifests (`io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml`) to grant read-write access to native Steam paths (`~/.local/share/Steam:rw`, `~/.steam:rw`).
- Deduplicate candidate `shortcuts.vdf` files in `assets/goverlay-steam-shortcut.py` by resolving real paths (`os.path.realpath`).

**Non-Goals:**
- Changing the binary VDF parser or serializer logic.
- Altering the command options passed to Steam shortcuts.

## Decisions

### 1. Update Flatpak Manifests
In `flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`:
```yaml
finish-args:
  ...
  - --filesystem=~/.local/share/Steam:rw
  - --filesystem=~/.steam:rw
  - --filesystem=~/.var/app/com.valvesoftware.Steam:rw
```
- **Rationale**: Follows standard Flathub permissions for Steam utility apps (such as ProtonUp-Qt and BoilR), allowing modification of `shortcuts.vdf` in native Steam directories.

### 2. Deduplicate Symlinked Steam Paths in Python Helper
In `assets/goverlay-steam-shortcut.py`:
```python
shortcut_files = []
for base in base_dirs:
    if os.path.isdir(base):
        for user_dir in os.listdir(base):
            config_dir = os.path.join(base, user_dir, "config")
            if os.path.isdir(config_dir):
                vdf_path = os.path.realpath(os.path.join(config_dir, "shortcuts.vdf"))
                if vdf_path not in shortcut_files:
                    shortcut_files.append(vdf_path)
```
- **Rationale**: Resolves `~/.steam/steam/...` and `~/.steam/root/...` symlinks to `~/.local/share/Steam/...`, preventing redundant operations and duplicate log messages.

## Risks / Trade-offs

- **Risk**: User has no write permissions on the host file even with Flatpak permissions (e.g. file owned by root).
  - **Mitigation**: The python script already includes `os.access(vdf_path, os.W_OK)` checking and clear logging per file.
