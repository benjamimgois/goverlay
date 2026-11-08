# Proposal

## Why

When Goverlay is installed as a Flatpak on SteamOS (Steam Deck), users who select all modules during first-run setup find that 8 out of 12 libraries appear as "not found" in red. This happens due to two architectural causes:
1. `MangoHud` and `vkBasalt` are installed as Flathub extensions mounted under `/app/lib/extensions/vulkan/`, but Goverlay's detection routines hardcode `/usr/lib/extensions/vulkan/` and early-exit on version detection in Flatpak.
2. `vkSumi`, `MAKO`, `lsfg-vk`, `afmf-linux`, and `vkNemu` were previously guarded by `if IsRunningInFlatpak then Exit;` to prevent writing host implicit Vulkan layers that previously caused Gamescope bootloops on Steam Deck. Consequently, their runtimes were skipped entirely during startup downloads. Furthermore, `DLSS-NR` was omitted from startup boot provisioning.

Fixing these detection paths and provisioning these runtimes safely within Flatpak user storage (`$XDG_DATA_HOME/goverlay/`)—using `enable_environment` to protect the host Gamescope compositor—ensures all modules work reliably on Steam Deck while adhering strictly to Flathub sandboxing and packaging policies.

## What Changes

- **Flatpak Vulkan Layer Extension Detection**:
  - Update `goverlay_system.pas`, `apputils.pas`, and `home_tab.pas` to detect `MangoHud` and `vkBasalt` libraries and layer manifests at `/app/lib/extensions/vulkan/MangoHud` and `/app/lib/extensions/vulkan/vkBasalt`.
  - Implement Flatpak-aware version discovery reading `manifest.json` or layer metadata for `MangoHud` and `vkBasalt` instead of exiting when `IsRunningInFlatpak` is true.
- **Safe Sandboxed Layer Provisioning in Flatpak**:
  - Allow `CheckAndInstallVkSumi`, `CheckAndInstallMako`, `CheckAndInstallLsfgVk`, `CheckAndInstallAfmf`, and `CheckAndInstallVkNemu` to provision binaries directly inside the Flatpak user data prefix (`$XDG_DATA_HOME/goverlay/layers/...`).
  - Generate layer manifests inside `$XDG_DATA_HOME/vulkan/implicit_layer.d/` with explicit `"enable_environment"` guards (e.g. `"ENABLE_VKSUMI": "1"`), guaranteeing Gamescope never loads uninvited layers on boot.
  - Update `IsVkSumiInstalled`, `IsMakoInstalled`, `IsLsfgVkInstalled`, `IsAfmfInstalled`, and `IsVkNemuInstalled` to check sandbox data paths in Flatpak.
- **DLSS-NR Startup Provisioning**:
  - Add `CheckAndInstallDlssNr` to `TStartupDownloadThread.Execute` in `overlayunit.pas` when `MODULE_UPSCALERS` is enabled.
- **Home Tab Library Status Alignment**:
  - Ensure `home_tab.pas` reflects green "installed" / version status for all Flatpak-managed and sandboxed user libraries.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `flatpak-auto-runtimes`: Update runtime extension inspection paths to check `/app/lib/extensions/vulkan/...` alongside `/usr/lib/extensions/...`, and extract versions from extension metadata.
- `startup-libraries-verification`: Support sandboxed user-space runtime provisioning in Flatpak for Vulkan companion layers (`vkSumi`, `MAKO`, `lsfg-vk`, `afmf-linux`, `vkNemu`) and `DLSS-NR` with `enable_environment` protection against compositor pollution.

## Impact

- **Affected Files**:
  - `goverlay_system.pas` (extension checks & dependency auditing)
  - `apputils.pas` (dependency verification routines)
  - `home_tab.pas` (library status dot and version reporting)
  - `optiscaler_update.pas` (layer installation, sandboxed path handling, and layer manifest generation)
  - `overlayunit.pas` (`TStartupDownloadThread.Execute` orchestration)
- **Affected Systems**: Flatpak build and runtime on Steam Deck (SteamOS) and standard Linux desktop distributions running Goverlay via Flatpak.
- **Breaking Changes**: None. Native execution paths and existing config files are fully preserved.
