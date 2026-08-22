## Why

Currently, GOverlay couples the injection of DLL-based upscalers (OptiScaler or DLSS Enabler) with the general "Upscalers" feature set. The "Method" card only allows selecting between `OptiScaler` and `DLSS Enabler`, and saving OptiScaler settings always writes `GOVERLAY_OPTISCALER=1` to `bgmod.conf`.

As a consequence, users who want to use **only Lossless Scaling (`lsfg-vk`)** without injecting OptiScaler/DLSS Enabler proxy DLLs into their game cannot do so. Introducing a `"None"` option under the "Method" card allows setting `GOVERLAY_OPTISCALER=0` in `bgmod.conf` while keeping Lossless Scaling active, allowing independent execution of both features.

## What Changes

- Add a 3rd radio option `"None"` with a dedicated standardized icon in the **"Method"** card of the OptiScaler sub-tab.
- When `"None"` is selected:
  - Set `GOVERLAY_OPTISCALER=0` and `UPSCALER_TYPE=2` in `bgmod.conf` `[Config]`.
  - Disable/dim the configuration controls in the "Options" card (Preferred upscaler, FG input/output, Reflex, etc.) to visually indicate that no proxy upscaler DLLs will be injected into the game.
  - Upon game launch via `bgmod`, OptiScaler proxy DLLs are uninstalled/cleaned from the game directory and no `WINEDLLOVERRIDES` are exported.
- When `OptiScaler` or `DLSS Enabler` is selected:
  - Set `GOVERLAY_OPTISCALER=1` and corresponding `UPSCALER_TYPE` (0 for OptiScaler, 1 for DLSS Enabler).
  - Enable the relevant configuration controls.
- Update sidebar navigation logic (`sidebar_nav.pas`) so that the "Upscalers" sidebar switch reflects `ON` when **either** `GOVERLAY_OPTISCALER=1` **or** `GOVERLAY_LOSSLESS=1` is enabled, and turning it off disables both.

## Capabilities

### Modified Capabilities
- `upscalers-dlss-enabler`: Add support for the "None" method option (`UPSCALER_TYPE=2` / `GOVERLAY_OPTISCALER=0`), add standardized icon to radio button, and update control dimming/enabling behavior.

## Impact

- **Affected files**:
  - `optiscaler_tab.pas`: Add `noneUpscalerRadioButton`, `noneUpscalerLogoImage`, layout calculations for 3 method options, opacity/enabled state updates.
  - `overlayunit.pas` / `overlayunit.lfm`: Form control definitions.
  - `overlay_config.pas`: Serialize `UPSCALER_TYPE=2` and `GOVERLAY_OPTISCALER=0`.
  - `sidebar_nav.pas`: Update tool state determination for Upscalers (OptiScaler OR Lossless).
  - `assets/icons/upscaler_none.png` (or `data/icons/upscaler_none.png`): Dedicated icon for "None" method.
- **Dependencies**: No external library additions.
