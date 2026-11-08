# flatpak-auto-runtimes Specification

## Purpose
Automates the installation and mounting of Vulkan layer extensions (MangoHud and vkBasalt) for Goverlay's Flatpak package via Flathub extension autodownload declarations.

## Requirements

### Requirement: Declare MangoHud and vkBasalt Flatpak Extensions
The Flatpak package manifests SHALL declare extension points for `org.freedesktop.Platform.VulkanLayer.MangoHud` and `org.freedesktop.Platform.VulkanLayer.vkBasalt` with automatic download enabled.

#### Scenario: Installing Goverlay from Flathub
- **WHEN** a user installs Goverlay via `flatpak install io.github.benjamimgois.goverlay` or a software center
- **THEN** the Flatpak package manager automatically downloads and mounts the `25.08` branch of `org.freedesktop.Platform.VulkanLayer.MangoHud` and `org.freedesktop.Platform.VulkanLayer.vkBasalt`.

### Requirement: Vulkan Layer Extension Directory Mapping
The Flatpak manifest SHALL configure extensions to be mapped to `/app/lib/extensions/vulkan/MangoHud`, `/app/lib/extensions/vulkan/vkBasalt`, and `/app/lib/extensions/vulkan/lsfgvk` with library paths added to the search path, SHALL ensure all declared extension mount directories are created in `/app` during package build, and SHALL NOT grant filesystem access to host Vulkan data directories (`xdg-data/vulkan`) to prevent sandbox processes from polluting host implicit Vulkan layers.

#### Scenario: Running 3D preview demo PasCube inside Flatpak
- **WHEN** PasCube is executed within the Goverlay Flatpak container
- **THEN** the Vulkan loader discovers and loads the MangoHud and vkBasalt layer extensions mounted at `/usr/lib/extensions/vulkan` and `/app/lib/extensions/vulkan`.

#### Scenario: Initializing Flatpak container with lsfgvk extension
- **WHEN** Goverlay is executed inside the Flatpak container on a host with `org.freedesktop.Platform.VulkanLayer.lsfgvk` installed
- **THEN** Bubblewrap mounts the extension into `/app/lib/extensions/vulkan/lsfgvk` without encountering read-only file system directory creation errors.

#### Scenario: Sandboxed Vulkan data isolation
- **WHEN** Goverlay runs inside a Flatpak container
- **THEN** the sandbox does not mount host `~/.local/share/vulkan` and cannot write implicit Vulkan layer manifests to the host operating system.

### Requirement: Flatpak Extension Detection and Version Discovery
The system SHALL detect `MangoHud` and `vkBasalt` Vulkan layer extensions when mounted under `/app/lib/extensions/vulkan/` or `/usr/lib/extensions/vulkan/`, and SHALL extract their installed version from extension manifest metadata when executing inside a Flatpak container.

#### Scenario: Discovering MangoHud extension in Flatpak
- **WHEN** Goverlay runs inside Flatpak and `org.freedesktop.Platform.VulkanLayer.MangoHud` is mounted at `/app/lib/extensions/vulkan/MangoHud`
- **THEN** Goverlay detects `libMangoHud.so`, parses the extension version from `manifest.json`, marks MangoHud as installed in the System and Libraries view, and displays the installed version.

#### Scenario: Discovering vkBasalt extension in Flatpak
- **WHEN** Goverlay runs inside Flatpak and `org.freedesktop.Platform.VulkanLayer.vkBasalt` is mounted at `/app/lib/extensions/vulkan/vkBasalt`
- **THEN** Goverlay detects `libvkbasalt.so`, marks vkBasalt as installed in the System and Libraries view, and displays the installed version.

#### Scenario: Extension directories checked on startup
- **WHEN** Goverlay audits missing dependencies inside a Flatpak container
- **THEN** both `/app/lib/extensions/vulkan/<extension>` and `/usr/lib/extensions/vulkan/<extension>` are checked prior to reporting runtime dependencies as missing.
