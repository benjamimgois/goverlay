## 1. UI Initialization Guards

- [x] 1.1 Declare `FoundIndex` local variable in `FormCreate`
- [x] 1.2 Add `pcidevComboBox.Items.Count > 0` safety guard before accessing `pcidevComboBox.Items[0]`
- [x] 1.3 Update GPU index selection to handle empty lists and safely set index 1 fallback only if multiple GPUs exist

## 2. Event Handler Guards

- [x] 2.1 Add bounds check in `pcidevComboBoxChange` before accessing `GPUDESC[pcidevComboBox.ItemIndex]`
