# Proposal: Fix Controls Text Contrast under Hybrid and Light Desktop Themes

## Why

On Linux desktop environments with hybrid or light application themes (notably Kubuntu 26.04 and KDE Plasma with Breeze Twilight or Breeze Light), several UI controls in GOverlay have illegible black text rendered over dark card backgrounds (reported in issue #423). This occurs because GOverlay renders custom dark cards but relies on system Qt styling without explicit stylesheets or foreground font colors for certain widgets, causing Qt's QStyle (Breeze) to paint text using the system's dark charcoal/black palette (`QPalette::WindowText` / `QPalette::ButtonText`).

## What Changes

Following Approach A (surgical fix):
- **Filter Radio Buttons (`filterRadioGroup`)**: Update the stylesheet to explicitly specify text color for `QGroupBox` and child `QRadioButton` widgets matching the current GOverlay theme (white on dark, dark on light), preventing illegible black labels under hybrid/light system styles.
- **Shortcut Capture Buttons**: Apply consistent Qt stylesheets (`QPushButton, QToolButton`) and explicit `Font.Color` to all key capture buttons across tabs:
  - `FVisualCaptureBtn` (HUD Toggle Key on Visual tab)
  - `FLimitCaptureBtn` (Limit toggle key on Performance tab)
  - `FLoggingCaptureBtn` (Logging toggle key on Extras tab)
- **Columns Plus / Minus Buttons (`FColumnsMinusBtn`, `FColumnsPlusBtn`)**:
  - Set explicit `Font.Color := TextColor` on creation and theme update.
  - Expand stylesheet selector to include `QToolButton` (`QPushButton, QToolButton`).
- **Generic Card Theme (`UpdateGenericCardTheme`)**:
  - Extend stylesheet rule on card handles from `QCheckBox` to `QCheckBox, QRadioButton` so any radio buttons in generic cards retain proper contrast.

## Capabilities

### New Capabilities
- `ui-theme-contrast`: Ensures all controls, action/capture buttons, and selection widgets maintain readable text contrast against their background across desktop themes (including hybrid and light KDE/Plasma themes).

### Modified Capabilities
<!-- None -->

## Impact

- `mangohud_ui.pas`: Update `InitPerformanceTab`, `UpdateVisualCardTheme`, `UpdatePerfCardTheme`, `UpdateExtrasCardTheme`, and button initialization.
- `overlayunit.pas`: Update `UpdateGenericCardTheme` stylesheet rule.
- No breaking changes or configuration file format changes.
