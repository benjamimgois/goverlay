## Why

1. **Auto Launch PasCube Option**: The "Auto launch PasCube" option in the settings menu is redundant for modern GOverlay workflows and should be hidden to reduce settings menu clutter.
2. **Preferred Upscaler Combobox Consistency**: The "Preferred upscaler" combobox items in the OptiScaler tab are currently displayed in uppercase (`AUTO`, `XESS`, `FSR21`, `FSR22`, `FSR4`, `DLSS`), while all other dropdown comboboxes across GOverlay use lowercase labels (`auto`, `xess`, `fsr21`, etc.). Converting these items to lowercase ensures uniform visual styling.

## What Changes

- **Hide Auto Launch PasCube**: Set `FForm.FCubeAutoLaunchItem.Visible := False` in `sidebar_nav.pas` when constructing `settingsMenu`.
- **Lowercase Preferred Upscaler Labels**: Update `preferredUpscalerComboBox` items in `overlayunit.lfm` to lowercase strings (`auto`, `xess`, `fsr21`, `fsr22`, `fsr4`, `dlss`).

## Capabilities

### New Capabilities
- `pascube-autolaunch-visibility`: Controls the visibility of PasCube auto-launch settings menu item.
- `lowercase-preferred-upscalers`: Standardizes preferred upscaler combobox strings to lowercase across UI controls.

### Modified Capabilities

## Impact

- `sidebar_nav.pas`: Sets `FCubeAutoLaunchItem.Visible := False`.
- `overlayunit.lfm`: Updates `preferredUpscalerComboBox` string items to lowercase.
- `tests/gui/gui_test_cases.pas`: Updates/adds GUI assertions for hidden `FCubeAutoLaunchItem` and lowercase combobox items.
