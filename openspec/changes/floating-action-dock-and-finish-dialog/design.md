## Context

Currently, GOverlay utilizes a permanent bottom bar (`goverlaybarPanel`) across all tabs. This bar hosts the static Steam command text box (`commandPanel`), the quick preview button (`FPreviewBtn`), popup menu button (`popupBitBtn`), and download progress bar (`updateProgressBar`). This legacy structure restricts vertical screen space and clutters the UI.

See `proposal.md` for motivation and background.

## Goals / Non-Goals

**Goals:**
- Free vertical space across all configuration tabs by removing the fixed `goverlaybarPanel`.
- Implement a floating action dock (pill-style dock) in the bottom-right corner hosting contextual Preview, Menu, and Finish Config buttons.
- Implement a dedicated modal Finish Configuration dialog with platform selection (Steam / Heroic), lightweight procedural canvas step-by-step animations, one-click copy, and English instructions.
- Implement floating UI overlays for automatic save feedback (toast) and component download progress (banner).
- Ensure all new UI texts, labels, and notifications are in English.

**Non-Goals:**
- Embedding external video player libraries or bundling heavy video files (lightweight custom canvas animation replaces video playback).
- Changing backend configuration generators or profile storage formats.

## Decisions

### 1. Floating Action Dock Architecture
- **Approach**: Create a dedicated floating dock control on `goverlayPanel`, anchored to `[akRight, akBottom]` with `BorderSpacing.Right := 24` and `BorderSpacing.Bottom := 20`.
- **Styling**: Rendered as a pill (rounded rectangle radius = 20px) with dark surface `#181B26`, subtle border `#2E3748`, and depth elevation.
- **Contextual Adaptation**:
  - `FPreviewBtn` (`▶ Preview`): Visible only on MangoHud, vkBasalt, and vkSumi tabs.
  - `FMenuBtn` (`☰`): Opens `popsaveMenu` popup.
  - `FFinishBtn` (`🚀 Finish Config`): Primary accented button, opens the Finish Configuration dialog on all tabs.
- **Alternatives considered**:
  - *Multiple individual floating circle buttons*: Clutters the screen and creates alignment issues across varying tab layouts.
  - *Keep fixed bottom bar*: Wastes ~40px of vertical space continuously.

### 2. Finish Configuration Modal Dialog (`finish_dialog.pas`)
- **Approach**: Build a dedicated `TFinishDialogForm` modal dialog with clean dark styling.
- **Platform Switching**: Segmented selector for `Steam` and `Heroic Games Launcher`.
- **Canvas-based Step-by-Step Animation**:
  - Instead of relying on `.mp4` video files or external media player processes, render procedural 2D visual animations on a `TPaintBox` using a lightweight timer (~30ms tick).
  - Demonstrates a stylized launcher UI with pulsating highlight cues over the Launch Options / Wrapper text input.
  - Ensures 100% reliability across native Linux distros, Flatpak, and AppImage without codec or player dependencies.
- **One-Click Clipboard Copy**: Copies the active command to `Clipboard.AsText` and provides instant feedback (`✓ Copied!`) on the copy button.

### 3. Floating Auto-Save Toast & Download Progress Banner
- **Auto-Save Toast**: Floating unobtrusive badge anchored at `[akLeft, akBottom]` showing `"✓ Settings saved automatically"` that fades out after 1.8 seconds.
- **Download Progress Banner**: Floating progress card positioned near the top of the interface displaying percentage and status text in English during background downloads.

## Risks / Trade-offs

- **[Risk]** Floating dock might obscure the bottom-most controls on scrolled tabs.
  - *Mitigation*: Add 60px bottom padding / margin to all scrollable content panels across all tabs so users can comfortably scroll past the dock.
- **[Risk]** Procedural canvas animations might consume unnecessary CPU when dialog is closed.
  - *Mitigation*: Ensure animation timers are active only while `TFinishDialogForm` is visible and cleanly stopped on form close.
- **[Risk]** Existing GUI unit tests check for `commandPanel` and `goverlaybarPanel` properties.
  - *Mitigation*: Update unit tests in `tests/gui/` to validate the new floating action dock and dialog interactions.
