## Why

When running the Flatpak build of GOverlay on systems where `org.freedesktop.Platform.VulkanLayer.lsfgvk` is installed (such as the Steam Deck), Bubblewrap fails to start the sandbox with:
`bwrap: Can't mkdir /app/lib/extensions/vulkan/lsfgvk: Read-only file system`
`erro: ldconfig falhou, status de saída 256`

This happens because `org.freedesktop.Platform.VulkanLayer.lsfgvk` was added under `add-extensions` with mount target `lib/extensions/vulkan/lsfgvk`, but the build commands in the Flatpak manifests do not create `/app/lib/extensions/vulkan/lsfgvk`. Because `/app` is mounted read-only inside the container at runtime, Bubblewrap cannot dynamically create the missing mount point directory, crashing container initialization.

## What Changes

- Add `mkdir -p /app/lib/extensions/vulkan/lsfgvk` to the `build-commands` of the `goverlay` module in:
  - `flatpak/io.github.benjamimgois.goverlay.nightly.yml`
  - `flatpak/io.github.benjamimgois.goverlay.yml`
- Ensure that the extension directory `/app/lib/extensions/vulkan/lsfgvk` exists inside the `/app` prefix prior to container assembly and execution.

## Capabilities

### Modified Capabilities
- `flatpak-auto-runtimes`: Expand Vulkan layer extension directory creation to include `lsfgvk` alongside `MangoHud`, `vkBasalt`, and `vkSumi`.

## Impact

- `flatpak/io.github.benjamimgois.goverlay.nightly.yml`
- `flatpak/io.github.benjamimgois.goverlay.yml`
- Eliminates the `bwrap: Can't mkdir` sandbox launch crash when `org.freedesktop.Platform.VulkanLayer.lsfgvk` is installed or auto-downloaded.
