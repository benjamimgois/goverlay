## Why

When GOverlay runs inside a Flatpak sandbox, it fails to persist manually added non-Steam game folders (game cards). This happens because GOverlay hardcodes the path to `~/.config/goverlay/nonsteam_folders.txt`, which is read-only inside the Flatpak sandbox. As a result, the list of folders is not saved and the game cards disappear after restarting GOverlay.

## What Changes

- Modify `games_tab.pas` to resolve the path for `nonsteam_folders.txt` dynamically using GOverlay's config folder resolver (`TConfigManager.GetGoverlayFolder`) instead of hardcoding `GetUserDir + '.config/goverlay/nonsteam_folders.txt'`.
- This ensures GOverlay writes to a writable persistent sandbox folder (`~/.var/app/io.github.benjamimgois.goverlay/config/goverlay/`) under Flatpak, and continues using `~/.config/goverlay/` under native environments.

## Capabilities

### New Capabilities

### Modified Capabilities

- `flatpak-config-paths`: Extend path resolution rules to include GOverlay's internal configuration (specifically `nonsteam_folders.txt`), requiring that they use the Flatpak-aware configuration directory.

## Impact

- **Affected Files**: `games_tab.pas`
- **Dependencies/APIs**: Uses `TConfigManager` to query the config directory location.
