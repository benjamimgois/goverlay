## Context

GOverlay supports running in Flatpak sandbox mode, where environment-specific Vulkan extensions (like MangoHud, vkBasalt) are mapped inside `/usr/lib/extensions/vulkan/`. 
Previously, vkSumi was not supported inside Flatpak mode, and thus the vkSumi tab sheet was hidden and the dependencies on the Home tab did not resolve vkSumi. Now that vkSumi is packageable as a Flatpak runtime/extension, GOverlay should support it inside the Flatpak sandbox.

## Goals / Non-Goals

**Goals:**
- Detect Flatpak-installed vkSumi extension by checking library files inside the sandbox.
- Render the vkSumi tab in Flatpak mode.
- Report correct dependency state on the Home tab.
- Update Flatpak manifests to map the vkSumi VulkanLayer extension.

**Non-Goals:**
- Upstream packaging of vkSumi to Flathub or external repositories.
- Custom user-facing installers for vkSumi inside the Flatpak version.

## Decisions

### 1. Detection Paths
We will check if the vkSumi library file exists at:
- `/usr/lib/extensions/vulkan/vkSumi/lib/x86_64-linux-gnu/libVkLayer_vksumi.so`
- `/usr/lib/extensions/vulkan/vkSumi/lib/i386-linux-gnu/libVkLayer_vksumi.so`

This aligns with how MangoHud and vkBasalt extensions are checked under Flatpak mode.

### 2. Dependency List Identity
If not found, we will add `'vkSumi runtime'` to the missing dependencies list.
In `home_tab.pas`, `SumiOK` will verify that both `'vksumi'` (native name) and `'vkSumi runtime'` (Flatpak name) are not present in the missing list.

### 3. Flatpak Manifests Update
Add `mkdir -p /app/lib/extensions/vulkan/vkSumi` to both flatpak manifests (`io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml`) in the build commands section. This ensures Flatpak runtime mounts the `org.freedesktop.Platform.VulkanLayer.vkSumi` extension inside GOverlay's sandbox.

## Risks / Trade-offs

- [Risk] Flatpak runtime extension named `vkSumi` may not be installed by the user on the host. → [Mitigation] The Home tab correctly alerts the user by displaying a red dot and "not found" if the library is not mapped.
