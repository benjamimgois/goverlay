## Why

When the user selects FSR version "4.0.2c (INT8)" in the OptiScaler tab and saves, GOverlay fails to persist the selection in the game's config directory (via `goverlay.vars`) and fails to update the Software Status card version to reflect the active selection. Furthermore, toggling the OptiScaler tool ON clobbers any customized FSR selection with the default FP8 DLL.

## What Changes

- Save the active FSR version configuration (`fsrversion`) to the game-specific `goverlay.vars` file when saving the configuration.
- Read and support both `'4.0.2c (INT8)'` and `'4.0.2c INT8'` string formats when loading the FSR version from `goverlay.vars` to restore the correct combobox state.
- Instantly refresh the Software Status card and version labels after saving the configuration.
- During OptiScaler toggle activation, copy and overwrite the correct `amd_fidelityfx_upscaler_dx12.dll` version in the game configuration directory depending on the saved setting.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `bgmod-update-optiscaler`: Update the requirements for FSR version persistence, UI synchronization, and activation toggling.

## Impact

- `overlay_config.pas`: Persist the selected FSR version inside `goverlay.vars` and support both string formats during loading.
- `optiscaler_update.pas`: Support both string formats when parsing FSR version from vars and displaying it.
- `optiscaler_tab.pas`: Reload and refresh Software Status panel immediately after configuration saves.
- `sidebar_nav.pas`: Overwrite with correct FSR DLL when copying files to the game config folder on toggle.
