# Design: Reorganize OptiScaler Sub-Card Controls Layout

## Control Placement Math (`optiscaler_tab.pas`)

Inside `InitOptiScalerTab` / `FOsOptiSec`:

```
┌─────────────────────────────────────────────────────────────┐
│ OptiScaler (Top: 12)                                        │
│                                                             │
│ File name (Top: 40, L: 14)  Preferred upscaler (Top: 40, L: 140)
│ ┌───────────────┐           ┌───────────────┐               │
│ │ version.dll  ▼│ (Top: 60) │ AUTO         ▼│ (Top: 60)     │
│ └───────────────┘           └───────────────┘               │
│                                                             │
│ ☐ Spoof DLSS (Top: 105, L:14) ☑ Force FSR4-i8 (Top: 105, L:140)
│                                                             │
│ ☐ Emulate FP8 (Top: 145, L:14)☐ OptiPatcher (Top: 145, L:140)
│                               Games supported (Top: 167, L:148)
└─────────────────────────────────────────────────────────────┘
```

### Coordinates Mapping
- `filenameLabel`: `Top := 40`, `Left := 14`
- `filenameComboBox`: `Top := 60`, `Left := 14`, `Width := 110`
- `preferredUpscalerLabel`: `Top := 40`, `Left := 140`
- `preferredUpscalerComboBox`: `Top := 60`, `Left := 140`, `Width := 110`

- `spoofCheckBox`: `Top := 105`, `Left := 14`
- `forceFsr4Int8CheckBox`: `Top := 105`, `Left := 140`

- `emufp8CheckBox`: `Top := 145`, `Left := 14`
- `optipatcherCheckBox`: `Top := 145`, `Left := 140`
- `patcherlistLabel`: `Top := 167`, `Left := 148`
