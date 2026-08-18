# Design: Modernize TrackBars and Value Labels Across All Tabs

## Context

GOverlay features multiple tabs containing sliders/trackbars (`TTrackBar`), including:
1. **MangoHud ➔ Visual**: `transpTrackBar` (Alpha), `fontsizeTrackBar` (Size)
2. **MangoHud ➔ Performance**: `afTrackBar` (Anisotropic Filtering), `mipmapTrackBar` (Mipmap LOD bias)
3. **MangoHud ➔ Extras**: `durationTrackBar` (Duration), `delayTrackBar` (Autostart), `intervalTrackBar` (Interval)
4. **Post Processing (vkBasalt)**: `casTrackBar`, `fxaaTrackBar`, `smaaTrackBar`, `dlsTrackBar`, and 15 dynamic `FVsTrackbars` (vkSumi)
5. **Upscalers (OptiScaler)**: `menuscaleTrackBar`
6. **Upscalers (Lossless Scaling)**: `FLsFlowScaleTrackBar`

Previously, only `FLsFlowScaleTrackBar` had custom Qt CSS applied locally in `lossless_scaling_tab.pas`. Other trackbars used default LCL Qt6 rendering with inconsistent styles and value labels placed below the sliders.

## Goals / Non-Goals

**Goals:**
- Inject global QSS rules for `QSlider` (both horizontal and vertical) into `GlobalSS` (`overlayunit.pas`) and `themeunit.pas`.
- Reposition `alphavalueLabel` and `fontsizevalueLabel` in `mangohud_ui.pas` to the right of their respective trackbars.
- Format all slider value labels with `CLR_TEXT_ACCENT` ($00F0BE30 / `rgb(48,190,240)`) and `[fsBold]`.
- Update `ReflowVisualTab` in `mangohud_ui.pas` to ensure elastic resizing properly accounts for the right-aligned value labels.
- Ensure light theme compatibility.

**Non-Goals:**
- Changing slider min/max/step values or underlying configuration persistence logic.
- Rewriting `TTrackBar` with custom canvas painting (Qt QSS via LCL Qt6 widgetset is the established, performant, and declarative pattern in GOverlay).

## Decisions

### 1. Global QSS Injection for `QSlider`
- **Choice**: Add `QSlider` rules to `GlobalSS` in `overlayunit.pas` (`FormShow`) and `themeunit.pas` (`DoApplyTheme`):
  ```css
  /* Horizontal Sliders */
  QSlider::groove:horizontal { height: 6px; background: rgb(38,46,72); border-radius: 3px; }
  QSlider::sub-page:horizontal { background: rgb(48,190,240); border-radius: 3px; }
  QSlider::handle:horizontal { background: rgb(220,225,240); border: 1px solid rgb(48,190,240); width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; }
  QSlider::handle:horizontal:hover { background: rgb(255,255,255); }

  /* Vertical Sliders */
  QSlider::groove:vertical { width: 6px; background: rgb(38,46,72); border-radius: 3px; }
  QSlider::add-page:vertical { background: rgb(48,190,240); border-radius: 3px; }
  QSlider::handle:vertical { background: rgb(220,225,240); border: 1px solid rgb(48,190,240); height: 14px; margin-left: -4px; margin-right: -4px; border-radius: 7px; }
  QSlider::handle:vertical:hover { background: rgb(255,255,255); }
  ```
- **Rationale**: Setting this at the form root level styles every `QSlider` universally without needing per-control boilerplate.

### 2. Layout Geometry in MangoHud Visual Tab (`mangohud_ui.pas`)
- **Initial Placement**:
  - `transpTrackBar`: `Place(transpTrackBar, FVisualSections[2], 52, 56)`
  - `alphavalueLabel`: `Place(alphavalueLabel, FVisualSections[2], 52 + transpTrackBar.Width + 8, 58)`
  - `fontsizeTrackBar`: `Place(fontsizeTrackBar, FVisualSections[3], 60, 140)`
  - `fontsizevalueLabel`: `Place(fontsizevalueLabel, FVisualSections[3], 60 + fontsizeTrackBar.Width + 8, 142)`
- **Reflow**:
  - `transpTrackBar.Width := SecW3 - 52 - 40;`
  - `alphavalueLabel.Left := transpTrackBar.Left + transpTrackBar.Width + 8;`
  - `fontsizeTrackBar.Width := SecW1 - 60 - 40;`
  - `fontsizevalueLabel.Left := fontsizeTrackBar.Left + fontsizeTrackBar.Width + 8;`
- **Rationale**: Keeps label text right-aligned and vertically centered with the slider track, eliminating the awkward gap below the sliders.

### 3. Typography Standardization
- Set `Font.Color := CLR_TEXT_ACCENT` and `Font.Style := [fsBold]` on all value labels across Visual, vkBasalt, Performance, and Extras tabs.

## Risks / Trade-offs

- **Risk**: Very narrow container widths could clip the value labels if not accounted for in reflow.
  - **Mitigation**: Reserve a fixed 40px margin for value labels, which is more than sufficient for typical numeric values (e.g. `0.6`, `24`, `100%`).
