## Why

When the user selects a game or global settings, the OptiScaler channel dropdown (`optversionComboBox`) can leak the selection state from the previously active game. If the active config file does not contain a saved `OPT_CHANNEL` setting, the combobox's item index is left unmodified, retaining the state of whatever game or configuration was viewed prior.

## What Changes

- Initialize/default the OptiScaler update channel combobox index to `0` (Stable Channel) in `TOptiScalerTabHelper.LoadOptiScalerConfig` if the loaded settings do not contain a valid channel index.
- Ensure that switching between games or global views correctly overrides/resets the combobox state and avoids any leaking index state.

## Capabilities

### New Capabilities
- `fix-optiscaler-channel-leak`: Ensure OptiScaler channel dropdown defaults to Stable (0) when configuration lacks channel value to prevent previous settings leakage.

### Modified Capabilities
None.

## Impact

- `optiscaler_tab.pas` (`TOptiScalerTabHelper.LoadOptiScalerConfig`)
