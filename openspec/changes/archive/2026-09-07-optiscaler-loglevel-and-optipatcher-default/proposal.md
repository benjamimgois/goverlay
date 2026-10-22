# Proposal: OptiScaler LogLevel Selector and OptiPatcher Default Enabled

## Why
OptiScaler log verbosity can significantly impact gameplay performance when set to verbose modes (0 = Trace or 1 = Debug) or hinder troubleshooting when insufficient detail is logged. Currently, GOverlay does not expose a user interface to configure `LogLevel=` in `OptiScaler.ini`, forcing manual text edits. Additionally, OptiPatcher was defaulting to disabled on clean setups because the default template value `LoadAsiPlugins=auto` was incorrectly parsed as `False`, despite OptiPatcher being a core recommended feature for DLSS/DLSS-FG input handling.

## What Changes
- Add a new "Log level" combobox (`loglevelComboBox`) and label (`loglevelLabel`) inside Sub-card 1 ("Main") of the OptiScaler tab, placed below "Menu scale".
- Populate the combobox with options: `0 - Trace`, `1 - Debug`, `2 - Info (Default)`, `3 - Warning`, and `4 - Error`.
- Provide a clear tooltip/hint explaining verbosity levels and warning that high verbosity (Trace / Debug) may impact game performance.
- Automatically save the configuration whenever the user changes the LogLevel combobox.
- Parse and serialize `LogLevel=` under section `[Log]` in `OptiScaler.ini` (defaulting to `2` when `auto`, missing, or invalid).
- Update `LoadOptiScalerConfig` to treat `LoadAsiPlugins=auto` (and missing key) as `True`, enabling OptiPatcher by default while preserving explicit user deactivation (`LoadAsiPlugins=false`).
- Adjust layout dimensions (`MinOptH`) in `optiscaler_tab.pas` so the added controls fit cleanly in the Main sub-card.

## Capabilities

### New Capabilities
- `optiscaler-loglevel-and-optipatcher`: UI controls, persistence, auto-save, and default behaviors for OptiScaler LogLevel and OptiPatcher plugin loading.

### Modified Capabilities
<!-- None -->

## Impact
- `overlayunit.pas`: Add `loglevelComboBox` and `loglevelLabel` declarations, and `loglevelComboBoxChange` auto-save handler.
- `optiscaler_tab.pas`: Instantiate controls in `InitOptiScalerTab`, adjust bounds and `MinOptH` in `ReflowOptiScalerTabNew`, load and save LogLevel in `LoadOptiScalerConfig` and `SaveOptiScalerConfig`.
- `overlay_config.pas`: Add `LogLevelItemIndex` to `TOptiScalerSettings`, read/write `[Log] LogLevel=` in `OptiScaler.ini`, and treat `LoadAsiPlugins=auto` as `True`.
- `configkeys.pas`: Add `OPTI_INI_SECTION_LOG` and `OPTI_KEY_LOG_LEVEL`.
- `tests/gui/gui_test_cases.pas`: Add GUI tests verifying LogLevel presence, items, hint, persistence, auto-save, and OptiPatcher default enabled behavior.
