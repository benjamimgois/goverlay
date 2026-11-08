# Spec Delta

## ADDED Requirements

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
