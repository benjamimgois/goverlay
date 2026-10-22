# Proposal

## Why

When HelixSR is selected as the active upscaler method in GOverlay, the "Spoof DLSS" toggle switch is currently hidden from the user interface. Because standard HelixSR deployment uses OptiScaler as a frontend injector with HelixSR as the backend, games that lack native AMD FSR support require DLSS spoofing so that the in-game settings expose the DLSS toggle, allowing OptiScaler to intercept DLSS API calls and route them into HelixSR.

Hiding the "Spoof DLSS" toggle prevents users on non-NVIDIA GPUs from configuring DLSS spoofing when using HelixSR, breaking compatibility in DLSS-only titles.

## What Changes

- Keep the "Spoof DLSS" toggle (`FSpoofToggle` / `spoofCheckBox`) visible and operable when HelixSR is the selected upscaler method.
- Reflow the controls inside the "Spatial Upscaler" column (`FOsSpatialSec`) during HelixSR mode to neatly accommodate both HelixSR tuning controls (sharpener, sharpness, wave size, native DLSS toggle) and the DLSS Spoofing toggle.
- When Experimental Native DLSS mode is enabled, disable or hide DLSS spoofing appropriately since native DLSS bypasses the OptiScaler pipeline.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `helixsr-runtime-management`: Add requirement and scenarios for DLSS spoofing configuration accessibility during HelixSR mode.

## Impact

- `optiscaler_tab.pas`: `ReflowOptiScalerTabNew` spatial sub-column layout logic.
- GUI test suite: update or add test asserting `FSpoofToggle` / `spoofCheckBox` remains visible and toggleable when `helixsrRadioButton.Checked` is true.
