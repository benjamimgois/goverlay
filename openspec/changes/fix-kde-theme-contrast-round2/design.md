# Design

## Context

See proposal.md for motivation. The previous round introduced `StyleBitBtnTheme` (`themeunit.pas`), which sets the QSS stylesheet and the `ButtonText`/`WindowText` palette roles. Facts relevant to this round:

- `TQtBitBtn` (LCL-Qt) custom-paints buttons that carry an icon: it lets Qt draw the background, then draws the text with its own `QPainter` whose pen comes from the widget palette. Icon-less buttons use the native path, which honours QSS.
- Metrics buttons (`gpuframesjouleBitBtn`, `cpuframesjouleBitBtn`, `coreloadtypeBitBtn`) are styled via `UpdateGenericCardTheme` → `StyleBitBtnTheme`, but their click handlers change `Caption`/`ImageIndex` (which rebuilds the Qt icon) with no re-style.
- Lossless Scaling buttons are created with `StyleActionButton` (QSS only in dark mode) and then overwritten by their own QSS in `TLosslessScalingTabHelper.ApplyThemeStyles`, with a separate `:disabled` colour pair (dim gray).
- `aboutunit.pas` styles `Color`s only; the main form's `QTabBar` stylesheet is not reused.

The residual cause for the first two items is not proven. The screenshots show dim text consistent with either (a) the palette `ButtonText` not being applied at paint time, or (b) the Disabled colour group / `:disabled` QSS being used.

## Goals / Non-Goals

**Goals:**
- Legible text on the three reported areas under the official Kubuntu theme, in dark and light GOverlay themes.
- A single styling path for buttons so QSS and palette cannot diverge.

**Non-Goals:**
- Replacing the Qt widgets with custom-drawn controls (e.g. BGRAControls).
- Restyling dialogs not reported (howto tabs are hidden and unaffected).

## Decisions

1. **Diagnose before fixing.** Add temporary logging (env `GOVERLAY_DEBUG_THEME`) of `QPalette` ButtonText/WindowText per group, `Enabled`, and stylesheet for the affected buttons, and run on a Kubuntu session. Alternative: patch blindly; rejected because the previous round already did that once and the issue persisted.
2. **Central re-style hook.** Provide a small helper (e.g. `RestyleBitBtn(ABtn)`) calling `StyleBitBtnTheme` with the current theme colours, and call it after every `Caption`/`ImageIndex` change in the Metrics click handlers and config load. Alternative: subclass `TBitBtn`; rejected as too invasive for `.lfm`-declared controls.
3. **Harden `StyleBitBtnTheme` for the icon path.** Set the palette for all colour groups (Active/Inactive/Disabled) including `Text`, and keep the QSS `:disabled` colours in one shared place. Choose the concrete mechanism once step 1 identifies the cause.
4. **Lossless Scaling buttons use `StyleBitBtnTheme`.** Replace the per-button `setStyleSheet` block in `ApplyThemeStyles` with `StyleBitBtnTheme` calls; keep bold weight via the shared helper if still desired. Alternative: only add palette sync next to the existing QSS; rejected because it keeps two sources of truth.
5. **About tab bar.** Reuse the main form's `QTabBar`/`QTabWidget::pane` rules, parameterised by theme, and apply them to `aboutPageControl` in `FormCreate` after `ApplyTheme`. Extract the rules into `themeunit.pas` (`GetTabBarStyleSheet(AIsDark)`) so the main form can share it.

## Risks / Trade-offs

- [Cause of items 1-2 differs from hypothesis] → Decision 1 gates the fix; tasks include re-verification on Kubuntu.
- [Qt version differences (Qt5 vs Qt6)] → verify on the Qt6 build used by the reporter; keep code compatible with both through the existing `{$IFDEF LCLqt6}` units.
- [Re-styling on every click causes flicker] → buttons are tiny; styling only runs on caption/icon change, not on paint.
