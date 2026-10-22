## MODIFIED Requirements

### Requirement: Vulkan Layer Extension Directory Mapping
The Flatpak manifest SHALL configure extensions to be mapped to `/app/lib/extensions/vulkan/MangoHud`, `/app/lib/extensions/vulkan/vkBasalt`, and `/app/lib/extensions/vulkan/lsfgvk` with library paths added to the search path, and SHALL ensure all declared extension mount directories are created in `/app` during package build.

#### Scenario: Running 3D preview demo PasCube inside Flatpak
- **WHEN** PasCube is executed within the Goverlay Flatpak container
- **THEN** the Vulkan loader discovers and loads the MangoHud and vkBasalt layer extensions mounted at `/usr/lib/extensions/vulkan` and `/app/lib/extensions/vulkan`.

#### Scenario: Initializing Flatpak container with lsfgvk extension
- **WHEN** Goverlay is executed inside the Flatpak container on a host with `org.freedesktop.Platform.VulkanLayer.lsfgvk` installed
- **THEN** Bubblewrap mounts the extension into `/app/lib/extensions/vulkan/lsfgvk` without encountering read-only file system directory creation errors.
