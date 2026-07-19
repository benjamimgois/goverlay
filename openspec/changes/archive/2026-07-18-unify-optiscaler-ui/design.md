## Context

Currently, the OptiScaler tab's UI layout switches dynamically based on the selected channel. Under the Stable channel, GOverlay displays the "FSR Version" combobox and hides "Force FSR4-i8". Under the Bleeding-edge channel, GOverlay hides "FSR Version" and repositions "Force FSR4-i8" to take its place. To unify the layout, GOverlay needs to apply the Bleeding-edge layout (hiding FSR Version and displaying Force FSR4-i8) to both channels.

## Goals / Non-Goals

**Goals:**
- Present a unified layout for the FSR version section in both the Stable and Bleeding-edge channels.
- Hide the FSR Version combobox and label on both channels.
- Display the "Force FSR4-i8" checkbox aligned in place of the combobox on both channels.

**Non-Goals:**
- Completely removing the `fsrversionComboBox` from the `.lfm` layout file (it must still exist in the form, just remain hidden).

## Decisions

### Decision 1: Unify UI logic in `fsrversionComboBoxChange`
- **Choice**: Refactor `Tgoverlayform.fsrversionComboBoxChange` in `overlayunit.pas` to always hide `fsrversionLabel` and `fsrversionComboBox`, force `fsrversionComboBox.ItemIndex := 0`, and show `forceFsr4Int8CheckBox` positioned at `fsrversionComboBox.Left` and `emufp8CheckBox.Top` for both channels.
- **Rationale**: `fsrversionComboBoxChange` is the centralized procedure for synchronizing FSR-related controls. Modifying this method keeps all dynamic UI layout changes in one place and avoids editing the static `.lfm` form files.

## Risks / Trade-offs

- **[Risk]** The `fsrversionComboBox` state might get out of sync.
  - *Mitigation*: The `fsrversionComboBox.ItemIndex := 0` call is forced at the beginning of the handler to ensure that FSR version defaults to "Latest" for all channels.
