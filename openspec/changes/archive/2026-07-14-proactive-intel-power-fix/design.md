## Context

We want to trigger the Intel power fix flow automatically when enabling the CPU Power checkbox.

## Goals / Non-Goals

**Goals:**
- Trigger the existing `intelpowerfixBitBtnClick` automatically when `cpupowerCheckBox` is clicked and checked, but only if the RAPL path is not readable.

**Non-Goals:**
- Do not trigger during programmatic changes (e.g. loading profile files). We use the `OnClick` event instead of `OnChange` to avoid this.

## Decisions

- **Event connection**:
  Define `procedure cpupowerCheckBoxClick(Sender: TObject);` in `Tgoverlayform`.
  Assign `cpupowerCheckBox.OnClick := @cpupowerCheckBoxClick;` in `FormCreate`.
- **Logic**:
  Verify `cpupowerCheckBox.Checked` is true.
  Try reading `/sys/class/powercap/intel-rapl:0/energy_uj`.
  If not readable, call `intelpowerfixBitBtnClick(Sender)`.
