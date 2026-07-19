## Why

Moving the Wine prefix setting of the OptiScaler tab into GOverlay's global config menu cleans up the tab layout and groups system prefix configurations together. This also frees up layout space in the OptiScaler tab to introduce a "Preferred upscaler" selection combobox, simplifying the configuration of Dx11, Dx12, and Vulkan upscalers in `OptiScaler.ini`.

## What Changes

- Move the "Wine prefix" button and functionality from the OptiScaler tab into GOverlay's settings menu (gear icon modal), positioned directly below "Status" with a separator line.
- Add a "Preferred upscaler" combobox to the OptiScaler tab (options: `auto`, `xess`, `fsr21`, `fsr22`, `fsr4`, `dlss`).
- Selecting a preferred upscaler updates `Dx11Upscaler=`, `Dx12Upscaler=`, and `VulkanUpscaler=` settings in `OptiScaler.ini` to the chosen value (or `"fsr31"` if `"fsr4"` is selected).

## Capabilities

### New Capabilities
- `optiscaler-preferred-upscaler`: Introducing preferred upscaler select capability.

### Modified Capabilities
<!-- None -->

## Impact

- `overlayunit.pas` / `overlayunit.lfm`: Move "Wine prefix" button UI components and logic to the settings panel.
- `optiscaler_update.pas`: Implement "Preferred upscaler" combobox UI controls and configuration writer routine for `OptiScaler.ini`.
