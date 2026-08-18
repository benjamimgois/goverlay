# Proposal: Grant Flatpak Write Permission for Steam Shortcuts and Deduplicate Paths

## Problem Statement

When using the Flatpak version of GOverlay on Steam Deck or standard Linux desktop environments with native Steam, clicking "Create steam shortcut" fails with:
`Skipping (no write permission): /home/deck/.local/share/Steam/userdata/.../config/shortcuts.vdf` and `Failed to update any shortcuts.`

This failure happens because:
1. The Flatpak manifests (`flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`) grant only read-only access (`:ro`) to host Steam directories (`~/.local/share/Steam:ro` and `~/.steam:ro`).
2. The python helper script (`assets/goverlay-steam-shortcut.py`) scans multiple alias paths (`~/.local/share/Steam`, `~/.steam/steam`, `~/.steam/root`) without resolving symbolic links (`os.path.realpath`), leading to duplicate attempts and repeated permission error messages for the same physical `shortcuts.vdf` file.

## Proposed Solution

1. **Update Flatpak Manifests**:
   - Change `--filesystem=~/.local/share/Steam:ro` to `--filesystem=~/.local/share/Steam:rw`.
   - Change `--filesystem=~/.steam:ro` to `--filesystem=~/.steam:rw`.
   - Maintain `--filesystem=~/.var/app/com.valvesoftware.Steam:rw` for Flatpak Steam compatibility.

2. **Deduplicate Shortcuts Paths in Python Script**:
   - In `assets/goverlay-steam-shortcut.py`, resolve candidate `shortcuts.vdf` paths using `os.path.realpath` before adding them to the processing list.
   - Ensure each physical `shortcuts.vdf` file on the filesystem is processed and reported only once.

## Capabilities

### Modified Capabilities
- `steam-shortcut-settings`: Enables write access to native Steam userdata folders inside Flatpak sandbox and ensures accurate, non-redundant shortcut file discovery.

## Impact

- Flatpak GOverlay can seamlessly create Steam shortcuts on Steam Deck and all Linux distributions with native Steam installations.
- Zero duplicate file warnings when symlinked Steam paths exist.
- Backward and forward compatible with native package builds (deb, rpm, arch, appimage) and Flatpak Steam.
