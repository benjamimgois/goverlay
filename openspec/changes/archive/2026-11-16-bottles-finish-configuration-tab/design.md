# Design

## Context

- See `proposal.md` for motivation.
- `finish_dialog.pas` (`TFinishDialogForm`) currently supports `TFinishPlatform = (fpSteam, fpHeroic, fpLutris)` in a `680x478` custom-drawn dark dialog.
- Each platform button in the switcher is `110x34` with `6px` spacing (`Left = PAD + idx * 116`). Adding a fourth button (`FBottlesBtn` at `PAD + 348`, ending at `476px`) fits comfortably within `680px`.
- Platform icons live in `assets/icons/*-gray.png` (`256x256` RGBA monochrome for Heroic and Lutris) and are loaded into a `20x20` `TImageList` via `LoadPlatformIcon`.
- In `overlayunit.pas`, `GetLaunchCommand` omits `%command%` when `FActiveGameIsNonSteam` is true. However, modern Bottles' **Launch Arguments** dialog explicitly requires `%command%` (e.g., `gamemoderun %command%`) to wrap the game executable.

## Goals / Non-Goals

**Goals:**
- Match the visual style, interaction model, and testability of the existing Steam, Heroic, and Lutris tabs in `finish_dialog.pas`.
- Generate a monochrome `256x256` RGBA `assets/icons/bottles-gray.png` from the official Bottles icon.
- Ensure `BuildBottlesCommand` always produces a valid `%command%`-terminated wrapper command.

**Non-Goals:**
- Automatic detection or editing of Bottles YAML configuration files.
- Supporting legacy Bottles versions that lacked `%command%` in Launch Arguments.

## Decisions

1. **Command formatting (`BuildBottlesCommand`).**
   - Modern Bottles parses arguments with `%command%` substitution, matching Steam's syntax.
   - `BuildBottlesCommand` will normalize `FLaunchCommand` by quoting the `bgmod` path if it contains spaces and appending `%command%` if not already present (handling the case where `ShowFinishDialog` was opened from a non-Steam card).
   - *Alternative considered:* Reusing `FLaunchCommand` verbatim like `fpSteam`. Rejected because `GetLaunchCommand` omits `%command%` for non-Steam cards, which would break wrapper execution in Bottles.

2. **Visual palette & animated walkthrough (`PaintAnimBottles`).**
   - Accent color: Bottles modern teal/blue (`RGBToColor(43, 138, 157)` / `RGBToColor(53, 132, 228)`) for `CmdPanelPaint`, `FCmdPromptLbl`, the `Save` header button, and the pulsing border around the `Arguments` input field.
   - Canvas layout (`644x175`): renders a background `Game Settings` card/header (`Cancel` | `Game Settings` | `Save`) with the `Launch › Arguments` row, overlaid by the `Launch Arguments` modal (`Cancel` | `Launch Arguments` | `Save`), explanatory `%command%` hint text, and the rounded `Arguments` input box with pencil icon and animated cursor/border.
   - All strings in the miniature UI and steps use English to stay consistent with `PaintAnimSteam`, `PaintAnimHeroic`, and `PaintAnimLutris`.

3. **Monochrome icon (`assets/icons/bottles-gray.png`).**
   - Convert the official 3-bottle icon to a `256x256` RGBA grayscale/white silhouette with transparent background so `LoadPlatformIcon` renders it cleanly at `20x20` alongside `steam-gray.png`, `heroic-gray.png`, and `lutris-gray.png`.

## Risks / Trade-offs

- [Non-Steam card opened before clicking Bottles] → Mitigated by `BuildBottlesCommand` normalizing quotes and ensuring `%command%` is always appended.
- [Bottles UI changes in future releases] → Same low-risk trade-off as Steam/Heroic/Lutris walkthroughs; isolated to `PaintAnimBottles` and `FStepsLabel`.
