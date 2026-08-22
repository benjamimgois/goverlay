## Context

See `proposal.md` for background and motivation.

Currently, `FOsUpscalerCard` ("Method") inside `optiscaler_tab.pas` creates two radio buttons: `optiscalerRadioButton` (OptiScaler) and `dlssenablerRadioButton` (DLSS Enabler). In `overlay_config.pas`, saving the upscaler configuration unconditionally writes `GOVERLAY_OPTISCALER=1`.

The launcher wrapper `bgmod` already handles `GOVERLAY_OPTISCALER=0` (skipping proxy DLL injection and cleaning up existing DLLs) and `GOVERLAY_LOSSLESS=1` (activating `lsfg-vk`) as independent subsystems.

## Goals / Non-Goals

**Goals:**
- Add a `"None"` radio option with a dedicated, standardized graphical logo/icon in the "Method" card.
- Adjust `optiscaler_tab.pas` layout to neatly distribute 3 options across `FOsUpscalerCard`: OptiScaler, DLSS Enabler, and None.
- Persist `UPSCALER_TYPE=2` and `GOVERLAY_OPTISCALER=0` when "None" is chosen.
- Disable/dim configuration controls on the Options card when "None" is selected to provide immediate visual feedback.
- Update `sidebar_nav.pas` so that the "Upscalers" switch considers either `GOVERLAY_OPTISCALER=1` or `GOVERLAY_LOSSLESS=1` as active.

**Non-Goals:**
- Modifying `bgmod.lpr` injection internals (which already supports `GOVERLAY_OPTISCALER=0` alongside `GOVERLAY_LOSSLESS=1`).
- Altering the Lossless Scaling tab structure or settings serialization (`lsfg.toml`).

## Decisions

### 1. Dedicated Standardized "None" Icon
- Create `data/icons/upscaler_none.svg` and `assets/icons/upscaler_none.png` following the exact typography, height, and badge style of `upscaler_optiscaler.png` and `upscaler_dlss_enabler.png`.
- Stylized with a clean slate-grey badge and disabled/slash icon with text "NONE" in bold modern font.

### 2. Method Card 3-Column Layout in `optiscaler_tab.pas`
- Divide `CardW` by 3 items:
  ```pascal
  ItemW := (CardW - 2 * PAD) div 3;
  LogoW := Min(100, Max(40, ItemW - 28));
  ```
- Position controls:
  - Column 1: `optiscalerRadioButton` + `optiscalerLogoImage`
  - Column 2: `dlssenablerRadioButton` + `dlssEnablerLogoImage`
  - Column 3: `noneUpscalerRadioButton` + `noneUpscalerLogoImage`

### 3. UpscalerType Index Mapping
- `0`: OptiScaler (`GOVERLAY_OPTISCALER=1`)
- `1`: DLSS Enabler (`GOVERLAY_OPTISCALER=1`)
- `2`: None (`GOVERLAY_OPTISCALER=0`)

### 4. Sidebar Compound Tool State (`sidebar_nav.pas`)
- For `AToolIdx = 2` ("Upscalers"):
  - Read: `(Ini.ReadString('Config', 'GOVERLAY_OPTISCALER', '0') = '1') or (Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '0') = '1')`.
  - Write `False`: Sets both `GOVERLAY_OPTISCALER=0` and `GOVERLAY_LOSSLESS=0`.

## Risks / Trade-offs

- [Width constraint in Method card with 3 options] → The Method card is 50% width (~295px on standard 619px form). Dividing by 3 yields ~90px per column. Using 20px radio buttons and ~60-70px logo images ensures clean, unclipped placement.
