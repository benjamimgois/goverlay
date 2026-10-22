## 1. Data Model and Platform Switcher

- [x] 1.1 Add `fpLutris` to `TFinishPlatform` enum and declare `FLutrisBtn: TSpeedButton` and `LutrisBtnClick` in `TFinishDialogForm` within `finish_dialog.pas`
- [x] 1.2 Instantiate and position `FLutrisBtn` in `TFinishDialogForm.BuildUI` adjacent to `FHeroicBtn`, and verify button geometry within dialog bounds
- [x] 1.3 Update `UpdateForPlatform` in `finish_dialog.pas` to set button states, prompt colors (Lutris orange), panel border, font auto-scaling, and 3-step setup instructions for Lutris

## 2. Command Formatting and Clipboard

- [x] 2.1 Implement `BuildLutrisCommand: string;` in `finish_dialog.pas` returning the unquoted wrapper path without `%command%`
- [x] 2.2 Update `CopyBtnClick` to copy `BuildLutrisCommand` when `fpLutris` is active and show visual copied feedback

## 3. Procedural Canvas Mockup

- [x] 3.1 Implement `PaintAnimLutris(ACanvas: TCanvas; AW, AH: Integer)` in `finish_dialog.pas` rendering Lutris Libadwaita window frame, header bar with Search and active Advanced toggle, and System options tab
- [x] 3.2 Draw the "Game execution" group card, "Command prefix" input field with pulsating orange border, blinking cursor, undo icon `↩`, and bouncing guide arrow `>`
- [x] 3.3 Connect `fpLutris` branch in `AnimBoxPaint` to `PaintAnimLutris` and verify animation redraws cleanly

## 4. Verification and Automated Tests

- [x] 4.1 Add GUI tests in `tests/gui/gui_test_cases.pas` verifying switching to Lutris, `BuildLutrisCommand` formatting, step instructions, and `PaintAnimLutris` execution
- [x] 4.2 Compile and run GUI test suite to verify tests pass with zero regressions
