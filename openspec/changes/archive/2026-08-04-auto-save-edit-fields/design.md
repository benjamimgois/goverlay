## Context

See `proposal.md` for motivation. Currently `WireAutoSaveEvents` in `overlayunit.pas` binds change/click handlers for `TCheckBox`, `TRadioButton`, `TComboBox`, `TColorButton`, `TListBox`, and `TSpinEdit`, but omits `TCustomEdit`. As a result, editing text fields does not trigger `TriggerAutoSave` or show the `✓ Saved` status label.

## Goals / Non-Goals

**Goals:**
- Include `TCustomEdit` (excluding `Tag = 9999` search box) in `WireAutoSaveEvents`.
- Ensure typing in any text edit field fires `@GenericControlChange`, triggering the 300ms debounced auto-save.

**Non-Goals:**
- Auto-saving on global search input (`searchEdit`, `Tag = 9999`).

## Decisions

1. **Wire `TCustomEdit.OnChange` to `@GenericControlChange` in `WireAutoSaveEvents`**:
   - *Decision*: In `WireAutoSaveEvents`, add check `else if (Ctrl is TCustomEdit) and (Ctrl.Tag <> 9999) then begin if not Assigned(TCustomEdit(Ctrl).OnChange) then TCustomEdit(Ctrl).OnChange := @GenericControlChange; end`.
   - *Rationale*: Leverages existing `FLoadingConfig` guard and 300ms debounced `autoSaveTimer` infrastructure seamlessly across all tabs.
