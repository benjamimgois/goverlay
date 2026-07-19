## Why

Currently, the OptiScaler tab UI differs between the "Stable" and "Bleeding-edge" channels. Under Stable, a dropdown "FSR Version" is shown, whereas under Bleeding-edge, it is hidden and replaced by a "Force FSR4-i8" checkbox. Unifying the user interface by displaying the "Force FSR4-i8" checkbox and hiding the "FSR Version" dropdown on both channels provides a cleaner, more consistent interface.

## What Changes

- Modify GOverlay to hide the FSR Version combobox and label on both Stable and Bleeding-edge channels.
- Force FSR Version to "Latest" (index 0) under both channels.
- Position and display the "Force FSR4-i8" checkbox in place of the FSR Version combobox for both channels.

## Capabilities

### New Capabilities

<!-- None -->

### Modified Capabilities

- `optiscaler-bleeding-edge-fsr-layout`: Update requirements to hide FSR version components and display/reposition the Force FSR4-i8 checkbox on both channels instead of just the bleeding-edge channel.

## Impact

- `overlayunit.pas`: Modify `fsrversionComboBoxChange` to apply the FSR version hiding and "Force FSR4-i8" checkbox visibility/repositioning logic to both the Stable and Bleeding-edge channels.
