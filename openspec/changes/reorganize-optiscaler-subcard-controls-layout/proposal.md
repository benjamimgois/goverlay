# Proposal: Reorganize OptiScaler Sub-Card Controls Layout

## Problem Statement
Inside the "Options" card on the Upscalers tab, controls in the "OptiScaler" section (`FOsOptiSec`) are currently arranged asymmetrical with mixed vertical comboboxes and checkboxes. Placing "Preferred upscaler" at the bottom makes the layout uneven compared to neighboring sub-cards ("ImGUI Menu" and "FakeNVAPI").

## Proposed Changes
1. **Side-by-Side ComboBoxes (Row 1)**:
   - Place `filenameLabel` ("File name") and `filenameComboBox` on the left column (`Left := 14`).
   - Place `preferredUpscalerLabel` ("Preferred upscaler") and `preferredUpscalerComboBox` on the right column (`Left := 140`).

2. **Top Checkbox Row (Row 2)**:
   - Place `spoofCheckBox` ("Spoof DLSS") on the left column (`Left := 14`, `Top := 105`).
   - Place `forceFsr4Int8CheckBox` ("Force FSR4-i8") on the right column (`Left := 140`, `Top := 105`).

3. **Bottom Checkbox Row (Row 3)**:
   - Place `emufp8CheckBox` ("Emulate FP8") on the left column (`Left := 14`, `Top := 145`).
   - Place `optipatcherCheckBox` ("OptiPatcher") on the right column (`Left := 140`, `Top := 145`) with `patcherlistLabel` ("Games supported") directly below (`Left := 148`, `Top := 167`).

## Impact
- Creates a clean 2x2 grid of checkboxes below two side-by-side comboboxes.
- Improves visual balance, spacing, and user experience inside the OptiScaler sub-card.
