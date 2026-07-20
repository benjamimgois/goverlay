## Why

Our previous fix causes a "configuration saved" desktop notification and displays the
launcher command panel whenever the user alternates between NVIDIA and MESA GPU drivers,
as well as during application startup. We need to implement a silent saving mechanism
for auto-saved driver options and prevent config-saves entirely during GOverlay startup
when loading existing preferences.

## What Changes

- **Avoid Saves During Startup**: Add a loading guard (`FOsDriverLoading`) so that setting GPU
  driver RadioButton checks at program startup does not trigger any configuration saves.
- **Silent Save Parameter**: Add an optional parameter `ASilent` (default `False`) to
  `SaveOptiScalerConfig` to bypass desktop notifications and startup command panel invalidations
  when the configuration is updated programmatically.
- **Silent Save on Driver Toggle**: Set `SaveOptiScalerConfig(True)` on driver change events
  so the dependent checkboxes are saved silently.

## Capabilities

### New Capabilities
- *(none)*

### Modified Capabilities
- `bgmod-update-optiscaler`: Driver preference changes and startup loading must not spawn user-facing notification messages or show startup command panels.

## Impact

- `overlayunit.pas`: `SaveOptiScalerConfig` definition/forward, `nvidiaRadioButtonChange`, `mesaRadioButtonChange`, and `FormCreate` (initialization).
- `optiscaler_tab.pas`: `SaveOptiScalerConfig` signature and helper implementation.
