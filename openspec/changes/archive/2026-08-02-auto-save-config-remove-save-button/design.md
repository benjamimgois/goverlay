# Design Document: Auto-Save Configuration & Remove Manual Save Button

## Overview
This document outlines the architectural changes needed to replace the manual "Save" button in GOverlay with instant, debounced auto-save functionality and a subtle "✓ Saved" status indicator.

## Architecture & Implementation Details

### 1. Removal of Manual Save Button
- Remove `saveBitBtn` / `SaveBtn` creation, bounds allocation, and event wiring from `sidebar_nav.pas` and `overlayunit.pas`.
- Create a `savedStatusLabel: TLabel` (or icon + text) in the sidebar footer displaying `"✓ Saved"` in Slate Navy / muted green theme (`clOlive` / `rgb(48,190,240)`).

### 2. Loading Guard Flag (`FLoadingConfig`)
- Declare `FLoadingConfig: Boolean` in `Tgoverlayform`.
- Wrap `LoadMangoHudConfig`, `LoadOptiScalerConfig`, `LoadVkBasaltConfig`, `LoadEnvVarsConfig`, etc. with `FLoadingConfig := True; try ... finally FLoadingConfig := False; end;`.
- In all UI change handlers (`CheckBoxClick`, `ComboBoxChange`, `TrackBarChange`, `EditChange`), add `if FLoadingConfig then Exit;`.

### 3. Debounce Timer (`autoSaveTimer: TTimer`)
- Create a `TTimer` with `Interval := 300` and `Enabled := False`.
- Sliders and text fields start/restart `autoSaveTimer` on change.
- When `autoSaveTimer` fires, execute active tab save and disable timer.

### 4. Tab Auto-Save Triggers
- **MangoHud**: Call `SaveMangoHudConfig(True)` on control changes.
- **OptiScaler**: Call `SaveOptiScalerConfig(True)` on control changes.
- **Post Processing / VkBasalt**: Call `SaveVkBasaltConfig(True)` on control changes.
- **EnvVars / Presets**: Call `SaveEnvVarsConfig(True)` on control changes.

### 5. "Saved" Feedback System
- When any tab save completes, set `savedStatusLabel.Caption := '✓ Saved'` and trigger a 1.5-second fade/hide timer if desired.
