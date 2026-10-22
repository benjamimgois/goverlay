## Context

See `proposal.md` for background and problem motivation.

In GOverlay 1.9.1, `--filesystem=xdg-data/vulkan:create` was introduced in `flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`. Additionally, `CheckAndInstallVkSumi` and `CheckAndInstallMako` ran without a Flatpak sandbox check in `overlayunit.pas` (`TStartupDownloadThread`). When the vkSumi download failed with HTTP 404, curl saved the error text as `libVkLayer_vksumi.so`, which GOverlay registered as a global implicit Vulkan layer in the host's `~/.local/share/vulkan/implicit_layer.d/`. This corrupted layer crashed SteamOS's `gamescope` and `gamescope-mangoapp` on boot.

## Goals / Non-Goals

**Goals:**
- Completely isolate the Flatpak sandbox from host Vulkan layer directories by removing `xdg-data/vulkan` access.
- Guard `CheckAndInstallVkSumi` and `CheckAndInstallMako` to immediately exit when running in Flatpak (`IsRunningInFlatpak`).
- Enforce curl `--fail` / `-f` and minimum file size / ELF magic validation on all binary downloads to prevent saving 404 error text as shared libraries.
- Clean up any legacy corrupt layer files (`vksumi.json` pointing to invalid ELF binaries) if detected.

**Non-Goals:**
- Creating Flathub VulkanLayer extensions for vkSumi or MAKO in this change (that is managed via separate Flathub pull requests).
- Reworking how explicit Vulkan layers are passed to Steam launch options.

## Decisions

### Decision 1: Remove `xdg-data/vulkan` from Flatpak manifests
- **Rationale**: Flatpak sandboxes should never have write access to host Vulkan data. Any Vulkan layer needed inside Flatpak must come from Flatpak runtime extensions (e.g. `org.freedesktop.Platform.VulkanLayer.*`). Writing implicit layers to the host risks breaking the host display server (`gamescope` on SteamOS).
- **Alternatives considered**: Read-only access (`:ro`). Rejected because GOverlay doesn't need to read host implicit layers inside the sandbox.

### Decision 2: Guard `CheckAndInstallVkSumi` and `CheckAndInstallMako` with `IsRunningInFlatpak`
- **Rationale**: Mirrors the established pattern in `CheckAndInstallLsfgVk`:
  ```pascal
  if IsRunningInFlatpak then
  begin
    WriteLn('[AUTO-INSTALL] Flatpak environment detected; skipping host layer installation');
    Exit;
  end;
  ```
  This guarantees that even if filesystem permissions were somehow available, the download thread will never attempt to install host binaries from inside Flatpak.

### Decision 3: Enforce `--fail` and HTTP status verification in Curl downloads
- **Rationale**: `curl -sL` without `-f` / `--fail` outputs the HTTP 404 / 500 error page directly to the `-o` file. Adding `--fail` ensures curl exits with a non-zero code on HTTP errors and deletes/does not create the output file.
- **Alternatives considered**: Inspecting HTTP headers via a separate curl call. Rejected as `--fail` does this atomically in a single request.

### Decision 4: Validate binary size and ELF header before creating layer JSON
- **Rationale**: Before generating `vksumi.json` or any implicit layer manifest, verify:
  1. The target `.so` file exists and has size > 64 KB.
  2. The first 4 bytes match the ELF magic number (`0x7F 'E' 'L' 'F'`).
  If validation fails, delete the invalid file and abort manifest creation.

## Risks / Trade-offs

- **[Risk] Existing installations on Steam Deck still have broken manifests from 1.9.1** → **Mitigation**: Add a sanity check on GOverlay startup that checks for `~/.local/share/vulkan/implicit_layer.d/vksumi.json`. If the referenced `.so` is missing or invalid ELF, safely remove the stale JSON.
- **[Risk] Flatpak users won't get vkSumi installed** → **Mitigation**: vkSumi in Flatpak must be provided via Flathub extension or configured explicitly per-game, not injected into host compositor space.
