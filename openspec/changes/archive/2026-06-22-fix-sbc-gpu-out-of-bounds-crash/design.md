## Context

On single board computers (SBCs) or any systems running arm64/aarch64 with integrated non-PCI GPUs (e.g. Mali), `lspci` does not return any VGA/3D/video controller devices. In GOverlay (`overlayunit.pas`), the initialization code parses the output of `lspci` and populates the `pcidevComboBox` component. When no GPUs are found, `pcidevComboBox` remains empty. However, the initialization code subsequently attempts to access `pcidevComboBox.Items[0]`, resulting in a "List index (0) out of bounds" crash.

## Goals / Non-Goals

**Goals:**
- Prevent GOverlay from crashing on startup when no PCI GPUs are detected.
- Handle empty lists of PCI GPUs gracefully.
- Prevent subsequent index out of bounds exceptions when changing selection on `pcidevComboBox` if empty.

**Non-Goals:**
- Implementing fully fledged non-PCI GPU detection on SBCs; standard graphics drivers and/or MangoHud defaults are sufficient.

## Decisions

### 1. Guard `pcidevComboBox` Index Accesses
- **Decision:** Check `pcidevComboBox.Items.Count` before accessing `Items[0]` or setting `ItemIndex` to index values >= 0.
- **Alternatives Considered:**
  - *Mocking a GPU:* Adding a fake placeholder GPU in the list when empty. However, this could write invalid PCI device information to MangoHud config.
  - *Guarding accesses (Chosen):* Simple, standard Pascal safety guard. If empty, set `ItemIndex` to -1 and `gpudescEdit.Text` to empty.

### 2. Guard `pcidevComboBoxChange` handler
- **Decision:** In `pcidevComboBoxChange`, check bounds `(pcidevComboBox.ItemIndex >= 0) and (pcidevComboBox.ItemIndex < GPUDESC.Count)` before indexing into `GPUDESC`.
- **Alternatives Considered:**
  - None, this is a standard index bounds check.

## Risks / Trade-offs

- **Risk:** No PCI device configuration is written to MangoHud.
- **Mitigation:** On SBCs/non-PCI GPU systems, MangoHud automatically selects/detects the active GPU vendor, so leaving `gpu_list` unset is correct.
