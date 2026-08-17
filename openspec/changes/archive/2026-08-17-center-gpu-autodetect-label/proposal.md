# Proposal: Center GPU Driver Auto Detect Label and Slightly Reduce Font Size

## Why

In the "GPU Driver" section of the "Upscalers" tab, the "Auto Detected" label (`autodetectmesaLabel` / `autodetectnvLabel`) is currently positioned at the left edge of the driver image (`PAD + 22` / `PAD + ItemW + 22`). Because the label is narrower than the driver logo image, it appears misaligned and awkwardly anchored to the left under the radio button and image. Horizontally centering the label relative to the driver logo image and slightly reducing its font size gives the UI a cleaner, balanced, and more polished presentation.

## What Changes

- In `optiscaler_tab.pas` `InitOptiScalerTab`:
  - Set `autodetectmesaLabel.Font.Size := 8;` and `autodetectnvLabel.Font.Size := 8;` for a cleaner, subtle badge style.
- In `optiscaler_tab.pas` `ReflowOptiScalerTabNew`:
  - Calculate `autodetectmesaLabel.Left` as `PAD + 22 + (MesaW - autodetectmesaLabel.Width) div 2` to horizontally center it with `mesaImage`.
  - Calculate `autodetectnvLabel.Left` as `PAD + ItemW + 22 + (NvW - autodetectnvLabel.Width) div 2` to horizontally center it with `nvidiaImage`.

## Capabilities

### Modified Capabilities
- `upscalers-dlss-enabler`: Add requirement that the GPU Driver "Auto Detected" label is horizontally centered relative to the driver logo image with a reduced font size.

## Impact

- `optiscaler_tab.pas`: Updated `InitOptiScalerTab` font size and `ReflowOptiScalerTabNew` horizontal alignment math.
