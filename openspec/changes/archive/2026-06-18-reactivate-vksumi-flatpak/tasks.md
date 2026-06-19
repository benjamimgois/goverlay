## 1. Dependency Checking Updates

- [x] 1.1 Edit `goverlay_system.pas` to detect the vkSumi library inside `/usr/lib/extensions/vulkan/vkSumi` when running in Flatpak mode, adding 'vkSumi runtime' to the missing list if it is not present.
- [x] 1.2 Edit `apputils.pas` to detect the vkSumi library inside `/usr/lib/extensions/vulkan/vkSumi` when running in Flatpak mode, adding 'vkSumi runtime' to the missing list if it is not present.

## 2. Home Tab Status Updates

- [x] 2.1 Edit `home_tab.pas` to check for both 'vksumi' and 'vkSumi runtime' in the missing dependencies list when calculating `SumiOK`.

## 3. UI Tab Visibility Updates

- [x] 3.1 Edit `overlayunit.pas` to change `vksumiTabSheet.TabVisible := not IsRunningInFlatpak;` to `vksumiTabSheet.TabVisible := True;` under the `vkbasaltLabelClick` event handler, enabling vkSumi settings to be visible in Flatpak mode.

## 4. Flatpak Manifests Updates

- [x] 4.1 Edit `flatpak/io.github.benjamimgois.goverlay.yml` to add `mkdir -p /app/lib/extensions/vulkan/vkSumi` under build-commands.
- [x] 4.2 Edit `flatpak/io.github.benjamimgois.goverlay.nightly.yml` to add `mkdir -p /app/lib/extensions/vulkan/vkSumi` under build-commands.
