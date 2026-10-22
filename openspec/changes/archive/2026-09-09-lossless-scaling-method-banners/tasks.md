## 1. Asset Deployment

- [x] 1.1 Copy generated high-resolution transparent banners `method_lsfg.png` and `method_mako.png` into `assets/icons/` and verify with `file assets/icons/method_*.png`
- [x] 1.2 Update asset loading in `TLosslessScalingTabHelper.InitTab` to load `assets/icons/method_lsfg.png` into `FLsfgPngLogo` and `assets/icons/method_mako.png` into `FMakoPngLogo` with fallback

## 2. UI Code Refactor in lossless_scaling_tab.pas

- [x] 2.1 Remove `FLsLsfgLbl` and `FLsMakoLbl` field declarations, creation, and event bindings
- [x] 2.2 Update `FLsMethodCard` layout calculations in `SetupLayout` for `LogoW_Lsfg := 117` and `LogoW_Mako := 97` at 36px height, centered vertically in `GPU_GH`
- [x] 2.3 Update `UpdateMethodImageOpacity` to control opacity purely via `TImage.Enabled` without label references

## 3. Build and Verification

- [x] 3.1 Build GOverlay using `lazbuild -B goverlay.lpi` and verify clean compilation
- [x] 3.2 Test interactive selection and opacity dimming across None, LSFG-VK, and MAKO methods
