# Proposal: Modernize Heroic Finish Dialog Guide

## Why

The Finish Configuration popup currently displays an outdated legacy Heroic Games Launcher settings mockup (vertical sidebar with "Other" tab). In modern versions of Heroic, settings navigation tabs are arranged horizontally across the top (`WINE | OTHER | ADVANCED | CLOUD SAVES | GAMESCOPE | LEGACY`), and the Wrapper configuration is located on the **`ADVANCED`** tab, requiring the user to scroll down to the `Wrapper Command` section (`Wrapper` and `Arguments` fields with an add `[+]` button). Updating the animation and instructions ensures users are accurately guided through modern Heroic without confusion.

## What Changes

- Redesign the custom Canvas animation in `finish_dialog.pas` for the Heroic platform (`PaintAnimHeroic`) to replicate modern Heroic Games Launcher:
  - Add top title bar featuring `<Game Title> (Settings)` (or `GLOBAL OVERLAY (Settings)`) and top-right close `✕` icon.
  - Add horizontal tab bar (`WINE | OTHER | ADVANCED | CLOUD SAVES | GAMESCOPE | LEGACY`) with `ADVANCED` highlighted in Heroic cyan/teal (`#55EBD8`) and a solid cyan underline indicator.
  - Render a vertical scrollbar track on the right with the thumb positioned down, visually indicating a scrolled-down state on the `ADVANCED` tab.
  - Render the `Wrapper Command:` section with `Wrapper` and `Arguments` subheaders, two dark input fields, and a green/teal `[+]` add button (`#00C9B7`).
  - Animate an interactive cyan pulsing border and blinking cursor in the `Wrapper` field with a bouncing guide arrow.
- Update the step-by-step instruction text in `finish_dialog.pas` (`UpdateForPlatform`) for Heroic:
  - `1. Click "Copy" above to copy the wrapper command.`
  - `2. In Heroic, open game Settings › Advanced › scroll down to "Wrapper Command".`
  - `3. Paste into the "Wrapper" field, click "+", and save.`

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `finish-configuration-dialog`: Update animated walkthrough and instruction steps for Heroic Games Launcher to depict modern horizontal tabs, Advanced tab scroll down, Wrapper Command fields, and add button.

## Impact

- `finish_dialog.pas`: Updated `PaintAnimHeroic` rendering and `UpdateForPlatform` instruction captions.
- `tests/gui/gui_test_cases.pas`: Regression tests for Heroic finish dialog rendering and instruction text validation.
