# Design: PasPlot Benchmark Renaming and Full-Card Click Selection

## Context

See `proposal.md` for background motivation and `specs/gplot-benchmark-viewer/spec.md` for functional requirements.

PasPlot's run list uses a standard LCL `TCheckListBox` (`FRunCheckListBox`) styled with `lbOwnerDrawFixed`. Its owner-draw procedure (`RunCheckListDrawItem`) paints custom cards over each item. However, LCL only toggles `Checked` within the native checkbox boundary (`X < 20px`), causing clicks on the series dot or text to only change selection focus rather than toggling run inclusion in charts.

Currently, `TGplotRunData.DisplayName` is initialized directly from the CSV filename's timestamp. Every consumer across the dashboard (KPI cards, comparison bars, hardware telemetry, comparative table, and PNG export) already references `DisplayName`, making it the ideal single point of truth for custom run labeling.

## Goals / Non-Goals

**Goals:**
- Enable seamless single-click selection across the entire width of each benchmark item card.
- Provide intuitive renaming via double-click, right-click context menu, `F2` key, and a top toolbar button.
- Store custom labels in a per-game `benchmarks.ini` file without modifying CSV filenames.
- Render the custom label in the card title and preserve the date/time reference in the card footer alongside metrics.

**Non-Goals:**
- Renaming `.csv` files on disk (MangoHud CSV filenames must stay intact for log parsing, chronological sorting, and external tool compatibility).
- Multi-run batch renaming.

## Decisions

### 1. Full-Card Hit-Testing via `OnMouseDown`
- **Choice**: Wire an `OnMouseDown` handler to `FRunCheckListBox`.
  - When `Button = mbLeft` and `X >= 20` (outside the native checkbox boundary):
    - Identify item via `ItemAtPos(Point(X, Y), True)`.
    - If `ssDouble in Shift`: bypass or revert toggle and trigger the rename dialog.
    - Otherwise: toggle `Checked[Idx] := not Checked[Idx]` and call `ReloadCheckedRunsData`.
  - When `Button = mbRight`:
    - Set `ItemIndex` to the right-clicked item so context menu actions apply to that specific run.
- **Cursor**: Set `FRunCheckListBox.Cursor := crHandPoint` to visually signal full-card interactivity.
- **Alternatives Considered**: Replacing `TCheckListBox` with a `TScrollBox` filled with custom `TPanel` cards. *Rejected*: `TCheckListBox` with owner-draw is already fast, lightweight, and supports keyboard navigation.

### 2. Metadata Storage in `benchmarks.ini`
- **Choice**: Store aliases in `~/.config/goverlay/logs/<GameName>/benchmarks.ini` under `[Names]`:
  ```ini
  [Names]
  DOOM_The_Dark_Ages_2026-10-17_15-20-05.csv=Doom DA FSR4
  ```
- **Rationale**:
  - Keeps names co-located with the game's log files.
  - Allows full UTF-8 characters, punctuation, and spaces without filesystem restrictions.
  - Clearing the text restores the default formatted timestamp automatically.
- **Lifecycle Integration**:
  - `LoadRunsForSelectedGame`: Reads `benchmarks.ini` and sets `RunData.DisplayName` if present.
  - `DeleteRunClick`: Deletes the key from `benchmarks.ini` when deleting the CSV and summary files.
- **Alternatives Considered**:
  - Renaming `.csv` directly: *Rejected* because it breaks timestamp regex, chronological sorting, and paired `_summary.csv` associations.
  - Central global config: *Rejected* because moving or inspecting a single game's log folder wouldn't carry its benchmark aliases.

### 3. UI Interaction Triggers for Renaming
- **Choice**: Support 4 access points:
  1. **Double-Click**: Quickest mouse action on any card.
  2. **Context Menu**: Right-click popup (`TPopupMenu`) with "Rename Benchmark... (F2)" and "Delete Benchmark".
  3. **Toolbar Button**: New `FRenameRunBtn` placed on `FTopPanel` at position `(658, 11, 130, 30)`, shifting `Delete Run` and `Export PNG` rightward cleanly.
  4. **Keyboard Shortcut**: Pressing `F2` in `FRunCheckListBox.OnKeyDown`.
- **Dialog**: Standard `InputQuery` modal with current `DisplayName` pre-filled.

### 4. Card Layout in `RunCheckListDrawItem`
- **Choice**:
  - **Title line** (`Top + 6`):
    - If renamed: Displays custom name in bold font (size 9) + `[Baseline]` badge if rank = 0.
    - If unrenamed: Displays timestamp in bold font (size 9) + `[Baseline]` badge if rank = 0.
  - **Footer line** (`Top + 28`):
    - If renamed: Displays formatted date/time followed by metrics (e.g. `2026-10-17 15:20 • 114s • 179 FPS • 285W`).
    - If unrenamed: Displays metrics as before (e.g. `114s • 179 FPS • 285W`).

## Risks / Trade-offs

- **[Double-click double-toggle]** → Double clicking fires a first single click before the double-click event.
  - *Mitigation*: In `MouseDown`, detect `ssDouble in Shift` and restore the check state before opening the rename modal, leaving the checked state unmodified.
- **[Long custom names overflowing card]** → User might type a very long name (e.g. 50+ characters).
  - *Mitigation*: `RunCheckListDrawItem` will use text clipping or measure width to avoid overlapping the `[Baseline]` badge.
