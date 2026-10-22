## Purpose

Automates the installation and mounting of Vulkan layer extensions (MangoHud and vkBasalt) for Goverlay's Flatpak package via Flathub extension autodownload declarations.

## ADDED Requirements

### Requirement: Declare MangoHud and vkBasalt Flatpak Extensions
The Flatpak package manifests SHALL declare extension points for `org.freedesktop.Platform.VulkanLayer.MangoHud` and `org.freedesktop.Platform.VulkanLayer.vkBasalt` with automatic download enabled.

#### Scenario: Installing Goverlay from Flathub
- **WHEN** a user installs Goverlay via `flatpak install io.github.benjamimgois.goverlay` or a software center
- **THEN** the Flatpak package manager automatically downloads and mounts the `25.08` branch of `org.freedesktop.Platform.VulkanLayer.MangoHud` and `org.freedesktop.Platform.VulkanLayer.vkBasalt`.

### Requirement: Vulkan Layer Extension Directory Mapping
The Flatpak manifest SHALL configure extensions to be mapped to `/app/lib/extensions/vulkan/MangoHud` and `/app/lib/extensions/vulkan/vkBasalt` with library paths added to the search path.

#### Scenario: Running 3D preview demo PasCube inside Flatpak
- **WHEN** PasCube is executed within the Goverlay Flatpak container
- **THEN** the Vulkan loader discovers and loads the MangoHud and vkBasalt layer extensions mounted at `/usr/lib/extensions/vulkan` and `/app/lib/extensions/vulkan`.
