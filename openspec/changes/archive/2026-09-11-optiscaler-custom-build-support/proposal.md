## Why

Users experimenting with bleeding-edge features (such as Multi-Frame Generation/MFG, neural rendering, and customized upscaling backends) frequently build or download custom forks of OptiScaler that are not available through the official GitHub release/pre-release channels. Currently, GOverlay only supports official GitHub releases (Stable and Bleeding-edge), and attempting to use custom files causes GOverlay to check for remote updates and overwrite game files. Furthermore, GOverlay's configuration manager continuously overwrites `OptiScaler.ini` on save or game launch, destroying custom parameters (e.g. MFG and neural rendering) set in-game or directly in the file.

Providing a dedicated "Custom Build" channel with folder import, companion DLL inheritance, and an in-game unmanaged INI toggle solves issue #410 completely.

## What Changes

- Add a third option **"Custom Build"** (`OPT_CHANNEL=2`) to the OptiScaler channel selection combobox (`optversionComboBox`).
- Introduce a folder selection action (**"Select Folder..."**) when "Custom Build" is selected, allowing the user to pick a local folder containing their custom OptiScaler build.
- Validate that the chosen folder contains `OptiScaler.dll` before importing; copy the build to a dedicated central cache `~/.local/share/goverlay/optiscaler-custom/`.
- Automatically populate missing companion libraries (`amd_fidelityfx_*.dll`, `libxess.dll`, `fakenvapi.dll`, etc.) from `optiscaler-stable` so custom builds lacking bundled libraries remain fully functional.
- Inform the user in a non-intrusive way (toast and subtle status card hint) that companion libraries are inherited from the stable cache if not supplied in the custom folder.
- Hide remote GitHub update checks and "Update Available" notifications when "Custom Build" is active.
- Introduce a conditional toggle **"In-game menu configuration only (do not override OptiScaler.ini)"** (`OPT_UNMANAGED_INI=1`), visible only when "Custom Build" is selected.
- In unmanaged mode:
  - GOverlay UI visually dims and skips overwriting `OptiScaler.ini` upon saving game profiles.
  - `bgmod` (`SyncOptiScalerIni`) preserves existing `GameDir/OptiScaler.ini` without timestamp-based overwrite, giving the game and in-game menu exclusive ownership of the configuration.
- Update asset deployment in `sidebar_nav.pas` and `bgmod.lpr` to deploy files from `optiscaler-custom/` when `OPT_CHANNEL=2`.

## Capabilities

### New Capabilities
- `optiscaler-custom-build-support`: Covers custom build directory selection, validation, companion DLL fallback inheritance from `optiscaler-stable`, UI toggle visibility for in-game unmanaged mode, and non-intrusive notifications.

### Modified Capabilities
- `upscaler-channel-persistence`: Extends `OPT_CHANNEL` to support value `2` ("Custom Build"), updates channel restoration and in-card version labels, and deploys assets from `optiscaler-custom/`.
- `bgmod-sync-optiscaler`: Adds support for `OPT_UNMANAGED_INI=1` in `bgmod` execution wrapper, ensuring `GameDir/OptiScaler.ini` is never overwritten when unmanaged mode is enabled.

## Impact

- **Code affected**:
  - `bgmod_resources.pas`: Add `GetBGModOriginalCustomPath` / `GetOptiScalerCustomPath`.
  - `optiscaler_update.pas`: Handle Custom channel in `optversionComboBox`, skip remote checks, implement import and fallback inheritance logic.
  - `optiscaler_tab.pas`: UI reflow for Custom action button, conditional "In-game menu configuration only" toggle, and dimming of managed INI controls when active.
  - `overlay_config.pas`: Persist `OPT_UNMANAGED_INI`, skip rewriting `OptiScaler.ini` when unmanaged mode is enabled.
  - `sidebar_nav.pas`: Deploy from `optiscaler-custom` when `OPT_CHANNEL=2`.
  - `bgmod.lpr`: Resolve `optiscaler-custom` path and honor `OPT_UNMANAGED_INI` in `SyncOptiScalerIni`.
  - Tests: Add regression test cases for custom channel selection, asset copying, and unmanaged INI preservation.
