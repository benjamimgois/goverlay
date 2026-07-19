## MODIFIED Requirements

### Requirement: Hide FSR Version components and auto-adjust value on bleeding-edge channel
GOverlay SHALL lock the FSR Version combobox (`fsrversionComboBox`) value to "Latest" (index 0) and hide both the FSR Version label (`fsrversionLabel`) and combobox (`fsrversionComboBox`) when either the stable or bleeding-edge channel is selected.

#### Scenario: Selecting stable or bleeding-edge channel
- **WHEN** user selects either "Stable Channel" or "Bleeding-edge" option in the OptiScaler channel dropdown (`optversionComboBox`)
- **THEN** GOverlay selects index 0 ("Latest") in `fsrversionComboBox` and hides `fsrversionLabel` and `fsrversionComboBox`.

### Requirement: Reposition Force FSR4-i8 checkbox on bleeding-edge channel
GOverlay SHALL reposition the **Force FSR4-i8** checkbox (`forceFsr4Int8CheckBox`) to align horizontally with `emufp8CheckBox` (using `fsrversionComboBox.Left` and `emufp8CheckBox.Top`) and display it when either the stable or bleeding-edge channel is selected.

#### Scenario: Displaying and positioning checkbox on stable or bleeding-edge channel
- **WHEN** stable or bleeding-edge channel is selected in `optversionComboBox`
- **THEN** GOverlay sets `forceFsr4Int8CheckBox.Left` to match `fsrversionComboBox`'s Left coordinate, `forceFsr4Int8CheckBox.Top` to match `emufp8CheckBox`'s Top coordinate, and makes `forceFsr4Int8CheckBox` visible.

## REMOVED Requirements

### Requirement: Restore FSR Version components and checkbox position on stable channel
**Reason**: We no longer restore the FSR Version dropdown components on the stable channel, as the UI layout is now unified between channels.
**Migration**: None.
