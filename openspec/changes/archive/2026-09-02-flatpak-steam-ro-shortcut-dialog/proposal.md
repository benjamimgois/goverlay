## Why

Flathub review moderation rejected build 313503 due to write permissions on Steam directories (`~/.local/share/Steam:rw`, `~/.steam:rw`, `~/.var/app/com.valvesoftware.Steam:rw`). In a sandboxed Flatpak environment, directly manipulating Steam's internal `shortcuts.vdf` binary configuration is discouraged and violates Flathub security guidelines. Instead, Steam filesystem permissions should be read-only (`:ro`) for scanning libraries/games, and Flatpak users attempting to create a Steam shortcut should be guided via an informative dialog on how to add GOverlay to Steam from Desktop Mode.

## What Changes

- Revert Steam filesystem permissions from `:rw` to `:ro` in Flatpak manifests (`flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`).
- Add a localized resource string (`rsSteamShortcutFlatpakInfo`) in `goverlay_strings.pas` explaining in English how to add GOverlay to Steam in Desktop Mode via Application Menu or Steam client.
- Update `Tgoverlayform.CreateSteamShortcutMenuItemClick` in `overlayunit.pas` to detect `IsRunningInFlatpak` and display the informational dialog instead of attempting to write to Steam directories.

## Capabilities

### New Capabilities
- `flatpak-steam-shortcuts`: Handling Steam shortcut creation in Flatpak environment using read-only filesystem permissions and desktop instructions dialog.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Files**: `flatpak/io.github.benjamimgois.goverlay.yml`, `flatpak/io.github.benjamimgois.goverlay.nightly.yml`, `goverlay_strings.pas`, `overlayunit.pas`
- **Affected Systems**: Flatpak build and runtime behavior for Steam shortcut creation.
- **Breaking Changes**: None.
