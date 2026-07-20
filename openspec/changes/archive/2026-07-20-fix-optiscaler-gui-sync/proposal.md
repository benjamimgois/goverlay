## Why

When the user selects NVIDIA or MESA driver on the OptiScaler tab, the GOverlay GUI updates the driver preference synchronously in its global configuration. However, the dependent checkboxes (Spoof DLSS and Force Reflex) are only saved on disk when the user manually clicks the main "Save" button. If the user changes tabs or reopens GOverlay without saving first, the GUI reloads the checkboxes from the old config file, resulting in an inconsistent UI where MESA is selected but spoofing and reflex options are reverted. Additionally, navigation in global mode fails to update the Save button enabled/disabled state consistently.

## What Changes

- **Synchronous Save on GPU Driver Change**: Automatically save the full OptiScaler configuration (`OptiScaler.ini` and `fakenvapi.ini`) when the GPU driver rádio button (NVIDIA/MESA) changes.
- **Global Save Button Synchronization**: Update `optiscalerLabelClick`, `vkbasaltLabelClick`, and `tweaksLabelClick` to call `ApplyToolEnabledState` and `SetSaveBtnEnabled` in global mode, mirroring the behavior already present in per-game mode.

## Capabilities

### New Capabilities
- *(none)*

### Modified Capabilities
- `bgmod-update-optiscaler`: Save GPU driver dependencies synchronously to prevent desynchronization of GUI checkboxes when navigating between tabs.

## Impact

- `overlayunit.pas`: `mesaRadioButtonChange`, `nvidiaRadioButtonChange`, `optiscalerLabelClick`, `vkbasaltLabelClick`, `tweaksLabelClick`
- OptiScaler UI behaviour: GUI checkbox state and configuration files will remain perfectly in sync regardless of tab navigation or restart.
