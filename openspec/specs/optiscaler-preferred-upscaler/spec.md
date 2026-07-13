# Preferred Upscaler and Wine Prefix Settings

This capability defines the relocation of the Wine Prefix configuration menu item and the introduction of a preferred upscaler dropdown selection to configure game-specific upscale rendering targets.

## Requirements

### Requirement: Wine Prefix Button Relocation
GOverlay SHALL move the "Wine prefix" configuration button from the OptiScaler tab into GOverlay's settings menu (gear icon modal), positioned directly below "Status" with a separator line.

#### Scenario: Relocated Wine Prefix Click
- **WHEN** the user opens the GOverlay settings modal
- **THEN** they see the "Wine prefix" configuration button directly under the Status settings and separated by a divider line.

### Requirement: Preferred Upscaler Combobox
The OptiScaler tab SHALL display a combobox titled "Preferred upscaler" in place of the relocated "Wine prefix" button. The combobox SHALL contain the options: `auto`, `xess`, `fsr21`, `fsr22`, `fsr4`, `dlss`.

#### Scenario: Display Preferred Upscaler Combobox
- **WHEN** the user opens the OptiScaler configuration tab
- **THEN** they see a "Preferred upscaler" combobox with the specified upscaler selection choices.

### Requirement: Write Preferred Upscaler to Configuration
Changing the "Preferred upscaler" selection SHALL update the `Dx11Upscaler=`, `Dx12Upscaler=`, and `VulkanUpscaler=` keys in `OptiScaler.ini` to the selected value, except for `"fsr4"`, which SHALL map to the configuration value `"fsr31"`.

#### Scenario: Selecting FSR4 Preferred Upscaler
- **WHEN** the user selects "fsr4" from the Preferred upscaler combobox
- **THEN** GOverlay writes `Dx11Upscaler=fsr31`, `Dx12Upscaler=fsr31`, and `VulkanUpscaler=fsr31` inside the `OptiScaler.ini` file.

#### Scenario: Selecting XeSS Preferred Upscaler
- **WHEN** the user selects "xess" from the Preferred upscaler combobox
- **THEN** GOverlay writes `Dx11Upscaler=xess`, `Dx12Upscaler=xess`, and `VulkanUpscaler=xess` inside the `OptiScaler.ini` file.
