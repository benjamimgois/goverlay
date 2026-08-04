# Design: Hide PasCube AutoLaunch and Lowercase Preferred Upscalers

## Context

1. **PasCube AutoLaunch**: In `sidebar_nav.pas` line 334, `FCubeAutoLaunchItem` ("Auto launch PasCube") is created and inserted into `settingsMenu`. Setting `FForm.FCubeAutoLaunchItem.Visible := False` hides the menu item.
2. **Preferred Upscaler Combobox Labels**: `preferredUpscalerComboBox` in `overlayunit.lfm` stores items in uppercase (`AUTO`, `XESS`, `FSR21`, `FSR22`, `FSR4`, `DLSS`). Updating `overlayunit.lfm` to lowercase (`auto`, `xess`, `fsr21`, `fsr22`, `fsr4`, `dlss`) aligns with all other comboboxes without breaking `ItemIndex` mappings or `SameText` config parsers in `overlay_config.pas`.

## Design Decisions

### 1. Hide PasCube Auto-Launch Menu Item
In `sidebar_nav.pas`:
```pascal
FForm.FCubeAutoLaunchItem.Visible := False;
```

### 2. Lowercase Preferred Upscaler Items
In `overlayunit.lfm`:
```lfm
Items.Strings = (
  'auto'
  'xess'
  'fsr21'
  'fsr22'
  'fsr4'
  'dlss'
)
```

## Risk Analysis

- **Config Persistence Compatibility**: `overlay_config.pas` maps `PreferredUpscalerItemIndex` by numeric index (0..5) and parses INI values using `SameText`, so case changes in UI labels will not break configuration loading or saving.
