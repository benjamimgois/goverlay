# Tasks

## 1. Constants & Form Checkboxes

- [x] 1.1 Add `ENV_PROTON_ZLUDA`, `ENV_PROTON_SONY_WINDOWS_DEVICE_NAMES`, `ENV_PROTON_STEAM_INPUT_XBOX_PROMPTS`, `ENV_PROTON_SONY_AUTO_XINPUT`, `ENV_PROTON_SONY_HIDRAW_XINPUT`, and `ENV_PROTON_DUALSENSE_HAPTICS_PREFER_NON_EVENT` constants to `configkeys.pas`.
- [x] 1.2 Add the corresponding hidden `TCheckBox` fields to `Tgoverlayform` in `overlayunit.pas` and initialize/reset them in `tweaks_md3.pas` (`InitTweaksMD3`, `GetTweakRowCheckBox`, clear/reset logic).

## 2. Controllers Category, GE Badge & Tweak Rows

- [x] 2.1 Add `TWEAK_CAT_CONTROLLERS` in `tweaks_md3.pas`, update `TweakCategoryName`, `CatNames`, and all predefined category loops (`0..5`) for painting and hit-testing.
- [x] 2.2 Add `[GE]` / `[proton-ge]` badge rendering in `tweaks_md3.pas` (`BadgeText := 'GE'`).
- [x] 2.3 Move `PROTON_USE_SDL=1` to `TWEAK_CAT_CONTROLLERS` and add `PROTON_ZLUDA=1` (`TWEAK_CAT_EXPERIMENTAL`, `[proton-cachyos]`) plus the 5 Proton-GE controller variables (`TWEAK_CAT_CONTROLLERS`, `[GE]`) to `TWEAK_ROWS` with English descriptions.

## 3. Persistence & Build Verification

- [x] 3.1 Update `IsKnownTweakKey`, `SaveTweaksConfig` (writing `'0'` for `PROTON_SONY_AUTO_XINPUT` and `'1'` for the others), and `LoadTweaksFromFGMod` in `tweaks_md3.pas`.
- [x] 3.2 Build Goverlay (`lazbuild`) and verify zero compilation errors and clean Tweaks card layout/persistence.
