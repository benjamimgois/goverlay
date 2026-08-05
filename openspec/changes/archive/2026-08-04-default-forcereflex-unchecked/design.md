## Context

See `proposal.md` for motivation. Currently, in `sidebar_nav.pas` (`ApplyToolEnabledState`) and `overlayunit.pas` (`mesaRadioButtonChange`), when OptiScaler is enabled with MESA selected, code explicitly executes `FForm.forcereflexCheckBox.Checked := True` and `FForm.reflexComboBox.ItemIndex := 2`. This overrides user default preference and causes Force Reflex to be checked automatically even on new or unconfigured games.

## Goals / Non-Goals

**Goals:**
- Update `sidebar_nav.pas` so that enabling OptiScaler under MESA enables `forcereflexCheckBox` (`Enabled := True`) without modifying its `Checked` property.
- Update `overlayunit.pas` (`mesaRadioButtonChange`) so that switching to MESA driver enables `forcereflexCheckBox` (`Enabled := True`) and sets `forcereflexCheckBox.Checked := False` by default.
- Maintain existing persistence in `overlay_config.pas` (`LoadOptiScalerConfig` & `SaveOptiScalerConfig`), ensuring that if `fakenvapi.ini` contains `force_reflex=...`, `forcereflexCheckBox.Checked` is loaded as `True` and preserved.

**Non-Goals:**
- Alter NVIDIA driver restriction behavior (`forcereflexCheckBox.Enabled := False`).

## Decisions

1. **Remove Automatic Forcing of `Checked := True` in Tool Toggle**:
   - *Decision*: In `sidebar_nav.pas` (`ApplyToolEnabledState`), remove `FForm.forcereflexCheckBox.Checked := True` and set `FForm.reflexComboBox.Enabled := FForm.forcereflexCheckBox.Checked`.
   - *Rationale*: Preserves whatever `Checked` state was loaded from `fakenvapi.ini` or defaults to `False`.

2. **Default `Checked := False` in MESA Radio Button Change**:
   - *Decision*: In `overlayunit.pas` (`mesaRadioButtonChange`), change `forcereflexCheckBox.Checked := true;` to `forcereflexCheckBox.Checked := false;`.
   - *Rationale*: Ensures switching to MESA leaves Force Reflex unchecked by default unless the user enables it.

## Risks / Trade-offs

- **[Risk] Existing GUI tests expecting `forcereflexCheckBox.Checked = True` after MESA toggle**:
  - *Mitigation*: Update assertions in `gui_test_cases.pas` to verify `forcereflexCheckBox.Checked = False` by default on MESA, while verifying explicit check and save roundtrip.
