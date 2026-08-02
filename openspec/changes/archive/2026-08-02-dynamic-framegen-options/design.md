# Design Document: Dynamic Frame Generation Options per Upscaler Mode

## Overview
This document outlines the architecture for dynamically switching FG Input and FG Output combobox items and tooltips based on the selected upscaler mode (OptiScaler vs DLSS-Enabler).

## Implementation Details

### 1. UI Handler in `optiscaler_tab.pas`
Create helper method `UpdateFrameGenOptionsUI(IsDLSSEnamler: Boolean)`:
- Save current selected text for `fgInputComboBox` and `fgOutputComboBox`.
- Repopulate `fgInputComboBox.Items` and `fgOutputComboBox.Items` according to `IsDLSSEnamler`.
- Update `fgInputComboBox.Hint` and `fgOutputComboBox.Hint` with mode-specific strings.
- Re-select matching string or equivalent index (`nukems` <-> `nvngxfg`).

### 2. Event Wiring in `optiscaler_tab.pas` & `overlayunit.pas`
- Call `UpdateFrameGenOptionsUI` when initializing controls, loading configuration, or whenever `optiscalerRadioButton` or `dlssenablerRadioButton` are toggled.

### 3. Config Parsing & Persistence in `overlay_config.pas`
- Update `SaveOptiScalerConfigCore` to serialize index to appropriate string (`nukems` vs `nvngxfg`, `dlssgwithnvngx`, etc.) depending on `Settings.UpscalerTypeItemIndex`.
- Update `LoadOptiScalerConfig` to handle parsing for both modes cleanly.
