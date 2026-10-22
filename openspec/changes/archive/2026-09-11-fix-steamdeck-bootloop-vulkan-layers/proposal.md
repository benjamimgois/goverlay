## Why

In GOverlay 1.9.1, `--filesystem=xdg-data/vulkan:create` was added to Flatpak permissions, and startup download routines (`CheckAndInstallVkSumi` and `CheckAndInstallMako`) were executed unconditionally inside Flatpak. This caused corrupted, partial, or missing Vulkan layers to be written directly into the host user's `~/.local/share/vulkan/implicit_layer.d/`.

On SteamOS / Steam Deck, `gamescope` (the display server/compositor) and `steamwebhelper` (via `capsule-capture-libs`) scan all host implicit Vulkan layers during boot. Due to a 404 response on the vkSumi fallback download producing an invalid 9-byte text file (`invalid 'Elf' handle`) and MAKO layers missing host `.so` libraries, `gamescope`, `gamescope-mangoapp`, and the Steam session crash immediately with `SIGABRT`, resulting in an unbootable black screen / boot loop on Steam Deck.

Preventing host Vulkan layer pollution from Flatpak and ensuring strict binary download verification is urgent to protect user systems and restore boot stability.

## What Changes

- **Flatpak Permission Confinement**: Remove `--filesystem=xdg-data/vulkan:create` from both `io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml` to ensure Flatpak sandboxes can never register host-level implicit Vulkan layers.
- **Flatpak Auto-install Guarding**: Guard `CheckAndInstallVkSumi` and `CheckAndInstallMako` with `if IsRunningInFlatpak then Exit;`, matching the existing protection in `CheckAndInstallLsfgVk`.
- **Download Integrity Verification**: Update `RunCurlWithProgress` and direct curl invocations to pass `--fail` / `-f` so HTTP error responses (such as 404 Not Found) fail cleanly instead of writing error text into binary `.so` files.
- **Binary Validation**: Ensure layer manifests (`vksumi.json`, etc.) are only generated if the target shared library exists, is non-empty, and satisfies minimum size requirements (> 10 KB).

## Capabilities

### Modified Capabilities
- `flatpak-auto-runtimes`: Forbid `--filesystem=xdg-data/vulkan` access from Flatpak manifests to prevent polluting host Vulkan layers.
- `vksumi-auto-install`: Restrict vkSumi auto-installation to native environments only, enforce `--fail` on downloads, and validate binary integrity before manifest creation.
- `mako-engine-management`: Restrict standalone MAKO auto-installation to native environments only to avoid registering incomplete layer manifests on host systems.

## Impact

- **Affected Code**: `flatpak/io.github.benjamimgois.goverlay.yml`, `flatpak/io.github.benjamimgois.goverlay.nightly.yml`, `optiscaler_update.pas`.
- **System Stability**: Completely eliminates the risk of GOverlay causing SteamOS Game Mode / `gamescope` crashes and bootloops upon installation.
