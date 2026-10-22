# Design: Dim Unselected Method Logos in OptiScaler and Lossless Scaling Tabs

## Context

See `proposal.md` for motivation. In Lazarus LCL (Qt6 widgetset), setting `TImage.Enabled := False` disables mouse event routing but does not dim the rendered bitmap or alter pixel transparency. Both `UpdateUpscalerImageOpacity` in `overlayunit.pas` and `UpdateMethodImageOpacity` in `lossless_scaling_tab.pas` relied on `.Enabled`, resulting in no visible brightness change between active and inactive options.

## Goals / Non-Goals

**Goals:**
- Provide clear visual prominence for the selected method logo (100% full brightness) while distinctly dimming inactive method logos (~35% brightness).
- Ensure instantaneous and flicker-free tab switching and radio button selection with zero computational overhead at click time.
- Keep logos interactive: clicking a dimmed logo still selects the associated method radio button.
- Ensure proper memory cleanup of all newly allocated graphic objects.

**Non-Goals:**
- Modifying the underlying banner assets on disk (`assets/icons/*.png`).
- Changing layout dimensions, margins, or positioning of the radio buttons and cards.
- Adding smooth animated transitions/fades (instant assignment is standard and matches the rest of the application).

## Decisions

### 1. Pre-compute Dimmed PNGs on Tab Initialization
- **Decision**: Pre-allocate and store both full-brightness and dimmed `TPortableNetworkGraphic` instances in memory during tab initialization.
- **Rationale**: There are only 3 images per tab (6 images total, totaling < 200KB memory). Pre-generating them once allows `UpdateUpscalerImageOpacity` and `UpdateMethodImageOpacity` to simply perform `Picture.Assign(CachedGraphic)` in O(1) time when clicking options.
- **Alternative considered**: Dynamically calculating and dimming pixel buffers on each click. Rejected because pixel loops on user input cause perceptible frame drops or stutter.

### 2. Dimming Algorithm: RGB Channel Attenuation with Alpha Preservation
- **Decision**: Implement `CreateDimmedPng(ASrc: TPortableNetworkGraphic; BrightFactor: Integer): TPortableNetworkGraphic` using `TLazIntfImage` to scale the red, green, and blue color channels (`Byte(Integer(SrcRow[px]) * BrightFactor div 100)`) while preserving the alpha byte (`DstRow[px+3] := SrcRow[px+3]`) for 32-bit images.
- **Factor**: `BrightFactor = 35` (35% brightness).
- **Rationale**: On the dark card background (`RGB(26, 30, 46)`), lowering RGB brightness to 35% creates a natural subdued look that matches native desktop dark mode conventions without making the icon unreadable or disappearing into the background.

### 3. Location of Helper Function
- **Decision**: Place `CreateDimmedPng` in a shared location accessible by both `overlayunit.pas` / `optiscaler_tab.pas` and `lossless_scaling_tab.pas` (or directly in `apputils.pas`).
- **Rationale**: Prevents code duplication between the OptiScaler and Lossless Scaling tab helpers.

## Risks / Trade-offs

- **[Memory leak from graphic objects]** → Mitigated by declaring explicit destructor cleanup (`FreeAndNil`) for all dimmed PNG objects in `TOptiScalerTabHelper.Destroy` (or `Tgoverlayform.FormDestroy`) and `TLosslessScalingTabHelper.Destroy`.
- **[Loss of click event on dimmed image]** → `TImage.Enabled` must remain `True` (unlike the old implementation) so that clicking the dimmed logo triggers its `OnClick` event to select the corresponding radio button.
