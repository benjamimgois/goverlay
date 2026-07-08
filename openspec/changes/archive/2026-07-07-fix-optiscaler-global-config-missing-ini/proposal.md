## Why

When opening the OptiScaler tab with the global profile active, the "Spoof DLSS" and "Optipatcher" checkboxes are always displayed as empty, and "Scale" is always reset to "1080p/1.0". This happens because `OptiScaler.ini` is never copied/initialized in `gameconfig/global/`. Furthermore, attempting to save the configuration fails to create the file because `TConfigFile.Load` returns `False` for non-existent files, skipping the saving routine completely.

## What Changes

- Modify `SaveOptiScalerConfigCore` to check if `OptiScaler.ini` exists in the target configuration directory. If it is missing, copy the template/default `OptiScaler.ini` from the active channel's cache folder (`optiscaler-stable` or `optiscaler-edge`) before loading and writing settings.
- Modify `LoadOptiScalerConfig` to check if `OptiScaler.ini` exists in the target configuration directory. If it is missing, fallback to loading the default values from the active channel's cache folder's `OptiScaler.ini` so the user interface initializes with correct baseline defaults instead of empty settings.

## Capabilities

### New Capabilities
<!-- Capabilities being introduced. Replace <name> with kebab-case identifier (e.g., user-auth, data-export, api-rate-limiting). Each creates specs/<name>/spec.md -->

### Modified Capabilities
<!-- Existing capabilities whose REQUIREMENTS are changing (not just implementation).
     Only list here if spec-level behavior changes. Each needs a delta spec file.
     Use existing spec names from openspec/specs/. Leave empty if no requirement changes. -->
- `bgmod-update-optiscaler`: Add requirements for fallback loading of default `OptiScaler.ini` settings from cache when missing, and template seeding/creation during save operations.

## Impact

- `overlay_config.pas`: `SaveOptiScalerConfigCore` and `LoadOptiScalerConfig` will be modified to support template copy and fallback resolution of `OptiScaler.ini`.
