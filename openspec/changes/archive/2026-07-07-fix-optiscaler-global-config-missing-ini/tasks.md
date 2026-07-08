## 1. Core Loader and Saver Fallback Implementation

- [x] 1.1 In `overlay_config.pas` `SaveOptiScalerConfigCore`, check if `OptiScalerIniPath` exists. If not, read the active update channel selection and copy the template/default `OptiScaler.ini` from the corresponding cache directory (`GetBGModOriginalPath` or `GetBGModOriginalEdgePath`) to `OptiScalerIniPath` before loading it with `TConfigFile`.
- [x] 1.2 In `overlay_config.pas` `LoadOptiScalerConfig`, if the target `OptiScalerIniPath` does not exist in the active profile's configuration directory, resolve the configured channel and fall back to loading settings from the cache folder's `OptiScaler.ini` template.

## 2. Verification

- [x] 2.1 Rebuild GOverlay using `lazbuild` or `make`.
- [x] 2.2 Verify that opening the OptiScaler tab in global mode shows the correct default checkbox states and scale settings.
- [x] 2.3 Verify that changing global settings and clicking Save successfully creates `gameconfig/global/OptiScaler.ini` and persists the updated settings.
