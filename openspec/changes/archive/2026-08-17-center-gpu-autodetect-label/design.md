# Design: Center GPU Driver Auto Detect Label and Slightly Reduce Font Size

## Context

`autodetectmesaLabel` and `autodetectnvLabel` are child controls of `FOsGpuCard` in `optiscaler_tab.pas`. They display "Auto Detected" beneath the driver logo when GOverlay automatically detects the active graphics driver on clean launch.

## Goals / Non-Goals

**Goals:**
- Horizontally center `autodetectmesaLabel` relative to `mesaImage`.
- Horizontally center `autodetectnvLabel` relative to `nvidiaImage`.
- Slightly reduce the font size of both labels (`Font.Size := 8`).

**Non-Goals:**
- Modifying GPU driver detection logic or radio button switching behavior.

## Decisions

### Decision 1: Horizontal Centering Formula
- **Choice**:
  ```pascal
  MesaW := Min(144, ItemW - 24);
  mesaImage.SetBounds(PAD + 22, HDR + (GPU_GH - 58) div 2 - 2, MesaW, 58);
  autodetectmesaLabel.SetBounds(PAD + 22 + (MesaW - autodetectmesaLabel.Width) div 2,
                                HDR + GPU_GH - autodetectmesaLabel.Height - 2,
                                autodetectmesaLabel.Width,
                                autodetectmesaLabel.Height);

  NvW := Min(185, ItemW - 24);
  nvidiaImage.SetBounds(PAD + ItemW + 22, HDR + (GPU_GH - 42) div 2 - 2, NvW, 42);
  autodetectnvLabel.SetBounds(PAD + ItemW + 22 + (NvW - autodetectnvLabel.Width) div 2,
                              HDR + GPU_GH - autodetectnvLabel.Height - 2,
                              autodetectnvLabel.Width,
                              autodetectnvLabel.Height);
  ```
- **Rationale**: Uses dynamic control widths so centering remains exact regardless of text string length or DPI changes.

### Decision 2: Font Styling
- **Choice**: In `InitOptiScalerTab`, set `autodetectmesaLabel.Font.Size := 8;` and `autodetectnvLabel.Font.Size := 8;`.
- **Rationale**: 8pt font provides a compact, clean badge presentation that harmonizes with the header and logo hierarchy.
