## Why

In the Upscalers tab, the OptiScaler "Options" card currently features an isolated "ImGUI Menu" sub-card and a crowded "OptiScaler" options section. Reorganizing the "Options" card into a spacious 2-card layout—where OptiScaler occupies the left 67% with 3 distinct vertical columns ("Main", "Spatial Upscaler", "Temporal Upscaler") and FakeNVAPI occupies the right 33%—greatly improves visual hierarchy, breathing room, and logical control grouping.

## What Changes

- **Remove "ImGUI Menu" sub-card**: Remove `FOsImgSec` as a standalone sub-card.
- **Expand OptiScaler section**: Expand `FOsOptiSec` to span 67% of `FOsOptionsCard` width.
- **Section 1 - Main**: Group `File name` (`filenameComboBox`), `Scale` trackbar (`menuscaleTrackBar`), `OptiPatcher` (`optipatcherCheckBox`), and `Menu Toggle Key` (`FOsShortcutCaptureBtn`) vertically under the "Main" sub-header.
- **Section 2 - Spatial Upscaler**: Group `Preferred upscaler` (`preferredUpscalerComboBox`), `Spoof DLSS` (`spoofCheckBox`), and `Force FSR4-i8` (`forceFsr4Int8CheckBox`) vertically under the "Spatial Upscaler" sub-header.
- **Section 3 - Temporal Upscaler**: Group `FG Input` (`fgInputComboBox`), `FG Output` (`fgOutputComboBox`), and `Emulate FP8` (`emufp8CheckBox`) vertically under the "Temporal Upscaler" sub-header.
- **Vertical Dividers**: Add subtle 1px vertical section dividers between the 3 sub-columns inside `FOsOptiSec`.
- **FakeNVAPI position**: Anchor `FOsFakeSec` to the right 33% of `FOsOptionsCard`.

## Capabilities

### New Capabilities
- `optiscaler-options-layout`: Reorganized 3-column sub-section layout for OptiScaler options with incorporated ImGUI menu controls and FakeNVAPI side-card.

### Modified Capabilities

## Impact

- `optiscaler_tab.pas`: `InitOptiScalerTab` and `ReflowOptiScalerTab` procedures.
