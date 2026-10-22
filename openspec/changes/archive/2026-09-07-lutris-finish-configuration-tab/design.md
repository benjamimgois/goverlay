## Context

`finish_dialog.pas` implements `TFinishDialogForm`, a modal dialog displaying launch instructions and animated UI mockups for Steam (`fpSteam`) and Heroic Games Launcher (`fpHeroic`). Platform selection is managed via `TSpeedButton` instances in a single button group. Custom procedural painting on `FAnimBox: TPaintBox` renders animated launcher mockups at ~30 FPS. See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Extend `TFinishPlatform` with `fpLutris`.
- Add `FLutrisBtn` horizontally aligned alongside `FSteamBtn` and `FHeroicBtn`.
- Format the command string for Lutris without surrounding quotes and without `%command%`.
- Implement `PaintAnimLutris` with authentic Lutris GTK4/Libadwaita styling, animated pulsating border around the "Command prefix" input, cursor blink, and guide indicator.
- Display concise 3-step setup instructions in `FStepsLabel`.
- Maintain test coverage in `tests/gui/gui_test_cases.pas`.

**Non-Goals:**
- Automatically modifying Lutris game `.yml` configurations on disk (GOverlay provides copy-paste guidance).
- Changing default tab selection (regular games default to Steam; non-Steam games continue to default to Heroic).

## Decisions

### 1. Command Generation Sharing
- **Choice**: Implement `BuildLutrisCommand: string;` which shares the same sanitization logic as `BuildHeroicCommand` (strips `%command%`, `%COMMAND%`, and quotes).
- **Rationale**: Both Heroic's wrapper field and Lutris's command prefix require an unquoted executable path prepended to the game launch.
- **Alternatives**: Duplicating string manipulation logic, or renaming `BuildHeroicCommand` to a generic name. Keeping `BuildHeroicCommand` and adding `BuildLutrisCommand` preserves backwards compatibility with existing tests while keeping callers clean.

### 2. Accent Color and UI Mockup Theme
- **Choice**: Use Lutris brand orange (`#FA7C14` / `RGBToColor(250, 124, 20)`) for terminal prompt, panel border, and mockup highlight accents. The canvas mockup uses Libadwaita dark window styling (`#242424`) with the "System options" tab active, "Advanced" switch ON, and the "Game execution" card containing the "Command prefix" input.
- **Rationale**: Provides clear visual differentiation from Steam (cyan) and Heroic (teal), immediately signaling the Lutris platform context to the user.
- **Alternatives**: Reusing a generic accent color. Dedicated branding colors make the platform distinction unmistakable.

### 3. Button Layout and Geometry
- **Choice**: Position `FLutrisBtn` at `Left := PAD + 116 * 2` (250px) with `Width := 110`.
- **Rationale**: Fits comfortably within the dialog width (`DLG_W = 680px`), using 360px total width for the 3 platform buttons with ample margin.

## Risks / Trade-offs

- **[Risk]** Users might not see the "Command prefix" field in Lutris if the "Advanced" toggle is off.
  - **Mitigation:** Explicitly include `(enable "Advanced" if needed)` in step 2 of `FStepsLabel`, and render the "Advanced" toggle switch in the active state in `PaintAnimLutris`.
- **[Risk]** Long file paths overflowing the mockup input box.
  - **Mitigation:** Apply string truncation with ellipsis (`...`) in `PaintAnimLutris`, matching the existing behavior of `PaintAnimSteam` and `PaintAnimHeroic`.
