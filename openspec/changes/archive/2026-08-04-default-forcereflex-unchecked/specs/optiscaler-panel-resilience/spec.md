## MODIFIED Requirements

### Requirement: GPU Driver Restriction Enforcement in OptiScaler Tab
GOverlay SHALL enforce GPU driver restrictions whenever the OptiScaler configuration tab or tool toggle state is updated, keeping Nvidia-incompatible controls disabled when Nvidia driver preference is selected, enabling Reflex controls unchecked (`Checked = False`) by default when MESA driver preference is selected, and preserving saved user Reflex preferences.

#### Scenario: Navigating to OptiScaler tab with Nvidia selected
- **WHEN** Nvidia driver is selected and the user clicks on the OptiScaler menu item in the left navigation
- **THEN** `spoofCheckBox` and `forcereflexCheckBox` SHALL remain disabled (`Enabled = False`).

#### Scenario: Re-enabling OptiScaler with NVIDIA selected
- **WHEN** the user re-enables the OptiScaler tool toggle switch after it was disabled
- **AND** `nvidiaRadioButton` is selected
- **THEN** `spoofCheckBox` ("Spoof DLSS") and `forcereflexCheckBox` ("Force Reflex") SHALL remain disabled (`Enabled = False`).

#### Scenario: Enabling OptiScaler with MESA selected
- **WHEN** the user enables the OptiScaler tool toggle switch
- **AND** `mesaRadioButton` is selected
- **THEN** `forcereflexCheckBox.Enabled` SHALL be set to `True` and `forcereflexCheckBox.Checked` SHALL be `False` by default unless `force_reflex` is present in `fakenvapi.ini`.
