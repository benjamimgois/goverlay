## Why

The current Finish Configuration dialog uses standard operating system window decorations (`bsSingle` with OS borders and title bar) and includes a redundant "Done" button at the bottom. To align the dialog with GOverlay's modern borderless styling (such as the "What's New" changelog window), the dialog should use a borderless window with custom chrome, draggable header, quick top-right close button, and support for the `Escape` key. Additionally, the launch command container needs higher visual contrast and prominent terminal/code styling to make the primary copy-action visually striking and intuitive.

## What Changes

- **Borderless Window Style**: Change `BorderStyle` to `bsNone`, custom paint dark borders matching GOverlay's palette, and provide a custom draggable header area.
- **Top-Right Close Button & Keyboard Shortcuts**: Add a dedicated `✕` close button in the top-right header and enable `Escape` key handling to close the dialog.
- **Remove Redundant "Done" Button**: Remove the bottom "Done" button, streamlining the dialog layout and vertical height.
- **High-Contrast Launch Command Card**: Redesign the command container to resemble a modern terminal/code block with enhanced visual prominence (distinct dark container background, subtle accent border, terminal prompt symbol `❯_` / `$`, clear typography, and a prominent action button for copying).

## Capabilities

### Modified Capabilities
- `finish-configuration-dialog`: Update dialog window style to borderless custom chrome with draggable header, top-right close button, `Escape` key dismissal, remove redundant "Done" button, and enhance visual prominence of the launch command copy container.

## Impact

- `finish_dialog.pas`: Updated UI layout, form border style, header drag handlers, close button, and styled command card.
- No external APIs or configuration files are affected.
