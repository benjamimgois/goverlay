# Tasks

## 1. Monochrome Icon Asset

- [x] 1.1 Convert the official Bottles icon into a monochrome `256x256` RGBA PNG at `assets/icons/bottles-gray.png` matching the style of `heroic-gray.png` and `lutris-gray.png`; verify dimensions and RGBA format with `file assets/icons/bottles-gray.png`.

## 2. Apply Configuration Dialog (`finish_dialog.pas`)

- [x] 2.1 Add `fpBottles` to `TFinishPlatform`, create `FBottlesBtn` (`Bottles`, `Left := PAD + 348`) with `LoadPlatformIcon(FBottlesBtn, 'bottles-gray.png', FPlatformImages)`, and add `BottlesBtnClick` + `BottlesBtn` property; verify the project compiles cleanly.
- [x] 2.2 Implement `BuildBottlesCommand` (quoting `bgmod` path when spaces are present and ensuring `%command%` suffix is always included), wire `fpBottles` into `UpdateForPlatform`, `CopyBtnClick`, and `CmdPanelPaint` (teal/blue accent); verify with GUI tests covering both Steam and non-Steam launch inputs.
- [x] 2.3 Implement `PaintAnimBottles` (modern Libadwaita `Game Settings` + `Launch Arguments` overlay with English labels, `%command%` hint, and pulsing teal/blue border around the `Arguments` field) and dispatch `fpBottles` in `AnimBoxPaint`; verify by running the GUI test suite and visually inspecting the dialog.
- [x] 2.4 Add GUI test cases in `tests/gui/gui_test_cases.pas` verifying the Bottles tab button, icon loading, `BuildBottlesCommand` formatting, step instructions, and clipboard copy; verify `make test` passes.
