# Proposal

## Why

Users running games through Bottles need clear guidance on how to apply GOverlay's generated `bgmod` launch command inside the modern Bottles UI. While the Apply Configuration dialog (`finish_dialog.pas`) already includes dedicated tabs for Steam, Heroic, and Lutris, Bottles is missing, leaving users without launcher-specific instructions or an animated walkthrough.

## What Changes

- Add a **"Bottles"** platform tab (`fpBottles`) to the Apply Configuration dialog (`TFinishDialogForm`) alongside Steam, Heroic, and Lutris.
- Add a monochrome `256x256` RGBA platform icon at `assets/icons/bottles-gray.png`, adapted from the official Bottles icon to match the existing monochrome launcher icons.
- Format the displayed and copied command for modern Bottles (`BuildBottlesCommand`): modern Bottles' **Launch Arguments** field supports `%command%` (e.g. `gamemoderun %command%`), so the command must preserve quoting for paths with spaces and always include the `%command%` suffix even when a non-Steam card is selected in GOverlay.
- Display step-by-step instructions and a modern Bottles Libadwaita/GTK4 animated UI walkthrough (`PaintAnimBottles`) showing **Game Settings › Launch › Arguments › Launch Arguments** with a pulsing teal/blue highlight around the **Arguments** input field.

## Capabilities

### New Capabilities
- `finish-dialog-bottles-tab`: Dedicated Bottles tab in the Apply Configuration dialog with monochrome icon, `%command%`-formatted launch command, step-by-step instructions, and animated modern Bottles UI walkthrough.

### Modified Capabilities
<!-- None -->

## Impact

- `finish_dialog.pas`: New `fpBottles` enum value, `FBottlesBtn` platform switcher button, `BuildBottlesCommand`, `BottlesBtnClick`, `PaintAnimBottles`, teal/blue accent color for `FCmdPanel`/`FCmdPromptLbl`, and updated `UpdateForPlatform` / `CopyBtnClick`.
- `assets/icons/bottles-gray.png`: New monochrome icon asset.
- `tests/gui/gui_test_cases.pas`: GUI tests verifying the Bottles tab button, icon loading, command formatting (including `%command%` preservation for non-Steam cards), step instructions, and clipboard copy.
