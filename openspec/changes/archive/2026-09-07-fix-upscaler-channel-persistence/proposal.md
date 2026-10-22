## Why

When an OptiScaler or DLSS Enabler channel ("Stable Channel" or "Bleeding-edge") is configured for a specific game profile (or globally), the selection reverts to "Stable Channel" on application restart or when switching games, and the version label in the Software Status card reverts to showing the stable version. This occurs because `optversionComboBox` lacks auto-save handling, `FOptiscalerUpdate.InitializeTab` unconditionally reads from global settings rather than the active profile, `optversionComboBoxChange` does not reload the in-card version labels, and DLSS Enabler file synchronization ignores the selected channel.

## What Changes

- Trigger auto-save immediately whenever `optversionComboBox` selection changes, saving `OPT_CHANNEL` in the active game profile's `bgmod.conf` (or global `bgmod.conf`).
- Update `FOptiscalerUpdate.InitializeTab` to load channel configuration from the active profile (`FActiveGameName`) rather than hardcoding global settings (`''`).
- Call `FOptiscalerUpdate.LoadVersionsFromFile` in `optversionComboBoxChange` so the Software Status version labels (`FDlssEnablerLabel`, `dlssEnablerVersionLabel`, `FOptiLabel`) refresh immediately to reflect the selected channel.
- Ensure `TSidebarNavHelper.CopyOptiScalerGameFiles` passes `IsStable` to `GetDlssEnablerPath(IsStable)` when copying DLSS Enabler assets, ensuring the correct channel's DLLs are deployed.
- Align `LoadVersionsFromFile` fallback paths to check the selected channel's cache folder.
- Add automated GUI test verifying that selecting "Bleeding-edge" for a game profile persists `OPT_CHANNEL=1` and restores the selection and corresponding version label across tab and profile switches.

## Capabilities

### New Capabilities
- `upscaler-channel-persistence`: Defines channel selection persistence (Stable vs Bleeding-edge) for OptiScaler and DLSS Enabler across global and per-game profiles, including in-card Software Status synchronization and correct cache deployment.

### Modified Capabilities
<!-- None -->

## Impact

- `overlayunit.pas`: `optversionComboBoxChange` triggers auto-save and version reload.
- `optiscaler_update.pas`: `InitializeTab` and `LoadVersionsFromFile` honor the active profile and selected channel.
- `sidebar_nav.pas`: `CopyOptiScalerGameFiles` respects `IsStable` for DLSS Enabler.
- `tests/gui/gui_test_cases.pas`: Automated regression test covering per-game channel persistence.
