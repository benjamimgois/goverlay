## Why

When activating the OptiScaler tool toggle in the sidebar navigation or selecting the MESA driver radio button, GOverlay currently forces `forcereflexCheckBox.Checked := True` by default. This forces "Force Reflex" to be enabled even for users who have not opted in, and overwrites the unchecked state loaded from `fakenvapi.ini`. "Force Reflex" should remain unchecked (`False`) by default, while preserving and respecting any explicit selection saved by the user.

## What Changes

- Update `sidebar_nav.pas` (`ApplyToolEnabledState`) when MESA driver is selected and OptiScaler tool toggle is enabled: enable `forcereflexCheckBox` control (`Enabled := True`) without forcing `forcereflexCheckBox.Checked := True`.
- Update `overlayunit.pas` (`mesaRadioButtonChange`) when switching to MESA driver: set `forcereflexCheckBox.Enabled := True` and keep `forcereflexCheckBox.Checked := False` by default if not previously saved as `True`.
- Ensure that if the user explicitly checks `forcereflexCheckBox` and saves, `force_reflex=...` is saved to `fakenvapi.ini` and correctly restored upon reload.

## Capabilities

### Modified Capabilities
- `optiscaler-panel-resilience`: Update MESA driver behavior in OptiScaler tab so that `forcereflexCheckBox` comes enabled but unchecked (`Checked = False`) by default, while correctly saving and restoring user selections.

## Impact

- `sidebar_nav.pas`: Tool toggle enablement logic for MESA driver in `ApplyToolEnabledState`.
- `overlayunit.pas`: MESA radio button selection handler `mesaRadioButtonChange`.
- `tests/gui/gui_test_cases.pas`: Updates to GUI test assertions regarding default `forcereflexCheckBox.Checked` state.
