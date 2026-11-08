# Tasks

## 1. MangoHud & vkBasalt Flatpak Extension Detection

- [x] 1.1 Update `goverlay_system.pas` and `apputils.pas` to inspect `/app/lib/extensions/vulkan/MangoHud` and `/app/lib/extensions/vulkan/vkBasalt` in addition to `/usr/lib/extensions/vulkan/...`, verifying `DEP_MANGOHUD_RUNTIME` and `DEP_VKBASALT_RUNTIME` are not added when extension directories are mounted in `/app`.
- [x] 1.2 Implement Flatpak-aware version parsing in `home_tab.pas` (`GetMangoHudVersion` and `GetVkBasaltVersion`) reading from `manifest.json` or layer JSONs under `/app/lib/extensions/vulkan/`, verifying non-empty version strings are returned.
- [x] 1.3 Update `VkBasaltSystemLayersPresent` and `VkSumiSystemLayersPresent` in `optiscaler_update.pas` and `home_tab.pas` to recognize `/app/lib/extensions/vulkan/...` mount points.

## 2. Sandboxed Companion Layers Provisioning

- [x] 2.1 Update `CheckAndInstallVkSumi` and `CheckAndInstallVkNemu` in `optiscaler_update.pas` to download and install libraries to `$XDG_DATA_HOME/goverlay/layers/` and write manifests with `"enable_environment"` to `$XDG_DATA_HOME/vulkan/implicit_layer.d/` inside Flatpak.
- [x] 2.2 Update `CheckAndInstallMako`, `CheckAndInstallLsfgVk`, and `CheckAndInstallAfmf` in `optiscaler_update.pas` to extract runtimes into `$XDG_DATA_HOME/goverlay/layers/` and register manifests with `"enable_environment"` inside Flatpak.
- [x] 2.3 Connect `CheckAndInstallDlssNr` to `TStartupDownloadThread.Execute` in `overlayunit.pas` when `TConfigManager.IsModuleEnabled(MODULE_UPSCALERS)` is true.
- [x] 2.4 Update `IsVkSumiInstalled`, `IsMakoInstalled`, `IsLsfgVkInstalled`, `IsAfmfInstalled`, `IsVkNemuInstalled`, and `IsDlssNrInstalled` in `optiscaler_update.pas` to inspect sandboxed user paths in Flatpak.

## 3. UI Status Synchronization & Validation

- [x] 3.1 Update `home_tab.pas` library status dots and label hints so that sandboxed Flatpak layers and extensions are reported as installed (green dots and valid versions).
- [x] 3.2 Execute automated test suite (`tests/run_tests.sh` or `make test`) and verify all logic and detection tests pass cleanly.
