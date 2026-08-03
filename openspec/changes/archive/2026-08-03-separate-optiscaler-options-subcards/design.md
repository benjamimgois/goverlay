# Design: Separate OptiScaler Options into 4 Independent Sub-Cards

## Architecture Overview

Currently, `FOsOptionsCard` contains two child panels:
1. `FOsOptiSec` (75% width): Shared by Main, Spatial, and Temporal sections; uses `OnPaint` to draw vertical divider lines.
2. `FOsFakeSec` (25% width): Dedicated sub-card panel for Reflex / Antilag settings with its own header label `FOsFakeLbl`.

We will replace `FOsOptiSec` with 3 separate sub-card panels, resulting in 4 equal-width sub-card panels parented to `FOsOptionsCard`:

```
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│  Options                                                                                       │
│ ┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐ ┌─────────────────────────┐ │
│ │ FOsMainSec        │ │ FOsSpatialSec     │ │ FOsTemporalSec    │ │ FOsFakeSec              │ │
│ │ (Main)            │ │ (Spatial Upscaler)│ │ (Temporal Upscaler│ │ (Reflex / Antilag)      │ │
│ └───────────────────┘ └───────────────────┘ └───────────────────┘ └─────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Component Mapping & Control Parenting

### `FOsMainSec` (Column 1 - 25% width)
- Title Header: `FOsMainLbl` ("Main")
- Controls:
  - `filenameLabel` & `filenameComboBox` (DLL selection)
  - `menuLabel` & `menuscaleComboBox` (ImGUI menu scale)
  - `optipatcherCheckBox` & `FOsPatcherListBtn` (OptiPatcher + link)
  - `shortcutkeyLabel` & `FOsShortcutCaptureBtn` (Toggle key capture)

### `FOsSpatialSec` (Column 2 - 25% width)
- Title Header: `FOsSpatialLbl` ("Spatial Upscaler")
- Controls:
  - `preferredUpscalerLabel` & `preferredUpscalerComboBox`
  - `spoofCheckBox` ("Spoof DLSS")
  - `forceFsr4Int8CheckBox` ("Force FSR4-i8")

### `FOsTemporalSec` (Column 3 - 25% width)
- Title Header: `FOsTemporalLbl` ("Temporal Upscaler")
- Controls:
  - `fgInputLabel` & `fgInputComboBox`
  - `fgOutputLabel` & `fgOutputComboBox`
  - `emufp8CheckBox` ("Force MLFG in RDNA3")

### `FOsFakeSec` (Column 4 - 25% width)
- Title Header: `FOsFakeLbl` ("Reflex / Antilag")
- Controls:
  - `forcereflexCheckBox` & `reflexComboBox`
  - `forcelatencyflexCheckBox` & `latencyflexComboBox`

## Paint & Theme Integration
- All 4 panels (`FOsMainSec`, `FOsSpatialSec`, `FOsTemporalSec`, `FOsFakeSec`) set `OnPaint := @SubCardPaint`.
- In `overlayunit.pas`, `SubCardPaint` no longer requires `if P = FOsOptiSec` or `FOsOptiDiv1`/`FOsOptiDiv2` divider line painting.
