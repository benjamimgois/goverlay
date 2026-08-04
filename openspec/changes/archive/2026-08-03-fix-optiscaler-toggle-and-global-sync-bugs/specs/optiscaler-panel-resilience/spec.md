# optiscaler-panel-resilience Delta Spec

## MODIFIED REQUIREMENTS

### Requirement: GPU Driver Restriction Enforcement in OptiScaler Tab
GOverlay SHALL enforce GPU driver restrictions whenever the OptiScaler configuration tab or tool toggle state is updated, keeping Nvidia-incompatible controls disabled when Nvidia driver preference is selected and applying recommended Reflex defaults for MESA.

#### Scenario: Re-enabling OptiScaler with NVIDIA selected
- **WHEN** the user re-enables the OptiScaler tool toggle switch after it was disabled
- **AND** `nvidiaRadioButton` is selected
- **THEN** `spoofCheckBox` ("Spoof DLSS") and `forcereflexCheckBox` ("Force Reflex") SHALL remain disabled (`Enabled = False`).

#### Scenario: First activation of OptiScaler with MESA selected
- **WHEN** the user enables the OptiScaler tool toggle switch for the first time
- **AND** `mesaRadioButton` is selected
- **THEN** `forcereflexCheckBox.Checked` SHALL be set to `True` and `reflexComboBox.ItemIndex` SHALL be set to `2` ("Force enable").
