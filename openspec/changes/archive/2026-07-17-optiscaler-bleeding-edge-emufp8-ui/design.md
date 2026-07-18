## Context

Currently, the `emufp8CheckBox` is hidden when the user selects the bleeding-edge OptiScaler channel. Under bleeding-edge, this checkbox will be utilized for a new purpose: activating FSR MLFG on RDNA3 GPUs. The tooltip/hint needs to change to explain this new function. However, the `forceFsr4Int8CheckBox` occupies the exact same layout slot (`Left := 134`, `Top := 142`), which would cause overlap if both checkboxes were visible.

## Goals / Non-Goals

**Goals:**
- Retain the "Emulate FP8" checkbox (`emufp8CheckBox`) visible and enabled when switching to bleeding-edge.
- Dynamically update the hint of `emufp8CheckBox` based on the channel selection.
- Shift the layout position of `forceFsr4Int8CheckBox` downwards (`Top := 165`) so it does not overlap with `emufp8CheckBox`.

**Non-Goals:**
- Changing the internal configuration key (`DXIL_SPIRV_CONFIG` / `wmma_rdna3_workaround`) associated with `emufp8CheckBox`.

## Decisions

### Decision 1: Shift forceFsr4Int8CheckBox vertically
In `optiscaler_tab.pas`, change `forceFsr4Int8CheckBox.Top` from `142` to `165`. This positions it directly underneath `emufp8CheckBox` (which is at `Top := 142`), ensuring clean columns and no overlapping.

### Decision 2: Dynamically configure visibility and hints in fsrversionComboBoxChange
In `overlayunit.pas` `fsrversionComboBoxChange`:
- If `optversionComboBox.ItemIndex = 1` (Bleeding-edge):
  * Set `emufp8CheckBox.Visible := True;`
  * Set `emufp8CheckBox.Enabled := True;`
  * Change `emufp8CheckBox.Hint` to `'Emulate FP8' + LineEnding + 'Used to activate FSR MLFG on RDNA3';`
  * Set `forceFsr4Int8CheckBox.Visible := True;` (if assigned).
- If `optversionComboBox.ItemIndex = 0` (Stable):
  * Set `emufp8CheckBox.Hint` back to the default `'Emulate FP8' + LineEnding + 'Emulates FP8 floating point precision';`
  * Follow the existing FSR version index logic to show/hide/disable it.
  * Hide `forceFsr4Int8CheckBox` (if assigned).

## Risks / Trade-offs

- **Risk:** Controls might overlap on small window sizes.
  * **Mitigation:** The OptiScaler card height is `BOX_H = 280`, and the next control (`optipatcherCheckBox`) is at `Top := 216`, leaving a large vertical gap (from 165 to 216) which easily fits the shifted checkbox.
