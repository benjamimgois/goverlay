## 1. Refactor FSR Version Change Event in overlayunit.pas

- [x] 1.1 Refactor `Tgoverlayform.fsrversionComboBoxChange` in `overlayunit.pas` to always hide `fsrversionLabel` and `fsrversionComboBox`, and display/reposition `forceFsr4Int8CheckBox` for all channels

## 2. Verification

- [x] 2.1 Build the GOverlay application to verify it compiles successfully
- [x] 2.2 Verify the FSR version layout is unified on both stable and bleeding-edge channels at runtime
