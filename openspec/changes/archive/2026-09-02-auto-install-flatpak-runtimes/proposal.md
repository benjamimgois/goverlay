## Why

When installing Goverlay via Flatpak, users often encounter missing runtime dependencies for MangoHud, vkBasalt, and vkSumi. Currently, users are required to manually run terminal commands to install Flatpak runtime extensions from Flathub or standalone bundles. Because many users do not read the manual README installation steps, they assume Goverlay is broken when overlay features and the PasCube preview do not work out of the box.

Automating the installation of Flatpak Vulkan extensions (`MangoHud`, `vkBasalt`) via Flathub extension autodownload, and providing automated user-space download and registration for `vkSumi` during the startup boot splash, will eliminate manual setup and deliver a zero-configuration experience.

## What Changes

- **Flatpak Manifest Extension Autodownload**: Add `add-extensions` entries for `org.freedesktop.Platform.VulkanLayer.MangoHud` and `org.freedesktop.Platform.VulkanLayer.vkBasalt` in `flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml` with `autodownload: true`, matching the runtime version branch (`25.08` or equivalent).
- **Automated vkSumi Layer Download & Registration**: Add `CheckAndInstallVkSumi` in `optiscaler_update.pas` and call it from `TStartupDownloadThread` during the boot splash sequence. This downloads the latest `libVkLayer_vksumi.so` to `~/.local/share/goverlay/layers/vksumi/` and registers the layer in `~/.local/share/vulkan/implicit_layer.d/vksumi.json`.
- **System Detection & UI Status Updates**: Ensure `CheckDependencies` in `goverlay_system.pas` and `home_tab.pas` recognizes user-space vkSumi installations in `~/.local/share/vulkan/implicit_layer.d/vksumi.json` when running in both Flatpak and native modes.
- **Documentation Updates**: Simplify the Flatpak installation guide in `README.md` and `CONTRIBUTING.md` by removing manual extension install steps.

## Capabilities

### New Capabilities
- `flatpak-auto-runtimes`: Automatic installation of Flatpak Vulkan layer extensions (`MangoHud`, `vkBasalt`) via manifest extension points with `autodownload: true`.
- `vksumi-auto-install`: Automatic download, user-space extraction, and Vulkan layer manifest generation for `vkSumi` during startup.

### Modified Capabilities
<!-- No requirement changes to existing capabilities -->

## Impact

- **Manifests**: `flatpak/io.github.benjamimgois.goverlay.yml`, `flatpak/io.github.benjamimgois.goverlay.nightly.yml`.
- **Pascal Units**: `optiscaler_update.pas` (vkSumi download logic), `overlayunit.pas` (splash thread integration), `goverlay_system.pas` (dependency detection), `home_tab.pas` (UI status dots).
- **Documentation**: `README.md`, `CONTRIBUTING.md`.
- **User Experience**: First-time Flatpak and native launch will automatically provision all required layers without user intervention.
