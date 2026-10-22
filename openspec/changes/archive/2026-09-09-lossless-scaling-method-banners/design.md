## Context

In the Lossless Scaling tab (`lossless_scaling_tab.pas`), Card 0a (`FLsMethodCard`) presents three method options: None, lsfg-vk, and MAKO. Currently, `lsfg-vk` and `MAKO` use separate 34x34 square `TImage` widgets paired with adjacent `TLabel` controls. This contrasts with the OptiScaler tab (`FOsUpscalerCard`), which uses self-contained rectangular logo banners next to each `TRadioButton`.

## Goals / Non-Goals

**Goals:**
- Add high-resolution transparent assets `assets/icons/method_lsfg.png` and `assets/icons/method_mako.png` featuring squircle rounded icons and uniform white bold typography.
- Update `lossless_scaling_tab.pas` to use composite banner images for `FLsLsfgImage` and `FLsMakoImage` at 36px height.
- Remove redundant label controls `FLsLsfgLbl` and `FLsMakoLbl`.
- Update `SetupLayout` calculations to position the banners with balanced spacing across Card 0a.
- Update `UpdateMethodImageOpacity` to toggle `Enabled` state on the banner images directly for active/inactive visual feedback.

**Non-Goals:**
- No changes to interpolation logic, `conf.toml` serialization, or environment variable handling.
- No modifications to the Target GPU Device card (Card 0b) or other cards in the tab.

## Decisions

### Decision 1: High-Resolution Transparent PNG Assets
- **Choice**: Generate `method_lsfg.png` (468x144 px) and `method_mako.png` (387x144 px) with transparent backgrounds.
- **Rationale**: Matches the pattern of `upscaler_optiscaler.png` and `upscaler_dlss_enabler.png`. When rendered with `AntialiasingMode := amOn`, `Stretch := True`, and `Proportional := True`, LCL/Qt scales the assets cleanly to height 36px on both standard and HiDPI displays.
- **Alternatives Considered**: Drawing text on a custom paint event or overlaying a `TLabel` over the image. Both introduce cross-desktop theme inconsistencies and complex alignment code.

### Decision 2: Geometry and Layout Sizing
- **Choice**:
  - `LogoW_None := 48` (Height 20, centered at `(GPU_GH - 20) div 2`)
  - `LogoW_Lsfg := 117` (Height 36, centered at `(GPU_GH - 36) div 2`)
  - `LogoW_Mako := 97` (Height 36, centered at `(GPU_GH - 36) div 2`)
  - Groups:
    - `GroupW_None := 22 + LogoW_None` (70px)
    - `GroupW_Lsfg := 22 + LogoW_Lsfg` (139px)
    - `GroupW_Mako := 22 + LogoW_Mako` (119px)
    - `TotalGroupW := 328px`
  - Leftover space (`InnerW - TotalGroupW`) is distributed evenly as gap padding.
- **Rationale**: 328px total group width fits comfortably within `CardW` (which is typically ~360-400px), maintaining visual equilibrium with the adjacent Card 0b.

### Decision 3: Removal of Text Labels
- **Choice**: Remove `FLsLsfgLbl` and `FLsMakoLbl` from the class fields, creation, layout, and opacity update routines.
- **Rationale**: The banner image already contains the crisp stylized text. Removing the labels eliminates unnecessary widgets and simplifies `UpdateMethodImageOpacity`.

## Risks / Trade-offs

- **[Asset loading failure]** → Mitigation: Use standard GOverlay asset resolution pattern (`GetAppBaseDir + 'assets/icons/method_*.png'` with fallback to relative `assets/icons/method_*.png`).
