# Proposal: Modernize TrackBars and Value Labels Across All Tabs

## Problem Statement

Currently, trackbars across GOverlay—including MangoHud (Visual, Performance, Extras), built-in vkBasalt effects, and OptiScaler—rely on legacy/default Qt6 widget rendering. They display inconsistent groove heights, generic rectangular or grey thumbs, and plain value labels positioned awkwardly below the slider controls (e.g. in the MangoHud Visual tab).

In contrast, the new Lossless Scaling tab introduced a modern, cohesive slider design featuring:
- A slim 6px groove with rounded ends matching the slate-navy dark palette (`rgb(38,46,72)`).
- An active progress sub-page fill in vibrant cyan (`rgb(48,190,240)`).
- A circular thumb with a cyan border and white hover feedback.
- Clean value labels highlighted in bold cyan (`CLR_TEXT_ACCENT` / `[fsBold]`) aligned neatly to the right of horizontal sliders.

Applying this modern design language universally across all tabs will elevate visual consistency and polish across the entire application.

## Proposed Solution

1. **Global Qt Stylesheet for `QSlider` (Horizontal & Vertical)**:
   - Extend `GlobalSS` in `overlayunit.pas` and `themeunit.pas` (`DoApplyTheme` / `ApplyDarkTheme`) to include full styling rules for `QSlider`.
   - Provide rules for horizontal sliders (`QSlider::groove:horizontal`, `QSlider::sub-page:horizontal`, `QSlider::handle:horizontal`).
   - Provide rules for vertical sliders (`QSlider::groove:vertical`, `QSlider::add-page:vertical`, `QSlider::handle:vertical`) used in Performance (Anisotropic filtering, Mipmap LOD bias) and Extras (Benchmark duration, delay, interval).
   - Support both Dark and Light theme modes.

2. **Reposition and Highlight Value Labels in MangoHud Visual Tab**:
   - In `mangohud_ui.pas`, update `transpTrackBar` (Alpha) and `fontsizeTrackBar` (Size) layout:
     - Shift `alphavalueLabel` and `fontsizevalueLabel` from below the trackbars to the right side of the sliders.
     - Apply cyan accent color (`CLR_TEXT_ACCENT` = `$00F0BE30` / `rgb(48,190,240)`) and bold style (`[fsBold]`).
     - Update `ReflowVisualTab` width calculations to cleanly accommodate the right-aligned value labels.

3. **Standardize Value Labels in Other Tabs**:
   - In `overlayunit.lfm` / `overlayunit.pas` / `vkbasalt_tab.pas`:
     - Update CAS, FXAA, SMAA, and DLS value labels to `CLR_TEXT_ACCENT` and `[fsBold]`.
     - Update vertical slider value labels in Performance (`afvalueLabel`, `mipmapvalueLabel`) and Extras (`durationvalueLabel`, `delayvalueLabel`, `intervalvalueLabel`) to `CLR_TEXT_ACCENT` and `[fsBold]`.
     - Update OptiScaler menu scale value label (`mark2Label`) to match accent styling.

## Capabilities

### Modified Capabilities
- `ui-design-system`: Standardizes `QSlider` / `TTrackBar` styling tokens and value label alignment across all application tabs.

## Impact

- All sliders across all tabs instantly gain a unified, modern, slate-navy and cyan appearance.
- Improved readability and visual hierarchy on all slider-based settings.
- Zero breaking changes to underlying configuration persistence or logic handlers.
