# Spec Delta

## MODIFIED Requirements

### Requirement: Mandatory Startup Libraries Verification
The system SHALL verify the presence of mandatory companion, upscaler, frame generation, and post-processing libraries during application startup before launching the main window, auditing only libraries belonging to currently enabled functional modules.

Mandatory libraries per module include:
- When **Upscaling Ecosystem** is enabled:
  - `OptiScaler.dll` and `amd_fidelityfx_upscaler_dx12.dll` in the OptiScaler stable cache directory
  - `nvngx_dlss.dll`, `nvngx_dlssd.dll`, `nvngx_dlssg.dll`, `dlssg_to_fsr3_amd_is_better.dll`, and `fakenvapi.dll` in the OptiScaler stable cache directory
  - `Latest/amd_fidelityfx_upscaler_dx12.dll`, `4.1.1b/amd_fidelityfx_upscaler_dx12.dll`, and `4.0.2c/amd_fidelityfx_upscaler_dx12.dll` in the central `FSR4/` directory
  - `amd_fidelityfx_dx12.dll` in the `optiscaler-helixsr/` directory
  - DLSS Enabler `version.dll` in the DLSS Enabler stable directory
  - `OptiPatcher.asi` plugin in the plugins cache directory
  - `dlss-nr` central models directory containing `dlssnr.bin` or architecture assets
- When **Post-Processing & Shaders** is enabled:
  - `ReShade64.dll` and `ReShade32.dll` in the central ReShade directory (`~/.local/share/goverlay/reshade/bin/`)
  - Standard Shaders directory (`~/.local/share/goverlay/reshade/shaders/Shaders/`) containing default shader files
  - vkBasalt ReShade shaders repository directory (`~/.config/vkBasalt/reshade-shaders/`) containing shader files
  - vkSumi Vulkan layer binary (`libVkLayer_vksumi.so`) and manifest (`vksumi.json`) in system paths or user data paths
- When **Frame Generation & Interpolation** is enabled:
  - `libVkLayer_lsfg_vk.so` and manifest (`lsfg_vk.json`) in system paths or user data paths
  - MAKO renderer installation files in system paths or user data paths
  - `libVkLayer_afmf.so` and manifest (`afmf.json`) in system paths or user data paths
- When only **MangoHud (Core)** is enabled:
  - No external library audit is performed during startup.

#### Scenario: All mandatory libraries exist
- **WHEN** GOverlay launches and all mandatory libraries for enabled modules exist on disk
- **THEN** the system bypasses the download splash screen and displays the main application window immediately.

#### Scenario: One or more mandatory libraries are missing
- **WHEN** GOverlay launches and any mandatory library belonging to an active module is missing
- **THEN** the system displays the boot splash screen and initiates background downloads for the missing files belonging to enabled modules.

#### Scenario: vkSumi library is missing on native Linux
- **WHEN** GOverlay launches with Post-Processing enabled and `libVkLayer_vksumi.so` or `vksumi.json` is missing from system and user paths
- **THEN** `HasMissingMandatoryLibraries` returns `True` and includes vkSumi in the missing libraries list, triggering the startup boot splash.

#### Scenario: Libraries missing for a disabled module
- **WHEN** GOverlay launches and files belonging to a disabled module (such as OptiScaler or MAKO) are absent
- **THEN** the system ignores the missing files, skips downloads for that module, and boots normally.

## ADDED Requirements

### Requirement: Sandboxed Flatpak Companion Layer Provisioning
The system SHALL allow background downloading and installation of user-space Vulkan layers (`vkSumi`, `MAKO`, `lsfg-vk`, `afmf-linux`, `vkNemu`) and `DLSS-NR` inside the Flatpak user data directory (`$XDG_DATA_HOME/goverlay/`), registering layer manifests with `"enable_environment"` variables to prevent uninvited layer loading by host compositors.

#### Scenario: Provisioning user layer inside Flatpak
- **WHEN** Goverlay runs in Flatpak with a companion layer module enabled and the layer is not installed
- **THEN** the system downloads the runtime into `$XDG_DATA_HOME/goverlay/layers/<module>/`, generates the manifest with an explicit `enable_environment` key in `$XDG_DATA_HOME/vulkan/implicit_layer.d/`, and reports the module as installed.

#### Scenario: Host compositor isolation on Steam Deck
- **WHEN** a companion Vulkan layer is installed via Flatpak on SteamOS
- **THEN** the generated manifest requires an explicit environment variable to load, ensuring Gamescope does not load the layer during boot.
