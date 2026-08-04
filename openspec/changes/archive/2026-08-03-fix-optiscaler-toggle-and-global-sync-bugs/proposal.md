## Why

Users reported UI state inconsistency and missing global OptiScaler configuration files (Issue #247 comment 5172544430):
1. Re-enabling the OptiScaler tool toggle in the sidebar re-enables `spoofCheckBox` ("Spoof DLSS") and `forcereflexCheckBox` ("Force Reflex") even when the NVIDIA driver is selected, bypassing driver-specific restrictions.
2. Initial activation of OptiScaler with MESA selected by default does not trigger MESA recommended settings (`Force Reflex` checked and set to "Force enable").
3. Toggling OptiScaler ON in global mode (`FActiveGameName = ''`) does not synchronize/populate OptiScaler configuration files and DLLs into `gameconfig/global/` until the user manually saves or toggles driver radio buttons, unlike per-game mode which syncs immediately upon toggle.

Addressing these issues guarantees UI state integrity, consistent global profile file synchronization, and proper driver constraint enforcement across tool toggle state changes.

## What Changes

- **Driver Constraint Re-enforcement on Tool Toggle**: Re-apply driver-specific control enablement rules (`nvidiaRadioButton.Checked` disables `spoofCheckBox` and `forcereflexCheckBox`) when `ApplyToolEnabledState` re-enables the OptiScaler tab controls.
- **Initial MESA Defaults Enforcement**: Trigger recommended MESA defaults (`forcereflexCheckBox.Checked := True`, `reflexComboBox.ItemIndex := 2`) when OptiScaler is toggled ON with MESA selected.
- **Immediate Global File Sync on Tool Toggle**: Update `NavToolToggleClick` in `sidebar_nav.pas` to invoke OptiScaler file population/synchronization (`SyncOptiScalerToGlobalConfig` / `CopyOptiScalerGameFiles`) immediately when turning OptiScaler ON in global mode (`FActiveGameName = ''`).

## Capabilities

### Modified Capabilities

- `optiscaler-panel-resilience`: Re-enforce NVIDIA driver restrictions on `spoofCheckBox` and `forcereflexCheckBox` when re-enabling the OptiScaler tool toggle, and apply recommended MESA defaults upon initial activation.
- `global-sidebar-toggles`: Ensure global OptiScaler files and DLLs in `gameconfig/global/` are synchronized immediately upon toggling OptiScaler ON in global mode.

## Impact

- `sidebar_nav.pas`: `NavToolToggleClick` and `ApplyToolEnabledState` updated for global OptiScaler file sync and UI control re-enforcement.
- `optiscaler_tab.pas` / `overlayunit.pas`: Driver state enforcement logic invoked during tab enable state updates.
- `tests/gui/gui_test_cases.pas`: New GUI tests covering tool toggle re-enable with NVIDIA selected and global OptiScaler toggle file synchronization.
