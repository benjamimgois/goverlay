## 1. Config Templates and bgmod Decoupling

- [x] 1.1 Update `bgmod.conf` and `data/bgmod/bgmod.conf` templates to include `GOVERLAY_VKSUMI=0` under `[Config]`.
- [x] 1.2 In `bgmod.lpr`, read `GOverlayVkSumi` from `[Config]` (defaulting to `'0'`), copy/delete `vkSumi.conf` conditionally based on `GOverlayVkSumi`, and export `ENABLE_VKSUMI=1` only when `GOverlayVkSumi` is true.

## 2. Default Detection and Save Logic

- [x] 2.1 In `overlay_config.pas`, implement `IsVkSumiAtDefaults` helper function checking all 15 trackbar positions against `PARAMS[i].Default`.
- [x] 2.2 In `overlay_config.pas` (`SaveVkSumiConfig`), evaluate default state and write `GOVERLAY_VKSUMI` as `0` or `1` in `bgmod.conf` without modifying `GOVERLAY_VKBASALT`.
- [x] 2.3 In `overlay_config.pas` (`SaveVkBasaltConfig`), ensure saving vkBasalt configuration sets `GOVERLAY_VKBASALT` without modifying `GOVERLAY_VKSUMI`.

## 3. Launch Scripts and Navigation Alignment

- [x] 3.1 In `sidebar_nav.pas` and `data/fgmod/fgmod`, update environment export templates to export `ENABLE_VKSUMI=1` only when `GOVERLAY_VKSUMI=1`.

## 4. Verification and Automated Testing

- [x] 4.1 In `tests/logic/logic_test_cases.pas`, add tests for `IsVkSumiAtDefaults` and `GOVERLAY_VKSUMI` config persistence.
- [x] 4.2 In `tests/gui/gui_test_cases.pas`, add tests validating roundtrip slider customization and `bgmod.conf` flag synchronization.
- [x] 4.3 Run full logic and GUI test suites (`test-logic`, `test-gui`) and compile release binaries.
