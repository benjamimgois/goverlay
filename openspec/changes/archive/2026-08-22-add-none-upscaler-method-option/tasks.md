## 1. Asset Creation

- [x] 1.1 Create `data/icons/upscaler_none.svg` and generate `assets/icons/upscaler_none.png` matching the visual style of OptiScaler and DLSS Enabler logos.

## 2. UI Implementation in OptiScaler Tab

- [x] 2.1 Add `noneUpscalerRadioButton` and `noneUpscalerLogoImage` to `optiscaler_tab.pas` with appropriate DarkRadio styling and click handlers.
- [x] 2.2 Update `ReflowOptiScalerTabNew` in `optiscaler_tab.pas` to layout 3 method columns (OptiScaler, DLSS Enabler, None) inside `FOsUpscalerCard`.
- [x] 2.3 Implement `UpdateUpscalerImageOpacity` and control dimming/enabling when "None" is checked vs when OptiScaler or DLSS Enabler is checked.

## 3. Configuration Persistence & Loading

- [x] 3.1 Update `SaveOptiScalerConfig` in `optiscaler_tab.pas` and `overlay_config.pas` to write `UPSCALER_TYPE=2` and `GOVERLAY_OPTISCALER=0` when "None" is selected.
- [x] 3.2 Update `LoadOptiScalerConfig` in `optiscaler_tab.pas` to restore `noneUpscalerRadioButton.Checked := True` when `UPSCALER_TYPE=2` and apply visual states.

## 4. Sidebar Compound State Integration

- [x] 4.1 Update `GetGameToolEnabled` in `sidebar_nav.pas` to report "Upscalers" ON if either `GOVERLAY_OPTISCALER=1` or `GOVERLAY_LOSSLESS=1`.
- [x] 4.2 Update `SetGameToolEnabled` in `sidebar_nav.pas` to set both `GOVERLAY_OPTISCALER=0` and `GOVERLAY_LOSSLESS=0` when toggling Upscalers OFF from the sidebar.

## 5. Verification & Testing

- [x] 5.1 Compile with `make clean && make` and verify zero errors or regression warnings.
- [x] 5.2 Test switching between OptiScaler, DLSS Enabler, and None, verifying `bgmod.conf` contents and independent Lossless Scaling behavior.
