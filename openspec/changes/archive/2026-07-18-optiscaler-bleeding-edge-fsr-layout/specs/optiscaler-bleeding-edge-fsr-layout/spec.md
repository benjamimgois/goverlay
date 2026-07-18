# Capability: optiscaler-bleeding-edge-fsr-layout

## ADDED Requirements

### Requirement: Hide FSR Version components and auto-adjust value on bleeding-edge channel
GOverlay SHALL lock the FSR Version combobox (`fsrversionComboBox`) value to "Latest" (index 0) and hide both the FSR Version label (`fsrversionLabel`) and combobox (`fsrversionComboBox`) when the bleeding-edge channel is selected.

#### Scenario: Selecting bleeding-edge channel
- **WHEN** user selects the "Bleeding-edge" option in the OptiScaler channel dropdown (`optversionComboBox`)
- **THEN** GOverlay selects index 0 ("Latest") in `fsrversionComboBox` and hides `fsrversionLabel` and `fsrversionComboBox`.

### Requirement: Reposition Force FSR4-i8 checkbox on bleeding-edge channel
GOverlay SHALL reposition the **Force FSR4-i8** checkbox (`forceFsr4Int8CheckBox`) to align horizontally with `emufp8CheckBox` (using `fsrversionComboBox.Left` and `emufp8CheckBox.Top`) and display it when the bleeding-edge channel is selected.

#### Scenario: Displaying and positioning checkbox on bleeding-edge channel
- **WHEN** the bleeding-edge channel is selected in `optversionComboBox`
- **THEN** GOverlay sets `forceFsr4Int8CheckBox.Left` to match `fsrversionComboBox`'s Left coordinate, `forceFsr4Int8CheckBox.Top` to match `emufp8CheckBox`'s Top coordinate, and makes `forceFsr4Int8CheckBox` visible.

### Requirement: Restore FSR Version components and checkbox position on stable channel
GOverlay SHALL restore the visibility of `fsrversionLabel` and `fsrversionComboBox`, hide `forceFsr4Int8CheckBox`, and restore its original coordinates (`Left = 134`, `Top = 165`) when the stable channel is selected.

#### Scenario: Switching back to stable channel
- **WHEN** user switches the channel dropdown `optversionComboBox` back to "Stable Channel"
- **THEN** GOverlay shows `fsrversionLabel` and `fsrversionComboBox`, hides `forceFsr4Int8CheckBox`, and sets `forceFsr4Int8CheckBox.Left := 134` and `forceFsr4Int8CheckBox.Top := 165`.
