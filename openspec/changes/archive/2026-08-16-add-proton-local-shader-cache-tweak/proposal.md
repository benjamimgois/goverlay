## Why

Proton-CachyOS supports the `PROTON_LOCAL_SHADER_CACHE=1` environment variable to enable per-game local shader cache storage instead of relying exclusively on global shared shader caches. Adding this tweak under the "Performance" group in the EnvVars tab gives users a convenient toggle in GOverlay, with clear visual indication that it is tailored for Proton-CachyOS.

## What Changes

- Add `PROTON_LOCAL_SHADER_CACHE=1` to the `TWEAK_ROWS` definition array in `tweaks_md3.pas` under the `TWEAK_CAT_PERF` ("Performance") category.
- Set its description to `"[proton-cachyos] Enable per-game shader cache"`, taking advantage of the existing purple `[proton-cachyos]` prefix styling.
- Add `FProtonLocalShaderCacheCheckBox` backing component in `overlayunit.pas` and map it in `GetTweakRowCheckBox`.
- Support saving to and loading from `bgmod.conf` (`PROTON_LOCAL_SHADER_CACHE=1` under `[Env]`).
- Display tooltip `"Works only with proton-cachyos"` on hover in the EnvVars tab.

## Capabilities

### New Capabilities

- `proton-local-shader-cache-tweak`: Toggle support for `PROTON_LOCAL_SHADER_CACHE=1` under the Performance category of the EnvVars tab.

### Modified Capabilities

*(None)*

## Impact

- `overlayunit.pas`: Declares `FProtonLocalShaderCacheCheckBox`.
- `tweaks_md3.pas`: Increases `TWEAK_ROW_COUNT` from 29 to 30, defines the new row, hooks up persistence, UI interactions, and tooltips.
