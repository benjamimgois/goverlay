## 1. UI and Coordinates Toggling Logic

- [x] 1.1 In `overlayunit.pas` `fsrversionComboBoxChange`, implement the dynamic visibility logic for stable channel: if `optversionComboBox.ItemIndex = 0`, make `fsrversionLabel` and `fsrversionComboBox` visible, hide `forceFsr4Int8CheckBox`, and restore `forceFsr4Int8CheckBox` coordinates to `Left := 134` and `Top := 165`.
- [x] 1.2 In `overlayunit.pas` `fsrversionComboBoxChange`, implement the dynamic visibility and coordinate shift logic for bleeding-edge channel: if `optversionComboBox.ItemIndex = 1`, set `fsrversionComboBox.ItemIndex := 0` ("Latest"), hide `fsrversionLabel` and `fsrversionComboBox`, move `forceFsr4Int8CheckBox` to `fsrversionComboBox.Left` and `fsrversionComboBox.Top`, and make `forceFsr4Int8CheckBox` visible.

## 2. Verification

- [x] 2.1 Verify that when Stable Channel is selected, the FSR version dropdown is visible, FSR version options are visible, and Force FSR4-i8 is hidden.
- [x] 2.2 Verify that when Bleeding-edge is selected, the FSR version dropdown and label are hidden, FSR version is set to "Latest", and Force FSR4-i8 is displayed in the exact position of the FSR version dropdown.
- [x] 2.3 Verify that switching between Stable and Bleeding-edge channels correctly toggles visibility and updates the Force FSR4-i8 checkbox coordinates back and forth.
- [x] 2.4 Verify that loading settings (global or per-game) behaves correctly and sets up the correct UI layout automatically.
