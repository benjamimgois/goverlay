# Tasks: Reorganize OptiScaler Sub-Card Controls Layout

## Implementation Steps
- [x] 1. Update control positioning in `optiscaler_tab.pas`:
  - [x] 1.1 Move `preferredUpscalerLabel` and `preferredUpscalerComboBox` to Row 1 right column (`Left := 134`, `Top := 40/61`).
  - [x] 1.2 Position `spoofCheckBox` and `forceFsr4Int8CheckBox` in Row 2 (`Top := 105`, `Left := 14 / 134`).
  - [x] 1.3 Position `emufp8CheckBox`, `optipatcherCheckBox`, and `patcherlistLabel` in Row 3 (`Top := 145/167`).
- [x] 2. Build & verify layout:
  - [x] 2.1 Recompile with `lazbuild --build-mode=Release goverlay.lpi`.
  - [x] 2.2 Verify control alignment and interactions in OptiScaler sub-card.
