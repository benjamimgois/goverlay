## MODIFIED Requirements

### Requirement: Hide Emulate FP8 checkbox
GOverlay SHALL control the visibility and behavior of the "Emulate FP8" checkbox (`emufp8CheckBox`) on the OptiScaler tab. It SHALL only hide `emufp8CheckBox` when the stable channel is active and the FSR version is "4.0.2c (INT8)". When the bleeding-edge channel is active, `emufp8CheckBox` SHALL remain visible and enabled, and its tooltip hint SHALL dynamically change to reflect FSR MLFG activation on RDNA3.

#### Scenario: Stable channel with Latest selected
- **WHEN** the stable channel is active and "Latest" is selected in the FSR version combobox
- **THEN** the "Emulate FP8" checkbox is visible and enabled, with the default tooltip.

#### Scenario: Stable channel with INT8 selected
- **WHEN** the stable channel is active and "4.0.2c (INT8)" is selected in the FSR version combobox
- **THEN** the "Emulate FP8" checkbox is hidden and disabled.

#### Scenario: Bleeding-edge channel active
- **WHEN** the bleeding-edge channel is active
- **THEN** the "Emulate FP8" checkbox is visible and enabled, and its hint displays "Used to activate FSR MLFG on RDNA3".
