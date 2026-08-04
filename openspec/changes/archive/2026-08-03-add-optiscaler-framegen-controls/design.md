# Design: Add OptiScaler Frame Generation Controls

## Layout Mathematics (`optiscaler_tab.pas`)

Inside `InitOptiScalerTab` / `FOsOptiSec`:

```
┌─────────────────────────────────────────────────────────────┐
│ OptiScaler (Top: 12)                                        │
│                                                             │
│ File name (Top: 38, L: 14)  Preferred upscaler (Top: 38, L: 134)
│ ┌───────────────┐           ┌───────────────┐               │
│ │ version.dll  ▼│ (Top: 56) │ AUTO         ▼│ (Top: 56)     │
│ └───────────────┘           └───────────────┘               │
│                                                             │
│ FG Input (Top: 90, L: 14)   FG Output (Top: 90, L: 134)     │
│ ┌───────────────┐           ┌───────────────┐               │
│ │ auto         ▼│ (Top: 108)│ auto         ▼│ (Top: 108)    │
│ └───────────────┘           └───────────────┘               │
│                                                             │
│ ☐ Spoof DLSS (Top: 148, L:14)☑ Force FSR4-i8 (Top: 148, L:134)
│                                                             │
│ ☐ Emulate FP8 (Top: 182, L:14)☐ OptiPatcher (Top: 182, L:134)
│                               Games supported (Top: 204, L:142)
└─────────────────────────────────────────────────────────────┘
```

### Coordinates Mapping
- Row 1: `filenameLabel` / `preferredUpscalerLabel` at `Top := 38`, `filenameComboBox` / `preferredUpscalerComboBox` at `Top := 56`.
- Row 2: `fgInputLabel` / `fgOutputLabel` at `Top := 90`, `fgInputComboBox` / `fgOutputComboBox` at `Top := 108`.
- Row 3: `spoofCheckBox` / `forceFsr4Int8CheckBox` at `Top := 148`.
- Row 4: `emufp8CheckBox` / `optipatcherCheckBox` at `Top := 182`, `patcherlistLabel` at `Top := 204`.

## Persistence Logic (`overlay_config.pas`)

1. **`TOptiScalerSettings` Record**:
   - `FGInputItemIndex: Integer;`
   - `FGOutputItemIndex: Integer;`

2. **Save Logic**:
   ```pascal
   // Map FGInputItemIndex -> string
   case Settings.FGInputItemIndex of
     0: FGInputValue := 'auto';
     1: FGInputValue := 'nofg';
     2: FGInputValue := 'dlssg';
     3: FGInputValue := 'nukems';
     4: FGInputValue := 'fsrfg';
     5: FGInputValue := 'upscaler';
     6: FGInputValue := 'fsrfg30';
   else
     FGInputValue := 'auto';
   end;

   // Map FGOutputItemIndex -> string
   case Settings.FGOutputItemIndex of
     0: FGOutputValue := 'auto';
     1: FGOutputValue := 'nofg';
     2: FGOutputValue := 'fsrfg';
     3: FGOutputValue := 'xefg';
     4: FGOutputValue := 'nukems';
   else
     FGOutputValue := 'auto';
   end;

   OptiCfg.SetValue('FGInput=', FGInputValue, 'FrameGen');
   OptiCfg.SetValue('FGOutput=', FGOutputValue, 'FrameGen');

   if (FGInputValue <> 'auto') or (FGOutputValue <> 'auto') then
     OptiCfg.SetValue('Enabled=', 'true', 'FrameGen')
   else
     OptiCfg.SetValue('Enabled=', 'auto', 'FrameGen');
   ```
