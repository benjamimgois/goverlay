# Tasks: Modernize Steam Finish Dialog Guide

## 1. Finish Dialog Modern Steam Redesign

- [x] 1.1 Update `TFinishDialogForm` and `ShowFinishDialog` in `finish_dialog.pas` to accept and store an optional game title parameter
- [x] 1.2 Implement modern Steam window Canvas renderer in `PaintAnimSteam` with dark sidebar (`#131922`), cyan game title (`#1A9FFF`), active `General` pill (`#2B3947`), inactive menu items (`#8F98A0`), `General` panel header, Steam Overlay toggle, and `Launch Options` helper text
- [x] 1.3 Implement animated pulsing cyan border highlight, blinking cursor, and animated guide arrow pointing to the `Launch Options` input field
- [x] 1.4 Update callers of `ShowFinishDialog` across `overlayunit.pas` and `games_tab.pas` to pass the currently active game title (or default to `'GLOBAL OVERLAY'`)

## 2. Testing and Validation

- [x] 2.1 Add automated GUI test case in `tests/gui/gui_test_cases.pas` verifying Finish Configuration dialog rendering with custom game titles and platform switching
- [x] 2.2 Run full test suite (`make test` and `make test-logic`) and verify clean release build
