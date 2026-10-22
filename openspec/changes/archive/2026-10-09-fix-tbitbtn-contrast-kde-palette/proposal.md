# Proposal

## Why

On Linux desktop environments with hybrid or light application palettes (specifically Kubuntu 26.04 and KDE Plasma with Breeze Twilight / Breeze Light), several `TBitBtn` controls throughout GOverlay render illegible black or dark charcoal text over dark card backgrounds (issue #423).

Investigation revealed that in Lazarus LCL-Qt (Qt5 and Qt6), `TQtBitBtn` intercepts the `QEventPaint` event and manually paints button text via `QPainter_drawText`. This painter initializes its pen color using the Qt widget's palette role `QPalette::ButtonText`. Under KDE Breeze Light or Hybrid themes, `ButtonText` defaults to dark charcoal/black (`#2b2e32`), completely ignoring both LCL `TBitBtn.Font.Color` (which only sets `QPalette::WindowText`) and QSS stylesheet rules (`QPushButton { color: white; }`).

## What Changes

- **Centralized Button Palette Synchronization (`StyleBitBtnTheme`)**: Introduce a helper in `themeunit.pas` (or `overlay_utils.pas`) that applies both the QSS stylesheet and explicitly sets `QPaletteButtonText` and `QPaletteWindowText` on the underlying `QWidget` handle via `QPalette_setColor` and `QWidget_setPalette`.
- **Generic Card Containers (`UpdateGenericCardTheme`)**: Update container traversal so every `TBitBtn` child (such as `gpuframesjouleBitBtn`, `coreloadtypeBitBtn`, `cpuframesjouleBitBtn`, `intelpowerfixBitBtn`) automatically receives synchronized palette and stylesheet contrast.
- **Visual Tab Buttons**: Ensure `FColumnsMinusBtn`, `FColumnsPlusBtn`, and `FVisualCaptureBtn` receive palette and stylesheet synchronization on creation and theme update.
- **Performance Tab Buttons**: Style `fpsavgBitBtn`, `frametimetypeBitBtn`, and `FLimitCaptureBtn` with palette and stylesheet synchronization.
- **Extras & Remaining Tabs**: Style `FTimeConfigBtn`, `logfolderBitBtn`, `FLoggingCaptureBtn`, and other tab buttons across the app.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `ui-theme-contrast`: Expand button contrast requirements to explicitly enforce Qt Palette synchronization (`QPaletteButtonText` and `QPaletteWindowText`) for `TBitBtn` controls, guaranteeing crisp text contrast across all desktop environment styles.

## Impact

- `themeunit.pas`: Helper for setting button Qt Palette (`QPaletteButtonText`, `QPaletteWindowText`) and stylesheet.
- `overlayunit.pas`: Update `UpdateGenericCardTheme` to apply palette styling to `TBitBtn`.
- `mangohud_ui.pas`: Apply palette synchronization across Visual, Performance, Metrics, and Extras tabs.
- No config file format changes or breaking API changes.
