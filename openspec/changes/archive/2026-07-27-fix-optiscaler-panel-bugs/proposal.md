## Why

The OptiScaler tab in GOverlay contains several UI synchronization, file seeding, global profile initialization, and asset download resilience bugs that prevent settings (such as Force Reflex) from persisting correctly, allow invalid options under NVIDIA, cause missing DLLs in `gameconfig/global/` until restart, and leave the cache without `fakenvapi` files if GitHub API fails.

## What Changes

- **UI Driver Enforcement**: Re-apply GPU driver restrictions (disabling Spoof DLSS and Force Reflex under NVIDIA) when loading or switching to the OptiScaler tab via left navigation.
- **Immediate Global Sync on Save**: Force synchronization of OptiScaler DLLs, plugins, and helper assets to `gameconfig/global/` immediately upon saving when OptiScaler is enabled, eliminating the need to restart GOverlay.
- **`fakenvapi.ini` Seeding**: Seed `fakenvapi.ini` from the cache folder if missing when saving OptiScaler settings, ensuring `fakenvapi.ini` exists before attempting `FakeCfg.Load` so user settings (such as Force Reflex mode) are correctly saved.
- **FakeNVAPI Download Fallback**: Preserve existing `fakenvapi` assets in the cache folder when performing an OptiScaler update/install if downloading `fakenvapi` fails (e.g. due to GitHub API rate limits or network errors).

## Capabilities

### New Capabilities
- `optiscaler-panel-resilience`: Bug fixes for OptiScaler driver enforcement, immediate global DLL sync on save, `fakenvapi.ini` initial seeding, and update fallback resilience.

### Modified Capabilities
- `optiscaler-persistence`: Updated requirement for seeding `fakenvapi.ini` on save when absent, and forcing instant global profile sync upon enabling.

## Impact

- `optiscaler_tab.pas` and `overlayunit.pas`: Driver state checking during config loading and menu tab navigation.
- `overlay_config.pas`: Seeding `fakenvapi.ini` prior to editing keys in `SaveOptiScalerConfigCore`.
- `bgmod_resources.pas`: Exposing or calling `InitializeGlobalConfigDirectory` / asset sync upon saving.
- `optiscaler_update.pas`: Resilient fallback handling when fetching `fakenvapi` releases.
- Unit tests in `tests/gui/` and `tests/logic/`: Adding test cases covering driver toggle persistence and `fakenvapi.ini` seeding.
