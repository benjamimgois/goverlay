# Tasks

## 1. Constants & Key Infrastructure

- [x] 1.1 Declare new configuration keys in `configkeys.pas` (`OPTI_KEY_FSR4_PRESET`, `OPTI_KEY_FG_NVNGX`, `MANGO_FLAG_DX_API`, `MANGO_FLAG_TEXT_OUTLINE`, `HELIX_KEY_SHARPENER`, `HELIX_KEY_SHARPNESS`, `HELIX_KEY_WAVESIZE`, `VKSUMI_KEY_COMPARE`, `VKSUMI_KEY_DALTONIZE`) and verify compilation.
- [x] 1.2 Add hint tooltips and UI strings in `hintsunit.pas` and `goverlay_strings.pas` and verify clean build.

## 2. OptiScaler Controls

- [x] 2.1 Handle `Fsr4Preset` and `FGNvngxReplacement` in `overlay_config.pas` with standard `auto` serialization into `OptiScaler.ini` without cluttering the UI with redundant dropdowns.

## 3. MangoHud Controls

- [x] 3.1 Verify `dx_api` checkbox in `mangohud_ui.pas` and add `text_outline` toggle, verifying inclusion in `MangoHud.conf`.

## 4. HelixSR & vkSumi Controls

- [x] 4.1 Add HelixSR sharpener, sharpness slider, and wave size controls in `optiscaler_tab.pas` and verify persistence into `helixsr.ini`.
- [x] 4.2 Add vkSumi compare mode toggle and daltonize dropdown in `vkbasalt_tab.pas` and verify persistence into `vksumi.conf`.

## 5. Verification & Testing

- [x] 5.1 Run full project compilation (`make goverlay` and `make pascube`) and verify zero errors.
- [x] 5.2 Execute test suite (`make test-logic` and `make test-gui`) and verify all automated test cases pass.
