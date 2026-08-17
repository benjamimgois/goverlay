## Context

See `proposal.md` for motivation and background. `TFinishDialogForm` in `finish_dialog.pas` currently inherits standard OS window decorations (`BorderStyle := bsSingle`), contains a redundant bottom "Done" button, and renders a basic command panel. `TChangelogForm` in `changelogunit.pas` already establishes GOverlay's borderless window pattern with custom dragging and close controls.

## Goals / Non-Goals

**Goals:**
- Convert `TFinishDialogForm` to `BorderStyle := bsNone` with custom borders drawn on `OnPaint`.
- Implement a custom draggable header bar with game/dialog title, subtitle, and top-right `✕` close button.
- Support modal dismissal via clicking `✕` or pressing the `Escape` key (`VK_ESCAPE`).
- Remove the redundant bottom "Done" button and adjust window dimensions for a compact, balanced layout.
- Restyle the launch command container into a high-contrast terminal-like card with distinct background, subtle accent border, terminal prompt (`❯_` / `$`), clear monospace font, and a prominent action button for copying with feedback.

**Non-Goals:**
- Modifying the underlying animation frames or launcher logic for Steam/Heroic walkthroughs.
- Altering external notification or launcher integration pipelines.

## Decisions

### 1. Borderless Window and Custom Chrome
- **Choice**: Use `BorderStyle := bsNone`, `Color := RGBToColor(22, 26, 40)` and draw custom outer borders in `OnPaint` (`Canvas.Rectangle` with `RGBToColor(45, 55, 80)` and 2px width), matching `changelogunit.pas`.
- **Rationale**: Keeps visual consistency across GOverlay popups and eliminates jarring OS titlebars.
- **Alternatives considered**: Retaining `bsSingle` with OS titlebar (rejected per user request).

### 2. Header Dragging and Close Controls
- **Choice**: Add an `FHeaderPanel` (height 56px) hosting the title, subtitle, and close button. Attach `HeaderMouseDown`, `HeaderMouseMove`, and `HeaderMouseUp` to handle window repositioning. Add `FCloseIconLbl` with `✕` (hover effect to highlight on mouse over) and wire `OnKeyDown` with `KeyPreview := True` for `VK_ESCAPE`.
- **Rationale**: Guarantees standard desktop usability on all Linux window managers (X11 / Wayland).

### 3. Removal of "Done" Button and Height Adjustment
- **Choice**: Remove `FCloseBtn` and reduce dialog height to ~510px so the step-by-step instructions sit cleanly at the bottom without empty dead space.
- **Rationale**: Simplifies interaction — users copy the command and close via `✕` or `Esc`.

### 4. High-Contrast Terminal-Style Command Card
- **Choice**: Style `FCmdPanel` with a deep dark background (`RGBToColor(16, 20, 30)`), an accent-tinted border (`RGBToColor(48, 80, 120)` / dynamic accent matching the active platform), a bright monospace font (`DejaVu Sans Mono`, 9pt, `RGBToColor(78, 195, 252)`), a terminal prompt indicator (`❯_`), and a styled action button (`FCopyBtn`) with distinct fill and green feedback state on copy.
- **Rationale**: Makes the primary action in this dialog immediately eye-catching and clear.

## Risks / Trade-offs

- **[Risk] Window dragging in Wayland/X11**: Without OS titlebars, users must be able to drag the window naturally.
  - *Mitigation*: Header panel, title, and subtitle all propagate mouse drag events to move the form smoothly.
- **[Risk] Modal closure without Done button**: Users may expect multiple ways to dismiss the dialog.
  - *Mitigation*: Support top-right `✕`, `Escape` key, and standard modal return.
