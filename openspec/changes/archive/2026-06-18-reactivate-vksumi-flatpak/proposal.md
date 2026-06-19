## Why

When vkSumi is installed via Flatpak (e.g., from custom remotes like `vksumi-origin`), it should be detected and supported properly within GOverlay just like MangoHud and vkBasalt. Currently, the vkSumi tab sheet is hidden in Flatpak mode, and GOverlay cannot detect the Flatpak version of vkSumi on the Home tab.

## What Changes

- Reactivate the vkSumi tab sheet under Flatpak mode so users can configure it when running in Flatpak.
- Implement dependency checking for vkSumi in Flatpak mode by looking for mapped Flatpak Vulkan extensions.
- Enable correct identification of Flatpak-installed vkSumi on the Home tab.
- Update the Flatpak packaging manifests (`io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml`) to ensure `/app/lib/extensions/vulkan/vkSumi` directory is created, enabling the Flatpak runtime to map the vkSumi Vulkan extension into the sandbox.

## Capabilities

### New Capabilities
- `vksumi-flatpak`: Detect, show, configure, and launch vkSumi Vulkan layer in Flatpak mode when installed as a Flatpak runtime extension.

### Modified Capabilities
<!-- Leave empty if no requirement changes -->

## Impact

- `goverlay_system.pas` / `apputils.pas`: Dependency checks updated to include vkSumi Flatpak runtime detection.
- `home_tab.pas`: Update Home tab dependency status resolution to correctly recognize vkSumi runtime presence in Flatpak.
- `overlayunit.pas`: Show `vksumiTabSheet` even when running in Flatpak.
- `flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`: Manifest build commands updated.
