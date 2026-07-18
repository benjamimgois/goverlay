## Why

On the bleeding-edge channel, OptiScaler's FSR Version is locked to "Latest". Displaying the FSR Version label and dropdown is redundant and wastes screen space. Hiding these elements and placing the "Force FSR4-i8" checkbox in their place optimizes the UI layout, makes it cleaner, and prevents redundant user configuration.

## What Changes

- When selecting the **Bleeding-edge** channel:
  - Automatically set the FSR Version combobox index to `0` ("Latest").
  - Hide the FSR Version label (`fsrversionLabel`) and combobox (`fsrversionComboBox`).
  - Position the **Force FSR4-i8** checkbox (`forceFsr4Int8CheckBox`) in place of the combobox (using its Left/Top coordinates).
  - Make `forceFsr4Int8CheckBox` visible.
- When selecting the **Stable** channel:
  - Restore visibility of the FSR Version label and combobox.
  - Hide the `forceFsr4Int8CheckBox` checkbox.
  - Restore the original coordinates (`Left = 134`, `Top = 165`) of `forceFsr4Int8CheckBox` so it is laid out correctly.

## Capabilities

### New Capabilities
- `optiscaler-bleeding-edge-fsr-layout`: Hide FSR Version label/combobox and position the Force FSR4-i8 checkbox in their place when the bleeding-edge channel is selected.

### Modified Capabilities

## Impact

- `overlayunit.pas`: Modifications to `fsrversionComboBoxChange` to implement layout toggling and coordinate shifting.
